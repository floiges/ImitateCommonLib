//
//  BYFancyRow.h
//  Pods
//
//  Created by 刘亚东 on 16/6/6.
//
//

#import <UIKit/UIKit.h>

@interface BYFancyRow : NSObject

@property (nonatomic, copy) NSString *protoType;

@property (nonatomic, strong) id rawModel;

@property (nonatomic, copy) NSString *tag;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) SEL configSel;

@property (nonatomic, assign) SEL heightSel;

@property (nonatomic, copy) void (^selectHandler)(id);

@property (nonatomic, copy) UITableViewCell * (^constructBlock)(id);

@property (nonatomic, copy) void (^configureBlock)(id);

@end
