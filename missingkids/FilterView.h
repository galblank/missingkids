//
//  FilterView.h
//  missingkids
//
//  Created by Gal Blank on 9/28/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterView : UIView
{
    UIButton * countryButton;
    UIButton * stateButton;
    UIButton * cityButton;
}

@property(nonatomic,strong)UIButton * countryButton;
@property(nonatomic,strong)UIButton * stateButton;
@property(nonatomic,strong)UIButton * cityButton;
@end
