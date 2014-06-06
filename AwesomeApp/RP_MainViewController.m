//
//  RP_MainViewController.m
//  testApp
//
//  Created by Jean-Philippe Joyal on 12/5/13.
//  Copyright (c) 2013 Jean-Philippe Joyal. All rights reserved.
//

#import "RP_MainViewController.h"
#import "Ringo.h"

@interface RP_MainViewController ()

@end

@implementation RP_MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	UILabel* label = [UILabel new];
    label.text = @"Tap here to start Ringo!";
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = self.view.frame;
    label.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:label];
    label.userInteractionEnabled = YES;
    [self.view addSubview:label];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(helpcenter)];
    [label addGestureRecognizer:tap];

}

- (void)helpcenter{
    [Ringo showTime];
}

@end
