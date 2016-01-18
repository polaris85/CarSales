//
//  DetailNavigationController.m
//  Car Sales
//
//  Created by Adam on 5/23/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "DetailNavigationController.h"
#import "Common.h"

static __weak DetailNavigationController *shared = nil;

@interface DetailNavigationController () <UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *popover;

@end

@implementation DetailNavigationController

+ (DetailNavigationController *)shared
{
    return shared;
}

- (id)init_
{
    ResultsVCPA *vc = [[ResultsVCPA alloc] init];
    self = [super initWithRootViewController:vc];
    if (self) {
        self.delegate = self;
        shared = self;
        
        UIButton *btBack =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btBack setImage:[UIImage imageNamed:@"btn_leftnav_mainview.png"] forState:UIControlStateNormal];
        [btBack addTarget:self action:@selector(backVC) forControlEvents:UIControlEventTouchUpInside];
        [btBack setFrame:CGRectMake(0, 0, 61, 30)];
        
        self.masterBackButton = [[UIBarButtonItem alloc] initWithCustomView:btBack];
        self.navigationItem.backBarButtonItem = nil;
    }
    return self;
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


#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.viewControllers count] > 1) {
        [viewController.navigationItem setLeftBarButtonItem:self.masterBackButton animated:NO];
    } else {
        [viewController.navigationItem setLeftBarButtonItem:self.masterButtonItem animated:NO];
    }
}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if ([self.viewControllers count] > 1) {
//        [viewController.navigationItem setLeftBarButtonItem:self.masterBackButton animated:NO];
//    } else {
//        [viewController.navigationItem setLeftBarButtonItem:self.masterButtonItem animated:NO];
//    }
//}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    UIButton *btMenu =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btMenu setImage:[UIImage imageNamed:@"btn_menu_ipad.png"] forState:UIControlStateNormal];
    [btMenu addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
    [btMenu setFrame:CGRectMake(0, 0, 55, 30)];
    
    barButtonItem.title = @"";
    barButtonItem.customView = btMenu;
    
    self.masterButtonItem = barButtonItem;
    
    if ([self.viewControllers count] == 1) {
        [[[self.viewControllers lastObject] navigationItem] setLeftBarButtonItem:self.masterButtonItem animated:YES];
    }
    
    self.popover = popoverController;
    self.popover.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.masterButtonItem = nil;
//    [[[self.viewControllers lastObject] navigationItem] setLeftBarButtonItem:nil animated:YES];
    if ([self.viewControllers count] > 1) {
        [viewController.navigationItem setLeftBarButtonItem:self.masterBackButton animated:NO];
    } else {
        [viewController.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
    self.popover = nil;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    DetailNavigationController *navi = [DetailNavigationController shared];
    if ([navi.viewControllers count] == 1) {
        ResultsVCPA *vc = (ResultsVCPA *)navi.viewControllers[0];
        [vc dismissPopover];
    }
}

#pragma mark - Other

- (void)showResultsVCStyleGrid
{
    if ([self.viewControllers count] > 1) {
        [self popToRootViewControllerAnimated:YES];
    }
}

- (void)showDetailsVC
{
    if ([self.viewControllers count] == 1) {
        DetailsVCPA *vc = [[DetailsVCPA alloc] init];
        [self pushViewController:vc animated:YES];
    }
}

- (void)dismissPopover
{
    [self.popover dismissPopoverAnimated:YES];
}

- (void)showPopover
{
   [_popover presentPopoverFromRect:CGRectMake(0, 0, 1, 1)
                             inView:self.view
           permittedArrowDirections:UIPopoverArrowDirectionUp
                           animated:YES];
}

- (void) backVC {
    [self popViewControllerAnimated:YES];
}

@end
