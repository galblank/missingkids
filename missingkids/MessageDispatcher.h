//
//  MessageDispatcher.h
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    MESSAGEROUTE_INTERNAL,
    MESSAGEROUTE_API,
    MESSAGEROUTE_OTHER
}messageRoute;

typedef enum{
    MESSAGETYPE_SIGNIN
}messageType;

@interface MessageDispatcher : NSObject

+ (MessageDispatcher*)shared;


@end
