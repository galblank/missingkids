//
//  TimelineTableViewController.m
//  missingkids
//
//  Created by Gal Blank on 9/30/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "TimelineTableViewController.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MessageDispatcher.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "ImageResizer.h"
#import "UIImageView+AFNetworking.h"

@interface TimelineTableViewController ()

@end

@implementation TimelineTableViewController

@synthesize person;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableData = [[NSMutableArray alloc] init];
    [self loadmessagesfromDB];

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addInputView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40);
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messagesFromServer:)
                                                 name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_GET_ALL_MESSAGESFORCASE_RESPONSE]
                                               object:nil];
    
    [self fetchMessagesFromServer];
    
}

-(void)loadmessagesfromDB
{
    [tableData removeAllObjects];
    NSString * query = [NSString stringWithFormat:@"select * from timeline where caseid = '%@' order by createdat desc",[person objectAtIndex:CASE_NUMBER]];
    NSMutableArray * array = [[DBManager sharedInstance] loadDataFromDB:query];
    for(NSMutableArray * onemsg in array){
        NSNumber * _id          = [onemsg objectAtIndex:COLUMN_ID];
        NSString * caseid       = [onemsg objectAtIndex:COLUMN_CASEID];
        NSString * message      = [onemsg objectAtIndex:COLUMN_MESSAGE];
        NSNumber * createdat    = [onemsg objectAtIndex:COLUMN_CREATEDAT];
        NSString * submittedby  = [onemsg objectAtIndex:COLUMN_SUBMITTEDBY];
        NSString * imageid      = [onemsg objectAtIndex:COLUMN_IMAGEID];
        NSMutableDictionary * dicmessage = [[NSMutableDictionary alloc] init];
        [dicmessage setObject:_id forKey:@"id"];
        [dicmessage setObject:caseid forKey:@"caseid"];
        [dicmessage setObject:message forKey:@"message"];
        [dicmessage setObject:createdat forKey:@"createdat"];
        [dicmessage setObject:submittedby forKey:@"submittedby"];
        [dicmessage setObject:imageid forKey:@"imageid"];
        [tableData addObject:dicmessage];
    }
}

-(void)fetchMessagesFromServer
{
    if(tableData.count == 0){
        if(actView == nil){
            actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        }
        [self.view addSubview:actView];
        actView.center = self.view.center;
        [actView startAnimating];
    }
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_API;
    msg.mesType = MESSAGETYPE_GET_ALL_MESSAGESFORCASE;
    msg.ttl = DEFAULT_TTL;
    msg.params = [[NSMutableDictionary alloc] init];
    [msg.params setObject:[person objectAtIndex:CASE_NUMBER] forKey:@"caseid"];
    if(tableData && tableData.count > 0){
        NSMutableDictionary * lastmessage = [tableData lastObject];
        [msg.params setObject:[lastmessage objectForKey:@"id"] forKey:@"lastmessageid"];
    }
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        [bgView removeFromSuperview];
    }
}
-(void)messagesFromServer:(NSNotification*)notify
{
    [actView stopAnimating];
    Message * msg = [notify.userInfo objectForKey:@"message"];
    NSMutableArray * messagesfromserver = (NSMutableArray *)(msg.params);
    BOOL bHaveNewMessages = NO;
    for(NSMutableDictionary * onemessage in messagesfromserver){
        NSString * caseid = [onemessage objectForKey:@"caseid"];
        NSString * message = [onemessage objectForKey:@"message"];
        NSString * imageid = [onemessage objectForKey:@"imageid"];
        NSString * submittedby = [onemessage objectForKey:@"submittedby"];
        NSNumber * createdat = [onemessage objectForKey:@"createdat"];
        NSNumber * seedid = [onemessage objectForKey:@"seedid"];
        NSString * query = [NSString stringWithFormat:@"select * from timeline where seedid = '%@'",seedid];
       
        NSMutableArray * result = [[DBManager sharedInstance] loadDataFromDB:query];
        if(result == nil || result.count == 0){
            bHaveNewMessages = YES;
            query = [NSString stringWithFormat:@"insert into timeline values(%@,'%@','%@',%f,'%@','%@','%@')",nil,caseid,message,createdat.doubleValue,submittedby,imageid,seedid];
            [[DBManager sharedInstance] executeQuery:query];
        }
    }
    
    if(bHaveNewMessages){
        [self loadmessagesfromDB];
        [self.tableView reloadData];
    }
}

-(void)addInputView
{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.view.frame.size.height - 40, self.tableView.frame.size.width, 40)];
    bgView.backgroundColor = [UIColor whiteColor];
    //bgView.alpha = 0.3;
    textView = [[UITextView alloc] initWithFrame:CGRectMake(40,5, bgView.frame.size.width - 80, 30)];
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth = 0.5;
    textView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:textView];
    
    UIButton * imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = CGRectMake(3, 5, 30, 30);
    [imageButton setBackgroundImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:imageButton];
    
    UIButton * enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enterButton.frame = CGRectMake(bgView.frame.size.width - 33, 5, 30, 30);
    [enterButton setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:enterButton];
    
    [self.navigationController.view addSubview:bgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)textViewShouldEndEditing:(UITextView * _Nonnull)textView
{
    return YES;
}

-(void)sendMessage
{
    NSString * message = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(message.length == 0){
        return;
    }
    
    NSMutableDictionary * msgDic = [[NSMutableDictionary alloc] init];
    [msgDic setObject:textView.text forKey:@"message"];
    [msgDic setObject:[person objectAtIndex:CASE_NUMBER] forKey:@"caseid"];
    [msgDic setObject:[NSNumber  numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)] forKey:@"createdat"];
    [msgDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"] forKey:@"submittedby"];
    
    [tableData insertObject:msgDic atIndex:0];
    [self.tableView reloadData];
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:tableData.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    Message * msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_API;
    msg.mesType = MESSAGETYPE_SENDMESSAGE;
    msg.ttl = TTL_NOW;
    msg.params = [[NSMutableDictionary alloc] init];
    NSString * seedid = [NSString stringWithFormat:@"%@%f",[[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"],[[NSDate date] timeIntervalSince1970]];
    [msg.params setObject:seedid forKeyedSubscript:@"seedid"];
    [msg.params setObject:textView.text forKeyedSubscript:@"message"];
    
    NSString * caseid = [self.person objectAtIndex:CASE_NUMBER];
    [msg.params setObject:caseid forKey:@"caseid"];
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    textView.text = @"";
    
    NSString * query = [NSString stringWithFormat:@"insert into timeline values(%@,'%@','%@',%f,'%@','%@','%@')",nil,caseid,message,[[NSDate date] timeIntervalSince1970] * 1000,[[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"],@"",seedid];
    [[DBManager sharedInstance] executeQuery:query];
}

-(void)chooseImage
{
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Take Picture or Choose from Existing", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Picture", nil),NSLocalizedString(@"Select from existing", nil), nil];
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        
    }
    else if(buttonIndex == 1){
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    if(isKeyboardUp == NO){
        isKeyboardUp = YES;
    }
    else{
        return;
    }
    
    NSLog(@"[ChatRoomViewController] -keyboardDidShow-");
    
    NSDictionary* userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = bgView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    newFrame.origin.y -= keyboardFrame.size.height * 1;
    bgView.frame = newFrame;
    
    [self adjustChatviewOnKeyboardEvent:keyboardFrame.size.height];
    [UIView commitAnimations];
}

-(void)adjustChatviewOnKeyboardEvent:(CGFloat)animatedHeight
{
    
    if(animatedHeight == 0){
        keyboardHeight = 0;
        if(UIEdgeInsetsEqualToEdgeInsets(originalChatViewEdgeInsets, UIEdgeInsetsZero) == YES){
            originalChatViewEdgeInsets = self.tableView.contentInset;
            originalChatViewScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
            return;
        }
        self.tableView.contentInset = originalChatViewEdgeInsets;
        self.tableView.scrollIndicatorInsets = originalChatViewScrollIndicatorInsets;
    }
    else{
        keyboardHeight = animatedHeight;
        
        UIEdgeInsets currentContentInset = self.tableView.contentInset;
        if(UIEdgeInsetsEqualToEdgeInsets(originalChatViewEdgeInsets, UIEdgeInsetsZero) == YES){
            originalChatViewEdgeInsets = currentContentInset;
        }
        self.tableView.contentInset = UIEdgeInsetsMake(currentContentInset.top,currentContentInset.left, animatedHeight - currentContentInset.top,currentContentInset.right);
        
        UIEdgeInsets currentScrollInset = self.tableView.scrollIndicatorInsets;
        if(UIEdgeInsetsEqualToEdgeInsets(originalChatViewScrollIndicatorInsets, UIEdgeInsetsZero) == YES){
            originalChatViewScrollIndicatorInsets = currentScrollInset;
        }
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(currentScrollInset.top,currentScrollInset.left, animatedHeight - currentScrollInset.top,currentScrollInset.right);
        
        if(tableData.count > 0)
        {
                NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:(tableData.count - 1) inSection:0];
                [self.tableView scrollToRowAtIndexPath:lastIndex
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
            
        }
    }
}


-(void)adjustInsetsBy:(CGFloat)yInset
{
    UIEdgeInsets currentContentInset = self.tableView.contentInset;
    self.tableView.contentInset = UIEdgeInsetsMake(currentContentInset.top,currentContentInset.left, currentContentInset.bottom + yInset,currentContentInset.right);
    
    UIEdgeInsets currentScrollInset = self.tableView.scrollIndicatorInsets;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(currentScrollInset.top,currentScrollInset.left, currentScrollInset.bottom + yInset,currentScrollInset.right);
    
    CGPoint currentOffset = self.tableView.contentOffset;
    currentOffset.y = currentOffset.y + yInset;
    [self.tableView setContentOffset:currentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    
    if(isKeyboardUp == YES){
        isKeyboardUp = NO;
    }
    else{
        return;
    }
    
    NSDictionary* userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = bgView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    newFrame.origin.y -= keyboardFrame.size.height * -1;
    bgView.frame = newFrame;
    
    //self.tableView.frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    [UIView commitAnimations];
    
    [self adjustChatviewOnKeyboardEvent:-keyboardFrame.size.height];
}


#pragma mark - Table view data source

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        NSURL * url = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        
        
        [[MessageDispatcher sharedInstance] uploadAsset:imageToUse withBlock:^(NSString *imageID) {
            NSMutableDictionary * msgDic = [[NSMutableDictionary alloc] init];
            [msgDic setObject:imageID forKey:@"imageid"];
            [msgDic setObject:[person objectAtIndex:CASE_NUMBER] forKey:@"caseid"];
            [msgDic setObject:[NSNumber  numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"createdat"];
            [msgDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"] forKey:@"submittedby"];
            [tableData insertObject:msgDic atIndex:0];
            [self.tableView reloadData];
            
            Message * msg = [[Message alloc] init];
            msg.mesRoute = MESSAGEROUTE_API;
            msg.mesType = MESSAGETYPE_SENDMESSAGE;
            msg.ttl = TTL_NOW;
            msg.params = [[NSMutableDictionary alloc] init];
            NSString * seedid = [NSString stringWithFormat:@"%@%f",[[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"],[[NSDate date] timeIntervalSince1970]];
            [msg.params setObject:seedid forKeyedSubscript:@"seedid"];
            [msg.params setObject:imageID forKeyedSubscript:@"imageid"];
            NSString * caseid = [self.person objectAtIndex:CASE_NUMBER];
            [msg.params setObject:caseid forKey:@"caseid"];
            [[MessageDispatcher sharedInstance] addMessageToBus:msg];
            
            NSString * query = [NSString stringWithFormat:@"insert into timeline values(%@,'%@','%@',%f,'%@','%@','%@')",nil,caseid,@"",[[NSDate date] timeIntervalSince1970],[[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"],imageID,seedid];
            [[DBManager sharedInstance] executeQuery:query];
        }];
        
        
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:tableData.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        // Do something with the picked movie available at moviePath
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatcellid"];
    
    NSMutableDictionary * message = [tableData objectAtIndex:indexPath.row];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"chatcellid"];
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.layer.borderWidth = 0.3;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        cell.textLabel.textColor = [UIColor blackColor];
        
        
        
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        
    }
    
    cell.tag = indexPath.row;
    cell.imageView.image = nil;
    cell.textLabel.text = @"";
    NSNumber * createdat = [message objectForKey:@"createdat"];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:(createdat.doubleValue / 1000)];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:date];
    if(today){
        dateString = [NSDateFormatter localizedStringFromDate:date
                                                    dateStyle:NSDateFormatterNoStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    }
    cell.detailTextLabel.text = dateString;
    
    if([[message objectForKey:@"message"] length] > 0) {
        cell.textLabel.text = [message objectForKey:@"message"];
    }
    else if([[message objectForKey:@"imageid"] length] > 0) {
        [[MessageDispatcher sharedInstance] fetchAssetForImageID:[message objectForKey:@"imageid"] withBlock:^(UIImage *assetimage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell.tag == indexPath.row) {
                    cell.imageView.image = assetimage;
                    [cell setNeedsLayout];
                }
            });
        }];
    }

    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString * images = [person objectAtIndex:IMAGE];
    NSMutableArray *arrayOfImages = [[NSMutableArray alloc] init];
    while (images.length > 0) {
        NSString * oneimage = [images substringToIndex:2];
        [arrayOfImages addObject:oneimage];
        images = [images substringFromIndex:2];
    }
    NSString *imageurl = [arrayOfImages objectAtIndex:0];
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 100)];
    UIImageView * personimage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];
    NSString * buildFullPath = [NSString stringWithFormat:@"%@/%@%@%@.jpg",ROOT_IMAGES,[person objectAtIndex:ORG_PREFIX],[person objectAtIndex:CASE_NUMBER],imageurl];
    
    [personimage setImageWithURL:[NSURL URLWithString:buildFullPath] placeholderImage:[UIImage imageNamed:@"profile"]];
    personimage.layer.cornerRadius = personimage.frame.size.height / 2;
    personimage.layer.masksToBounds = YES;
    [header addSubview:personimage];
    
    UILabel * textlabel = [[UILabel alloc] initWithFrame:CGRectMake(personimage.frame.size.width + 5, 5, tableView.frame.size.width - 10, header.frame.size.height)];
    textlabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    textlabel.textColor = [UIColor blackColor];
    textlabel.text = [NSString stringWithFormat:@"%@ %@\r\n%@",[person objectAtIndex:FIRST_NAME],[person objectAtIndex:LAST_NAME],[person objectAtIndex:CIRCUMSTANCE]];
    [textlabel sizeToFit];
    [header addSubview:textlabel];
    
    header.backgroundColor = THEME_WARNING_COLOR;
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * message = [tableData objectAtIndex:indexPath.row];
    if([[message objectForKey:@"message"] length] > 0) {
        NSString * text = [message objectForKey:@"message"];
        CGSize s = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        return s.height + 10;
    }
    else if([[message objectForKey:@"imageid"] length] > 0) {
        return 200.0 + 10;
    }
    return 0.0;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
