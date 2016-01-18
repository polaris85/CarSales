//
//  CarDetailWS.h
//  Car Sales
//
//  Created by Le Phuong Tien on 5/31/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@protocol CarDetailWSDelegate;
@class Error;

@interface CarDetailWS : NSObject

@property(nonatomic,weak) id<CarDetailWSDelegate> delegate;

- (void) getDetailCarByID:(NSString*)carID;

@end

@protocol CarDetailWSDelegate <NSObject>

- (void)didFailWithError:(Error*)error;
- (void)didSuccessWithCar:(NSMutableDictionary*)carInfo;

@end
