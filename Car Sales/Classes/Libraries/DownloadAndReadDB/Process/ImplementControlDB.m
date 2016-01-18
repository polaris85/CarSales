//
//  ImplementControlDB.m
//  ReadFileDatabase
//
//  Created by phungduythien on 6/6/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import "ImplementControlDB.h"

#import "NSFileManager+Helper.h"

#import "DownloaderFileDB.h"
#import "JT2ReadFileDB.h"

ImplementControlDB *implementControlDB;

@implementation ImplementControlDB

- (void)callDownloadDBFileWithURL:(NSString *)stringURL andFileNameDatabase:(NSString *)filename returnPathDirectoryExtract:(ReturnDirectoryExtract)returnPathDirectoryExtract {
    DownloaderFileDB *downloadFile = [[DownloaderFileDB alloc] init];
    [downloadFile startGetWithURL:stringURL withFileName:filename returnResulf:^(NSMutableData *downloadData, NSString *dbName, NSError *error) {
        if (downloadData && downloadData.length) {
            [NSFileManager addFile:downloadData fileName:dbName intoFolder:@""];
            NSString *path = [NSFileManager getPathWithFoder:@"" andFileName:nil];
            returnPathDirectoryExtract(path);
        }else {
            returnPathDirectoryExtract(nil);
        }
    }];
}

+ (void)callDownloadDBFileWithURL:(NSString *)stringURL andFileNameDatabase:(NSString *)filename returnPathDirectoryExtract:(ReturnDirectoryExtract)returnPathDirectoryExtract {
    if (implementControlDB == nil) {
        implementControlDB = [[ImplementControlDB alloc] init];
    }
    [implementControlDB callDownloadDBFileWithURL:stringURL andFileNameDatabase:(NSString *)filename returnPathDirectoryExtract:returnPathDirectoryExtract];
}

//Methods helpers

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:string];
}


@end
