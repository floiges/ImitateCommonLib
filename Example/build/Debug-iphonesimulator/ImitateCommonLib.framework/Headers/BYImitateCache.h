//
//  BYImitateCache.h
//  Pods
//
//  Created by 刘亚东 on 16/5/10.
//
//

#import <Foundation/Foundation.h>

@interface BYImitateCache : NSObject

+ (instancetype)sharedCache;
/**
 *  根据URL缓存response
 *
 *  @param response 返回的结果
 *  @param url      url
 */
- (void)cacheResponse:(NSData *)response forURL:(NSString *)url;
/**
 *  取缓存
 *
 *  @param url URL
 *
 *  @return response
 */
- (NSData *)cachedResponseForURL:(NSString *)url;

- (void)clearDisk;

- (void)clearMemory;

@end
