//
//  AppDelegate.m
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "AppDelegate.h"
#import "MessageDispatcher.h"
#import "WYPopoverController/WYPopoverController.h"
#import "MenuViewController.h"
#import <MessageUI/MessageUI.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


AppDelegate *shared = nil;


+ (AppDelegate*)shared
{
    return shared;
}

- (id)init
{
    self = [super init];
    
    shared = self;
    return (self);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSLog(@"country code is: %@", countryCode);

    apnsToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"apnskey"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:TITLE_BUTTONS_COLOR];
    
    
    mainVc = [[MainViewController alloc] init];
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:mainVc];
    rootVC.navigationBarHidden = YES;
    self.window.rootViewController = rootVC;
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               TITLE_HEADER_COLOR,NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"HelveticaNeue-Regular" size:20],NSFontAttributeName
                                               ,nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];

    
    [self.window makeKeyAndVisible];
    
    
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self parsePushNotifications:[userInfo mutableCopy]];
    }
    
    [self startStandardUpdates];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//////////////////////////DELEGATE FUNCTiONS/////////////////////////////////
// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    apnsToken = hexToken;
    NSLog(@"DeviceToken: %@",apnsToken);
    [[NSUserDefaults standardUserDefaults] setObject:apnsToken forKey:@"apnskey"];
    [self signin];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
    if(err.code == 3010){
        //simulator
        apnsToken = @"simulator1010";
        [[NSUserDefaults standardUserDefaults] setObject:apnsToken forKey:@"apnskey"];
        [self signin];
    }
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    location = [locations lastObject];
    [locationManager stopUpdatingLocation];
    [self signin];
    
}


-(void)signin
{
    if(apnsToken && apnsToken.length > 10 && location != nil){
        Message * msg = [[Message alloc] init];
        msg.mesType = MESSAGETYPE_SIGNIN;
        msg.mesRoute = MESSAGEROUTE_API;
        msg.ttl = TTL_NOW;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:apnsToken forKey:@"apnskey"];
        [params setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [params setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
        msg.params = params;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signinresponse:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SIGNIN_RESPONSE] object:nil];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    }
}


-(void)signinresponse:(NSNotification*)notify
{
    NSLog(@"signinresponse: %@",notify.userInfo);
    Message * msg = [notify.userInfo objectForKey:@"message"];
    if([msg.params objectForKey:@"securitytoken"]){
        [[NSUserDefaults standardUserDefaults] setObject:[msg.params objectForKey:@"securitytoken"] forKey:@"securitytoken"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMenuButton) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_MENU_BUTTON] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenuButton) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_MENU_BUTTON] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMenuButton:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_CHANGE_MENU_BUTTON] object:nil];
    
    [self showMenuButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSharingMenu:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_SHARING_MENU] object:nil];
}

//////////////////////////PROPRETERY FUNCTiONS/////////////////////////////
-(void)sendMail{
    MFMailComposeViewController *mailComp = [[MFMailComposeViewController alloc] init];
    [mailComp setMailComposeDelegate:self];

    if ([MFMailComposeViewController canSendMail]) {
    
        [mailComp setSubject:@"Subject test"];
    
        [mailComp setMessageBody:@"Message body test" isHTML:NO];
    
        [[self topViewController] presentViewController:mailComp animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    if (error) {
        // Error handling
    }
    [controller dismissViewControllerAnimated:NO completion:nil];
}


-(void)showSharingMenu:(NSNotification*)notify
{
    Message * msg = [notify.userInfo objectForKey:@"message"];
    NSMutableArray * person = [msg.params objectForKey:@"person"];
    AAShareBubbles *shareBubbles = [[AAShareBubbles alloc] initCenteredInWindowWithRadius:130];
    shareBubbles.delegate = self;
    shareBubbles.bubbleRadius = 45; // Default is 40
    shareBubbles.showFacebookBubble = YES;
    shareBubbles.showTwitterBubble = YES;
    shareBubbles.showMailBubble = YES;
    shareBubbles.showVkBubble = YES;
    
    // add custom buttons -- buttonId for custom buttons MUST be greater than or equal to 100
    /*[shareBubbles addCustomButtonWithIcon:[UIImage imageNamed:@"custom-icon"]
                          backgroundColor:[UIColor greenColor]
                              andButtonId:100];*/
    
    
    [shareBubbles show];
}

-(void)aaShareBubbles:(AAShareBubbles *)shareBubbles tappedBubbleWithType:(AAShareBubbleType)bubbleType
{
    switch (bubbleType) {
        case AAShareBubbleTypeFacebook:
            NSLog(@"Facebook");
            break;
        case AAShareBubbleTypeTwitter:
            NSLog(@"Twitter");
            break;
        case AAShareBubbleTypeMail:
        {
            NSLog(@"Email");
            [self sendMail];
        }
            break;
        case AAShareBubbleTypeGooglePlus:
            NSLog(@"Google+");
            break;
        case AAShareBubbleTypeTumblr:
            NSLog(@"Tumblr");
            break;
        case AAShareBubbleTypeVk:
            NSLog(@"Vkontakte (vk.com)");
            break;
        case 100:
            // custom buttons have type >= 100
            NSLog(@"Custom Button With Type 100");
            break;
        default:
            break;
    }
}

-(void)aaShareBubblesDidHide:(AAShareBubbles *)bubbles {
    NSLog(@"All Bubbles hidden");
}

-(void)changeMenuButton:(NSNotification*)notify
{
    Message *msg = [notify.userInfo objectForKey:@"message"];
    FLOATINGBUTTONTYPE flbType = [[msg.params objectForKey:@"buttontype"] intValue];
    switch (flbType) {
        case FLOATINGBUTTON_TYPE_BACK:
        {
            if(menuButton.tag != FLOATINGBUTTON_TYPE_BACK){
                [menuButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
                [menuButton removeTarget:self action:@selector(populateMenu) forControlEvents:UIControlEventTouchUpInside];
                [menuButton addTarget:self action:@selector(popTopViewController) forControlEvents:UIControlEventTouchUpInside];
            }
        }
            break;
        case FLOATINGBUTTON_TYPE_MENU:
        {
            if(menuButton.tag != FLOATINGBUTTON_TYPE_MENU){
                [menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
                [menuButton removeTarget:self action:@selector(popTopViewController) forControlEvents:UIControlEventTouchUpInside];
                [menuButton addTarget:self action:@selector(populateMenu) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        default:
            break;
    }
    menuButton.tag = flbType;
}

-(void)popTopViewController
{
    [[self topViewController].navigationController popViewControllerAnimated:YES];
}

-(void)showMenuButton
{
    if(menuButton == nil){
        
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(self.window.frame.size.width - 80, self.window.frame.size.height - 80, 60, 60);
        menuButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        menuButton.layer.borderWidth = 0.3;
        menuButton.alpha = 0.8;
        [menuButton setBackgroundColor:[UIColor whiteColor]];
        [menuButton addTarget:self action:@selector(populateMenu) forControlEvents:UIControlEventTouchUpInside];
        menuButton.layer.cornerRadius = menuButton.frame.size.height / 2;
        [menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [self.window addSubview:menuButton];
    }
    menuButton.hidden = NO;
}

-(void)hideMenuButton
{
    if(menuButton){
        menuButton.hidden = YES;
    }
}

-(void)populateMenu
{
    MenuViewController *menu = [[MenuViewController alloc] init];
    if(popoverController == nil){
        popoverController = [[WYPopoverController alloc] initWithContentViewController:menu]; //content view controller needs to be tableviewcontroller
        popoverController.popoverContentSize = CGSizeMake(200, 200);
        popoverController.delegate = self;
    }
    [popoverController presentPopoverFromRect:menuButton.bounds inView:menuButton permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];

}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
}



- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    
    
    if (nil == locationManager){
        locationManager = [[CLLocationManager alloc] init];
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500; // meters
    
    [locationManager startUpdatingLocation];
}

- (void)parsePushNotifications:(NSMutableDictionary*)push
{
    NSLog(@"[AppDelegate] -parsePushNotifications- push: %@", push);
    
    NSNumber *type = [push objectForKey:@"type"];
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
        
    } else {
        return rootViewController;
    }
}
@end
