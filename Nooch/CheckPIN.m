//
//  CheckPIN.m
//  Nooch
//
//  Created by crks on 1/6/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "CheckPIN.h"
#import "Home.h"
#import <QuartzCore/QuartzCore.h>

@interface CheckPIN ()
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@property(nonatomic,strong) NSString *pin_check;
@property(nonatomic,strong) NSMutableDictionary *user;
@end


@implementation CheckPIN

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated{
    self.pin_check = @"";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];
    
    [self.navigationItem setTitle:@"Create PIN"];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    [title setText:@"Enter your PIN"];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 280, 50)];
    [self.prompt setNumberOfLines:2];
    [self.prompt setText:@"Require Immediately is enabled, please enter your PIN to continue."];
    [self.prompt setStyleClass:@"instruction_text"];
    [self.view addSubview:self.prompt];
    
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];
    
    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(85,240,30,30)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(125,240,30,30)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(165,240,30,30)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(205,240,30,30)];
    
    //self.first_num.alpha = self.second_num.alpha = self.third_num.alpha = self.fourth_num.alpha = 0.5;
    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 15;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 4;
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    int len = [textField.text length] + [string length];
    if([string length] == 0) //deleting
    {
        switch (len) {
            case 4:
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 3:
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 2:
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 1:
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 0:
                break;
            default:
                break;
        }
    }else{
        UIColor *which = kNoochGreen;
        switch (len) {
            case 5:
                return NO;
                break;
            case 4:
            {
                [self.fourth_num setBackgroundColor:which];
                serve *pin = [serve new];
                pin.Delegate = self;
                pin.tagName = @"ValidatePinNumber";
                [pin getEncrypt:[NSString stringWithFormat:@"%@%@",self.pin.text,string]];
                break;
            }
            case 3:
                [self.third_num setBackgroundColor:which];
                break;
            case 2:
                [self.second_num setBackgroundColor:which];
                break;
            case 1:
                [self.first_num setBackgroundColor:which];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    return YES;
}

- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"ValidatePinNumber"])
    {
        NSError* error;
        NSDictionary *dictResult= [NSJSONSerialization
                                   JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                   options:kNilOptions
                                   error:&error];
        
        NSString *encryptedPIN=[dictResult valueForKey:@"Status"];
        serve *checkValid = [serve new];
        checkValid.tagName = @"checkValid";
        checkValid.Delegate = self;
        [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
    }
    if ([tagName isEqualToString:@"check_pin"]) {
        NSLog(@"%@",result);
        if (true) {
            [nav_ctrl popToRootViewControllerAnimated:NO];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
