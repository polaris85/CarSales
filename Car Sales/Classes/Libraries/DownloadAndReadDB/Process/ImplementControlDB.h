//
//  ImplementControlDB.h
//  ReadFileDatabase
//
//  Created by phungduythien on 6/6/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImplementControlDB : NSObject

+ (void)callDownloadDBFileWithURL:(NSString *)stringURL andFileNameDatabase:(NSString *)filename returnPathDirectoryExtract:(ReturnDirectoryExtract)returnPathDirectoryExtract;

//Methods helper
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;

@end
