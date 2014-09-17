//  ReferralCode.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "ReferralCode.h"
#import "Home.h"
#import "Welcome.h"
//#import "GetLocation.h"
#import "Register.h"
#import "ECSlidingViewController.h"
#import "SpinKit/RTSpinKitView.h"

@interface ReferralCode ()//<GetLocationDelegate>
{
    //GetLocation*getLocation;
}
@property(nonatomic,strong) NSMutableDictionary *user;
@property(nonatomic,strong) UITextField *code_field;
@property(nonatomic,strong) MBProgressHUD *hud;
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
-(void) BackClicked:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.trackedViewName = @"ReferralCode Screen";
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];
    
    UILabel * slogan = [[UILabel alloc] initWithFrame:CGRectMake(58, 90, 202, 19)];
    [slogan setBackgroundColor:[UIColor clearColor]];
    [slogan setText:@"Money Made Simple"];
    [slogan setFont:[UIFont fontWithName:@"VarelaRound-regular" size:15]];
    [slogan setStyleClass:@"prelogin_slogan"];
    [self.view addSubview:slogan];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 40)];
    [title setTextColor:kNoochGrayDark];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Enter Referral Code"];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];

    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 166, 280, 70)];
    [prompt setTextColor:kNoochGrayDark];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setNumberOfLines:3];
    [prompt setFont:[UIFont systemFontOfSize:14]];
    [prompt setText:@"Nooch is currently invite-only. If you have a Referral Code enter it below to sign up."]; [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setStyleClass:@"instruction_text"];
    [self.view addSubview:prompt];

    enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    enter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setTitle:@"Continue" forState:UIControlStateNormal];
    [enter addTarget:self action:@selector(enter_code) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 350, 300, 60)];
    [enter setStyleClass:@"button_green"];
    [self.view addSubview:enter];

    UIButton *request = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [request setFrame:CGRectMake(10, 420, 300, 60)];
    [request setTitleShadowColor:Rgb2UIColor(32, 33, 34, 0.22) forState:UIControlStateNormal];
    request.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [request setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [request setTitle:@"I Don't Have a Code" forState:UIControlStateNormal];
    [request addTarget:self action:@selector(request_code) forControlEvents:UIControlEventTouchUpInside];
    [request setStyleClass:@"button_gray"];
    [self.view addSubview:request];
    
    self.code_field = [[UITextField alloc] initWithFrame:CGRectMake(55, 250, 210, 60)];
    [self.code_field setBackgroundColor:[UIColor whiteColor]]; 
    [self.code_field setTextColor:kNoochGrayDark];
    self.code_field.inputAccessoryView = [[UIView alloc] init];
    [self.code_field setKeyboardType:UIKeyboardTypeAlphabet];
    [self.code_field setReturnKeyType:UIReturnKeyGo];
    [self.code_field setDelegate:self];
    [self.code_field setTextAlignment:NSTextAlignmentCenter];
    [self.code_field setFont:[UIFont systemFontOfSize:24]];
    [self.code_field setPlaceholder:@"ENTER CODE"];
    self.code_field.layer.borderWidth = 2;
    self.code_field.layer.borderColor = kNoochGrayLight.CGColor;
    [self.code_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.code_field setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    self.code_field.layer.borderColor = kNoochBlue.CGColor;
    self.code_field.layer.cornerRadius = 12;
    [self.view addSubview:self.code_field];
}

#pragma mark-Location Tracker Delegates

-(void)locationError:(NSError *)error{
    [[assist shared]setlocationAllowed:NO];
}

- (void)enter_code
{
    if ([self.code_field.text length] == 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Please Enter Invite Code" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [enter setEnabled:YES];
        return;
    }
    
    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = @"Validating your invite code";
    [self.hud show:YES];
    [spinner1 startAnimating];
    
    [enter setEnabled:NO];
    serve *inv_code = [serve new];
    [inv_code setDelegate:self];
    [inv_code setTagName:@"inv_check"];
    [inv_code validateInviteCode:[self.code_field.text uppercaseString]];
}

- (void)request_code
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Nooch Money" message:@"Thank you! We will be in touch with an invite code soon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    serve*serveobj=[serve new];
    [serveobj setDelegate:self];
    serveobj.tagName=@"requestcode";
    [serveobj ReferalCodeRequest:[self.user valueForKey:@"email"]];
}

- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError *error;
    
    if ([tagName isEqualToString:@"requestcode"])
    {
        self.slidingViewController.panGesture.enabled = NO;
        [nav_ctrl performSelector:@selector(reset)];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
    }
    else if ([tagName isEqualToString:@"inv_check"])
    {
        [self.hud hide:YES];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([[response objectForKey:@"validateInvitationCodeResult"] boolValue])
        {
            serve * serveOBJ = [serve new];
            [serveOBJ setDelegate:self];
            serveOBJ.tagName=@"validate";
            [serveOBJ getTotalReferralCode:self.code_field.text];
            self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:self.hud];
            self.hud.delegate = self;
            self.hud.labelText = @"Creating your Nooch account";
            [self.hud show:YES];
        }
        else
        {
            UIAlertView *avInvalidCode = [[UIAlertView alloc]initWithTitle:@"Not Quite Right" message:@"Please check your referral code to make sure you entered it correctly.  If you do not have a code, you can request one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Request Code", nil];
            [avInvalidCode setTag:88];
            [avInvalidCode show];
            [self.code_field becomeFirstResponder];
            [enter setEnabled:YES];
            [spinner stopAnimating];
            [spinner setHidden:YES];
        }
    }
    if ([tagName isEqualToString:@"validate"])
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([[[response valueForKey:@"getTotalReferralCodeResult"] valueForKey:@"Result"] isEqualToString:@"True"])
        {
            serve *create = [serve new];
            [create setDelegate:self];
            [create setTagName:@"encrypt"];
            [[assist shared]setPassValue:[self.user objectForKey:@"password"]];
            [create getEncrypt:[self.user objectForKey:@"password"]];
        }
        else
        {
            [self.hud hide:YES];
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Sorry! Referral Code Expired" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [enter setEnabled:YES];
            [spinner stopAnimating];
            [spinner setHidden:YES];
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
        
        if (![[loginResult objectForKey:@"Status"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"Status"]!=NULL) {
            getEncryptedPassword = [loginResult objectForKey:@"Status"];
        }
        
        [user setObject:[self.user objectForKey:@"first_name"] forKey:@"firstName"];
        [[NSUserDefaults standardUserDefaults]setObject:[self.user objectForKey:@"email"] forKey:@"UserName"];
        
        [create newUser:[self.user objectForKey:@"email"] first:[self.user objectForKey:@"first_name" ] last:[self.user objectForKey:@"last_name"] password:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] pin:[self.user objectForKey:@"pin_number"] invCode:self.code_field.text fbId:[self.user objectForKey:@"facebook_id"] ? [self.user objectForKey:@"facebook_id"]: @"" ];
        
        self.code_field.text = @"";
    }
    else if ([tagName isEqualToString:@"create_account"])
    {
        NSLog(@"login result %@",result);
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if([[[response objectForKey:@"MemberRegistrationResult"]objectForKey:@"Result"] isEqualToString:@"Thanks for registering! Check your email to complete activation."])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"asdfa" forKey:@"setPrompt"];
            serve *login = [serve new];
            login.Delegate = self;
            login.tagName = @"login";
        
         //   NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            NSString *udid=[[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"];
            [login login:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] password:getEncryptedPassword remember:YES lat:lat lon:lon uid:udid];
        }
        else if([[[response objectForKey:@"MemberRegistrationResult"] objectForKey:@"Result"] isEqualToString:@"You are already a nooch member."])
        {
            [self.hud hide:YES];
            UIAlertView *decline= [[UIAlertView alloc] initWithTitle:@"Well..." message:@"This address already exists in our system, we are not able to clone you, our apologies." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [decline show];
            [decline setTag:1];
            [enter setEnabled:YES];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            
            return;
        }
    }
    else if ([tagName isEqualToString:@"login"])
    {
        serve *req = [[serve alloc] init];
        req.Delegate = self;
        req.tagName = @"getMemId";
        [req getMemIdFromuUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    }

    if ([tagName isEqualToString:@"getMemId"])
    {
        [self.hud hide:YES];

        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",response);
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"Result"] forKey:@"MemberId"];
        me = [core new];
        [me birth];
        [me stamp];
        [spinner stopAnimating];
        [spinner setHidden:YES];
        Welcome *welc = [Welcome new];
        [self.navigationController pushViewController:welc animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 88)
    {
        if (buttonIndex == 1)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Nooch Money" message:@"Thank you! We will be in touch with an invite code soon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            serve*serveobj=[serve new];
            [serveobj setDelegate:self];
            serveobj.tagName=@"requestcode";
            [serveobj ReferalCodeRequest:[self.user valueForKey:@"email"]];
        }
        else
        {
            [[me usr] setObject:@"YES" forKey:@"requiredImmediately"];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else if (alertView.tag == 2)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (alertView.tag == 2022)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        me = [core new];
    }
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self enter_code];
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
