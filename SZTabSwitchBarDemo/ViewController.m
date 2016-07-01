//
//  ViewController.m
//  SZTabSwitchBarDemo
//
//  Created by 陈圣治 on 15/12/4.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "ViewController.h"
#import "SZTabSwitchBar.h"
#import "UIView+SZFrameHelper.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet SZTabSwitchBar *switchBar;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    _switchBar.titleArray = @[
                              @"测试0",
                              @"测试1",
                              @"测试2",
                              @"测试3",
                              @"测试4",
                              @"测试5",
                              @"测试6",
                              @"测试7",
                              @"测试8",
                              @"测试9",
                              ];
    _switchBar.scrollView = _scrollView;

    [_scrollView layoutIfNeeded];
    _scrollView.scrollsToTop = NO;

    for (int i = 0; i < _switchBar.titleArray.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
        [_scrollView addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;

        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_scrollView
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1
                                                                           constant:_scrollView.width * i];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_scrollView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:0];
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_scrollView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1
                                                                            constant:0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1
                                                                             constant:0];
        [_scrollView addConstraints:@[leftConstraint, topConstraint, widthConstraint, heightConstraint]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    _scrollView.contentSize = CGSizeMake(_switchBar.titleArray.count * _scrollView.width, _scrollView.height);
}

@end
