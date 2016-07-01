//
//  SZTabSwitchBar.h
//  SZTabSwitchBarDemo
//
//  Created by shengzhichen on 15/7/3.
//  Copyright (c) 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SZTabSwitchBarTapBlock)(NSUInteger index);


/**
 *  @brief  标签切换工具栏, 属性设置后需要调用 -setup 方法
 */
@interface SZTabSwitchBar : UIView

@property (nonatomic) NSUInteger currentIndex;

//默认值: [UIColor grayColor]
@property (nonatomic, strong, nullable) UIColor *textColor;

//默认值: [UIFont systemFontOfSize:14]
@property (nonatomic, strong, nullable) UIFont *textFont;

//默认值: [UIColor blackColor]
@property (nonatomic, strong, nullable) UIColor *highlightedTextColor;

//默认值: [UIFont boldSystemFontOfSize:16]
@property (nonatomic, strong, nullable) UIFont *highlightedTextFont;

//默认值: YES
@property (nonatomic) BOOL showVerticalSeperator;

//默认值: [UIColor colorWithWhite:0.88 alpha:1]
@property (nonatomic, strong, nullable) UIColor *seperatorColor;

//默认值: 10.0
@property (nonatomic) CGFloat horizontalPaddingBetweenTextAndSeperator;

//默认值: [UIColor redColor]
@property (nonatomic, strong, nullable) UIColor *indicatorColor;

//默认值: 2.0
@property (nonatomic) CGFloat indicatorHeight;

@property (nonatomic, strong, nonnull) UIScrollView *scrollView;

@property (nonatomic, strong, nonnull) NSArray *titleArray;

@property (nonatomic, copy, nullable) SZTabSwitchBarTapBlock tapHandleBlock;

- (void)reload;

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
