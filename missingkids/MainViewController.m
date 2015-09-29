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
#import "PersonViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSAGETYPE_CHANGE_MENU_BUTTON;
    msg.params = [[NSMutableDictionary alloc] init];
    [msg.params setObject:[NSNumber numberWithInt:FLOATINGBUTTON_TYPE_MENU] forKey:@"buttontype"];
    NSMutableDictionary *userinfo = [[NSMutableDictionary alloc] init];
    
    [userinfo setObject:msg forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_CHANGE_MENU_BUTTON] object:nil userInfo:userinfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    maincollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(2, 20, self.view.frame.size
                                                                      .width - 4, self.view.frame.size.height - 20) collectionViewLayout:layout];
    [maincollectionView setDataSource:self];
    [maincollectionView setDelegate:self];
    
    [maincollectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [maincollectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:maincollectionView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    currentSortingMissingDateOption = SORTING_MISSING_DATE_DESC;
    currentSortingAgeOption = SORTING_AGE_DESC;
    currentSortingSexOption =SORTING_SEX_MALE;
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width,50)];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = YES;
    scrollView.delegate = self;
    scrollView.minimumZoomScale=0.5;
    scrollView.maximumZoomScale=6.0;
    //scrollView.layer.borderWidth = 0.3;
    //scrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.alpha = 0.8;
    self.automaticallyAdjustsScrollViewInsets = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.view addSubview:scrollView];
    
    CGFloat x = 0 * self.view.frame.size.width;
    UIButton *buttonDate = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonDate.titleLabel.numberOfLines = 0;
    [buttonDate.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    [buttonDate setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    buttonDate.frame = CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [buttonDate setTitle:NSLocalizedString(@"Sort by : Missing Date", nil) forState:UIControlStateNormal];
    [scrollView addSubview:buttonDate];
    
    x += scrollView.frame.size.width;
    UIButton *buttonAge = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonAge.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    buttonAge.titleLabel.numberOfLines = 0;
    buttonAge.frame = CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [buttonAge setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [buttonAge setTitle:NSLocalizedString(@"Sort by : Age", nil) forState:UIControlStateNormal];
    [scrollView addSubview:buttonAge];
    
    x += scrollView.frame.size.width;
    UIButton *buttonSex = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSex.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    buttonSex.titleLabel.numberOfLines = 0;
    [buttonSex setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    buttonSex.frame = CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [buttonSex setTitle:NSLocalizedString(@"Sort by : Sex", nil) forState:UIControlStateNormal];
    [scrollView addSubview:buttonSex];
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3,scrollView.frame.size.height);
    
    
    
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
        [maincollectionView reloadData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sort:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SORT_BY_MISSINGDATE] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sort:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SORT_BY_AGE] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sort:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SORT_BY_SEX] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filter:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_FILTER_OPTIONS] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidefilter) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_HIDE_FILTER_OPTIONS] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showItemsList:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_LIST_VIEW] object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyFilter) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_APPLY_FILTER] object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearFilter) name:[[MessageDispatcher sharedInstance] messageTypeToString:MESSageTYPE_CLEAR_FILTER] object:nil];
    
    
}

-(void)clearFilter
{
   [self hidefilter];
    NSMutableArray * results = [[DBManager sharedInstance] loadDataFromDB:@"select * from person order by missingDate desc"];
    if(results){
        collectionData = results;
        [maincollectionView reloadData];
    }
}

-(void)didselectItem:(NSString*)item forItemType:(ITEMTYPE)type
{
    
    switch (type) {
        case ITEM_TYPE_COUNTRY:
            [filterWindow.countryButton setTitle:item forState:UIControlStateNormal];
            break;
        case ITEM_TYPE_STATE:
            [filterWindow.stateButton setTitle:item forState:UIControlStateNormal];
            break;
            case ITEM_TYPE_CITY:
            [filterWindow.cityButton setTitle:item forState:UIControlStateNormal];
            break;
        default:
            break;
    }
   
}

-(void)showItemsList:(NSNotification*)notify
{
    Message * msg = [notify.userInfo objectForKey:@"message"];
    ItemsTableViewController * countries = [[ItemsTableViewController alloc] init];
    countries.lsitDelegate = self;
    NSNumber * itemtype = [msg.params objectForKey:@"itemtype"];
    countries.iType = [itemtype intValue];
    [self.navigationController pushViewController:countries animated:YES];
}


-(void)applyFilter
{
    [self hidefilter];
    if(filterWindow){
        
        NSString * query = @"select * from person where";
        if([filterWindow.countryButton.titleLabel.text caseInsensitiveCompare:NSLocalizedString(@"Country", nil)] != NSOrderedSame){
            query = [query stringByAppendingFormat:@" missingCountry = '%@'",filterWindow.countryButton.titleLabel.text];
            if([filterWindow.stateButton.titleLabel.text caseInsensitiveCompare:NSLocalizedString(@"State", nil)] != NSOrderedSame){
                query = [query stringByAppendingFormat:@"or missingState = '%@'",filterWindow.stateButton.titleLabel.text];
            }
            if([filterWindow.cityButton.titleLabel.text caseInsensitiveCompare:NSLocalizedString(@"City", nil)] != NSOrderedSame){
                query = [query stringByAppendingFormat:@"or missingCity = '%@'",filterWindow.cityButton.titleLabel.text];
            }
        }
        else if([filterWindow.stateButton.titleLabel.text caseInsensitiveCompare:NSLocalizedString(@"State", nil)] != NSOrderedSame){
            query = [query stringByAppendingFormat:@" missingState = '%@'",filterWindow.stateButton.titleLabel.text];
            if([filterWindow.cityButton.titleLabel.text caseInsensitiveCompare:NSLocalizedString(@"City", nil)] != NSOrderedSame){
                query = [query stringByAppendingFormat:@"or missingCity = '%@'",filterWindow.cityButton.titleLabel.text];
            }
        }
        else if([filterWindow.cityButton.titleLabel.text caseInsensitiveCompare:NSLocalizedString(@"City", nil)] != NSOrderedSame){
            query = [query stringByAppendingFormat:@" missingCity = '%@'",filterWindow.cityButton.titleLabel.text];
        }
        
        query = [query stringByAppendingString:@" order by missingDate desc;"];
        NSMutableArray * results = [[DBManager sharedInstance] loadDataFromDB:query];
        if(results){
            collectionData = results;
            [maincollectionView reloadData];
        }
    }
}

-(void)hidefilter
{
    if(filterWindow){
        [UIView animateWithDuration:0.5
                         animations:^{
                             filterWindow.frame = CGRectMake(0,-250,self.view.frame.size.width,250);
                         }
                         completion:^(BOOL finished){
                             [self.view sendSubviewToBack:filterWindow];
                         }];
    }
}

-(void)filter:(NSNotification*)notify
{
    if(filterWindow == nil){
        filterWindow = [[FilterView alloc] initWithFrame:CGRectMake(0,-250,self.view.frame.size.width,250)];
        [self.view addSubview:filterWindow];
        
    }
    
    
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         filterWindow.frame = CGRectMake(0,0,self.view.frame.size.width,250);
                     }
                     completion:^(BOOL finished){
                         [self.view bringSubviewToFront:filterWindow];
                     }];
   
}

-(void)sort:(NSNotification*)notify
{
    Message *msg = [notify.userInfo objectForKey:@"message"];
    switch (msg.mesType) {
        case MESSAGETYPE_SORT_BY_MISSINGDATE:
        {
            NSString * query = @"select * from person order by missingDate";
            if(currentSortingMissingDateOption == SORTING_MISSING_DATE_DESC){
                query = [query stringByAppendingString:@" asc;"];
                currentSortingMissingDateOption = SORTING_MISSING_DATE_ASC;
                
            }
            else{
                query = [query stringByAppendingString:@" desc;"];
                currentSortingMissingDateOption = SORTING_MISSING_DATE_DESC;
            }
            
            NSMutableArray * results = [[DBManager sharedInstance] loadDataFromDB:query];
            if(results){
                collectionData = results;
                [maincollectionView reloadData];
            }
            
            
        }
            break;
        case MESSAGETYPE_SORT_BY_SEX:
        {
            NSString * query = @"select * from person order by age";
            if(currentSortingAgeOption == SORTING_AGE_DESC){
                query = [query stringByAppendingString:@" asc;"];
                currentSortingAgeOption = SORTING_AGE_ASC;
                
            }
            else{
                query = [query stringByAppendingString:@" desc;"];
                currentSortingAgeOption = SORTING_AGE_DESC;
            }
            
            NSMutableArray * results = [[DBManager sharedInstance] loadDataFromDB:query];
            if(results){
                collectionData = results;
                [maincollectionView reloadData];
            }
        }
            break;
        case MESSAGETYPE_SORT_BY_AGE:
        {
            NSString * query = @"select * from person where sex like '%";
            if(currentSortingSexOption == SORTING_SEX_MALE){
                query = [query stringByAppendingString:@"female%';"];
                currentSortingSexOption = SORTING_SEX_FEMALE;
                
            }
            else{
                query = [query stringByAppendingString:@"male%'"];
                currentSortingSexOption = SORTING_SEX_MALE;
            }
            
            NSMutableArray * results = [[DBManager sharedInstance] loadDataFromDB:query];
            if(results){
                collectionData = results;
                [maincollectionView reloadData];
            }
        }
            break;
        default:
            break;
    }
    
    [maincollectionView reloadData];
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
            [maincollectionView reloadData];
        }
    });
    
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return collectionData.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((collectionView.frame.size.width - 10) / 2, self.view.frame.size.height / 3);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *person = [collectionData objectAtIndex:indexPath.item];
    PersonViewController *personVC = [[PersonViewController alloc] init];
    [personVC setPerson:person];
    [self.navigationController pushViewController:personVC animated:YES];
}


- (CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSMutableArray * person = [collectionData objectAtIndex:indexPath.item];
    if([person objectAtIndex:IMAGE]){
        NSString *imagename = [person objectAtIndex:IMAGE];
        if(imagename.length > 2){
            imagename = [imagename substringToIndex:2];
        }
        NSString * buildFullPath = [NSString stringWithFormat:@"%@/%@%@%@.jpg",ROOT_IMAGES,[person objectAtIndex:ORG_PREFIX],[person objectAtIndex:CASE_NUMBER],imagename];
        NSURL *url = [NSURL URLWithString:buildFullPath];
        /*NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * response, NSData * data, NSError * error)
         {
             if (data) {
                 UIImage *image = [UIImage imageWithData:data];
                 if(image){
                     cell.backgroundView = [[UIImageView alloc] initWithImage:image];
                 }
                 else{
                     NSLog(@"image is null");
                 }
             }
         }];*/
        
        [cell.imageview setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile"]];
    }
    else{
        NSLog(@"no image");
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
    
    //[maincollectionView reloadItemsAtIndexPaths:[maincollectionView indexPathsForVisibleItems]];
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
        //[maincollectionView reloadItemsAtIndexPaths:[maincollectionView indexPathsForVisibleItems]];
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
    //[maincollectionView reloadItemsAtIndexPaths:[maincollectionView indexPathsForVisibleItems]];
}

@end
