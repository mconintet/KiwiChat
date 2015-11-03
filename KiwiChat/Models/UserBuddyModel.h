//
//  UserBuddyModel.h
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/30/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "Model.h"

@interface UserBuddyModel : Model
@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSNumber* buddyID;

+ (UserBuddyModel*)loadByUID:(NSNumber*)uid buddyID:(NSNumber*)buddyID;

@end
