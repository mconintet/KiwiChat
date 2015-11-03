//
//  ChatModel.h
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/31/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "Model.h"
#import "MessageModel.h"
#import "BuddyModel.h"

@interface ChatModel : Model
@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSNumber* buddyID;

+ (ChatModel*)loadByUID:uid buddyID:buddyID;
+ (NSArray*)loadArrayByUID:(NSNumber*)uid;

- (MessageModel*)getLastMessage;
- (BuddyModel*)getBuddy;

@end
