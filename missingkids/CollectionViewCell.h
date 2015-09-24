//
//  CollectionViewCell.h
//  missingkids
//
//  Created by Gal Blank on 9/23/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetUILabel.h"
@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) InsetUILabel *label;
@property (nonatomic, strong) UIImageView *imageview;
@end
