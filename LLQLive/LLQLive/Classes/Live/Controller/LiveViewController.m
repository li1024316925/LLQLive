//
//  LiveViewController.m
//  LLQLive
//
//  Created by LLQ on 2017/3/28.
//  Copyright © 2017年 LLQ. All rights reserved.
//

#import "LiveViewController.h"
#import "LLQLivePreview.h"

@interface LiveViewController ()

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[[LLQLivePreview alloc] initWithFrame:self.view.bounds]];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


@end
