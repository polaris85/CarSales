//
//  ImplementControl.m
//  ReadFileDatabase
//
//  Created by phungduythien on 6/3/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import "ImplementControl.h"
#import "DownloaderZipFile.h"
#import "NSFileManager+Helper.h"
#import "ZipArchive.h"

ImplementControl *implementControl;

@implementation ImplementControl

- (void)callDownloadZipFileWithURL:(NSString *)stringURL returnPathDirectoryExtract:(ReturnDirectoryExtract)returnPathDirectoryExtract {
    [DownloaderZipFile startGetWithURL:stringURL returnResulf:^(NSMutableData *downloadData, NSError *error) {
        [NSFileManager addFile:downloadData fileName:@"database.zip" intoFolder:@""];
        
        NSString *path = [NSFileManager getPathWithFoder:@"" andFileName:nil];
        NSString *zipFilePath = [path stringByAppendingPathComponent:@"database.zip"];
        NSString *output = [path stringByAppendingPathComponent:@"unZipDirName"];
        
        ZipArchive* za = [[ZipArchive alloc] init];
        
        if( [za UnzipOpenFile:zipFilePath] ) {
            if( [za UnzipFileTo:output overWrite:YES] != NO ) {
                //unzip data success
                NSString *pathDB = [NSFileManager getPathWithFoder:@"unZipDirName" andFileName:nil];
                NSLog(@"returnPathDirectoryExtract: %@",pathDB);
                returnPathDirectoryExtract(pathDB);
            }            
            [za UnzipCloseFile];
        }    

    }];
}

+ (void)callDownloadZipFileWithURL:(NSString *)stringURL returnPathDirectoryExtract:(ReturnDirectoryExtract)returnPathDirectoryExtract {
    if (implementControl == nil) {
        implementControl = [[ImplementControl alloc] init];       
    }
    [implementControl callDownloadZipFileWithURL:stringURL returnPathDirectoryExtract:returnPathDirectoryExtract];
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
