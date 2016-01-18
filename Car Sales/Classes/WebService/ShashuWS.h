//
//  ShashuWS.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/10/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@class Error;
@protocol ShashuWSDelegate;

@interface ShashuWS : NSObject

@property(nonatomic,weak) id<ShashuWSDelegate> delegate;

- (void)getShashuWS;
- (void)getShashuFile;

@end

@protocol ShashuWSDelegate <NSObject>

- (void)didFailWithErrorShashu:(Error*)error;
- (void)didSuccessShashu;
- (void)didSuccessShashuWith:(NSMutableArray*)listItem;

@end
