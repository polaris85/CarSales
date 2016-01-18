//
//  Toolbar.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "Toolbar.h"

@interface Toolbar ()
{
    IBOutletCollection(UIBarButtonItem) NSArray *_barButtonItems;
}

@end

@implementation Toolbar

- (id)load
{
    return [[[NSBundle mainBundle] loadNibNamed:@"Toolbar" owner:self options:nil] lastObject];
}

- (NSArray *)barButtonItems
{
    return [_barButtonItems sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
}

@end
