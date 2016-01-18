#import <Foundation/Foundation.h>

typedef void (^ReturnResultDownloaded)(NSMutableData *downloadData, NSError *error);

@protocol DownloaderZipFileDelegate;

@interface DownloaderZipFile : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (void)startGetWithURL:(NSString *)stringUrl withDelegate:(id)delegate;
+ (void)startGetWithURL:(NSString *)stringUrl returnResulf:(ReturnResultDownloaded)resultDownloaded;
+ (void)stopDownload;

@end


@protocol DownloaderZipFileDelegate<NSObject>

- (void)downloader:(DownloaderZipFile *)downloader didFinishWithData:(NSMutableData*)downloaddata;
- (void)downloaded:(DownloaderZipFile *)downloader didFailWithError:(NSError *)error;

@end
