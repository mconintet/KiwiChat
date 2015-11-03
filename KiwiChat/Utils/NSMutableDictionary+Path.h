//
//  NSMutableDictionary+Path.h
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Path)
- (void)setObject:(id)anObject forPath:(NSString*)path;
- (id)objectForPath:(NSString*)path;
@end

@interface NSDictionary (Path)
- (id)objectForPath:(NSString*)path;
@end
