//
//  BYTableViewMaker.m
//  Pods
//
//  Created by 刘亚东 on 16/6/7.
//
//

#import "BYTableViewMaker.h"
#import <BlocksKit/BlocksKit.h>

@implementation BYTableViewSectionMaker

- (instancetype)init {
    if (self = [super init]) {
        _section = [[BYFancySection alloc] init];
    }
    return self;
}

@end

@implementation BYTableViewRowMaker

- (instancetype)init {
    if (self = [super init]) {
        _row = [[BYFancyRow alloc] init];
    }
    return self;
}

- (BYTableViewRowMaker *(^)(CGFloat))height {
    return ^id(CGFloat height) {
        self.row.height = height;
        return self;
    };
}

- (BYTableViewRowMaker *(^)(id))model {
    return ^id(id m) {
        self.row.rawModel = m;
        return self;
    };
}

- (BYTableViewRowMaker *(^)(NSString *))tag {
    return ^id(NSString *t) {
        self.row.tag = t;
        return self;
    };
}

- (BYTableViewRowMaker *(^)(SEL))configureSEL {
    return ^id(SEL s) {
        self.row.configSel = s;
        return self;
    };
}

- (BYTableViewRowMaker *(^)(SEL))heightSEL {
    return ^id(SEL s) {
        self.row.heightSel = s;
        return self;
    };
}

- (BYTableViewRowMaker *(^)(UITableViewCell *(^)(id)))constructBlock {
    return ^id(UITableViewCell *(^block)(id)) {
        self.row.constructBlock = block;
        return self;
    };
}

- (BYTableViewRowMaker *(^)(void (^)(id)))selectBlock {
    return ^id(void (^selectHandler)(id)) {
        self.row.selectHandler = selectHandler;
        return self;
    };
}

@end

@interface BYTableViewMaker ()

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) BYTableViewSectionMaker *currentSectionMaker;

@end

@implementation BYTableViewMaker

- (instancetype)init {
    if (self = [super init]) {
        _sections = [NSMutableArray array];
    }
    return self;
}

- (BYTableViewSectionMaker *(^)(NSString *key))section {
    return ^id(NSString *key) {
        BYTableViewSectionMaker *sectionMaker = [[BYTableViewSectionMaker alloc] init];
        [_sections addObject:sectionMaker];
        _currentSectionMaker = sectionMaker;
        sectionMaker.section.key = key;
        return sectionMaker;
    };
}

- (BYTableViewRowMaker *(^)(NSString *))row {
    return ^id(NSString *proto) {
        BYTableViewRowMaker *rowMaker = [[BYTableViewRowMaker alloc] init];
        rowMaker.row.protoType = proto;
        [_currentSectionMaker.section.rows addObject:rowMaker.row];
        return rowMaker;
    };
}

- (BYTableViewRowMaker *(^)(NSString *))sectionHeader {
    return ^id(NSString *proto){
        BYTableViewRowMaker *rowMaker = [[BYTableViewRowMaker alloc] init];
        rowMaker.row.protoType = proto;
        _currentSectionMaker.section.headerView = rowMaker.row;
        return rowMaker;
    };
}

- (BYTableViewRowMaker *(^)(NSString *))sectionFooter
{
    return ^id(NSString *proto){
        BYTableViewRowMaker *rowMaker = [[BYTableViewRowMaker alloc] init];
        rowMaker.row.protoType = proto;
        _currentSectionMaker.section.footerView = rowMaker.row;
        return rowMaker;
    };
}

- (NSArray *)install {
    return [_sections bk_map:^id(BYTableViewSectionMaker *sectionMaker) {
        return sectionMaker.section;
    }];
}

@end
