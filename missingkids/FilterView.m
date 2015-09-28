//
//  FilterView.m
//  missingkids
//
//  Created by Gal Blank on 9/28/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "FilterView.h"
#import "MessageDispatcher.h"
#import "Message.h"

@implementation FilterView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        //self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.2;
        
        UIButton * btnApply = [UIButton buttonWithType:UIButtonTypeCustom];
        btnApply.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width / 2, 30);
        [btnApply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnApply setTitle:NSLocalizedString(@"Filter", nil) forState:UIControlStateNormal];
        btnApply.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btnApply.layer.borderWidth = 0.5;
        [self addSubview:btnApply];
        
        UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height - 30, self.frame.size.width / 2, 30);
        [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnCancel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btnCancel.layer.borderWidth = 0.5;
        [self addSubview:btnCancel];
    }
    
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
