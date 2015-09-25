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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    }
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
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Message * msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.ttl = TTL_NOW;
    if(indexPath.row == 0){
        msg.mesType = MESSAGETYPE_SHOW_FILTER_OPTIONS;
    }
    else if(indexPath.row == 1){
        msg.mesType = MESSAGETYPE_SHOW_SORTING_OPTIONS;
    }
    else if(indexPath.row == 2){
        msg.mesType = MESSAGETYPE_SHARE_THIS_APP;
    }
    else if(indexPath.row == 3){
        msg.mesType = MESSAGETYPE_CONTACT_DEVELOPER;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_MENU] object:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:msg.mesType] object:nil];
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
