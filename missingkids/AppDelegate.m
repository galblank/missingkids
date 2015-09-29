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
#import "Social/Social.h"
#import "UIKit+AFNetworking.h"
#import "AFContact.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DBManager.h"


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
    
    bShouldUpdateLocation = NO;
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSLog(@"country code is: %@", countryCode);
    
    apnsToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"apnskey"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor lightGrayColor]];
    
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMenuButton) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_MENU_BUTTON] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenuButton) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_MENU_BUTTON] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMenuButton:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_CHANGE_MENU_BUTTON] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactDeveloper) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_CONTACT_DEVELOPER] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareThisApp) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHARE_THIS_APP] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenu) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_MENU] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCallingCard) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_CALLINGCARD] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeacall) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_CALL_REGIONAL_AUTHORITIES] object:nil];
    [self showMenuButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSharingMenu:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_SHARING_MENU] object:nil];
    
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
    
    if(location != nil){
        return;
    }
    
    location = [locations lastObject];
    [locationManager stopUpdatingLocation];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"]){
        [self updateLocation];
    }
    else{
        bShouldUpdateLocation = YES;
    }
}

-(void)updateLocation
{
    Message * msg = [[Message alloc] init];
    msg.mesType = MESSAGETYPE_UPDATE_LOCATION;
    msg.mesRoute = MESSAGEROUTE_API;
    msg.ttl = DEFAULT_TTL;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [params setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    msg.params = params;
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}


-(void)signin
{
    if(apnsToken && apnsToken.length > 10){
        Message * msg = [[Message alloc] init];
        msg.mesType = MESSAGETYPE_SIGNIN;
        msg.mesRoute = MESSAGEROUTE_API;
        msg.ttl = TTL_NOW;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:apnsToken forKey:@"apnskey"];
        msg.params = params;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signinresponse:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SIGNIN_RESPONSE] object:nil];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    }
}


-(void)fetchpersons
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"]){
        Message * msg = [[Message alloc] init];
        msg.mesType = MESSAGETYPE_FETCH_PERSONS;
        msg.mesRoute = MESSAGEROUTE_API;
        msg.ttl = DEFAULT_TTL;
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    }
}

-(void)signinresponse:(NSNotification*)notify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SIGNIN_RESPONSE] object:nil];
    NSLog(@"signinresponse: %@",notify.userInfo);
    Message * msg = [notify.userInfo objectForKey:@"message"];
    if([msg.params objectForKey:@"securitytoken"]){
        [[NSUserDefaults standardUserDefaults] setObject:[msg.params objectForKey:@"securitytoken"] forKey:@"securitytoken"];
        Message * msg = [[Message alloc] init];
        msg.mesType = MESSAGETYPE_FETCH_GETREGIONALCONTACTS;
        msg.mesRoute = MESSAGEROUTE_API;
        msg.ttl = TTL_NOW;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedRegionalContacts:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_FETCH_GETREGIONALCONTACTS_RESPONSE] object:nil];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
        if(bShouldUpdateLocation){
            [self updateLocation];
        }
        [self fetchpersons];
    }
}

-(void)updatedRegionalContacts:(NSNotification*)notify
{
    Message * msg = [notify.userInfo objectForKey:@"message"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSMutableDictionary * contact in msg.params){
            NSString * country = [contact objectForKey:@"country"];
            NSString * state = [contact objectForKey:@"state"];
            NSString * contactname = [contact objectForKey:@"contactname"];
            NSString * contactnumber = [contact objectForKey:@"contactnumber"];
            NSString * isostate = [contact objectForKey:@"isostate"];
            NSString * query = [NSString stringWithFormat:@"select * from regionalcontacts where country = '%@' AND state = '%@'",country,state];
            NSMutableArray * result = [[DBManager sharedInstance] loadDataFromDB:query];
            if(result && result.count > 0){
                query = [NSString stringWithFormat:@"update regionalcontacts set contactnumber = '%@', contactname = '%@'",contactnumber,contactname];
            }
            else{
                query = [NSString stringWithFormat:@"insert into regionalcontacts values('%@','%@','%@','%@','%@')",country,state,contactname,contactnumber,isostate];
            }
            [[DBManager sharedInstance] executeQuery:query];
        }
    });
}

//////////////////////////PROPRETERY FUNCTiONS/////////////////////////////
-(void)makeacall
{
    if(callwindow == nil){
        callwindow = [[CallingCardView alloc] initWithFrame:CGRectMake(0,-250,self.window.frame.size.width,250)];
        callwindow.infoDoc = sharemissingperson;
        [callwindow updateUI];
        [self.window addSubview:callwindow];
    }
    
    [UIView animateWithDuration:0.5
                         animations:^{
                             callwindow.frame = CGRectMake(0,0,self.window.frame.size.width,250);
                         }
                         completion:^(BOOL finished){
                             [self.window bringSubviewToFront:callwindow];
                         }];
    
    
    
}


-(void)hideCallingCard
{
    if(callwindow){
        [UIView animateWithDuration:0.5
                     animations:^{
                         callwindow.frame = CGRectMake(0,-250,self.window.frame.size.width,250);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    }
}

-(void)shareThisApp
{
    [self showSharingMenu:nil];
}
-(void)contactDeveloper
{
    if(mailComp == nil){
        mailComp = [[MFMailComposeViewController alloc] init];
        [mailComp setMailComposeDelegate:self];
    }
    if ([MFMailComposeViewController canSendMail]) {
        [mailComp setToRecipients:@[@"galblank@gmail.com"]];
        [mailComp setSubject:NSLocalizedString(@"Contact for MissingKids developer", nil)];
        [self.window.rootViewController presentViewController:mailComp animated:YES completion:nil];
    }
}
-(void)sendMail{
    if(mailComp == nil){
        mailComp = [[MFMailComposeViewController alloc] init];
        [mailComp setMailComposeDelegate:self];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        [mailComp setSubject:NSLocalizedString(@"Please help find this missing child!", nil)];
        NSNumber * missingDate = [sharemissingperson objectAtIndex:MISSING_DATE];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:(missingDate.doubleValue / 1000)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MMM dd yyyy";
        NSString * strDate = [df stringFromDate:date];
        NSString *shareString = [NSString stringWithFormat:@"%@\r\n%@ %@ went missing on %@ from %@ %@",NSLocalizedString(@"Please help find this missing child!", nil),[sharemissingperson objectAtIndex:FIRST_NAME],[sharemissingperson objectAtIndex:LAST_NAME],strDate,[sharemissingperson objectAtIndex:MISSING_CITY],[sharemissingperson objectAtIndex:MISSING_COUNTRY]];
        [mailComp setMessageBody:shareString isHTML:YES];
        if([[sharemissingperson lastObject] isKindOfClass:[UIImage class]]){
            [mailComp addAttachmentData:UIImageJPEGRepresentation([sharemissingperson lastObject],1.0) mimeType:@"image/jpeg" fileName:@"image"];
        }
        
        [self.window.rootViewController presentViewController:mailComp animated:YES completion:nil];
    }
}


-(void)TweetPressed{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSNumber * missingDate = [sharemissingperson objectAtIndex:MISSING_DATE];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:(missingDate.doubleValue / 1000)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MMM dd yyyy";
        NSString * strDate = [df stringFromDate:date];
        NSString *shareString = [NSString stringWithFormat:@"%@\r\n%@ %@ went missing on %@ from %@ %@",NSLocalizedString(@"Please help find this missing child!", nil),[sharemissingperson objectAtIndex:FIRST_NAME],[sharemissingperson objectAtIndex:LAST_NAME],strDate,[sharemissingperson objectAtIndex:MISSING_CITY],[sharemissingperson objectAtIndex:MISSING_COUNTRY]];
        [tweetSheet setInitialText:shareString];
        if([[sharemissingperson lastObject] isKindOfClass:[UIImage class]]){
            [tweetSheet addImage:[sharemissingperson lastObject]];
        }
        [[self topViewController] presentViewController:tweetSheet animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}


-(void)FBPressed{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSNumber * missingDate = [sharemissingperson objectAtIndex:MISSING_DATE];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:(missingDate.doubleValue / 1000)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MMM dd yyyy";
        NSString * strDate = [df stringFromDate:date];
        NSString *shareString = [NSString stringWithFormat:@"%@\r\n%@ %@ went missing on %@ from %@ %@",NSLocalizedString(@"Please help find this missing child!", nil),[sharemissingperson objectAtIndex:FIRST_NAME],[sharemissingperson objectAtIndex:LAST_NAME],strDate,[sharemissingperson objectAtIndex:MISSING_CITY],[sharemissingperson objectAtIndex:MISSING_COUNTRY]];
        if([fbPostSheet setInitialText:shareString] == NO){
            
        }
        if([[sharemissingperson lastObject] isKindOfClass:[UIImage class]]){
            [fbPostSheet addImage:[sharemissingperson lastObject]];
        }
        [[self topViewController] presentViewController:fbPostSheet animated:YES completion:nil];
    } else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't post right now, make sure your device has an internet connection and you have at least one facebook account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
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
    if(notify){
        Message * msg = [notify.userInfo objectForKey:@"message"];
        sharemissingperson = [msg.params objectForKey:@"person"];
    }
    else{
        sharemissingperson = nil;
    }
    AAShareBubbles *shareBubbles = [[AAShareBubbles alloc] initCenteredInWindowWithRadius:130];
    shareBubbles.delegate = self;
    shareBubbles.bubbleRadius = 45; // Default is 40
    shareBubbles.showFacebookBubble = YES;
    shareBubbles.showTwitterBubble = YES;
    shareBubbles.showMailBubble = YES;
    shareBubbles.showSmsBubble = YES;
    shareBubbles.showPhoneBubble = YES;
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
            [self FBPressed];
            break;
        case AAShareBubbleTypeTwitter:
            NSLog(@"Twitter");
            [self TweetPressed];
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
        case AAShareBubbleTypeSMS:
            NSLog(@"SMS");
            [self sendText];
            break;
        case AAShareBubbleTypePhone:
            [self makeacall];
            break;
        case 100:
            // custom buttons have type >= 100
            NSLog(@"Custom Button With Type 100");
            break;
        default:
            break;
    }
}


-(void)CancelSmsSending{
    [contactsController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)finishSendingSms:(NSArray*)theList
{
    NSLog(@"finishSendingSms");
    [contactsController dismissViewControllerAnimated:YES completion:^{
        if((theList) && (theList.count > 0))
        {
            NSMutableArray *listOfPhoneNumbers = [NSMutableArray array];
            
            for(AFContact *contact in theList)
            {
                NSArray *userPhoneNumberList = contact.numbers;
                
                if((userPhoneNumberList) && (userPhoneNumberList.count > 0))
                {
                    for(NSString *eachNumber in userPhoneNumberList)
                    {
                        NSLog(@"eachNumber: %@", eachNumber);
                        
                        // Might need to clean up the numbers here...
                        
                        [listOfPhoneNumbers addObject:eachNumber];
                    }
                }
            }
            

            NSNumber * missingDate = [sharemissingperson objectAtIndex:MISSING_DATE];
            NSDate * date = [NSDate dateWithTimeIntervalSince1970:(missingDate.doubleValue / 1000)];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"MMM dd yyyy";
            NSString * strDate = [df stringFromDate:date];
            NSString *shareString = [NSString stringWithFormat:@"%@\r\n%@ %@ went missing on %@ from %@ %@",NSLocalizedString(@"Please help find this missing child!", nil),[sharemissingperson objectAtIndex:FIRST_NAME],[sharemissingperson objectAtIndex:LAST_NAME],strDate,[sharemissingperson objectAtIndex:MISSING_CITY],[sharemissingperson objectAtIndex:MISSING_COUNTRY]];
            
            
            if(listOfPhoneNumbers.count > 0)
            {
                if(messageController == nil)
                {
                    messageController = [[MFMessageComposeViewController alloc] init];
                }
                
                
                if(messageController)
                {
                    messageController.messageComposeDelegate = self;
                    [messageController setRecipients:listOfPhoneNumbers];
                    [messageController setBody:shareString];
                    if([[sharemissingperson lastObject] isKindOfClass:[UIImage class]]){
                        if([messageController addAttachmentData:UIImageJPEGRepresentation([sharemissingperson lastObject], 1.0) typeIdentifier:@"public.jpeg" filename:@"image.jpg"] == NO){
                            NSLog(@"Adding attachment failed");
                        }
                    }
                    
                    [self.window.rootViewController presentViewController:messageController animated:YES completion:NULL];
                    
                }
                else
                {
                    NSLog(@"{WARNING} The Simulator can't show the MFMessageComposeViewController interface.");
                }
            }
            
        }
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    
    if(result == MessageComposeResultSent)
    {
        NSLog(@"MessageComposeResultSent");
    }
    
    if(result == MessageComposeResultCancelled)
    {
        NSLog(@"MessageComposeResultCancelled");
    }
    
    if(result == MessageComposeResultFailed)
    {
        NSLog(@"MessageComposeResultCancelled");
    }
    
    
    [messageController dismissViewControllerAnimated:YES completion:^
     {
         
     }];
}

- (void)sendText
{
    NSLog(@"sendText");
    
    if([MFMessageComposeViewController canSendText] == YES)
    {
        ABContactsViewController *abcontact = [[ABContactsViewController alloc] init];
        abcontact.abcontactsDel = self;
        contactsController = [[UINavigationController alloc] initWithRootViewController:abcontact];
        [self.window.rootViewController presentViewController:contactsController animated:YES completion:^
         {
         }];
    }
    else
    {
        NSString *title   = NSLocalizedString(@"Device Settings", nil);
        NSString *message = NSLocalizedString(@"Your device is not currently configured to support sending a message. Please check your device Settings and try again.", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
        [alert show];
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
    MenuViewController *menu = [[MenuViewController alloc] initWithStyle:UITableViewStylePlain];
    if(popoverController == nil){
        popoverController = [[WYPopoverController alloc] initWithContentViewController:menu]; //content view controller needs to be tableviewcontroller
        [popoverController setTheme:[WYPopoverTheme themeForIOS7]];
        popoverController.popoverContentSize = CGSizeMake(200, 200);
        popoverController.delegate = self;
    }
    [popoverController presentPopoverFromRect:menuButton.bounds inView:menuButton permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    
}

-(void)hideMenu
{
    if(popoverController){
        [popoverController dismissPopoverAnimated:YES];
    }
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
