//
//  BYImitateRequest.m
//  Pods
//
//  Created by 刘亚东 on 16/5/8.
//
//

#import "BYImitateRequest.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (md5)

+ (NSString *)bynetworking_md5:(NSString *)string;

@end

@implementation NSString (md5)

+ (NSString *)bynetworking_md5:(NSString *)string {
    if (string == nil || [string length] == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    
    return [ms copy];
}

@end

static NSString *by_baseUrl = nil;
static BOOL by_enableDebug = NO;
static BOOL by_autoEncode = NO;
static BOOL by_shouldCallbackOnCancleRequest = YES;
static NSDictionary *by_httpHeaders = nil;
static BYNetworkStatus by_netWorkStatus = kBYNetworkStatusUnknown;
static BYRequestType by_requestType = kBYRequesTypeJSON;
static BYResponseType by_responseType = kBYResponseTypeJSON;
static NSMutableArray *by_requestTasks = nil;
static NSTimeInterval by_timeout = 60.0f;


@implementation BYImitateRequest

+ (void)updateBaseUrl:(NSString *)baseUrl {
    by_baseUrl = baseUrl;
}

+ (NSString *)baseUrl {
    return by_baseUrl;
}

+ (void)setTimeOut:(NSTimeInterval)timeout {
    by_timeout = timeout;
}

+ (void)enableDebug:(BOOL)isDebug {
    by_enableDebug = isDebug;
}

+ (BOOL)isDebug {
    return by_enableDebug;
}

+ (void)configRequestType:(BYRequestType)requestType
             responseType:(BYResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
shouldCallbackOnCancleRequest:(BOOL)shouldCallbackOnCancleRequest {
    by_requestType = requestType;
    by_responseType = responseType;
    by_autoEncode = shouldAutoEncode;
    by_shouldCallbackOnCancleRequest = shouldCallbackOnCancleRequest;
}

+ (BOOL)shouldAutoEncode {
    return by_autoEncode;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    by_httpHeaders = httpHeaders;
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (by_requestTasks = nil) {
            by_requestTasks =  [[NSMutableArray alloc] init];
        }
    });
    return by_requestTasks;
}

+ (void)cancleAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(BYURLSessionTask *  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[BYURLSessionTask class]]) {
                [task cancel];
            }
        }];
        
        [[self allTasks] removeAllObjects];
    };
}

+ (void)cancleRequestWithURL:(NSString *)url {
    if (url == nil) {
        return;
    }
    
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(BYURLSessionTask *  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[BYURLSessionTask class]] && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}

+ (BYURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                         success:(onCompletion)success
                            fail:(onError)fail {
    return [self getWithUrl:url
                     params:nil
               refreshCache:refreshCache
                    success:success
                       fail:fail];
}

+ (BYURLSessionTask *)getWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                    refreshCache:(BOOL)refreshCache
                         success:(onCompletion)success
                            fail:(onError)fail {
    return [self getWithUrl:url
                     params:params
               refreshCache:refreshCache
                   progress:nil
                    success:success
                       fail:fail];
}

+ (BYURLSessionTask *)getWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                    refreshCache:(BOOL)refreshCache
                        progress:(onProgress)progress
                         success:(onCompletion)success
                            fail:(onError)fail {
    return [self _requestWithUrl:url
                          params:params
                      httpMethod:2
                    refreshCache:refreshCache
                        progress:progress
                         success:success
                            fail:fail];
}

+ (BYURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                     refreshCache:(BOOL)refreshCache
                          success:(onCompletion)success
                             fail:(onError)fail {
    return [self postWithUrl:url params:params
                refreshCache:refreshCache
                    progress:nil
                     success:success fail:fail];
}

+ (BYURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                     refreshCache:(BOOL)refreshCache
                         progress:(onProgress)progress
                          success:(onCompletion)success
                             fail:(onError)fail {
    return [self _requestWithUrl:url
                          params:params
                      httpMethod:2
                    refreshCache:refreshCache
                        progress:progress
                         success:success
                            fail:fail];
}

+ (BYURLSessionTask *)_requestWithUrl:(NSString *)url
                               params:(NSDictionary *)params
                            httpMethod:(NSInteger)method
                         refreshCache:(BOOL)refreshCache
                             progress:(onProgress)progress
                              success:(onCompletion)success
                                 fail:(onError)fail {
    AFHTTPSessionManager *manager = [self manager];
    NSString *absoluteString = [self absoluteUrlWithPath:url];
    
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            BYLog(@"url无效，若url包含中文，请尝试Encode url");
            return nil;
        }
    } else {
        NSURL *absoluteUrl = [NSURL URLWithString:absoluteString];
        if (absoluteUrl == nil) {
            BYLog(@"url无效，若url包含中文，请尝试Encode url");
            return nil;
        }
    }
    
    if ([self shouldAutoEncode]) {
        url = [self encodeURL:url];
    }
    
    BYURLSessionTask *session = nil;
    
    if (method == 1) {
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self successResponse:responseObject callBack:success];
            
            [[self allTasks] removeObject:task];
            
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:absoluteString
                                      params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug]) {
                [self logWithFailError:error url:absoluteString params:params];
            }
        }];
    } else if (method == 2){
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            if (progress) {
                progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject callBack:success];
            
            [[self allTasks] removeObject:task];
            
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject url:absoluteString params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug]) {
                [self logWithFailError:error url:absoluteString params:params];
            }
        }];
    }
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
}

#pragma mark - private

+ (AFHTTPSessionManager *)manager {
    // 转圈圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = nil;
    if ([self baseUrl] != nil) {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    } else {
        manager = [AFHTTPSessionManager manager];
    }
    
    switch (by_requestType) {
        case kBYRequesTypeJSON:
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        break;
        case kBYRequestTypePlainText:
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        break;
        default:
        break;
    }
    
    switch (by_responseType) {
        case kBYResponseTypeJSON:
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        break;
        case kBYResponseTypeXML:
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        break;
        case kBYRespnseTypeData:
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        break;
        default:
        break;
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    for (NSString *key in by_httpHeaders.allKeys) {
        if (by_httpHeaders[key] != nil) {
            [manager.requestSerializer setValue:by_httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    manager.requestSerializer.timeoutInterval = by_timeout;
    
    // 设置允许的最大并发数量
    manager.operationQueue.maxConcurrentOperationCount = 3;
    
    return manager;
}

+ (NSString *)absoluteUrlWithPath:(NSString *)path {
    if (path == nil || [path length] == 0) {
        return @"";
    }
    
    if ([self baseUrl] == nil || [[self baseUrl] length] == 0) {
        return path;
    }
    
    NSString *absoluteUrl = path;
    if (![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"]) {
        if ([[self baseUrl] hasSuffix:@"/"]) {
            if ([path hasPrefix:@"/"]) {
                NSMutableString *mutablePath = [NSMutableString stringWithString:path];
                [mutablePath deleteCharactersInRange:NSMakeRange(0, 1)];
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl],mutablePath];
            } else {
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl], path];
            }
        } else {
            if ([path hasPrefix:@"/"]) {
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl], path];
            }else {
                absoluteUrl = [NSString stringWithFormat:@"%@/%@",
                               [self baseUrl], path];
            }
        }
    }
    return absoluteUrl;
}

+ (NSString *)encodeURL:(NSString *)url {
    NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    return url;
}

+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    BYLog(@"\n");
    BYLog(@"\nRequest success, URL: %@\n params:%@\n response:%@\n\n",
          [self generateGETAbsoluteURL:url params:params],
          params,
          [self parseData:response]);
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(id)params {
    NSString *format = @" params: ";
    if (params == nil || ![params isKindOfClass:[NSDictionary class]]) {
        format = @"";
        params = @"";
    }
    
    BYLog(@"\n");
    if ([error code] == NSURLErrorCancelled) {
        BYLog(@"\nRequest was canceled mannully, URL: %@ %@%@\n\n",
                  [self generateGETAbsoluteURL:url params:params],
                  format,
                  params);
    } else {
        BYLog(@"\nRequest error, URL: %@ %@%@\n errorInfos:%@\n\n",
                  [self generateGETAbsoluteURL:url params:params],
                  format,
                  params,
                  [error localizedDescription]);
    }
}

+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0) {
        return url;
    }
    
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}


+ (void)successResponse:(id)responseObject callBack:(onCompletion)success {
    if (success) {
        success([self parseData:responseObject]);
    }
}

+ (id)parseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

+ (void)handleCallbackWithError:(NSError *)error fail:(onError)fail {
    if ([error code] == NSURLErrorCancelled) {
        if (by_shouldCallbackOnCancleRequest) {
            if (fail) {
                fail(error);
            }
        }
    } else {
        if (fail) {
            fail(error);
        }
    }
}

@end
