//
//  SKUserActionHistory.h
//  SupportKit
//
//  Created by Michael Spensieri on 12/5/13.
//  Copyright (c) 2013 Radialpoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKUserActionHistory : NSObject

+ (SKUserActionHistory*) sharedInstance;
-(id)initWithArray:(NSArray*)array;

-(void)logArticleViewed:(NSString*)title;
-(void)logSearchQuery:(NSString*)query;

-(NSString*)getContextString;

@end
