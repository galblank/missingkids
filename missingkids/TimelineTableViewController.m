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

@interface TimelineTableViewController ()

@end

@implementation TimelineTableViewController

@synthesize person;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableData = [[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"select * from timeline where caseid = '%@' order by id desc",[person objectAtIndex:CASE_NUMBER]];
    tableData = [[DBManager sharedInstance] loadDataFromDB:query];

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self addInputView];

    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40);
    
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

-(void)fetchMessagesFromServer
{
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

-(void)messagesFromServer:(NSNotification*)notify
{
    Message * msg = [notify.userInfo objectForKey:@"message"];
    NSMutableArray * messagesfromserver = (NSMutableArray *)(msg.params);
    for(NSMutableDictionary * onemessage in messagesfromserver){
        NSString * caseid = [onemessage objectForKey:@"caseid"];
        NSString * message = [onemessage objectForKey:@"message"];
        NSString * imageid = [onemessage objectForKey:@"imageid"];
        NSString * submittedby = [onemessage objectForKey:@"submittedby"];
        NSNumber * createdat = [onemessage objectForKey:@"createdat"];
        
        NSString * query = [NSString stringWithFormat:@"select * from timeline where createdat = %f and submittedby = '%@'",createdat.floatValue,submittedby];
        NSMutableArray * result = [[DBManager sharedInstance] loadDataFromDB:query];
        if(result && result.count > 0){
            //exists
        }
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
    [tableData addObject:textView.text];
    [self.tableView reloadData];
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:tableData.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    Message * msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_API;
    msg.mesType = MESSAGETYPE_SENDMESSAGE;
    msg.ttl = TTL_NOW;
    msg.params = [[NSMutableDictionary alloc] init];
    [msg.params setObject:textView.text forKeyedSubscript:@"message"];
    
    NSString * caseid = [self.person objectAtIndex:CASE_NUMBER];
    [msg.params setObject:caseid forKey:@"caseid"];
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    textView.text = @"";
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
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y - keyboardFrame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    [UIView commitAnimations];
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
    
    self.tableView.frame = CGRectMake(0,0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    [UIView commitAnimations];
    
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
        
        NSUInteger imgSize  = CGImageGetHeight(imageToUse.CGImage) * CGImageGetBytesPerRow(imageToUse.CGImage);
        
        Message * msg = [[Message alloc] init];
        msg.mesRoute = MESSAGEROUTE_API;
        msg.mesType = MESSAGETYPE_UPLOADIMAGE;
        msg.ttl = TTL_NOW;
         NSData *imgData = UIImageJPEGRepresentation(imageToUse, 0);
        msg.params = [[NSMutableDictionary alloc] init];
        [msg.params setObject:imageToUse forKey:@"image"];
        [msg.params setObject:[NSNumber numberWithInteger:imgData.length] forKey:@"size"];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
        
        [tableData addObject:imageToUse];
        [self.tableView reloadData];
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:tableData.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        /*Message * msg = [[Message alloc] init];
        msg.mesRoute = MESSAGEROUTE_API;
        msg.mesType = MESSAGETYPE_SENDMESSAGE;
        msg.ttl = TTL_NOW;
        msg.params = [[NSMutableDictionary alloc] init];
        [msg.params setObject:imageToUse forKeyedSubscript:@"image"];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];*/
        // Do something with imageToUse
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
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatcellid"];
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.layer.borderWidth = 0.3;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    id object = [tableData objectAtIndex:indexPath.row];
    if([object isKindOfClass:[NSString class]]){
        cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    }
    else if([object isKindOfClass:[UIImage class]]){
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width / 2 - 100, 5, 200, 200)];
        image.image = (UIImage*)object;
        [cell.contentView addSubview:image];
    }

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [tableData objectAtIndex:indexPath.row];
    if([object isKindOfClass:[NSString class]]){
        NSString * text = [tableData objectAtIndex:indexPath.row];
        CGSize s = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        return s.height + 10;
    }
    else if([object isKindOfClass:[UIImage class]]){
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
