//
//  StatesVC.h
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CatalogItem.h"
#import "CompanyItem.h"

@interface StatesVC : ViewController

@property(nonatomic,strong) CatalogItem *catalogItem;
@property(nonatomic,strong) CompanyItem *companyItem;

- (void)loadPrefPrefWithPriceMin:(NSString*)priceMin priceMax:(NSString*)priceMax;

@end
