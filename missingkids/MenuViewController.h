//
//  MenuViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/24/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    MENUTYPE_MAIN = 1,
    MENUTYPE_SORT,
    MENUTYPE_FILTER
}MENU_TYPES;

@interface MenuViewController : UITableViewController

@property(nonatomic)MENU_TYPES currentMenuType;

@end
