//
//  BuddyModel.h
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/30/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface BuddyModel : Model
@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSData* avatar;
@property (nonatomic, strong) NSNumber* network;

+ (BuddyModel*)loadByUID:(NSNumber*)uid;

- (UIImage*)getAvatarAsUIImage;
- (void)setAvatarByBase64:(NSString*)encode;

@end
