//
//  ChatsTableViewCell.h
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatsTableViewCell : UITableViewCell
@property (strong, nonatomic) UIImageView* avatarImageView;
@property (strong, nonatomic) UILabel* nicknameLabel;
@property (strong, nonatomic) UILabel* lastMessageLabel;
@property (strong, nonatomic) UILabel* lastMessageTimeLabel;

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;
+ (CGFloat)height;
@end
