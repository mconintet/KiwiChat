//
//  ChatModel.m
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/31/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "ChatModel.h"
#import "macro.h"

@implementation ChatModel

+ (NSString*)tableName
{
    return @"chat";
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

+ (NSArray*)loadArrayByUID:(NSNumber*)uid
{
    S3ODBHandler* dbh = [[self class] newDBHandler];
    NSString* select = [S3ODBHandler selectStrWithColumns:nil tableName:[[self class] tableName]];
    NSString* where = [S3ODBHandler whereStrWithConditions:@[ @"uid" ]];
    NSString* sql = [NSString stringWithFormat:@"%@%@", select, where];

    DLOG(@"sql: %@", sql);

    S3OStatement* stmt = [dbh newStmtWithString:sql];
    [stmt bindParamWithNameDict:@{
        @":uid" : uid
    }];

    NSArray* ret = [stmt newRawsWithClass:[ChatModel class]
                              customSetup:^(id obj) {
                                  ChatModel* c = (ChatModel*)obj;
                                  c.isChanged = false;
                              }];

    [stmt finalize];
    [dbh close];
    return ret;
}

+ (ChatModel*)loadByUID:uid buddyID:buddyID
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

    ChatModel* ret = [[ChatModel alloc] init];
    [stmt fetchRowToObj:ret];

    [stmt finalize];
    [dbh close];
    return ret;
}

- (MessageModel*)getLastMessage
{
    S3ODBHandler* dbh = [[self class] newDBHandler];

    NSString* sql = @"SELECT * FROM `%@` \
    WHERE (`uid`=:uid AND `to`=:buddyID) OR (`uid`=:uid AND `from`=:buddyID ) \
    ORDER BY _id DESC LIMIT 1";

    sql = [NSString stringWithFormat:sql, [MessageModel tableName]];
    DLOG(@"sql: %@", sql);

    S3OStatement* stmt = [dbh newStmtWithString:sql];
    [stmt bindParamWithNameDict:@{
        @":uid" : self.uid,
        @":buddyID" : self.buddyID
    }];

    MessageModel* ret = [[MessageModel alloc] init];
    [stmt fetchRowToObj:ret];
    ret.isChanged = false;

    [stmt finalize];
    [dbh close];
    return ret;
}

- (BuddyModel*)getBuddy
{
    return [BuddyModel loadByUID:self.buddyID];
}

@end
