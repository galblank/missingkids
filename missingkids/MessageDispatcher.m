//
//  MessageDispatcher.m
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "MessageDispatcher.h"
#import "CommManager.h"

@implementation MessageDispatcher

MessageDispatcher *sharedInstance = nil;


+ (MessageDispatcher*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
            
        }
    }
    
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedInstance;
        }
    }
    // on subsequent allocation attempts return nil
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(id)init
{
    if (self = [super init]) {
        if(messageBus == nil){
            messageBus = [[NSMutableArray alloc] init];
        }
        
        if(dispatchedMessages == nil){
            dispatchedMessages = [[NSMutableArray alloc] init];
        }
        
        
             [NSTimer scheduledTimerWithTimeInterval:CLEANUP_TIMER target:self selector:@selector(clearDispastchedMessages) userInfo:nil repeats:YES];
        
       
    }
    return self;
}

-(void)addMessageToBus:(Message*)newmessage
{
    if(newmessage.mesType == MESSAGETYPE_GENERAL_SUCCESS){
        NSLog(@"General success result");
        return;
    }
    if(newmessage.ttl == DEFAULT_TTL){
        [messageBus addObject:newmessage];
        if(dispsatchTimer == nil){
            [self startDispatching];
        }
    }
    else{
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:newmessage forKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
        NSTimer * scheduled = [NSTimer scheduledTimerWithTimeInterval:newmessage.ttl target:self selector:@selector(dispatchThisMessage:) userInfo:userInfo repeats:NO];
            });
    }
}


-(void)clearDispastchedMessages
{
    for (Message *msg in dispatchedMessages) {
        [messageBus removeObject:msg];
    }
    [dispatchedMessages removeAllObjects];
}

-(void)dispatchThisMessage:(NSTimer*)timer
{
    Message* message = [timer.userInfo objectForKey:@"message"];
    if(message){
        [self dispatchMessage:message];
    }
}

-(void)startDispatching
{
    dispsatchTimer = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_TTL target:self selector:@selector(leave) userInfo:nil repeats:YES];
}

-(void)stopDispathing
{
    if(dispsatchTimer){
        [dispsatchTimer invalidate];
        dispsatchTimer = nil;
    }
}

-(void)leave
{
    for(Message *msg in messageBus){
        [self dispatchMessage:msg];
    }
}


-(NSString*)messageTypeToString:(messageType)Type
{
    NSString *retMessage = @"";
    switch (Type) {
        case MESSAGETYPE_SIGNIN_RESPONSE:
            retMessage = @"MESSAGETYPE_SIGNIN_RESPONSE";
            break;
        case MESSAGETYPE_FETCH_PERSONS:
            retMessage = @"MESSAGETYPE_FETCH_PERSONS";
            break;
        case MESSAGETYPE_FETCH_PERSON_RESPONSE:
            retMessage = @"MESSAGETYPE_FETCH_PERSON_RESPONSE";
            break;
        case MESSAGETYPE_HIDE_MENU_BUTTON:
            retMessage = @"MESSAGETYPE_HIDE_MENU_BUTTON";
            break;
        case MESSAGETYPE_SHOW_MENU_BUTTON:
            retMessage = @"MESSAGETYPE_SHOW_MENU_BUTTON";
            break;
        case MESSAGETYPE_CHANGE_MENU_BUTTON:
            retMessage = @"MESSAGETYPE_CHANGE_MENU_BUTTON";
            break;
        case MESSAGETYPE_SHOW_SHARING_MENU:
            retMessage = @"MESSAGETYPE_SHOW_SHARING_MENU";
            break;
        case MESSAGETYPE_SHARE_THIS_APP:
            retMessage = @"MESSAGETYPE_SHARE_THIS_APP";
            break;
        case MESSAGETYPE_SHOW_FILTER_OPTIONS:
            retMessage = @"MESSAGETYPE_SHOW_FILTER_OPTIONS";
            break;
        case MESSAGETYPE_SHOW_SORTING_OPTIONS:
            retMessage = @"MESSAGETYPE_SHOW_SORTING_OPTIONS";
            break;
        case MESSAGETYPE_CONTACT_DEVELOPER:
            retMessage = @"MESSAGETYPE_CONTACT_DEVELOPER";
            break;
        case MESSAGETYPE_HIDE_MENU:
            retMessage = @"MESSAGETYPE_HIDE_MENU";
            break;
        case MESSAGETYPE_SORT_BY_MISSINGDATE:
            retMessage = @"MESSAGETYPE_SORT_BY_MISSINGDATE";
            break;
        case MESSAGETYPE_SORT_BY_AGE:
            retMessage = @"MESSAGETYPE_SORT_BY_AGE";
            break;
        case MESSAGETYPE_SORT_BY_SEX:
            retMessage = @"MESSAGETYPE_SORT_BY_SEX";
            break;
        case MESSAGETYPE_HIDE_FILTER_OPTIONS:
            retMessage = @"MESSAGETYPE_HIDE_FILTER_OPTIONS";
            break;
        case MESSAGETYPE_SHOW_LIST_VIEW:
            retMessage = @"MESSAGETYPE_SHOW_LIST_VIEW";
            break;
        case MESSAGETYPE_APPLY_FILTER:
            retMessage = @"MESSAGETYPE_APPLY_FILTER";
            break;
        case MESSAGETYPE_CLEAR_FILTER:
            retMessage = @"MESSAGETYPE_CLEAR_FILTER";
            break;
        case MESSAGETYPE_CALL_REGIONAL_AUTHORITIES:
            retMessage = @"MESSAGETYPE_CALL_REGIONAL_AUTHORITIES";
            break;
        case MESSAGETYPE_HIDE_CALLINGCARD:
            retMessage = @"MESSAGETYPE_HIDE_CALLINGCARD";
            break;
        case MESSAGETYPE_FETCH_GETREGIONALCONTACTS_RESPONSE:
            retMessage = @"MESSAGETYPE_FETCH_GETREGIONALCONTACTS_RESPONSE";
            break;
        case MESSAGETYPE_UPDATE_LOCATION:
            retMessage = @"MESSAGETYPE_UPDATE_LOCATION";
            break;
        case MESSAGETYPE_UPLOADIMAGE:
            retMessage = @"MESSAGETYPE_UPLOADIMAGE";
            break;
        case MESSAGETYPE_SENDMESSAGE:
            retMessage = @"MESSAGETYPE_SENDMESSAGE";
            break;
        case MESSAGETYPE_SENDMESSAGE_RESPONSE:
            retMessage = @"MESSAGETYPE_SENDMESSAGE_RESPONSE";
            break;
        case MESSAGETYPE_GET_ALL_MESSAGESFORCASE:
            retMessage = @"MESSAGETYPE_GET_ALL_MESSAGESFORCASE";
            break;
        case MESSAGETYPE_GET_ALL_MESSAGESFORCASE_RESPONSE:
            retMessage = @"MESSAGETYPE_GET_ALL_MESSAGESFORCASE_RESPONSE";
            break;
        case MESSAGETYPE_DOWNLOAD_ASSET:
            retMessage = @"MESSAGETYPE_DOWNLOAD_ASSET";
            break;
        case MESSAGETYPE_GOTOTIMELINE:
            retMessage = @"MESSAGETYPE_GOTOTIMELINE";
            break;
        default:
            break;
    }
    
    return retMessage;
}

-(void)dispatchMessage:(Message*)message
{
    switch (message.mesRoute) {
        case MESSAGEROUTE_API:
            if([self canSendMessage:message]){
               [self routeMessageToServerWithType:message];
            }
            [dispatchedMessages addObject:message];
            break;
        case MESSAGEROUTE_INTERNAL:
        {
            NSMutableDictionary * messageDic = [[NSMutableDictionary alloc] init];
            [messageDic setObject:message forKey:@"message"];
            [[NSNotificationCenter defaultCenter] postNotificationName:[self messageTypeToString:message.mesType] object:nil userInfo:messageDic];
            [dispatchedMessages addObject:message];
        }
            break;
        case MESSAGEROUTE_OTHER:
            break;
        default:
            break;
    }
}


-(void)routeMessageToServerWithType:(Message*)message
{
    if(message.params == nil){
        message.params = [[NSMutableDictionary alloc] init];
    }
    NSString * sectoken = [[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"];
    
    if(sectoken && sectoken.length > 0){
        [message.params setObject:sectoken forKey:@"securitytoken"];
    }
    
    switch (message.mesType) {
        case MESSAGETYPE_SIGNIN:
            [[CommManager sharedInstance] postAPI:@"NewUser" andParams:message.params];
            break;
        case MESSAGETYPE_FETCH_PERSONS:
            [[CommManager sharedInstance] getAPI:@"fetchpersons" andParams:message.params];
            break;
        case MESSAGETYPE_FETCH_GETREGIONALCONTACTS:
            [[CommManager sharedInstance] getAPI:@"GetRegionalContacts" andParams:message.params];
            break;
        case MESSAGETYPE_UPDATE_LOCATION:
            [[CommManager sharedInstance] postAPI:@"updatelocation" andParams:message.params];
            break;
        case MESSAGETYPE_UPLOADIMAGE:
        {
            NSString * strUrl = [self saveImage:[message.params objectForKey:@"image"]];
            NSURL * url = [NSURL fileURLWithPath:strUrl];
            NSString * imageName = [strUrl lastPathComponent];
            [[CommManager sharedInstance] uploadImage:url andAssetName:imageName andAssetSize:[message.params objectForKey:@"size"] withDelegate:self];
        }
            break;
        case MESSAGETYPE_SENDMESSAGE:
            [[CommManager sharedInstance] postAPI:@"sendmessage" andParams:message.params];
            break;
        case MESSAGETYPE_GET_ALL_MESSAGESFORCASE:
            [[CommManager sharedInstance] getAPI:@"getmessages" andParams:message.params];
            break;
        default:
            break;
    }
}


-(void)downloadedAssetFinishedWithResult:(NSError*)error savedUrl:(NSURL*)url assetName:(NSString*)name
{
    
    UIImage * image = [UIImage imageWithContentsOfFile:url.absoluteString];
    NSMutableArray *arrayOfCurrentDownloads = [[CommManager sharedInstance].imagesDownloadQueue objectForKey:name];
    for(void (^Queued_fetchImageWithBlock)(UIImage*) in arrayOfCurrentDownloads){
        Queued_fetchImageWithBlock(image);
    }
    [[CommManager sharedInstance].imagesDownloadQueue removeObjectForKey:name];
}


- (void)fetchAssetForImageID:(NSString*)imageID withBlock:(void (^)(UIImage* userimage))callbackBlock
{
    NSString * localpath = [self generatelocalpathforImageID:imageID];
    UIImage * image = [UIImage imageWithContentsOfFile:localpath];
    if(image){
        callbackBlock(image);
        return;
    }
    NSMutableArray *arrayOfCurrentDownloads = [[CommManager sharedInstance].imagesDownloadQueue objectForKey:imageID];
    if(arrayOfCurrentDownloads == nil){
        arrayOfCurrentDownloads = [[NSMutableArray alloc] init];
    }
    else{
        NSLog(@"Download image %@",imageID);
        [arrayOfCurrentDownloads addObject:callbackBlock];
        [[CommManager sharedInstance].imagesDownloadQueue setObject:arrayOfCurrentDownloads forKey:imageID];
        return;
    }
    
    [arrayOfCurrentDownloads addObject:callbackBlock];
    [[CommManager sharedInstance].imagesDownloadQueue setObject:arrayOfCurrentDownloads forKey:imageID];
    
    NSURL * savingURL = [NSURL fileURLWithPath:localpath];
    [[CommManager sharedInstance] downloadAssetFromS3WithName:imageID andSavingUrl:savingURL withDelegate:self];
}


-(NSString*)generatelocalpathforImageID:(NSString*)imageID
{
    if(imageID == nil){
        imageID = [NSString stringWithFormat:@"%f.jpg",[[NSDate date] timeIntervalSince1970]];
    }
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentURL = [paths objectAtIndex:0];
    documentURL = [documentURL URLByAppendingPathComponent:@"missingkids_images" isDirectory:YES];
    BOOL bExists = NO;
    BOOL isFolder;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[documentURL path] isDirectory:&isFolder])
    {
        NSError *error = nil;
        bExists = [[NSFileManager defaultManager] createDirectoryAtURL:documentURL withIntermediateDirectories:YES attributes:nil error:&error];
    }
    else{
        bExists = YES;
    }
    NSString * url = [NSString stringWithFormat:@"%@/%@",documentURL.path,imageID];
    return url;
}



-(NSString *)saveImage:(UIImage*)image{
    NSString * localpath  = [self generatelocalpathforImageID:nil];
    BOOL bFileWritten = [UIImageJPEGRepresentation(image, 0.0) writeToFile:localpath atomically:YES];
    return localpath;
}


-(void)uploadAsset:(UIImage *)asset withBlock:(void (^)(NSString*imageID))callbackBlock
{
    uploadFinishedBlock = callbackBlock;
    NSString * strUrl = [self saveImage:asset];
    NSURL * url = [NSURL fileURLWithPath:strUrl];
    NSString * imageName = [strUrl lastPathComponent];
    NSData *imgData = UIImageJPEGRepresentation(asset, 0);
    [[CommManager sharedInstance] uploadImage:url andAssetName:imageName andAssetSize:[NSNumber numberWithInteger:imgData.length] withDelegate:self];
}

-(void)uploadAssetFinishedWithResult:(NSError*)error forAssetName:(NSString*)name
{
    NSLog(@"uploadAssetFinishedWithResult %@",error);
    if(uploadFinishedBlock){
        uploadFinishedBlock(name);
        uploadFinishedBlock = nil;
    }
    for(void (^Queued_fetchImageWithBlock)(NSString*) in queueCallbacks){
        Queued_fetchImageWithBlock(name);
    }
    [queueCallbacks removeAllObjects];
}



-(BOOL)canSendMessage:(Message*)message
{
    switch (message.mesType) {
        case MESSAGETYPE_SIGNIN:
        {
            if(((NSString*)([message.params objectForKey:@"apnskey"])).length <= 10){
                return NO;
            }
            
            
        }
        break;
        case MESSAGETYPE_FETCH_PERSONS:
        case MESSAGETYPE_FETCH_GETREGIONALCONTACTS:
        case MESSAGETYPE_UPDATE_LOCATION:
        case MESSAGETYPE_SENDMESSAGE:
        case MESSAGETYPE_UPLOADIMAGE:
        case MESSAGETYPE_GET_ALL_MESSAGESFORCASE:
            return YES;
        default:
            break;
    }
    
    return YES;
}


@end
