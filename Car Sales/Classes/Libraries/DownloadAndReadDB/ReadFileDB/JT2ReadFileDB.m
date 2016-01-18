//
//  JT2ReadFileDB.m
//  ReadFileDatabase
//
//  Created by phungduythien on 6/2/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import "JT2ReadFileDB.h"
#import <sqlite3.h>

JT2ReadFileDB *jT2ReadFileDB;

@interface JT2ReadFileDB (){
    sqlite3 *contactDB;
}

@end

@implementation JT2ReadFileDB

- (void)readDatabaseWithPath:(NSString *)pathDB andTableName:(NSString *)tableName returnResult:(ReturnResult)returnResult {
    const char *dpPath = [pathDB UTF8String];
    if (sqlite3_open(dpPath, &contactDB) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSString *querySQL = [NSString stringWithFormat:@"select * from %@",tableName];
        const char *querySTATEMENT = [querySQL UTF8String] ;
        if (sqlite3_prepare_v2(contactDB, querySTATEMENT, -1, &statement, NULL) == SQLITE_OK) {
            NSMutableArray *array = [NSMutableArray array];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int column = sqlite3_data_count(statement);
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (int i = 0; i < column; i ++) {
                    NSString *keyColumn = [NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
                    NSString *valueColumn = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                    [dic setObject:valueColumn forKey:keyColumn];
                }
                [array addObject:dic];
            }
            returnResult(array,nil);
        }else {
            NSError *error = [NSError errorWithDomain:@"" code:200 userInfo:@{@"errorMsg": @"Can't read database."}];
            returnResult(nil,error);
        }
        sqlite3_close(contactDB);
    }else {
        NSError *error = [NSError errorWithDomain:@"" code:201 userInfo:@{@"errorMsg": @"Open database unsuccessfull."}];
        returnResult(nil,error);
    }
}

- (NSString *)getPathDBFileName:(NSString *)dbName {
    
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = array[0];
    return [documentDir stringByAppendingPathComponent:dbName];
}

+ (void)readDatabaseWithPath:(NSString *)pathDB andTableName:(NSString *)tableName returnResult:(ReturnResult)returnResult {
    if (jT2ReadFileDB == nil) {
        jT2ReadFileDB = [[JT2ReadFileDB alloc] init];
    }
    [jT2ReadFileDB readDatabaseWithPath:pathDB andTableName:tableName returnResult:returnResult];
}

@end
