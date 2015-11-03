//
//  UIImage+ImageWithColor.h
//  Chat
//
//  Created by mconintet on 9/3/15.
//  Copyright (c) 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageWithColor)
+ (UIImage*)imageWithColor:(UIColor*)color;
+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
