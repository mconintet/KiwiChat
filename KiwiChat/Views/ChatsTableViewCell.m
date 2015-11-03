//
//  ChatsTableViewCell.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "ChatsTableViewCell.h"
#import "macro.h"
#import "font_icon.h"

#define CTVC_NICKNAME_FONT_SIZE 13
#define CTVC_LAST_MESSAGE_FONT_SIZE 12
#define CTVC_LAST_MESSAGE_TIME_FONT_SIZE 10

@implementation ChatsTableViewCell

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UICOLOR_FROM_RGB(0xFBFBFB);

        _avatarImageView = ({
            UIImageView* imageView = [[UIImageView alloc]
                initWithFrame:CGRectMake(0, 0, 40, 40)];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 40 * 0.5;
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:imageView];
            imageView;
        });

        _nicknameLabel = ({
            UILabel* label = [[UILabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:CTVC_NICKNAME_FONT_SIZE];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:label];
            label;
        });

        _lastMessageLabel = ({
            UILabel* label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:CTVC_LAST_MESSAGE_FONT_SIZE];
            label.textColor = UICOLOR_FROM_RGB(0x666666);
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:label];
            label;
        });

        _lastMessageTimeLabel = ({
            UILabel* label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:CTVC_LAST_MESSAGE_TIME_FONT_SIZE];
            label.textColor = UICOLOR_FROM_RGB(0x999999);
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:label];
            label;
        });

        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews
{
    CALayer* bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = UICOLOR_FROM_RGB(0xBCBAC1).CGColor;
    [self.layer addSublayer:bottomBorder];

    CALayer* topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0, self.frame.size.width, 0.5f);
    topBorder.backgroundColor = UICOLOR_FROM_RGB(0xBCBAC1).CGColor;
    [self.layer addSublayer:topBorder];

    [super layoutSubviews];
}

- (void)setupConstraints
{
    NSArray* constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-10-[avatar(40)]-10-[nickname]-(>=10)-[time]-10-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImageView,
                                  @"nickname" : _nicknameLabel,
                                  @"time" : _lastMessageTimeLabel
                              }];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-10-[avatar(40)]-10-[message]-(>=10)-[time]-10-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImageView,
                                  @"message" : _lastMessageLabel,
                                  @"time" : _lastMessageTimeLabel
                              }];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|[nickname][message]-3-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"nickname" : _nicknameLabel,
                                  @"message" : _lastMessageLabel,
                              }];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-3-[time]"
                            options:0
                            metrics:nil
                              views:@{
                                  @"time" : _lastMessageTimeLabel
                              }];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-3-[avatar(40)]-3-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImageView
                              }];
    [self addConstraints:constraints];
}

+ (CGFloat)height
{
    // padding top + avatar height + padding bottom
    return 3 + 40 + 3;
}
@end
