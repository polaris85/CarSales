//
//  ViewShopVC.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/10/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewShopVC : UIViewController

- (void)loadWebCarByID:(NSString*)carID;

@property (strong, nonatomic) NSString *carID;
@property (strong, nonatomic) NSString *urlAddress;

@end
