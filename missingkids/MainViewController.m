//
//  ViewController.m
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "MainViewController.h"
#import "MessageDispatcher.h"
#import "CollectionViewCell.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(2, 0, self.view.frame.size
                                                                      .width - 4, self.view.frame.size.height) collectionViewLayout:layout];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    
    [collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:collectionView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    Message * msg = [[Message alloc] init];
    msg.mesType = MESSAGETYPE_FETCH_PERSONS;
    msg.mesRoute = MESSAGEROUTE_API;
    msg.ttl = TTL_NOW;
    /*NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
     [params setObject:apnsToken forKey:@"apnskey"];
     [params setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
     [params setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
     msg.params = params;*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotpersons:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_FETCH_PERSON_RESPONSE] object:nil];
    [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    
    NSMutableArray * results = [[DBManager sharedInstance] loadDataFromDB:@"select * from person order by missingDate desc"];
    if(results){
        collectionData = results;
        [collectionView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)gotpersons:(NSNotification*)notify
{
    Message * msg = [notify.userInfo objectForKey:@"message"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFoundNew = NO;
        for(NSMutableDictionary * person in msg.params){
            NSString *caseNumber = [person objectForKey:@"caseNumber"];
            NSMutableArray * arr = [[DBManager sharedInstance] loadDataFromDB:[NSString stringWithFormat:@"select * from person where caseNumber = '%@'",caseNumber]];
            if(arr && arr.count > 0){
                //NSLog(@"person exist");
            }
            else{
                bFoundNew = YES;
            }
        }
        
        if(bFoundNew){
            collectionData = msg.params;
            [collectionView reloadData];
        }
    });
    
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return collectionData.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.view.frame.size.width - 15) / 2, self.view.frame.size.height / 3);
}


- (CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.imageview.image = nil;
    cell.label.text = @"";
    if(bScrolling){
        return cell;
    }
    NSMutableArray * person = [collectionData objectAtIndex:indexPath.row];
    if([person objectAtIndex:IMAGE]){
        NSString *imagename = [person objectAtIndex:IMAGE];
        if(imagename.length > 2){
            imagename = [imagename substringToIndex:2];
        }
        NSString * buildFullPath = [NSString stringWithFormat:@"%@/%@%@%@.jpg",ROOT_IMAGES,[person objectAtIndex:ORG_PREFIX],[person objectAtIndex:CASE_NUMBER],imagename];
        NSURL *url = [NSURL URLWithString:buildFullPath];
        [cell.imageview setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile"]];
        [cell sendSubviewToBack:cell.imageview];
    }
    
    NSNumber * missingDate = [person objectAtIndex:MISSING_DATE];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:(missingDate.doubleValue / 1000)];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM dd yyyy";
    NSString * strDate = [df stringFromDate:date];
    NSString * labeltext = [NSString stringWithFormat:@"%@ %@\r\n%@\r\n%@ %@",[person objectAtIndex:FIRST_NAME],[person objectAtIndex:LAST_NAME],strDate,[person objectAtIndex:MISSING_CITY],[person objectAtIndex:MISSING_COUNTRY]];
    cell.label.text = labeltext;
    
    return cell;
}



- (void)scrollViewWillBeginDecelerating:(UIScrollView * _Nonnull)scrollView
{
    bScrolling = YES;
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType  = MESSAGETYPE_HIDE_MENU_BUTTON;
    msg.params = nil;
    NSMutableDictionary * msgDic = [[NSMutableDictionary alloc] init];
    [msgDic setObject:msg forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_MENU_BUTTON] object:nil userInfo:msgDic];
    
    [collectionView reloadData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        bScrolling = NO;
        Message *msg = [[Message alloc] init];
        msg.mesRoute = MESSAGEROUTE_INTERNAL;
        msg.mesType  = MESSAGETYPE_SHOW_MENU_BUTTON;
        msg.params = nil;
        NSMutableDictionary * msgDic = [[NSMutableDictionary alloc] init];
        [msgDic setObject:msg forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_MENU_BUTTON] object:nil userInfo:msgDic];
        [collectionView reloadData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    bScrolling = NO;
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType  = MESSAGETYPE_SHOW_MENU_BUTTON;
    msg.params = nil;
    NSMutableDictionary * msgDic = [[NSMutableDictionary alloc] init];
    [msgDic setObject:msg forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_MENU_BUTTON] object:nil userInfo:msgDic];
    [collectionView reloadData];
}

-(void)aaShareBubbles:(AAShareBubbles *)shareBubbles tappedBubbleWithType:(AAShareBubbleType)bubbleType
{
    switch (bubbleType) {
        case AAShareBubbleTypeFacebook:
            NSLog(@"Facebook");
            break;
        case AAShareBubbleTypeTwitter:
            NSLog(@"Twitter");
            break;
        case AAShareBubbleTypeMail:
            NSLog(@"Email");
            break;
        case AAShareBubbleTypeGooglePlus:
            NSLog(@"Google+");
            break;
        case AAShareBubbleTypeTumblr:
            NSLog(@"Tumblr");
            break;
        case AAShareBubbleTypeVk:
            NSLog(@"Vkontakte (vk.com)");
            break;
        case 100:
            // custom buttons have type >= 100
            NSLog(@"Custom Button With Type 100");
            break;
        default:
            break;
    }
}

-(void)aaShareBubblesDidHide:(AAShareBubbles *)bubbles {
    NSLog(@"All Bubbles hidden");
}
@end
