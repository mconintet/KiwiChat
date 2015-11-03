//
//  MessageRouter.h
//  KiwiChat
//
//  Created by mconintet on 10/27/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWSConnection.h"

KWSMessage* makeKWSMessage(NSDictionary* action);

typedef NS_ENUM(NSUInteger, MR_RESP_ERR_CODE) {
    MR_RESP_ERR_CODE_NONE = 0,
    MR_RESP_ERR_CODE_UNREACHABLE = 1001,
    MR_RESP_ERR_CODE_INVALID_TOKEN = 1006
};

@interface MessageHandler : NSObject

@property (nonatomic, strong) NSString* pattern;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;

- (instancetype)initWithPattern:(NSString*)pattern Target:(id)target action:(SEL)action;
- (void)performMessage:(NSDictionary*)msg;

@end

@interface MessageRouter : NSObject

+ (void)addPattern:(NSString*)pattern target:(id)target action:(SEL)action;
+ (void)routeMessage:(KWSMessage*)message conn:(KWSConnection*)conn;

@end
