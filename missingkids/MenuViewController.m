//
//  MenuViewController.m
//  missingkids
//
//  Created by Gal Blank on 9/24/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "MenuViewController.h"
#import "Message.h"
#import "MessageDispatcher.h"


@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize currentMenuType;

- (void)viewDidLoad {
    [super viewDidLoad];
    currentMenuType = MENUTYPE_MAIN;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.view.alpha = 0.9;
    self.view.backgroundColor = [UIColor clearColor];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.alpha = 0.9;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (self.currentMenuType) {
        case MENUTYPE_SORT:
            return 25;
            break;
        case MENUTYPE_FILTER:
            return 25;
        case MENUTYPE_MAIN:
            return 0.0;
        default:
            break;
    }
}


- (UIView * _Nullable)tableView:(UITableView * _Nonnull)tableView
         viewForHeaderInSection:(NSInteger)section
{
    UILabel *view = nil;
    switch (self.currentMenuType) {
        case MENUTYPE_SORT:
            view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
            view.text = NSLocalizedString(@"Sort By", nil);
            view.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            view.backgroundColor = [UIColor lightGrayColor];
            view.textAlignment = NSTextAlignmentCenter;
            break;
        case MENUTYPE_FILTER:
            view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
            view.text = NSLocalizedString(@"Filter By", nil);
            view.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            view.backgroundColor = [UIColor lightGrayColor];
            view.textAlignment = NSTextAlignmentCenter;
        default:
            break;
    }
   
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (currentMenuType) {
        case MENUTYPE_MAIN:
            return 4;
        case MENUTYPE_FILTER:
            return 10;
        case MENUTYPE_SORT:
            return 4;
        default:
            break;
    }
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    switch (currentMenuType) {
        case MENUTYPE_MAIN:
        {
            if(indexPath.row == 0){
                cell.textLabel.text = NSLocalizedString(@"Filter", nil);
            }
            else if(indexPath.row == 1){
                cell.textLabel.text = NSLocalizedString(@"Sort", nil);
            }
            else if(indexPath.row == 2){
                cell.textLabel.text = NSLocalizedString(@"Share", nil);
            }
            else if(indexPath.row == 3){
                cell.textLabel.text = NSLocalizedString(@"Contact", nil);
            }
        }
            break;
        case MENUTYPE_FILTER:
        {
            if(indexPath.row == 0){
                cell.textLabel.text = NSLocalizedString(@"Filter", nil);
            }
            else if(indexPath.row == 1){
                cell.textLabel.text = NSLocalizedString(@"Sort", nil);
            }
            else if(indexPath.row == 2){
                cell.textLabel.text = NSLocalizedString(@"Share", nil);
            }
            else if(indexPath.row == 3){
                cell.textLabel.text = NSLocalizedString(@"Contact", nil);
            }
        }
            break;
        case MENUTYPE_SORT:
        {
            if(indexPath.row == 0){
                cell.textLabel.text = NSLocalizedString(@"Missing Date", nil);
            }
            else if(indexPath.row == 1){
                cell.textLabel.text = NSLocalizedString(@"Sex", nil);
            }
            else if(indexPath.row == 2){
                cell.textLabel.text = NSLocalizedString(@"Age", nil);
            }
            else if(indexPath.row == 3){
                cell.textLabel.text = NSLocalizedString(@"Cancel", nil);
            }
        }
            break;
        default:
            break;
    }
    
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (currentMenuType) {
        case MENUTYPE_MAIN:
            return 50.0;
        case MENUTYPE_FILTER:
            return 40.0;
        case MENUTYPE_SORT:
            return 40.0;
        default:
            break;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Message * msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.ttl = TTL_NOW;
    
    switch (self.currentMenuType) {
        case MENUTYPE_MAIN:
        {
            if(indexPath.row == 0){
                msg.mesType = MESSAGETYPE_SHOW_FILTER_OPTIONS;
            }
            else if(indexPath.row == 1){
                msg.mesType = MESSAGETYPE_SHOW_SORTING_OPTIONS;
                self.currentMenuType = MENUTYPE_SORT;
                [tableView reloadData];
                return;
            }
            else if(indexPath.row == 2){
                msg.mesType = MESSAGETYPE_SHARE_THIS_APP;
            }
            else if(indexPath.row == 3){
                msg.mesType = MESSAGETYPE_CONTACT_DEVELOPER;
            }
            
        }
            break;
            
        case MENUTYPE_FILTER:
        {
            if(indexPath.row == 0){
                msg.mesType = MESSAGETYPE_SHOW_FILTER_OPTIONS;
                self.currentMenuType = MENUTYPE_FILTER;
                [tableView reloadData];
                return;
            }
            else if(indexPath.row == 1){
                msg.mesType = MESSAGETYPE_SHOW_SORTING_OPTIONS;
                self.currentMenuType = MENUTYPE_SORT;
                [tableView reloadData];
                return;
            }
            else if(indexPath.row == 2){
                msg.mesType = MESSAGETYPE_SHARE_THIS_APP;
            }
            else if(indexPath.row == 3){
                msg.mesType = MESSAGETYPE_CONTACT_DEVELOPER;
            }
        }
            break;
        case MENUTYPE_SORT:
        {
            if(indexPath.row == 0){
                msg.mesType = MESSAGETYPE_SORT_BY_MISSINGDATE;
            }
            else if(indexPath.row == 1){
                msg.mesType = MESSAGETYPE_SORT_BY_AGE;
            }
            else if(indexPath.row == 2){
                msg.mesType = MESSAGETYPE_SORT_BY_SEX;
            }
        }
            break;
        default:
            break;
    }
   
    self.currentMenuType = MENUTYPE_MAIN;
    [tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_MENU] object:nil];
    
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
