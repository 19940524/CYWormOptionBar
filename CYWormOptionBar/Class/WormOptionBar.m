//
//  WormOptionBar.m
//  Demo
//
//  Created by 薛国宾 on 17/4/10.
//  Copyright © 2017年 千里之行始于足下. All rights reserved.
//

#import "WormOptionBar.h"
#import "CYDrawBoard.h"

#define kFont 16
#define kMaxScale 1
#define kDefaultAlpha 0.6
#define kLineLength 10
#define kLineLengthHalf kLineLength / 2

@interface WormOptionBar () <UIScrollViewDelegate> {
    CGFloat _lineY;
    UIButton *_seleteButton;
}

@property (nonatomic, strong) CYDrawBoard *bgView;

@property (nonatomic, copy) TopBlock block;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, strong) UIScrollView *targetScrollView;

@end

@implementation WormOptionBar

- (NSMutableArray *)buttons {
    
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

-(void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (!self.bgView) {
        return;
    }
    self.bgView.lineColor = titleColor;
    for (UIButton *button in _buttons) {
        [button setTitleColor:_titleColor forState:UIControlStateNormal];
        button.alpha = kDefaultAlpha;
    }
    
    [self refresh:_selectedIndex];
}


-(void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    for (UIButton *button in _buttons) {
        button.titleLabel.font = titleFont;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
                   scrollView:(UIScrollView *)targetScrollView
                      tapView:(TopBlock)block {
    if (self = [super initWithFrame:frame]) {
        self.block = block;
        self.targetScrollView = targetScrollView;
        [self.targetScrollView layoutIfNeeded];
        self.targetScrollView.delegate = self;
        self.titleInterval = 15;
        [self __initUI:titles];
        self.titleColor = [UIColor whiteColor];
    }
    return self;
}

- (void)__initUI:(NSArray *)titles {
    
    self.bounces = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat btnH = self.frame.size.height;
    CGFloat btnX = 0;
    
    CGFloat contentW = 0.0;
    
    if (!titles.count) {
        return;
    }
    
    for (int i = 0; i < titles.count; i++) {
        
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttons addObject:titleButton];
        titleButton.tag = i;
        NSString *vcName = titles[i];
        [titleButton setTitle:vcName forState:UIControlStateNormal];
        titleButton.alpha = kDefaultAlpha;
        titleButton.titleLabel.font = [UIFont systemFontOfSize:kFont];
        [titleButton sizeToFit];
        if (i == 0) {
            _lineY = (self.frame.size.height - titleButton.frame.size.height) / 2 + titleButton.frame.size.height;
        }
        titleButton.frame = CGRectMake(btnX, 0, titleButton.frame.size.width+self.titleInterval, btnH);
        [titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:titleButton];
        
        btnX += titleButton.frame.size.width;
        contentW = titleButton.frame.origin.x + titleButton.frame.size.width;
    }
    
    UIButton *button = self.buttons[self.buttons.count-1];
    self.bgView = [[CYDrawBoard alloc] initWithFrame:CGRectMake(0, 0, button.frame.origin.x + button.frame.size.width, self.frame.size.height)];
    self.bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgView];
    [self sendSubviewToBack:self.bgView];
    
    self.contentSize = CGSizeMake(contentW, self.frame.size.height);
    
    [self refresh:0];
}

static CGFloat lastOffsetX = 0;
- (void)__premiereText:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    BOOL toLeft = YES;
    
    if (offsetX > lastOffsetX) {
        toLeft = NO;
    }
    
    [self __premiereText:offsetX / scrollView.frame.size.width toLeft:toLeft];
    
    lastOffsetX = offsetX;
}

- (void)refresh:(NSInteger)index {
    
    [self __refreshLine:index];
    
    [self scrollViewDidEndScrollingAnimation:self.targetScrollView];
}

- (void)__refreshLine:(NSInteger)index {
    UIButton *button = self.buttons[index];
    CGFloat mp = button.center.x - kLineLengthHalf;
    
    NSMutableArray *points = [NSMutableArray array];
    
    CGPoint movePath = CGPointMake(mp, _lineY);
    CGPoint toPath = CGPointMake(movePath.x+kLineLength, movePath.y);
    
    [points addObject:[NSValue valueWithCGPoint:movePath]];
    [points addObject:[NSValue valueWithCGPoint:toPath]];
    
    [self.bgView drawLine:[points copy]];
    
    self.targetScrollView.contentOffset = CGPointMake(index * self.targetScrollView.frame.size.width, 0);
    
}

- (void)titleClick:(UIButton *)button {
    
    if (_selectedIndex == button.tag) {
        return;
    }
    
    if (self.block) {
        self.block(button.tag);
    }
    
    for (UIButton *button in _buttons) {
        button.alpha = kDefaultAlpha;
    }
    
    [self __scrollToIndex:button.tag];
    
    [self __refreshLine:button.tag];
}


- (void)__scrollToIndex:(NSInteger)index {
    _selectedIndex = index;
    
    UIButton *button = self.buttons[index];
    __weak typeof(self) weakSelf = self;
    
    [weakSelf __setButtonLabelPremiere:_seleteButton alpha:kDefaultAlpha scale:0];
    [weakSelf __setButtonLabelPremiere:button alpha:1 scale:1];
    
    _seleteButton = button;
    CGFloat x = 0;
    
    if (button.frame.origin.x + button.frame.size.width > self.contentOffset.x + self.frame.size.width) {
        x = button.frame.origin.x + button.frame.size.width - self.frame.size.width;
        [self setContentOffset:CGPointMake(x, 0) animated:YES];
    }
    
    if (button.frame.origin.x < self.contentOffset.x) {
        x = button.frame.origin.x;
        [self setContentOffset:CGPointMake(x, 0) animated:YES];
    }
}

- (void)__premiereText:(CGFloat)offsetX toLeft:(BOOL)toLeft {
    
    int firstIndex = (int)offsetX;
    int secondIndex = (int)ceil(offsetX);
    
    if (firstIndex >= _buttons.count || secondIndex >= _buttons.count) {
        return;
    }
    
    if (firstIndex == secondIndex) {
        [self refresh:firstIndex];
        return;
    }
    
    UIButton *currentButton;
    UIButton *toButton;
    
    // 0.6 ~ 1 & 1 ~ 0.6
    CGFloat toAlpha;
    CGFloat currentAlpha;
    CGFloat currentWeight;
    CGFloat toWeight;
    
    // 计算透明度和字体粗细
    if (toLeft) {
        currentButton = _buttons[secondIndex];
        toButton = _buttons[firstIndex];
        
        currentAlpha = (offsetX - firstIndex) * 0.4 + kDefaultAlpha;
        toAlpha = 1 - ((offsetX - firstIndex) * 0.4);
        
        currentWeight = (offsetX - firstIndex) * kMaxScale;
        toWeight = (1 - (offsetX - firstIndex)) * kMaxScale;
        
    } else {
        currentButton = _buttons[firstIndex];
        toButton = _buttons[secondIndex];
        
        currentAlpha = (1 - (offsetX - firstIndex)) * 0.4 + kDefaultAlpha;
        toAlpha = kDefaultAlpha + (offsetX - firstIndex) * 0.4;
        
        toWeight = (offsetX - firstIndex) * kMaxScale;
        currentWeight = (1 - (offsetX - firstIndex)) * kMaxScale;
    }
    
    [self __setButtonLabelPremiere:currentButton alpha:currentAlpha scale:currentWeight];
    [self __setButtonLabelPremiere:toButton alpha:toAlpha scale:toWeight];
    
    [self __scrollLine:offsetX curBtn:currentButton toBtn:toButton toLeft:toLeft];
    
}

- (void)__setButtonLabelPremiere:(UIButton *)button alpha:(CGFloat)alpha scale:(CGFloat)scale {
    
    button.transform = CGAffineTransformMakeScale(1+scale*0.07, 1+scale*0.07);
    button.alpha = alpha;
}

#pragma mark - 计算直线点
- (void)__scrollLine:(CGFloat)offsetX curBtn:(UIButton *)curBtn toBtn:(UIButton *)toBtn toLeft:(BOOL)toLeft {
    
    CGFloat mp = curBtn.center.x - kLineLengthHalf;
    CGFloat tp = toBtn.center.x - kLineLengthHalf;

    CGFloat scrProgress = offsetX - (int)offsetX;
    CGPoint toPath;
    CGPoint movePath;
    
    if (toLeft) {
        
        scrProgress = 1 - scrProgress;
        
        if (scrProgress <= 0.5) {
            CGFloat toLength = mp - tp - kLineLength;
            CGFloat tox = mp - scrProgress*2 * toLength;
            toPath = CGPointMake(tox, _lineY);
            
            CGFloat moLength = kLineLengthHalf*3;
            CGFloat mox = (mp+kLineLength) - scrProgress*2 * moLength;
            movePath = CGPointMake(mox, _lineY);
        } else {
            CGFloat tox = (tp+kLineLength) - (scrProgress-0.5)*2 * kLineLength;
            toPath = CGPointMake(tox, _lineY);
            
            CGFloat startX = mp-kLineLengthHalf;
            CGFloat mox = startX - (scrProgress-0.5)*2 * (startX-(tp+kLineLength));
            movePath = CGPointMake(mox, _lineY);
        }
        
    } else {
        
        if (scrProgress <= 0.5) {
            CGFloat toLength = tp - (mp+kLineLength);
            CGFloat tox = (mp+kLineLength) + scrProgress*2 * toLength;
            toPath = CGPointMake(tox, _lineY);
            
            CGFloat moLength = kLineLengthHalf*3;
            CGFloat mox = mp + scrProgress*2 * moLength;
            movePath = CGPointMake(mox, _lineY);
        } else {

            CGFloat tox = tp + (scrProgress-0.5)*2 * kLineLength;
            toPath = CGPointMake(tox, _lineY);
            
            CGFloat startX = mp+kLineLengthHalf*3;
            CGFloat mox = startX + (scrProgress-0.5)*2 * (tp-startX);
            movePath = CGPointMake(mox, _lineY);
        }
    }
    
    NSMutableArray *points = [NSMutableArray array];
    
    [points addObject:[NSValue valueWithCGPoint:movePath]];
    [points addObject:[NSValue valueWithCGPoint:toPath]];
    
    [self.bgView drawLine:[points copy]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    CGFloat indexf = scrollView.contentOffset.x / scrollView.frame.size.width;
    int index = (int)indexf;
    if (index == indexf) {
        [self __scrollToIndex:index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x < 0) {
        return;
    }
    
    if (scrollView.contentOffset.x + scrollView.frame.size.width > scrollView.contentSize.width) {
        return;
    }
    
    [self __premiereText:scrollView];
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
