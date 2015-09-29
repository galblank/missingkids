//
//  CallingCardView.h
//  missingkids
//
//  Created by Gal Blank on 9/29/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallingCardView : UIView
{
    UIActivityIndicatorView * aiView;
    UILabel * header;
    UILabel * label;
    NSString * phone;
}

-(void)updateUI;
@property(nonatomic,strong)NSMutableArray * infoDoc;
@end
