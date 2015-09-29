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
        
        [NSTimer scheduledTimerWithTimeInterval:CLEANUP_TIMER target:self selector:@selector(clearDispastchedMessages) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)addMessageToBus:(Message*)newmessage
{
    if(newmessage.mesType == MESSAGETYPE_GENERAL_SUCCESS){
        NSLog(@"General success result");
        return;
    }
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
    dispsatchTimer = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_TTL target:self selector:@selector(leave) userInfo:nil repeats:YES];
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
        case MESSAGETYPE_FETCH_PERSONS:
            retMessage = @"MESSAGETYPE_FETCH_PERSONS";
            break;
        case MESSAGETYPE_FETCH_PERSON_RESPONSE:
            retMessage = @"MESSAGETYPE_FETCH_PERSON_RESPONSE";
            break;
        case MESSAGETYPE_HIDE_MENU_BUTTON:
            retMessage = @"MESSAGETYPE_HIDE_MENU_BUTTON";
            break;
        case MESSAGETYPE_SHOW_MENU_BUTTON:
            retMessage = @"MESSAGETYPE_SHOW_MENU_BUTTON";
            break;
        case MESSAGETYPE_CHANGE_MENU_BUTTON:
            retMessage = @"MESSAGETYPE_CHANGE_MENU_BUTTON";
            break;
        case MESSAGETYPE_SHOW_SHARING_MENU:
            retMessage = @"MESSAGETYPE_SHOW_SHARING_MENU";
            break;
        case MESSAGETYPE_SHARE_THIS_APP:
            retMessage = @"MESSAGETYPE_SHARE_THIS_APP";
            break;
        case MESSAGETYPE_SHOW_FILTER_OPTIONS:
            retMessage = @"MESSAGETYPE_SHOW_FILTER_OPTIONS";
            break;
        case MESSAGETYPE_SHOW_SORTING_OPTIONS:
            retMessage = @"MESSAGETYPE_SHOW_SORTING_OPTIONS";
            break;
        case MESSAGETYPE_CONTACT_DEVELOPER:
            retMessage = @"MESSAGETYPE_CONTACT_DEVELOPER";
            break;
        case MESSAGETYPE_HIDE_MENU:
            retMessage = @"MESSAGETYPE_HIDE_MENU";
            break;
        case MESSAGETYPE_SORT_BY_MISSINGDATE:
            retMessage = @"MESSAGETYPE_SORT_BY_MISSINGDATE";
            break;
        case MESSAGETYPE_SORT_BY_AGE:
            retMessage = @"MESSAGETYPE_SORT_BY_AGE";
            break;
        case MESSAGETYPE_SORT_BY_SEX:
            retMessage = @"MESSAGETYPE_SORT_BY_SEX";
            break;
        case MESSAGETYPE_HIDE_FILTER_OPTIONS:
            retMessage = @"MESSAGETYPE_HIDE_FILTER_OPTIONS";
            break;
        case MESSAGETYPE_SHOW_LIST_VIEW:
            retMessage = @"MESSAGETYPE_SHOW_LIST_VIEW";
            break;
        case MESSAGETYPE_APPLY_FILTER:
            retMessage = @"MESSAGETYPE_APPLY_FILTER";
            break;
        case MESSAGETYPE_CLEAR_FILTER:
            retMessage = @"MESSAGETYPE_CLEAR_FILTER";
            break;
        case MESSAGETYPE_CALL_REGIONAL_AUTHORITIES:
            retMessage = @"MESSAGETYPE_CALL_REGIONAL_AUTHORITIES";
            break;
        case MESSAGETYPE_HIDE_CALLINGCARD:
            retMessage = @"MESSAGETYPE_HIDE_CALLINGCARD";
            break;
        case MESSAGETYPE_FETCH_GETREGIONALCONTACTS_RESPONSE:
            retMessage = @"MESSAGETYPE_FETCH_GETREGIONALCONTACTS_RESPONSE";
            break;
        case MESSAGETYPE_UPDATE_LOCATION:
            retMessage = @"MESSAGETYPE_UPDATE_LOCATION";
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
        {
            NSMutableDictionary * messageDic = [[NSMutableDictionary alloc] init];
            [messageDic setObject:message forKey:@"message"];
            [[NSNotificationCenter defaultCenter] postNotificationName:[self messageTypeToString:message.mesType] object:nil userInfo:messageDic];
            [dispatchedMessages addObject:message];
        }
            break;
        case MESSAGEROUTE_OTHER:
            break;
        default:
            break;
    }
}


-(void)routeMessageToServerWithType:(Message*)message
{
    if(message.params == nil){
        message.params = [[NSMutableDictionary alloc] init];
    }
    NSString * sectoken = [[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"];
    
    if(sectoken && sectoken.length > 0){
        [message.params setObject:sectoken forKey:@"securitytoken"];
    }
    
    switch (message.mesType) {
        case MESSAGETYPE_SIGNIN:
            [[CommManager sharedInstance] postAPI:@"NewUser" andParams:message.params];
            break;
        case MESSAGETYPE_FETCH_PERSONS:
            [[CommManager sharedInstance] getAPI:@"fetchpersons" andParams:message.params];
            break;
        case MESSAGETYPE_FETCH_GETREGIONALCONTACTS:
            [[CommManager sharedInstance] getAPI:@"GetRegionalContacts" andParams:message.params];
            break;
        case MESSAGETYPE_UPDATE_LOCATION:
            [[CommManager sharedInstance] postAPI:@"updatelocation" andParams:message.params];
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
            if(((NSString*)([message.params objectForKey:@"apnskey"])).length <= 10){
                return NO;
            }
            
            
        }
        break;
        case MESSAGETYPE_FETCH_PERSONS:
        case MESSAGETYPE_FETCH_GETREGIONALCONTACTS:
        case MESSAGETYPE_UPDATE_LOCATION:
            return YES;
        default:
            break;
    }
    
    return YES;
}


@end
