//
//  MasterTabBarController.m
//  Car Sales
//
//  Created by Adam on 5/24/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "MasterTabBarController.h"

#import "MasterNavigationController.h"
#import "SearchVC.h"
#import "FavoritesVC.h"
#import "RecentsVC.h"
#import "HistoryVC.h"

#import "DetailNavigationController.h"

static __weak MasterTabBarController *shared = nil;

@interface MasterTabBarController ()

@end

@implementation MasterTabBarController

+ (MasterTabBarController *)shared
{
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        shared = self;
        
        SearchVC *vc1 = [[SearchVC alloc] init];
        FavoritesVC *vc2 = [[FavoritesVC alloc] init];
        RecentsVC *vc3 = [[RecentsVC alloc] init];
        HistoryVC *vc4 = [[HistoryVC alloc] init];
        
        MasterNavigationController *navi1 = [[MasterNavigationController alloc] initWithRootViewController:vc1];
        UINavigationController *navi2 = [[UINavigationController alloc] initWithRootViewController:vc2];
        UINavigationController *navi3 = [[UINavigationController alloc] initWithRootViewController:vc3];
        UINavigationController *navi4 = [[UINavigationController alloc] initWithRootViewController:vc4];
        
        navi1.tabBarItem = [[UITabBarItem alloc] initWithTitle:SEARCH_TITLE image:[UIImage imageNamed:@"Icon.png"] tag:1];
        navi2.tabBarItem = [[UITabBarItem alloc] initWithTitle:FAVORITES_TITLE image:[UIImage imageNamed:@"Icon.png"] tag:2];
        navi3.tabBarItem = [[UITabBarItem alloc] initWithTitle:RECENTS_TITLE image:[UIImage imageNamed:@"Icon.png"] tag:3];
        navi4.tabBarItem = [[UITabBarItem alloc] initWithTitle:HISTORY_TITLE image:[UIImage imageNamed:@"Icon.png"] tag:4];
        
        
        self.contentSizeForViewInPopover = CGSizeMake(320, 748);
        self.viewControllers = @[navi1, navi2, navi3, navi4];
    }
    return self;
}

@end
