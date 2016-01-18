//
//  ZoomImageVC.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/8/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ZoomImageVC.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"
#import "Downloader.h"
#import "PhotoItem.h"
#import "MBNScrollImageView.h"

@interface ZoomImageVC ()<DownloaderDelegate>
{
    
    __weak IBOutlet UIActivityIndicatorView *_indicator;
    __weak IBOutlet UIButton *_btNext;
    __weak IBOutlet UIButton *_btBack;
    __weak IBOutlet UILabel *_lbCaption;
    __weak IBOutlet UIView *_viewInfo;
    __weak IBOutlet UIView *_viewScroll;
    MBNScrollImageView *_scrollImage;
}

@property(nonatomic,strong) NSMutableArray *images;
@property(nonatomic) int indexImage;
- (IBAction)backViewImage:(id)sender;
- (IBAction)nextViewImage:(id)sender;

@end

@implementation ZoomImageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"Zoom image screen";
    
    self.navigationItem.rightBarButtonItem = nil;
    
    _images = [[NSMutableArray alloc] init];
    
    if ([Common user].isIPhone5Screen) {
        CGRect rect = CGRectMake(0, 0, 320, 419);
        _viewScroll.frame = rect;
        _scrollImage = [[MBNScrollImageView alloc] initWithFrame:rect image:nil];
    } else {
        CGRect rect = CGRectMake(0, 0, 320, 331);
        _viewScroll.frame = rect;
        _scrollImage = [[MBNScrollImageView alloc] initWithFrame:rect image:nil];
    }
    
    [_viewScroll addSubview:_scrollImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Others

- (void) loadInfor:(NSMutableArray*)images index:(int)indexImage
{
    _indexImage = indexImage;
    
    
    for (PhotoItem *item in images) {
        [_images addObject:item];
    }
    
    [self loadImageWithIndex:_indexImage];
}

- (void) loadImageWithIndex:(int)index
{
    self.title = [NSString stringWithFormat:@"%d/%d",index+1,[_images count]];
    
    PhotoItem *item = [_images objectAtIndex:index];
    
    _lbCaption.text = item.strCaption;
    
    _btBack.hidden = !(_indexImage > 0);
    _btNext.hidden = !(_indexImage < [_images count] - 1);
    
    if (item.image) {
        [_scrollImage addImage:item.image];
        _indicator.hidden = YES;
    } else {
        [_scrollImage addImage:nil];
        _indicator.hidden = NO;
        //down load photo
        Downloader *downloader = [[Downloader alloc] init];
        downloader.delegate = self;
        downloader.identifier = item.photoID;
        [downloader get:[NSURL URLWithString:item.strUrl]];
    }
}

- (void)viewDidUnload {
    _viewScroll = nil;
    _viewInfo = nil;
    _lbCaption = nil;
    _btBack = nil;
    _btNext = nil;
    _indicator = nil;
    [super viewDidUnload];
}

#pragma mark - Action
- (IBAction)backViewImage:(id)sender {
    if (_indexImage > 0) {
        _indexImage --;
        [self loadImageWithIndex:_indexImage];
    }
}

- (IBAction)nextViewImage:(id)sender {
    if (_indexImage < [_images count] - 1) {
        _indexImage ++;
        [self loadImageWithIndex:_indexImage];
    }
}

#pragma mark - DownloaderDelegate
-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier
{
    _indicator.hidden = YES;
    int index = [identifier integerValue];
    index -= 100;
    
    if (index < [_images count]) {
        PhotoItem *item = [_images objectAtIndex:index];
        item.image = [UIImage imageWithData:data];
        
        if (index == _indexImage) {
            [_scrollImage addImage:item.image];
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier;
{
    _indicator.hidden = YES;
    int index = [indentifier integerValue];
    index -= 100;
    
    if (index < [_images count]) {
        PhotoItem *item = [_images objectAtIndex:index];
        item.image = [UIImage imageNamed:@"no_image_car.png"];
        
        if (index == _indexImage) {
            [_scrollImage addImage:item.image];
        }
    }
}




@end
