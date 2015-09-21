//
//  Utils.m
//  re:group'd
//
//  Created by Gal Blank on 2/5/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import "Utils.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "GCrypto.h"
@implementation Utils


static Utils *sharedSampleSingletonDelegate = nil;

@synthesize captureVideoPreviewLayer,thumbnailsArray;

+ (Utils *)sharedInstance {
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
        bMonitoringForCameraRollChanges = NO;
        isCameraRollUpdateInProgress = NO;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////
-(CGSize)expectedHeightForMessageLabelInChatStreamForWidth:(CGFloat)width :(NSString*)text
{
    CGSize maximumLabelSize = CGSizeMake(width, CGFLOAT_MAX);
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    
    
    
    // NOTE: Increasing the size to +1 of what is set in the app global setting here on
    // purpose to report a little larger font to give some extra padding in our height
    // to fix issues with the text in larger cells getting cut off.
    //gettingSizeLabel.font = CHAT_MESSAGE_FONT;  // <--- This is size 17.0
    gettingSizeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    
    
    gettingSizeLabel.text = text;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    
    
    // For debugging:
    //NSLog(@"[Utils] -expectedHeightForMessageLabelInChatStreamForWidth-");
    //NSLog(@"width: %0.1f text: %@", width, text);
    //NSLog(@"expectSize: %@", NSStringFromCGSize(expectSize));
    
    
    return(expectSize);
}

/*
 NOTE: This is another alertnative for determining the size...
 -(CGSize)expectedHeightForMessageLabelInChatStreamForWidth:(CGFloat)width :(NSString*)text
 {
 CGSize expectSize = CGSizeZero;
 
 if(text)
 {
 CGSize constraintSize = CGSizeMake(width, CGFLOAT_MAX);
 NSString *theString = text;
 UIFont *drawingFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
 NSDictionary *attributes = @{NSFontAttributeName : drawingFont };
 CGRect boundingRect = [theString boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
 
 expectSize = CGSizeMake(boundingRect.size.width, boundingRect.size.height + 0);
 }
 
 
 // For debugging:
 NSLog(@" ");
 NSLog(@"[Utils] -expectedHeightForMessageLabelInChatStreamForWidth-");
 NSLog(@"width: %0.1f text: %@", width, text);
 NSLog(@"expectSize: %@", NSStringFromCGSize(expectSize));
 
 
 return(expectSize);
 }
 */


-(CGSize)bubbleSizeForTextLabelSize:(CGSize)labelsize{
    CGSize newsize = labelsize;
    newsize.width = labelsize.width + BUBBLE_RIGHT_INSET;
    newsize.height = labelsize.height + BUBBLE_TOP_INSET + BUBBLE_BOTTOM_INSET;
    return newsize;
}

-(NSInteger)secondsSinceMidnightForDate:(NSDate*)date
{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSIntegerMax fromDate:date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSDateComponents *diff = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:midnight toDate:date options:0];
    
    NSInteger numberOfSecondsPastMidnight = [diff second];
    
    return numberOfSecondsPastMidnight;
}

-(NSString*)userFriendlyTimeStamp:(double)secondsSince1970
{
    NSString *friendlyTimestampString = nil;
    
    NSDate *createddate = [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
    
    double diffTime = [[NSDate date] timeIntervalSince1970] - secondsSince1970;
    
    NSInteger secondsSinceMidnightToday = [self secondsSinceMidnightForDate:[NSDate date]];
    NSInteger secondsSinceMidnightYesterday = [self secondsSinceMidnightForDate:[[NSDate date] dateByAddingTimeInterval:-DIFF_DAY]];
    secondsSinceMidnightYesterday+=DIFF_DAY;
    
    NSDate *TODAYmidnight     = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsSinceMidnightToday];
    NSDate *YESTERDAYmidnight = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsSinceMidnightYesterday];
    
    if(secondsSince1970 > [YESTERDAYmidnight timeIntervalSince1970] && secondsSince1970 < [TODAYmidnight timeIntervalSince1970])
    {
        friendlyTimestampString = NSLocalizedString(@"Yesterday", nil);
    }
    else if(secondsSince1970 > [TODAYmidnight timeIntervalSince1970])
    {
        if(diffTime <= DIFF_1MIN)
        {
            friendlyTimestampString = NSLocalizedString(@"Just now", nil);
        }
        else if(diffTime <= DIFF_2MIN)
        {
            friendlyTimestampString = NSLocalizedString(@"2 minutes ago", nil);
        }
        else if(diffTime < DIFF_DAY)
        {
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:[NSLocale currentLocale]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:formatString];
            
            friendlyTimestampString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:createddate]];
        }
        else
        {
            NSLog(@"{WARNING} Should not get here.");
        }
    }
    else
    {
        if(diffTime < DIFF_WEEK)
        {
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EEEE" options:0 locale:[NSLocale currentLocale]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:formatString];
            
            friendlyTimestampString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:createddate]];
        }
        else
        {
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/yy" options:0 locale:[NSLocale currentLocale]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:formatString];
            
            friendlyTimestampString = [dateFormatter stringFromDate:createddate];
        }
    }
    
    // Safety code.
    if(friendlyTimestampString == nil)
    {
        friendlyTimestampString = @"Time";
        NSLog(@"{WARNING} friendlyTimestampString is nil, check for missing if");
    }
    
    
    //NSLog(@"[Utils] -userFriendlyTimeStamp- %0.6f friendlyTimestampString: %@", secondsSince1970, friendlyTimestampString);
    
    return(friendlyTimestampString);
    
}

-(NSString*)buildAddressFromLocation:(CLPlacemark*)location
{
    NSLog(@"[Globals] -buildAddressFromLocation-");
    
    NSArray *areasOfInterestList = [location areasOfInterest];
    
    NSString *zipCode     = [location postalCode];
    NSString *country     = [location country];
    NSString *state       = [location administrativeArea];
    NSString *city        = [location locality];
    NSString *streetNum   = [location subThoroughfare];
    NSString *streetName  = [location thoroughfare];
    
    NSString *subLocality = [location subLocality];
    NSString *county      = [location subAdministrativeArea];
    NSString *isoCountry  = [location ISOcountryCode];
    NSString *ocean       = [location ocean];
    NSString *inlandWater = [location inlandWater];
    
    if((areasOfInterestList) && (areasOfInterestList.count > 0))
    {
        NSLog(@"CLPlacemark areasOfInterestList: %@", [areasOfInterestList objectAtIndex:0]);
    }
    NSLog(@"CLPlacemark ocean:       %@", ocean);
    NSLog(@"CLPlacemark inlandWater: %@", inlandWater);
    NSLog(@"CLPlacemark country:     %@", country);
    NSLog(@"CLPlacemark state:       %@", state);
    NSLog(@"CLPlacemark city:        %@", city);
    NSLog(@"CLPlacemark streetNum:   %@", streetNum);
    NSLog(@"CLPlacemark streetName:  %@", streetName);
    NSLog(@"CLPlacemark subLocality: %@", subLocality);
    NSLog(@"CLPlacemark county:      %@", county);
    NSLog(@"CLPlacemark isoCountry:  %@", isoCountry);
    NSLog(@"CLPlacemark zipCode:     %@", zipCode);
    
    
    NSString *address = @"";
    
    if((areasOfInterestList) && (areasOfInterestList.count > 0))
    {
        address = [address stringByAppendingString:[areasOfInterestList objectAtIndex:0]];
        address = [address stringByAppendingString:@", "];
    }
    
    
    if(streetNum != nil && streetNum.length > 0)
    {
        address = [address stringByAppendingString:streetNum];
        address = [address stringByAppendingString:@" "];
        
        if(streetName != nil && streetName.length > 0)
        {
            address = [address stringByAppendingString:streetName];
            address = [address stringByAppendingString:@", "];
        }
    }
    else
    {
        if(streetName != nil && streetName.length > 0)
        {
            address = [address stringByAppendingString:streetName];
            address = [address stringByAppendingString:@", "];
        }
    }
    
    
    
    if(city != nil && city.length > 0)
    {
        if(isoCountry)
        {
            // For non-US addresses, include the 'subLocality' to get the full address.
            if([isoCountry isEqualToString:@"US"] == NO && subLocality)
            {
                address = [address stringByAppendingString:subLocality];
                address = [address stringByAppendingString:@", "];
            }
        }
        
        address = [address stringByAppendingString:city];
        address = [address stringByAppendingString:@", "];
    }
    
    if(isoCountry)
    {
        // For non-US addresses, include the 'county' to get the full address.
        if([isoCountry isEqualToString:@"US"] == NO)
        {
            if(county)
            {
                address = [address stringByAppendingString:county];
                address = [address stringByAppendingString:@", "];
            }
        }
    }
    
    if(state != nil && state.length > 0)
    {
        address = [address stringByAppendingString:state];
        address = [address stringByAppendingString:@", "];
    }
    if(country != nil && country.length > 0)
    {
        if([isoCountry isEqualToString:@"US"] == NO)
        {
            address = [address stringByAppendingString:country];
            address = [address stringByAppendingString:@", "];
        }
    }
    if(country != nil  && [country isEqualToString:@"Kyrgyzstan"])
    {
        return @"";
    }
    if(zipCode != nil && zipCode.length > 0)
    {
        address = [address stringByAppendingString:zipCode];
    }
    
    NSLog(@"Address string: %@", address);
    
    return address;
}

-(NSString*) sha256:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
    
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

//MD5 -
- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (UIImage*)previewFromFileAtPath:(NSString*)path ratio:(CGFloat)ratio
{
    AVAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CGFloat durationInSeconds = duration.value / duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(durationInSeconds * ratio, (int)duration.value);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return thumbnail;
}


- (UIImage *)imageWithMask:(UIImage *)maskImage originalImage:(UIImage*)image
{
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask(image.CGImage, mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);  
    CGImageRelease(maskedImageRef);  
    
    return maskedImage;  
}

- (BOOL)compareimages:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}


#pragma mark - Microphone Permissions

- (void)checkAndDisplayRequestForMicPermission
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL response)
    {
        NSLog(@"Allow microphone use response: %d", response);
    }];
}


#pragma mark -

-(void)removeVideoLayerFromSuperLayer
{
    if(captureVideoPreviewLayer){
        [captureVideoPreviewLayer removeFromSuperlayer];
    }
}
-(void)stopCurrentSession
{
    if(captureSession && [captureSession isRunning]){
        [captureSession stopRunning];
    }
}

-(AVCaptureSession*)currentCaptureSession
{
    if(captureSession){
        if([captureSession isRunning] == NO){
            [captureSession startRunning];
        }
        return captureSession;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {

                               AVCaptureDevicePosition desiredPosition;
                               
                               BOOL shouldUseRearFacingCamera = YES;
                               
                               if (shouldUseRearFacingCamera == YES)
                               {
                                   desiredPosition = AVCaptureDevicePositionBack;
                               }
                               else
                               {
                                   desiredPosition = AVCaptureDevicePositionFront;
                               }
                               
                               
                               
                               NSArray *captureInputDeviceList = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
                               
                               if((captureInputDeviceList) && (captureInputDeviceList.count > 0))
                               {
                                   for(AVCaptureDevice *inputDevice in captureInputDeviceList)
                                   {
                                       AVCaptureDevicePosition cameraPosition = [inputDevice position];
                                       
                                       if(cameraPosition == desiredPosition)
                                       {
                                           NSError *error = nil;
                                           AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
                                           
                                           if(captureInput)
                                           {
                                               AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
                                               [captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
                                               
                                               
                                               NSString *key   = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                                               NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
                                               NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
                                               [captureOutput setVideoSettings:videoSettings];
                                               
                                               if(captureSession == nil)
                                               {
                                                   captureSession = [[AVCaptureSession alloc] init];
                                               }
                                               
                                               NSString *preset = 0;
                                               
                                               if (!preset)
                                               {
                                                   // I'm selecting a lower quality because we are just using this view for show
                                                   // in a small view. This will help performace while allowing for the cool effect.
                                                   preset = AVCaptureSessionPreset352x288;
                                               }
                                               
                                               captureSession.sessionPreset = preset;
                                               
                                               if ([captureSession canAddInput:captureInput])
                                               {
                                                   [captureSession addInput:captureInput];
                                               }
                                               
                                               if ([captureSession canAddOutput:captureOutput])
                                               {
                                                   [captureSession addOutput:captureOutput];
                                               }
                                               [captureSession startRunning];
                                               break;
                                           }
                                           else
                                           {
                                               NSLog(@"{WARNING} AVCaptureDeviceInput is nil, Error: %@",error.description);
                                               NSString *displayString = NSLocalizedString(@"Camera access is disabled, please enable it for Begroupd in your device settings.", nil);
                                               NSString *version = [[UIDevice currentDevice] systemVersion];
                                               UIAlertView * alert = nil;
                                               if([version floatValue] < 8.0){
                                                   alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Permissions issue", nil) message:displayString delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
                                               }
                                               else{
                                                   alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Permissions issue", nil) message:displayString delegate:self cancelButtonTitle:NSLocalizedString(@"Settings", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil),nil];
                                               }
                                               alert.tag = 998;
                                               [alert show];
                                           }
                                       }
                                       else
                                       {
                                           NSLog(@"{WARNING} cameraPosition != desiredPosition");
                                       }
                                   }
                               }
                               else
                               {
                                   if(captureInputDeviceList.count == 0)
                                   {
                                       NSLog(@"{WARNING} captureInputDeviceList.count is 0");
                                   }
                                   else
                                   {
                                       NSLog(@"{WARNING} captureInputDeviceList is nil");
                                   }
                               }
                           }
                           else
                           {
                               NSLog(@"{WARNING} cameraWindowView is nil!");
                           }

    return captureSession;
  
}


- (void)buildCameraWindowViewAndTurnOnCameraWithView:(UIView*)view withBlock:(void (^)(UIView* cameraView))callbackBlock
{
    if(cameraWindowView){
        if(captureSession){
            if([captureSession isRunning] == NO){
                [captureSession startRunning];
            }
        }
        callbackBlock(cameraWindowView);
    }
    
    NSLog(@"-buildCameraWindowViewAndTurnOnCamera-");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        CGFloat width = view.frame.size.width - 10.0;
        CGFloat itemwidth = (width / 3) - 2.0;
        
        CGSize cameraWindowSize = CGSizeMake(itemwidth, itemwidth);
        CGSize cameraIconSize   = CGSizeMake(28.0, 22.0);
        
        cameraWindowView = [[UIView alloc] init];
        cameraWindowView.frame = CGRectMake(0.0, 0.0, cameraWindowSize.width, cameraWindowSize.height);
        
        AVCaptureDevicePosition desiredPosition;
        
        BOOL shouldUseRearFacingCamera = YES;
        
        if (shouldUseRearFacingCamera == YES)
        {
            desiredPosition = AVCaptureDevicePositionBack;
        }
        else
        {
            desiredPosition = AVCaptureDevicePositionFront;
        }
        
        [cameraWindowView.layer addSublayer:[self currentCaptureVideoPreviewLayerWithFrame:CGRectMake(0.0, 0.0, cameraWindowSize.width, cameraWindowSize.height)]];
        
        // Finally, add our camera icon on top.
        UIImageView *cameraIconImageView = [[UIImageView alloc] init];
        CGFloat iconWidth  = cameraIconSize.width;
        CGFloat iconHeight = cameraIconSize.height;
        cameraIconImageView.frame = CGRectMake((cameraWindowSize.width-iconWidth)/2,
                                               (cameraWindowSize.height-iconHeight)/2,
                                               iconWidth,
                                               iconHeight);
        cameraIconImageView.image = [UIImage imageNamed:@"button_camera.png"];
        [cameraWindowView addSubview:cameraIconImageView];
        callbackBlock(cameraWindowView);
    }
    callbackBlock(nil);
}

-(AVCaptureVideoPreviewLayer *)currentCaptureVideoPreviewLayerWithFrame:(CGRect)frame{
    if (captureVideoPreviewLayer == nil)
    {
        captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[self currentCaptureSession]];
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    captureVideoPreviewLayer.frame = frame;
    return captureVideoPreviewLayer;
}


- (void)refetchCameraRoll:(NSNotification *)note
{
    NSDictionary* info = [note userInfo];
    NSLog(@"refetchCameraRoll assetsLibraryDidChange calling loadCameraRollIntoMemory, userInfo %@", info);
    
    //   If the user information dictionary is nil, reload all assets and asset groups.
        //   If the user information dictionary an empty dictionary, there is no need to reload assets and asset groups.
    if(!note.userInfo || note.userInfo.count == 0) {
        NSLog(@"refetchCameraRoll: skipping this notification");
        return;
    }


    // Only refetch if there isn't one in progress.
    if(isCameraRollUpdateInProgress == NO)
    {
        if((self.thumbnailsArray) && (self.thumbnailsArray.count > 0))
        {
            [self.thumbnailsArray removeAllObjects];
        }
        
        self.thumbnailsArray = nil;
        [self loadCameraRollIntoMemory];
    }
    else
    {
        NSLog(@"{WARNING} Skipping refetchCameraRoll because there is a fetch in progress...");
    }
}




-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}


- (NSString *) platform{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}


- (NSString *)platformString
{
    NSString *strplatform = [self platform];
    
    if ([strplatform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([strplatform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([strplatform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([strplatform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([strplatform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([strplatform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([strplatform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([strplatform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([strplatform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([strplatform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([strplatform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([strplatform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([strplatform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([strplatform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([strplatform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s Plus";
    if ([strplatform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s";
    if ([strplatform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([strplatform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([strplatform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([strplatform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([strplatform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([strplatform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([strplatform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([strplatform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([strplatform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([strplatform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([strplatform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([strplatform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([strplatform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([strplatform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([strplatform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([strplatform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([strplatform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([strplatform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([strplatform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([strplatform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([strplatform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([strplatform isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([strplatform isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([strplatform isEqualToString:@"i386"])         return @"Simulator";
    if ([strplatform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return strplatform;
}

@end
