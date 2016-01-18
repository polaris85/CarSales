//
//  SortVCPA.h
//  Car Sales
//
//  Created by TienLP on 6/29/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "MenuBarViewController.h"
#import "SortVC.h"

@protocol SortVCPADelegate <NSObject>

- (void)didChangeSortWithType:(SortType)type;

@end

@interface SortVCPA : MenuBarViewController

@property (nonatomic, weak) UIPopoverController *popover;
@property (nonatomic, weak) id<SortVCPADelegate> delegate;

@end
