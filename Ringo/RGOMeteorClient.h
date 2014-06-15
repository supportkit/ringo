//
//  RGOMeteorClient.h
//  AwesomeApp
//
//  Created by Andrew Lavers on 2014-06-14.
//  Copyright (c) 2014 Jean-Philippe Joyal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveDDP.h"
#import <ObjectiveDDP/MeteorClient.h>

@interface RGOMeteorClient : NSObject

- (id)initWithURL:(NSURL *)url;

@end
