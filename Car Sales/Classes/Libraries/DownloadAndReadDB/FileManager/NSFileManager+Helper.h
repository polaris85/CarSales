//
//  NSFileManager+Helper.h
//  
//
//  Created by phungduythien on 6/2/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Helper)

+(void) createFolder:(NSString *)folder agreeToReplaceIfExist:(BOOL)agree;
+(void) addFile:(NSData *)data fileName:(NSString *)file intoFolder:(NSString *)folder;
+(BOOL) isExistFolder:(NSString *)folder;
+(BOOL) isExistFile:(NSString *)file inFolder:(NSString *)folder;
+(NSData *) getFileWithName:(NSString *)file inFolder:(NSString *)folder;
+ (NSString *)getPathWithFoder:(NSString *)folder andFileName:(NSString *)fileName;

@end
