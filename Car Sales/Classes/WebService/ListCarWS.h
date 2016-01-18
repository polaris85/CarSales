//
//  ListCarWS.h
//  Car Sales
//
//  Created by Le Phuong Tien on 5/30/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@protocol ListCarWSDelegate;
@class Error;


@interface ListCarWS : NSObject

@property(nonatomic,weak) id<ListCarWSDelegate> delegate;

- (void) getTotalCarWithCount:(int)count page:(int)page;
- (void) getListCarWithQueryString:(NSString*) queryStr count:(int)count page:(int)page;

@end

@protocol ListCarWSDelegate <NSObject>

- (void)didFailWithError:(Error*)error;
- (void)didSuccessWithListCar:(NSMutableArray*)listCar totalCar:(int)totalCar offset:(int)offset;

@end
