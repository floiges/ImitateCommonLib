//
//  BYFancyDataSource.m
//  Pods
//
//  Created by 刘亚东 on 16/6/6.
//
//

#import "BYFancyDataSource.h"
#import "BYFancyRow.h"
#import "BYFancySection.h"

static NSString * const BYFancyProtoTypeIdentifierKey = @"byIdentifier";
static NSString * const BYFancyProtoTypeClassKey = @"byclass";
static NSString * const BYFancyProtoTypeNibKey = @"bynib";

@interface BYFancyDataSource ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *protoTypes;
@property (nonatomic, strong) NSMutableArray *sections;

@end

@implementation BYFancyDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    if (self = [super init]) {
        _tableView = tableView;
        _protoTypes = [NSMutableDictionary dictionary];
        _sections = [NSMutableArray array];
    }
    return self;
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BYFancySection *sec = (section < _sections.count) ? _sections[section] : nil;
    return sec.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BYFancySection *sec = (indexPath.section < _sections.count) ? _sections[indexPath.section] : nil;
    BYFancyRow *row = (sec && indexPath.row < sec.rows.count) ? sec.rows[indexPath.row] : nil;
    if (row) {
        if (row.constructBlock) {
            return row.constructBlock(row.rawModel);
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.protoType forIndexPath:indexPath];
        if (row.configSel) {
            id model = row.rawModel;
            
            NSMethodSignature *ms = [[cell class] instanceMethodSignatureForSelector:row.configSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:ms];
            invocation.target = cell;
            invocation.selector = row.configSel;
            [invocation setArgument:&model atIndex:2];
            [invocation invoke];
        }
        
        if (row.configureBlock) {
            row.configureBlock(row.rawModel);
        }
        
        return cell;
    } else {
        NSLog(@"indexpath : %zd, %zd is empty", indexPath.section, indexPath.row);
        return nil;
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BYFancySection *sec = (indexPath.section < _sections.count) ? _sections[indexPath.section] : nil;
    BYFancyRow *row = (sec && indexPath.row < sec.rows.count) ? sec.rows[indexPath.row] : nil;
    if (row.selectHandler) {
        row.selectHandler(row.rawModel);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BYFancySection *sec = (indexPath.section < _sections.count) ? _sections[indexPath.section] : nil;
    BYFancyRow *row = (sec && indexPath.row < sec.rows.count) ? sec.rows[indexPath.row] : nil;
    
    if (row.height != CGFLOAT_MIN) {
        return row.height;
    } else if (row.heightSel) {
        Class cls = (_protoTypes[row.protoType] ? _protoTypes[row.protoType][BYFancyProtoTypeClassKey] : nil);
        if (cls) {
            id model = row.rawModel;
            
            NSMethodSignature *ms = [cls methodSignatureForSelector:row.heightSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:ms];
            invocation.target = cls;
            invocation.selector = row.heightSel;
            [invocation setArgument:&model atIndex:2];
            [invocation invoke];
            
            CGFloat height;
            [invocation getReturnValue:&height];
            
            return height;
        }
    }
    
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BYFancySection *sec = (section < _sections.count) ? _sections[section] : nil;
    BYFancyRow *header = sec.headerView;
    if (header) {
        return [tableView dequeueReusableCellWithIdentifier:header.protoType];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    BYFancySection *sec = (section < _sections.count) ? _sections[section] : nil;
    BYFancyRow *header = sec.headerView;
    if (header) {
        return header.height;
    } else {
        return CGFLOAT_MIN;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    BYFancySection *sec = (section < _sections.count) ? _sections[section] : nil;
    BYFancyRow *footer = sec.footerView;
    if (footer) {
        return [tableView dequeueReusableCellWithIdentifier:footer.protoType];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    BYFancySection *sec = (section < _sections.count) ? _sections[section] : nil;
    BYFancyRow *footer = sec.footerView;
    if (footer) {
        return footer.height;
    } else {
        return CGFLOAT_MIN;
    }
}

@end


@implementation BYFancyDataSource(ProtoType)

- (void)registerCell:(Class)cellClass forIdentifier:(NSString *)identifier {
    NSAssert(identifier && identifier.length > 0, @"identifier must not be empty");
    NSAssert(!self.protoTypes[identifier], @"%@ was already registered",identifier);
    NSAssert(cellClass != nil, @"cell class must not be nil");
    
    _protoTypes[identifier] = @{BYFancyProtoTypeClassKey : cellClass};
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib cellClass:(Class)cellClass forIdentifier:(NSString *)identifier {
    NSAssert(identifier && identifier.length > 0, @"identifier must not be empty");
    NSAssert(!self.protoTypes[identifier], @"%@ was already registered",identifier);
    NSAssert(cellClass != nil, @"cell class must not be nil");
    NSAssert(nib, @"nib must not be nil");
    
    _protoTypes[identifier] = @{BYFancyProtoTypeClassKey : cellClass,
                                BYFancyProtoTypeNibKey : nib};
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)registerHeaderFooterView:(Class)viewClass forIdentifier:(NSString *)identifier {
    _protoTypes[identifier] = @{BYFancyProtoTypeClassKey : viewClass};
    [self.tableView registerClass:viewClass forHeaderFooterViewReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib headerFooterViewClass:(NSString *)viewClass forIdentifier:(NSString *)identifier {
    _protoTypes[identifier] = @{BYFancyProtoTypeClassKey : viewClass,
                                BYFancyProtoTypeNibKey : nib};
    [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
}

@end

@implementation BYFancyDataSource(Cell)

- (void)updateAll:(NSArray *)sections {
    [self.sections removeAllObjects];
    [self.sections addObjectsFromArray:sections];
}

@end