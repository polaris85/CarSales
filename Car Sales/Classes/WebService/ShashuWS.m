//
//  ShashuWS.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/10/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ShashuWS.h"
#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import "CDShashu.h"

#define root_response                       @"response"
#define root_results                        @"results"

#define response_status                     @"status"
#define response_message                    @"message"

#define results_available                   @"results_available"
#define results_returned                    @"results_returned"
#define results_start                       @"results_start"

#define maker                               @"maker"
#define code                                @"code"
#define name                                @"name"

#define shashu                              @"shashu"

@interface ShashuWS()<NSXMLParserDelegate>
{
    NSURLConnection *_connection;
    NSMutableData   *_data;
    BOOL             _done;
    Error           *_error;
    
    NSInteger        _index;
    NSMutableString *_currentString;
    NSArray  *_elementList;
    
    BOOL _isMaker;
    NSString *strMakerCode, *strMakerName,*strShashuCode, *strShashuName;
    
    NSMutableArray *_listItem;

}

- (void)parseData;
- (void)CallWSSuccess;
- (void)CallWSFail;

@end

@implementation ShashuWS

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
        case 7:
            _isMaker = YES;
            break;
         case 8:
            _isMaker = NO;
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
                break;
            }
            case 8:
            {
//                NSLog(@" %@ shashu : %@ - %@",strMakerCode,strShashuCode,strShashuName);
            
//                CDShashu *cdShashu = (CDShashu *)[NSEntityDescription insertNewObjectForEntityForName:@"CDShashu"
//                                                                         inManagedObjectContext:[AppDelegate shared].managedObjectContext];
//                cdShashu.makerCode  = strMakerCode;
//                cdShashu.makerName  = strMakerName;
//                cdShashu.shashuCode = strShashuCode;
//                cdShashu.shashuName = strShashuName;
                
//                [[AppDelegate shared] saveContext];
                
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                [item setObject:strMakerCode forKey:@"makerCode"];
                [item setObject:strMakerName forKey:@"makerName"];
                [item setObject:strShashuCode forKey:@"shashuCode"];
                [item setObject:strShashuName forKey:@"shashuName"];
                
                [_listItem addObject:item];

                
                break;
            }
            case 9:
            {
                if (_isMaker) {
                    strMakerCode = trimmedString;
                } else {
                    strShashuCode = trimmedString;
                }
                break;
            }
            case 10:
            {
                if (_isMaker) {
                    strMakerName = trimmedString;
                } else {
                    strShashuName = trimmedString;
                }
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
                     maker,
                     shashu,
                     code,
                     name];
    
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
    if (_delegate && [_delegate respondsToSelector:@selector(didSuccessShashuWith:)]) {
        [_delegate didSuccessShashuWith:_listItem];
    }
}

- (void)CallWSFail{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailWithErrorShashu:)]) {
        [_delegate didFailWithErrorShashu:_error];
    }
}

#pragma mark - public

- (void)getShashuWS
{
    if (!_done) {
        _done = YES;
    }
    
    [NSThread detachNewThreadSelector:@selector(getShashuWSInBackground)
                             toTarget:self
                           withObject:nil];
}

- (void)getShashuWSInBackground
{
    @autoreleasepool {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        
        NSString *strQuery = [NSString stringWithFormat:@"%@%@%@&%@&%@SHASHU",WEB_URL,WS_MASTER,PRA_PN,PRA_KEY,PRA_MODE];
        NSLog(@"Load : %@",strQuery);
        NSURL *url = [NSURL URLWithString: strQuery];
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
    
    NSLog(@"GET SHASHU LIST DONE");
}

- (void)getShashuFile
{
    if (!_done) {
        _done = YES;
    }
    
    [NSThread detachNewThreadSelector:@selector(getShashuFileInBackground)
                             toTarget:self
                           withObject:nil];
}

- (void)getShashuFileInBackground
{
    @autoreleasepool {        
        _error      = [Error error];
        _data       = [NSMutableData data];
        _listItem   = [[NSMutableArray alloc] init];
        
        // get file
        NSString* path = [[NSBundle mainBundle] pathForResource:@"shashu_xml" ofType:@"xml"];
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
    
    NSLog(@"GET SHASHU LIST FILE DONE");
}

@end
