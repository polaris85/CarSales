//
//  ViewController.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (id)init
{
    self = [super init];
    if (self) {
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
//        self.navigationItem.backBarButtonItem.title = BACK;
//        
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(showHideMenuBar)];
        
        //add Button
        self.navigationItem.backBarButtonItem = nil;
        
        UIButton *btBack =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btBack setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [btBack addTarget:self action:@selector(backVC) forControlEvents:UIControlEventTouchUpInside];
        [btBack setFrame:CGRectMake(0, 0, 61, 30)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btBack];
        
        UIButton *btMenu =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btMenu setImage:[UIImage imageNamed:@"btn_navi_menu.png"] forState:UIControlStateNormal];
        [btMenu addTarget:self action:@selector(showHideMenuBar) forControlEvents:UIControlEventTouchUpInside];
        [btMenu setFrame:CGRectMake(0, 0, 60, 30)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btMenu];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[AppDelegate shared] setMenuBarHidden:YES];
    [super viewWillDisappear:animated];
}

- (void)showHideMenuBar
{
    [[AppDelegate shared] showHideMenuBar];
}

- (void)backVC
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)crash {
    [NSException raise:@"There is no spoon."
                format:@"Abort, retry, fail?"];
}

@end
