//
//  ListCarWS.m
//  Car Sales
//
//  Created by Le Phuong Tien on 5/30/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ListCarWS.h"
#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import "CarItem.h"

#define root_response                       @"response"
#define root_results                        @"results"

#define response_status                     @"status"
#define response_message                    @"message"

#define results_available                   @"results_available"
#define results_returned                    @"results_returned"
#define results_start                       @"results_start"
#define used_car                            @"used_car"

#define used_car_id                         @"id"
#define used_car_maker_cd                   @"maker_cd"
#define used_car_maker                      @"maker"
#define used_car_shashu_cd                  @"shashu_cd"
#define used_car_shashu                     @"shashu"
#define used_car_grade                      @"grade"
#define used_car_price                      @"price"
#define used_car_price_disp                 @"price_disp"
#define used_car_total_price                @"total_price"
#define used_car_other_price                @"other_price"
#define used_car_mileage                    @"mileage"
#define used_car_mileage_disp               @"mileage_disp"
#define used_car_syaken                     @"syaken"
#define used_car_syaken_disp                @"syaken_disp"
#define used_car_repair                     @"repair"
#define used_car_mission                    @"mission"
#define used_car_body                       @"body"
#define used_car_color                      @"color"
#define used_car_photo                      @"photo"
#define used_car_year                       @"year"
#define used_car_year_disp                  @"year_disp"
#define used_car_year_disp_title            @"year_disp_title"
#define used_car_displacement               @"displacement"

#define used_car_shop                       @"shop"
#define used_car_shop_id                    @"shop_id"
#define used_car_shop_name                  @"name"
#define used_car_shop_pref                  @"pref"
#define used_car_shop_navi                  @"navi"
#define used_car_shop_cs_shop_url           @"cs_shop_url"

#define used_car_inspection                 @"inspection"
#define used_car_inspection_cost            @"inspection_cost"
#define used_car_warranty                   @"warranty"
#define used_car_warranty_cost              @"warranty_cost"
#define used_car_warranty_kikan             @"warranty_kikan"
#define used_car_warranty_distance          @"warranty_distance"
#define used_car_m_photo                    @"m_photo"
#define used_car_coupon                     @"coupon"
#define used_car_cart                       @"cart"
#define used_car_inquiry                    @"inquiry"
#define used_car_mobile_detail              @"mobile_detail"
#define used_car_mobile_inquiry             @"mobile_inquiry"
#define used_car_inquiry_type               @"inquiry_type"
#define used_car_body_cd                    @"body_cd"
#define used_car_pref_cd                    @"pref_cd"

#define used_car_car_type                   @"car_type"
#define used_car_car_type_items             @"items"
#define used_car_car_type_items_type_cd     @"type_cd"
#define used_car_car_type_items_type_name   @"type_name"

#define used_car_new                        @"new"
#define used_car_nintei                     @"nintei"
#define used_car_budget                     @"budget"
#define used_car_movie                      @"movie"


@interface ListCarWS()<NSXMLParserDelegate>
{
    NSURLConnection *_connection;
    NSMutableData   *_data;
    BOOL             _done;
    Error           *_error;
    
    NSInteger        _index;
    NSMutableString *_currentString;
    NSArray  *_elementList;
    
    NSMutableArray  *_listCar;
    int _totalCar, _offset;
    
    int _count,_page;
    
    NSString *_carId;
    
    NSString *_carName;
    NSString *_carGrade;
    NSString *_carPrice;
    
    NSString *_carYear;
    NSString *_carOdd;
    NSString *_carPref;
    
    NSString *_thumd;
    BOOL      _isSmallImage;
    BOOL      _isNew;
}

@property(nonatomic,strong) NSString *queryString;

- (void)parseData;
- (void)CallWSSuccess;
- (void)CallWSFail;

- (void)getTotalCarInBackground;
- (void) getListCarWithQueryStringInBackGroup;

@end

@implementation ListCarWS

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
    self.queryString = nil;
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

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _index = -1;
    _index = [_elementList indexOfObject:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //    NSLog(@"element: %@", elementName);
    //    NSLog(@"string: %@", _currentString);
    
    _index = [_elementList indexOfObject:elementName];
    
    if (_index >= 0) {
        NSString *trimmedString = [Common trimString:_currentString];
        
        switch (_index) {
            case 0:
            {
                break;
            }
            case 1:
            {
                break;
            }
            case 2:
            {
                _error.error_id = [trimmedString intValue];
                break;
            }
            case 3:
            {
                _error.error_msg = trimmedString;
                break;
            }
            case 4:
            {
                _totalCar = [trimmedString integerValue];
                break;
            }
            case 5:
            {
                break;
            }
            case 6:
            {
                _offset = [trimmedString integerValue];
                break;
            }
            case 7:
            {
                break;
            }
            case 8:
            {
                _carId = trimmedString;
                break;
            }
            case 9:
            {
                _carName = trimmedString;
                break;
            }
            case 10:
            {
                _carGrade = trimmedString;
                break;
            }
            case 11:
            {
                _carPrice = trimmedString;
                break;
            }
            case 12:
            {
                _carYear = [trimmedString stringByAppendingString:@"年式"];
                break;
            }
            case 13:
            {
                _carOdd = trimmedString;
                break;
            }
            case 14:
            {
                _carPref = trimmedString;
                break;
            }
            case 15:
            {
                _thumd = trimmedString;
                break;
            }
            case 16:
            {
                if ([trimmedString integerValue] == 0) {
                    _isSmallImage = NO;
                } else {
                    _isSmallImage = YES;
                }
                break;
            }
            case 17:
            {
                if ([trimmedString integerValue] == 0) {
                    _isNew = NO;
                } else {
                    _isNew = YES;
                }
                break;
            }
            default:
                break;
        }
    }
    
    if ([elementName isEqualToString:used_car])
    {
        CarItem *item = [[CarItem alloc] init];
        
        item.carId          = _carId;
        
        item.carName        = _carName;
        item.carGrade       = _carGrade;
        item.carPrice       = _carPrice;
        
        item.carYear        = _carYear;
        item.carOdd         = _carOdd;
        item.carPref        = _carPref;
        
        item.thumd          = _thumd;
        item.isSmallImage   = _isSmallImage;
        
        item.isNew          = _isNew;
        
        [_listCar addObject:item];
    }
    
    _index = -1;
    [_currentString setString:@""];
}


#pragma mark - Private method

- (void)parseData{
    
    //    NSString *tempStr = [[NSString alloc] initWithBytes: [_data mutableBytes]
    //                                                 length:[_data length]
    //                                               encoding:NSUTF8StringEncoding];
    //    NSLog(@"Data : %@",tempStr);
    
    NSLog(@"    paser begin");
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_data];
    parser.delegate = self;
    _elementList = @[root_response,
                     root_results,
                     response_status,
                     response_message,
                     results_available,
                     results_returned,
                     results_start,
                     used_car,
                     used_car_id,
                     used_car_maker,
                     used_car_grade,
                     used_car_price_disp,
                     used_car_year_disp,
                     used_car_mileage_disp,
                     used_car_shop_pref,
                     used_car_photo,
                     used_car_m_photo,
                     used_car_new];
    _index = -1;
    _currentString = [NSMutableString string];
    
    //parser xml
    [parser parse];
    
    _elementList = nil;
    _currentString = nil;
    parser = nil;
    
    NSLog(@"    parser end");
    
    if (_error.error_id==0) {
        [self performSelectorOnMainThread:@selector(CallWSSuccess) withObject:nil waitUntilDone:YES];
    } else {
        [self performSelectorOnMainThread:@selector(CallWSFail) withObject:nil waitUntilDone:YES];
    }
    
    _done = YES;
}

- (void)CallWSSuccess{
    if (_delegate && [_delegate respondsToSelector:@selector(didSuccessWithListCar:totalCar:offset:)]) {
        [_delegate didSuccessWithListCar:_listCar totalCar:_totalCar offset:_offset];
    }
}

- (void)CallWSFail{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailWithError:)]) {
        [_delegate didFailWithError:_error];
    }
}

#pragma mark - Public method

- (void) getTotalCarWithCount:(int)count page:(int)page
{
    if ([Common isNetworkAvailable]) {
        if (!_done) {
            _done = YES;
        }
        
        _page   = page;
        _count  = count;
        
        [NSThread detachNewThreadSelector:@selector(getTotalCarInBackground)
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

- (void)getTotalCarInBackground
{
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // load url: http://www.carsensor.net/webapi/b/p/usedcar/?pn=xxx&key=xxx
        NSString *strQuery = [NSString stringWithFormat:@"%@%@%@&%@&%@%d&%@%d",WEB_URL,WS_USEDCAR,PRA_PN,PRA_KEY,PRA_COUNT,_count,PRA_PAGE,_page];
        NSLog(@"Load : %@",strQuery);
        
        NSURL *url = [NSURL URLWithString: strQuery];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
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
    
    NSLog(@"GET TOTAL CAR DONE");
}

- (void) getListCarWithQueryString:(NSString*) queryStr count:(int)count page:(int)page
{
    if ([Common isNetworkAvailable]) {
        if (!_done) {
            _done = YES;
        }
        
        _page           = page;
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

- (void) getListCarWithQueryStringInBackGroup
{
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // load url: http://www.carsensor.net/webapi/b/p/usedcar/?pn=xxx&key=xxx&****
        NSString *strQuery = [NSString stringWithFormat:@"%@%@%@&%@&%@%d&%@%d%@",WEB_URL,WS_USEDCAR,PRA_PN,PRA_KEY,PRA_COUNT,_count,PRA_PAGE,_page,_queryString];
        
        //        NSLog(@"Load : %@",strQuery);
        //        NSURL *url = [NSURL URLWithString: strQuery];
        //        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
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
    
    NSLog(@"GET LIST CAR BY QUERY STRING DONE");
}

@end
