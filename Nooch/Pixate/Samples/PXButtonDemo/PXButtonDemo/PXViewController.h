//
//  PXViewController.h
//  PXButtonDemo
//
//  Created by Paul Colton on 6/8/12.
//  Copyright (c) Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PXViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) NSMutableArray *kulers;

@property (weak, nonatomic) IBOutlet UIButton *myButton;
@property (weak, nonatomic) IBOutlet UIButton *myButton2;
@property (weak, nonatomic) IBOutlet UIButton *myButton3;
@property (weak, nonatomic) IBOutlet UIButton *myButton4;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *cssTextView;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *sliderLabel;

@property (weak, nonatomic) IBOutlet UIView *buttonView;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)radiusSlider:(id)sender;

+ (NSString *)cssGradientFromColor:(UIColor *)color;

@end
