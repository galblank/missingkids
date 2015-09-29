//
//  CollectionViewCell.m
//  missingkids
//
//  Created by Gal Blank on 9/23/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

@synthesize label,imageview;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        imageview = [[UIImageView alloc] initWithFrame:self.frame];
        self.backgroundView = imageview;
        //[self addSubview:self.imageview];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        //self.layer.cornerRadius = 10.0;
        self.label = [[InsetUILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
        self.autoresizesSubviews = YES;
        self.label.backgroundColor = [UIColor blackColor];
        self.label.alpha = 0.7;
        self.label.numberOfLines = 0;
        self.label.layer.masksToBounds = YES;
        //self.label.layer.cornerRadius = 10.0;
        self.label.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight);
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.label];
    }
    return self;
}


@end
