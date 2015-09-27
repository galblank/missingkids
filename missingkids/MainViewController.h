//
//  ViewController.h
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAShareBubbles.h"

@interface MainViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AAShareBubblesDelegate>
{
    UICollectionView    *maincollectionView;
    NSMutableArray      *collectionData;
    BOOL bScrolling;
    UIScrollView *scrollView;
}

@end

