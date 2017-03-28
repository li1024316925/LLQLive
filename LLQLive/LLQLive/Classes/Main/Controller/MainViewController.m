//
//  MainViewController.m
//  LLQLive
//
//  Created by LLQ on 2017/3/28.
//  Copyright © 2017年 LLQ. All rights reserved.
//

#import "MainViewController.h"
#import "LiveViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

//我要直播
- (IBAction)liveAction:(UIButton *)sender {
    
    LiveViewController *liveVC = [[LiveViewController alloc] init];
    [self presentViewController:liveVC animated:YES completion:nil];
    
}


//观看直播
- (IBAction)playAction:(UIButton *)sender {
}


@end
