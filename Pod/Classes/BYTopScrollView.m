//
//  BYTopScrollView.m
//  Pods
//
//  Created by 刘亚东 on 16/5/15.
//
//

#import "BYTopScrollView.h"
#import "BYCategoryCollectionViewCell.h"
#import "BYCategryCollectionReusableView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface BYTopScrollView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *addView;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BYTopScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lineView = [UIView new];
        _buttonArray = [NSMutableArray array];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopScrollHeight)];
        [self addSubview:_scrollView];
        CGRect collectionFrame = CGRectMake(0, kTopScrollHeight, kScreenWidth, 0);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionFrame
                                             collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[kBYCategoryCollectionViewCell class]
            forCellWithReuseIdentifier:kBYCategoryCollectionViewCell];
        [_collectionView registerClass:[kBYCategryCollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kBYCategryCollectionReusableView];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)setButtonArray:(NSMutableArray *)buttonArray {
    //设置数组的时候初始化UI
}

#pragma mark - CollectionView Delegate

#pragma mark - CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBYCategoryCollectionViewCell forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    // 返回标题
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kBYCategryCollectionReusableView forIndexPath:indexPath];
    return reusableView;
}

@end
