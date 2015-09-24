//
//  InsetUILabel.m
//  re:group'd
//
//  Created by Gal Blank on 1/14/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import "InsetUILabel.h"

@implementation InsetUILabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0,5, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end
