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
#import "ItemsTableViewController.h"

@implementation FilterView

@synthesize countryButton,stateButton,cityButton;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        //self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.2;
        self.alpha = 0.9;
        countryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        countryButton.frame = CGRectMake(10, 30, self.frame.size.width - 20, 30);
        [countryButton setBackgroundColor:[UIColor whiteColor]];
        [countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [countryButton setTitle:NSLocalizedString(@"Country", nil) forState:UIControlStateNormal];
        countryButton.tag = ITEM_TYPE_COUNTRY;
        countryButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [countryButton addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
        countryButton.layer.borderWidth = 0.5;
        [self addSubview:countryButton];
        
        stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        stateButton.frame = CGRectMake(10, countryButton.frame.origin.y  + countryButton.frame.size.height + 5, self.frame.size.width - 20, 30);
        stateButton.tag = ITEM_TYPE_STATE;
        [stateButton setBackgroundColor:[UIColor whiteColor]];
        [stateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [stateButton setTitle:NSLocalizedString(@"State", nil) forState:UIControlStateNormal];
        stateButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [stateButton addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
        stateButton.layer.borderWidth = 0.5;
        [self addSubview:stateButton];
        
        cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cityButton.frame = CGRectMake(10, stateButton.frame.origin.y  + stateButton.frame.size.height + 5, self.frame.size.width - 20, 30);
        cityButton.tag = ITEM_TYPE_CITY;
        [cityButton setBackgroundColor:[UIColor whiteColor]];
        [cityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cityButton setTitle:NSLocalizedString(@"City", nil) forState:UIControlStateNormal];
        cityButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [cityButton addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
        cityButton.layer.borderWidth = 0.5;
        [self addSubview:cityButton];
        
        
        UIButton *clearfilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearfilterButton.frame = CGRectMake(10, self.frame.size.height - 50 - 40, self.frame.size.width - 20, 30);
        clearfilterButton.tag = ITEM_TYPE_CITY;
        [clearfilterButton setBackgroundColor:[UIColor whiteColor]];
        [clearfilterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [clearfilterButton setTitle:NSLocalizedString(@"Clear Filter", nil) forState:UIControlStateNormal];
        clearfilterButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [clearfilterButton addTarget:self action:@selector(clearFilter) forControlEvents:UIControlEventTouchUpInside];
        clearfilterButton.layer.borderWidth = 0.5;
        [self addSubview:clearfilterButton];
        
        UIButton * btnApply = [UIButton buttonWithType:UIButtonTypeCustom];
        btnApply.frame = CGRectMake(10, self.frame.size.height - 50, self.frame.size.width / 2 - 20, 30);
        [btnApply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnApply  setBackgroundColor:[UIColor whiteColor]];
        [btnApply setTitle:NSLocalizedString(@"Filter", nil) forState:UIControlStateNormal];
        btnApply.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [btnApply addTarget:self action:@selector(apply) forControlEvents:UIControlEventTouchUpInside];
        btnApply.layer.borderWidth = 0.5;
        [self addSubview:btnApply];
        
        UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCancel setBackgroundColor:[UIColor whiteColor]];
        btnCancel.frame = CGRectMake(self.frame.size.width / 2 + 10, self.frame.size.height - 50, self.frame.size.width / 2 - 20, 30);
        [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnCancel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btnCancel.layer.borderWidth = 0.5;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCancel];
    }
    
    return self;
}

-(void)clearFilter
{
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSageTYPE_CLEAR_FILTER;
    msg.ttl = TTL_NOW;
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}

-(void)selectItem:(UIButton*)button
{
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSAGETYPE_SHOW_LIST_VIEW;
    msg.ttl = TTL_NOW;
    msg.params = [[NSMutableDictionary alloc] init];
    [msg.params setObject:[NSNumber numberWithInteger:button.tag] forKey:@"itemtype"];
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}

-(void)cancel
{
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSAGETYPE_HIDE_FILTER_OPTIONS;
    msg.ttl = TTL_NOW;
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}

-(void)apply
{
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSAGETYPE_APPLY_FILTER;
    msg.ttl = TTL_NOW;
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
