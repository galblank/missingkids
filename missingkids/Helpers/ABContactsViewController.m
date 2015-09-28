//
//  ABContactsViewController.m
//  re:group'd
//
//  Created by Gal Blank on 1/29/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import "ABContactsViewController.h"
#import "AFAddressBookManager.h"
#import "AFContact.h"
#import "AppDelegate.h"
#import "RegexKitLite.h"
#import "RoundImageTableViewCell.h"


@interface ABContactsViewController ()

@end

@implementation ABContactsViewController

@synthesize abcontactsDel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Select Contacts", nil);
    selectedContacts = [[NSMutableArray alloc] init];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSendTouched:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    isSearching = NO;
    tempContacts = [[NSMutableArray alloc] initWithArray:[AFAddressBookManager allContactsFromAddressBook]];
    
    sections = [[NSMutableDictionary alloc] init];
    
    for(AFContact *contact in tempContacts)
    {
        NSString *firstLetterOfLastName = @"";
        if(contact.contactLastName && contact.contactLastName.length > 0){
            firstLetterOfLastName = [contact.contactLastName substringWithRange:NSMakeRange(0, 1)];
        }
        else if(contact.contactFirstName && contact.contactFirstName.length > 0){
            firstLetterOfLastName = [contact.contactFirstName substringWithRange:NSMakeRange(0, 1)];
        }
        else{
            firstLetterOfLastName = @"Z";
        }
        
        NSMutableArray * usersforsection = [sections objectForKey:firstLetterOfLastName];
        if(usersforsection == nil){
            usersforsection = [[NSMutableArray alloc] init];
        }
        [usersforsection addObject:contact];
        [sections setObject:usersforsection forKey:firstLetterOfLastName];
    }
    
    
    CGRect myFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height,self.view.bounds.size.width, 44.0f);
    searchBar = [[UISearchBar alloc] initWithFrame:myFrame];
    //set the delegate to self so we can listen for events
    searchBar.delegate = self;
    //display the cancel button next to the search bar
    searchBar.showsCancelButton = NO;
    //searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.layer.borderWidth = 0;
    [searchBar setBackgroundImage:[[UIImage alloc]init]];
    searchBar.translucent = YES;
    searchBar.opaque = YES;
    //add the search bar to the view
    [self.view addSubview:searchBar];
    
    CGFloat posY = searchBar.frame.origin.y + searchBar.frame.size.height;
    
    
    
    NSArray *keys = [sections allKeys];
    sortedKeys = [[NSMutableArray alloc] initWithArray:[keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    contactsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,posY, self.view.frame.size.width, self.view.frame.size.height - posY) style:UITableViewStylePlain];
    contactsTableView.showsVerticalScrollIndicator = YES;
    contactsTableView.userInteractionEnabled = YES;
    contactsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    contactsTableView.separatorColor = [UIColor lightGrayColor];
    contactsTableView.bounces = YES;
    contactsTableView.backgroundColor =[UIColor whiteColor];
    contactsTableView.delegate = self;
    contactsTableView.dataSource = self;
    contactsTableView.sectionIndexColor = [UIColor lightGrayColor];
    [self.view addSubview:contactsTableView];
}


//user tapped on the cancel button
- (void)searchBarCancelButtonClicked:(UISearchBar *) _searchBar {
    isSearching = NO;
    NSLog(@"User canceled search");
    [searchResults removeAllObjects];
    [searchedSortedKey removeAllObjects];
    [searchedSectionsResults removeAllObjects];
    [selectedContacts removeAllObjects];
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    [contactsTableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)_searchBar {
    isSearching = YES;
    _searchBar.showsCancelButton = YES;
    [contactsTableView reloadData];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)_searchBar {
    _searchBar.showsCancelButton = NO;
    [contactsTableView reloadData];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
}


#pragma mark - Button Handlers


-(void)Cancel
{
    if(abcontactsDel && [abcontactsDel respondsToSelector:@selector(CancelSmsSending)]){
        [abcontactsDel CancelSmsSending];
    }
}

-(void)handleSendTouched:(id)sender
{
    NSLog(@"handleSendTouched");
    
    // Send invite to selected users
    if(abcontactsDel && [abcontactsDel respondsToSelector:@selector(finishSendingSms:)])
    {
        if((selectedContacts) && (selectedContacts.count > 0))
        {
            NSArray *listOfSelectedContacts = [NSArray arrayWithArray:selectedContacts];
            [abcontactsDel finishSendingSms:listOfSelectedContacts];
        }
        else
        {
            if(abcontactsDel && [abcontactsDel respondsToSelector:@selector(CancelSmsSending)])
            {
                [abcontactsDel CancelSmsSending];
            }
            else
            {
                NSLog(@"{WARNING} ABContactsViewController respondsToSelector Cancel failed!");
            }
        }
    }
    else
    {
        NSLog(@"{WARNING} ABContactsViewController respondsToSelector failed!");
    }
}





#pragma mark - UITableView


-(CGFloat)tableView:(UITableView *)tableView  heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We need some padding around the image in each cell, so put 5 above and 5 below.
    return ROUNDIMAGE_MEDIUMHEIGHT_CELL + 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isSearching && [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
        return searchedSortedKey.count;
    }
    return sortedKeys.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(isSearching && [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
        NSString *oneKey = [searchedSortedKey objectAtIndex:section];
        NSMutableArray *users = [searchedSectionsResults objectForKey:oneKey];
        count = users.count;
    }
    else{
        NSString *oneKey = [sortedKeys objectAtIndex:section];
        NSMutableArray *users = [sections objectForKey:oneKey];
        count = users.count;
    }
    
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = THEME_GRAY_BG_COLOR;
    
    NSString *oneKey = @"";
    
    
    if(isSearching && [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        if((searchedSortedKey) && (section < searchedSortedKey.count))
        {
            oneKey = [searchedSortedKey objectAtIndex:section];
        }
    }
    else
    {
        if((sortedKeys) && (section < sortedKeys.count))
        {
            oneKey = [sortedKeys objectAtIndex:section];
        }
    }

    
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 20);
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.frame.size.width - 20, 20)];
    headerLabel.textColor = [UIColor lightGrayColor];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = oneKey;
    [headerView addSubview:headerLabel];
    
    return headerView;
}



-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *tablefooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.01)];
    tablefooterView.backgroundColor = [UIColor whiteColor];
    return tablefooterView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    
    RoundImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UIImageView *selectButton = nil;
    if (cell == nil) {
        cell = [[RoundImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier withRowHeight:ROUNDIMAGE_MEDIUMHEIGHT_CELL];
    }
    
    
    selectButton = (UIImageView*)(cell.accessoryView);
    if(selectButton == nil){
        selectButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        selectButton.tag = 0;
        cell.accessoryView = selectButton;
    }

    selectButton.image = [UIImage imageNamed:@"radio_off"];
    
    
    NSMutableArray *users  = nil;
    
    if(isSearching && [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        if((searchedSortedKey) && (indexPath.section < searchedSortedKey.count))
        {
            NSString *oneKey = [searchedSortedKey objectAtIndex:indexPath.section];
            
            if(oneKey){
                users = [searchedSectionsResults objectForKey:oneKey];
            }
        }
    }
    else
    {
        if((sortedKeys) && (indexPath.section < sortedKeys.count))
        {
            NSString *oneKey = [sortedKeys objectAtIndex:indexPath.section];
            
            if(oneKey){
                users = [sections objectForKey:oneKey];
            }
        }
    }
    
    
    
    AFContact *contact = nil;
    
    if((users) && (indexPath.row < users.count))
    {
        contact = [users objectAtIndex:indexPath.row];
        
        if(contact)
        {
            if((selectedContacts) && (selectedContacts.count > 0))
            {
                NSInteger n = [selectedContacts indexOfObject:contact];
                
                if(n != NSNotFound){
                    selectButton.image = [UIImage imageNamed:@"check"];
                }
                else{
                    selectButton.image = [UIImage imageNamed:@"radio_off"];
                }
            }
            [cell setAvatar:contact.photo userLabel:[contact initials] withAvatarHeight:ROUNDIMAGE_MEDIUMHEIGHT_CELL shouldCenterlabel:YES];
            cell.cellTextString = contact.name;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(isSearching && [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        NSString *oneKey = [searchedSortedKey objectAtIndex:indexPath.section];
        NSMutableArray *usersInSection = [searchedSectionsResults objectForKey:oneKey];
        
        AFContact *contact = [usersInSection objectAtIndex:indexPath.row];
        
        if(contact)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIImageView *accessory = (UIImageView*)cell.accessoryView;
            if(accessory.tag == 0){
                accessory.tag = 1;
                accessory.image = [UIImage imageNamed:@"check"];
                [selectedContacts addObject:contact];
            }
            else{
                accessory.tag = 0;
                accessory.image = [UIImage imageNamed:@"radio_off"];
                [selectedContacts removeObject:contact];
            }

           
            self.navigationItem.rightBarButtonItem.enabled = (selectedContacts.count > 0);
        }
        else
        {
            NSLog(@"{WARNING} contact is nil, item not added to list.");
        }
        
        
        [searchBar resignFirstResponder];
        
    }
    else{
        NSString *oneKey = [sortedKeys objectAtIndex:indexPath.section];
        NSMutableArray *usersInSection = [sections objectForKey:oneKey];
        AFContact *contact = [usersInSection objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *accessory = (UIImageView*)cell.accessoryView;
        if(accessory.tag == 0){
            accessory.tag = 1;
            accessory.image = [UIImage imageNamed:@"check"];
            [selectedContacts addObject:contact];
        }
        else{
            accessory.tag = 0;
            accessory.image = [UIImage imageNamed:@"radio_off"];
            [selectedContacts removeObject:contact];
        }
        self.navigationItem.rightBarButtonItem.enabled = (selectedContacts.count > 0);
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(isSearching && [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
        return searchedSortedKey;
    }
    return sortedKeys;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchResults removeAllObjects];// remove all data that belongs to previous search
    [searchedSectionsResults removeAllObjects];
    [searchedSortedKey removeAllObjects];
    
    if([searchText isEqualToString:@""] || searchText==nil){
        [contactsTableView reloadData];
        return;
    }
    
    
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(AFContact* evaluatedObject, NSDictionary *bindings) {
        NSString *regEx = [NSString stringWithFormat:@"%@(.*?)",[searchText lowercaseString]];
        NSRange rangeOfRegEx = NSMakeRange(0, searchText.length);
        if((evaluatedObject.contactFirstName.length >= searchText.length && [[evaluatedObject.contactFirstName lowercaseString] isMatchedByRegex:regEx inRange:rangeOfRegEx]) || (evaluatedObject.contactLastName.length >= searchText.length && [[evaluatedObject.contactLastName lowercaseString] isMatchedByRegex:regEx inRange:rangeOfRegEx]))
        {
            return true;
        }
        return false;
    }];
    
    
    searchResults = [[NSMutableArray alloc] initWithArray:[tempContacts filteredArrayUsingPredicate:pred]];
    searchedSectionsResults = [[NSMutableDictionary alloc] init];
    
    for(AFContact *contact in searchResults){
        NSString *firstLetterOfLastName = @"";
        if(contact.contactLastName && contact.contactLastName.length > 0){
            firstLetterOfLastName = [contact.contactLastName substringWithRange:NSMakeRange(0, 1)];
        }
        else if(contact.contactFirstName && contact.contactFirstName.length > 0){
            firstLetterOfLastName = [contact.contactFirstName substringWithRange:NSMakeRange(0, 1)];
        }
        else{
            firstLetterOfLastName = @"Z";
        }
        
        NSMutableArray * usersforsection = [searchedSectionsResults objectForKey:firstLetterOfLastName];
        if(usersforsection == nil){
            usersforsection = [[NSMutableArray alloc] init];
        }
        [usersforsection addObject:contact];
        [searchedSectionsResults setObject:usersforsection forKey:firstLetterOfLastName];
    }
    
    NSArray *keys = [searchedSectionsResults allKeys];
    searchedSortedKey = [[NSMutableArray alloc] initWithArray:[keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    [contactsTableView reloadData];
    
}

@end
