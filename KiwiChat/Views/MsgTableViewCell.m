//
//  MsgTableViewCell.m
//  kiwi-chat
//
//  Created by mconintet on 10/13/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "MsgTableViewCell.h"
#import "macro.h"

#define MTVC_PADDING_LEFT 5
#define MTVC_PADDING_RIGHT 5
#define MTVC_PADDING_TOP 10

#define MTVC_VIEW_MAX_WIDTH 0.5f

#define MTVC_TEXT_VIEW_FONT_SIZE 14

#define MTVC_TEXT_VIEW_ME_PADDING UIEdgeInsetsMake(0, 5, 0, 10)
#define MTVC_TEXT_VIEW_OTHER_PADDING UIEdgeInsetsMake(0, 10, 0, 5)

#define MTVC_ME_TEXT_COLOR 0xFFFFFF
#define MTVC_ME_BACKGROUND_COLOR 0x136EFD

#define MTVC_OTHER_TEXT_COLOR 0x0
#define MTVC_OTHER_BACKGROUND_COLOR 0xDFDEE5

#define MTVC_BORDER_WIDTH 1.0f
#define MTVC_BORDER_RADIUS 3.0f

#define MTVC_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define MTVC_MAX_CONTENT_WIDTH (0.65 * MTVC_SCREEN_WIDTH)

#define MTVC_DATE_MARGIN_LEFT 10

#define MTVC_DATE_FONT_SIZE 11
#define MTVC_DATE_TEXT_COLOR 0x8F8E93

@interface MsgTableViewCell ()
@property (strong, nonatomic) UITextView* textView;
@property (strong, nonatomic) UITextView* dateView;
@property (strong, nonatomic) UIImageView* bkgView;
@property (strong, nonatomic) UIActivityIndicatorView* sendingView;
@end

@implementation MsgTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _bkgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bkgView];

        _textView = ({
            UITextView* tv = [[UITextView alloc] init];
            tv.scrollEnabled = NO;
            tv.editable = NO;
            tv.backgroundColor = [UIColor clearColor];
            tv.contentInset = UIEdgeInsetsZero;
            tv.textAlignment = NSTextAlignmentCenter;
            tv;
        });
        [_bkgView addSubview:_textView];

        _dateView = ({
            UITextView* tv = [[UITextView alloc] init];
            tv.font = [UIFont systemFontOfSize:MTVC_DATE_FONT_SIZE];
            tv.textColor = UICOLOR_FROM_RGB(MTVC_DATE_TEXT_COLOR);
            tv.textAlignment = NSTextAlignmentCenter;
            tv.scrollEnabled = NO;
            tv.editable = NO;
            tv;
        });
        [self.contentView addSubview:_dateView];

        _sendingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

- (void)setText:(NSString*)text
           date:(NSDate*)date
  ownershipType:(MsgTableViewCellOwnershipType)ownershipType
{
    [_dateView setFrame:CGRectZero];

    _textView.text = text;
    _textView.font = [UIFont systemFontOfSize:MTVC_TEXT_VIEW_FONT_SIZE];

    CGSize textSize = [MsgTableViewCell calcSizeWithText:text];
    textSize.width = MAX(30, textSize.width);

    CGRect frame = _textView.frame;
    frame.size = textSize;
    _textView.frame = frame;

    _contentType = MsgTableViewCellContentTypeText;
    _ownershipType = ownershipType;

    if (_ownershipType == MsgTableViewCellOwnershipTypeMe) {
        UIImage* image = [[UIImage imageNamed:@"bubble_min_me.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 15, 15, 30) resizingMode:UIImageResizingModeStretch];
        _bkgView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_bkgView setTintColor:UICOLOR_FROM_RGB(MTVC_ME_BACKGROUND_COLOR)];

        UIEdgeInsets padding = MTVC_TEXT_VIEW_ME_PADDING;

        CGRect frame = _bkgView.frame;
        frame.size = CGSizeMake(textSize.width + padding.left + padding.right, textSize.height + padding.top + padding.bottom);

        frame.origin.x = self.contentView.bounds.size.width - MTVC_PADDING_RIGHT - frame.size.width;
        _bkgView.frame = frame;

        frame = _textView.frame;
        frame.origin.x = padding.left;
        _textView.frame = frame;

        _textView.textColor = UICOLOR_FROM_RGB(MTVC_ME_TEXT_COLOR);
    }
    else {
        UIImage* image = [[UIImage imageNamed:@"bubble_min_other.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 30, 15, 15) resizingMode:UIImageResizingModeStretch];
        _bkgView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_bkgView setTintColor:UICOLOR_FROM_RGB(MTVC_OTHER_BACKGROUND_COLOR)];

        UIEdgeInsets padding = MTVC_TEXT_VIEW_OTHER_PADDING;

        CGRect frame = _bkgView.frame;
        frame.size = CGSizeMake(textSize.width + padding.left + padding.right, textSize.height + padding.top + padding.bottom);

        frame.origin.x = MTVC_PADDING_LEFT;
        _bkgView.frame = frame;

        frame = _textView.frame;
        frame.origin.x = padding.left;
        _textView.frame = frame;

        _textView.textColor = UICOLOR_FROM_RGB(MTVC_OTHER_TEXT_COLOR);
    }
}

- (void)setDate:(NSDate*)date
{
    [_bkgView setFrame:CGRectZero];
    [_textView setFrame:CGRectZero];

    _contentType = MsgTableViewCellContentTypeDate;

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString* dateStr = [formatter stringFromDate:date];

    _dateView.text = dateStr;
    CGRect frame = _dateView.frame;
    frame.size.width = MTVC_SCREEN_WIDTH;
    frame.size.height = [_dateView sizeThatFits:CGSizeMake(MTVC_SCREEN_WIDTH, MAXFLOAT)].height;
    _dateView.frame = frame;
}

+ (CGFloat)calcHeightWithDate
{
    static UITextView* calcTextView = nil;
    if (calcTextView == nil) {
        calcTextView = [[UITextView alloc] init];
        calcTextView.font = [UIFont systemFontOfSize:MTVC_DATE_FONT_SIZE];
        calcTextView.contentInset = UIEdgeInsetsZero;
    }

    calcTextView.text = @"DATE";
    return [calcTextView sizeThatFits:CGSizeMake(MTVC_MAX_CONTENT_WIDTH, MAXFLOAT)].height + MTVC_PADDING_TOP;
}

+ (CGSize)calcSizeWithText:(NSString*)text
{
    static UITextView* calcTextView = nil;
    if (calcTextView == nil) {
        calcTextView = [[UITextView alloc] init];
        calcTextView.font = [UIFont systemFontOfSize:MTVC_TEXT_VIEW_FONT_SIZE];
        calcTextView.contentInset = UIEdgeInsetsZero;
    }

    calcTextView.text = text;
    return [calcTextView sizeThatFits:CGSizeMake(MTVC_MAX_CONTENT_WIDTH, MAXFLOAT)];
}

+ (CGFloat)calcHeightWithText:(NSString*)text
{
    return [self calcSizeWithText:text].height + MTVC_PADDING_TOP;
}

@end
