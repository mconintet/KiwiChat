//
//  MsgInputView.h
//  kiwi-chat
//
//  Created by mconintet on 10/13/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOITextView.h"

@class MsgInputView;

@protocol MsgInputViewDelegate <NSObject>
- (void)didHeightChange:(CGFloat)height
           msgInputView:(MsgInputView*)view
                 offset:(CGFloat)offset;
@end

@interface MsgInputView : UIView <MOITextViewDelegate>
@property (nonatomic, strong) MOITextView* textView;
@property (nonatomic, strong) UIButton* button;
@property (nonatomic, weak) id<MsgInputViewDelegate> msgInputViewDelegate;

+ (CGFloat)calcHeightWithText:(NSString*)text
                         font:(UIFont*)font
                      padding:(UIEdgeInsets)padding
                        width:(CGFloat)width;

// frame size must be equal to it's parent's frame size
- (instancetype)initWithFrame:(CGRect)frame placeholder:(NSString*)placeholder;

- (NSString*)text;
@end
