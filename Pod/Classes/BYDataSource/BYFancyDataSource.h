//
//  BYFancyDataSource.h
//  Pods
//
//  Created by 刘亚东 on 16/6/6.
//
//

#import <UIKit/UIKit.h>

@interface BYFancyDataSource : NSObject<UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView;

@end

@interface BYFancyDataSource (ProtoType)

- (void)registerCell:(Class)cellClass forIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib cellClass:(Class)cellClass forIdentifier:(NSString *)identifier;
- (void)registerHeaderFooterView:(Class)viewClass forIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib headerFooterViewClass:(NSString *)viewClass forIdentifier:(NSString *)identifier;

@end

@interface BYFancyDataSource (Cell)

- (void)updateAll:(NSArray *)sections;

@end
