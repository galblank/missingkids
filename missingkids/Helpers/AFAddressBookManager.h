//
//  AFAddressBookManager.h
//  re:group'd
//
//  Created by Gal Blank on 12/4/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface AFAddressBookManager : NSObject<UIAlertViewDelegate>


/**
 *  Get name of contact with specific phone number.
 *
 *  @param phoneNumber Phone number for the contact.
 *
 *  @return Name of contact.
 */
//+ (NSString *)nameForContactWithPhoneNumber:(NSString *)phoneNumber;

/**
 *  Get photo of contact with specific phone number.
 *
 *  @param phoneNumber Phone number for the contact.
 *
 *  @return Photo of contact.
 */
//+ (UIImage *)photoForContactWithPhoneNumber:(NSString *)phoneNumber;

/**
 *  Get name of contact with specific email address.
 *
 *  @param emailAddress Email address for the contact.
 *
 *  @return Name of contact.
 */
//+ (NSString *)nameForContactWithEmailAddress:(NSString *)emailAddress;

/**
 *  Get photo of contact with specific email address.
 *
 *  @param emailAddress Email address for the contact.
 *
 *  @return Photo of contact.
 */
//+ (UIImage *)photoForContactWithEmailAddress:(NSString *)emailAddress;


// Send out notification if there is a new item added to the iOS Address Book
//+ (void)registerForUserAddressBookChanges;
+ (void)registerForUserAddressBookChangesWithBook:(ABAddressBookRef)addressBook;

+ (NSArray *)allContactsFromAddressBook;

+(void)getvCardsFromAddressBook:(void (^)(NSData*result,BOOL bAccessGranted))callbackBlock;

@end
