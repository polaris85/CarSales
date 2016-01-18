//
//  UIImage+UIColor.m
//  Car Sales
//
//  Created by Adam on 5/20/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "UIImage+UIColor.h"

@implementation UIImage (UIColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
