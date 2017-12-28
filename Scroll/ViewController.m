//
//  ViewController.m
//  Scroll
//
//  Created by mika on 2017/12/28.
//  Copyright © 2017年 mika. All rights reserved.
//

#import "ViewController.h"
#import "MikaScrollView.h"

@interface ViewController ()
@property (nonatomic, strong) MikaScrollView *mikaScroll;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mikaScroll = [[MikaScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    self.mikaScroll.imagesArray = @[@"1",@"2",@"3",@"4",@"5"];
    self.mikaScroll.autoScroll = YES;
    [self.mikaScroll setTapImageBlock:^(NSInteger index) {
        NSLog(@"点击了%ld",index);
    }];
    [self.view addSubview:self.mikaScroll];
}

@end
