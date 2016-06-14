//
//  BYTopScrollView.h
//  Pods
//
//  Created by 刘亚东 on 16/5/15.
//
//
/**
 *  顶部类目滚动view
 */

#import <UIKit/UIKit.h>

static CGFloat kTopScrollHeight = 40.0;

@class BYTopScrollView;
@protocol BYTopScrollViewDelegate <NSObject>

@required

- (void)topScrollView:(BYTopScrollView *)scrollView didSelectedAtIndex:(NSInteger)index;

@end

@interface BYTopScrollView : UIView
/**
 *  delegate
 */
@property (nonatomic, weak) id<BYTopScrollViewDelegate> delegate;
/**
 *  是否显示底部横线，默认YES,即显示
 */
@property (nonatomic, assign) BOOL showBttomLine;
/**
 *  传递类目数组
 */
@property (nonatomic, strong) NSArray<NSString *> *titleArray;
/**
 *  字体大小
 */
@property (nonatomic, assign) CGFloat normalFontSize;
/**
 *  选中时的字体大小
 */
@property (nonatomic, assign) CGFloat selectedFontSize;
/**
 *  字体颜色
 */
@property (nonatomic, strong) UIColor *normalColor;
/**
 *  选中时的字体颜色
 */
@property (nonatomic, strong) UIColor *selectedColor;
/**
 *  底部line的颜色
 */
@property (nonatomic, strong) UIColor *bottomLineColor;

@end
