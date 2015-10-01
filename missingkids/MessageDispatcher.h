//
//  MessageDispatcher.h
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import <UIKit/UIKit.h>
@interface MessageDispatcher : NSObject
{
    NSTimer *dispsatchTimer;
    NSMutableArray * messageBus;
    
    NSMutableArray * dispatchedMessages;
    
    void (^uploadFinishedBlock)(NSString*imageID);
    NSMutableArray *queueCallbacks;
}
+ (MessageDispatcher*) sharedInstance;


-(void)addMessageToBus:(Message*)newmessage;
-(void)startDispatching;
-(void)stopDispathing;
-(NSString*)messageTypeToString:(messageType)Type;
- (void)fetchAssetForImageID:(NSString*)imageID withBlock:(void (^)(UIImage* userimage))callbackBlock;
-(void)uploadAsset:(UIImage *)asset withBlock:(void (^)(NSString*imageID))callbackBlock;
@end
