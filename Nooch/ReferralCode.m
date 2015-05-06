//  ReferralCode.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "ReferralCode.h"
#import "Home.h"
#import "Welcome.h"
#import "Register.h"
#import "ECSlidingViewController.h"
#import "SpinKit/RTSpinKitView.h"

@interface ReferralCode ()

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Referral Code Screen";
    self.artisanNameTag = @"Referral Code Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];

    UILabel * slogan = [[UILabel alloc] initWithFrame:CGRectMake(75, 82, 170, 16)];
    [slogan setBackgroundColor:[UIColor clearColor]];
    NSString * sloganFromArtisan = [ARPowerHookManager getValueForHookById:@"slogan"];
    [slogan setText:sloganFromArtisan];
    [slogan setFont:[UIFont fontWithName:@"VarelaRound-Regular" size:15]];
    [slogan setStyleClass:@"prelogin_slogan"];
    [self.view addSubview:slogan];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 40)];
    [title setTextColor:kNoochGrayDark];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:NSLocalizedString(@"ReferCode_HdrTxt", @"'Enter Referral Code' Header Text")];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];

    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 166, 300, 70)];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setNumberOfLines:3];
    [prompt setText:NSLocalizedString(@"ReferCode_Instruct", @"Referral Code screen instruction Text")];
    [prompt setStyleClass:@"instruction_text"];
    [self.view addSubview:prompt];

    enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    enter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setTitle:NSLocalizedString(@"ReferCode_SbmtBtn", @"'Submit' Button Text") forState:UIControlStateNormal];
    [enter addTarget:self action:@selector(enter_code) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 350, 300, 60)];
    [enter setStyleClass:@"button_green"];
    [self.view addSubview:enter];

    UIButton *request = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [request setFrame:CGRectMake(10, 424, 300, 60)];
    [request setTitle:NSLocalizedString(@"ReferCode_DntHvCodeTxt", @"'I Don't Have a Code' Button Text") forState:UIControlStateNormal];
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
    [self.code_field setPlaceholder:NSLocalizedString(@"ReferCode_PlchldrTxt", @"'ENTER CODE' Placeholder Text")];
    self.code_field.layer.borderWidth = 2;
    self.code_field.layer.borderColor = kNoochGrayLight.CGColor;
    [self.code_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.code_field setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    self.code_field.layer.borderColor = kNoochBlue.CGColor;
    self.code_field.layer.cornerRadius = 12;
    [self.view addSubview:self.code_field];
}

#pragma mark-Location Tracker Delegates

-(void)locationError:(NSError *)error
{
    NSLog(@"LocationManager didFailWithError %@", error);
    [[assist shared]setlocationAllowed:NO];
}

- (void)enter_code
{
    if ([self.code_field.text length] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ReferCode_EntrCodeAlrtTtl", @"'Please Enter An Invite Code' Alert Title")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
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
    self.hud.labelText = NSLocalizedString(@"ReferCode_HUDlbl1", @"'Validating your code' HUD Label");
    [self.hud show:YES];

    [enter setEnabled:NO];
    serve *inv_code = [serve new];
    [inv_code setDelegate:self];
    [inv_code setTagName:@"inv_check"];
    [inv_code validateInviteCode:[self.code_field.text uppercaseString]];
}

- (void)request_code
{
    NSString * requireCodeSettingFromArtisan = [ARPowerHookManager getValueForHookById:@"reqCodeSetting"];
    if ([requireCodeSettingFromArtisan isEqualToString:@"yes"])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReferCode_RqstCdAlrtTtl", @"'Request An Invite Code' Alert Title")
                                                     message:NSLocalizedString(@"ReferCode_RqstCdAlrtBody", @"'Request An Invite Code' Alert Body")
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:NSLocalizedString(@"ReferCode_RqstCdAlrtBtn", @"'Request code' Alert Button"), nil];
        [av show];
        [av setTag:101];
    }

    else
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];

        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.labelText = @"";
        [self.hud show:YES];

        [enter setEnabled:NO];

        refCodeFromArtisan = [ARPowerHookManager getValueForHookById:@"refCode"];
        serve * inv_code = [serve new];
        [inv_code setDelegate:self];
        [inv_code setTagName:@"inv_check"];
        [inv_code validateInviteCode:[refCodeFromArtisan uppercaseString]];
    }
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"ReferCode_CnctnErrAlrtTitle", @"Referral Code screen 'Connection Error' Alert Text")
                          message:NSLocalizedString(@"ReferCode_CnctnErrAlrtBody", @"Referral Code screen Connection Error Alert Body Text")//@"Looks like we're having trouble finding an internet connection! Please try again."
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
            self.hud.labelText = NSLocalizedString(@"ReferCode_HUDlbl2", @"'Creating your Nooch account...' HUD Label");
            [self.hud show:YES];

            serve * serveOBJ = [serve new];
            [serveOBJ setDelegate:self];
            serveOBJ.tagName = @"validate";
            if ([self.code_field.text length] > 0)
            {
                [serveOBJ getTotalReferralCode:self.code_field.text];
            }
            else
            {
                [serveOBJ getTotalReferralCode:refCodeFromArtisan];
            }

        }
        else
        {
            UIAlertView *avInvalidCode = [[UIAlertView alloc]initWithTitle:@"Not Quite Right"
                                                                   message:@"We don't recognize that referral code. Please check to make sure you entered it correctly.  If you do not have a code, you can request one."
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:@"Request Code", nil];
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
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ReferCode_ExprdAlrtTtl", @"'Expired Code' Alert Title")
                                                            message:NSLocalizedString(@"ReferCode_ExprdAlrtBody", @"'Expired Code' Alert Body")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            [enter setEnabled:YES];
        }
    }

    else if ([tagName isEqualToString:@"encrypt"])
    {
        NSError *error;
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        [user setObject:[self.user objectForKey:@"email"] forKey:@"UserName"];
        [user setObject:[self.user objectForKey:@"first_name"] forKey:@"FirstName"];
        [user setObject:[self.user objectForKey:@"last_name"] forKey:@"last_name"];
        [user setObject:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] forKey:@"password"];

        if ([self.user objectForKey:@"facebook_id"])
        {
            [user setObject:[self.user objectForKey:@"facebook_id"] forKey:@"facebook_id"];
        }
    
        if (![[loginResult objectForKey:@"Status"] isKindOfClass:[NSNull class]] &&
              [loginResult objectForKey:@"Status"] != NULL)
        {
            getEncryptedPassword = [loginResult objectForKey:@"Status"];
        }

        serve * create = [serve new];
        [create setDelegate:self];
        [create setTagName:@"create_account"];
        [create newUser:[self.user objectForKey:@"email"]
                  first:[self.user objectForKey:@"first_name" ]
                   last:[self.user objectForKey:@"last_name"]
               password:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]]
                    pin:[self.user objectForKey:@"pin_number"]
                invCode:[self.code_field.text length] == 0 ? refCodeFromArtisan : self.code_field.text
                   fbId:[self.user objectForKey:@"facebook_id"] ? [self.user objectForKey:@"facebook_id"]: @"" ];

        // NSLog(@"User Fields to be sent to server are: %@",create);
        self.code_field.text = @"";
        [user synchronize];
    }
    else if ([tagName isEqualToString:@"create_account"])
    {
        NSLog(@"Login Result: %@",result);
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([[[response objectForKey:@"MemberRegistrationResult"]objectForKey:@"Result"] isEqualToString:@"Thanks for registering! Check your email to complete activation."])
        {
            NSString * udid = [user valueForKey:@"DeviceToken"];
            serve * login = [serve new];
            login.Delegate = self;
            login.tagName = @"login";
            [login login:[user objectForKey:@"UserName"] password:getEncryptedPassword remember:YES lat:lat lon:lon uid:udid];
        }
        else if ([[[response objectForKey:@"MemberRegistrationResult"] objectForKey:@"Result"] isEqualToString:@"You are already a nooch member."])
        {
            [self.hud hide:YES];
            UIAlertView *decline = [[UIAlertView alloc] initWithTitle:@"Well..."
                                                              message:@"This address already exists in our system, we are not yet able to clone you, our apologies."
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
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
        [req getMemIdFromuUsername:[user objectForKey:@"UserName"]];
    }

    if ([tagName isEqualToString:@"getMemId"])
    {
        [self.hud hide:YES];

        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",response);
        [user setObject:[response objectForKey:@"Result"] forKey:@"MemberId"];

        me = [core new];
        [me birth];
        [me stamp];

        NSMutableDictionary * automatic = [[NSMutableDictionary alloc] init];
        [automatic setObject:[user valueForKey:@"MemberId"] forKey:@"MemberId"];
        [automatic setObject:[user valueForKey:@"UserName"] forKey:@"UserName"];
        [automatic writeToFile:[self autoLogin] atomically:YES];

        Welcome * welc = [Welcome new];
        [self.navigationController pushViewController:welc animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 88 || alertView.tag == 101)
    {
        if (buttonIndex == 1)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Received"
                                                         message:@"Thank you! We will be in touch with an invite code soon."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
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
