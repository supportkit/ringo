//
//  RGOVideoViewController.m
//
//  Created by Mike Gozzo on 1/30/2014.
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//
/*
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1.      Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2.      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3.      Neither the name of Radialpoint SafeCare Inc., nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED ''AS IS'', AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RADIALPOINT SAFECARE INC. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL OR OTHER LOSSES OR DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION), HOWEVER CAUSED, AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "RGOVideoViewController.h"
#import "RGOOpenTokApiClient.h"
#import <Opentok/Opentok.h>
#import <time.h>
#import "RGODraggableView.h"
#import "RGOScreenCaptureThread.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "RGOMeteorClient.h"

static NSString* const socketUrl = @"wss://ringo.meteor.com/websocket";
static NSString* const kApiEndpoint = @"http://rpringo.herokuapp.com/";

@interface RGOVideoViewController ()

@property RGOMeteorClient* meteorClient;
@property(nonatomic, strong) OTSession* session;
@property(nonatomic, strong) OTPublisher* publisher;
@property(nonatomic, strong) OTSubscriber* subscriber;
@property(nonatomic, strong) RGOOpenTokApiClient* apiClient;
@property(nonatomic, strong) RGOScreenCaptureThread* capThread;
@property(nonatomic, strong) SocketIO* socketIO;

@property (nonatomic, retain) CALayer *animationLayer;
@property (nonatomic, retain) CAShapeLayer *pathLayer;

@end

@implementation RGOVideoViewController

+ (RGOVideoViewController*)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

+(RGOVideoViewController*)addTo:(UIViewController*)parent{
    
    RGOVideoViewController * video = [RGOVideoViewController sharedInstance];
    
    [parent addChildViewController:video];
    [parent.view addSubview:video.view];
    video.view.alpha = 0;
    
    return video;
}

-(void)hide
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.alpha = 0;
                     }
                     completion:nil];
    [self disconnect];
}

- (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.width, (([UIScreen mainScreen].bounds.size.height )));
}

-(void)show
{
    [self.meteorClient joinLobby];
    self.view.alpha = 1;
}

- (id)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(200, 200, 200, 200)];
        
        [self initDragView];
        self.view.alpha = 0;
        
        self.meteorClient = [[RGOMeteorClient alloc]initWithURL:[NSURL URLWithString:socketUrl]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChatConnected:) name:RGOChatConnected object:nil];
    }
    return self;
}

- (void) initDragView{
    
    RGODraggableView* drag = [RGODraggableView sharedInstance];
    
    drag.frame = CGRectMake(0,0,239,267);
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [drag addGestureRecognizer:panGesture];
    
    [self.view addSubview:drag];
}

-(void)pan:(UIPanGestureRecognizer*)panGesture {
    
    UIView *view = panGesture.view;
    
    // If dragging started or changed...
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged) {
        
        // Get the translation in superview coordinates
        CGPoint translation = [panGesture translationInView:view.superview];
        
        // Get your view's center
        CGPoint viewCenter = view.center;
        
        // Add the delta
        viewCenter.x += translation.x;
        viewCenter.y += translation.y;
        view.center = viewCenter;
        
        // Reset delta from the gesture recognizer
        [panGesture setTranslation:CGPointZero inView:view.superview];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    NSString* orientation = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? @"portrait" : @"landscape";
    NSLog(@"user_rotate : %@",orientation);

    [self.socketIO sendEvent:@"user_rotate" withData:[NSDictionary dictionaryWithObject:orientation forKey:@"orientation"]];
    
    return YES;
}

#pragma mark - OpenTok methods

- (void)onChatConnected:(NSNotification *)notification {
    NSDictionary *response = [notification userInfo];
    NSString* token = [response objectForKey:@"token"];
    NSString* sessionId = [response objectForKey:@"sessionId"];
    NSString* otKey = [response objectForKey:@"otKey"];
    
    self.session = [[OTSession alloc] initWithSessionId:sessionId delegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session connectWithApiKey:otKey token:token];
    });
}

- (void)doPublish
{
    self.publisher = [[OTPublisher alloc] initWithDelegate:self];
    [self.publisher setName:[[UIDevice currentDevice] name]];
    
    self.publisher.publishAudio = YES;
    self.publisher.publishVideo = NO;
    
    [self.session publish:self.publisher];
}

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    //Connected to the session, start taking screenshots
    self.capThread = [[RGOScreenCaptureThread alloc] init];
    self.capThread.apiClient = self.apiClient;
    [self.capThread start];
    
    //Connect to socketIO
    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    NSURL* tmpUrl  = [NSURL URLWithString:kApiEndpoint];
    [self.socketIO connectToHost:[tmpUrl host] onPort:[[tmpUrl port] integerValue]];
    
    [self setupDrawingLayer];
    [self startAnimation];
    
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage = [NSString stringWithFormat:@"Session disconnected: (%@)", session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
    
    [self.capThread cancel];
    [self showAlert:alertMessage];
}

- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    NSLog(@"session didReceiveStream (%@)", stream.streamId);
    
    // See the declaration of subscribeToSelf above.
    if (![stream.connection.connectionId isEqualToString: _session.connection.connectionId]) {
        if (!self.subscriber && stream.hasVideo) {
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        }
    }
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream{
    NSLog(@"session didDropStream (%@)", stream.streamId);
    NSLog(@"_subscriber.stream.streamId (%@)", _subscriber.stream.streamId);
    if (self.subscriber && [_subscriber.stream.streamId isEqualToString: stream.streamId])
    {
        self.subscriber = nil;
    }
}

- (void)session:(OTSession *)session didCreateConnection:(OTConnection *)connection {
    NSLog(@"session didCreateConnection (%@)", connection.connectionId);
}

- (void) session:(OTSession *)session didDropConnection:(OTConnection *)connection {
    NSLog(@"session didDropConnection (%@)", connection.connectionId);
}

- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
    [[RGODraggableView sharedInstance] addVideo:subscriber.view];
}

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error {
    NSLog(@"publisher didFailWithError %@", error);
    [self showAlert:[NSString stringWithFormat:@"There was an error publishing."]];
}

- (void)subscriber:(OTSubscriber*)subscriber didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@", subscriber.stream.streamId, error);
    [self showAlert:[NSString stringWithFormat:@"There was an error subscribing to stream %@", subscriber.stream.streamId]];
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"sessionDidFail - %@", [error description]);
    [self showAlert:[NSString stringWithFormat:@"There was an error connecting to session %@", session.sessionId]];
}

- (void)subscriberVideoDataReceived:(OTSubscriber *)subscriber{
    NSLog(@"subscriberVideoDataReceived - %@", [subscriber description]);
    [[RGODraggableView sharedInstance] connected];
}


- (void)showAlert:(NSString*)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from video session"
                                                    message:string
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark SocketIO delegate

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    if([packet.name isEqualToString:@"agent_draw_relay"] ) {
        NSError* err;
        NSData* data = [[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&err];
        [self drawCurveFromArray:array];
    } else if([packet.name isEqualToString:@"agent_clear_relay"]) {
        NSMutableArray* toRemove = [NSMutableArray array];
        
        for(CALayer* layer in self.animationLayer.sublayers) {
            if([[layer class] isSubclassOfClass:[CAShapeLayer class]]) {
                [toRemove addObject:layer];
            }
        }
        
        for(CALayer* layer in toRemove) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
        
        [toRemove removeAllObjects];
    } else if([packet.name isEqualToString:@"agent_signal_relay"]) {
        NSError* err;
        NSData* data = [[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *rawPt = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&err];
        [self drawTapHighlightOvalAtPoint:rawPt];
    }
}


#pragma mark -
#pragma mark Animation Baby

-(void)drawTapHighlightOvalAtPoint:(NSDictionary*)rawPt {
    CGFloat x = [[rawPt valueForKey:@"x"] floatValue];
    CGFloat y = [[rawPt valueForKey:@"y"] floatValue];
    CGFloat w = [[rawPt valueForKey:@"w"] floatValue];
    
    CGFloat scale = 1.0;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        scale = self.view.frame.size.width / w;
    } else {
        scale = self.view.frame.size.height / w;
    }
    
    x *= scale;
    y *= scale;
    
    //Invert y
    y = self.view.frame.size.height - y;
    
    CGRect rect = CGRectMake(x-50, y-50, 100, 100);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.animationLayer.bounds;
    pathLayer.bounds = self.view.frame;
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [[UIColor greenColor] CGColor];
    pathLayer.opacity = 0.60;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 10.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    [self.animationLayer addSublayer:pathLayer];
    self.pathLayer = pathLayer;
    
    [pathLayer performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:1.0f];
    [self startAnimation];
}

-(void)drawCurveFromArray:(NSArray*)rawPoints {
    UIBezierPath *path = [UIBezierPath bezierPath];
    bool first = true;
    
    for(NSDictionary* rawPt in rawPoints) {
        CGFloat x = [[rawPt valueForKey:@"x"] floatValue];
        CGFloat y = [[rawPt valueForKey:@"y"] floatValue];
        CGFloat w = [[rawPt valueForKey:@"w"] floatValue];

        CGFloat scale = 1.0;

        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            scale = self.view.frame.size.width / w;
        } else {
            scale = self.view.frame.size.height / w;
        }
        
        x *= scale;
        y *= scale;
        
        //Invert y
        y = self.view.frame.size.height - y;
        
        if(first) {
            [path moveToPoint:CGPointMake(x, y)];
            first = false;
        } else {
            [path addLineToPoint:CGPointMake(x, y)];
        }
    }
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.animationLayer.bounds;
    pathLayer.bounds = self.view.frame;
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [[UIColor orangeColor] CGColor];
    pathLayer.opacity = 0.60;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 30.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    [self.animationLayer addSublayer:pathLayer];
    self.pathLayer = pathLayer;
    
    [self startAnimation];
}

- (void) setupDrawingLayer
{
    if (self.pathLayer != nil) {
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
    }
    
    self.animationLayer= self.view.layer;
}

- (void) startAnimation {
    [self.pathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.25;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}


- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

}

- (void) disconnect{
    [self.meteorClient leaveChat];
    if(self.session){
        [self.session disconnect];
    }
}

@end
