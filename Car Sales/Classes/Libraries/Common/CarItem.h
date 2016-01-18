//
//  CarItem.h
//  Car Sales
//
//  Created by Le Phuong Tien on 5/30/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarItem : NSObject

@property(nonatomic,strong) NSString *carId;

@property(nonatomic,strong) NSString *carName;
@property(nonatomic,strong) NSString *carGrade;
@property(nonatomic,strong) NSString *carPrice;

@property(nonatomic,strong) NSString *carYear;
@property(nonatomic,strong) NSString *carOdd;
@property(nonatomic,strong) NSString *carPref;

@property(nonatomic,strong) NSString *thumd;
@property(nonatomic,strong) UIImage  *thumbImage;

@property(nonatomic)        BOOL        isSmallImage;
@property(nonatomic)        BOOL        isNew;
@property(nonatomic)        BOOL        isDel;



@end
