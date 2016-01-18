//
//  CDPref.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/5/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDPref : NSManagedObject

@property (nonatomic) int16_t prefCode;
@property (nonatomic, retain) NSString * prefName;
@property (nonatomic) int16_t sessionCode;
@property (nonatomic, retain) NSString * sessionName;

@end
