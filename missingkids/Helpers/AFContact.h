//
//  AFContact.h
//  re:group'd
//
//  Created by Gal Blank on 12/4/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AFContact : NSObject
@property (nonatomic, strong) NSString *initials;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *numbers;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSString *contactFirstName;
@property (nonatomic, strong) NSString *contactLastName;
@end
