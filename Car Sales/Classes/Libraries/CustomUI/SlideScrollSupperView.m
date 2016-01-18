//
//  SlideScrollSupperView.m
//  Car Sales
//
//  Created by Adam on 5/20/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "SlideScrollSupperView.h"

@implementation SlideScrollSupperView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.subviews lastObject];
}

@end
