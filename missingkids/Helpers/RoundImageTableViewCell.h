//
//  RoundImageTableViewCell.h
//  re:group'd
//
//  Created by Gal Blank on 1/11/15.
//  Copyright (c) 2015 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define ROUND_CORNER_RADIUS 17.5

#define  kCELL_REUSE_ID_PROFILE_MAIN_DISPLAY  @"kCELL_REUSE_ID_PROFILE_MAIN_DISPLAY"
#define  kCELL_REUSE_ID_GROUP_LIKES_USER      @"kCELL_REUSE_ID_GROUP_LIKES_USER"

#define  kCELL_REUSE_ID_CONTACT_LISTING       @"kCELL_REUSE_ID_CONTACT_LISTING"
#define FORM_HEADER_COLOR [UIColor colorWithRed:11 / 255.0 green:192  / 255.0 blue:255.0 / 255.0 alpha:1.0]
#define FORM_CELLVIEW_HEIGHT 350.0
#define FORM_CELLVIEW_HEADER_HEIGHT 36.0
#define POLL_CELL_HEIGHT    60.0
#define FORM_CELLVIEW_FOOTER_HEIGHT 70.0
#define YESNO_CELLVIEW_FOOTER_HEIGHT 55.0
#define FORM_IMAGE_HEIGHT   180.0
#define MESSAGE_IMAGE_HEIGHT 180.0
#define MESSAGE_DEFAULT_HEIGHT 50.0
#define TYPING_BUBBLE_HEIGHT 40.0
#define ROUND_CELL_AVATAR_HEIGHT 35.0
#define ROOMS_MANAGER_AVATAR_HEIGHT 50.0
#define ROUND_IMAGE_CELL_HEIGHT 80.0
#define ROUNDIMAGE_MEDIUMHEIGHT_CELL 40.0
#define THEME_COLOR_DISABLED [UIColor colorWithRed:105.0 / 255.0 green:217.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]

#define POLL_THEME_COLOR [UIColor colorWithRed:11.0 / 255.0 green:192.0  / 255.0 blue:255.0 / 255.0 alpha:1.0]
#define RATINGS_THEME_COLOR [UIColor colorWithRed:255 / 255.0 green:218  / 255.0 blue:81.0 / 255.0 alpha:1.0]
#define RSVP_THEME_COLOR [UIColor colorWithRed:98.0 / 255.0 green:236  / 255.0 blue:170.0 / 255.0 alpha:1.0]
#define YESNO_THEME_COLOR [UIColor colorWithRed:161 / 255.0 green:137  / 255.0 blue:255.0 / 255.0 alpha:1.0]
#define STREAM_BUTTONS_BG_COLOR [UIColor colorWithRed:235.0 / 255.0 green:236.0 / 255.0 blue:237.0 / 255.0 alpha:1.0]
#define SEARCHBAR_BG_COLOR [UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:215.0 / 255.0 alpha:1.0]
#define FORM_TEXT_DARKISH_GRAY [UIColor colorWithRed:74.0 / 255.0 green:74.0 / 255.0 blue:74.0 / 255.0 alpha:1.0]
#define FORM_TEXT_BUTTON_COLOR [UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0]
#define FORM_BORDER_COLOR [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0]
#define AVATAR_BG_COLOR [UIColor colorWithRed:226.0 / 255.0 green:226.0 / 255.0 blue:226.0 / 255.0 alpha:1.0]
#define ROUND_CORNER_RADIUS 17.5
enum
{
    kROUND_IMAGE_CELL_STYLE_INVALID                          = -1,
    kROUND_IMAGE_CELL_STYLE_PROFILE_MAIN_USER                =  1,
    kROUND_IMAGE_CELL_STYLE_GROUP_LIKES_USER                 =  2,
    kROUND_IMAGE_CELL_STYLE_ROOM_MANAGER_USER_LISTING_CHAT   =  3,
    kROUND_IMAGE_CELL_STYLE_CHAT_ROOM_USER_LISTING           =  4,
    kROUND_IMAGE_CELL_STYLE_CONTACT_LISTING                  =  5
};




@interface RoundImageTableViewCell : UITableViewCell
{
    UIImageView *avatarView;
    UILabel *cellTextLabel;
    UILabel *cellDetailedTextLabel;
    UILabel *overlaybadge;
    UITableViewCellStyle cellStyle;
    UILabel *badge;
    
    CGFloat selfHeight;
    UILabel *timeStampLabel;
    UIActivityIndicatorView *activityView;
    UIActivityIndicatorView * loadingSpinner;
    
    // For content loading
    UIActivityIndicatorView *contentActivityView;
    
    // For loading avatar in the contacts
    UIActivityIndicatorView *loadingAvatarActivityView;
    
}
@property(nonatomic)NSInteger implementationStyle;
@property(nonatomic,retain)UILabel *timeStampLabel;
@property(nonatomic,retain)NSString *badgeCount;
@property(nonatomic,retain)UIImageView *avatarView;
@property(nonatomic,retain)UILabel *cellTextLabel;
@property(nonatomic,retain)UILabel *cellDetailedTextLabel;
@property(nonatomic,retain)UILabel *avatarLabel;
@property(nonatomic,retain)NSString *cellDetailedString;
@property(nonatomic,retain)NSString *cellTextString;
@property(nonatomic,retain)NSString *timeStamp;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withRowHeight:(CGFloat)rowHeight;
-(void)setOverlayBadgeValue:(NSString*)text;
-(void)setAvatar:(UIImage*)image userLabel:(NSString*)label;
-(void)setAvatar:(UIImage*)image userLabel:(NSString*)label withAvatarHeight:(CGFloat)height shouldCenterlabel:(BOOL)shouldCenterlabel;
-(void)setRoomAvatar:(UIImage*)image defaultImage:(UIImage*)defaultImage withAvatarHeight:(CGFloat)height;

- (void)startCellContentActivity;
- (void)stopCellContentActivity;
- (void)stopCellLoadingAvatarActivity;
- (void)startCellLoadingAvatarActivity;
- (void)clearCellStateFromAnyReuse;
- (void)startCellLoadingAvatarActivityOnWhiteBackground;
@end
