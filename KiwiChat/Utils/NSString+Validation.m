//
//  NSString+Validation.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

- (NSString*)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isEmpty
{
    return [self isEqualToString:@""];
}

- (BOOL)isNotEmpty
{
    return ![self isEqualToString:@""];
}

- (BOOL)isEmail
{
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    return match.range.location != NSNotFound;
}

- (BOOL)isDigits
{
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    return match.range.location != NSNotFound;
}

- (BOOL)isURL
{
    NSURL* url = [NSURL URLWithString:self];
    return url != nil;
}

@end
