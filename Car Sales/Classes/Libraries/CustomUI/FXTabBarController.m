//
//  FXTabBarController.m
//  Car Sales
//
//  Created by TienLP on 7/3/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "FXTabBarController.h"
#import "FXNavigationController.h"
#import "ZoomImageScrollVC.h"

@interface FXTabBarController ()

@end

@implementation FXTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

@end
