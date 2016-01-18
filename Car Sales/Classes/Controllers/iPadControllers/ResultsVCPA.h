//
//  ResultsVCPA.h
//  Car Sales
//
//  Created by TienLP on 6/21/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ResultsTypeLoadNone  = 0,
    ResultsTypeLoadMaster = 1,
    ResultsTypeLoadFilter = 2,
    ResultsTypeLoadHistory = 3,
} ResultsTypeLoad;

@interface ResultsVCPA : UIViewController

@property(nonatomic) ResultsTypeLoad typeload;


- (void)loadListForCommonQueryDic:(NSMutableDictionary*)commonQueryDic;
+ (ResultsVCPA *)shared;
- (void)dismissPopover;

@end
