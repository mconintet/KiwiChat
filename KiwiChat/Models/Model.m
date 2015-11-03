//
//  Model.m
//  kiwi-chat
//
//  Created by mconintet on 10/18/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "Model.h"
#import "macro.h"
#import "objc/runtime.h"

#define DB_FILE_NAME @"KiwiChat.sqlite"

@implementation Model

+ (NSString*)dbPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];

    NSString* destinationPath = [documentsDirectory stringByAppendingPathComponent:DB_FILE_NAME];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        return destinationPath;
    }

    NSString* sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_FILE_NAME];
    NSError* error;
    [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];

    if (error != nil) {
        raiseException(NSDestinationInvalidException, @"cannot copy db file");
    }
    return destinationPath;
}

+ (S3ODBHandler*)newDBHandler
{
    DLOG(@"open db: %@", [self dbPath]);
    return [[S3ODBHandler alloc] initWithDBFilePath:[self dbPath]];
}

- (BOOL)save
{
    return [self saveThen:^(UInt64 lastInsertId) {
        objc_property_t prop = class_getProperty([self class], "_id");
        if (prop != NULL) {
            [self setValue:[NSNumber numberWithLongLong:lastInsertId] forKey:@"_id"];
        }
    }];
}

- (BOOL)remove
{
    objc_property_t prop = class_getProperty([self class], "_id");
    if (prop != NULL) {
        S3ODBHandler* dbh = [[self class] newDBHandler];

        NSString* sql = @"DELETE FROM `%@` WHERE `_id`=:_id";
        sql = [NSString stringWithFormat:sql, [[self class] tableName]];
        DLOG(@"sql: %@", sql);

        S3OStatement* stmt = [dbh newStmtWithString:sql];
        return [stmt executeWithParams:@{ @":_id" : [self valueForKey:@"_id"] }];
    }
    else {
        DLOG(@"no property named '_id' of %@ for delete", [self class]);
        return false;
    }
}

@end
