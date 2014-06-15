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
@property UILabel* countLabel;
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(helpcenter)];
    [label addGestureRecognizer:tap];
    
    // Count label
    self.countLabel = [UILabel new];
    [self.countLabel setBackgroundColor:[UIColor clearColor]];
    [self.countLabel setText:@"Tap to connect"];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.frame = self.view.frame;
    self.countLabel.font = [UIFont systemFontOfSize:36];
    [self.view addSubview:self.countLabel];
}

- (void)helpcenter{
    [Ringo showTime];
}

@end
