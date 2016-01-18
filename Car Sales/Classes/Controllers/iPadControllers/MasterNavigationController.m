//
//  MasterNavigationController.m
//  Car Sales
//
//  Created by Adam on 5/24/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "MasterNavigationController.h"
#import "DetailNavigationController.h"
#import "SearchVC.h"

@interface MasterNavigationController () <UINavigationControllerDelegate>

@end

@implementation MasterNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[SearchVC class]]) {
        [[DetailNavigationController shared] showResultsVCStyleGrid];
    }
}

@end
