//
//  HCZoomableImageView.h
//  HelpCenter
//
//  Created by Dominic Jodoin on 12/13/2013.
//  Copyright (c) 2013 Radialpoint. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCZoomableBackgroundView : UIImageView

-(id)initWithImage:(UIImage *)image initialScaleFactor:(CGFloat)factor;

-(void)setScaleFactor:(CGFloat)factor withDuration:(CGFloat)duration andDelay:(CGFloat)delay;
-(void)setScaleFactor:(CGFloat)factor;

@end
