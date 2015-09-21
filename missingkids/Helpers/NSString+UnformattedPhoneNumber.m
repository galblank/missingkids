//
//  NSString+UnformattedPhoneNumber.m
//  re:group'd
//
//  Created by Gal Blank on 12/4/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import "NSString+UnformattedPhoneNumber.h"

@implementation NSString (UnformattedPhoneNumber)

- (NSString *)unformattedPhoneNumber
{
    NSCharacterSet *toExclude = [NSCharacterSet characterSetWithCharactersInString:@"/.,()-+ "];
    return [[self componentsSeparatedByCharactersInSet:toExclude] componentsJoinedByString:@""];
}

@end