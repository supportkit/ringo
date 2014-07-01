//
//  RGOMeteorClient.m
//  AwesomeApp
//
//  Created by Andrew Lavers on 2014-06-14.
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//

#import "RGOMeteorClient.h"

NSString* const RGOChatConnected = @"RGOChatConnected";
NSString* const RGODraw = @"RGODraw";
NSString* const RGOSignal = @"RGOSignal";
NSString* const RGOClear = @"RGOClear";

@interface RGOMeteorClient()

@property (strong, nonatomic) MeteorClient *meteorClient;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *chats;
@property NSString *username;
@property NSString *userId;
@property NSString *token;
@property NSDictionary *user;
@property NSDictionary *chat;

@end

@implementation RGOMeteorClient

- (id)initWithURL:(NSURL *)url;
{
    if ((self = [super init])) {
        // Temp stand-in username
        self.username = @"Bob";
        
        self.meteorClient = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
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

- (void)joinLobby;
{
    [self login];
}

- (void)leaveChat;
{
    if (self.userId && self.meteorClient.connected) {
        [self.meteorClient callMethodName:@"disconnect" parameters:@[self.userId] responseCallback:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"websocketReady"] && self.meteorClient.websocketReady) {
        NSLog(@"====> websocketReady, fetching user info");
    } else {
        NSLog(@"====> DISCONNECTED websocketReady");
    }
}

- (void)login {
    [self.meteorClient callMethodName:@"login" parameters:@[self.username] responseCallback:^(NSDictionary *response, NSError *error) {
        if(error) {
            NSLog(@"Error logging in: %@", error);
        } else {
            NSDictionary *user = response[@"result"];
            [self onLoginSuccess:user];
        }
    }];
}

- (void)onLoginSuccess:(NSDictionary *)response {
    NSLog(@"Login success, user: %@", response);
    
    self.userId = [response valueForKey:@"_id"];
    [self.meteorClient addSubscription:@"users" withParameters:@[self.userId]];
    [self.meteorClient addSubscription:@"chats" withParameters:@[self.userId]];
    
    // Join the lobby, wait to receive an OpenTok token in onDataChange
    [self.meteorClient callMethodName:@"connect" parameters:@[self.userId] responseCallback:nil];
}

- (void)onConnect {
    NSLog(@"================> connected to server!");
}

- (void)onDisconnect {
    NSLog(@"================> disconnected from server!");
}

- (void)onDataChange:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSLog(@"Observed a data change: %@", dict);

    self.user = [self.meteorClient.collections[@"users"] firstObject];
    self.chat = [self.meteorClient.collections[@"chats"] firstObject];
    
    NSLog(@"Chat: %@", self.chat);
    
    // Detect & fire OpenTok connected event
    NSString *newToken = [dict valueForKey:@"token"];
    if (newToken && ![newToken isEqualToString:self.token]) {
        self.token = newToken;
        NSLog(@"Triggering ChatConnected");
        [[NSNotificationCenter defaultCenter] postNotificationName:RGOChatConnected object:self userInfo:self.user];
    };
    
    // Detect draw/clear draw events
    NSDictionary *draw = [dict valueForKey:@"draw"];
    if (draw) {
        if ([draw count] != 0) {
            NSLog(@"Triggering Draw event");
            [[NSNotificationCenter defaultCenter] postNotificationName:RGODraw object:self userInfo:draw];
        } else {
            NSLog(@"Triggering Clear event");
            [[NSNotificationCenter defaultCenter] postNotificationName:RGOClear object:self userInfo:nil];
        }
    }
    
    // Detect signal events
    NSDictionary *signal = [dict valueForKey:@"signal"];
    if ([signal count]) {
        NSLog(@"Triggering Signal event");
        [[NSNotificationCenter defaultCenter] postNotificationName:RGOSignal object:self userInfo:signal];
    }
}

@end