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
    MESSAGETYPE_SIGNIN_RESPONSE = 1,
    MESSAGETYPE_FETCH_PERSONS = 2,
    MESSAGETYPE_FETCH_PERSON_RESPONSE=3,
    MESSAGETYPE_HIDE_MENU_BUTTON = 1000,
    MESSAGETYPE_SHOW_MENU_BUTTON = 1001,
    MESSAGETYPE_CHANGE_MENU_BUTTON = 1002
}messageType;



@interface Message : NSObject

@property(nonatomic)messageRoute mesRoute;
@property(nonatomic)messageType mesType;
@property(nonatomic,strong)id params;
@property(nonatomic)int ttl;

@end
