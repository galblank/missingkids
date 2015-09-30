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
#import <MessageUI/MessageUI.h>
#import "ABContactsViewController.h"
#import "CallingCardView.h"




@interface AppDelegate : UIResponder <UIApplicationDelegate,WYPopoverControllerDelegate,ABContactsDelegate>
{
    MainViewController *mainVc;
    CLLocationManager *locationManager;
    CLLocation* location;
    NSString *apnsToken;
    UIButton *menuButton;
    WYPopoverController* popoverController;
    NSMutableArray *sharemissingperson;
    MFMailComposeViewController *mailComp;
    UINavigationController * contactsController;
    MFMessageComposeViewController *messageController;
    CallingCardView * callwindow;
    BOOL bShouldUpdateLocation;
}
@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)shared;


-(void)showMenuButton;
-(void)hideMenuButton;


-(void)CancelSmsSending;
-(void)finishSendingSms:(NSArray*)theList;
@end

