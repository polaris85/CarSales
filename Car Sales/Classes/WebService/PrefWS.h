//
//  PrefWS.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/5/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@class Error;
@protocol PrefWSDelegate;

@interface PrefWS : NSObject

@property(nonatomic,weak) id<PrefWSDelegate> delegate;

- (void)getPrefWS;
- (void)getPrefFile;

@end


@protocol PrefWSDelegate <NSObject>

- (void)didFailWithErrorPref:(Error*)error;
- (void)didSuccess;
- (void)didSuccessWith:(NSMutableArray*)listItem;

@end