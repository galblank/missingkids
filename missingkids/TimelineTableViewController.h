//
//  TimelineTableViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/30/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineTableViewController : UITableViewController<UIActionSheetDelegate>
{
    NSMutableArray * tableData;
    UITextView * textView;
    BOOL isKeyboardUp;
    UIView * bgView;
}

@property(nonatomic,strong)NSMutableArray * person;

@end
