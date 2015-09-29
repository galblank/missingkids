//
//  CountryTableViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/28/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum{
    ITEM_TYPE_COUNTRY = 0,
    ITEM_TYPE_STATE,
    ITEM_TYPE_CITY
}ITEMTYPE;

@protocol ListVCDelegate <NSObject>
@optional
-(void)didselectItem:(NSString*)item forItemType:(ITEMTYPE)type;
@end

@interface ItemsTableViewController : UITableViewController
{
    NSMutableArray *listofItems;
    id<ListVCDelegate> __unsafe_unretained lsitDelegate;
}

@property (nonatomic, unsafe_unretained) id<ListVCDelegate> lsitDelegate;
@property (nonatomic)ITEMTYPE iType;

@end
