//
//  UIView+Snapshot.m
//  Chat
//
//  Created by mconintet on 9/4/15.
//  Copyright (c) 2015 mconintet. All rights reserved.
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

- (UIImage*)snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
