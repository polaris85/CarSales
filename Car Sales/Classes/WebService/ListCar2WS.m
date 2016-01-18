//
//  ListCar2WS.m
//  Car Sales
//
//  Created by TienLP on 6/18/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ListCar2WS.h"
#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import "JSON.h"

@interface ListCar2WS()
{
    NSURLConnection *_connection;
    NSMutableData   *_data;
    BOOL             _done;
    Error           *_error;
    
    NSMutableArray *_listCar;
    int _numCar,_total,_count,_offset;
}

@property(nonatomic,strong) NSString *queryString;

- (void)parseData;
- (void)CallWSSuccess;
- (void)CallWSFail;

@end

@implementation ListCar2WS

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _error.error_id = 1;
    if ([error.localizedDescription isEqualToString:@"The request timed out."]) {
        _error.error_msg = ERROR_TIMEOUT;
    } else {
        _error.error_msg = ERROR_NETWORK;
    }
    [self performSelectorOnMainThread:@selector(CallWSFail)
                           withObject:nil
                        waitUntilDone:YES];
    _done = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseData];
}

#pragma mark - Private method

- (void)parseData{
    NSString *tempStr = [[NSString alloc] initWithBytes: [_data mutableBytes]
                                                 length:[_data length]
                                               encoding:NSUTF8StringEncoding];
    //    NSLog(@"Data : %@",tempStr);
    NSMutableDictionary *dic = [tempStr JSONValue];
    
//    NSLog(@"Data JSON: %@",dic);
    
    if (dic) {
        NSMutableDictionary *results = [dic objectForKey:@"results"];
        
        if (results) {
            
            if (![results objectForKey:@"error"]) {
                _total = [[results objectForKey:@"results_available"] intValue];
                _numCar = [[results objectForKey:@"results_returned"] intValue];
                
                NSArray *usedcar = [results objectForKey:@"usedcar"];
                
                for (NSDictionary *carItem in usedcar) {
                    CarItem *item = [[CarItem alloc] init];
                    
                    item.carId          = [Common formatJSONValue:[carItem objectForKey:@"id"]];
                    
                    NSDictionary *brand = [carItem objectForKey:@"brand"];
                    item.carName        = [Common formatJSONValue:[brand objectForKey:@"name"]];
                    
                    item.carGrade       = [Common formatJSONValue:[carItem objectForKey:@"grade"]];
                    
                    float price = [Common formatJSONValueFloat:[carItem objectForKey:@"price"]] / 10000;
                    
                    if (price == 0) {
                        item.carPrice = @"応談";
                    } else {
                        item.carPrice       = [NSString stringWithFormat:@"%.1f万円",price];
                    }

                    
                    item.carYear        = [NSString stringWithFormat:@"%@年",[Common formatJSONValue:[carItem objectForKey:@"year"]]];
                    item.carOdd         = [Common formatJSONValue:[carItem objectForKey:@"odd"]];
                    
                    NSDictionary *shop  = [carItem objectForKey:@"shop"];
                    NSDictionary *pref  = [shop objectForKey:@"pref"];
                    item.carPref        = [Common formatJSONValue:[pref objectForKey:@"name"]];

                    NSDictionary *photo = [carItem objectForKey:@"photo"];
                    NSArray      *sub   = [photo objectForKey:@"sub"];
                    NSDictionary *main  = [photo objectForKey:@"main"];
                    
                    item.thumd          = [Common formatJSONValue:[main objectForKey:@"l"]];
                    item.isSmallImage   = [sub count] == 0 ? NO : YES;

//                    item.isNew          = _isNew;
                    
                    [_listCar addObject:item];
                }
                
            } else {
                NSArray *error = [results objectForKey:@"error"];
                NSMutableDictionary *msg = [error objectAtIndex:0];
                _error.error_id = 1;
                _error.error_msg = [msg objectForKey:@"message"];
            }
            
        } else {
            _error.error_id = 1;
            _error.error_msg = @"Data error dic";
        }
        
    } else {
        _error.error_id = 1;
        _error.error_msg = @"Data error dic";
        
    }
    
    
    // return delegate
    if (_error.error_id == 0) {
        [self performSelectorOnMainThread:@selector(CallWSSuccess)
                               withObject:nil
                            waitUntilDone:YES];
    } else {
        [self performSelectorOnMainThread:@selector(CallWSFail)
                               withObject:nil
                            waitUntilDone:YES];
    }
    
    _done = YES;
}

- (void)CallWSSuccess{
    if (_delegate && [_delegate respondsToSelector:@selector(didSuccessListCar2WSWithListCar:numCar:total:)]) {
        [_delegate didSuccessListCar2WSWithListCar:_listCar numCar:_numCar total:_total];
    }
}

- (void)CallWSFail{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailListCar2WSWithError:)]) {
        [_delegate didFailListCar2WSWithError:_error];
    }
}

#pragma mark - public

- (void) getListCarWithQueryString:(NSString*) queryStr count:(int)count offset:(int)offset
{
    if ([Common isNetworkAvailable]) {
        if (!_done) {
            _done = YES;
        }
        
        _offset         = offset;
        _count          = count;
        _queryString    = queryStr;
        
        [NSThread detachNewThreadSelector:@selector(getListCarWithQueryStringInBackGroup)
                                 toTarget:self
                               withObject:nil];
    } else {
        _error      = [Error error];
        _error.error_id = 1;
        _error.error_msg = ERROR_NETWORK;
        _done = YES;
        [self performSelectorOnMainThread:@selector(CallWSFail) withObject:nil waitUntilDone:YES];
    }
}

- (void) getListCarWithQueryStringInBackGroup{
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *strQuery = [NSString stringWithFormat:@"%@%@%@&%@%d&%@%d%@&format=json",WEB_URL_2,WS_USEDCAR_2,KEY_2,PRA_COUNT,_count,PRA_START,_offset,_queryString];
        
        NSString *encodedUrl = [strQuery stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        
        NSLog(@"URL - %@", encodedUrl);              // Checking the url
        
        NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
        
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
        _listCar    = [[NSMutableArray alloc] init];
        _data       = [NSMutableData data];
        _error      = [Error error];
        
        if (_connection) {
            _done = NO;
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            } while (!_done);
        }
        
        //[[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        _listCar    = nil;
        _error      = nil;
        _connection = nil;
        _data       = nil;
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    NSLog(@"GET LIST CAR 2 BY QUERY STRING DONE");
}





























@end
