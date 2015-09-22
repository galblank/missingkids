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

MessageDispatcher *sharedInstance = nil;


+ (MessageDispatcher*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedInstance;
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
        if(messageBus == nil){
            messageBus = [[NSMutableArray alloc] init];
        }
        
        if(dispatchedMessages == nil){
            dispatchedMessages = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

-(void)addMessageToBus:(Message*)newmessage
{
    if(newmessage.ttl == DEFAULT_TTL){
        [messageBus addObject:newmessage];
        if(dispsatchTimer == nil){
            [self startDispatching];
        }
    }
    else{
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:newmessage forKey:@"message"];
        [NSTimer scheduledTimerWithTimeInterval:newmessage.ttl target:self selector:@selector(dispatchThisMessage:) userInfo:userInfo repeats:NO];
    }
}


-(void)clearDispastchedMessages
{
    for (Message *msg in dispatchedMessages) {
        [messageBus removeObject:msg];
    }
    [dispatchedMessages removeAllObjects];
}

-(void)dispatchThisMessage:(NSTimer*)timer
{
    Message* message = [timer.userInfo objectForKey:@"message"];
    if(message){
        [self dispatchMessage:message];
    }
}

-(void)startDispatching
{
    dispsatchTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(leave) userInfo:nil repeats:YES];
}

-(void)stopDispathing
{
    if(dispsatchTimer){
        [dispsatchTimer invalidate];
        dispsatchTimer = nil;
    }
}

-(void)leave
{
    for(Message *msg in messageBus){
        [self dispatchMessage:msg];
    }
}


-(NSString*)messageTypeToString:(messageType)Type
{
    NSString *retMessage = @"";
    switch (Type) {
        case MESSAGETYPE_SIGNIN_RESPONSE:
            retMessage = @"MESSAGETYPE_SIGNIN_RESPONSE";
            break;
            
        default:
            break;
    }
    
    return retMessage;
}

-(void)dispatchMessage:(Message*)message
{
    switch (message.mesRoute) {
        case MESSAGEROUTE_API:
            if([self canSendMessage:message]){
               [self routeMessageToServerWithType:message];
            }
            [dispatchedMessages addObject:message];
            break;
        case MESSAGEROUTE_INTERNAL:
            [[NSNotificationCenter defaultCenter] postNotificationName:[self messageTypeToString:message.mesType] object:nil userInfo:message.params];
            [dispatchedMessages addObject:message];
            break;
        case MESSAGEROUTE_OTHER:
            break;
        default:
            break;
    }
}


-(void)routeMessageToServerWithType:(Message*)message
{
    switch (message.mesType) {
        case MESSAGETYPE_SIGNIN:
            [[CommManager sharedInstance] postAPI:@"NewUser" andParams:message.params];
            break;
        default:
            break;
    }
}


-(BOOL)canSendMessage:(Message*)message
{
    switch (message.mesType) {
        case MESSAGETYPE_SIGNIN:
        {
            if(message.params.count < 3){
                return NO;
            }
          
            if(((NSString*)([message.params objectForKey:@"apnskey"])).length <= 10){
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
