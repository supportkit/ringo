//
//  RGOMeteorClient.h
//  AwesomeApp
//
//  Created by Andrew Lavers on 2014-06-14.
//  Copyright (c) 2014 Radialpoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveDDP.h"
#import <ObjectiveDDP/MeteorClient.h>

extern NSString* const RGOChatConnected;

@interface RGOMeteorClient : NSObject

- (id)initWithURL:(NSURL *)url;
- (void)joinLobby;
- (void)leaveChat;

@end
