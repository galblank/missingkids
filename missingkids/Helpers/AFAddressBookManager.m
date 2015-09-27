//
//  AFAddressBookManager.m
//  re:group'd
//
//  Created by Gal Blank on 12/4/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import "AFAddressBookManager.h"

#import "AFContact.h"
#import "NSString+UnformattedPhoneNumber.h"
#import "AppDelegate.h"

@implementation AFAddressBookManager

+(void)getvCardsFromAddressBook:(void (^)(NSData*result,BOOL bAccessGranted))callbackBlock
{
    //static dispatch_once_t onceToken;
    NSData *__block vcards = nil;
    __block BOOL accessGranted = NO;


    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    //dispatch_once(&onceToken, ^{
        // Semaphore is used for blocking until response
        dispatch_semaphore_signal(sema);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
    {
            accessGranted = granted;
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            if (addressBook) {
                CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
                CFRetain(contacts);
                vcards = (__bridge NSData *)ABPersonCreateVCardRepresentationWithPeople(contacts);
                CFRelease(contacts);
                contacts = nil;
            }
            
            
            if(vcards != nil){
                callbackBlock([vcards copy],accessGranted);
                return;
            }
            callbackBlock(nil,accessGranted);
        });
    //});
}

#pragma mark -


- (void)openApplicationSettings
{
    // UIApplicationOpenSettingsURLString is only availiable in iOS 8 and above.
    // The following code will crash if run on a prior version of iOS.  See the
    // check in -viewDidLoad.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+ (NSArray *)allContactsFromAddressBook
{
    static NSMutableArray *contacts = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        CFErrorRef *error = nil;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        
        __block BOOL accessGranted = NO;
        
        // Semaphore is used for blocking until response
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        
        if (accessGranted)
        {
            NSArray *allPeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
            contacts = [NSMutableArray arrayWithCapacity:allPeople.count];
            
            for (id person in allPeople) {
                @autoreleasepool {
                    AFContact *contact = [AFContact new];
                    
                    // Get the name of the contact
                    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonFirstNameProperty) ?: @"";
                    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonLastNameProperty) ?: @"";
                    contact.contactFirstName = firstName;
                    contact.contactLastName = lastName;
                    if(firstName != nil && firstName.length > 0){
                        contact.initials = [firstName substringWithRange:NSMakeRange(0, 1)];
                    }
                    
                    if(lastName != nil && lastName.length > 0){
                        if(contact.initials == nil || contact.initials.length == 0){
                            contact.initials = [lastName substringWithRange:NSMakeRange(0, 1)];
                        }
                        else{
                            contact.initials = [contact.initials stringByAppendingString:[lastName substringWithRange:NSMakeRange(0, 1)]];
                        }
                    }
                    if(contact.initials){
                        contact.initials = [contact.initials uppercaseString];
                    }
                    contact.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                    
                    // Get the photo of the contact
                    CFDataRef imageData = ABPersonCopyImageData((__bridge ABRecordRef)(person));
                    UIImage *image = [UIImage imageWithData:(__bridge NSData *)imageData];
                    if (imageData) {
                        CFRelease(imageData);
                    }
                    contact.photo = image;
                    
                    // Get all phone numbers of the contact
                    ABMultiValueRef phoneNumbers = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty);
                    
                    // If the contact has multiple phone numbers, iterate on each of them
                    NSInteger phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
                    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:phoneNumberCount];
                    for (int i = 0; i < phoneNumberCount; i++) {
                        NSString *phoneNumberFromAB = [(__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i) unformattedPhoneNumber];
                        [tempArray addObject:phoneNumberFromAB];
                    }
                    CFRelease(phoneNumbers);
                    contact.numbers = tempArray;
                    
                    // Get all email addresses of the contact
                    ABMultiValueRef emailAddresses = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonEmailProperty);
                    
                    // If the contact has multiple email addresses, iterate on each of them
                    NSInteger emailAddressCount = ABMultiValueGetCount(emailAddresses);
                    NSMutableArray *emailArray = [NSMutableArray arrayWithCapacity:emailAddressCount];
                    for (int i = 0; i < emailAddressCount; i++) {
                        NSString *emailAddressFromAB = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailAddresses, i);
                        [emailArray addObject:emailAddressFromAB];
                    }
                    CFRelease(emailAddresses);
                    contact.emails = emailArray;
                    
                    [contacts addObject:contact];
                }
            }
        }
        
        
        // Ensure there is no crash when this is released.
        if(addressBook)
        {
            CFRelease(addressBook);
        }
        
        
    });
    
    return contacts;
}




/*
+ (AFContact *)findContactWithPhoneNumber:(NSString *)phoneNumber
{
    NSArray *contacts = [AFAddressBookManager allContactsFromAddressBook];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numbers contains %@", phoneNumber];
    NSArray *filteredArray = [contacts filteredArrayUsingPredicate:predicate];
    
    AFContact *matchedContact = [filteredArray lastObject];
    return matchedContact;
}

+ (AFContact *)findContactWithEmailAddress:(NSString *)emailAddress
{
    NSArray *contacts = [AFAddressBookManager allContactsFromAddressBook];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emails contains %@", emailAddress];
    NSArray *filteredArray = [contacts filteredArrayUsingPredicate:predicate];
    
    AFContact *matchedContact = [filteredArray lastObject];
    return matchedContact;
}

+ (NSString *)nameForContactWithPhoneNumber:(NSString *)phoneNumber
{
    return [AFAddressBookManager findContactWithPhoneNumber:phoneNumber].name;
}

+ (UIImage *)photoForContactWithPhoneNumber:(NSString *)phoneNumber
{
    return [AFAddressBookManager findContactWithPhoneNumber:phoneNumber].photo;
}

+ (NSString *)nameForContactWithEmailAddress:(NSString *)emailAddress
{
    return [AFAddressBookManager findContactWithEmailAddress:emailAddress].name;
}

+ (UIImage *)photoForContactWithEmailAddress:(NSString *)emailAddress
{
    return [AFAddressBookManager findContactWithEmailAddress:emailAddress].photo;
}
*/

@end
