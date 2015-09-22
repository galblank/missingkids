//
//  Message.h
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
    MESSAGETYPE_SIGNIN = 0,
    MESSAGETYPE_SIGNIN_RESPONSE = 1
}messageType;



@interface Message : NSObject

@property(nonatomic)messageRoute mesRoute;
@property(nonatomic)messageType mesType;
@property(nonatomic,strong)NSMutableDictionary *params;
@property(nonatomic)int ttl;

@end
