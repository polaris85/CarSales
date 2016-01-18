//
//  CatalogItem.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/4/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "CatalogItem.h"

@implementation CatalogItem

- (void)dealloc
{
    _catalogId      = nil;
    _model          = nil;
    _grade          = nil;
    _companyCode    = nil;
    _bodyCode       = nil;
    _photo          = nil;
    _carNum         = nil;
    _image          = nil;
}

- (NSDictionary*) itemToDic
{
    NSArray *keys = @[@"catalogId",@"model",@"grade",@"companyCode",@"bodyCode",@"photo",@"carNum"];
    NSArray *valuses = @[_catalogId,_model,_grade,_companyCode,_bodyCode,_photo,_carNum];
    
    return [NSDictionary dictionaryWithObjects:valuses forKeys:keys];
}

+ (CatalogItem*) itemWith:(NSDictionary*)dic
{
    CatalogItem *item = [[CatalogItem alloc] init];
    
    item.catalogId      = [dic objectForKey:@"catalogId"];
    item.model          = [dic objectForKey:@"model"];
    item.grade          = [dic objectForKey:@"grade"];
    item.companyCode    = [dic objectForKey:@"companyCode"];
    item.bodyCode       = [dic objectForKey:@"bodyCode"];
    item.photo          = [dic objectForKey:@"photo"];
    item.carNum         = [dic objectForKey:@"carNum"];
   
    
    return item;
}

@end
