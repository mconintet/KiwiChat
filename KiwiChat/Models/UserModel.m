//
//  UserModel.m
//  KiwiChat
//
//  Created by mconintet on 10/27/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "UserModel.h"
#import "macro.h"
#import "UserBuddyModel.h"
#import "BuddyModel.h"

@implementation UserModel

+ (NSString*)tableName
{
    return @"user";
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
        @"nickname",
        @"avatar",
        @"token",
        @"is_current"
    ];
}

+ (UserModel*)getCurrent
{
    UserModel* user = [[UserModel alloc] initWithWhereCondition:@"is_current=1" bindParams:nil];
    return user;
}

- (void)setLoggedIn
{
    S3ODBHandler* dbh = [[self class] newDBHandler];
    NSString* update = [S3ODBHandler updateStrWithColumns:@[ @"is_current" ] tableName:[[self class] tableName]];
    NSString* where = [S3ODBHandler whereNotStrWithConditions:@[ @"uid" ]];
    NSString* sql = [NSString stringWithFormat:@"%@%@", update, where];

    S3OStatement* stmt = [dbh newStmtWithString:sql];
    [stmt executeWithParams:@{
        @":uid" : self.uid,
        @":is_current" : [NSNumber numberWithInt:0]
    }];

    [stmt finalize];
    [dbh close];
}

- (NSArray*)getBuddies
{
    S3ODBHandler* dbh = [[self class] newDBHandler];

    NSString* B = [BuddyModel tableName];
    NSString* UB = [UserBuddyModel tableName];

    NSString* sql = @"SELECT B.* FROM %@ AS B JOIN %@ AS UB ON UB.buddyID=B.uid WHERE UB.uid=:uid";
    sql = [NSString stringWithFormat:sql, B, UB];
    DLOG("sql: %@", sql);

    S3OStatement* stmt = [dbh newStmtWithString:sql];
    [stmt bindParamWithName:@":uid" value:self.uid];

    NSArray* ret = [stmt newRawsWithClass:[BuddyModel class]
                              customSetup:^(id obj) {
                                  BuddyModel* b = (BuddyModel*)obj;
                                  b.isChanged = false;
                              }];

    [stmt finalize];
    [dbh close];
    return ret;
}

- (UIImage*)getAvatarAsUIImage
{
    if ([_avatar isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [UIImage imageWithData:_avatar];
}

- (void)setAvatarByBase64:(NSString*)encoded
{
    self.avatar = [[NSData alloc] initWithBase64EncodedString:encoded options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

@end
