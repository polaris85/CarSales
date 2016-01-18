//
//  PrefWS.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/5/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "PrefWS.h"
#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import "CDPref.h"

#define root_response                       @"response"
#define root_results                        @"results"

#define response_status                     @"status"
#define response_message                    @"message"

#define results_available                   @"results_available"
#define results_returned                    @"results_returned"
#define results_start                       @"results_start"

#define pref                                @"pref"
#define pref_code                           @"code"
#define pref_name                           @"name"

#define pref_large_area                     @"large_area"
#define pref_large_area_code                @"code"
#define pref_large_area_name                @"name"


@interface PrefWS()<NSXMLParserDelegate>
{
    NSURLConnection *_connection;
    NSMutableData   *_data;
    BOOL             _done;
    Error           *_error;
    
    NSInteger        _index;
    NSMutableString *_currentString;
    NSArray  *_elementList;
    
    BOOL _isSessionTag;
    NSString *prefName, *sessionName;
    int prefCode, sessionCode;
    
    NSMutableArray *_listItem;
}

- (void)parseData;
- (void)CallWSSuccess;
- (void)CallWSFail;

@end

@implementation PrefWS

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

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _index = -1;
    _index = [_elementList indexOfObject:elementName];
    
    switch (_index) {
        case 10:
            _isSessionTag = YES;
            break;
            
        default:
            break;
    }
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
                _error.error_id = 1;
                break;
            }
            case 3:
            {
                _error.error_msg = trimmedString;
                break;
            }
            case 4:
            {
                break;
            }
            case 5:
            {
                break;
            }
            case 6:
            {
                break;
            }
            case 7:
            {
                // add coredata
                
//                NSLog(@"prefName : %@ -- prefCode: %d ----- sessionCode: %d -- sessionName: %@",prefName,prefCode,sessionCode,sessionName);
                
//                CDPref *cdPref = (CDPref *)[NSEntityDescription insertNewObjectForEntityForName:@"CDPref"
//                                                                                  inManagedObjectContext:[AppDelegate shared].managedObjectContext];
//                cdPref.prefCode     = prefCode;
//                cdPref.prefName     = prefName;
//                cdPref.sessionCode  = sessionCode;
//                cdPref.sessionName  = sessionName;
                
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                [item setObject:[NSNumber numberWithInt:prefCode] forKey:@"prefCode"];
                [item setObject:prefName forKey:@"prefName"];
                [item setObject:[NSNumber numberWithInt:sessionCode] forKey:@"sessionCode"];
                [item setObject:sessionName forKey:@"sessionName"];
                
                [_listItem addObject:item];
                
                break;
            }
            case 8:
            {
                if (_isSessionTag) {
                    sessionCode = [trimmedString intValue];
                } else {
                    prefCode = [trimmedString intValue];
                }
                break;
            }
            case 9:
            {
                if (_isSessionTag) {
                    sessionName = trimmedString;
                } else {
                    prefName = trimmedString;
                }
                break;
            }
            case 10:
            {
                _isSessionTag = NO;
                break;
            }
            default:
                break;
        }

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
                     pref,
                     pref_code,
                     pref_name,
                     pref_large_area];
    
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
    if (_delegate && [_delegate respondsToSelector:@selector(didSuccessWith:)]) {
        [_delegate didSuccessWith:_listItem];
    }
}

- (void)CallWSFail{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailWithErrorPref:)]) {
        [_delegate didFailWithErrorPref:_error];
    }
}

#pragma mark - public

- (void)getPrefWS
{
    if (!_done) {
        _done = YES;
    }
    
    [NSThread detachNewThreadSelector:@selector(getPrefWSInBackground)
                             toTarget:self
                           withObject:nil];
}

- (void)getPrefWSInBackground
{
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        NSLog(@"Load : %@",WS_PREF);
        
        NSURL *url = [NSURL URLWithString: WS_PREF];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
        _data       = [NSMutableData data];
        _error      = [Error error];
        _listItem   = [[NSMutableArray alloc] init];
        
        if (_connection) {
            _done = NO;
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            } while (!_done);
        }
        
        //[[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        _error      = nil;
        _connection = nil;
        _data       = nil;
        _listItem   = nil;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    NSLog(@"GET PREF LIST DONE");
}

- (void)getPrefFile
{
    if (!_done) {
        _done = YES;
    }
    
    [NSThread detachNewThreadSelector:@selector(getPrefFileInBackGroup)
                             toTarget:self
                           withObject:nil];
}

- (void)getPrefFileInBackGroup
{
    @autoreleasepool {
        _error      = [Error error];
        _data       = [NSMutableData data];
        _listItem   = [[NSMutableArray alloc] init];
        
        // get file
        NSString* path = [[NSBundle mainBundle] pathForResource:@"pref_xml" ofType:@"xml"];
        if (path)
        {
            _data = [NSMutableData dataWithContentsOfFile:path];
            
            // parse
            
            if (_data) {
                _done = NO;
                [self parseData];
            } else {
                _done = YES;
            }
            
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            } while (!_done);
            
            
        } else {
            NSLog(@"path error");
        }
        
        _error      = nil;
        _connection = nil;
        _data       = nil;
        _listItem   = nil;
    }
    
    NSLog(@"GET PREF LIST FILE DONE");
}

@end
