//
//  JT2PopupAlertView.m
//  PopupAlert
//
//  Created by phungduythien on 6/6/13.
//  Copyright (c) 2013 phungduythien. All rights reserved.
//

#import "JT2PopupAlertView.h"
#import <QuartzCore/QuartzCore.h>

#define DELTA   60.0f;

JT2PopupAlertView *jT2PopupAlertView;

@implementation JT2PopupAlertView

+ (void)showPopupAlertViewWithString:(NSString *)string withFont:(UIFont *)font andDelayTime:(NSInteger)second  {
    if (!jT2PopupAlertView) {
        jT2PopupAlertView = [[JT2PopupAlertView alloc] init];
    }
    [jT2PopupAlertView showPopupAlertViewWithString:string withFont:font andDelayTime:second];
}

- (void)showPopupAlertViewWithString:(NSString *)string withFont:(UIFont *)font andDelayTime:(NSInteger)second {
    CGFloat delta = DELTA;
    CGFloat deltaWidthTextView = 30;
    CGFloat deltaHeightTextView = 21;
    
    UIWindow *window =  [UIApplication sharedApplication].windows[0] ;
    CGRect rect = window.frame;
        
    CGFloat widthPopUp = rect.size.width - DELTA;
    CGSize size = [self sizeOfString:string inFont:font maxWidth:widthPopUp];
       
    
    CGRect rectView;
    rectView.origin.x = rect.origin.x + delta/4;
    rectView.origin.y = rect.size.height - (size.height + delta/4 + 50);
    rectView.size.width = 320 - delta/2;
    rectView.size.height = size.height + deltaHeightTextView + delta/4;
    // create view main
    UIView *viewMain = [[UIView alloc] initWithFrame:rectView];
    viewMain.backgroundColor = [UIColor clearColor];
    viewMain.layer.cornerRadius = 7;
    viewMain.clipsToBounds = YES;
    //create view bg
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectView.size.width, rectView.size.height)];
    viewBg.backgroundColor = [UIColor blackColor];
    viewBg.alpha = 0.8;
    [viewMain addSubview:viewBg];
    //create text view
    UITextView *tvx = [[UITextView alloc] initWithFrame:CGRectMake(viewMain.frame.size.width/2 - (size.width + deltaWidthTextView)/2,viewMain.frame.size.height/2 - (size.height+deltaHeightTextView)/2, size.width + deltaWidthTextView, size.height + deltaHeightTextView)];   
    tvx.font = font;
    tvx.text = string;
    tvx.textAlignment = NSTextAlignmentCenter;
    tvx.textColor = [UIColor whiteColor];
    tvx.backgroundColor = [UIColor clearColor];
    [viewMain addSubview:tvx];        
    //effect
    viewMain.alpha = 0.0;    
    [window addSubview:viewMain];
    [UIView animateWithDuration:0.5 animations:^{
        viewMain.alpha = 1.0;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:second options:UIViewAnimationOptionLayoutSubviews animations:^{
            viewMain.alpha = 0.0;
        } completion:^(BOOL finished) {
            jT2PopupAlertView = nil;
        }];
    } ];    
}

- (CGSize)sizeOfString:(NSString *)string inFont:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    CGSize size = [string sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth - 25, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return size;
}

@end
