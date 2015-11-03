//
//  macro.h
//  kiwi-chat
//
//  Created by mconintet on 10/13/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#ifndef macro_h
#define macro_h

#import "AppDelegate.h"

#define UICOLOR_FROM_RGB(rgb)                              \
    [UIColor colorWithRed:((rgb & 0xFF0000) >> 16) / 255.0 \
                    green:((rgb & 0x00FF00) >> 8) / 255.0  \
                     blue:(rgb & 0x0000FF) / 255.0         \
                    alpha:1.0]

#define UICOLOR_FROM_RGBA(rgb, a)                          \
    [UIColor colorWithRed:((rgb & 0xFF0000) >> 16) / 255.0 \
                    green:((rgb & 0x00FF00) >> 8) / 255.0  \
                     blue:(rgb & 0x0000FF) / 255.0         \
                    alpha:a]

#define UICOLOR_TO_HEX(uicolor)                                            \
    ((((int)(CGColorGetComponents([uicolor CGColor])[0] * 255)) << 16)     \
        | (((int)(CGColorGetComponents([uicolor CGColor])[1] * 255)) << 8) \
        | ((int)(CGColorGetComponents([uicolor CGColor])[2] * 255)))

#ifdef DEBUG
#define DLOG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLOG(...)
#endif

#define DLOG_CGRECT(tag, rect)                                                   \
    DLOG(@"[" #tag "] origin.x: %f origin.y: %f size.width: %f size.height: %f", \
        rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

#define DLOG_CGPOINT(tag, point)            \
    DLOG(@"[" #tag "] point: %f point: %f", \
        point.x, point.y)

#define DLOG_UIEDGEINSETS(tag, edgeInsets)                    \
    DLOG(@"[" #tag "] top: %f left: %f bottom: %f right: %f", \
        edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right)

#define DLOG_CGSIZE(tag, size)               \
    DLOG(@"[" #tag "] width: %f height: %f", \
        size.width, size.height)

#define DLOG_NSData(d)                                                   \
    do {                                                                 \
        NSMutableString* log = [NSMutableString stringWithString:@"[ "]; \
        NSUInteger len = [d length];                                     \
        uint8_t* byts = (uint8_t*)[d bytes];                             \
        for (NSUInteger i = 0; i < len; i++) {                           \
            [log appendFormat:@"%x ", byts[i]];                          \
        }                                                                \
        [log appendString:@"]\n"];                                       \
        NSLog(@"%@", log);                                               \
    } while (0);

#define MAIN_SCREEN_BOUNDS ([[UIScreen mainScreen] bounds])

#define APP ([UIApplication sharedApplication])

#define APP_DELEGATE ((AppDelegate*)APP.delegate)

#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]
#define methodNotImplemented() mustOverride()

#define raiseException(EXP_TYPE, REASON) @throw [NSException exceptionWithName:EXP_TYPE reason:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, REASON] userInfo:nil];

#define SuppressPerformSelectorLeakWarning(Stuff)                                                                   \
    do {                                                                                                            \
        _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") Stuff; \
        _Pragma("clang diagnostic pop")                                                                             \
    } while (0)

#define CURRENT_NAV ((UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController)

#define DISMISS_KEYBOARD()                                                             \
    do {                                                                               \
        [APP sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]; \
    } while (0)

#endif /* macro_h */
