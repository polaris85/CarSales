//
//  DetailsHeaderView.m
//  Car Sales
//
//  Created by TienLP on 7/1/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "DetailsHeaderView.h"

@interface DetailsHeaderView ()

@end

@implementation DetailsHeaderView

+ (id)customView
{
    DetailsHeaderView *customView = [[[NSBundle mainBundle] loadNibNamed:@"DetailsHeaderView" owner:nil options:nil] objectAtIndex:0];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[DetailsHeaderView class]])
        return customView;
    else
        return nil;
}

@end
