//
//  SZTabSwitchBar.m
//  SZTabSwitchBarDemo
//
//  Created by shengzhichen on 15/7/3.
//  Copyright (c) 2015年 shengzhichen. All rights reserved.
//

#import "SZTabSwitchBar.h"
#import "UIView+SZFrameHelper.h"

@interface SZTabSwitchBar ()

@property (nonatomic) CGFloat tabWidth;

@property (nonatomic, strong) UIScrollView *containerScrollView;

@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, strong) UIView *horizontalSeperator;

@property (nonatomic, strong) NSMutableArray<UILabel *> *labelArray;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic) BOOL scrollViewDragging;
@property (nonatomic) NSUInteger draggingIndex;

@end

@implementation SZTabSwitchBar

#pragma mark - 视图生命周期 -

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    if (self) {
        [self tabSwitchBarCommInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self tabSwitchBarCommInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tabSwitchBarCommInit];
    }
    return self;
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset" context:NULL];
    _scrollView = nil;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self reload];
    }
}

#pragma mark - 属性方法 -
- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:YES];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated {
    NSAssert(_titleArray.count == _labelArray.count, @"should invoke -reload before -setCurrentIndex:animated:");
    if (currentIndex >= _titleArray.count) {
        currentIndex = _titleArray.count - 1;
    }
    if (currentIndex != self.currentIndex) {
        [self unHighlightedLabelAtIndex:_currentIndex];
        _currentIndex = currentIndex;
        [self highlightedLabelAtIndex:_currentIndex];
        
        [UIView animateWithDuration:animated?.25:0
                              delay:0
                            options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             CGPoint contentOffset = _scrollView.contentOffset;
                             contentOffset.x = _currentIndex * _scrollView.width;
                             [_scrollView setContentOffset:contentOffset animated:YES];
                             
                             if (_containerScrollView) {
                                 [self updateContainerScrollViewOffsetWithTargetRect:_labelArray[_currentIndex].frame];
                             }
                         } completion:nil];
        if (_tapHandleBlock) {
            _tapHandleBlock(self.currentIndex);
        }
    }
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        if (_scrollView) {
            [_scrollView removeObserver:self forKeyPath:@"contentOffset" context:NULL];
        }
        _scrollView = scrollView;
        
        [_scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionPrior
                         context:NULL];
    }
}

- (void)setScrollViewDragging:(BOOL)scrollViewDragging {
    if (_scrollViewDragging != scrollViewDragging) {
        if (_scrollViewDragging && _currentIndex != _draggingIndex) {
            //结束拖动
            _currentIndex = _draggingIndex;
            
            if (_tapHandleBlock) {
                _tapHandleBlock(self.currentIndex);
            }
        } else {
            //开始拖动
            _draggingIndex = self.currentIndex;
        }
        _scrollViewDragging = scrollViewDragging;
    }
}

- (void)setDraggingIndex:(NSUInteger)draggingIndex {
    if (draggingIndex >= _titleArray.count) {
        draggingIndex = _titleArray.count - 1;
    }
    if (_draggingIndex != draggingIndex) {
        [self unHighlightedLabelAtIndex:_draggingIndex];
        _draggingIndex = draggingIndex;
        [self highlightedLabelAtIndex:_draggingIndex];
    }
}

#pragma mark - 重载方法 -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            self.scrollViewDragging = _scrollView.dragging;
            
            self.draggingIndex = round(_scrollView.contentOffset.x / _scrollView.width);
            
            if (_containerScrollView) {
                if (_scrollView.contentSize.width > 0) {
                    _indicatorView.left = _scrollView.contentOffset.x * _containerScrollView.contentSize.width / _scrollView.contentSize.width;
                    
                    if (_scrollView.dragging || _scrollView.decelerating) {
                        CGRect targetRect = CGRectMake(_scrollView.contentOffset.x * _containerScrollView.contentSize.width / _scrollView.contentSize.width,
                                                       0,
                                                       _tabWidth,
                                                       self.height);
                        [self updateContainerScrollViewOffsetWithTargetRect:targetRect];
                    }
                }
            } else {
                _indicatorView.left = _scrollView.contentOffset.x / _titleArray.count;
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_containerScrollView) {
        _containerScrollView.size = self.size;
    }
}

#pragma mark - 外部方法 -
- (void)reload {
    NSAssert(_titleArray, @"_titleArray = nil");
    NSAssert(_scrollView, @"_scrollView = nil");
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self calculateTabWidth];
    
    [self createTabs];
    
    [self createIndicator];
    
    self.currentIndex = 0;
    [self highlightedLabelAtIndex:_currentIndex];
    
    //增加手势
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabHeaderBarTap:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:_tapGesture];
}

#pragma mark - 内部方法 -
- (void)tabSwitchBarCommInit {
    self.backgroundColor = [UIColor whiteColor];
    
    _textColor = [UIColor grayColor];
    _textFont = [UIFont systemFontOfSize:14];
    
    _highlightedTextColor = [UIColor blackColor];
    _highlightedTextFont = [UIFont boldSystemFontOfSize:16];
    
    _seperatorColor = [UIColor colorWithWhite:0.88 alpha:1];
    
    _indicatorColor = [UIColor redColor];
    
    _showVerticalSeperator = YES;
    
    _horizontalPaddingBetweenTextAndSeperator = 10;
    
    _indicatorHeight = 2;
    
    _labelArray = [NSMutableArray array];
}

- (void)calculateTabWidth {
    for (NSString *title in _titleArray) {
        CGFloat normalHeight = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                   options:kNilOptions
                                                attributes:@{NSFontAttributeName: _textFont}
                                                   context:NULL].size.width;
        _tabWidth = MAX(_tabWidth, ceil(normalHeight) + 2*_horizontalPaddingBetweenTextAndSeperator);
        if (_highlightedTextFont && _highlightedTextFont.lineHeight > _textFont.lineHeight) {
            CGFloat highlightHieght = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                          options:kNilOptions
                                                       attributes:@{NSFontAttributeName: _highlightedTextFont}
                                                          context:NULL].size.width;
            _tabWidth = MAX(_tabWidth, ceil(highlightHieght) + 2*_horizontalPaddingBetweenTextAndSeperator);
        }
    }
    _tabWidth = MAX(_tabWidth, floor([UIScreen mainScreen].bounds.size.width/_titleArray.count));
}

- (void)createTabs {
    UIView *realContainerView = self;
    
    if (_titleArray.count * _tabWidth > [UIScreen mainScreen].bounds.size.width) {
        self.containerScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.containerScrollView.showsVerticalScrollIndicator = NO;
        self.containerScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.containerScrollView];
        realContainerView = self.containerScrollView;
    }
    
    for (int i = 0; i < _titleArray.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*_tabWidth, 0, _tabWidth, self.height)];
        label.text = [_titleArray objectAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = _textFont;
        label.adjustsFontSizeToFitWidth = YES;
        label.tag = i + 100;
        label.textColor = _textColor;
        [realContainerView addSubview:label];
        [_labelArray addObject:label];
        
        if (_containerScrollView && i == _titleArray.count - 1) {
            _containerScrollView.contentSize = CGSizeMake(ceil(label.right), self.containerScrollView.height);
        }
    }
    
    if (_showVerticalSeperator) {
        CGFloat cutOffHeight = self.height*1.0/3;
        //底部垂直分割线
        for (int i=1; i<=_titleArray.count-1; i++) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(_tabWidth*(i),
                                                                    round((self.height-cutOffHeight)/2),
                                                                    .5,
                                                                    round(cutOffHeight))];
            line.backgroundColor = _seperatorColor;
            [realContainerView addSubview:line];
        }
    }
}

- (void)createIndicator {
    _horizontalSeperator = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    self.height-(1.0/[UIScreen mainScreen].scale),
                                                                    [UIScreen mainScreen].bounds.size.width,
                                                                    (1.0/[UIScreen mainScreen].scale))];
    _horizontalSeperator.backgroundColor = _seperatorColor;
    [self addSubview:_horizontalSeperator];
    
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-_indicatorHeight, _tabWidth, _indicatorHeight)];
    _indicatorView.backgroundColor = _indicatorColor;
    if (_containerScrollView) {
        [_containerScrollView addSubview:_indicatorView];
    } else {
        [self addSubview:_indicatorView];
    }
}

- (void)tabHeaderBarTap:(UIGestureRecognizer *)recognizer {
    //手势处理，根据点的位置
    if (_containerScrollView) {
        CGPoint tapPoint = [recognizer locationInView:_containerScrollView];
        self.currentIndex = tapPoint.x / _tabWidth;
    } else {
        CGPoint tapPoint = [recognizer locationInView:self];
        self.currentIndex = tapPoint.x / _tabWidth;
    }
}

- (void)unHighlightedLabelAtIndex:(NSUInteger)index {
    UILabel *label = _labelArray[index];
    label.textColor = self.textColor;
    label.font = self.textFont;
}

- (void)highlightedLabelAtIndex:(NSUInteger)index {
    UILabel *label = _labelArray[index];
    label.textColor = self.highlightedTextColor ? self.highlightedTextColor : self.textColor;
    label.font = self.highlightedTextFont ? self.highlightedTextFont : self.textFont;
}

- (void)updateContainerScrollViewOffsetWithTargetRect:(CGRect)targetRect {
    CGFloat offsetX = _containerScrollView.contentOffset.x;
    CGFloat dx = (targetRect.origin.x - offsetX) - (self.frame.size.width/2 - targetRect.size.width/2);
    if (offsetX + dx < 0) {
        dx = 0 - offsetX;
    } else if (offsetX + dx > _containerScrollView.contentSize.width - _containerScrollView.frame.size.width) {
        dx = _containerScrollView.contentSize.width - _containerScrollView.frame.size.width - offsetX;
    }
    [_containerScrollView setContentOffset:CGPointMake(offsetX + dx, 0)];
}

@end
