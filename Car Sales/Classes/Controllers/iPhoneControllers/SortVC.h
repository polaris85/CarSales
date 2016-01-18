//
//  SortVC.h
//  Car Sales
//
//  Created by Adam on 5/17/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"

typedef enum{
    SortTypeNone  = 0,
    SortTypeCheapPrice = 1,
    SortTypeHighestPrice = 2,
    SortTypeName = 3,
    SortTypeOldestYear = 4,
    SortTypeNewYear = 5,
    SortTypeLessMileage = 6,
    SortTypeNewest = 7,
    SortTypeNoOrder = 8,
    SortTypeRadom = 9
} SortType ;

@protocol SortVCDelegate <NSObject>

- (void)didChangeSortWithType:(SortType)type;

@end

@interface SortVC : ViewController

@property(nonatomic,weak) id<SortVCDelegate> delegate;

@end
