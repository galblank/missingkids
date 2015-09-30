//
//  ViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAShareBubbles.h"
#import "FilterView.h"
#import "ItemsTableViewController.h"
#import "definitions.h"


@interface MainViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AAShareBubblesDelegate,ListVCDelegate>
{
    UICollectionView    *maincollectionView;
    NSMutableArray      *collectionData;
    BOOL bScrolling;
    UIScrollView *scrollView;
    
    FilterView * filterWindow;
    
    SORTING_OPTIONS currentSortingMissingDateOption;
    SORTING_OPTIONS currentSortingAgeOption;
    SORTING_OPTIONS currentSortingSexOption;
}


//delegate
-(void)didselectItem:(NSString*)item forItemType:(ITEMTYPE)type;

@end

