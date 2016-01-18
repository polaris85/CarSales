//
//  NSFileManager+Helper.m
//  
//
//  Created by phungduythien on 6/2/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import "NSFileManager+Helper.h"

#define KEY_FILE_MANAGER @"key_manager"

@implementation NSFileManager (Helper)

+(void) createFolder:(NSString *)folder agreeToReplaceIfExist:(BOOL)agree{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(YES){
            NSString *pathLD = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
            NSFileManager *mFile = [NSFileManager defaultManager];
            if (![mFile fileExistsAtPath:pathLD]){
                [mFile createDirectoryAtPath:pathLD withIntermediateDirectories:NO attributes:nil error:nil];
               
            }else{
                if(agree){
                    [mFile removeItemAtPath:folder error:nil];
                    [mFile createDirectoryAtPath:pathLD withIntermediateDirectories:NO attributes:nil error:nil];                   
                }
            }
        }else{
            NSLog(@"Can't create this folder. A file name can't contain any of the following character special.");
        }
    });
}

+(BOOL) isExistFolder:(NSString *)folder{
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    NSFileManager *mFile = [NSFileManager defaultManager];
    if ([mFile fileExistsAtPath:folderPath]){
        return YES;
    }
    return NO;
}

+(BOOL) isExistFile:(NSString *)file inFolder:(NSString *)folder{
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:file];
    NSFileManager *mFile = [NSFileManager defaultManager];
    if ([mFile fileExistsAtPath:filePath]){
        return YES;
    }
    return NO;
}

+(void) addFile:(NSData *)data fileName:(NSString *)file intoFolder:(NSString *)folder{
    NSFileManager *mFile = [NSFileManager defaultManager];
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    if(![mFile fileExistsAtPath:folderPath]){
        [self createFolder:folder agreeToReplaceIfExist:YES];
    }
    if([data length]){
        NSString *pathLD = [folderPath stringByAppendingPathComponent:file];
        [data writeToFile:pathLD atomically:YES];
    }
}

+(NSData *) getFileWithName:(NSString *)file inFolder:(NSString *)folder{
    if([self isExistFile:file inFolder:folder]){
        NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
        NSString *filePath = [folderPath stringByAppendingPathComponent:file];
        return [NSData dataWithContentsOfFile:filePath];
    }
    return nil;
}

+ (NSString *)getPathWithFoder:(NSString *)folder andFileName:(NSString *)fileName {
    if([self isExistFile:fileName inFolder:folder]){
        NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
        return filePath;
    }
    return nil;
}

@end
