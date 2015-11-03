//
//  MsgInputView.m
//  kiwi-chat
//
//  Created by mconintet on 10/13/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "MsgInputView.h"
#import "macro.h"

#define MIV_BORDER_TOP_WIDTH 1
#define MIV_BORDER_TOP_COLOR 0xBDBDBD
#define MIV_BACKGROUND_COLOR 0xF6F6F6

#define MIV_PADDING_TOP 8
#define MIV_PADDING_BOTTOM 8
#define MIV_PADDING_LEFT 8
#define MIV_PADDING_RIGHT 8

#define MIV_BUTTON_TEXT_COLOR 0x7B7B81
#define MIV_BUTTON_TEXT_COLOR_HAS_INPUT 0x0A60FE
#define MIV_BUTTON_PADDING_LEFT 10
#define MIV_BUTTON_PADDING_RIGHT 10

#define MIV_INPUT_FONT_SIZE 15
#define MIV_BUTTON_FONT_SIZE 16

@interface MsgInputView ()
@property (nonatomic, strong) UIVisualEffectView* visualEfView;
@end

@implementation MsgInputView

- (instancetype)initWithFrame:(CGRect)frame placeholder:(NSString*)placeholder
{
    self = [super initWithFrame:frame];
    if (self) {
        _visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [self addSubview:_visualEfView];

        _button = ({
            UIButton* btn = [[UIButton alloc] init];
            [btn setTitle:@"Send" forState:UIControlStateNormal];
            [btn setTitleColor:UICOLOR_FROM_RGB(MIV_BUTTON_TEXT_COLOR) forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:MIV_BUTTON_FONT_SIZE]];
            [btn setContentEdgeInsets:UIEdgeInsetsMake(0, MIV_BUTTON_PADDING_LEFT, 0, MIV_BUTTON_PADDING_RIGHT)];
            [btn sizeToFit];
            btn;
        });

        _textView = ({
            CGRect frame = self.frame;
            CGFloat width = frame.size.width - MIV_PADDING_LEFT - _button.frame.size.width;
            MOITextView* tv = [[MOITextView alloc] initWithFont:[UIFont systemFontOfSize:MIV_INPUT_FONT_SIZE]
                                                        padding:UIEdgeInsetsZero
                                                    placeholder:@"Text Message"
                                                          width:width
                                                      maxHeight:self.bounds.size.height * 0.35];

            frame = tv.frame;
            frame.origin.x = MIV_PADDING_LEFT;
            frame.origin.y = MIV_PADDING_TOP;
            tv.frame = frame;
            tv;
        });

        _textView.moiTextViewDelegate = self;

        CGRect frame = self.frame;
        frame = _button.frame;
        frame.origin.x = MIV_PADDING_LEFT + _textView.frame.size.width;
        frame.origin.y = 0;
        frame.size.height = _textView.frame.size.height + MIV_PADDING_TOP + MIV_PADDING_BOTTOM;
        _button.frame = frame;
        DLOG_CGRECT(_button.frame, _button.frame);

        [self addSubview:_textView];
        [self addSubview:_button];

        self.backgroundColor = UICOLOR_FROM_RGBA(MIV_BACKGROUND_COLOR, 0.8);
        self.opaque = NO;

        CALayer* borderTop = [CALayer layer];
        borderTop.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
        borderTop.backgroundColor = [UICOLOR_FROM_RGB(MIV_BORDER_TOP_COLOR) CGColor];
        [self.layer addSublayer:borderTop];

        frame = self.frame;
        CGFloat initHeight = _textView.frame.size.height + MIV_PADDING_TOP + MIV_PADDING_BOTTOM;
        DLOG(@"%f", initHeight);
        frame.origin.x = 0;
        frame.origin.y = frame.size.height - initHeight;
        frame.size.height = initHeight;
        self.frame = frame;

        frame = _visualEfView.frame;
        frame.size = self.frame.size;
        _visualEfView.frame = frame;
        _visualEfView.alpha = 1.0;

        DLOG_CGRECT(frame, frame);
    }
    return self;
}

+ (CGFloat)calcHeightWithText:(NSString*)text
                         font:(UIFont*)font
                      padding:(UIEdgeInsets)padding
                        width:(CGFloat)width
{
    CGFloat height = [MOITextView calcHeightWithText:text
                                                font:[UIFont systemFontOfSize:MIV_INPUT_FONT_SIZE]
                                             padding:UIEdgeInsetsZero
                                               width:width];
    return height + MIV_PADDING_TOP + MIV_PADDING_BOTTOM;
}

- (NSString*)text
{
    return self.textView.text;
}

#pragma mark MOITextViewDelegate
- (void)didChangeHeight:(CGFloat)height
               textView:(MOITextView*)textView
                 offset:(CGFloat)offset
{
    CGRect frame = self.frame;
    height += MIV_PADDING_TOP + MIV_PADDING_BOTTOM;
    frame.size.height = height;
    self.frame = frame;

    frame = _button.frame;
    frame.size.height = height;
    _button.frame = frame;

    frame = self.frame;
    frame.origin.y -= offset;
    self.frame = frame;

    frame = _visualEfView.frame;
    frame.size = self.frame.size;
    _visualEfView.frame = frame;

    [self.msgInputViewDelegate didHeightChange:height
                                  msgInputView:self
                                        offset:offset];
}

- (void)textViewDidChange:(UITextView*)textView
{
    if ([textView.text isEqualToString:@""]) {
        [self.button setTitleColor:UICOLOR_FROM_RGB(MIV_BUTTON_TEXT_COLOR)
                          forState:UIControlStateNormal];
    }
    else {
        [self.button setTitleColor:UICOLOR_FROM_RGB(MIV_BUTTON_TEXT_COLOR_HAS_INPUT)
                          forState:UIControlStateNormal];
    }
}

@end
