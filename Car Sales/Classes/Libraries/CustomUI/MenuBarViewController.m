//
//  MenuBarViewController.m
//  Car Sales
//
//  Created by Adam on 5/22/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "MenuBarViewController.h"
#import "AppDelegate.h"

@interface MenuBarViewController ()

@end

@implementation MenuBarViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = BACK;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MENU style:UIBarButtonItemStyleBordered target:self action:@selector(showHideMenuBar)];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[AppDelegate shared] setMenuBarHidden:YES];
    [super viewWillDisappear:animated];
}

- (void)showHideMenuBar
{
//    [[AppDelegate shared] showHideMenuBar];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
