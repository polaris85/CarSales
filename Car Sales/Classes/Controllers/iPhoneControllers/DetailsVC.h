//
//  DetailsVC.h
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CarItem.h"

@protocol DetailsVCDelegate <NSObject>

- (void)carNoDataWithID:(NSString*)carID;

@end

@interface DetailsVC : ViewController

@property(nonatomic,strong) CarItem *carItem;
@property(nonatomic,weak) id<DetailsVCDelegate> delegate;

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
