//
//  CDHistory.h
//  Car Sales
//
//  Created by Nick Lee on 6/17/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDHistory : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSData * dicQuery;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * strQuery;
@property (nonatomic, retain) NSNumber * isData;

@end
