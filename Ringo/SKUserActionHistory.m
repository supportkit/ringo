//
//  SKUserActionHistory.m
//  SupportKit
//
//  Created by Michael Spensieri on 12/5/13.
//  Copyright (c) 2013 Radialpoint. All rights reserved.
//

#import "SKUserActionHistory.h"
#import "SKUtility.h"

static NSString* const userDefaultsKey = @"SupportKitUserActionHistory";
static NSString* const queryKey = @"query";
static NSString* const articlesKey = @"articles";
static NSString* const timestampKey = @"timestamp";

static NSString* const contextPrefix = @"\\n\\n------------------------------------";

@interface SKUserActionHistory()

// Format:
//
// [
//      {
//          "query":"oldestQuery (index 0)",
//          "timestamp":"xxxxxx",
//          "articles":
//              [
//                  ".....",
//                  ".....",
//                  "....."
//              ]
//      },
//      {
//          "query":"middleQuery (index 1)",
//          "timestamp":"xxxxxx",
//          "articles":
//              [
//                  ".....",
//                  ".....",
//                  "....."
//              ]
//      },
//      {
//          "query":"latestQuery (index 2)",
//          "timestamp":"xxxxxx",
//          "articles":
//              [
//                  ".....",
//                  ".....",
//                  "....."
//              ]
//      }
// ]
@property NSMutableArray* innerArray;

@end

@implementation SKUserActionHistory

+ (SKUserActionHistory*) sharedInstance
{
	static SKUserActionHistory* SharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray* savedHistory = [defaults objectForKey:userDefaultsKey];
        
		SharedInstance = [[SKUserActionHistory alloc] initWithArray:(savedHistory == nil) ? @[] : savedHistory];
	});
	
	return SharedInstance;
}

-(id)initWithArray:(NSArray*)array
{
    self = [super init];
    if(self) {
        self.innerArray = [array mutableCopy];
    }
    return self;
}

-(void)logArticleViewed:(NSString *)title
{
    if(self.innerArray.count == 0){
        return;
    }

    NSMutableDictionary* latestQuery = [self.innerArray.lastObject mutableCopy];
    
    NSMutableArray* articles = [[latestQuery objectForKey:articlesKey] mutableCopy];
    
    BOOL alreadyLookedAt = [articles containsObject:title];
    if(!alreadyLookedAt){
        if(articles.count == 3){
            [articles removeObjectAtIndex:0];
        }
        [articles addObject:title];
    
        [latestQuery setObject:articles forKey:articlesKey];
        [self.innerArray setObject:latestQuery atIndexedSubscript:self.innerArray.count - 1];

        [self save];
    }
}

-(void)logSearchQuery:(NSString *)query
{
    NSString* latestQueryString = [self.innerArray.lastObject objectForKey:queryKey];
    if([query isEqualToString:latestQueryString]){
        return;
    }
    
    if(self.innerArray.count == 3){
        [self.innerArray removeObjectAtIndex:0];
    }
    
    [self.innerArray addObject:@{timestampKey : [NSDate date], queryKey : query, articlesKey : @[]}];
    
    [self save];
}

-(NSString*)getContextString
{
    NSMutableString* contextString = [NSMutableString new];
    
    if(self.innerArray.count > 0){
        [contextString appendString:contextPrefix];
    }
    
    for(int i = (int)self.innerArray.count - 1; i >= 0; i--){
        NSDictionary* query = self.innerArray[i];
        [self appendQueryDetails:query toString:contextString];
        
        NSArray* articles = [query objectForKey:articlesKey];
        [self appendArticleDetails:articles toString:contextString];
        
        NSDate* timestamp = [query objectForKey:timestampKey];
        [self appendTimestampDetails:timestamp toString:contextString];
    }
    
    return contextString;
}

-(void)appendQueryDetails:(NSDictionary*)query toString:(NSMutableString*)contextString
{
    NSString* queryPrefix = @"I searched for";
    [contextString appendFormat:@"\\n%@ '%@'", queryPrefix, [query objectForKey:queryKey]];
}

-(void)appendArticleDetails:(NSArray*)articles toString:(NSMutableString*)contextString
{
    NSString* articlePrefix = @"and looked at";
    switch (articles.count){
        case 1:
            [contextString appendFormat:@" %@ '%@'.", articlePrefix, articles[0]];
            break;
        case 2:
            [contextString appendFormat:@" %@ '%@', '%@'.", articlePrefix, articles[1], articles[0]];
            break;
        case 3:
            [contextString appendFormat:@" %@ '%@', '%@', '%@'.", articlePrefix, articles[2], articles[1], articles[0]];
            break;
        default:
            [contextString appendFormat:@" %@.", @"and did not look at any articles"];
            break;
    }
}

-(void)appendTimestampDetails:(NSDate*)timestamp toString:(NSMutableString*)contextString
{
    if(nil != timestamp){
        [contextString appendFormat:@" (%@)", SKFormatDate(timestamp)];
    }
}

-(void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.innerArray forKey:userDefaultsKey];
}

@end
