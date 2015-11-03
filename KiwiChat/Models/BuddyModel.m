//
//  BuddyModel.m
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/30/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "BuddyModel.h"
#import "macro.h"

@implementation BuddyModel
+ (NSString*)tableName
{
    return @"buddy";
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
        @"network",
    ];
}

+ (BuddyModel*)loadByUID:(NSNumber*)uid
{
    S3ODBHandler* dbh = [[self class] newDBHandler];
    NSString* select = [S3ODBHandler selectStrWithColumns:nil tableName:[[self class] tableName]];
    NSString* where = [S3ODBHandler whereStrWithConditions:@[ @"uid" ]];
    NSString* sql = [NSString stringWithFormat:@"%@%@", select, where];

    S3OStatement* stmt = [dbh newStmtWithString:sql];
    [stmt bindParamWithName:@":uid" value:uid];

    BuddyModel* ret = [[BuddyModel alloc] init];
    [stmt fetchRowToObj:ret];
    ret.isChanged = false;

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
