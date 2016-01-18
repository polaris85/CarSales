//
//  PAPickerVC.h
//  MovingHouse
//
//  Created by Nick Lee on 4/15/13.
//  Copyright (c) 2013 tienlp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PAPickerVC;

@protocol PAPickerDelegate <NSObject>

- (void)didChangePickerWithDone:(BOOL)isDone date:(NSDate*)date;
- (void)pickerSheet:(PAPickerVC *)pickerSheet dismissWithDone:(BOOL)done;

@end

@interface PAPickerVC : UIViewController

@property (nonatomic, weak) UIPopoverController *popover;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (nonatomic,weak) id<PAPickerDelegate>delegate;


- (IBAction)didChangeCancel:(id)sender;
- (IBAction)didChangeDone:(id)sender;
- (void)setTitlePicker:(NSString*)name;

@end
