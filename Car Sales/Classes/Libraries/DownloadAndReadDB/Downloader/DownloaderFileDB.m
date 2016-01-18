#import "DownloaderFileDB.h"

DownloaderFileDB *downloader;

@interface DownloaderFileDB ()
{
    NSURLConnection *_connection;    
}

@property (nonatomic, strong) NSMutableData *downloadData;

@property (nonatomic, strong) id <DownloaderFileDBDelegate> delegate;

@property (nonatomic, strong) ReturnResultDownloaded returnResultDownloaded;

@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *url;
@end

@implementation DownloaderFileDB

@synthesize downloadData       = _downloadData;
@synthesize delegate        = _delegate;

#pragma mark - Other

- (void)startGetWithURL:(NSString *)stringUrl withFileName:(NSString *)filename withDelegate:(id)delegate
{
    self.delegate = delegate;
    self.filename = filename;
    self.url = stringUrl;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringUrl]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        _connection = [NSURLConnection connectionWithRequest:theRequest delegate:self]; 
        if (_connection) {
            
        }
    });

}

- (void)startGetWithURL:(NSString *)stringUrl withFileName:(NSString *)filename returnResulf:(ReturnResultDownloaded)resultDownloaded
{
    self.returnResultDownloaded = resultDownloaded;
    self.filename = filename;
    self.url = stringUrl;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringUrl]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        _connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        if (_connection) {
            
        }
    });
    
}

- (void)stopDownloadding
{
    if (_connection) {
        [_connection cancel];
        _connection = nil;
    }    
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// creo il contenitore dei dati
    self.downloadData = [NSMutableData data];
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dataDownloaded {
    [self.downloadData appendData:dataDownloaded];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(downloaded:didFailWithError:)]) {
            [self.delegate performSelector:@selector(downloaded:didFailWithError:) 
                                withObject:self 
                                withObject:error];
        }
    }else {
        self.returnResultDownloaded(nil,nil,error);
    }
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {    
    NSString *currentURL = [NSString stringWithFormat:@"%@",connection.currentRequest.URL];
    if ([currentURL isEqualToString:self.url]) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(downloader:didFinishWithData:)]) {
                [self.delegate performSelector:@selector(downloader:didFinishWithData:)
                                    withObject:self
                                    withObject:self.downloadData ];
            }
        }else {
            self.returnResultDownloaded(self.downloadData,self.filename,nil);
        }
    }    
    self.downloadData=nil;    
}


@end
