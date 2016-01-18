//
//  InnerShadowView.m
//  Car Sales
//
//  Created by Adam on 5/20/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "InnerShadowView.h"

@implementation InnerShadowView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef innerPath = CGPathCreateMutable();
    CGPathAddRect(innerPath, NULL, self.bounds);
    
    CGContextAddPath(context, innerPath);
    
    CGMutablePathRef outerPath = CGPathCreateMutable();
    CGPathAddRect(outerPath, NULL, CGRectInset(self.bounds, -5, -5));
    CGPathAddPath(outerPath, NULL, innerPath);
    CGPathCloseSubpath(outerPath);
    
    CGContextAddPath(context, innerPath);
    CGContextClip(context);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 5.0f, [[UIColor blackColor] CGColor]);
    
    CGContextAddPath(context, outerPath);
    CGContextEOFillPath(context);
    
    CGPathRelease(innerPath);
    CGPathRelease(outerPath);
}

@end
