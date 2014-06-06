//
//  RGOScreenCaptureThread.m
//
//  Created by Mike Gozzo on 1/31/2014.
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//
/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.      Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2.      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 3.      Neither the name of Radialpoint SafeCare Inc., nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED ''AS IS'', AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RADIALPOINT SAFECARE INC. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL OR OTHER LOSSES OR DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION), HOWEVER CAUSED, AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RGOScreenCaptureThread.h"
#import "RGOOpenTokApiClient.h"

@implementation RGOScreenCaptureThread

- (void)main {
    bool busy = false;
    while(1) {
        if(!busy) {
            busy = true;
            
            CGSize imageSize = CGSizeZero;
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                imageSize = [UIScreen mainScreen].bounds.size;
            } else {
                imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            }
            
            UIWindow* window = [UIApplication sharedApplication].delegate.window;

            dispatch_sync(dispatch_get_main_queue(), ^{
                UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, window.center.x, window.center.y);
                CGContextConcatCTM(context, window.transform);
                CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
                if (orientation == UIInterfaceOrientationLandscapeLeft) {
                    CGContextRotateCTM(context, M_PI_2);
                    CGContextTranslateCTM(context, 0, -imageSize.width);
                } else if (orientation == UIInterfaceOrientationLandscapeRight) {
                    CGContextRotateCTM(context, -M_PI_2);
                    CGContextTranslateCTM(context, -imageSize.height, 0);
                } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
                    CGContextRotateCTM(context, M_PI);
                    CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
                }
                
                [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
                CGContextRestoreGState(context);
                
                UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [self.apiClient pushImage:image portrait:UIInterfaceOrientationIsPortrait(orientation)];
            });

            busy = false;
        }
        
        [NSThread sleepForTimeInterval:1.0f];
    }
}

@end
