//
//  RGOMeteorClient.m
//  AwesomeApp
//
//  Created by Andrew Lavers on 2014-06-14.
//  Copyright (c) 2014 Jean-Philippe Joyal. All rights reserved.
//

#import "RGOMeteorClient.h"

@interface RGOMeteorClient()

@property (strong, nonatomic) MeteorClient *meteorClient;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *chats;
@property NSString *username;

@end

@implementation RGOMeteorClient

- (id)initWithURL:(NSURL *)url;
{
    if ((self = [super init])) {
        // Temp stand-in username
        self.username = @"Bob";
        
        self.meteorClient = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
        [self.meteorClient addSubscription:@"users" withParameters:@[self.username]];
        [self.meteorClient addSubscription:@"chats" withParameters:@[self.username]];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:[url absoluteString] delegate:self.meteorClient];
        self.meteorClient.ddp = ddp;
        
        NSLog(@"Connecting meteorClient to web socket...");
        [self.meteorClient.ddp connectWebSocket];
        
        [self.meteorClient addObserver:self
                            forKeyPath:@"websocketReady"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnect) name:MeteorClientDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDisconnect) name:MeteorClientDidDisconnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChange:) name:@"changed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChange:) name:@"added" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChange:) name:@"removed" object:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"websocketReady"] && self.meteorClient.websocketReady) {
        NSLog(@"====> websocketReady, fetching user info");
        [self refreshData];
    } else {
        NSLog(@"====> DISCONNECTED websocketReady");
    }
}

- (void)onConnect {
    NSLog(@"================> connected to server!");
}

- (void)onDisconnect {
    NSLog(@"================> disconnected from server!");
}

- (void)onDataChange:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    
    NSLog(@"Received a user/chats changed/added/removed notification");
    NSLog(@"There are %d cached users", [self.users count]);
    NSLog(@"There are %d cached chats", [self.chats count]);
    
    NSLog(@"There are %d meteor users", [self.meteorClient.collections[@"users"] count]);
    NSLog(@"There are %d meteor chats", [self.meteorClient.collections[@"chats"] count]);
}

- (void)refreshData {
    self.users = self.meteorClient.collections[@"users"];
    NSLog(@"Found %d users", self.users.count);
    
    self.chats = self.meteorClient.collections[@"chats"];
    NSLog(@"Found %d chats", self.users.count);
}

@end