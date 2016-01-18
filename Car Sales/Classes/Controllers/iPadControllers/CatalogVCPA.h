//
//  CatalogVCPA.h
//  Car Sales
//
//  Created by TienLP on 6/22/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "CompanyItem.h"
#import "BodyTypeItem.h"

@interface CatalogVCPA : ViewController

- (void) loadDataWith:(CompanyItem*) companyItem;
- (void) loadDataWithBodyItem:(BodyTypeItem*) bodyItem;

- (BOOL) checkDataListCatalog;

@end
