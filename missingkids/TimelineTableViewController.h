//
//  TimelineTableViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/30/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineTableViewController : UITableViewController
{
    NSMutableArray * tableData;
    void (^uploadFinishedBlock)(void);
    NSMutableArray *queueCallbacks;
    UITextView * textView;
    BOOL isKeyboardUp;
}
@end
