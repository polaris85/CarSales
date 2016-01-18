//
//  ZoomImageScrollVC.m
//  Car Sales
//
//  Created by TienLP on 6/20/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ZoomImageScrollVC.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"
#import "Downloader.h"
#import "JSON.h"

#import "MBNScrollImageView.h"
#import "PhotoItem.h"


@interface ZoomImageScrollVC ()<DownloaderDelegate>
{
    __weak IBOutlet UIScrollView *_scrollView;
    __weak IBOutlet UILabel      *_lbCaption;
    __weak IBOutlet UIActivityIndicatorView *_indicator;
    
    __weak IBOutlet UIView *_viewCaption;
    __weak IBOutlet UIButton *_btNext;
    __weak IBOutlet UIButton *_btBack;
    
    __weak IBOutlet UINavigationBar *_naviBar;
    UINavigationItem *_naviItem;
    
    MBNScrollImageView *_scrollImage1,*_scrollImage2,*_scrollImage3;
    int _pageIndex;
    
    BOOL _isPressButton,_isHideNavi,_isFirst;
    NSTimer *_timer;
}

- (IBAction)backViewImage:(id)sender;
- (IBAction)nextViewImage:(id)sender;

@end

@implementation ZoomImageScrollVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //setting
        _pageIndex = 0;
        
        // init list image
        _images = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"Zoom image screen";
    
    self.navigationItem.rightBarButtonItem = nil;
    
    //---------
    UIButton *btBack =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btBack setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [btBack addTarget:self action:@selector(backVC) forControlEvents:UIControlEventTouchUpInside];
    [btBack setFrame:CGRectMake(0, 0, 61, 30)];
    
    
    _naviItem = [[UINavigationItem alloc] initWithTitle:@""];
    _naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btBack];;
    [_naviBar pushNavigationItem:_naviItem animated:NO];
    
    // set up Recognizer with tag
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [_scrollView addGestureRecognizer:tapRecognizer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideNavi) userInfo:nil repeats:NO];
    
    
    if ([Common isIOS7]) {
        // move tabbar
        
        CGRect tmpRect = _naviBar.frame;
        tmpRect.origin.y += 20;
        _naviBar.frame = tmpRect;
        
        // load data

        _pageIndex = _indexImage;
        
        _scrollView.contentSize = CGSizeMake(3 * self.view.bounds.size.width, 0);
        [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];
        
        float detaHeight = self.view.bounds.size.height;
        
        CGRect rect1 = CGRectMake(0, 0, _scrollView.frame.size.width, detaHeight);
        _scrollImage1 = [[MBNScrollImageView alloc] initWithFrame:rect1 image:nil];
        _scrollImage1.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
        [_scrollView addSubview:_scrollImage1];
        
        CGRect rect2 = CGRectMake(self.view.bounds.size.width, 0, _scrollView.frame.size.width, detaHeight);
        _scrollImage2 = [[MBNScrollImageView alloc] initWithFrame:rect2 image:nil];
        _scrollImage2.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
        [_scrollView addSubview:_scrollImage2];
        
        CGRect rect3 = CGRectMake(self.view.bounds.size.width*2, 0, _scrollView.frame.size.width, detaHeight);
        _scrollImage3= [[MBNScrollImageView alloc] initWithFrame:rect3 image:nil];
        _scrollImage3.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
        [_scrollView addSubview:_scrollImage3];
        
        [self showImageInScroll];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void) viewDidAppear:(BOOL)animated {
    _isFirst = YES;
}

- (void)backVC {
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = self.view.bounds;
    
    CGRect rect1 = CGRectMake(0, 0,     self.view.bounds.size.width, self.view.bounds.size.height);
    CGRect rect2 = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    CGRect rect3 = CGRectMake(self.view.bounds.size.width*2, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    _scrollView.frame = rect;
    _scrollView.contentSize = CGSizeMake(3 * rect.size.width, 0);
    [_scrollView setContentOffset:CGPointMake(rect.size.width, 0) animated:NO];
    
    _scrollImage1.frame = rect1;
    _scrollImage2.frame = rect2;
    _scrollImage3.frame = rect3;
    
    if (_isFirst) {
        [self showImageInScroll];
    } else {
        _isFirst = YES;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return !UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Others

- (void)hideNavi{
    if (!_isHideNavi) {
        _isHideNavi = YES;
        
        CGRect rect = self.view.bounds;
        CGRect rectBar = _naviBar.frame;
        CGRect rectCap = _viewCaption.frame;
        
        CGRect rect1 = CGRectMake(0, 0,     self.view.bounds.size.width, self.view.bounds.size.height);
        CGRect rect2 = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        CGRect rect3 = CGRectMake(self.view.bounds.size.width*2, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        rectBar.origin.y = -44;
        rectCap.origin.y += rectCap.size.height;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        _naviBar.frame = rectBar;
        _viewCaption.frame = rectCap;
        
        _scrollView.frame = rect;
        
        [_scrollImage1 resetFrame:rect1];
        [_scrollImage2 resetFrame:rect2];
        [_scrollImage3 resetFrame:rect3];
        
        [UIView commitAnimations];
    }
}

- (void) showNavi
{
    if (_isHideNavi) {
        CGRect rect = self.view.bounds;
        CGRect rectBar = _naviBar.frame;
        
        CGRect rectCap = _viewCaption.frame;
        
        CGRect rect1 = CGRectMake(0, 0,     self.view.bounds.size.width, self.view.bounds.size.height);
        CGRect rect2 = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        CGRect rect3 = CGRectMake(self.view.bounds.size.width*2, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        rectBar.origin.y = 0;
        rectCap.origin.y -= rectCap.size.height;
        
        rect.size.height = self.view.bounds.size.height;
        rect.origin.y = 0;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        if ([Common isIOS7]) {
            // move tabbar
            rectBar.origin.y += 20;
        }
        _naviBar.frame = rectBar;
        _viewCaption.frame = rectCap;
        
        _scrollView.frame = rect;

        [_scrollImage1 resetFrame:rect1];
        [_scrollImage2 resetFrame:rect2];
        [_scrollImage3 resetFrame:rect3];
        
        [UIView commitAnimations];
        
        _isHideNavi = NO;
    }
}

- (void)scrollViewTapped:(UITapGestureRecognizer*)recognizer{
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideNavi) userInfo:nil repeats:NO];
    
    if (_isHideNavi) {
        [self showNavi];
    } else {
        [self hideNavi];
    }
}

#pragma mark - load info

- (void) loadInfor:(NSMutableArray*)images index:(int)indexImage
{
    _pageIndex = indexImage;
    
    _scrollView.contentSize = CGSizeMake(3 * self.view.bounds.size.width, 0);
    [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];
    
    float detaHeight = self.view.bounds.size.height;
    
    CGRect rect1 = CGRectMake(0, 0, _scrollView.frame.size.width, detaHeight);
    _scrollImage1 = [[MBNScrollImageView alloc] initWithFrame:rect1 image:nil];
    _scrollImage1.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
    [_scrollView addSubview:_scrollImage1];
    
    CGRect rect2 = CGRectMake(self.view.bounds.size.width, 0, _scrollView.frame.size.width, detaHeight);
    _scrollImage2 = [[MBNScrollImageView alloc] initWithFrame:rect2 image:nil];
    _scrollImage2.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
    [_scrollView addSubview:_scrollImage2];
    
    CGRect rect3 = CGRectMake(self.view.bounds.size.width*2, 0, _scrollView.frame.size.width, detaHeight);
    _scrollImage3= [[MBNScrollImageView alloc] initWithFrame:rect3 image:nil];
    _scrollImage3.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
    [_scrollView addSubview:_scrollImage3];
    
    for (PhotoItem *item in images) {
        [_images addObject:item];
    }
    
    [self showImageInScroll];
}

#pragma mark - Scroll delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        if (scrollView.contentOffset.x == 0) {
            // lui lai
            if (_pageIndex == 0) {
                _pageIndex = [_images count] - 1;
            } else {
                _pageIndex--;
            }
        } else if (scrollView.contentOffset.x == self.view.bounds.size.width*2) {
            // tien toi
            if (_pageIndex == [_images count] - 1) {
                _pageIndex =0;
            } else {
                _pageIndex++;
            }
        }
        
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideNavi) userInfo:nil repeats:NO];
        [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];
        [self showImageInScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) {
        // lui lai
        if (_pageIndex == 0) {
            _pageIndex = [_images count] - 1;
        } else {
            _pageIndex--;
        }
    } else if (scrollView.contentOffset.x == self.view.bounds.size.width*2) {
        // tien toi
        if (_pageIndex == [_images count] - 1) {
            _pageIndex = 0;
        } else {
            _pageIndex++;
        }
    }
    
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideNavi) userInfo:nil repeats:NO];
    [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];
    [self showImageInScroll];
}

- (void) showImageInScroll
{
    self.title = [NSString stringWithFormat:@"%d/%d",_pageIndex + 1,[_images count]];
    _naviItem.title = [NSString stringWithFormat:@"%d/%d",_pageIndex + 1,[_images count]];
    
    int itemIndex1 = -1;
    int itemIndex2 = -1;
    int itemIndex3 = -1;
    
    if (_pageIndex == 0) {
        itemIndex1 = [_images count] - 1;
        itemIndex2 = _pageIndex;
        itemIndex3 = _pageIndex + 1;
    } else if (_pageIndex == [_images count] - 1) {
        itemIndex1 = _pageIndex - 1;
        itemIndex2 = _pageIndex;
        itemIndex3 = 0;
    } else {
        itemIndex1 = _pageIndex - 1;
        itemIndex2 = _pageIndex;
        itemIndex3 = _pageIndex + 1;
    }
    
    
    
    if (itemIndex1 < [_images count] - 1 && itemIndex1 >= 0) {
        PhotoItem *item1 = [_images objectAtIndex:itemIndex1];
        if (item1.image) {
            [_scrollImage1 addImage:item1.image];
        } else {
            [_scrollImage1 addImage:nil];
        }
    }
    
    
    PhotoItem *item2 = [_images objectAtIndex:itemIndex2];
    if (item2.image) {
        [_scrollImage2 addImage:item2.image];
        _lbCaption.text = item2.strCaption;
        _indicator.hidden = YES;
    } else {
        [_scrollImage2 addImage:nil];
        _indicator.hidden = NO;
        _lbCaption.text = item2.strCaption;
        [self downloadImageWithIndex:itemIndex2];
    }
    
    if (itemIndex3 < [_images count] - 1 && itemIndex3 >= 0) {
        PhotoItem *item3 = [_images objectAtIndex:itemIndex3];
        if (item3.image) {
            [_scrollImage3 addImage:item3.image];
        } else {
            [_scrollImage3 addImage:nil];
        }
    }
    
    if ([Common isIOS7]) {
        [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, -20) animated:NO];
    }
    else
    {
        [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];

    }
    _isPressButton = NO;
}

#pragma mark - downloader

- (void)downloadImageWithIndex:(int)index
{
    if (index < [_images count]) {
        PhotoItem *item = [_images objectAtIndex:index];
        if (!item.image) {
            Downloader *downloader = [[Downloader alloc] init];
            downloader.delegate = self;
            downloader.identifier = [NSNumber numberWithInt:index];
            [downloader get:[NSURL URLWithString:item.strUrl]];
        }
    }
}

-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier
{
    int index = [identifier intValue];
    _indicator.hidden = YES;
    
    if (index < [_images count]) {
        NSLog(@"Download success image with index : %d",index);
        PhotoItem *item = [_images objectAtIndex:index];
        item.image = [UIImage imageWithData:data];
        
        if (index == _pageIndex) {
            [_scrollImage2 addImage:item.image];
        } else {
            if (_pageIndex == 0) {
                if (index == [_images count] - 1) {
                    [_scrollImage1 addImage:item.image];
                } else if (index == _pageIndex + 1) {
                    [_scrollImage3 addImage:item.image];
                }
                
            } else if (_pageIndex == [_images count] - 1) {
                if (index == _pageIndex - 1) {
                    [_scrollImage1 addImage:item.image];
                } else if (index == 0) {
                    [_scrollImage3 addImage:item.image];
                }
            } else {
                if (index == _pageIndex - 1) {
                    [_scrollImage1 addImage:item.image];
                } else if (index == _pageIndex + 1) {
                    [_scrollImage3 addImage:item.image];
                }
            }
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier
{
    int index = [indentifier intValue];
    _indicator.hidden = YES;
    
    if (index < [_images count]) {
        NSLog(@"Download fail image with index : %d",index);
        PhotoItem *item = [_images objectAtIndex:index];
        item.image = [UIImage imageNamed:@"no_image_car.png"];
        
        if (index == _pageIndex) {
            [_scrollImage2 addImage:item.image];
        } else {
            if (_pageIndex == 0) {
                if (index == [_images count] - 1) {
                    [_scrollImage1 addImage:item.image];
                } else if (index == _pageIndex + 1) {
                    [_scrollImage3 addImage:item.image];
                }
                
            } else if (_pageIndex == [_images count] - 1) {
                if (index == _pageIndex - 1) {
                    [_scrollImage1 addImage:item.image];
                } else if (index == 0) {
                    [_scrollImage3 addImage:item.image];
                }
            } else {
                if (index == _pageIndex - 1) {
                    [_scrollImage1 addImage:item.image];
                } else if (index == _pageIndex + 1) {
                    [_scrollImage3 addImage:item.image];
                }
            }
        }
    }
}


- (void)viewDidUnload {
    _indicator = nil;
    _naviBar = nil;
    _viewCaption = nil;
    [super viewDidUnload];
}

#pragma mark - Action

- (IBAction)backViewImage:(id)sender
{
    _isPressButton = YES;
    // lui lai
    if (_pageIndex == 0) {
        _pageIndex = [_images count] - 1;
    } else {
        _pageIndex--;
    }
    
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self showImageInScroll];
}

- (IBAction)nextViewImage:(id)sender
{
    _isPressButton = YES;
    // tien toi
    if (_pageIndex == [_images count] - 1) {
        _pageIndex = 0;
    } else {
        _pageIndex++;
    }
    
    [_scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:NO];
    [self showImageInScroll];

}

@end
