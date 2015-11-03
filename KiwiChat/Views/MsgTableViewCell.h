//
//  MsgTableViewCell.h
//  kiwi-chat
//
//  Created by mconintet on 10/13/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MsgTableViewCellContentType) {
    MsgTableViewCellContentTypeText = 0,
    MsgTableViewCellContentTypeImage,
    MsgTableViewCellContentTypeDate
};

typedef NS_ENUM(NSInteger, MsgTableViewCellOwnershipType) {
    MsgTableViewCellOwnershipTypeMe = 0,
    MsgTableViewCellOwnershipTypeOther
};

@interface MsgTableViewCell : UITableViewCell
@property (nonatomic, assign) NSInteger ownershipType;
@property (nonatomic, assign) NSInteger contentType;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) UIImage* image;

- (void)setText:(NSString*)text
           date:(NSDate*)date
  ownershipType:(MsgTableViewCellOwnershipType)ownershipType;

// set cell content type to be MsgTableViewCellContentTypeDate automatically
- (void)setDate:(NSDate*)date;

+ (CGFloat)calcHeightWithText:(NSString*)text;
+ (CGFloat)calcHeightWithDate;
@end
