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


@interface MessageDispatcher : NSObject
{
    NSTimer *dispsatchTimer;
    NSMutableArray*messageBus;
}
+ (MessageDispatcher*) sharedInstance;


-(void)addMessageToBus:(Message*)newmessage;
-(void)startDispatching;
-(void)stopDispathing;

@end
