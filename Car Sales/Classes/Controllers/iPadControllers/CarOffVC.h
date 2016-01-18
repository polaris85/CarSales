//
//  CarOffVC.h
//  Car Sales
//
//  Created by TienLP on 7/2/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuBarViewController.h"
#import "CarItem.h"

@protocol CarOffVCDelegate <NSObject>

- (void) showDetailCar:(CarItem*)carItem;
- (void) loadResultDic:(NSMutableDictionary*)dic;

@end

@interface CarOffVC : UIViewController

@property (nonatomic, weak) UIPopoverController *popover;
@property (nonatomic, weak) id<CarOffVCDelegate> delegate;

-(IBAction)changeListInTable:(id)sender;
- (void)reloadAllTable;

@end
