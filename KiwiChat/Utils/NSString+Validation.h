//
//  NSString+Validation.h
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

- (NSString*)trim;
- (BOOL)isEmpty;
- (BOOL)isNotEmpty;
- (BOOL)isURL;
- (BOOL)isEmail;
- (BOOL)isDigits;

@end
