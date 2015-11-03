//
//  UserBuddyModel.m
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/30/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "UserBuddyModel.h"
#import "macro.h"

@implementation UserBuddyModel

+ (NSString*)tableName
{
    return @"user_buddy";
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
        @"buddyID",
    ];
}

+ (UserBuddyModel*)loadByUID:(NSNumber*)uid buddyID:(NSNumber*)buddyID
{
    S3ODBHandler* dbh = [[self class] newDBHandler];
    NSString* select = [S3ODBHandler selectStrWithColumns:nil tableName:[[self class] tableName]];
    NSString* where = [S3ODBHandler whereStrWithConditions:@[ @"uid", @"buddyID" ]];
    NSString* sql = [NSString stringWithFormat:@"%@%@", select, where];

    DLOG(@"sql: %@", sql);

    S3OStatement* stmt = [dbh newStmtWithString:sql];
    [stmt bindParamWithNameDict:@{
        @":uid" : uid,
        @":buddyID" : buddyID
    }];

    UserBuddyModel* ret = [[UserBuddyModel alloc] init];
    [stmt fetchRowToObj:ret];
    ret.isChanged = false;

    [stmt finalize];
    [dbh close];
    return ret;
}

@end
