//
//  UITableView+FancyTableView.m
//  Pods
//
//  Created by 刘亚东 on 16/6/6.
//
//

#import "UITableView+FancyTableView.h"
#import <objc/runtime.h>
#import <BlocksKit/BlocksKit.h>

static char kFancyDataSourceKey;
static char kSectionMapKey;

@implementation UITableView (FancyDataSource)

- (BYFancyDataSource *)by_dataSource {
    BYFancyDataSource *ds = objc_getAssociatedObject(self, &kFancyDataSourceKey);
    if (!ds) {
        ds = [[BYFancyDataSource alloc] initWithTableView:self];
        objc_setAssociatedObject(self, &kFancyDataSourceKey, ds, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (!self.dataSource) {
            self.dataSource = ds;
            self.delegate = ds;
        }
    }
    return ds;
}

- (NSDictionary *)by_sectionMap {
    NSMutableDictionary *sectionMap = objc_getAssociatedObject(self, &kSectionMapKey);
    if (!sectionMap) {
        sectionMap = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kSectionMapKey, sectionMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return sectionMap;
}

@end

@implementation UITableView (FancyTableView)

- (void)by_configTableView:(void (^)(BYTableViewProtoFactory *))block
{
    BYTableViewProtoFactory *config = [[BYTableViewProtoFactory alloc] init];
    block(config);
    
    NSArray *configs = [config install];
    [configs bk_each:^(NSDictionary *config) {
        NSInteger type = (config[@"type"] ? [config[@"type"] integerValue] : 1);
        if (type == 0) {
            if (config[@"nibName"]) {
                UINib *nib = [UINib nibWithNibName:config[@"nibName"] bundle:nil];
                [self.by_dataSource registerNib:nib
                        headerFooterViewClass:NSStringFromClass(config[@"class"])
                                  forIdentifier:config[@"proto"]];
            } else {
                [self.by_dataSource registerHeaderFooterView:NSClassFromString(config[@"class"])
                                               forIdentifier:config[@"proto"]];
            }
        } else {
            if (config[@"nibName"]) {
                UINib *nib = [UINib nibWithNibName:config[@"nibName"] bundle:nil];
                [self.by_dataSource registerNib:nib
                                      cellClass:NSClassFromString(config[@"class"])
                                  forIdentifier:config[@"proto"]];
            } else {
                [self.by_dataSource registerCell:NSClassFromString(config[@"class"])
                                   forIdentifier:config[@"proto"]];
            }
        }
        
    }];
}

- (void)by_setup:(void (^)(BYTableViewMaker *))block
{
    BYTableViewMaker *maker = [[BYTableViewMaker alloc] init];
    block(maker);
    
    NSArray *sections = [maker install];
    
    [self.by_dataSource updateAll:sections];
    
    [sections bk_each:^(BYFancySection *section) {
        [self.by_sectionMap setValue:section forKey:section.key];
    }];
    
    [self reloadData];
}

- (void)by_append:(void (^)(BYTableViewMaker *))block
{
    
}

- (void)by_replaceSection:(NSString *)tag block:(void (^)(BYTableViewMaker *))block
{
    BYFancySection *section = self.by_sectionMap[tag];
    if (section) {
        BYTableViewMaker *maker = [[BYTableViewMaker alloc] init];
        block(maker);
        NSArray *sections = [maker install];
        if ([sections count] > 0) {
            BYFancySection *newSection = sections[0];
            [section.rows removeAllObjects];
            [section.rows addObjectsFromArray:newSection.rows];
        }
    }
}

@end
