//
//  DetailsVCPA.h
//  Car Sales
//
//  Created by TienLP on 6/29/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarItem.h"

@protocol DetailsVCPADelegate <NSObject>

- (void)carNoDataWithID:(NSString*)carID;

@end

@interface DetailsVCPA : UIViewController

@property(nonatomic,strong) CarItem *carItem;
@property(nonatomic,weak) id<DetailsVCPADelegate> delegate;

- (void) setFavoriteCar;

- (void) getDetailCarWSByID:(NSString*)carID;

- (void) dismissMail;

- (void) loadCellInView:(NSString*)title
                  bonus:(NSString*)bonus
                  price:(NSString*)price
                  more1:(NSString*)more1
                  more2:(NSString*)more2
                  more3:(NSString*)more3
         isMultipeImage:(BOOL)isMultipeImage
               carImage:(UIImage*)carImage;

@end
