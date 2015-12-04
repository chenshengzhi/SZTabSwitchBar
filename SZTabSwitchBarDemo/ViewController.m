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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    [_switchBar setup];
    
    _scrollView.contentSize = CGSizeMake(_switchBar.titleArray.count * _scrollView.width, _scrollView.height);
    for (int i = 0; i < _switchBar.titleArray.count; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.width*i, 0, _scrollView.width, _scrollView.height)];
        view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
        [_scrollView addSubview:view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
