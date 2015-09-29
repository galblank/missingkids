//
//  CountryTableViewController.m
//  missingkids
//
//  Created by Gal Blank on 9/28/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "ItemsTableViewController.h"
#import "DBManager.h"
@interface ItemsTableViewController ()

@end

@implementation ItemsTableViewController

@synthesize lsitDelegate,iType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *selection = @"missingCountry";
    switch (self.iType) {
        case ITEM_TYPE_COUNTRY:
            selection = @"missingCountry";
            break;
        case ITEM_TYPE_STATE:
            selection = @"missingState";
            break;
        case ITEM_TYPE_CITY:
            selection = @"missingCity";
            break;
        default:
            break;
    }
    
    
    NSString * query = [NSString stringWithFormat:@"select distinct %@ from person order by %@",selection,selection];
    NSMutableArray * data = [[DBManager sharedInstance] loadDataFromDB:query];
    
    listofItems = [[NSMutableArray alloc] init];
    for(NSMutableArray * item in data){
        [listofItems addObject:item[0]];
    }
    
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
    return listofItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"coiuntryCell"];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"coiuntryCell"];
    }
    
    NSString *item = [listofItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([lsitDelegate respondsToSelector:@selector(didselectItem:forItemType:)]){
        [lsitDelegate didselectItem:[listofItems objectAtIndex:indexPath.row] forItemType:iType];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
