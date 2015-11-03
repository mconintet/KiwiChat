//
//  UserModel.h
//  KiwiChat
//
//  Created by mconintet on 10/27/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "Model.h"
#import "BuddyModel.h"

@interface UserModel : Model
@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSData* avatar;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSNumber* is_current;

+ (UserModel*)getCurrent;

- (NSArray*)getBuddies;
- (void)setLoggedIn;

- (UIImage*)getAvatarAsUIImage;
- (void)setAvatarByBase64:(NSString*)encode;

@end
