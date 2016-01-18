//
//  OuterShadowView.m
//  Car Sales
//
//  Created by Adam on 5/20/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "OuterShadowView.h"

@implementation OuterShadowView

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    float cornerRadius = 1;
    float shadowRadius = self.tag;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef innerPath = CGPathCreateMutable();

    CGRect innerRect = CGRectInset(bounds, shadowRadius, shadowRadius);
    
    CGPathMoveToPoint(innerPath, NULL, innerRect.origin.x, innerRect.origin.y + cornerRadius);
    CGPathAddArc(innerPath, NULL,  innerRect.origin.x + cornerRadius, innerRect.origin.y + cornerRadius, cornerRadius, -M_PI, -M_PI_2, 0);
    CGPathAddLineToPoint(innerPath, NULL, innerRect.origin.x + innerRect.size.width - cornerRadius, innerRect.origin.y);
    CGPathAddArc(innerPath, NULL, innerRect.origin.x + innerRect.size.width - cornerRadius, innerRect.origin.y + cornerRadius, cornerRadius, -M_PI_2, 0, 0);
    CGPathAddLineToPoint(innerPath, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height - cornerRadius);
    CGPathAddArc(innerPath, NULL,  innerRect.origin.x + innerRect.size.width - cornerRadius, innerRect.origin.y + innerRect.size.height - cornerRadius, cornerRadius, 0, M_PI_2, 0);
    CGPathAddLineToPoint(innerPath, NULL, innerRect.origin.x + cornerRadius, innerRect.origin.y + innerRect.size.height);
    CGPathAddArc(innerPath, NULL,  innerRect.origin.x + cornerRadius, innerRect.origin.y + innerRect.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, 0);
    CGPathCloseSubpath(innerPath);
    
    CGContextAddPath(context, innerPath);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), shadowRadius, [[UIColor blackColor] CGColor]);
    CGContextFillPath(context);
    
    CGContextAddPath(context, innerPath);
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextStrokePath(context);
    
    CGContextAddPath(context, innerPath);
    CGContextClip(context);
    
    if (self.image) {
        [self.image drawInRect:innerRect];
    }

    CGPathRelease(innerPath);
}

@end
