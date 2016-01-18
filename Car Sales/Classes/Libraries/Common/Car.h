//
//  Car.h
//  Car Sales
//
//  Created by Adam on 5/17/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Car : NSObject

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *bonus;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *more;

@property (nonatomic, strong) NSString *more1;
@property (nonatomic, strong) NSString *more2;
@property (nonatomic, strong) NSString *more3;

@property (nonatomic, assign) BOOL newCar;

@end
