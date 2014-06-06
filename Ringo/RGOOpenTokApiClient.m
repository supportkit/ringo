//
//  RGOOpenTokApiClient.m
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

#import "RGOOpenTokApiClient.h"
#import "AFHTTPRequestOperation.h"

@interface RGOOpenTokApiClient ()
@property AFHTTPRequestOperation* lastRequest;
@end

@implementation RGOOpenTokApiClient

-(void) getTokBoxInfoWithBlock:(void (^)(NSDictionary *result, NSError *error))block {
    [self cancelCurrentRequest];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.lastRequest = [super GET:@"api/chat" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.isCancelled){
            // Needed for unit tests
            return;
        }

        NSDictionary* tokBoxInfo = [NSDictionary dictionaryWithDictionary:responseObject];
        
        if (block) {
            block(tokBoxInfo, (tokBoxInfo == nil) ? [NSError new] : nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    }];
}

-(void) cancelCurrentRequest {
    
}

-(void) pushImage:(UIImage*)img portrait:(bool)isPortrait {
    NSData* jpegData = UIImageJPEGRepresentation(img, 0.50f);

    NSDictionary* params = nil;
    if(isPortrait) {
        params = [NSDictionary dictionaryWithObject:@"portrait" forKey:@"orientation"];
    } else {
        params = [NSDictionary dictionaryWithObject:@"landscape" forKey:@"orientation"];
    }
    
    [super POST:@"api/screenshot" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:jpegData name:@"source" fileName:@"hacktheplanet" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Sent a screenshot!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
}
@end
