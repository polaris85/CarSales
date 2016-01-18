//
//  StatesVCPA.h
//  Car Sales
//
//  Created by TienLP on 6/27/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "CatalogItem.h"
#import "CompanyItem.h"

@interface StatesVCPA : ViewController

@property(nonatomic,strong) CatalogItem *catalogItem;
@property(nonatomic,strong) CompanyItem *companyItem;

- (void)loadPrefPrefWithPriceMin:(NSString*)priceMin priceMax:(NSString*)priceMax;

@end
