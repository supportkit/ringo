//
//  RGOOverlayWindow.m
//
//  Created by Michael Spensieri on 1/27/14.
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//
/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.      Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2.      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 3.      Neither the name of Radialpoint SafeCare Inc., nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED ''AS IS'', AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RADIALPOINT SAFECARE INC. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL OR OTHER LOSSES OR DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION), HOWEVER CAUSED, AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RGOOverlayWindow.h"

#import "RGODraggableView.h"

@interface RGOOverlayWindow()

@property BOOL isShown;
@property UIPanGestureRecognizer* panGesture;
@property UIWindow* mainWindow;
@property BOOL isDragging;

@end

@implementation RGOOverlayWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shown) name:@"shown" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidden) name:@"hidden" object:nil];
        
        self.mainWindow = [UIApplication sharedApplication].delegate.window;
        self.mainWindow.clipsToBounds = YES;
        
        self.panGesture.minimumNumberOfTouches = 2;
        self.panGesture.maximumNumberOfTouches = 2;
    }
    return self;
}

-(void)shown
{
    self.isShown = YES;
    
    [self.mainWindow removeGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.panGesture];
    
    [self makeKeyWindow];
}

-(void)hidden
{
    self.isShown = NO;
    
    [self removeGestureRecognizer:self.panGesture];
    //[self.mainWindow addGestureRecognizer:self.panGesture];
    
    [[UIApplication sharedApplication].delegate.window makeKeyWindow];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* tappedView = [super hitTest:point withEvent:event];
    BOOL inDragView = tappedView == [RGODraggableView sharedInstance]  || tappedView.superview == [RGODraggableView sharedInstance] || tappedView.tag == 678;
    if(self.isKeyWindow || inDragView){
        return [super hitTest:point withEvent:event];
    }
    
    return [self.mainWindow hitTest:point withEvent:event];
}

@end
