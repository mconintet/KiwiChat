//
//  UIButton+SetBackgroundColor.m
//  Chat
//
//  Created by mconintet on 9/2/15.
//  Copyright (c) 2015 mconintet. All rights reserved.
//

#import "UIButton+SetBackgroundColor.h"

@implementation UIButton (UIButtonSetBackground)

- (void)setBackgroundColor:(UIColor*)color forState:(UIControlState)state
{
    [self setBackgroundImage:[UIImage imageWithColor:color] forState:state];
}
@end
