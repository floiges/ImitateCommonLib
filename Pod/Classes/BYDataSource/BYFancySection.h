//
//  BYFancySection.h
//  Pods
//
//  Created by 刘亚东 on 16/6/6.
//
//

#import <Foundation/Foundation.h>

@class BYFancyRow;

@interface BYFancySection : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) BYFancyRow *headerView;
@property (nonatomic, strong) BYFancyRow *footerView;
@property (nonatomic, strong) NSMutableArray<BYFancyRow *> *rows;

@end
