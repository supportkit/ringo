//
//  HCZoomableImageView.m
//  HelpCenter
//
//  Created by Dominic Jodoin on 12/13/2013.
//  Copyright (c) 2013 Radialpoint. All rights reserved.
//

#import "SKZoomableBackgroundView.h"

@interface HCZoomableBackgroundView()

@property CGRect originalFrame;
@end

@implementation HCZoomableBackgroundView

- (id)initWithImage:(UIImage *)image initialScaleFactor:(CGFloat)factor
{
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        self.originalFrame = self.frame;
        [self setScaleFactor:factor];
    }
    return self;
}

-(void)setScaleFactor:(CGFloat)factor withDuration:(CGFloat)duration andDelay:(CGFloat)delay
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelay:delay];
    
    [self setScaleFactor:factor];
    
    [UIView commitAnimations];
}

-(void)setScaleFactor:(CGFloat)factor
{
    CGRect frame = self.originalFrame;
    frame.size.width *= factor;
    frame.size.height *= factor;
    
    frame.origin.x = self.center.x - frame.size.width/2;
    frame.origin.y = self.center.y - frame.size.height/2;
    self.frame = frame;
}

@end
