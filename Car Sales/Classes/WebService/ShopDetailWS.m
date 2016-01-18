//
//  ShopDetailWS.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/10/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ShopDetailWS.h"
#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import "XMLReader.h"
#import "XMLDictionary.h"

@interface ShopDetailWS()
{
    NSURLConnection *_connection;
    NSMutableData   *_data;
    BOOL             _done;
    Error           *_error;
    
    NSInteger        _index;
    NSMutableString *_currentString;
    NSArray  *_elementList;
    
    NSMutableDictionary *_carInfo;
}

@property(nonatomic,strong) NSString *carID;

- (void)parseData;
- (void)CallWSSuccess;
- (void)CallWSFail;


@end

@implementation ShopDetailWS

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
    _error.error_msg = ERROR_NETWORK;
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
    
    NSLog(@"    paser begin");
    
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLString:tempStr];
    //    NSLog(@"dictionary: %@", xmlDoc);
    
    if (!xmlDoc) {
        _error.error_id = 1;
        _error.error_msg = @"Format XML error.";
    } else {
        _carInfo = [[NSMutableDictionary alloc] initWithDictionary:xmlDoc];
    }
    
    
    NSLog(@"    parser end");
    
    if (_error.error_id==0) {
        [self performSelectorOnMainThread:@selector(CallWSSuccess) withObject:nil waitUntilDone:YES];
    } else {
        [self performSelectorOnMainThread:@selector(CallWSFail) withObject:nil waitUntilDone:YES];
    }
    
    _done = YES;
}

- (void)CallWSSuccess{
    if (_delegate && [_delegate respondsToSelector:@selector(didSuccessWithShop:)]) {
        [_delegate didSuccessWithShop:_carInfo];
    }
}

- (void)CallWSFail{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailWithErrorShop:)]) {
        [_delegate didFailWithErrorShop:_error];
    }
}

#pragma mark - Public method

- (void) getDetailShopByID:(NSString*)carID
{
    if (!_done) {
        _done = YES;
    }
    
    self.carID = carID;
    
    [NSThread detachNewThreadSelector:@selector(getDetailShopInBackground)
                             toTarget:self
                           withObject:nil];
}

- (void) getDetailShopInBackground
{
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        //load url :   http://www.carsensor.net/webapi/b/p/shop/?pn=****&key=****&shop_id=XXXX
        NSString *strQuery = [NSString stringWithFormat:@"%@%@%@&%@&%@%@",WEB_URL,WS_SHOP,PRA_PN,PRA_KEY,PRA_SHOP_ID,_carID];
        NSLog(@"Load : %@",strQuery);
        
        NSURL *url = [NSURL URLWithString: strQuery];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
        _data       = [NSMutableData data];
        _error      = [Error error];
        
        if (_connection) {
            _done = NO;
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            } while (!_done);
        }
        
        //[[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        _carID      = nil;
        _error      = nil;
        _connection = nil;
        _data       = nil;
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    NSLog(@"GET DETAIL SHOP CAR DONE");
}

@end
