//
//  CompanyItem.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/4/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "CompanyItem.h"

@implementation CompanyItem

- (void)dealloc
{
    _companyID = nil;
    _companyCode = nil;
    _companyName = nil;
    _companyImage  = nil;
    _countryCode  = nil;
    _countryName = nil;
    _useCarNum = nil;
    _status  = nil;
    _viewNum = nil;
}

- (NSDictionary*) itemToDic
{
    NSArray *keys = @[@"companyID",@"companyCode",@"companyName",@"companyImage",@"countryCode",@"countryName",@"useCarNum",@"status",@"viewNum",];
    NSArray *valuses = @[_companyID,_companyCode,_companyName,_companyImage,_countryCode,_countryName,_useCarNum,_status,_viewNum];
    
    return [NSDictionary dictionaryWithObjects:valuses forKeys:keys];
}

+ (CompanyItem*) itemWith:(NSDictionary*)dic
{
    CompanyItem *item = [[CompanyItem alloc] init];
    
    item.companyID      = [dic objectForKey:@"companyID"];
    item.companyCode    = [dic objectForKey:@"companyCode"];
    item.companyName    = [dic objectForKey:@"companyName"];
    item.companyImage   = [dic objectForKey:@"companyImage"];
    item.countryCode    = [dic objectForKey:@"countryCode"];
    item.countryName    = [dic objectForKey:@"countryName"];
    item.useCarNum      = [dic objectForKey:@"useCarNum"];
    item.status         = [dic objectForKey:@"status"];
    item.viewNum        = [dic objectForKey:@"viewNum"];
    
    return item;
}

@end
