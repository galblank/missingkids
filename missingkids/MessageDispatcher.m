//
//  MessageDispatcher.m
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "MessageDispatcher.h"
#import "CommManager.h"

@implementation MessageDispatcher

MessageDispatcher *shared = nil;


+ (MessageDispatcher*)shared
{
    return shared;
}

- (id)init
{
    self = [super init];
    
    shared = self;
    return (self);
}


-(void)dispatchMessageTo:(messageRoute)route withType:(messageType)type andParams:(NSMutableDictionary*)params
{
    switch (route) {
        case MESSAGEROUTE_API:
            [self routeMessageToServerWithType:type withParams:params];
            break;
        case MESSAGEROUTE_INTERNAL:
            break;
        case MESSAGEROUTE_OTHER:
            break;
        default:
            break;
    }
}


-(void)routeMessageToServerWithType:(messageType)type withParams:(NSMutableDictionary*)params
{
    switch (type) {
        case MESSAGETYPE_SIGNIN:
            //NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
            //[params setObject:apnsToken forKey:@"apnskey"];
            //[[CommManager sharedInstance] getAPI:@"NewUser" andParams:<#(NSMutableDictionary *)#>]
            break;
        default:
            break;
    }
}


-(BOOL)canSendMessage:(messageType)type withParams:(NSMutableDictionary*)params
{
    switch (type) {
        case MESSAGETYPE_SIGNIN:
        {
            if(params.count < 3){
                return NO;
            }
            
        }
        break;
        default:
            break;
    }
    
    return YES;
}


@end
