//
//  Label.m
//  Car Sales
//
//  Created by Adam on 5/20/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "NotHighlightedLabel.h"

@interface NotHighlightedLabel ()
{
    BOOL _didSet;
}

@end

@implementation NotHighlightedLabel

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.editing) {
        return;
    }
    [super setBackgroundColor:backgroundColor];
}

@end
