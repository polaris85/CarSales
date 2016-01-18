#import <Foundation/Foundation.h>

typedef void (^ReturnResultDownloaded)(NSMutableData *downloadData,NSString *filename, NSError *error);

@protocol DownloaderFileDBDelegate;

@interface DownloaderFileDB : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (void)startGetWithURL:(NSString *)stringUrl withFileName:(NSString *)filename withDelegate:(id)delegate;

- (void)startGetWithURL:(NSString *)stringUrl withFileName:(NSString *)filename returnResulf:(ReturnResultDownloaded)resultDownloaded;

- (void)stopDownloadding;

@end


@protocol DownloaderFileDBDelegate<NSObject>

- (void)downloader:(DownloaderFileDB *)downloader didFinishWithData:(NSMutableData*)downloaddata;
- (void)downloaded:(DownloaderFileDB *)downloader didFailWithError:(NSError *)error;

@end
