//
//  Car.m
//  Car Sales
//
//  Created by Adam on 5/17/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "Car.h"

@implementation Car

- (id)init
{
    self = [super init];
    if (self) {
        self.icon = [NSString stringWithFormat:@"Car%d.jpg", rand()%6+1];
        
        self.title = @"ホンダ";
        self.bonus = @"フリード 1.5 フレックス エアロ";
        self.price = @"89.0万円";
        
        self.more = @"08(H20)年式 | 11.6万km | 千葉県";
        
        self.more1 = @"08(H20)年式";
        self.more2 = @"11.6万km";
        self.more3 = @"千葉県";
        
        self.newCar = rand()%2 ? YES : NO;
    }
    return self;
}

@end
