//
//  PersonViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/24/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIScrollView *scrollView;
}

@property(nonatomic,strong)NSMutableArray *person;
@end
