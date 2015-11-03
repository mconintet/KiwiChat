//
//  ChatView.m
//  kiwi-chat
//
//  Created by mconintet on 10/14/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "ChatView.h"
#import "macro.h"

#define CV_PLACEHOLDER @"Text Message"

#define CV_TABLE_PADDING_TOP 10
#define CV_TABLE_PADDING_BOTTOM 10

@interface ChatView ()
@property (nonatomic, assign) CGPoint originCenter;
@property (nonatomic, assign) CGSize kbSize;
@property (nonatomic, assign) BOOL kbIsShow;
@end

@implementation ChatView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _msgInput = [[MsgInputView alloc] initWithFrame:self.bounds placeholder:CV_PLACEHOLDER];
        _msgInput.msgInputViewDelegate = self;

        [_msgInput.button addTarget:self
                             action:@selector(sendButtonClicked:)
                   forControlEvents:UIControlEventTouchUpInside];

        _msgTable = ({
            MsgTableView* tb = [[MsgTableView alloc] initWithFrame:self.bounds];
            tb.contentInset = UIEdgeInsetsMake(CV_TABLE_PADDING_TOP, 0, _msgInput.frame.size.height, 0);
            tb;
        });

        [self addSubview:_msgTable];
        [self addSubview:_msgInput];
        [self bringSubviewToFront:_msgInput];

        _originCenter = self.center;
        [self registerForKeyboardNotifications];
    }
    return self;
}

#pragma mark KeyboardNotifications
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGPoint point = self.originCenter;
    point.y -= self.kbSize.height;

    CGRect frame = _msgTable.frame;
    frame.size.height -= self.kbSize.height;
    frame.origin.y += self.kbSize.height;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];

    self.center = point;
    _msgTable.frame = frame;

    [UIView commitAnimations];

    self.kbIsShow = true;
    [self.msgTable scrollToBottom];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    if (self.kbIsShow) {
        CGPoint point = self.center;
        point.y += self.kbSize.height;

        CGRect frame = _msgTable.frame;
        frame.size.height += self.kbSize.height;
        frame.origin.y -= self.kbSize.height;

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];

        self.center = point;
        _msgTable.frame = frame;

        [UIView commitAnimations];

        self.kbIsShow = false;
    }
}

#pragma mark send button click handler
- (void)sendButtonClicked:(id)sender
{
    [self.delegate sendMsgButtonClicked:[self.msgInput text]];
}

#pragma mark MsgInputViewDelegate
- (void)didHeightChange:(CGFloat)height
           msgInputView:(MsgInputView*)view
                 offset:(CGFloat)offset
{
    UIEdgeInsets insets = _msgTable.contentInset;
    insets.bottom += offset;
    _msgTable.contentInset = insets;

    [_msgTable scrollToBottom];
}

@end
