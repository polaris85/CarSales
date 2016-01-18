//
//  JT2ReadFileDB.h
//  ReadFileDatabase
//
//  Created by phungduythien on 6/2/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ReturnResult)(NSMutableArray *, NSError*);

@interface JT2ReadFileDB : NSObject

+ (void)readDatabaseWithPath:(NSString *)pathDB andTableName:(NSString *)tableName returnResult:(ReturnResult)returnResult;

@end
