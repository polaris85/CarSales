//
//  BodyTypesVC.h
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "BodyTypeItem.h"

@protocol BodyTypesVCDelegate <NSObject>

- (void)didChangeBodyName:(NSString*)name code:(NSString*)code;
- (void)didChangeBodyItem:(BodyTypeItem*)bodyTypeItem;

@end

@interface BodyTypesVC : ViewController

@property(nonatomic) BOOL isFilter;
@property(nonatomic,weak) id<BodyTypesVCDelegate> delegate;

- (void)loadIsFilter;

@end
