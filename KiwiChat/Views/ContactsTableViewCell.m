//
//  ContactsTableViewCell.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "ContactsTableViewCell.h"
#import "macro.h"
#import "font_icon.h"

#define CTVC_NICKNAME_FONT_SIZE 13
#define CTVC_LAST_MESSAGE_FONT_SIZE 12
#define CTVC_LAST_MESSAGE_TIME_FONT_SIZE 10

@implementation ContactsTableViewCell

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
            imageView.layer.borderWidth = 0;
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

        _onlineStateLabel = ({
            UILabel* label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:CTVC_LAST_MESSAGE_FONT_SIZE];
            label.textColor = UICOLOR_FROM_RGB(0x666666);
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:label];
            label;
        });

        _networkStateLabel = ({
            UILabel* label = [[UILabel alloc] init];
            label.font = [UIFont fontWithName:FONT_NAME size:12];
            label.textColor = UICOLOR_FROM_RGB(0xA0A0A0);
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
        constraintsWithVisualFormat:@"H:|-10-[avatar(40)]-10-[nickname]-(>=10)-[network]-10-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImageView,
                                  @"nickname" : _nicknameLabel,
                                  @"network" : _networkStateLabel
                              }];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-10-[avatar(40)]-10-[online]-(>=10)-[network]-10-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImageView,
                                  @"online" : _onlineStateLabel,
                                  @"network" : _networkStateLabel
                              }];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|[nickname][online]-3-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"nickname" : _nicknameLabel,
                                  @"online" : _onlineStateLabel,
                              }];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-3-[network]"
                            options:0
                            metrics:nil
                              views:@{
                                  @"network" : _networkStateLabel
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

- (void)setOnline:(BOOL)isOnline
{
    NSString* online = isOnline ? @"[online]" : @"[offline]";
    _onlineStateLabel.text = online;
    if (!isOnline) {
        _networkStateLabel.text = @"";
    }
    [self setNeedsUpdateConstraints];
}

- (void)setNetworkState:(MOINetworkStateCode)state
{
    DLOG(@"MOINetworkStateCode: %lu", (unsigned long)state);
    switch (state) {
    case MOINetworkStateCodeWiFi:
        _networkStateLabel.text = FONT_NSSTRING(FONT_ICON_WIFI);
        [self setOnline:YES];
        break;
    case MOINetworkStateCode4G:
        _networkStateLabel.text = @"4G";
        [self setOnline:YES];
        break;
    case MOINetworkStateCode3G:
        _networkStateLabel.text = @"3G";
        [self setOnline:YES];
        break;
    case MOINetworkStateCode2G:
        _networkStateLabel.text = @"2G";
        [self setOnline:YES];
        break;
    case MOINetworkStateCodeNone:
        _networkStateLabel.text = @"";
        [self setOnline:NO];
        break;
    default:
        break;
    }
}

+ (CGFloat)height
{
    // padding top + avatar height + padding bottom
    return 3 + 40 + 3;
}

@end
