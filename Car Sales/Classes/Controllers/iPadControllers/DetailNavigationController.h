//
//  DetailNavigationController.h
//  Car Sales
//
//  Created by Adam on 5/23/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultsVCPA.h"
#import "DetailsVCPA.h"

@interface DetailNavigationController : UINavigationController <UISplitViewControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *masterButtonItem;
@property (nonatomic, strong) UIBarButtonItem *masterBackButton;

- (id)init_;
- (void)showResultsVCStyleGrid;
- (void)showDetailsVC;

- (void)dismissPopover;
- (void)showPopover;

+ (DetailNavigationController *)shared;

@end
