//
//  ReferralCode.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "ReferralCode.h"
#import "Home.h"
#import "Welcome.h"

@interface ReferralCode ()
@property(nonatomic,strong) NSMutableDictionary *user;
@property(nonatomic,strong) UITextField *code_field;
@end

@implementation ReferralCode

- (id)initWithData:(NSDictionary *)usr
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.user = [usr mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    [title setTextColor:kNoochGrayDark]; [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Enter Referral Code"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, 280, 70)];
    [prompt setTextColor:kNoochGrayDark]; [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setNumberOfLines:3];
    [prompt setFont:[UIFont systemFontOfSize:14]];
    [prompt setText:@"Nooch is currently invite only. If you have a referral code enter it below to sign up."]; [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setStyleClass:@"instruction_text"];
    [self.view addSubview:prompt];
    
    UIButton *enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setBackgroundColor:kNoochGreen];
    [enter setTitle:@"Continue" forState:UIControlStateNormal];
    [enter addTarget:self action:@selector(enter_code) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 350, 300, 60)];
    [enter setStyleClass:@"button_green"];
    [self.view addSubview:enter];
    
    UIButton *request = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [request setFrame:CGRectMake(10, 420, 300, 60)];
    [request setBackgroundColor:kNoochGrayLight];
    [request setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [request setTitle:@"Don't Have a Code" forState:UIControlStateNormal];
    [request addTarget:self action:@selector(request_code) forControlEvents:UIControlEventTouchUpInside];
    [request setStyleClass:@"button_gray"];
    [self.view addSubview:request];
    
    self.code_field = [[UITextField alloc] initWithFrame:CGRectMake(55, 250, 210, 60)];
    [self.code_field setBackgroundColor:[UIColor whiteColor]]; [self.code_field setTextColor:kNoochGrayLight];
    [self.code_field setKeyboardType:UIKeyboardTypeAlphabet]; [self.code_field setDelegate:self];
    [self.code_field setTextAlignment:NSTextAlignmentCenter]; [self.code_field setPlaceholder:@"ENTER CODE"];
    self.code_field.layer.borderWidth = 1; self.code_field.layer.borderColor = kNoochGrayLight.CGColor;
    self.code_field.layer.cornerRadius = 2;
    [self.code_field setAutocorrectionType:UITextAutocorrectionTypeNo]; [self.code_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.code_field.layer.borderColor = kNoochBlue.CGColor;
    self.code_field.layer.cornerRadius = 15;
    [self.view addSubview:self.code_field];
}

- (void)enter_code
{
    ///delete when server communication is done
    //Welcome *welc = [Welcome new];
    //[self.navigationController pushViewController:welc animated:YES];
    ///end delete
    
    serve *inv_code = [serve new];
    [inv_code setDelegate:self];
    [inv_code setTagName:@"inv_check"];
    [inv_code validateInviteCode:self.code_field.text];
}

- (void)request_code
{
    
}

- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"inv_check"]) {
        NSError *error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([[response objectForKey:@"validateInvitationCodeResult"] boolValue]) {
            serve *create = [serve new];
            [create setDelegate:self];
            [create setTagName:@"encrypt"];
            [create getEncrypt:[self.user objectForKey:@"password"]];
        } else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Code" message:@"The referall code you entered is invalid. Please try again or request a code if you do not have one." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
     else if ([tagName isEqualToString:@"encrypt"])
     {
         serve *create = [serve new];
         [create setDelegate:self];
         [create setTagName:@"create_account"];
         NSError *error;
         NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
         [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"email"] forKey:@"email"];
         [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"first_name"] forKey:@"first_name"];
         [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"last_name"] forKey:@"last_name"];
         [[NSUserDefaults standardUserDefaults] setObject:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] forKey:@"password"];
         if ([self.user objectForKey:@"facebook_id"]) [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"facebook_id"] forKey:@"facebook_id"];
         
         [create newUser:[self.user objectForKey:@"email"] first:[self.user objectForKey:@"first_name" ] last:[self.user objectForKey:@"last_name"] password:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] pin:[self.user objectForKey:@"pin_number"] invCode:self.code_field.text fbId:[self.user objectForKey:@"facebook_id"] ? [self.user objectForKey:@"facebook_id"] : @""];
     }
    else if ([tagName isEqualToString:@"create_account"])
    {
        Welcome *welc = [Welcome new];
        [self.navigationController pushViewController:welc animated:YES];
    }
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //int len = [textField.text length] + [string length];
    if([string length] == 0) //deleting
    {
        
    }else{
        
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
