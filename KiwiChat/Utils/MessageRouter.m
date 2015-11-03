//
//  MessageRouter.m
//  KiwiChat
//
//  Created by mconintet on 10/27/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "MessageRouter.h"
#import "macro.h"

KWSMessage* makeKWSMessage(NSDictionary* action)
{
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:action
                                                       options:0
                                                         error:nil];

    DLOG(@"make action message: %@", [[NSString alloc] initWithBytes:[jsonData bytes]
                                                              length:[jsonData length]
                                                            encoding:NSUTF8StringEncoding]);

    KWSMessage* msg = [[KWSMessage alloc] init];
    msg.opcode = KWSOpcodeText;
    msg.data = [jsonData mutableCopy];
    return msg;
}

@implementation MessageHandler

- (instancetype)initWithPattern:(NSString*)pattern Target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        _pattern = pattern;
        _target = target;
        _action = action;
    }
    return self;
}

- (void)performMessage:(NSDictionary*)msg
{
    [_target performSelectorOnMainThread:_action withObject:msg waitUntilDone:NO];
}

@end

@implementation MessageRouter

+ (NSDictionary*)handlerMap
{
    static NSMutableDictionary* map = nil;
    if (map == nil) {
        map = [[NSMutableDictionary alloc] init];
    }
    return map;
};

+ (void)addPattern:(NSString*)pattern target:(id)target action:(SEL)action
{
    MessageHandler* handler = [[MessageHandler alloc] initWithPattern:pattern Target:target action:action];
    [[self handlerMap] setValue:handler forKey:pattern];
}

+ (void)routeMessage:(KWSMessage*)message conn:(KWSConnection*)conn
{
    NSError* error;
    NSDictionary* msg = [NSJSONSerialization JSONObjectWithData:message.data
                                                        options:kNilOptions
                                                          error:&error];
    NSString* action = [msg objectForKey:@"action"];
    DLOG(@"action: %@", action);
    if (action == nil) {
        return;
    }

    NSDictionary* map = [self handlerMap];
    id handler = [map objectForKey:action];
    if (handler == nil) {
        return;
    }

    [(MessageHandler*)handler performMessage:msg];
}

@end
