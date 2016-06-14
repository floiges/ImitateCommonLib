//
//  BYImitateRequest.h
//  Pods
//
//  Created by 刘亚东 on 16/5/8.
//
//
/**
 *  基础网络请求类
 */

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define BYLog(s, ...) NSLog(@"[%@ in line %d] ===============>%@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define BYLog(s, ...)
#endif

// 返回类型
typedef NS_ENUM(NSInteger, BYResponseType) {
    kBYResponseTypeJSON = 1,
    kBYResponseTypeXML  = 2,
    kBYRespnseTypeData  = 3
};

// 请求类型
typedef NS_ENUM(NSInteger, BYRequestType) {
    kBYRequesTypeJSON       = 1,
    kBYRequestTypePlainText = 2 // 普通text/html
};

// 网络类型
typedef NS_ENUM(NSInteger, BYNetworkStatus) {
    kBYNetworkStatusUnknown          = -1,
    kBYNetworkStatusNotReachable     = 0,
    kBYNetworkStatusReachableViaWWAN = 1,//2G，3G,4G
    kBYNetworkStatusReachableViaWiFi = 2
};

@class NSURLSessionTask;

typedef NSURLSessionTask BYURLSessionTask;

// 网络请求成功回调，modelDict用于外部字典转模型
typedef void (^onCompletion)(id modelDict);
// 网络请求失败回调
typedef void (^onError)(NSError *error);
/**
 *  进度
 *
 *  @param bytesWritten      已上传大小
 *  @param totalBytesWritten 总上传大小
 */
typedef void (^onProgress)(int64_t bytesWritten, int64_t totalBytesWritten);

@interface BYImitateRequest : NSObject
/**
 *  指定网络请求接口的基础URL字符串
 *
 *  @param baseUrl 例如sapi.beibei.com
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;
+ (NSString *)baseUrl;
/**
 *  设置请求的超时时间
 *
 *  @param timeout timeout description
 */
+ (void)setTimeOut:(NSTimeInterval)timeout;
/**
 *  是否开启接口打印信息
 *
 *  @param isDebug 默认NO
 */
+ (void)enableDebug:(BOOL)isDebug;
/**
 *  配置请求格式，默认为JSON
 *
 *  @param requestType                   requestType description
 *  @param responseType                  responseType description
 *  @param shouldAutoEncode              是否自动encode url，默认NO
 *  @param shouldCallbackOnCancleRequest 取消请求时，是否要求回调，默认YES。
 */
+ (void)configRequestType:(BYRequestType)requestType
             responseType:(BYResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
shouldCallbackOnCancleRequest:(BOOL)shouldCallbackOnCancleRequest;
/**
 *  配置公用的请求头
 *
 *  @param httpHeaders httpHeaders description
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;
/**
 *  取消所有请求
 */
+ (void)cancleAllRequest;
/**
 *  取消某一个url的请求
 *
 *  @param url url description
 */
+ (void)cancleRequestWithURL:(NSString *)url;
/**
 *  GET请求
 *
 *  @param url          请求地址，若未指定baseurl，则可传完整的url
 *  @param refreshCache 是否刷新缓存
 *  @param success      请求成功回调
 *  @param fail         请求失败回调
 *
 *  @return 返回的对象可取消请求
 */
+ (BYURLSessionTask *)getWithUrl:(NSString *)url
                    refreshCache:(BOOL)refreshCache
                         success:(onCompletion)success
                            fail:(onError)fail;
/**
 *  GET请求
 *
 *  @param url          请求地址，若未指定baseurl，则可传完整的url
 *  @param params       传递请求的参数
 *  @param refreshCache 是否刷新缓存
 *  @param success      请求成功回调
 *  @param fail         请求失败回调
 *
 *  @return 返回的对象可取消请求
 */
+ (BYURLSessionTask *)getWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                    refreshCache:(BOOL)refreshCache
                         success:(onCompletion)success
                            fail:(onError)fail;
/**
 *  GET请求
 *
 *  @param url          请求地址，若未指定baseurl，则可传完整的url
 *  @param params       传递请求的参数
 *  @param refreshCache 是否刷新缓存
 *  @param progress     请求进度
 *  @param success      请求成功回调
 *  @param fail         请求失败回调
 *
 *  @return 返回的对象可取消请求
 */
+ (BYURLSessionTask *)getWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                    refreshCache:(BOOL)refreshCache
                        progress:(onProgress)progress
                         success:(onCompletion)success
                            fail:(onError)fail;
/**
 *  POST请求
 *
 *  @param url          请求地址，若未指定baseurl，则可传完整的url
 *  @param params       传递请求的参数
 *  @param refreshCache 是否刷新缓存
 *  @param success      请求成功回调
 *  @param fail         请求失败回调
 *
 *  @return 返回的对象可取消请求
 */
+ (BYURLSessionTask *)postWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                    refreshCache:(BOOL)refreshCache
                         success:(onCompletion)success
                            fail:(onError)fail;
/**
 *  POST请求
 *
 *  @param url          请求地址，若未指定baseurl，则可传完整的url
 *  @param params       传递请求的参数
 *  @param refreshCache 是否刷新缓存
 *  @param progress     请求进度
 *  @param success      请求成功回调
 *  @param fail         请求失败回调
 *
 *  @return 返回的对象可取消请求
 */
+ (BYURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                     refreshCache:(BOOL)refreshCache
                         progress:(onProgress)progress
                          success:(onCompletion)success
                             fail:(onError)fail;

@end
