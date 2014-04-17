//  CreatePIN.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "CreatePIN.h"
#import "Home.h"
#import "ReferralCode.h"

@interface CreatePIN ()
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@property(nonatomic,strong) NSString *pin_check;
@property(nonatomic,strong) NSMutableDictionary *user;
@end

@implementation CreatePIN

- (id)initWithData:(NSDictionary *)usr
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.user = [usr mutableCopy];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.pin_check = @"";
    [self.pin setText:@""];
    [self.first_num setBackgroundColor:[UIColor clearColor]];
    [self.second_num setBackgroundColor:[UIColor clearColor]];
    [self.third_num setBackgroundColor:[UIColor clearColor]];
    [self.fourth_num setBackgroundColor:[UIColor clearColor]];
    [self.prompt setText:@"You'll be asked to enter this PIN anytime you send or request money."];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    int len = [textField.text length] + [string length];
    if([string length] == 0) { //deleting {
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
    }
    else{
        UIColor *which = kNoochGreen;
        switch (len) {
            case 5:
                return NO;
                break;
            case 4:
                [self.fourth_num setBackgroundColor:which];
                if ([self.pin_check length] != 4) {
                    self.pin_check = [NSString stringWithFormat:@"%@%@",textField.text,string];
                    [self.prompt setText:@"Confirm Your PIN"];
                    [self.pin setText:@""];
                    [self.first_num setBackgroundColor:[UIColor clearColor]];
                    [self.second_num setBackgroundColor:[UIColor clearColor]];
                    [self.third_num setBackgroundColor:[UIColor clearColor]];
                    [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                    return NO;
                }
                else{
                    if ([self.pin_check isEqualToString:[NSString stringWithFormat:@"%@%@",textField.text,string]]) {
                        [self.user setObject:[NSString stringWithFormat:@"%@%@",textField.text,string] forKey:@"pin_number"];
                        //push invite code
                        ReferralCode *code_entry = [[ReferralCode alloc] initWithData:self.user];
                        [self.navigationController pushViewController:code_entry animated:YES];
                    }else{
                        self.pin_check = @"";
                        [self.pin setText:@""];
                        [self.prompt setText:@"The PINs you entered did not match! Please try again."];
                        [self.first_num setBackgroundColor:[UIColor clearColor]];
                        [self.second_num setBackgroundColor:[UIColor clearColor]];
                        [self.third_num setBackgroundColor:[UIColor clearColor]];
                        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                        return NO;
                    }
                }
                break;
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
-(void) BackClicked:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton* btnback=[UIButton buttonWithType:UIButtonTypeCustom];

    [btnback setImage:[UIImage imageNamed:@"back-arrow-blue.png"] forState:UIControlStateNormal];
    [btnback setStyleClass:@"back_button-icon"];
    btnback.frame=CGRectMake(0, 7, 50, 30);
    [btnback addTarget:self action:@selector(BackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnback];
    self.pin_check = @"";
    [self.view setBackgroundColor:[UIColor whiteColor]];

    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];

    [self.navigationItem setTitle:@"Create PIN"];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    [title setText:@"Create your PIN"];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];

    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 280, 50)];
    [self.prompt setNumberOfLines:2];
    [self.prompt setText:@"You'll be asked to enter this PIN anytime you send or request money."];
    [self.prompt setStyleClass:@"instruction_text"];
    [self.view addSubview:self.prompt];
    
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];

    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(76,250,30,30)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(122,250,30,30)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(168,250,30,30)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(214,250,30,30)];

    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        self.first_num = [[UIView alloc] initWithFrame:CGRectMake(76,230,30,30)];
        self.second_num = [[UIView alloc] initWithFrame:CGRectMake(122,230,30,30)];
        self.third_num = [[UIView alloc] initWithFrame:CGRectMake(168,230,30,30)];
        self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(214,230,30,30)];
    }

    //self.first_num.alpha = self.second_num.alpha = self.third_num.alpha = self.fourth_num.alpha = 0.5;
    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 15;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 4;
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end