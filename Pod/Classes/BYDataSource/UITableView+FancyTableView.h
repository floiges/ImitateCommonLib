//
//  UITableView+FancyTableView.h
//  Pods
//
//  Created by 刘亚东 on 16/6/6.
//
//

#import <UIKit/UIKit.h>
#import "BYTableViewProtoFactory.h"
#import "BYFancyDataSource.h"
#import "BYTableViewMaker.h"

@interface UITableView (FancyDataSource)

@property (nonatomic, strong, readonly) BYFancyDataSource *by_dataSource;
@property (nonatomic, strong, readonly) NSDictionary *by_sectionMap;


@end

@interface UITableView (FancyTableView)

- (void)by_configTableView:(void(^)(BYTableViewProtoFactory *config))block;

- (void)by_setup:(void(^)(BYTableViewMaker *maker))block;

- (void)by_append:(void(^)(BYTableViewMaker *maker))block;

- (void)by_replaceSection:(NSString *)tag block:(void(^)(BYTableViewMaker *maker))block;

@end
