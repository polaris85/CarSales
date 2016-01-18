//
//  CDShashu.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/10/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDShashu : NSManagedObject

@property (nonatomic, retain) NSString * makerName;
@property (nonatomic, retain) NSString * makerCode;
@property (nonatomic, retain) NSString * shashuCode;
@property (nonatomic, retain) NSString * shashuName;

@end
