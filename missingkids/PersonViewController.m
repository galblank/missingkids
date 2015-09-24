//
//  PersonViewController.m
//  missingkids
//
//  Created by Gal Blank on 9/24/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "PersonViewController.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "MessageDispatcher.h"

@interface PersonViewController ()

@end

@implementation PersonViewController

@synthesize person;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    Message *msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSAGETYPE_CHANGE_MENU_BUTTON;
    msg.params = [[NSMutableDictionary alloc] init];
    [msg.params setObject:[NSNumber numberWithInt:FLOATINGBUTTON_TYPE_BACK] forKey:@"buttontype"];
    NSMutableDictionary *userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setObject:msg forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_CHANGE_MENU_BUTTON] object:nil userInfo:userinfo];
    
    // Do any additional setup after loading the view.
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height / 2)];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = YES;
    scrollView.delegate = self;
    scrollView.minimumZoomScale=0.5;
    scrollView.maximumZoomScale=6.0;
    scrollView.layer.borderWidth = 0.3;
    scrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    [self.view addSubview:scrollView];
    
    NSString * images = [person objectAtIndex:IMAGE];
    NSMutableArray *arrayOfImages = [[NSMutableArray alloc] init];
    while (images.length > 0) {
        NSString * oneimage = [images substringToIndex:2];
        [arrayOfImages addObject:oneimage];
        images = [images substringFromIndex:2];
    }
    
    for(int i=0;i< arrayOfImages.count; i++) {
        CGFloat x = i * self.view.frame.size.width;
        NSString *imageurl = [arrayOfImages objectAtIndex:i];
        NSString * buildFullPath = [NSString stringWithFormat:@"%@/%@%@%@.jpg",ROOT_IMAGES,[person objectAtIndex:ORG_PREFIX],[person objectAtIndex:CASE_NUMBER],imageurl];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
        imageView.tag = i;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
      
        [imageView setImageWithURL:[NSURL URLWithString:buildFullPath] placeholderImage:[UIImage imageNamed:@"profile"]];
        float minimumScale = [scrollView frame].size.width  / [imageView frame].size.width;
        [scrollView setMinimumZoomScale:minimumScale];
        [scrollView setZoomScale:minimumScale];
        [scrollView addSubview:imageView];
    }
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * arrayOfImages.count,scrollView.frame.size.height);
    
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, scrollView.frame.origin.y + scrollView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (scrollView.frame.origin.y + scrollView.frame.size.height)) style:UITableViewStyleGrouped];
    tableview.scrollEnabled = YES;
    tableview.showsVerticalScrollIndicator = YES;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableview.userInteractionEnabled = YES;
    tableview.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    tableview.scrollsToTop = YES;
    tableview.bounces = YES;
    tableview.backgroundColor = [UIColor whiteColor];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.allowsMultipleSelectionDuringEditing = NO;
    tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableview];
    
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(20, self.view.frame.size.height - 80, 60, 60);
    shareButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    shareButton.layer.borderWidth = 0.3;
    shareButton.alpha = 0.8;
    [shareButton setBackgroundColor:[UIColor whiteColor]];
    [shareButton addTarget:self action:@selector(showSharingMenu) forControlEvents:UIControlEventTouchUpInside];
    shareButton.layer.cornerRadius = shareButton.frame.size.height / 2;
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.view addSubview:shareButton];
}

-(void)showSharingMenu
{
    Message * msg = [[Message alloc] init];
    msg.mesRoute = MESSAGEROUTE_INTERNAL;
    msg.mesType = MESSAGETYPE_SHOW_SHARING_MENU;
    msg.ttl = TTL_NOW;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:msg forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:[[MessageDispatcher sharedInstance] messageTypeToString:MESSAGETYPE_SHOW_SHARING_MENU] object:nil userInfo:dic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        cell.textLabel.numberOfLines = 0;;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if(indexPath.row == 0){
        NSNumber * missingDate = [person objectAtIndex:MISSING_DATE];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:(missingDate.doubleValue / 1000)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MMM dd yyyy";
        NSString * strDate = [df stringFromDate:date];
        cell.textLabel.text = [NSString stringWithFormat:@"Went missing on %@ from %@ %@",strDate,[person objectAtIndex:MISSING_CITY],[person objectAtIndex:MISSING_COUNTRY]];
    }
    else if(indexPath.row == 1){
        cell.textLabel.text = [person objectAtIndex:CIRCUMSTANCE];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 50.0;
    }
    
    return 150.0;
}


@end
