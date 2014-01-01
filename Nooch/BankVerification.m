//
//  BankVerification.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "BankVerification.h"
#import "Home.h"

@interface BankVerification ()
@property (nonatomic,strong) UIButton *verify;
@property (nonatomic,strong) UITextField *micro1;
@property (nonatomic,strong) UITextField *micro2;
@end

@implementation BankVerification

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 0, 0)];
    [info setStyleClass:@"instruction_text"];
    [info setNumberOfLines:4];
    [info setText:@"Check your most recent bank statement and enter the amounts deposited by Nooch into your account into the boxes below."];
    [self.view addSubview:info];
    
    self.verify = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.verify setFrame:CGRectMake(0, 200, 0, 0)];
    [self.verify setTitle:@"Submit" forState:UIControlStateNormal];
    [self.verify setStyleClass:@"button_green"];
    [self.verify setStyleId:@"verifybank_button"];
    [self.verify addTarget:self action:@selector(verify_amounts) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.verify];
}

- (void) verify_amounts
{
    
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
