//
//  ImageResizer.h
//  re:group'd
//
//  Created by Gal Blank on 12/12/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@protocol ImageResizerDelegate <NSObject>
@optional
-(void)resizedImage:(UIImage*)image;
@end


@interface ImageResizer : NSObject
{
    id<ImageResizerDelegate> __unsafe_unretained imageResDel;
}

@property (nonatomic, unsafe_unretained) id<ImageResizerDelegate> imageResDel;
- (void)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size;
- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;
-(UIImage*)scaleImageKeepRatio: (UIImage*)sourceImage scaledToWidth: (float) i_width;
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;
-(UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
- (UIImage *)centerCropImage:(UIImage *)image;
- (UIImage *)imageScaledToSize:(CGSize)size andImage:(UIImage*)originalImage;
@end
