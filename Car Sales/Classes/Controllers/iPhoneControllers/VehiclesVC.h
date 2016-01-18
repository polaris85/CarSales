//
//  VehiclesVC.h
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CompanyItem.h"
#import "BodyTypeItem.h"

@interface VehiclesVC : ViewController

- (void) loadDataWith:(CompanyItem*) companyItem;
- (void) loadDataWithBodyItem:(BodyTypeItem*) bodyItem;

- (BOOL) checkDataListCatalog;

@end
