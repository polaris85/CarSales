//
//  ImplementControl.h
//  ReadFileDatabase
//
//  Created by phungduythien on 6/3/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImplementControl : NSObject

+ (void)callDownloadZipFileWithURL:(NSString *)stringURL returnPathDirectoryExtract:(ReturnDirectoryExtract)returnPathDirectoryExtract;

//Methods helper
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;

@end
