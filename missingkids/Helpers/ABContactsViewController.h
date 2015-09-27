//
//  ABContactsViewController.h
//  re:group'd
//
//  Created by Gal Blank on 1/29/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ABContactsDelegate <NSObject>
@optional
-(void)CancelSmsSending;
-(void)finishSendingSms:(NSArray*)theList;
@end


@interface ABContactsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    UITableView *contactsTableView;
    NSMutableDictionary *sections;
    NSMutableArray *sortedKeys;
    NSMutableArray *selectedContacts;
    id<ABContactsDelegate> __unsafe_unretained abcontactsDel;
    NSMutableArray *tempContacts;

    ///SEARCH
    NSMutableDictionary *searchedSectionsResults;
    NSMutableArray *searchedSortedKey;
    UISearchBar *searchBar;
    BOOL isSearching;
    NSMutableArray *searchResults;
}

@property (nonatomic,unsafe_unretained) id<ABContactsDelegate> abcontactsDel;


@end
