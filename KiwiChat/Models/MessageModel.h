//
//  MessageModel.h
//  kiwi-chat
//
//  Created by mconintet on 10/17/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "Model.h"

#define MessageModelIOType_In ([NSNumber numberWithInteger:0])
#define MessageModelIOType_Out ([NSNumber numberWithInteger:1])

#define MessageModelType_Text ([NSNumber numberWithInteger:0])
#define MessageModelType_Image ([NSNumber numberWithInteger:1])

@interface MessageModel : Model

@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSNumber* in_out;
@property (nonatomic, strong) NSNumber* to;
@property (nonatomic, strong) NSNumber* from;
@property (nonatomic, strong) NSNumber* type;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSData* data;
@property (nonatomic, strong) NSNumber* add_time;
@property (nonatomic, strong) NSNumber* success;

@end
