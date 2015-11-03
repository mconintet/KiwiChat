//
//  MessageModel.m
//  kiwi-chat
//
//  Created by mconintet on 10/17/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "MessageModel.h"
#import "macro.h"

@implementation MessageModel

+ (NSString*)tableName
{
    return @"message";
}

+ (NSString*)pk
{
    return @"_id";
}

+ (NSArray*)columns
{
    return @[
        @"_id",
        @"uid",
        @"in_out",
        @"to",
        @"from",
        @"type",
        @"data",
        @"text",
        @"add_time",
        @"success"
    ];
}

@end
