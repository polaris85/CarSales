//
//  CompanyItem.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/4/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyItem : NSObject

@property(nonatomic,strong) NSString *companyID;
@property(nonatomic,strong) NSString *companyCode;
@property(nonatomic,strong) NSString *companyName;
@property(nonatomic,strong) NSString *companyImage;
@property(nonatomic,strong) NSString *countryCode;
@property(nonatomic,strong) NSString *countryName;
@property(nonatomic,strong) NSString *useCarNum;
@property(nonatomic,strong) NSString *status;
@property(nonatomic,strong) NSString *viewNum;

- (NSDictionary*) itemToDic;

+ (CompanyItem*) itemWith:(NSDictionary*)dic;

@end
