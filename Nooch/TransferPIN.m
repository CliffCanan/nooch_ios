//
//  TransferPIN.m
//  Nooch
//
//  Created by crks on 9/30/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "TransferPIN.h"
#import <QuartzCore/QuartzCore.h>

@interface TransferPIN ()
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSDictionary *receiver;
@property(nonatomic) float amnt;
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@end

@implementation TransferPIN

- (id)initWithReceiver:(NSMutableDictionary *)receiver type:(NSString *)type amount:(float)amount
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.type = type;
        self.receiver = receiver;
        self.amnt = amount;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];
    
    [self.navigationItem setTitle:@"PIN Confirmation"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 60)];
    [title setText:@"Enter Your PIN to confirm your"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"pin_instructiontext"];
    [self.view addSubview:title];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 30)];
    [self.prompt setText:@"transfer"]; [self.prompt setTextAlignment:NSTextAlignmentCenter];
    [self.prompt setStyleId:@"pin_instructiontext_send"];
    [self.view addSubview:self.prompt];
    
    UIView *back = [UIView new];
    [back setStyleClass:@"raised_view"];
    [back setStyleClass:@"pin_recipientbox"];
    [self.view addSubview:back];
    
    UIView *bar = [UIView new];
    [bar setStyleClass:@"pin_recipientname_bar"];
    [self.view addSubview:bar];
    
    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 300, 30)];
    if ([[self.receiver objectForKey:@"FirstName"] length] == 0) {
        [to_label setText:@"   4K For Cancer"];
        [to_label setBackgroundColor:kNoochPurple];
    } else {
        [to_label setText:[NSString stringWithFormat:@" %@ %@",[self.receiver objectForKey:@"FirstName"],[self.receiver objectForKey:@"LastName"]]];
    }
    [to_label setStyleClass:@"pin_recipientname_text"];
    [self.view addSubview:to_label];
    
    UILabel *memo_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 230, 300, 30)];
    if ([[self.receiver objectForKey:@"memo"] length] > 0) {
        [memo_label setText:[self.receiver objectForKey:@"memo"]];
    }else{
        [memo_label setText:@"No memo attached"];
    }
    [memo_label setTextAlignment:NSTextAlignmentCenter];
    [memo_label setStyleClass:@"pin_memotext"];
    [self.view addSubview:memo_label];
    
    UIImageView *user_pic = [UIImageView new];
    [user_pic setStyleClass:@"pin_recipientpic"];
    [user_pic setStyleCSS:@"background-image : url(Preston.png)"];
    [self.view addSubview:user_pic];
    
    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 290, 30)];
    [total setBackgroundColor:[UIColor clearColor]];
    [total setTextColor:[UIColor whiteColor]]; [total setTextAlignment:NSTextAlignmentRight];
    [total setText:[NSString stringWithFormat:@"$ %.02f",self.amnt]];
    [total setStyleClass:@"pin_amountfield"];
    [self.view addSubview:total];
    
    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(44,70,32,32)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(107,70,32,32)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(170,70,32,32)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(233,70,32,32)];
    
    //self.first_num.alpha = self.second_num.alpha = self.third_num.alpha = self.fourth_num.alpha = 0.5;
    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 16;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;
    if ([self.type isEqualToString:@"send"]) {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    }else if([self.type isEqualToString:@"request"]){
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;
    }
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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
        UIColor *which;
        if ([self.type isEqualToString:@"send"]) {
            which = kNoochGreen;
        }else if([self.type isEqualToString:@"request"]){
            which = kNoochBlue;
        }
        switch (len) {
            case 5:
                return NO;
                break;
            case 4:
                [self.fourth_num setBackgroundColor:which];
                //start pin validation
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
