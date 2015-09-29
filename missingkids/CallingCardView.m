//
//  CallingCardView.m
//  missingkids
//
//  Created by Gal Blank on 9/29/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "CallingCardView.h"
#import "Message.h"
#import "MessageDispatcher.h"
#import "AppDelegate.h"
#import "DBManager.h"

@implementation CallingCardView

@synthesize infoDoc;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        //self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.2;
        self.alpha = 0.8;
        
        
        header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
        header.backgroundColor = [UIColor clearColor];
        header.textColor = [UIColor whiteColor];
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        header.text = NSLocalizedString(@"Contact Authorities", nil);
        [self addSubview:header];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(10,header.frame.origin.y + header.frame.size.height + 5, self.frame.size.width - 20, 150)];
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        [self addSubview:label];
        
        UIButton * btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCall.frame = CGRectMake(10, self.frame.size.height - 50, self.frame.size.width / 2 - 20, 30);
        [btnCall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnCall  setBackgroundColor:[UIColor whiteColor]];
        [btnCall setTitle:NSLocalizedString(@"CALL", nil) forState:UIControlStateNormal];
        btnCall.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [btnCall addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];
        btnCall.layer.borderWidth = 0.5;
        [self addSubview:btnCall];
        
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


-(void)cancel
{
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSAGETYPE_HIDE_CALLINGCARD;
    msg.ttl = TTL_NOW;
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}

-(void)call
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
    [self cancel];
}

-(void)updateUI
{
    NSString * state = [infoDoc objectAtIndex:MISSING_STATE];
    NSString * query = [NSString stringWithFormat:@"select * from regionalcontacts where isostate = '%@'",state];
    NSMutableArray * array = [[DBManager sharedInstance] loadDataFromDB:query];
    if(array){
        phone = [@"tel://" stringByAppendingString:[[array objectAtIndex:0] objectAtIndex:4]];
    }
    label.text = [[array objectAtIndex:0] objectAtIndex:3];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
