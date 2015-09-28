//
//  ViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAShareBubbles.h"

typedef enum{
    SORTING_MISSING_DATE_DESC = 1,
    SORTING_MISSING_DATE_ASC,
    SORTING_AGE_DESC,
    SORTING_AGE_ASC,
    SORTING_SEX_DESC,
    SORTING_SEX_ASC
}SORTING_OPTIONS;

@interface MainViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AAShareBubblesDelegate>
{
    UICollectionView    *maincollectionView;
    NSMutableArray      *collectionData;
    BOOL bScrolling;
    UIScrollView *scrollView;
    
    SORTING_OPTIONS currentSortingMissingDateOption;
    SORTING_OPTIONS currentSortingAgeOption;
    SORTING_OPTIONS currentSortingSexOption;
}

@end

