//
//  Utils.h
//  re:group'd
//
//  Created by Gal Blank on 2/5/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>

#define DIFF_WEEK       (86400*7)   //seconds
#define DIFF_2DAYS      (86400*2)   //seconds
#define DIFF_DAY         86400      //seconds
#define DIFF_5MIN        300
#define DIFF_2MIN        120
#define DIFF_1MIN        60

#define BUBBLE_TOP_INSET 8.0
#define BUBBLE_BOTTOM_INSET 8.0
#define IOS70_ADDED_INSET 6.0
#define BUBBLE_RIGHT_INSET 20.0

#define SUPPORT_FILE @"aB290377Ba"


@interface Utils : NSObject
{
    NSString * _s3Image;
    NSString *localFullPath;
    UIView *viewForImage;
    void (^imagedDownloadedCallback)(UIImage*);
    UIViewController *mailViewController;
    UIWindow *arrowWindow;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    UIView *cameraWindowView;
    NSMutableArray *thumbnailsArray;
    BOOL bMonitoringForCameraRollChanges;
    BOOL isCameraRollUpdateInProgress;
}
@property(nonatomic,retain)NSMutableArray *thumbnailsArray;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
+ (Utils *)sharedInstance;
-(CGSize)bubbleSizeForTextLabelSize:(CGSize)labelsize;
-(CGSize)expectedHeightForMessageLabelInChatStreamForWidth:(CGFloat)width :(NSString*)text;
-(NSString*)buildAddressFromLocation:(CLPlacemark*)location;
-(NSString*)userFriendlyTimeStamp:(double)secondsSince1970;
-(NSString*)sha1:(NSString*)input;
-(NSString *)md5:(NSString *)input;
- (void)fetchMessageImageForView:(UIView*)imageForView withLocalPath:(NSString*)localPath withS3ID:(NSString*)s3ID andaCallback:(void (^)(UIImage*returnImage))callbackBlock;
-(void)sendLogEmail:(UIViewController*)controller;
- (UIImage*)previewFromFileAtPath:(NSString*)path ratio:(CGFloat)ratio;
- (UIImage *)imageWithMask:(UIImage *)maskImage originalImage:(UIImage*)image;
- (BOOL)compareimages:(UIImage *)image1 isEqualTo:(UIImage *)image2;
-(NSString*) sha256:(NSString*)input;
- (NSData *)compressData:(NSData*)data;
- (NSData *)uncompressData:(NSData*)data;
-(AVCaptureSession*)currentCaptureSession;
-(AVCaptureVideoPreviewLayer *)currentCaptureVideoPreviewLayerWithFrame:(CGRect)frame;
- (void)buildCameraWindowViewAndTurnOnCameraWithView:(UIView*)view withBlock:(void (^)(UIView* cameraView))callbackBlock;
-(void)stopCurrentSession;
-(void)loadCameraRollIntoMemory;
-(void)removeVideoLayerFromSuperLayer;
- (void)refetchCameraRoll:(NSNotification *)note;
- (void)checkAndDisplayRequestForMicPermission;
-(uint64_t)getFreeDiskspace;
- (NSString *)platformString;
@end
