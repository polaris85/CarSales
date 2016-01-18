//
//  FilterStatesVC.h
//  Car Sales
//
//  Created by Le Phuong Tien on 5/28/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@protocol FilterStatesVCDelegate <NSObject>

- (void) didSelectWithPref:(NSMutableDictionary*)dicPref;

@end

@interface FilterStatesVC : ViewController

@property(nonatomic,weak) id<FilterStatesVCDelegate> delegate;

- (void) loadSelectDic:(NSMutableDictionary*)dicInfo;

@end
