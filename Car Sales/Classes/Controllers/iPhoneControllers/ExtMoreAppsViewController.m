//
//  ExtMoreAppsViewController.m
//  Car Sales
//
//  Created by Huynh Duc Dung on 1/14/14.
//  Copyright (c) 2014 Green Global. All rights reserved.
//

#import "ExtMoreAppsViewController.h"
#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import <MZFormSheetController/MZFormSheetController.h>

@interface ExtMoreAppsViewController ()<UIGestureRecognizerDelegate>

@end

@implementation ExtMoreAppsViewController

// ios 7 light content
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // detect touch position and close modal
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];


}

// UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


- (void)tapAction:(UITapGestureRecognizer *)sender
{
    CGPoint touchPoint=[sender locationInView:self.view];

    NSLog(@"touched %f %f", touchPoint.x,touchPoint.y);
    
    if (touchPoint.x >= 270 && touchPoint.y >= 7 && touchPoint.y <= 30) {
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            // do sth
        }];

    }
}


@end
