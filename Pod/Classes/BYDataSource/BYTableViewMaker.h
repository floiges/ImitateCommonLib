//
//  BYTableViewMaker.h
//  Pods
//
//  Created by 刘亚东 on 16/6/7.
//
//

#import <Foundation/Foundation.h>
#import "BYFancySection.h"
#import "BYFancyRow.h"

@interface BYTableViewSectionMaker : NSObject

@property (nonatomic, strong) BYFancySection *section;

@end

@interface BYTableViewRowMaker : NSObject

@property (nonatomic, strong) BYFancyRow *row;
@property (nonatomic, copy) BYTableViewRowMaker *(^height)(CGFloat height);
@property (nonatomic, copy, readonly) BYTableViewRowMaker *(^model)(id model);
@property (nonatomic, copy, readonly) BYTableViewRowMaker *(^tag)(NSString *tag);
@property (nonatomic, copy, readonly) BYTableViewRowMaker *(^configureSEL)(SEL selector);
@property (nonatomic, copy, readonly) BYTableViewRowMaker *(^heightSEL)(SEL selector);
@property (nonatomic, copy, readonly) BYTableViewRowMaker *(^constructBlock)(UITableViewCell *(^)(id));
@property (nonatomic, copy, readonly) BYTableViewRowMaker *(^selectBlock)(void(^)(id));
@property (nonatomic, copy, readonly) BYTableViewRowMaker *(^configureBlock)(void(^)(id));

@end

@interface BYTableViewMaker : NSObject

@property (nonatomic, copy) BYTableViewSectionMaker *(^section)(NSString *key);

@property (nonatomic, copy) BYTableViewRowMaker *(^sectionHeader)(NSString *proto);

@property (nonatomic, copy) BYTableViewRowMaker *(^sectionFooter)(NSString *proto);

@property (nonatomic, copy) BYTableViewRowMaker *(^row)(NSString *proto);

- (NSArray *)install;

@end
