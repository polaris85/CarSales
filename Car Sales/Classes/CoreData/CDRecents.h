//
//  CDRecents.h
//  Car Sales
//
//  Created by Nick Lee on 6/17/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDRecents : NSManagedObject

@property (nonatomic, retain) NSString * carGrade;
@property (nonatomic, retain) NSString * carId;
@property (nonatomic, retain) NSString * carName;
@property (nonatomic, retain) NSString * carOdd;
@property (nonatomic, retain) NSString * carPref;
@property (nonatomic, retain) NSString * carPrice;
@property (nonatomic, retain) NSString * carYear;
@property (nonatomic) NSTimeInterval created;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL isSmallImage;
@property (nonatomic, retain) NSString * thumd;
@property (nonatomic) BOOL isDel;

@end
