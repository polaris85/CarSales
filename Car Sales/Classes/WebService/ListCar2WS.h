//
//  ListCar2WS.h
//  Car Sales
//
//  Created by TienLP on 6/18/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@class Error;
@protocol ListCar2WSDelegate;


@interface ListCar2WS : NSObject

@property(nonatomic,weak) id<ListCar2WSDelegate> delegate;

- (void) getListCarWithQueryString:(NSString*) queryStr count:(int)count offset:(int)offset;

@end


@protocol ListCar2WSDelegate <NSObject>

- (void)didFailListCar2WSWithError:(Error*)error;
- (void)didSuccessListCar2WSWithListCar:(NSMutableArray*)listCar numCar:(int)numCar total:(int)total;

@end
