//
//  BYTableViewCellConfig.m
//  Pods
//
//  Created by 刘亚东 on 16/6/7.
//
//

#import "BYTableViewProtoFactory.h"
#import <BlocksKit/BlocksKit.h>

@interface BYTableViewCellConfig ()

@property (nonatomic, strong) NSMutableDictionary *configs;

@end

@implementation BYTableViewCellConfig

- (instancetype)init {
    if (self = [super init]) {
        _configs = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BYTableViewCellConfig *(^)(NSInteger))type {
    return ^id(NSInteger type) {
        self.configs[@"type"] = @(type);
        return self;
    };
}

- (BYTableViewCellConfig *(^)(NSString *))identifier {
    return ^id(NSString *protoName) {
        self.configs[@"proto"] = protoName;
        return self;
    };
}

- (BYTableViewCellConfig *(^)(NSString *))cls {
    return ^id(NSString *clsName) {
        self.configs[@"class"] = clsName;
        return self;
    };
}

- (BYTableViewCellConfig *(^)(NSString *))nibName {
    return ^id(NSString *nibName) {
        self.configs[@"nibName"] = nibName;
        return self;
    };
}

@end

@interface BYTableViewProtoFactory ()

@property (nonatomic, strong) NSMutableArray *cellConfigs;

@end

@implementation BYTableViewProtoFactory

- (instancetype)init {
    if (self = [super init]) {
        _cellConfigs = [NSMutableArray array];
    }
    return self;
}

- (BYTableViewCellConfig *(^)(NSString *))headerFooterView {
    return ^id(NSString *protoType) {
        BYTableViewCellConfig *protoConfig = [[BYTableViewCellConfig alloc] init];
        protoConfig.type(0).identifier(protoType);
        [self.cellConfigs addObject:protoConfig];
        return protoConfig;
    };
}

- (BYTableViewCellConfig *(^)(NSString *))cell {
    return ^id(NSString *protoType) {
        BYTableViewCellConfig *protoConfig = [[BYTableViewCellConfig alloc] init];
        protoConfig.type(1).identifier(protoType);
        [self.cellConfigs addObject:protoConfig];
        return protoConfig;
    };
}

- (NSArray *)install {
    return [self.cellConfigs bk_map:^id(BYTableViewCellConfig *proto) {
        return proto.configs;
    }];
}

@end
