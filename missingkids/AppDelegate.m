//
//  AppDelegate.m
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "AppDelegate.h"
#import "MessageDispatcher.h"

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
        msg.ttl = DEFAULT_TTL;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:apnsToken forKey:@"apnskey"];
        [params setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [params setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
        msg.params = params;
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    }
}
//////////////////////////PROPRETERY FUNCTiONS/////////////////////////////
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


@end
