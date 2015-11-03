//
//  NSMutableDictionary+Path.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "NSMutableDictionary+Path.h"
#import "macro.h"

@implementation NSMutableDictionary (Path)

- (void)setObject:(id)object forPath:(NSString*)path
{
    NSArray* parts = [path componentsSeparatedByString:@"/"];
    NSInteger partCount = [parts count];
    if (partCount == 0) {
        return;
    }

    NSMutableDictionary* dict = self;
    if (partCount == 1) {
        [dict setObject:object forKey:path];
        return;
    }

    id node = nil;
    NSString* part = nil;
    for (int i = 0; i < partCount - 2; i++) {
        part = [parts objectAtIndex:i];
        node = [dict objectForKey:part];
        if (node == nil) {
            node = [[NSMutableDictionary alloc] init];
            [dict setObject:node forKey:part];
        }
        else if (![node isKindOfClass:[NSDictionary class]]) {
            DLOG(@"node is not NSDirectory of part %@", part);
            return;
        }
        dict = node;
    }
    [dict setObject:object forKey:[parts objectAtIndex:partCount - 1]];
}

- (id)objectForPath:(NSString*)path
{
    NSArray* parts = [path componentsSeparatedByString:@"/"];
    NSInteger partCount = [parts count];
    if (partCount == 0) {
        return self;
    }

    id node = nil;
    NSInteger i = 1;
    NSMutableDictionary* dict = self;
    for (NSString* part in parts) {
        node = [dict objectForKey:part];
        if (i != partCount) {
            if (![node isKindOfClass:[NSDictionary class]]) {
                DLOG(@"node is not NSDirectory of part %@", part);
                return nil;
            }
            dict = node;
        }
        i++;
    }

    return node;
}

@end

@implementation NSDictionary (Path)

- (id)objectForPath:(NSString*)path
{
    NSArray* parts = [path componentsSeparatedByString:@"/"];
    NSInteger partCount = [parts count];
    if (partCount == 0) {
        return self;
    }

    id node = nil;
    NSInteger i = 1;
    NSDictionary* dict = self;
    for (NSString* part in parts) {
        node = [dict objectForKey:part];
        if (i != partCount) {
            if (![node isKindOfClass:[NSDictionary class]]) {
                DLOG(@"node is not NSDirectory of part %@", part);
                return nil;
            }
            dict = node;
        }
        i++;
    }

    return node;
}

@end
