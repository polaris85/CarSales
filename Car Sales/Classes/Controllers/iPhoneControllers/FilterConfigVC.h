//
//  FilterConfigVC.h
//  Car Sales
//
//  Created by Adam on 5/17/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"

@protocol FilterConfigVCDelegate <NSObject>

- (void)didSelectWithDic:(NSMutableDictionary*)dicSelect;

@end

@interface FilterConfigVC : ViewController

@property(nonatomic,weak) id<FilterConfigVCDelegate> delegate;

- (void)loadSelect:(NSMutableDictionary*)dicInfo;

@end
