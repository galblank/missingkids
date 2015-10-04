//
//  CommMamanger.m
//  TheLine
//
//  Created by Gal Blank on 5/21/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import "CommManager.h"
#import "StringHelper.h"
#import "AppDelegate.h"
#import "MessageDispatcher.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSSQS/AWSSQS.h>
#import <AWSSNS/AWSSNS.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSS3/AWSS3TransferUtility.h>*
@implementation CommManager


static CommManager *sharedSampleSingletonDelegate = nil;

@synthesize imagesDownloadQueue;


+ (CommManager *)sharedInstance {
    @synchronized(self) {
        if (sharedSampleSingletonDelegate == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedSampleSingletonDelegate;
}



+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedSampleSingletonDelegate == nil) {
            sharedSampleSingletonDelegate = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedSampleSingletonDelegate;
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
       self.imagesDownloadQueue = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)getAPI:(NSString*)api andParams:(NSMutableDictionary*)params{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSString *fullAPI = [NSString stringWithFormat:@"%@%@",ROOT_API,api];
    NSLog(@"GET: %@<>%@",fullAPI,params);
    [manager GET:fullAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        Message *msg = [[Message alloc] init];
        msg.mesRoute = MESSAGEROUTE_INTERNAL;
        msg.mesType = [[responseObject objectForKey:@"messageid"] intValue];
        msg.params = [responseObject objectForKey:@"data"];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)postAPI:(NSString*)api andParams:(NSMutableDictionary*)params{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSString *fullAPI = [NSString stringWithFormat:@"%@%@",ROOT_API,api];
    NSLog(@"POST: %@:%@",fullAPI,params);
    [manager POST:fullAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        Message *msg = [[Message alloc] init];
        msg.mesRoute = MESSAGEROUTE_INTERNAL;
        msg.mesType = [[responseObject objectForKey:@"messageid"] intValue];
        msg.params = [responseObject objectForKey:@"data"];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)uploadImage:(NSURL *)imageUrl andAssetName:(NSString*)assetName andAssetSize:(NSNumber*)assetSize withDelegate:(id)theDelegate
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = S3_IMAGES_BUCKET;
    
    uploadRequest.key = assetName;
    uploadRequest.body = imageUrl;
    uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:assetSize.doubleValue];
    uploadRequest.contentType = @"image/jpeg";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:assetName forKeyedSubscript:@"assetName"];
    [params setObject:uploadRequest.bucket forKeyedSubscript:@"bucket"];
    NSLog(@"uploading Image to S3");
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        // Do something with the response
        if(task.error == nil) {
            AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
            NSLog(@"Uploaded file with result: %@",task.result);
        }
        else{
            NSLog(@"Upload file error %@",task.error.description);
        }
        if(theDelegate && [theDelegate respondsToSelector:@selector(uploadAssetFinishedWithResult:forAssetName:)]){
            [theDelegate uploadAssetFinishedWithResult:task.error forAssetName:assetName];
        }
        return nil;
    }];
}

-(void)downloadAssetFromS3WithName:(NSString*)name andSavingUrl:(NSURL*)savingUrl withDelegate:(id)theDelegate
{
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = S3_IMAGES_BUCKET;
    downloadRequest.key = name;
    downloadRequest.downloadingFileURL = savingUrl;
    
    //Download the file
    [[transferManager download:downloadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        NSLog(@"Download paused or cancelled");
                        if(theDelegate && [theDelegate respondsToSelector:@selector(downloadedAssetFinishedWithResult:savedUrl:assetName:)])
                        {
                            [theDelegate downloadedAssetFinishedWithResult:task.error savedUrl:savingUrl assetName:name];
                        }
                        break;
                        
                    default:
                        NSLog(@"Error: %@", task.error);
                        if(theDelegate && [theDelegate respondsToSelector:@selector(downloadedAssetFinishedWithResult:savedUrl:assetName:)])
                        {
                            [theDelegate downloadedAssetFinishedWithResult:task.error savedUrl:savingUrl assetName:name];
                        }
                        break;
                }
            }else{
                //Unknown Error
                NSLog(@"Error: %@", task.error);
                if(theDelegate && [theDelegate respondsToSelector:@selector(downloadedAssetFinishedWithResult:savedUrl:assetName:)])
                {
                    [theDelegate downloadedAssetFinishedWithResult:task.error savedUrl:savingUrl assetName:name];
                }
                NSLog(@"Error: %@", task.error);
            }
        }
        if (task.result) {
            AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
            NSLog(@"Downloaded file from S3: %@ Len: %ld",downloadOutput.body,downloadOutput.contentLength.longValue);
            if(theDelegate && [theDelegate respondsToSelector:@selector(downloadedAssetFinishedWithResult:savedUrl:assetName:)])
            {
                [theDelegate downloadedAssetFinishedWithResult:task.error savedUrl:savingUrl assetName:name];
            }
        }
        
        return nil;
    }];
    
}

@end
