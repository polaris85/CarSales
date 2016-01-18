//
//  MultiLineButton.m
//  Car Sales
//
//  Created by Adam on 5/16/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "MultiLineButton.h"

@implementation MultiLineButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImage *imageStateNormal = [self backgroundImageForState:UIControlStateNormal];
    [self setBackgroundImage:[imageStateNormal stretchableImageWithLeftCapWidth:imageStateNormal.size.width/2 topCapHeight:0] forState:UIControlStateNormal];
    
    UIImage *imageStateHighlighted = [self backgroundImageForState:UIControlStateHighlighted];
    [self setBackgroundImage:[imageStateHighlighted stretchableImageWithLeftCapWidth:imageStateHighlighted.size.width/2 topCapHeight:0] forState:UIControlStateHighlighted];
}

@end
