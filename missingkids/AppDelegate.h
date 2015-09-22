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


#define TITLE_HEADER_COLOR [UIColor colorWithRed:133.0 / 255.0 green:150.0  / 255.0 blue:166.0 / 255.0 alpha:1.0]
#define THEME_GRAY_BG_COLOR [UIColor colorWithRed:243.0 / 255.0 green:243.0  / 255.0 blue:243.0 / 255.0 alpha:1.0]

#define GRAY_BG_COLOR [UIColor colorWithRed:240.0 / 255.0 green:240.0  / 255.0 blue:240.0 / 255.0 alpha:1.0]
#define TITLE_BUTTONS_COLOR [UIColor colorWithRed:11 / 255.0 green:192  / 255.0 blue:255.0 / 255.0 alpha:1.0]

#define THEME_COLOR_DISABLED [UIColor colorWithRed:105.0 / 255.0 green:217.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]


//#define ROOT_API @"http://galblank.com:8080/amberalertapi/"
#define ROOT_API    @"http://localhost:8080/amberalertapi/"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MainViewController *mainVc;
    CLLocationManager *locationManager;
    CLLocation* location;
    NSString *apnsToken;
}
@property (strong, nonatomic) UIWindow *window;
+ (AppDelegate*)shared;

@end

