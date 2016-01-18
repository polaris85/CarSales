//
//  BodyTypeItem.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/4/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "BodyTypeItem.h"

@implementation BodyTypeItem

- (void)dealloc
{
    _bodyTypeId = nil;
    _bodyCode = nil;
    _bodyName = nil;
    _bodyImage = nil;
    _bodyViewNum = nil;
    _bodyAllNum = nil;
}

- (NSDictionary*) itemToDic
{
    NSArray *keys = @[@"bodyTypeId",@"bodyCode",@"bodyName",@"bodyImage",@"bodyViewNum",@"bodyAllNum"];
    NSArray *valuses = @[_bodyTypeId,_bodyCode,_bodyName,_bodyImage,_bodyViewNum,_bodyAllNum];
    
    return [NSDictionary dictionaryWithObjects:valuses forKeys:keys];
}

+ (BodyTypeItem*) itemWith:(NSDictionary*)dic
{
    BodyTypeItem *item = [[BodyTypeItem alloc] init];
    
    item.bodyTypeId         = [dic objectForKey:@"bodyTypeId"];
    item.bodyCode           = [dic objectForKey:@"bodyCode"];
    item.bodyName           = [dic objectForKey:@"bodyName"];
    item.bodyImage          = [dic objectForKey:@"bodyImage"];
    item.bodyViewNum        = [dic objectForKey:@"bodyViewNum"];
    item.bodyAllNum         = [dic objectForKey:@"bodyAllNum"];
    
    return item;
}



@end
