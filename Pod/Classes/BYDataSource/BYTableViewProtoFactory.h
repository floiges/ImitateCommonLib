//
//  BYTableViewCellConfig.h
//  Pods
//
//  Created by 刘亚东 on 16/6/7.
//
//

#import <UIKit/UIKit.h>
#import "BYFancyDataSource.h"

@interface BYTableViewCellConfig : NSObject

@property (nonatomic, copy) BYTableViewCellConfig *(^type)(NSInteger);
@property (nonatomic, copy) BYTableViewCellConfig *(^identifier)(NSString *protoName);
@property (nonatomic, copy) BYTableViewCellConfig *(^cls)(NSString *clsName);
@property (nonatomic, copy) BYTableViewCellConfig *(^nibName)(NSString *nibName);

@end

@interface BYTableViewProtoFactory : NSObject

@property (nonatomic, copy) BYTableViewCellConfig *(^headerFooterView)(NSString *protoType);
@property (nonatomic, copy) BYTableViewCellConfig *(^cell)(NSString *protoType);

- (NSArray *)install;

@end
