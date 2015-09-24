//
//  AppDelegate.h
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WYPopoverController.h"

#define TITLE_HEADER_COLOR [UIColor colorWithRed:133.0 / 255.0 green:150.0  / 255.0 blue:166.0 / 255.0 alpha:1.0]
#define THEME_GRAY_BG_COLOR [UIColor colorWithRed:243.0 / 255.0 green:243.0  / 255.0 blue:243.0 / 255.0 alpha:1.0]

#define GRAY_BG_COLOR [UIColor colorWithRed:240.0 / 255.0 green:240.0  / 255.0 blue:240.0 / 255.0 alpha:1.0]
#define TITLE_BUTTONS_COLOR [UIColor colorWithRed:11 / 255.0 green:192  / 255.0 blue:255.0 / 255.0 alpha:1.0]

#define THEME_COLOR_DISABLED [UIColor colorWithRed:105.0 / 255.0 green:217.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]


//#define ROOT_API @"http://galblank.com:8080/amberalertapi/"
#define ROOT_API    @"http://localhost:8080/amberalertapi/"



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



@interface AppDelegate : UIResponder <UIApplicationDelegate,WYPopoverControllerDelegate>
{
    MainViewController *mainVc;
    CLLocationManager *locationManager;
    CLLocation* location;
    NSString *apnsToken;
    UIButton *menuButton;
    WYPopoverController* popoverController;
}
@property (strong, nonatomic) UIWindow *window;
+ (AppDelegate*)shared;


-(void)showMenuButton;
-(void)hideMenuButton;

@end

