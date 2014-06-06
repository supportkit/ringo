//
//  RGODraggableView.m
//
//  Created by Jean-Philippe Joyal on 1/30/14.
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//
/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.      Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2.      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 3.      Neither the name of Radialpoint SafeCare Inc., nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED ''AS IS'', AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RADIALPOINT SAFECARE INC. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL OR OTHER LOSSES OR DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION), HOWEVER CAUSED, AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RGODraggableView.h"

#import "RGOVideoViewController.h"

@implementation RGODraggableView

+ (RGODraggableView*)sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        
        UIImage* image = [UIImage imageNamed:@"bg_video"];
        assert(image && "bg_video missing");
        UIImageView* imageView = [UIImageView new];
        imageView.frame = CGRectMake(0,0,239,267);
        imageView.image = image;
        [self addSubview:imageView];
        
        UIView* end = [UIView new];
        end.userInteractionEnabled = YES;
        end.frame = CGRectMake(134,21, 98, 26);
        [self addSubview:end];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(end:)];
        gesture.numberOfTouchesRequired = 1;
        [end addGestureRecognizer:gesture];
        
        self.tempVideo = [UIView new];
        self.tempVideo.backgroundColor = [UIColor blackColor];
        self.tempVideo.frame = CGRectMake(19,47, 200, 200);
        [self addSubview:self.tempVideo];
        
        UILabel* connectionLabel = [UILabel new];
        connectionLabel.frame = CGRectMake(0,0, 200, 200);
        connectionLabel.numberOfLines = 0;
        connectionLabel.textAlignment = NSTextAlignmentCenter;
        connectionLabel.textColor = [UIColor whiteColor];
        connectionLabel.backgroundColor = [UIColor clearColor];
        connectionLabel.font = [UIFont boldSystemFontOfSize:12];
        connectionLabel.text = @"Waiting for agent...";
        [self.tempVideo addSubview:connectionLabel];
        
        
        UILabel* name = [UILabel new];
        name.frame = CGRectMake(25,229, 200, 200);
        name.numberOfLines = 0;
        name.lineBreakMode = NSLineBreakByWordWrapping;
        name.textAlignment = NSTextAlignmentLeft;
        name.textColor = [UIColor whiteColor];
        name.backgroundColor = [UIColor clearColor];
        name.font = [UIFont boldSystemFontOfSize:12];
        name.text = @"Ringo";
        [name sizeToFit];
        name.alpha = 0;
        self.label = name;
        [self addSubview:name];
        
        UIImageView* anim = [self getAnimation];
        
        anim.frame = CGRectMake(180,212, 35, 35);
        anim.alpha = 0;
        self.speakAnim = anim;
        
        [self addSubview:anim];
        
        [anim startAnimating];
        
        
    }
    return self;
}

- (void) addVideo:(UIView*) video{
    video.frame = CGRectMake(19,47, 200, 200);
    video.userInteractionEnabled = NO;
    [self addSubview:video];
    [self bringSubviewToFront:self.label];
    [self bringSubviewToFront:self.speakAnim];
}

- (UIImageView* )getAnimation{
    NSMutableArray * imageArray  = [[NSMutableArray alloc] init ];
                                    
    for(int i=1; i<32; i++) {
        NSString* fileName = [NSString stringWithFormat:@"%d.gif",i];
        UIImage* originalImage = [UIImage imageNamed:fileName];
        // scaling set to 2.0 makes the image 1/2 the size.
        UIImage *image =
        [UIImage imageWithCGImage:[originalImage CGImage]
                            scale:(originalImage.scale * 10.0)
                      orientation:(UIImageOrientationDown)];
        [imageArray addObject:image];
    }
    
    UIImageView * anim = [[UIImageView alloc] init];
	anim.animationImages = imageArray;
	anim.animationDuration = 3;
	anim.contentMode = UIViewContentModeBottomLeft;
	
    return anim;
}

- (void)end:(UITapGestureRecognizer *)gesture{
    [[RGOVideoViewController sharedInstance] hide];
    [self hideStatusViews];
}

-(void)connected{
    [self showStatusViews];
}


-(void)showStatusViews
{
    [UIView animateWithDuration:1
                     animations:^{
                         self.speakAnim.alpha = 1;
                         self.label.alpha = 1;
                         self.tempVideo.alpha = 0;
                     }
                     completion:nil];
}

-(void)hideStatusViews
{
    [UIView animateWithDuration:1
                     animations:^{
                         self.speakAnim.alpha = 0;
                         self.label.alpha = 0;
                         self.tempVideo.alpha = 1;
                     }
                     completion:nil];
}


@end
