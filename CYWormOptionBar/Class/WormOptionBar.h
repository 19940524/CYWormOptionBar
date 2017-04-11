//
//  WormOptionBar.h
//  Demo
//
//  Created by 薛国宾 on 17/4/10.
//  Copyright © 2017年 千里之行始于足下. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TopBlock)(NSInteger tag);

@interface WormOptionBar : UIScrollView

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
                   scrollView:(UIScrollView *)targetScrollView
                      tapView:(TopBlock)block;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, assign) CGFloat titleInterval;

@property (nonatomic, readonly, assign) NSInteger selectedIndex;

- (void)refresh:(NSInteger)index;

@end
