//
//  CommMamanger.m
//  TheLine
//
//  Created by Gal Blank on 5/21/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import "CommManager.h"
#import "StringHelper.h"
#import "AppDelegate.h"

@implementation CommManager


static CommManager *sharedSampleSingletonDelegate = nil;


+ (CommManager *)sharedInstance {
    @synchronized(self) {
        if (sharedSampleSingletonDelegate == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedSampleSingletonDelegate;
}



+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedSampleSingletonDelegate == nil) {
            sharedSampleSingletonDelegate = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedSampleSingletonDelegate;
        }
    }
    // on subsequent allocation attempts return nil
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(id)init
{
    if (self = [super init]) {
       
    
    }
    return self;
}

-(void)getAPI:(NSString*)api andParams:(NSMutableDictionary*)params{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *fullAPI = [NSString stringWithFormat:@"%@%@",ROOT_API,api];
    [manager GET:fullAPI parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)postAPI:(NSString*)api andParams:(NSMutableDictionary*)params{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:api parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
