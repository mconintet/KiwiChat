//
//  ContactsTableViewCell.h
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOINetworkState.h"

@interface ContactsTableViewCell : UITableViewCell
@property (strong, nonatomic) UIImageView* avatarImageView;
@property (strong, nonatomic) UILabel* nicknameLabel;
@property (strong, nonatomic) UILabel* onlineStateLabel;
@property (strong, nonatomic) UILabel* networkStateLabel;

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

- (void)setOnline:(BOOL)isOnline;
- (void)setNetworkState:(MOINetworkStateCode)state;

+ (CGFloat)height;
@end
