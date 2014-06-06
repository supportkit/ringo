//
//  RP_MainViewController.m
//  testApp
//
//  Created by Jean-Philippe Joyal on 12/5/13.
//  Copyright (c) 2013 Jean-Philippe Joyal. All rights reserved.
//

#import "RP_MainViewController.h"
#import "Ringo.h"
#import "ObjectiveDDP.h"
#import <ObjectiveDDP/MeteorClient.h>

//static NSString* const socketUrl = @"ws://localhost:3000/websocket";
//static NSString* const socketUrl = @"wss://ringo.meteor.com/websocket";
static NSString* const socketUrl = @"wss://alavers.meteor.com/websocket";

@interface RP_MainViewController ()
@property (strong, nonatomic) MeteorClient *meteorClient;
@property (strong, nonatomic) NSMutableArray *chats;
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
    
    // Connect to meteor websocket
    NSLog(@"Creating meteorClient...");
    self.meteorClient = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
    [self.meteorClient addSubscription:@"chats"];
    ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:socketUrl delegate:self.meteorClient];
    self.meteorClient.ddp = ddp;
    
    NSLog(@"Connecting meteorClient to web socket...");
    [self.meteorClient.ddp connectWebSocket];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportConnection) name:MeteorClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportDisconnection) name:MeteorClientDidDisconnectNotification object:nil];
}

- (void)executeLogin {
    NSLog(@"Logging in to meteor");
    [self.meteorClient logonWithUsername:@"test@example.com" password:@"password" responseCallback:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"Login fail: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        NSLog(@"Login success!");
    }];
}

- (void)reportConnection {
    NSLog(@"================> connected to server!");
}

- (void)reportDisconnection {
    NSLog(@"================> disconnected from server!");
}

- (void)viewWillAppear:(BOOL)animated {
    [self.meteorClient addObserver:self
                        forKeyPath:@"websocketReady"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
}

- (void)didReceiveAddedUpdate:(NSNotification *)notification {
    NSLog(@"Received a collection added notification %d", self.chats.count);
    self.countLabel.text = [NSString stringWithFormat: @"%d", self.chats.count];
}

- (void)didReceiveRemovedUpdate:(NSNotification *)notification {
    NSLog(@"Received a collection removed notification %d", self.chats.count);
    self.countLabel.text = [NSString stringWithFormat: @"%d", self.chats.count];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"websocketReady"] && self.meteorClient.websocketReady) {
        NSLog(@"Connected to meteor");
        
    } else {
        NSLog(@"Disconnected from meteor");
    }
}

- (void)helpcenter{
//    [Ringo showTime];

    NSLog(@"Attempting to call remote method...");
    [self.meteorClient callMethodName:@"bar" parameters:@[@"from iOS"]
                     responseCallback:^(NSDictionary *response, NSError *error) {
                         NSLog(@"bar callback, error is: %@", error);
                     }];
    
    self.chats = self.meteorClient.collections[@"chats"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAddedUpdate:)
                                                 name:@"added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRemovedUpdate:)
                                                 name:@"removed"
                                               object:nil];
}

@end
