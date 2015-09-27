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
    MESSAGETYPE_CHANGE_MENU_BUTTON = 1002,
    MESSAGETYPE_SHOW_SHARING_MENU = 1003,
    MESSAGETYPE_SHARE_THIS_APP = 1004,
    MESSAGETYPE_SHOW_FILTER_OPTIONS = 1005,
    MESSAGETYPE_SHOW_SORTING_OPTIONS = 1006,
    MESSAGETYPE_CONTACT_DEVELOPER = 1007,
    MESSAGETYPE_HIDE_MENU = 1008,
    MESSAGETYPE_SORT_BY_MISSINGDATE = 1009,
    MESSAGETYPE_SORT_BY_AGE = 1010,
    MESSAGETYPE_SORT_BY_SEX = 1011
}messageType;

typedef enum {
    FLOATINGBUTTON_TYPE_MENU = 1,
    FLOATINGBUTTON_TYPE_BACK
}FLOATINGBUTTONTYPE;


@interface Message : NSObject

@property(nonatomic)messageRoute mesRoute;
@property(nonatomic)messageType mesType;
@property(nonatomic,strong)id params;
@property(nonatomic)int ttl;

@end
