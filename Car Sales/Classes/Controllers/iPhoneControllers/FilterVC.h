//
//  FilterVC.h
//  Car Sales
//
//  Created by Adam on 5/17/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"

@protocol FilterVCDelegate <NSObject>

- (void)didChangeCommonQueryDic:(NSMutableDictionary*)commonQueryDic;

@end

@interface FilterVC : ViewController

@property(nonatomic,strong) NSMutableDictionary *dicQuery;
@property(nonatomic,weak) id<FilterVCDelegate> delegate;

- (void)loadDicQuery:(NSMutableDictionary*)dicQuery;

@end
