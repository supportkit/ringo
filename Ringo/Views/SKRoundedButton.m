//
//  SKRoundedButton.m
//  SupportKit
//
//  Created by Jean-Philippe Joyal on 11/15/13.
//  Copyright (c) 2013 Radialpoint. All rights reserved.
//

#import "SKRoundedButton.h"
#import "SKUtility.h"

static const int buttonSidePadding = 17;

@implementation SKRoundedButton

+(SKRoundedButton*) new{
    SKRoundedButton* button = [self buttonWithType:UIButtonTypeSystem];
    button.layer.cornerRadius = 23.0;
    button.layer.masksToBounds = YES;
    button.backgroundColor = [UIColor colorWithRed:83.0/255.0 green:215.0/255.0 blue:105.0/255.0 alpha:1.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if(!SKIsIOS7()){
        [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    }
    
    return button;
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGSize newSize = [super sizeThatFits:size];
    newSize.width = newSize.width + buttonSidePadding;
    newSize.height = size.height;
    return newSize;
}

@end
