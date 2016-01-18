//
//  ShopDetailWS.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/10/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@class Error;
@protocol ShopDetailWSDelegate;



@interface ShopDetailWS : NSObject

@property(nonatomic,weak) id<ShopDetailWSDelegate> delegate;

- (void) getDetailShopByID:(NSString*)carID;

@end

@protocol ShopDetailWSDelegate <NSObject>

- (void)didFailWithErrorShop:(Error*)error;
- (void)didSuccessWithShop:(NSMutableDictionary*)shopInfo;

@end
