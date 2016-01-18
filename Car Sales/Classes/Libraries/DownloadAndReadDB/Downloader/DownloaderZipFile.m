#import "DownloaderZipFile.h"

DownloaderZipFile *downloader;

@interface DownloaderZipFile ()
{
    NSURLConnection *_connection;
}

@property (nonatomic, strong) NSMutableData *downloadData;

@property (nonatomic, strong) id <DownloaderZipFileDelegate> delegate;

@property (nonatomic, strong) ReturnResultDownloaded returnResultDownloaded;

@end

@implementation DownloaderZipFile

@synthesize downloadData       = _downloadData;
@synthesize delegate        = _delegate;

#pragma mark - Other

- (void)startGetWithURL:(NSString *)stringUrl 
{               
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringUrl]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        _connection = [NSURLConnection connectionWithRequest:theRequest delegate:self]; 
        if (_connection) {
            
        }
    });

}

- (void)startGetWithURL:(NSString *)stringUrl returnResulf:(ReturnResultDownloaded)resultDownloaded
{
    self.returnResultDownloaded = resultDownloaded;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringUrl]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        _connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        if (_connection) {
            
        }
    });
    
}

- (void)stopDownload
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
        self.returnResultDownloaded(nil,error);
    }
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(downloader:didFinishWithData:)]) {
            [self.delegate performSelector:@selector(downloader:didFinishWithData:) 
                                withObject:self 
                                withObject:self.downloadData ];
        }
    }else {
        self.returnResultDownloaded(self.downloadData,nil);
    }
    self.downloadData=nil;
    
}

#pragma mark - Methods Class

+ (void)startGetWithURL:(NSString *)stringUrl withDelegate:(id)delegate {
    if (downloader == nil) {
        downloader = [[DownloaderZipFile alloc] init];        
    }
    [downloader startGetWithURL:stringUrl];
    downloader.delegate = delegate;
}

+ (void)startGetWithURL:(NSString *)stringUrl returnResulf:(ReturnResultDownloaded)resultDownloaded {
    if (downloader == nil) {
        downloader = [[DownloaderZipFile alloc] init];        
    }
    [downloader startGetWithURL:stringUrl returnResulf:resultDownloaded];
}

+ (void)stopDownload {
    if (downloader) {
        [downloader stopDownload];
    }
}

@end
