//
//  BYImitateCache.m
//  Pods
//
//  Created by 刘亚东 on 16/5/10.
//
//

#import "BYImitateCache.h"

static NSString *diskPath = @"com.imitate.cache";
static CGFloat maxCacheAge = 24 * 60 * 60 * 60 * 2; // 缓存2天

@interface BYImitateCache ()

@property (nonatomic, strong) dispatch_queue_t serialQ;
@property (nonatomic, strong) NSCache *cache;// 内存缓存
@property (nonatomic, copy) NSString *diskURLString;

@end

@implementation BYImitateCache

+ (instancetype)sharedCache {
    static dispatch_once_t onceToken;
    static BYImitateCache *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _serialQ = dispatch_queue_create("com.imitate.cache", DISPATCH_QUEUE_SERIAL);
        NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _diskURLString = [[documents firstObject] stringByAppendingPathComponent:diskPath];
        _cache = [[NSCache alloc] init];
        _cache.name = _diskURLString;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)cacheResponse:(NSData *)response forURL:(NSString *)url {
    // 串行队列中缓存
    dispatch_async(self.serialQ, ^{
        [self.cache setObject:response forKey:url cost:response.length];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:self.diskURLString]) {
            [fileManager createDirectoryAtPath:self.diskURLString withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        [fileManager createFileAtPath:[self.diskURLString stringByAppendingPathComponent:url]
                             contents:response
                           attributes:nil];
    });
}

- (NSData *)cachedResponseForURL:(NSString *)url {
    if ([self.cache objectForKey:url]) {
        return [self.cache objectForKey:url];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileURL = [self.diskURLString stringByAppendingPathComponent:url];
    if ([fileManager fileExistsAtPath:fileURL]) {
        NSData *response = [NSData dataWithContentsOfFile:fileURL];
        if (response) {
            [self.cache setObject:response forKey:url cost:response.length];
        }
        return response;
    }
    return nil;
}

- (void)clearMemory {
    [self.cache removeAllObjects];
}

- (void)clearDisk {
    dispatch_async(self.serialQ, ^{
        NSDate *expireDate = [NSDate dateWithTimeIntervalSinceNow:-maxCacheAge];
        NSURL *diskURL = [NSURL fileURLWithPath:self.diskURLString isDirectory:YES];
        NSDirectoryEnumerator *fileEnumertor = [[NSFileManager defaultManager] enumeratorAtURL:diskURL includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLContentModificationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
        for (NSURL *fileURL in fileEnumertor) {
            NSNumber *isDirectory;
            [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            if ([isDirectory boolValue]) {
                continue;
            }
            // compare file date with the max age
            NSDate *fileModificationDate;
            [fileURL getResourceValue:&fileModificationDate forKey:NSURLContentModificationDateKey error:NULL];
            if ([[fileModificationDate laterDate:expireDate] isEqualToDate:expireDate]) {
                [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
            }
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
