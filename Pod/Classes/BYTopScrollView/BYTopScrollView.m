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
#import <BlocksKit/UIView+BlocksKit.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kButtonWidth  100.0

@interface BYTopScrollView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *plusImageView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BYTopScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _showBttomLine = YES;
        _buttonArray = [NSMutableArray array];
        _sectionArray = [NSMutableArray array];

        // scrollview
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - kTopScrollHeight, kTopScrollHeight)];
        _scrollView.bounces = YES;
        [self addSubview:_scrollView];
        // +view
        _plusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - kTopScrollHeight, 0, kTopScrollHeight, kTopScrollHeight)];
        _plusImageView.image = [UIImage imageNamed:@"channel_nav_plus"];
        _plusImageView.contentMode = UIViewContentModeScaleAspectFill;
        _plusImageView.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [_plusImageView bk_whenTapped:^{
            [weakSelf showCollectionView];
        }];
        [self addSubview:_plusImageView];
        
        // lineView
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopScrollHeight - 1.0, kButtonWidth, 1.0)];
        _lineView.backgroundColor = [UIColor redColor];
        [self addSubview:_lineView];
        _lineView.hidden = !_showBttomLine;
        
        // collectionView
        CGRect collectionFrame = CGRectMake(0, 0, kScreenWidth, kTopScrollHeight - 64.0);
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
        _collectionView.hidden = YES;
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)setTitleArray:(NSArray<NSString *> *)titleArray {
    //设置数组的时候初始化UI
    NSParameterAssert(titleArray && titleArray.count > 0);
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.buttonArray removeAllObjects];
    
    [self.titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(idx * kButtonWidth, 0, kButtonWidth, kTopScrollHeight);
        NSAttributedString *normalString =
        [[NSAttributedString alloc] initWithString:obj
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.normalFontSize],NSForegroundColorAttributeName:self.normalColor}];
        NSAttributedString *selectedString =
        [[NSAttributedString alloc] initWithString:obj
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.selectedFontSize],NSForegroundColorAttributeName:self.selectedColor}];
        [button setAttributedTitle:normalString forState:UIControlStateNormal];
        [button setAttributedTitle:selectedString forState:UIControlStateSelected];
        [button bk_whenTapped:^{
            [self selectedButtonAtIndex:idx];
        }];
        [self.scrollView addSubview:button];
        [self.buttonArray addObject:button];
    }];
    self.scrollView.contentSize = CGSizeMake(self.titleArray.count * kButtonWidth, 0);
}

- (void)selectedButtonAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(topScrollView:didSelectedAtIndex:)]) {
        [self.delegate topScrollView:self didSelectedAtIndex:index];
    }
}

- (void)showCollectionView {
    self.scrollView.hidden = YES;
    self.collectionView.hidden = NO;
}

#pragma mark - CollectionView Delegate

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 9.0, 0.0, 9.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleString = self.titleArray[indexPath.item];
    CGSize size = [titleString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]}];
    CGFloat spacing = 3.0;
    return CGSizeMake(size.width + spacing * 2, kTopScrollHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 9.0;
}

#pragma mark - CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
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
