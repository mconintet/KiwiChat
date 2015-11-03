//
//  UIButton+SetBackgroundColor.h
//  Chat
//
//  Created by mconintet on 9/2/15.
//  Copyright (c) 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageWithColor.h"

@interface UIButton (UIButtonSetBackground)
- (void)setBackgroundColor:(UIColor*)color forState:(UIControlState)state;
@end
