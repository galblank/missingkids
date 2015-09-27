//
//  RoundImageTableViewCell.m
//  re:group'd
//
//  Created by Gal Blank on 1/11/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import "RoundImageTableViewCell.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "ImageResizer.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
@implementation RoundImageTableViewCell

@synthesize avatarView,cellTextLabel,cellDetailedTextLabel,avatarLabel,cellTextString,cellDetailedString,badgeCount,implementationStyle,timeStampLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withRowHeight:(CGFloat)rowHeight
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.implementationStyle = kROUND_IMAGE_CELL_STYLE_INVALID;
        
        
        if([reuseIdentifier isEqualToString:kCELL_REUSE_ID_CONTACT_LISTING])
        {
            self.implementationStyle = kROUND_IMAGE_CELL_STYLE_CONTACT_LISTING;
        }
        
        
        
        selfHeight = rowHeight;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        cellStyle = style;
        
        
        // Do our alloc's here...
        self.avatarView = [[UIImageView alloc] init];
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.layer.cornerRadius = ROUND_CORNER_RADIUS;
        self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
        
        
        loadingSpinner = [[UIActivityIndicatorView alloc] init];
        loadingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        loadingSpinner.hidden = YES;
        loadingSpinner.color = TITLE_BUTTONS_COLOR;
        loadingSpinner.hidesWhenStopped = YES;
        [self.avatarView addSubview:loadingSpinner];
        [self.contentView addSubview:avatarView];
        
        
        
        contentActivityView = [[UIActivityIndicatorView alloc] init];
        contentActivityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        contentActivityView.hidden = YES;
        contentActivityView.color = TITLE_BUTTONS_COLOR;
        contentActivityView.hidesWhenStopped = YES;
        [self.contentView addSubview:contentActivityView];
        
        
        
        avatarLabel = [[UILabel alloc] init];
        avatarLabel.textAlignment = NSTextAlignmentCenter;
        avatarLabel.font = [UIFont fontWithName:@"HelveticaNeue-Meduim" size:16];
        avatarLabel.backgroundColor = [UIColor whiteColor];
        avatarLabel.textColor = [UIColor whiteColor];
        avatarLabel.layer.masksToBounds = YES;
        avatarLabel.layer.cornerRadius = ROUND_CELL_AVATAR_HEIGHT / 2;
        [self.contentView addSubview:self.avatarLabel];
        
        
        activityView = [[UIActivityIndicatorView alloc] init];
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityView.color = POLL_THEME_COLOR;
        activityView.restorationIdentifier = @"avatarspinner";
        //[activityView startAnimating];
        activityView.center = avatarLabel.center;
        CGRect actframe = activityView.frame;
        actframe.origin.x = avatarLabel.frame.size.width / 2 - 7.5;
        actframe.origin.y = avatarLabel.frame.size.height / 2 - 7.5;
        activityView.frame = actframe;
        [avatarLabel addSubview:activityView];
        
        
        // This one has to be white because it is hard to see the blue on the gray background.
        loadingAvatarActivityView = [[UIActivityIndicatorView alloc] init];
        loadingAvatarActivityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        loadingAvatarActivityView.hidden = YES;
        loadingAvatarActivityView.hidesWhenStopped = YES;
        [self.contentView addSubview:loadingAvatarActivityView];
        
        
        self.cellTextLabel = [[UILabel alloc] init];
        self.cellTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        self.cellTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.cellTextLabel.numberOfLines = 1;
        self.cellTextLabel.textColor = [UIColor colorWithRed:76.0 / 255.0 green:79.0 / 255.0 blue:89.0 / 255.0 alpha:1.0];
        [self.contentView addSubview:self.cellTextLabel];
        
        
        
        overlaybadge = [[UILabel alloc] init];
        overlaybadge.backgroundColor = [UIColor clearColor];
        overlaybadge.textColor = [UIColor whiteColor];
        overlaybadge.textAlignment = NSTextAlignmentCenter;
        overlaybadge.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        overlaybadge.text = @"0";
        overlaybadge.hidden = YES;
        overlaybadge.restorationIdentifier = @"overlaybadge";
        [self.contentView addSubview:overlaybadge];
        
        
        self.cellDetailedTextLabel = [[UILabel alloc] init];
        self.cellDetailedTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        self.cellDetailedTextLabel.numberOfLines = 2;
        self.cellDetailedTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        //self.cellDetailedTextLabel.backgroundColor  = [UIColor yellowColor];
        self.cellDetailedTextLabel.textColor = [UIColor colorWithRed:106.0 / 255.0 green:106.0 / 255.0 blue:106.0 / 255.0 alpha:1.0];
        [self.contentView addSubview:self.cellDetailedTextLabel];
        
        
        timeStampLabel = [[UILabel alloc] init];
        timeStampLabel.backgroundColor = [UIColor clearColor];
        timeStampLabel.textColor = [UIColor colorWithRed:173.0 / 255.0 green:173.0 / 255.0 blue:173.0 / 255.0 alpha:1.0];
        timeStampLabel.textAlignment = NSTextAlignmentRight;
        timeStampLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        timeStampLabel.text = @"0";
        [self.contentView addSubview:timeStampLabel];
        
        
        badge = [[UILabel alloc] init];
        badge.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"badge"]];
        badge.textColor = [UIColor whiteColor];
        badge.textAlignment = NSTextAlignmentCenter;
        badge.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
        badge.text = @"";
        badge.hidden = YES;
        badge.restorationIdentifier = @"badge";
        [self.contentView addSubview:badge];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    // TODO: Finish these for the other places in the app where we use this cell.
    if(implementationStyle == kROUND_IMAGE_CELL_STYLE_CONTACT_LISTING)
    {
        self.avatarView.frame = CGRectMake(10.0,
                                           (self.contentView.frame.size.height - ROUND_CELL_AVATAR_HEIGHT) / 2,
                                           ROUND_CELL_AVATAR_HEIGHT,
                                           ROUND_CELL_AVATAR_HEIGHT);
    }
    else
    {
        if(selfHeight == ROUND_CELL_AVATAR_HEIGHT)
        {
            self.avatarView.frame = CGRectMake(10.0,
                                               (self.contentView.frame.size.height - ROUND_CELL_AVATAR_HEIGHT) / 2,
                                               ROUND_CELL_AVATAR_HEIGHT,
                                               ROUND_CELL_AVATAR_HEIGHT);
        }
        else
        {
            self.avatarView.frame = CGRectMake(10.0,
                                               self.contentView.frame.size.height / 2 - (ROOMS_MANAGER_AVATAR_HEIGHT / 2),
                                               ROOMS_MANAGER_AVATAR_HEIGHT,
                                               ROOMS_MANAGER_AVATAR_HEIGHT);
        }
    }
    
    
    
    loadingSpinner.frame = CGRectMake(0.0, 0.0, 15.0, 15.0);
    loadingSpinner.center = self.avatarView.center;
    
    
    
    contentActivityView.frame = CGRectMake(self.contentView.frame.size.width - 15.0 - 15.0,
                                           (self.contentView.frame.size.height-15.0)/2,
                                           15.0,
                                           15.0);
    
    
    
    
    
    self.avatarLabel.frame = self.avatarView.frame;
    loadingAvatarActivityView.frame = self.avatarView.frame;
    
    activityView.frame = CGRectMake(0.0, 0.0, 15.0, 15.0);
    
    CGRect actframe = activityView.frame;
    actframe.origin.x = avatarLabel.frame.size.width / 2 - 7.5;
    actframe.origin.y = avatarLabel.frame.size.height / 2 - 7.5;
    activityView.frame = actframe;
    
    loadingAvatarActivityView.center = self.avatarView.center;
    
    
    
    CGFloat posX = avatarView.frame.origin.x + avatarView.frame.size.width + 10;
    self.cellTextLabel.frame = CGRectMake(posX,self.avatarView.frame.origin.y, self.frame.size.width - posX - 80, ROUND_CELL_AVATAR_HEIGHT / 2);
    
    if(cellStyle != UITableViewCellStyleSubtitle)
    {
        /* This frame is set below.
         self.cellTextLabel.frame = CGRectMake(posX,
         avatarView.frame.origin.y,
         self.frame.size.width - posX,
         ROUND_CELL_AVATAR_HEIGHT);
         */
        
    }
    else
    {
        overlaybadge.frame = self.avatarView.frame;
        
        self.cellDetailedTextLabel.frame = CGRectMake(posX,
                                                      ROUND_IMAGE_CELL_HEIGHT / 2 - 13,
                                                      self.frame.size.width - posX - 30,
                                                      ROUND_IMAGE_CELL_HEIGHT / 2);
        
        timeStampLabel.frame = CGRectMake(self.contentView.frame.size.width - 140,
                                          0.0,
                                          130.0,
                                          30.0);
    }
    
    
    badge.frame = CGRectMake(10.0,
                             10.0,
                             [UIImage imageNamed:@"badge"].size.width,
                             [UIImage imageNamed:@"badge"].size.height);
    
    
    self.cellTextLabel.text = cellTextString;
    self.cellDetailedTextLabel.text = cellDetailedString;
    
    if(self.implementationStyle == kROUND_IMAGE_CELL_STYLE_ROOM_MANAGER_USER_LISTING_CHAT){
        CGRect lblFrame = self.cellDetailedTextLabel.frame;
        self.cellDetailedTextLabel.frame = CGRectMake(self.cellDetailedTextLabel.frame.origin.x,
                                                      self.cellTextLabel.frame.origin.y + self.cellTextLabel.frame.size.height,
                                                      self.cellDetailedTextLabel.frame.size.width,
                                                      self.cellDetailedTextLabel.frame.size.height);
        
        
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:self.cellDetailedTextLabel.frame];
        tempLabel.numberOfLines = 2;
        tempLabel.text = cellDetailedString;
        tempLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [tempLabel sizeToFit];
        lblFrame = tempLabel.frame;
        self.cellDetailedTextLabel.frame = CGRectMake(self.cellDetailedTextLabel.frame.origin.x,self.cellTextLabel.frame.origin.y + self.cellTextLabel.frame.size.height, self.cellDetailedTextLabel.frame.size.width, tempLabel.frame.size.height);
    }
    
    if(cellStyle == UITableViewCellStyleSubtitle)
    {
        timeStampLabel.text = self.timeStamp;
    }
    else
    {
        // The contacts view controller uses this code.
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:self.cellTextLabel.frame];
        tempLabel.numberOfLines = 1;
        tempLabel.text = cellTextString;
        tempLabel.font = self.cellTextLabel.font;
        [tempLabel sizeToFit];
        CGFloat posX = self.avatarLabel.frame.origin.x + self.avatarLabel.frame.size.width + 5;
        if(self.avatarView.image){
            posX = self.avatarView.frame.origin.x + self.avatarView.frame.size.width + 5;
        }
        
        self.cellTextLabel.frame = CGRectMake(posX,
                                              selfHeight / 2 - tempLabel.frame.size.height / 2,
                                              self.frame.size.width - 70,
                                              tempLabel.frame.size.height);
        
    }
    
    
    if(badgeCount.length > 0){
        badge.text = badgeCount;
        badge.hidden = NO;
    }
    else{
        badge.hidden = YES;
    }
    
}


// TODO: Remove this if not needed...
- (void)layoutSubviewsORG
{
    [super layoutSubviews];
    
    if(self.avatarView == nil){
        self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ROUND_CELL_AVATAR_HEIGHT / 2 - 10, ROUND_CELL_AVATAR_HEIGHT, ROUND_CELL_AVATAR_HEIGHT)];
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.layer.cornerRadius = ROUND_CORNER_RADIUS;
        self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
        
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        loadingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        loadingSpinner.hidden = YES;
        loadingSpinner.color = TITLE_BUTTONS_COLOR;
        loadingSpinner.center = self.avatarView.center;
        loadingSpinner.hidesWhenStopped = YES;
        [self.avatarView addSubview:loadingSpinner];
        [self.contentView addSubview:avatarView];
        
        avatarLabel = [[UILabel alloc] initWithFrame:avatarView.frame];
        avatarLabel.textAlignment = NSTextAlignmentCenter;
        avatarLabel.font = [UIFont fontWithName:@"HelveticaNeue-Meduim" size:16];
        avatarLabel.backgroundColor = [UIColor whiteColor];
        avatarLabel.textColor = [UIColor whiteColor];
        avatarLabel.layer.masksToBounds = YES;
        avatarLabel.layer.cornerRadius = ROUND_CELL_AVATAR_HEIGHT / 2;
        
        [self.contentView addSubview:self.avatarLabel];
        
        activityView = [[UIActivityIndicatorView alloc] init];
        activityView.frame = CGRectMake(0,0,15,15);
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityView.color = POLL_THEME_COLOR;
        activityView.restorationIdentifier = @"avatarspinner";
        //[activityView startAnimating];
        activityView.center = avatarLabel.center;
        CGRect actframe = activityView.frame;
        actframe.origin.x = avatarLabel.frame.size.width / 2 - 7.5;
        actframe.origin.y = avatarLabel.frame.size.height / 2 - 7.5;
        activityView.frame = actframe;
        [avatarLabel addSubview:activityView];
        
        CGFloat posX = avatarView.frame.origin.x + avatarView.frame.size.width + 10;
        
        self.cellTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX,self.avatarView.frame.origin.y, self.frame.size.width - posX - 80, ROUND_CELL_AVATAR_HEIGHT / 2)];
        //self.cellTextLabel.backgroundColor = [UIColor yellowColor];
        self.cellTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        self.cellTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.cellTextLabel.numberOfLines = 1;
        self.cellTextLabel.textColor = [UIColor colorWithRed:76.0 / 255.0 green:79.0 / 255.0 blue:89.0 / 255.0 alpha:1.0];
        [self.contentView addSubview:self.cellTextLabel];
        
        if(cellStyle != UITableViewCellStyleSubtitle){
            self.cellTextLabel.frame = CGRectMake(posX,avatarView.frame.origin.y, self.frame.size.width - posX, ROUND_CELL_AVATAR_HEIGHT);
        }
        else{
            overlaybadge = [[UILabel alloc] initWithFrame:self.avatarView.frame];
            overlaybadge.backgroundColor = [UIColor clearColor];
            overlaybadge.textColor = [UIColor whiteColor];
            overlaybadge.textAlignment = NSTextAlignmentCenter;
            overlaybadge.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
            overlaybadge.text = @"0";
            overlaybadge.hidden = YES;
            overlaybadge.restorationIdentifier = @"overlaybadge";
            [self.contentView addSubview:overlaybadge];
            self.cellDetailedTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX,ROUND_IMAGE_CELL_HEIGHT / 2 - 13, self.frame.size.width - posX - 30, ROUND_IMAGE_CELL_HEIGHT / 2)];
            self.cellDetailedTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            self.cellDetailedTextLabel.numberOfLines = 2;
            //self.cellDetailedTextLabel.backgroundColor = [UIColor yellowColor];
            self.cellDetailedTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            self.cellDetailedTextLabel.textColor = [UIColor colorWithRed:106.0 / 255.0 green:106.0 / 255.0 blue:106.0 / 255.0 alpha:1.0];
            [self.contentView addSubview:self.cellDetailedTextLabel];
            
            timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 140, 0, 130, 30)];
            timeStampLabel.backgroundColor = [UIColor clearColor];
            timeStampLabel.textColor = [UIColor colorWithRed:173.0 / 255.0 green:173.0 / 255.0 blue:173.0 / 255.0 alpha:1.0];
            timeStampLabel.textAlignment = NSTextAlignmentRight;
            timeStampLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
            timeStampLabel.text = @"0";
            [self.contentView addSubview:timeStampLabel];
        }
        
        badge = [[UILabel alloc] initWithFrame:CGRectMake(10,10, [UIImage imageNamed:@"badge"].size.width, [UIImage imageNamed:@"badge"].size.height)];
        badge.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"badge"]];
        badge.textColor = [UIColor whiteColor];
        badge.textAlignment = NSTextAlignmentCenter;
        badge.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
        badge.text = @"";
        badge.hidden = YES;
        badge.restorationIdentifier = @"badge";
        [self.contentView addSubview:badge];
    }
    
    self.cellTextLabel.text = cellTextString;
    self.cellDetailedTextLabel.text = cellDetailedString;
    
    
    
    if(cellStyle == UITableViewCellStyleSubtitle){
        timeStampLabel.text = self.timeStamp;
        //[self.cellTextLabel sizeToFit];
        self.cellDetailedTextLabel.frame = CGRectMake(self.cellDetailedTextLabel.frame.origin.x,self.cellTextLabel.frame.origin.y + self.cellTextLabel.frame.size.height, self.cellDetailedTextLabel.frame.size.width, self.cellDetailedTextLabel.frame.size.height);
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:self.cellDetailedTextLabel.frame];
        tempLabel.numberOfLines = 2;
        tempLabel.text = cellDetailedString;
        tempLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15];
        [tempLabel sizeToFit];
        self.cellDetailedTextLabel.frame = CGRectMake(self.cellDetailedTextLabel.frame.origin.x,self.cellTextLabel.frame.origin.y + self.cellTextLabel.frame.size.height, self.cellDetailedTextLabel.frame.size.width, tempLabel.frame.size.height);
    }
    else{
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:self.cellTextLabel.frame];
        tempLabel.numberOfLines = 1;
        tempLabel.text = cellTextString;
        tempLabel.font = self.cellTextLabel.font;
        [tempLabel sizeToFit];
        CGFloat posX = self.avatarLabel.frame.origin.x + self.avatarLabel.frame.size.width + 5;
        if(self.avatarView.image){
            posX = self.avatarView.frame.origin.x + self.avatarView.frame.size.width + 5;
        }
        self.cellTextLabel.frame = CGRectMake(posX,selfHeight / 2 - tempLabel.frame.size.height / 2, self.frame.size.width - 70, tempLabel.frame.size.height);
    }
    
    if(badgeCount.length > 0){
        badge.text = badgeCount;
        badge.hidden = NO;
    }
    else{
        badge.hidden = YES;
    }
}



#pragma mark - Cell Activity Control

- (void)startCellContentActivity
{
    contentActivityView.hidden = NO;
    [contentActivityView startAnimating];
}


- (void)stopCellContentActivity
{
    [contentActivityView stopAnimating];
}

- (void)startCellLoadingAvatarActivity
{
    loadingAvatarActivityView.hidden = NO;
    [loadingAvatarActivityView startAnimating];
}

- (void)startCellLoadingAvatarActivityOnWhiteBackground
{
    loadingAvatarActivityView.color = TITLE_BUTTONS_COLOR;
    loadingAvatarActivityView.hidden = NO;
    [loadingAvatarActivityView startAnimating];
}

- (void)stopCellLoadingAvatarActivity
{
    [loadingAvatarActivityView stopAnimating];
}

#pragma mark - Clear Cell Content (Reuse)

- (void)clearCellStateFromAnyReuse
{
    self.avatarView.image            = nil;
    self.avatarLabel.text            = @"";
    self.cellTextLabel.text          = @"";
    self.cellDetailedTextLabel.text  = @"";
    self.badgeCount                  = @"";
    self.cellDetailedString          = @"";
    self.timeStamp                   = @"";
    badge.text                       = @"";
    overlaybadge.text                = @"";
}



#pragma mark -


-(void)setOverlayBadgeValue:(NSString*)text
{
    if(text == nil || text.length == 0){
        overlaybadge.hidden = YES;
        self.avatarView.alpha = 1.0;
    }
    else{
        self.avatarView.alpha = 0.8;
        overlaybadge.hidden = NO;
        overlaybadge.text = text;
    }
}

-(void)aligntextlabelsWithReferenceFrame:(CGRect)refFrame shouldCenterLabel:(BOOL)bShouldCenter
{
    CGFloat posX = refFrame.origin.x + refFrame.size.width + 10;
    CGFloat posY = refFrame.origin.y;
    if(bShouldCenter == YES){
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:self.cellTextLabel.frame];
        tempLabel.numberOfLines = 1;
        tempLabel.text = cellTextString;
        tempLabel.font = self.cellTextLabel.font;
        [tempLabel sizeToFit];
        posY = selfHeight / 2 - tempLabel.frame.size.height / 2;
    }
    self.cellTextLabel.frame = CGRectMake(posX,posY,self.cellTextLabel.frame.size.width,self.cellTextLabel.frame.size.height);
    
    if(bShouldCenter == NO){
        self.cellDetailedTextLabel.frame = CGRectMake(posX,self.cellTextLabel.frame.origin.y + self.cellTextLabel.frame.size.height, self.cellDetailedTextLabel.frame.size.width, self.cellDetailedTextLabel.frame.size.height);
    }
}




-(void)setAvatar:(UIImage*)image userLabel:(NSString*)label withAvatarHeight:(CGFloat)height shouldCenterlabel:(BOOL)shouldCenterlabel
{  
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityView stopAnimating];
        if(image == nil)
        {
            self.avatarLabel.frame = CGRectMake(10, self.contentView.frame.size.height / 2 - (height / 2), height, height);
            self.avatarView.image = nil;
            self.avatarLabel.hidden = NO;
            self.avatarLabel.backgroundColor = [UIColor colorWithRed:192.0 / 255.0 green:192.0 / 255.0 blue:192.0 / 255.0 alpha:1.0];
            self.avatarLabel.layer.masksToBounds = YES;
            self.avatarLabel.layer.cornerRadius = height / 2;
            avatarLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            avatarLabel.layer.borderWidth = 1.0;
            self.avatarLabel.text = label;
            [self aligntextlabelsWithReferenceFrame:self.avatarLabel.frame shouldCenterLabel:shouldCenterlabel];
        }
        else{
            self.avatarLabel.hidden = YES;
            self.avatarView.alpha = 1.0;
            self.avatarView.frame = CGRectMake(10, self.contentView.frame.size.height / 2 - (height / 2), height, height);
            self.avatarView.image = [image copy];
            self.avatarView.layer.cornerRadius = height / 2;
            [self aligntextlabelsWithReferenceFrame:self.avatarView.frame shouldCenterLabel:shouldCenterlabel];
            
            
            /*[UIView transitionWithView: self.avatarView    // use the forView: argument
                              duration:0.50          // use the setAnimationDuration: argument
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^
             {
                 self.avatarView.alpha = 1.0;
             }
            completion:^(BOOL finished)
             {
                 
             }];*/
           

        }
        
    });
}

-(void)setRoomAvatar:(UIImage*)image defaultImage:(UIImage*)defaultImage withAvatarHeight:(CGFloat)height
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityView stopAnimating];
        [loadingSpinner stopAnimating];
        UIImage *imageToUse = image == nil?defaultImage:image;
        self.avatarLabel.hidden = YES;
        self.avatarView.frame = CGRectMake(10, self.contentView.frame.size.height / 2 - (height / 2), height, height);
        self.avatarView.image = [imageToUse copy];
        //self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = height / 2;
        [self aligntextlabelsWithReferenceFrame:self.avatarView.frame shouldCenterLabel:NO];
    });
    
}


-(void)setAvatar:(UIImage*)image userLabel:(NSString*)label
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(image == nil)
        {
            [activityView stopAnimating];
            self.avatarView.image = nil;
            self.avatarLabel.hidden = NO;
            self.avatarLabel.backgroundColor = [UIColor lightGrayColor];
            self.avatarLabel.layer.masksToBounds = YES;
            self.avatarLabel.layer.cornerRadius = ROUND_CORNER_RADIUS;
            avatarLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            avatarLabel.layer.borderWidth = 1.0;
            self.avatarLabel.text = label;
        }
        else{
            self.avatarLabel.hidden = YES;
            self.avatarView.image = image;
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = ROUND_CORNER_RADIUS;
        }
    });
    
}
@end
