//
//  MessageDispatcher.h
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

#define DEFAULT_TTL 15.0
#define TTL_NOW 0.5;

@interface MessageDispatcher : NSObject
{
    NSTimer *dispsatchTimer;
    NSMutableArray * messageBus;
    
    NSMutableArray * dispatchedMessages;
}
+ (MessageDispatcher*) sharedInstance;


-(void)addMessageToBus:(Message*)newmessage;
-(void)startDispatching;
-(void)stopDispathing;
-(NSString*)messageTypeToString:(messageType)Type;
@end
