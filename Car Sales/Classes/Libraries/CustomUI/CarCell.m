//
//  CarCell.m
//  Car Sales
//
//  Created by Adam on 5/20/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "CarCell.h"

@implementation CarCell

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    self.iconLb.editing = editing;
    self.moreLb.editing = editing;
    self.hotLb.editing = editing;
    [UIView animateWithDuration:0.3 animations:^{
        self.hotLb.alpha = editing ? 0 : 1;
    }];
    [super setEditing:editing animated:animated];
}

@end
