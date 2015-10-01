//
//  CommMamanger.h
//  TheLine
//
//  Created by Gal Blank on 5/21/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import "AFNetworking.h"

#define  KEY_COMM_DELEGATE              @"kKEY_COMM_DELEGATE"
#define  KEY_API_NAME                   @"KEY_API_NAME"
#define  KEY_RESULT_STRING              @"KEY_RESULT_STRING"
#define  KEY_RESULT_FAILURE_ERROR       @"KEY_RESULT_FAILURE_ERROR"

#define S3_IMAGES_BUCKET                @"missingkids"



@protocol CommunicationManagerDelegate <NSObject>
@optional
-(void)getApiFinished:(NSMutableDictionary*)response;
-(void)uploadAssetFinishedWithResult:(NSError*)error forAssetName:(NSString*)name;
-(void)downloadedAssetFinishedWithResult:(NSError*)error savedUrl:(NSURL*)url assetName:(NSString*)name;
@end



@interface CommManager : NSObject 
{
    id<CommunicationManagerDelegate> __unsafe_unretained CommDelegate;
}

+ (CommManager *)sharedInstance;
@property (nonatomic, unsafe_unretained) id<CommunicationManagerDelegate> CommDelegate;

-(void)postAPI:(NSString*)api andParams:(NSMutableDictionary*)params;
-(void)getAPI:(NSString*)api andParams:(NSMutableDictionary*)params;
-(void)uploadImage:(NSURL *)imageUrl andAssetName:(NSString*)assetName andAssetSize:(NSNumber*)assetSize withDelegate:(id)theDelegate;
-(void)downloadAssetFromS3WithName:(NSString*)name andSavingUrl:(NSURL*)savingUrl withDelegate:(id)theDelegate;

@property(nonatomic,retain)NSMutableDictionary *imagesDownloadQueue;
@end
