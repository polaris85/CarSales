//
//  BodyTypeItem.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/4/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BodyTypeItem : NSObject

@property(nonatomic,strong) NSString *bodyTypeId;
@property(nonatomic,strong) NSString *bodyCode;
@property(nonatomic,strong) NSString *bodyName;
@property(nonatomic,strong) NSString *bodyImage;
@property(nonatomic,strong) NSString *bodyAllNum;
@property(nonatomic,strong) NSString *bodyViewNum;

- (NSDictionary*) itemToDic;

+ (BodyTypeItem*) itemWith:(NSDictionary*)dic;

@end
