//
//  definitions.h
//  missingkids
//
//  Created by Gal Blank on 9/30/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#ifndef definitions_h
#define definitions_h


#define THEME_WARNING_COLOR [UIColor colorWithRed:245.0 / 255.0 green:203.0  / 255.0 blue:34.0 / 255.0 alpha:1.0]
#define TITLE_HEADER_COLOR [UIColor colorWithRed:133.0 / 255.0 green:150.0  / 255.0 blue:166.0 / 255.0 alpha:1.0]
#define THEME_GRAY_BG_COLOR [UIColor colorWithRed:243.0 / 255.0 green:243.0  / 255.0 blue:243.0 / 255.0 alpha:1.0]

#define GRAY_BG_COLOR [UIColor colorWithRed:240.0 / 255.0 green:240.0  / 255.0 blue:240.0 / 255.0 alpha:1.0]
#define TITLE_BUTTONS_COLOR [UIColor colorWithRed:11 / 255.0 green:192  / 255.0 blue:255.0 / 255.0 alpha:1.0]

#define THEME_COLOR_DISABLED [UIColor colorWithRed:105.0 / 255.0 green:217.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]

#define AWSAccessKeyId   @"AKIAIRA3Y62O5JJ5HN6A"
#define AWSSecretKey     @"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"
#define AwsBucketUrl     @"http://s3.amazonaws.com"


#define ROOT_API @"http://galblank.com:8080/amberalertapi/"
//#define ROOT_API    @"http://localhost:8080/amberalertapi/"

typedef enum {
    FIRST_NAME = 1,
    MIDDLE_NAME = 2,
    LAST_NAME = 3,
    AGE = 4,
    SEX = 5,
    RACE = 6,
    AGENOW = 7,
    IMAGE = 8,
    BIRTHDATE = 9,
    CASE_NUMBER = 10,
    CASE_TYPE = 11,
    CIRCUMSTANCE = 12,
    EYE_COLOR = 13,
    HAIR_COLOR = 14,
    HEIGHT = 15,
    WEIGHT = 16,
    MISSING_CITY = 17,
    MISSING_COUNTRY = 18,
    MISSING_COUNTY = 19,
    MISSING_PROVINCE = 20,
    MISSING_STATE = 21,
    MISSING_DATE = 22,
    ORG_CONTACT_INFO = 23,
    ORG_LOGO = 24,
    ORG_NAME = 25,
    ORG_PREFIX = 26,
    LAST_UPDATED = 27
}PERSON_TABLE_COLUMNS;


typedef enum{
    COLUMN_ID = 0,
    COLUMN_CASEID,
    COLUMN_MESSAGE,
    COLUMN_CREATEDAT,
    COLUMN_SUBMITTEDBY,
    COLUMN_IMAGEID,
    COLUMN_SEEDID
}MESSAGES_TABLE_COLUMNS;


typedef enum{
    SORTING_MISSING_DATE_DESC = 1,
    SORTING_MISSING_DATE_ASC,
    SORTING_AGE_DESC,
    SORTING_AGE_ASC,
    SORTING_SEX_MALE,
    SORTING_SEX_FEMALE
}SORTING_OPTIONS;


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
    MESSAGETYPE_HIDE_FILTER_OPTIONS = 1006,
    MESSAGETYPE_SHOW_SORTING_OPTIONS = 1007,
    MESSAGETYPE_CONTACT_DEVELOPER = 1008,
    MESSAGETYPE_HIDE_MENU = 1009,
    MESSAGETYPE_SORT_BY_MISSINGDATE = 1010,
    MESSAGETYPE_SORT_BY_AGE = 1011,
    MESSAGETYPE_SORT_BY_SEX = 1012,
    MESSAGETYPE_FILTERBY_COUNTRY = 1013,
    MESSAGETYPE_SHOW_LIST_VIEW = 1014,
    MESSAGETYPE_APPLY_FILTER = 1015,
    MESSAGETYPE_CLEAR_FILTER = 1016,
    MESSAGETYPE_CALL_REGIONAL_AUTHORITIES = 1017,
    MESSAGETYPE_HIDE_CALLINGCARD = 1018,
    MESSAGETYPE_FETCH_GETREGIONALCONTACTS = 1019,
    MESSAGETYPE_FETCH_GETREGIONALCONTACTS_RESPONSE = 1020,
    MESSAGETYPE_UPDATE_LOCATION = 1021,
    MESSAGETYPE_GENERAL_SUCCESS = 10000,
    MESSAGETYPE_UPLOADIMAGE = 1022,
    MESSAGETYPE_SENDMESSAGE = 1023,
    MESSAGETYPE_SENDMESSAGE_RESPONSE = 1024,
    MESSAGETYPE_GET_ALL_MESSAGESFORCASE = 1025,
    MESSAGETYPE_GET_ALL_MESSAGESFORCASE_RESPONSE = 1026,
    MESSAGETYPE_DOWNLOAD_ASSET = 1027,
    MESSAGETYPE_GOTOTIMELINE = 1028
}messageType;

typedef enum {
    FLOATINGBUTTON_TYPE_MENU = 1,
    FLOATINGBUTTON_TYPE_BACK
}FLOATINGBUTTONTYPE;

#define DEFAULT_TTL 15.0
#define TTL_NOW 0.5;
#define CLEANUP_TIMER 10.0

typedef enum{
    MENUTYPE_MAIN = 1,
    MENUTYPE_SORT,
    MENUTYPE_FILTER
}MENU_TYPES;

#define ROOT_IMAGES @"http://www.missingkids.com/photographs/"

typedef enum{
    ITEM_TYPE_COUNTRY = 0,
    ITEM_TYPE_STATE,
    ITEM_TYPE_CITY
}ITEMTYPE;

#endif /* definitions_h */
