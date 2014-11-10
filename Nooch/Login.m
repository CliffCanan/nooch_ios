//  Login.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch. All rights reserved.


#import "Login.h"
#import "core.h"
#import "Home.h"
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "InitSliding.h"
#import "NavControl.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+IdentifierAddition.h"
#import "SpinKit/RTSpinKitView.h"
#import <FacebookSDK/FacebookSDK.h>
@interface Login ()<FBLoginViewDelegate>{
    core*me;
    NSString*email_fb,*fbID;
}
@property(nonatomic,strong) UITextField *email;
@property(nonatomic,strong) UITextField *password;
@property(nonatomic,strong) UISwitch *stay_logged_in;
@property(nonatomic,strong) UIButton *login;
@property(nonatomic,strong) NSString *encrypted_pass;
@property(nonatomic,strong) MBProgressHUD *hud;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@end

@implementation Login
@synthesize inputAccessory;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)check_credentials
{
    if ([self.email.text length] > 0 &&
        [self.email.text rangeOfString:@"@"].location != NSNotFound &&
        [self.email.text  rangeOfString:@"."].location != NSNotFound &&
        [self.password.text length] > 5)
    {
        RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        self.hud.labelText = @"Checking Login Credentials...";
        [self.hud show:YES];

        serve *log = [serve new];
        [log setDelegate:self];
        [log setTagName:@"encrypt"];
        [[assist shared]setPassValue:self.password.text];
        [log getEncrypt:self.password.text];
    }
    else
    {
        if ([UIAlertController class]) // for iOS 8
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Please Enter Email And Password"
                                         message:@"We can't log you in if we don't know who you are!"
                                         preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction * ok = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                  }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else  // for iOS 7 and prior
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Please Enter Email And Password" message:@"We can't log you in if we don't know who you are!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }
    }
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied){
        NSLog(@"Error : %@",error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [manager stopUpdatingLocation];

    CLLocationCoordinate2D loc = [newLocation coordinate];
    lat = [[[NSString alloc] initWithFormat:@"%f",loc.latitude] floatValue];
    lon = [[[NSString alloc] initWithFormat:@"%f",loc.longitude] floatValue];
    [locationManager stopUpdatingLocation];
}

-(void) BackClicked:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     self.screenName = @"Login Screen";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //back button
    UIButton *btnback = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnback setBackgroundColor:[UIColor whiteColor]];
    [btnback setFrame:CGRectMake(7, -18, 44, 44)];
    [btnback addTarget:self action:@selector(BackClicked:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *glyph_back = [UILabel new];
    [glyph_back setBackgroundColor:[UIColor clearColor]];
    [glyph_back setFont:[UIFont fontWithName:@"FontAwesome" size:26]];
    [glyph_back setTextAlignment:NSTextAlignmentCenter];
    [glyph_back setFrame:CGRectMake(0, 14, 44, 44)];
    [glyph_back setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-circle-o-left"]];
    [glyph_back setTextColor:kNoochBlue];
    [btnback addSubview:glyph_back];

    [self.view addSubview:btnback];

    [UIView animateKeyframesWithDuration:.2
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [btnback setFrame:CGRectMake(7, 18, 44, 44)];
                                  }];
                              } completion: nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Close the session and remove the access token from the cache
    // The session state handler (in the app delegate) will be called automatically
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];

    isloginWithFB=NO;
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginview = [[FBLoginView alloc] init];
    loginview.frame = CGRectMake(19, 108, 282, 52);
    //loginview.frame = CGRectOffset(loginview.frame, 5, 5);

#ifdef __IPHONE_7_0
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        //loginview.frame = CGRectOffset(loginview.frame, 5, 25);
    }
#endif
#endif
#endif

    loginview.delegate = self;
    //[loginview sizeToFit];
    [self.view addSubview:loginview];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo_loginScreen"];
    [self.view addSubview:logo];
    
    if ([[UIScreen mainScreen] bounds].size.height > 500)
    {
        UILabel * slogan = [[UILabel alloc] initWithFrame:CGRectMake(90, 73, 140, 15)];
        [slogan setBackgroundColor:[UIColor clearColor]];
        [slogan setText:@"Money Made Simple"];
        [slogan setFont:[UIFont fontWithName:@"VarelaRound-Regular" size:15]];
        [slogan setStyleClass:@"prelogin_slogan"];
        [slogan setStyleClass:@"prelogin_slogan_loginScreen"];
        [self.view addSubview:slogan];
    }

    //[self.navigationItem setTitle:@"Log In"];

    self.email = [[UITextField alloc] initWithFrame:CGRectMake(30, 165, 300, 40)];
    [self.email setBackgroundColor:[UIColor clearColor]];
    [self.email setPlaceholder:@"email@example.com"];
    self.email.inputAccessoryView = [[UIView alloc] init];
    [self.email setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.email setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.email setReturnKeyType:UIReturnKeyNext];
    [self.email setTextAlignment:NSTextAlignmentRight];
    [self.email becomeFirstResponder];
    [self.email setDelegate:self];
    [self.email setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.email];

    UILabel *em = [UILabel new];
    [em setStyleClass:@"table_view_cell_textlabel_1"];
    CGRect frame = em.frame;
    frame.origin.y = 165;
    [em setFrame:frame];
    [em setBackgroundColor:[UIColor clearColor]];
    [em setText:@"Email"];
    [self.view addSubview:em];

    self.password = [[UITextField alloc] initWithFrame:CGRectMake(30, 207, 260, 40)];
    [self.password setBackgroundColor:[UIColor clearColor]];
    [self.password setPlaceholder:@"Password"];
    self.password.inputAccessoryView = [[UIView alloc] init];
    [self.password setSecureTextEntry:YES];
    [self.password setTextAlignment:NSTextAlignmentRight];
    [self.password setReturnKeyType:UIReturnKeyGo];
    [self.password setDelegate:self];
    [self.password setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.password];

    UILabel *pass = [UILabel new];
    [pass setStyleClass:@"table_view_cell_textlabel_1"];
    frame = pass.frame;
    frame.origin.y = 207;
    [pass setFrame:frame];
    [pass setText:@"Password"];
    [self.view addSubview:pass];

    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.login setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    self.login.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.login setTitle:@"Log In  " forState:UIControlStateNormal];
    [self.login setFrame:CGRectMake(10, 263, 300, 60)];
    [self.login addTarget:self action:@selector(check_credentials) forControlEvents:UIControlEventTouchUpInside];
    [self.login setStyleClass:@"button_green"];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

    UILabel *glyphLogin = [UILabel new];
    [glyphLogin setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [glyphLogin setFrame:CGRectMake(180, 9, 26, 30)];
    glyphLogin.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-sign-in"] attributes:textAttributes1];
    [glyphLogin setTextColor:[UIColor whiteColor]];

    [self.login addSubview:glyphLogin];
    [self.view addSubview:self.login];
    [self.login setEnabled:NO];

    self.stay_logged_in = [[UISwitch alloc] initWithFrame:CGRectMake(110, 319, 34, 21)];
    [self.stay_logged_in setStyleClass:@"login_switch"];
    [self.stay_logged_in setOnTintColor:kNoochBlue];
    [self.stay_logged_in setOn: YES];
    self.stay_logged_in.transform = CGAffineTransformMakeScale(0.8, 0.8);

    UILabel *remember_me = [[UILabel alloc] initWithFrame:CGRectMake(19, 320, 140, 30)];
    [remember_me setText:@"Remember Me"];
    [remember_me setStyleId:@"label_rememberme"];

    UIButton *forgot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [forgot setBackgroundColor:[UIColor clearColor]];
    [forgot setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [forgot setFrame:CGRectMake(190, 320, 120, 30)];
    [forgot addTarget:self action:@selector(forgot_pass) forControlEvents:UIControlEventTouchUpInside];
    [forgot setStyleId:@"label_forgotpw"];

    UILabel *encryption; [encryption setStyleId:@"label_encryption"];

    UIImageView *encrypt_icon;
    [encrypt_icon setStyleId:@"icon_encryption"];
    
    
    // Height adjustments for 3.5" screens
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [em setFrame:CGRectMake(20, 95, 100, 20)];
        [pass setFrame:CGRectMake(20, 130, 102, 20)];
        
        CGRect frameEmailTextField = self.email.frame;
        frameEmailTextField.origin.y = 95;
        [self.email setFrame:frameEmailTextField];

        CGRect framePassTextField = self.password.frame;
        framePassTextField.origin.y = 130;
        [self.password setFrame:framePassTextField];

        [self.login setFrame:CGRectMake(20, 180, 300, 60)];
        [forgot setFrame:CGRectMake(190, 234, 120, 30)];
        [remember_me setFrame:CGRectMake(19, 234, 140, 30)];
        [self.stay_logged_in setFrame:CGRectMake(115, 235, 34, 21)];
        self.stay_logged_in.transform = CGAffineTransformMakeScale(0.75, 0.72);
    }
    [self.view addSubview:self.stay_logged_in];
    [self.view addSubview:remember_me];
    [self.view addSubview:forgot];
    [self.view addSubview:encryption];
    [self.view addSubview:encrypt_icon];
}

- (void) forgot_pass
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Please enter your email and we will send you a reset link." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setText:self.email.text];
    [alert setTag:220011];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 220011 && buttonIndex == 1)
    {
        UITextField *emailField = [actionSheet textFieldAtIndex:0];
        
        if ([emailField.text length] > 0 &&
            [emailField.text  rangeOfString:@"@"].location != NSNotFound &&
            [emailField.text  rangeOfString:@"."].location != NSNotFound)
        {
            RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleBounce];
            spinner1.color = [UIColor whiteColor];
            self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:self.hud];
            
            self.hud.mode = MBProgressHUDModeCustomView;
            self.hud.customView = spinner1;
            self.hud.delegate = self;
            self.hud.labelText = @"Working hard...";
            [self.hud show:YES];

            serve * forgetful = [serve new];
            forgetful.Delegate = self;
            forgetful.tagName = @"ForgotPass";
            [forgetful forgotPass:emailField.text];   
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Enter Valid Email ID" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert setTag:220011];
            [alert show];
        }
    }

    else if (actionSheet.tag == 220011 && buttonIndex == 0)
    {
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
    else if (actionSheet.tag == 568 && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ((actionSheet.tag == 50 || actionSheet.tag == 500 || actionSheet.tag == 600) && buttonIndex == 1)
    {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have an email account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        
        [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else if (actionSheet.tag == 510 && buttonIndex == 1) {
        [self forgot_pass];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            
            [alert setTitle:@"Email Draft Saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            
            [alert setTitle:@"Email Sent Successfully"];
            [alert show];
            
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"The internet is busy right now... please try again."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    if([tagName isEqualToString:@"ForgotPass"])
    {
        [self.hud hide:YES];
        if ([UIAlertController class]) // for iOS 8
        {
            UIAlertController * alert = [UIAlertController
                                    alertControllerWithTitle:@"Reset Link Sent"
                                    message:@"Please check your email for a reset password link."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
            UIAlertAction * ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
            [alert addAction:ok];
        
            [self presentViewController:alert animated:YES completion:nil];
        }
        else // iOS 7 and prior
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Please check your email for a reset password link." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        [spinner stopAnimating];
        [spinner setHidden:YES];
    }
    
    else if ([tagName isEqualToString:@"encrypt"])
    {
        NSError *error;
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        self.encrypted_pass = [[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]];
        
        serve * log = [serve new];
        [log setDelegate:self];
        [log setTagName:@"login"];
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstName"];
        NSString * udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        [[assist shared]setlocationAllowed:YES];
        [[NSUserDefaults standardUserDefaults] setObject:self.email.text forKey:@"email"];

        if ([self.stay_logged_in isOn]) {
            [log login:[self.email.text lowercaseString] password:self.encrypted_pass remember:YES lat:lat lon:lon uid:udid];
        }
        else {
            [log login:[self.email.text lowercaseString] password:self.encrypted_pass remember:NO lat:lat lon:lon uid:udid];
        }
    }

    else if ([tagName isEqualToString:@"loginwithFB"])
    {
        NSError * error;
        NSDictionary * loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        NSLog(@"LoginwithFB Result is: %@",[loginResult objectForKey:@"Result"]);

        if ([[loginResult objectForKey:@"Result"] isEqualToString:@"FBID or EmailId not registered with Nooch"])
        {
            [self.hud hide:YES];
            [FBSession.activeSession closeAndClearTokenInformation];
            [FBSession.activeSession close];
            [FBSession setActiveSession:nil];

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Facebook Login Failed" message:@"Your Facebook account is not associated with a Nooch account.\nWould you like to create a Nooch account now?" delegate:self cancelButtonTitle:@"Register Now" otherButtonTitles:@"Cancel", nil];
            [alert setTag:568];
            [alert show];
            return;
        }
        
        if (  [loginResult objectForKey:@"Result"] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Invalid user id or password."] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"The password you have entered is incorrect."] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] &&
            [[loginResult objectForKey:@"Result"] rangeOfString:@"Your account has been temporarily blocked."].location == NSNotFound &&
            loginResult != nil)
        {
            serve * getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberId";
            [getDetails getMemIdFromuUsername:email_fb];
        }
        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] rangeOfString:@"Your account has been temporarily blocked."].location != NSNotFound &&
                 loginResult != nil)
        {
            [self.hud hide:YES];
            
            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Account Temporarily Suspended"
                                             message:@"To keep Nooch safe your account has been temporarily suspended because you entered an incorrect password too many times.\n\nIn most cases your account will be automatically un-suspended in 24 hours. You can always contact support if this is a mistake or error.\n\nWe apologize for this inconvenience, please understand it is only to protect your account."
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
                UIAlertAction * contactSupport = [UIAlertAction
                                                  actionWithTitle:@"Contact Support"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                                  {
                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                      if (![MFMailComposeViewController canSendMail]){
                                                          UIAlertController * alert = [UIAlertController
                                                                                       alertControllerWithTitle:@"No Email Detected"
                                                                                       message:@"You don't have an email account configured for this device."
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                                          
                                                          UIAlertAction * ok = [UIAlertAction
                                                                                actionWithTitle:@"OK"
                                                                                style:UIAlertActionStyleDefault
                                                                                handler:^(UIAlertAction * action)
                                                                                {
                                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                }];
                                                          [alert addAction:ok];
                                                          
                                                          [self presentViewController:alert animated:YES completion:nil];
                                                          return;
                                                      }
                                                      MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                                                      mailComposer.mailComposeDelegate = self;
                                                      mailComposer.navigationBar.tintColor=[UIColor whiteColor];
                                                      
                                                      [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
                                                      
                                                      [mailComposer setMessageBody:@"" isHTML:NO];
                                                      [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
                                                      [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                                                      [self presentViewController:mailComposer animated:YES completion:nil];
                                                  }];
                [alert addAction:ok];
                [alert addAction:contactSupport];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"To keep Nooch safe your account has been temporarily suspended because you entered an incorrect password too many times.\n\nIn most cases your account will be automatically un-suspended in 24 hours. You can always contact support if this is a mistake or error.\n\nWe apologize for this inconvenience, please understand it is only to protect your account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
                [alert setTag:600];
                [alert show];
            }
            [spinner stopAnimating];
        }
        
        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] && loginResult != nil)
        {
            [self.hud hide:YES];
            
            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Account Suspended"
                                             message:@"Your account has been temporarily suspended pending a review. We will contact you as soon as possible, and you can always contact us via email if this is a mistake or error."
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
                UIAlertAction * contactSupport = [UIAlertAction
                                                  actionWithTitle:@"Contact Support"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                                  {
                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                      if (![MFMailComposeViewController canSendMail]){
                                                          UIAlertController * alert = [UIAlertController
                                                                                       alertControllerWithTitle:@"No Email Detected"
                                                                                       message:@"You don't have an email account configured for this device."
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                                          
                                                          UIAlertAction * ok = [UIAlertAction
                                                                                actionWithTitle:@"OK"
                                                                                style:UIAlertActionStyleDefault
                                                                                handler:^(UIAlertAction * action)
                                                                                {
                                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                }];
                                                          [alert addAction:ok];
                                                          
                                                          [self presentViewController:alert animated:YES completion:nil];
                                                          return;
                                                      }
                                                      MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                                                      mailComposer.mailComposeDelegate = self;
                                                      mailComposer.navigationBar.tintColor=[UIColor whiteColor];
                                                      
                                                      [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
                                                      
                                                      [mailComposer setMessageBody:@"" isHTML:NO];
                                                      [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
                                                      [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                                                      [self presentViewController:mailComposer animated:YES completion:nil];
                                                  }];
                [alert addAction:ok];
                [alert addAction:contactSupport];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Suspended" message:@"Your account has been temporarily suspended pending a review. We will contact you as soon as possible, and you can always contact us via email if this is a mistake or error." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
                [alert setTag:500];
                [alert show];
            }
            [spinner stopAnimating];
        }
        
        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] && loginResult != nil)
        {
            [spinner stopAnimating];
            [self.hud hide:YES];
            
            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Account Temporarily Suspended"
                                             message:@"For security your account has been temporarily suspended.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com if you would like more information."
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
                UIAlertAction * contactSupport = [UIAlertAction
                                                  actionWithTitle:@"Contact Support"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                                  {
                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                      if (![MFMailComposeViewController canSendMail]) {
                                                          UIAlertController * alert = [UIAlertController
                                                                                       alertControllerWithTitle:@"No Email Detected"
                                                                                       message:@"You don't have an email account configured for this device."
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                                          
                                                          UIAlertAction * ok = [UIAlertAction
                                                                                actionWithTitle:@"OK"
                                                                                style:UIAlertActionStyleDefault
                                                                                handler:^(UIAlertAction * action)
                                                                                {
                                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                }];
                                                          [alert addAction:ok];
                                                          
                                                          [self presentViewController:alert animated:YES completion:nil];
                                                          return;
                                                      }
                                                      MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                                                      mailComposer.mailComposeDelegate = self;
                                                      mailComposer.navigationBar.tintColor=[UIColor whiteColor];
                                                      
                                                      [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
                                                      
                                                      [mailComposer setMessageBody:@"" isHTML:NO];
                                                      [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
                                                      [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                                                      [self presentViewController:mailComposer animated:YES completion:nil];
                                                      
                                                  }];
                [alert addAction:ok];
                [alert addAction:contactSupport];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"For security your account has been temporarily suspended.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com if you would like more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
                [alert show];
                [alert setTag:50];
            }
        }
    }

    else if ([tagName isEqualToString:@"login"])
    {
        NSError * error;
        NSDictionary * loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        NSLog(@"Result is: %@",[loginResult objectForKey:@"Result"]);
        if (  [loginResult objectForKey:@"Result"] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Invalid user id or password."] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"The password you have entered is incorrect."] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] &&
             [[loginResult objectForKey:@"Result"] rangeOfString:@"Your account has been temporarily blocked."].location == NSNotFound &&
            loginResult != nil)
        {
            serve * getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberId";
            [getDetails getMemIdFromuUsername:[self.email.text lowercaseString]];
        }
        
        else if ([loginResult objectForKey:@"Result"] && [[loginResult objectForKey:@"Result"] isEqualToString:@"Invalid user id or password."] && loginResult != nil)
        {
            [spinner stopAnimating];
            [self.hud hide:YES];

            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Invalid Email or Password"
                                             message:@"We don't recognize that information, please double check your email is entered correctly and try again."
                                             preferredStyle:UIAlertControllerStyleAlert];
            
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
            
                [alert addAction:ok];

                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Invalid Email or Password" message:@"We don't recognize that information, please double check your email is entered correctly and try again." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }

        else if ([loginResult objectForKey:@"Result"] && [[loginResult objectForKey:@"Result"] isEqualToString:@"The password you have entered is incorrect."] && loginResult != nil)
        {
            [spinner stopAnimating];
            [self.hud hide:YES];

            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"This Is Awkward"
                                         message:@"That doesn't appear to be the correct password. Please try again or contact us for futher help."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                  }];
                UIAlertAction * forgotPassword = [UIAlertAction
                                                  actionWithTitle:@"Forgot My Password"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                                  {
                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                      [self forgot_pass];
                                                  }];
                [alert addAction:ok];
                [alert addAction:forgotPassword];
            
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"This Is Awkward" message:@"That doesn't appear to be the correct password. Please try again or contact us for futher help." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Forgot Password", nil];
                [alert setTag:510];
                [alert show];
            }
        }

        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] rangeOfString:@"Your account has been temporarily blocked."].location != NSNotFound &&
                 loginResult != nil)
        {
            [self.hud hide:YES];
            
            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Account Temporarily Suspended"
                                             message:@"To keep Nooch safe your account has been temporarily suspended because you entered an incorrect password too many times.\n\nIn most cases your account will be automatically un-suspended in 24 hours. You can always contact support if this is a mistake or error.\n\nWe apologize for this inconvenience, please understand it is only to protect your account."
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
                UIAlertAction * contactSupport = [UIAlertAction
                                                  actionWithTitle:@"Contact Support"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                                  {
                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                      if (![MFMailComposeViewController canSendMail]){
                                                          UIAlertController * alert = [UIAlertController
                                                                                       alertControllerWithTitle:@"No Email Detected"
                                                                                       message:@"You don't have an email account configured for this device."
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                                          
                                                          UIAlertAction * ok = [UIAlertAction
                                                                                actionWithTitle:@"OK"
                                                                                style:UIAlertActionStyleDefault
                                                                                handler:^(UIAlertAction * action)
                                                                                {
                                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                }];
                                                          [alert addAction:ok];
                                                          
                                                          [self presentViewController:alert animated:YES completion:nil];
                                                          return;
                                                      }
                                                      MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                                                      mailComposer.mailComposeDelegate = self;
                                                      mailComposer.navigationBar.tintColor=[UIColor whiteColor];
                                                      
                                                      [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
                                                      
                                                      [mailComposer setMessageBody:@"" isHTML:NO];
                                                      [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
                                                      [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
                                                      [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                                                      [self presentViewController:mailComposer animated:YES completion:nil];
                                                  }];
                [alert addAction:ok];
                [alert addAction:contactSupport];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"To keep Nooch safe your account has been temporarily suspended because you entered an incorrect password too many times.\n\nIn most cases your account will be automatically un-suspended in 24 hours. You can always contact support if this is a mistake or error.\n\nWe apologize for this inconvenience, please understand it is only to protect your account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
                [alert setTag:600];
                [alert show];
            }
            [spinner stopAnimating];
        }

        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] && loginResult != nil)
        {
            [self.hud hide:YES];

            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Account Suspended"
                                         message:@"Your account has been temporarily suspended pending a review. We will contact you as soon as possible, and you can always contact us via email if this is a mistake or error."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
                UIAlertAction * ok = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                  }];
                UIAlertAction * contactSupport = [UIAlertAction
                                              actionWithTitle:@"Contact Support"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                                              {
                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                  if (![MFMailComposeViewController canSendMail]){
                                                      UIAlertController * alert = [UIAlertController
                                                                                alertControllerWithTitle:@"No Email Detected"
                                                                                message:@"You don't have an email account configured for this device."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                                      
                                                      UIAlertAction * ok = [UIAlertAction
                                                                           actionWithTitle:@"OK"
                                                                           style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action)
                                                                           {
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                           }];
                                                      [alert addAction:ok];
                                                      
                                                      [self presentViewController:alert animated:YES completion:nil];
                                                      return;
                                                  }
                                                  MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                                                  mailComposer.mailComposeDelegate = self;
                                                  mailComposer.navigationBar.tintColor=[UIColor whiteColor];
                                                  
                                                  [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
                                                  
                                                  [mailComposer setMessageBody:@"" isHTML:NO];
                                                  [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
                                                  [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
                                                  [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
                                                  [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                                                  [self presentViewController:mailComposer animated:YES completion:nil];
                                              }];
                [alert addAction:ok];
                [alert addAction:contactSupport];
            
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Suspended" message:@"Your account has been temporarily suspended pending a review. We will contact you as soon as possible, and you can always contact us via email if this is a mistake or error." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
                [alert setTag:500];
                [alert show];
            }
            [spinner stopAnimating];
        }

        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] && loginResult != nil)
        {
            [spinner stopAnimating];
            [self.hud hide:YES];

            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                        alertControllerWithTitle:@"Account Temporarily Suspended"
                                        message:@"For security your account has been temporarily suspended.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com if you would like more information."
                                        preferredStyle:UIAlertControllerStyleAlert];
            
                UIAlertAction * ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
                UIAlertAction * contactSupport = [UIAlertAction
                                              actionWithTitle:@"Contact Support"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                                              {
                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                  if (![MFMailComposeViewController canSendMail]) {
                                                      UIAlertController * alert = [UIAlertController
                                                                                alertControllerWithTitle:@"No Email Detected"
                                                                                message:@"You don't have an email account configured for this device."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                                      
                                                      UIAlertAction * ok = [UIAlertAction
                                                                           actionWithTitle:@"OK"
                                                                           style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action)
                                                                           {
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                           }];
                                                      [alert addAction:ok];
                                                      
                                                      [self presentViewController:alert animated:YES completion:nil];
                                                      return;
                                                  }
                                                  MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                                                  mailComposer.mailComposeDelegate = self;
                                                  mailComposer.navigationBar.tintColor=[UIColor whiteColor];
                                                  
                                                  [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
                                                  
                                                  [mailComposer setMessageBody:@"" isHTML:NO];
                                                  [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
                                                  [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
                                                  [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
                                                  [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                                                  [self presentViewController:mailComposer animated:YES completion:nil];
        
                                              }];
                [alert addAction:ok];
                [alert addAction:contactSupport];
            
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"For security your account has been temporarily suspended.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com if you would like more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
                [alert show];
                [alert setTag:50];
            }
        }

    }
    
    else if ([tagName isEqualToString:@"getMemberId"])
    {
        NSError *error;

        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];

        if (isloginWithFB) {
            [[NSUserDefaults standardUserDefaults] setObject:email_fb forKey:@"UserName"];
        }
        else
        [[NSUserDefaults standardUserDefaults] setObject:[self.email.text lowercaseString] forKey:@"UserName"];
        user = [NSUserDefaults standardUserDefaults];
        
        if (![self.stay_logged_in isOn]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        }
        else {
            NSMutableDictionary * automatic = [[NSMutableDictionary alloc] init];
            [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"MemberId"];
            [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserName"] forKey:@"UserName"];
            [automatic writeToFile:[self autoLogin] atomically:YES];
        }
        me = [core new];
        [me birth];
        
        [[me usr] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        if (isloginWithFB) {
             [[me usr] setObject:email_fb forKey:@"UserName"];
        }
        else
        [[me usr] setObject:[self.email.text lowercaseString] forKey:@"UserName"];
        
        serve * enc_user = [serve new];
        [enc_user setDelegate:self];
        [enc_user setTagName:@"username"];
        if (isloginWithFB) {
            [enc_user getEncrypt:email_fb];
        }
        else
        [enc_user getEncrypt:[self.email.text lowercaseString]];
    } 

    else if ([tagName isEqualToString:@"username"])
    {
        serve * details = [serve new];
        [details setDelegate:self];
        [details setTagName:@"info"];
        [details getDetails:[user objectForKey:@"MemberId"]];
    }

    else if ([tagName isEqualToString:@"info"])
    {
        [self.hud hide:YES];

        [[assist shared]setIsloginFromOther:NO];
        [self.navigationItem setHidesBackButton:YES];
        [nav_ctrl setNavigationBarHidden:NO];
        [nav_ctrl.navigationItem setLeftBarButtonItem:nil];
        [user removeObjectForKey:@"Balance"];
        [self.navigationItem setBackBarButtonItem:Nil];
        [spinner stopAnimating];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.7];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:nav_ctrl.view cache:NO];
        [UIView commitAnimations];
        [UIView beginAnimations:nil context:NULL];
        [nav_ctrl popToRootViewControllerAnimated:NO];

        [UIView commitAnimations];
        return;
    }

}

#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.email.text length] > 0 &&
        [self.email.text rangeOfString:@"@"].location != NSNotFound &&
        [self.email.text  rangeOfString:@"."].location != NSNotFound &&
        [self.password.text length] > 5)
    {
        [self.login setEnabled:YES];
    }
    else {
        [self.login setEnabled:NO];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _email)
    {
        [self.password becomeFirstResponder];
    }
    else if (textField == _password)
    {
        [self check_credentials];
    }
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - FBLoginViewDelegate
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    isloginWithFB = YES;
    self.loggedInUser = user;

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];

    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = @"Checking Login Credentials...";
    [self.hud show:YES];

    NSString * udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    email_fb = [self.loggedInUser objectForKey:@"email"];
    fbID = [self.loggedInUser objectForKey:@"id"];

    serve * log = [serve new];
    [log setDelegate:self];
    [log setTagName:@"loginwithFB"];
    [log loginwithFB:[self.loggedInUser objectForKey:@"email"] FBId:[self.loggedInUser objectForKey:@"id"] remember:YES lat:lat lon:lon uid:udid];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    isloginWithFB = NO;

    // test to see if we can use the share dialog built into the Facebook application
    FBLinkShareParams *p = [[FBLinkShareParams alloc] init];
    p.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
//    BOOL canShareFB = [FBDialogs canPresentShareDialogWithParams:p];
//    BOOL canShareiOS6 = [FBDialogs canPresentOSIntegratedShareDialogWithSession:nil];
//    BOOL canShareFBPhoto = [FBDialogs canPresentShareDialogWithPhotos];
    
//    self.buttonPostStatus.enabled = canShareFB || canShareiOS6;
//    self.buttonPostPhoto.enabled = canShareFBPhoto;
//    self.buttonPickFriends.enabled = NO;
//    self.buttonPickPlace.enabled = NO;
    
    // "Post Status" available when logged on and potentially when logged off.  Differentiate in the label.
//    [self.buttonPostStatus setTitle:@"Post Status Update (Logged Off)" forState:self.buttonPostStatus.state];
//    
//    self.profilePic.profileID = nil;
//    self.labelFirstName.text = nil;
//    self.loggedInUser = nil;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results

    NSLog(@"FBLoginView encountered an error=%@", error);
    
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook Error";
        alertMessage = [FBErrorUtility userMessageForError:error];

        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    }
    else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    }
    else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
    }
    else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark -

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
