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
    self.screenName = @"ReferralCode Screen";
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];
    
    UILabel * slogan = [[UILabel alloc] initWithFrame:CGRectMake(75, 82, 170, 16)];
    [slogan setBackgroundColor:[UIColor clearColor]];
    [slogan setText:@"Money Made Simple"];
    [slogan setFont:[UIFont fontWithName:@"VarelaRound-Regular" size:15]];
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

    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 166, 300, 70)];
    [prompt setTextColor:kNoochGrayDark];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setNumberOfLines:3];
    [prompt setFont:[UIFont systemFontOfSize:14]];
    [prompt setText:@"Nooch is currently invite-only. If you have a Referral Code enter it below to finish creating your account."]; [prompt setTextAlignment:NSTextAlignmentCenter];
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
    [request setFrame:CGRectMake(10, 424, 300, 60)];
    [request setTitleShadowColor:Rgb2UIColor(32, 33, 34, 0.22) forState:UIControlStateNormal];
    request.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [request setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [request setTitle:@"I Don't Have a Code" forState:UIControlStateNormal];
    [request addTarget:self action:@selector(request_code) forControlEvents:UIControlEventTouchUpInside];
    [request setStyleClass:@"label_small"];
    [self.view addSubview:request];
    
    self.code_field = [[UITextField alloc] initWithFrame:CGRectMake(55, 250, 210, 60)];
    [self.code_field setBackgroundColor:[UIColor whiteColor]]; 
    [self.code_field setTextColor:kNoochGrayDark];
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
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Please Enter An Invite Code" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    
    [enter setEnabled:NO];
    serve *inv_code = [serve new];
    [inv_code setDelegate:self];
    [inv_code setTagName:@"inv_check"];
    [inv_code validateInviteCode:[self.code_field.text uppercaseString]];
}

- (void)request_code
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request An Invite Code" message:@"To make sure every Nooch user has the best experience, you must have an invite or referral code.\n\nYou can get a code from any current Nooch user, or request an invite directly from us. We try to send out codes as quickly as possible when they are requested." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Request Code", nil];
    [av show];
    [av setTag:101];
}

-(void)Error:(NSError *)Error{
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
    
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
            [self.hud hide:YES];
            RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
            spinner1.color = [UIColor whiteColor];
            self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:self.hud];
            
            self.hud.mode = MBProgressHUDModeCustomView;
            self.hud.customView = spinner1;
            //self.hud.delegate = self;
            self.hud.labelText = @"Creating your Nooch account";
            [self.hud show:YES];

            serve * serveOBJ = [serve new];
            [serveOBJ setDelegate:self];
            serveOBJ.tagName=@"validate";
            [serveOBJ getTotalReferralCode:self.code_field.text];
        }
        else
        {
            UIAlertView *avInvalidCode = [[UIAlertView alloc]initWithTitle:@"Not Quite Right" message:@"Please check your referral code to make sure you entered it correctly.  If you do not have a code, you can request one." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Request Code", nil];
            [avInvalidCode setTag:88];
            [avInvalidCode show];
            [self.code_field becomeFirstResponder];
            [enter setEnabled:YES];
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
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Expired Referral Code" message:@"Sorry, looks like that referral code is no longer valid.  Please try another or request a new code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [enter setEnabled:YES];
        }
        
    }
    else if ([tagName isEqualToString:@"encrypt"])
    {
        NSError *error;
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"email"] forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"first_name"] forKey:@"first_name"];
        [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"last_name"] forKey:@"last_name"];
        [[NSUserDefaults standardUserDefaults] setObject:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] forKey:@"password"];
        
        if ([self.user objectForKey:@"facebook_id"]) [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"facebook_id"] forKey:@"facebook_id"];
        
        if (![[loginResult objectForKey:@"Status"] isKindOfClass:[NSNull class]] &&
              [loginResult objectForKey:@"Status"] != NULL)
        {
            getEncryptedPassword = [loginResult objectForKey:@"Status"];
        }
        
        [user setObject:[self.user objectForKey:@"first_name"] forKey:@"firstName"];
        [[NSUserDefaults standardUserDefaults]setObject:[self.user objectForKey:@"email"] forKey:@"UserName"];
        
        serve *create = [serve new];
        [create setDelegate:self];
        [create setTagName:@"create_account"];
        [create newUser:[self.user objectForKey:@"email"] first:[self.user objectForKey:@"first_name" ] last:[self.user objectForKey:@"last_name"] password:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] pin:[self.user objectForKey:@"pin_number"] invCode:self.code_field.text fbId:[self.user objectForKey:@"facebook_id"] ? [self.user objectForKey:@"facebook_id"]: @"" ];
        
        self.code_field.text = @"";
    }
    else if ([tagName isEqualToString:@"create_account"])
    {
        NSLog(@"Login Result: %@",result);
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([[[response objectForKey:@"MemberRegistrationResult"]objectForKey:@"Result"] isEqualToString:@"Thanks for registering! Check your email to complete activation."])
        {
            NSString * udid = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"];
            serve * login = [serve new];
            login.Delegate = self;
            login.tagName = @"login";
            [login login:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] password:getEncryptedPassword remember:YES lat:lat lon:lon uid:udid];
        }
        else if ([[[response objectForKey:@"MemberRegistrationResult"] objectForKey:@"Result"] isEqualToString:@"You are already a nooch member."])
        {
            [self.hud hide:YES];
            UIAlertView *decline = [[UIAlertView alloc] initWithTitle:@"Well..." message:@"This address already exists in our system, we are not yet able to clone you, our apologies." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [decline show];
            [decline setTag:1];
            [enter setEnabled:YES];
            
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
        NSMutableDictionary * automatic = [[NSMutableDictionary alloc] init];
        [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"MemberId"];
        [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserName"] forKey:@"UserName"];
        [automatic writeToFile:[self autoLogin] atomically:YES];
        
        Welcome *welc = [Welcome new];
        [self.navigationController pushViewController:welc animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 88 || alertView.tag == 101)
    {
        if (buttonIndex == 1)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Received" message:@"Thank you! We will be in touch with an invite code soon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            serve * serveobj = [serve new];
            [serveobj setDelegate:self];
            serveobj.tagName = @"requestcode";
            [serveobj ReferalCodeRequest:[self.user valueForKey:@"email"]];
        }
        else
        {
            [[me usr] setObject:@"YES" forKey:@"requiredImmediately"];
        }

        [self dismissViewControllerAnimated:YES completion:nil];
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
