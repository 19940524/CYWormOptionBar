//
//  ViewController.m
//  CYWormOptionBar
//
//  Created by 薛国宾 on 17/4/11.
//  Copyright © 2017年 千里之行始于足下. All rights reserved.
//

#import "ViewController.h"
#import "WormOptionBar.h"

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kRGB(r,g,b) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1]
#define kRANDOM_COLOR [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = kRGB(36, 218, 201);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSArray *titleNames = @[@"胡歌",@"司机",@"狗粮",@"向上",@"一丈红",@"老湿",@"GIF"];
    
    WormOptionBar *wormBar = [[WormOptionBar alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH/2-250/2, 0, 250, 40)
                                                           titles:titleNames
                                                       scrollView:_scrollView
                                                          tapView:nil];
    
    CGFloat width = kSCREEN_WIDTH;
    CGFloat height = kSCREEN_HEIGHT;
    CGFloat x = 0;
    for (NSInteger i = 0 ; i < titleNames.count; i ++) {
        
        UIViewController *vc = [[NSClassFromString(@"UIViewController") alloc] init];
        [self addChildViewController:vc];
        vc.view.frame = CGRectMake(x+i*width, 0, width, height);
        vc.view.backgroundColor = kRANDOM_COLOR;
        [_scrollView addSubview:vc.view];
    }
    
    _scrollView.contentSize = CGSizeMake(kSCREEN_WIDTH * titleNames.count, 0);
    self.navigationItem.titleView = wormBar;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
