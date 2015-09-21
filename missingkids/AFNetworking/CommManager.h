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





@protocol CommunicationManagerDelegate <NSObject>
@optional
-(void)getApiFinished:(NSMutableDictionary*)response;
@end


@interface CommManager : NSObject 
{
    id<CommunicationManagerDelegate> __unsafe_unretained CommDelegate;
}

+ (CommManager *)sharedInstance;
@property (nonatomic, unsafe_unretained) id<CommunicationManagerDelegate> CommDelegate;

-(void)postAPI:(NSString*)api andParams:(NSMutableDictionary*)params;
-(void)getAPI:(NSString*)api andParams:(NSMutableDictionary*)params;

@end
