//
//  CatalogItem.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/4/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogItem : NSObject

@property(nonatomic,strong) NSString *catalogId;
@property(nonatomic,strong) NSString *model;
@property(nonatomic,strong) NSString *grade;
@property(nonatomic,strong) NSString *companyCode;
@property(nonatomic,strong) NSString *bodyCode;
@property(nonatomic,strong) NSString *photo;
@property(nonatomic,strong) NSString *carNum;

@property(nonatomic,strong) UIImage  *image;

- (NSDictionary*) itemToDic;

+ (CatalogItem*) itemWith:(NSDictionary*)dic;

@end
