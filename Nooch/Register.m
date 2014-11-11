//  Register.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "Register.h"
#import "Home.h"
#import "SelectPicture.h"
#import "Login.h"
#import "terms.h"
#import "Appirater.h"
#import "UIDevice+IdentifierAddition.h"
@interface Register ()
@property(nonatomic,strong) UITextField *name_field;
@property(nonatomic,strong) UITextField *email_field;
@property(nonatomic,strong) UITextField *password_field;
@property(nonatomic,retain) ACAccountStore *accountStore;
@property(nonatomic,retain) ACAccount *facebookAccount;
@property(nonatomic,strong) __block NSMutableDictionary *facebook_info;
@property(nonatomic,strong) UIButton *facebook;
@property(nonatomic,strong) UIButton *cont;
@property(nonatomic,strong) UIButton *login;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(atomic,strong) UILabel *or;
@end
@implementation Register

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.navigationController setNavigationBarHidden:YES];
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Register Screen";
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.login removeFromSuperview];

    UILabel * glyph_login = [UILabel new];
    [glyph_login setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    [glyph_login setFrame:CGRectMake(268, 0, 18, 30)];
    [glyph_login setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-circle-right"]];
    [glyph_login setTextColor:kNoochGreen];

    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.login setBackgroundColor:[UIColor clearColor]];
    [self.login setTitle:@"Already a Member?  Sign in here  " forState:UIControlStateNormal];
    [self.login setFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height + 10, 280, 30)];
    [self.login addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.login setStyleClass:@"label_small"];
    [self.login addSubview:glyph_login];
    [self.login setAlpha:0];
    [self.view addSubview:self.login];

    [UIView animateKeyframesWithDuration:.4
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [self.login setAlpha:1];
                                      if ([[UIScreen mainScreen] bounds].size.height > 500) {
                                          [self.login setFrame:CGRectMake(10, 509, 280, 30)];
                                      }
                                      else {
                                          [self.login setFrame:CGRectMake(10, 440, 280, 30)];
                                      }
                                  }];
                              } completion: nil];
}

- (void)viewDidLoad
{
    [Appirater appLaunched:NO];

    [super viewDidLoad];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.hud hide:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [nav_ctrl performSelector:@selector(disable)];
    
    // Do any additional setup after loading the view from its nib.

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:YES];
    self.facebook_info = [NSMutableDictionary new];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [logo setStyleClass:@"animate_bubble_logo"];
    [self.view addSubview:logo];

    UILabel * signup = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, 320, 15)];
    [signup setText:@"Sign Up Below With"];
    [signup setStyleClass:@"instruction_text"];
    [self.view addSubview:signup];

    self.facebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebook setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.19) forState:UIControlStateNormal];
    self.facebook.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.facebook setTitle:@"  Facebook" forState:UIControlStateNormal];
    [self.facebook setFrame:CGRectMake(0, 153, 0, 0)];
    [self.facebook addTarget:self action:@selector(connect_to_facebook) forControlEvents:UIControlEventTouchUpInside];
    [self.facebook setStyleClass:@"button_blue"];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(26, 38, 32, .18);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    UILabel * glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphFB setFrame:CGRectMake(60, 8, 30, 30)];
    glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"]
                                                                 attributes:textAttributes];
    [glyphFB setTextColor:[UIColor whiteColor]];
    
    [self.facebook addSubview:glyphFB];
    [self.view addSubview:self.facebook];

    self.or = [UILabel new];// initWithFrame:CGRectMake(0, 216, 320, 15)];
    [self.or setFrame:CGRectMake(0, 216, 320, 15)];
    [self.or setBackgroundColor:[UIColor clearColor]];
    [self.or setTextAlignment:NSTextAlignmentCenter];
    [self.or setText:@"Or..."];
    [self.or setStyleClass:@"label_small"];
    [self.view addSubview:self.or];

    UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(20, 254, 60, 20)];
    [name setBackgroundColor:[UIColor clearColor]];
    [name setTextColor:kNoochBlue];
    [name setText:@"Name"];
    [name setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:name];

    self.name_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 254, 200, 30)];
    [self.name_field setBackgroundColor:[UIColor clearColor]];
    [self.name_field setDelegate:self];
    [self.name_field setPlaceholder:@"First and Last Name"];
    [self.name_field setKeyboardType:UIKeyboardTypeAlphabet];
    self.name_field .returnKeyType = UIReturnKeyNext;
    [self.name_field setTag:1];
    [self.name_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.name_field setStyleClass:@"table_view_cell_detailtext_1"];
    [self.name_field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [self.view addSubview:self.name_field];

    UILabel * email = [[UILabel alloc] initWithFrame:CGRectMake(20, 294, 60, 20)];
    [email setBackgroundColor:[UIColor clearColor]];
    [email setTextColor:kNoochBlue];
    [email setText:@"Email"];
    [email setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:email];

    self.email_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 294, 200, 30)];
    [self.email_field setBackgroundColor:[UIColor clearColor]];
    [self.email_field setDelegate:self];
    [self.email_field setPlaceholder:@"Email Address"];
    [self.email_field setKeyboardType:UIKeyboardTypeEmailAddress];
    self.email_field.returnKeyType = UIReturnKeyNext;
    [self.email_field setTag:2];
    [self.email_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.email_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.email_field setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.email_field];

    UILabel * password = [[UILabel alloc] initWithFrame:CGRectMake(20, 334, 80, 20)];
    [password setBackgroundColor:[UIColor clearColor]];
    [password setTextColor:kNoochBlue];
    [password setText:@"Password"];
    [password setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:password];

    self.password_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 334, 200, 30)];
    [self.password_field setBackgroundColor:[UIColor clearColor]];
    [self.password_field setDelegate:self];
    [self.password_field setPlaceholder:@"Password"];
    [self.password_field setKeyboardType:UIKeyboardTypeAlphabet];
    self.password_field .returnKeyType = UIReturnKeyDone;
    [self.password_field setSecureTextEntry:YES];
    [self.password_field setTag:3];
    [self.password_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.password_field setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.password_field];

    UILabel * checkbox_box = [UILabel new];
    [checkbox_box setFrame:CGRectMake(36, 386, 21, 20)];
    [checkbox_box setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [checkbox_box setTextAlignment:NSTextAlignmentCenter];
    [checkbox_box setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-square-o"]];
    [checkbox_box setTextColor:kNoochBlue];
    [self.view addSubview:checkbox_box];

    UIButton * checkbox_dot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkbox_dot setBackgroundColor:[UIColor clearColor]];
    [checkbox_dot setTitle:@"  " forState:UIControlStateNormal];
    [checkbox_dot setFrame:CGRectMake(31, 381, 31, 30)];
    [checkbox_dot setStyleId:@"checkbox_dot"];
    [checkbox_dot addTarget:self action:@selector(termsAndConditions:) forControlEvents:UIControlEventTouchUpInside];
    isTermsChecked = NO;
    [self.view addSubview:checkbox_dot];
    
    UILabel * termsText1 = [UILabel new];
    [termsText1 setFont:[UIFont fontWithName:@"Roboto-light" size:13]];
    [termsText1 setFrame:CGRectMake(65, 388, 55, 14)];
    [termsText1 setText:@"I agree to "];
    [termsText1 setTextColor:kNoochGrayDark];
    [self.view addSubview:termsText1];

    UIButton * termsText2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [termsText2 setFrame:CGRectMake(122, 382, 150, 26)];
    [termsText2 setBackgroundColor:[UIColor clearColor]];
    [termsText2 setTitle:@"Nooch's Terms of Service." forState:UIControlStateNormal];
    [termsText2 setStyleClass:@"termsCheckText"];
    [termsText2 addTarget:self action:@selector(open_terms_webview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:termsText2];
    
    UIView * underline = [UIView new];
    underline.frame = CGRectMake(0, 18, 146, 1);
    [underline setBackgroundColor:kNoochGrayDark];
    [underline setAlpha:0.6];
    [termsText2 addSubview:underline];
    
    self.cont = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cont setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    self.cont.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.cont setTitle:@"Continue" forState:UIControlStateNormal];
    [self.cont setFrame:CGRectMake(10, 434, 300, 60)];
    [self.cont addTarget:self action:@selector(continue_to_signup) forControlEvents:UIControlEventTouchUpInside];
    [self.cont setStyleClass:@"button_green"];
    [self.view addSubview:self.cont];
    [self.cont setEnabled:NO];
    [self.cont setAlpha:0];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [signup setFrame:CGRectMake(0, 77, 320, 15)];
        [self.facebook setFrame:CGRectMake(0, 135, 0, 0)];
        [self.or setFrame:CGRectMake(0, 194, 320, 15)];
        [name setFrame:CGRectMake(0, 223, 0, 0)];
        [self.name_field setFrame:CGRectMake(0, 223, 0, 0)];
        [email setFrame:CGRectMake(0, 263, 0, 0)];
        [self.email_field setFrame:CGRectMake(0, 263, 0, 0)];
        [password setFrame:CGRectMake(0, 303, 0, 0)];
        [self.password_field setFrame:CGRectMake(0, 303, 0, 0)];

        [checkbox_box setFrame:CGRectMake(36, 348, 21, 20)];
        [checkbox_dot setFrame:CGRectMake(31, 343, 31, 30)];
        [termsText1 setFrame:CGRectMake(65, 350, 55, 14)];
        [termsText2 setFrame:CGRectMake(122, 344, 150, 26)];

        [self.cont setFrame:CGRectMake(0, 381, 0, 0)];
        [self.login setFrame:CGRectMake(0, 439, 320, 20)];
    }
}

-(void)termsAndConditions:(UIButton*)sender{
    if (isTermsChecked) {
         isTermsChecked = NO;
         [sender setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        isTermsChecked = YES;
        [sender setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle"] forState:UIControlStateNormal];
        [sender setStyleId:@"checkbox_dot"];
    }
}

- (void)open_terms_webview
{
    isfromRegister = YES;
    terms * term = [terms new];
  
    CGRect rect = term.view.frame;
    rect.origin.y = self.view.frame.size.height;
    term.view.frame = rect;
    [self.view addSubview:term.view];
    [self addChildViewController:term];

    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.45];
    [UIView setAnimationDelegate:self];
    term.view.frame = self.view.frame;
    [UIView commitAnimations];
}

-(void)removeChild:(UIViewController *) child
{
    [UIView animateWithDuration:.35
                     animations:^{
                         CGRect rect = self.view.frame;
                         rect.origin.y = self.view.frame.size.height;
                         child.view.frame = rect;
                     }
                     completion:^(BOOL finished){
                         [child didMoveToParentViewController:nil];
                         [child.view removeFromSuperview];
                         [child removeFromParentViewController];
                     }];
}

#pragma mark - facebook integration
- (void)connect_to_facebook
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        self.accountStore = [[ACAccountStore alloc] init];
        self.facebookAccount = nil;
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"198279616971457",
                                  ACFacebookPermissionsKey: @[@"email",@"user_about_me"],
                                  ACFacebookAudienceKey: ACFacebookAudienceOnlyMe
                                  };
        ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [self.accountStore requestAccessToAccountsWithType:facebookAccountType
                                                   options:options completion:^(BOOL granted, NSError *e)
         {
             if (!granted) {
                 NSLog(@"didnt grant because: %@",e.description);
             }
             else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStylePulse];
                     spinner1.color = [UIColor whiteColor];
                     self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                     [self.navigationController.view addSubview:self.hud];
                     self.hud.labelText = @"Loading Facebook Info...";
                     [spinner1 startAnimating];
                     self.hud.mode = MBProgressHUDModeCustomView;
                     self.hud.customView = spinner1;
                     self.hud.delegate = self;
                     [self.hud show:YES];
                 });
                                 NSArray *accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
                 self.facebookAccount = [accounts lastObject];
                 //[self renewFb];
                 [self finishFb];
             }
         }];
    }
    else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"You do not have a Facebook account attached to this phone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

-(void)renewFb
{
    [self.accountStore renewCredentialsForAccount:(ACAccount *)self.facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error){
        if(!error)
        {
            switch (renewResult) {
                case ACAccountCredentialRenewResultRenewed:
                    break;
                case ACAccountCredentialRenewResultRejected:
                    NSLog(@"User declined permission");
                    break;
                case ACAccountCredentialRenewResultFailed:
                    NSLog(@"non-user-initiated cancel, you may attempt to retry");
                    break;
                default:
                    break;
            }
            [self finishFb];
        }
        else{
            //handle error gracefully
            NSLog(@"Error from renew credentials: %@",error);
        }
    }];
}

-(void)finishFb
{
    NSString *acessToken = [NSString stringWithFormat:@"%@",self.facebookAccount.credential.oauthToken];
    NSDictionary *parameters = @{@"access_token": acessToken,@"fields":@"id,username,first_name,last_name,email"};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodGET
                              URL:feedURL
                              parameters:parameters];
    feedRequest.account = self.facebookAccount;
    self.facebook_info = [NSMutableDictionary new];
    [feedRequest performRequestWithHandler:^(NSData *respData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
    {
         self.facebook_info = [NSJSONSerialization
                               JSONObjectWithData:respData
                               options:kNilOptions
                               error:&error];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.hud hide:YES];
             //login if it is already nooch user

             RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
             spinner1.color = [UIColor whiteColor];
             self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
             [self.navigationController.view addSubview:self.hud];

             self.hud.mode = MBProgressHUDModeCustomView;
             self.hud.customView = spinner1;
             self.hud.delegate = self;
             self.hud.labelText = @"Checking SignUp Credentials...";
             [self.hud show:YES];

             NSString * udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
             serve * log = [serve new];
             [log setDelegate:self];
             [log setTagName:@"loginwithFB"];
             [log loginwithFB:[self.facebook_info objectForKey:@"email"] FBId:[self.facebook_info objectForKey:@"id"] remember:YES lat:0.0 lon:0.0 uid:udid];
         });
        
     }];
}

#pragma mark - navigation
- (void)continue_to_signup
{
    if ([[[self.name_field.text componentsSeparatedByString:@" "] objectAtIndex:0]length] < 2)
    {
        UIAlertView* alert =[[UIAlertView alloc]initWithTitle:@"Need a Full Name" message:@"Nooch is currently only able to handle names greater than 3 letters.\n\nIf your first or last name has fewer than 3, please contact us and we'll be happy to manually create your account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.name_field becomeFirstResponder];
        return;
    }

    if (([self.password_field.text length] == 0) || ([self.name_field.text length] == 0) || ([self.email_field.text length] == 0))
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Eager Beaver" message:@"You have not filled out the sign up form!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.name_field becomeFirstResponder];
        return;
    }

    NSCharacterSet * digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet * lettercaseCharSet = [NSCharacterSet letterCharacterSet];

    if ([self.password_field.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Insecure Password" message:@"For security reasons, et cetera, we ask that passwords contain at least 1 number.\n\nWe know it's annoying, but we're just looking out for you. Keep it safe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.password_field becomeFirstResponder];
        return;
    }
    else if ([self.password_field.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Letters Are Fun Too" message:@"Regrettably, your Nooch password must contain at least one actual letter." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.password_field becomeFirstResponder];
        return;
    }

    if (!isTermsChecked) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Who Loves Lawyers" message:@"Please read Nooch's Terms of Service and check the box to proceed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Read Terms", nil];
        [av show];
        [av setTag:16];
        return;
    }
    else
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = @"Registering your account";
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        [self.hud show:YES];

        [[assist shared]setIsloginFromOther:NO];

        serve * check_duplicate = [serve new];
        [check_duplicate setTagName:@"check_dup"];
        [check_duplicate setDelegate:self];
        [check_duplicate dupCheck:[self.email_field.text lowercaseString]];
    }
}

- (void)login:(UIButton*)sender
{
    [UIView animateKeyframesWithDuration:.54
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.2 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height > 500) {
                                          [self.login setFrame:CGRectMake(-16, 509, 280, 30)];
                                      } else {
                                          [self.login setFrame:CGRectMake(-16, 440, 280, 30)];
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.21 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height > 500) {
                                          [self.login setFrame:CGRectMake(-25, 509, 280, 30)];
                                      } else {
                                          [self.login setFrame:CGRectMake(-25, 440, 280, 30)];
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.46 relativeDuration:0.32 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height > 500) {
                                          [self.login setFrame:CGRectMake(100, 509, 280, 30)];
                                      } else {
                                          [self.login setFrame:CGRectMake(100, 440, 280, 30)];
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.78 relativeDuration:0.22 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height > 500) {
                                          [self.login setFrame:CGRectMake(321, 509, 280, 30)];
                                      } else {
                                          [self.login setFrame:CGRectMake(321, 440, 280, 30)];
                                      }
                                  }];
                              } completion: ^(BOOL finished){
                                  [[UIApplication sharedApplication]setStatusBarHidden:YES];
                                  Login * signin = [Login new];
                                  [self.navigationController pushViewController:signin animated:YES];
                              }
     ];
}

-(void)loginFromAlertView
{
    Login * signin = [Login new];
    [self.navigationController pushViewController:signin animated:YES];
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

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"loginwithFB"])
    {
        NSError * error;
        NSDictionary * loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        // NSLog(@"Result is: %@",[loginResult objectForKey:@"Result"]);
      
        if ([[loginResult objectForKey:@"Result"] isEqualToString:@"FBID or EmailId not registered with Nooch"])
        {
            [self.hud hide:YES];

            self.name_field.text = [NSString stringWithFormat:@"%@ %@",[self.facebook_info objectForKey:@"first_name"],[self.facebook_info objectForKey:@"last_name"]];
            [self.password_field becomeFirstResponder];

            self.email_field.text = [self.facebook_info objectForKey:@"email"];
            
            NSString *imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [self.facebook_info objectForKey:@"id"]];

            [[NSUserDefaults standardUserDefaults] setObject:[self.facebook_info objectForKey:@"id"] forKey:@"facebook_id"];

            NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            NSMutableDictionary *d = [self.facebook_info mutableCopy];
            [d setObject:imgData forKey:@"image"];
            self.facebook_info = [d mutableCopy];

            [self.or setText:@"Now just create a password..."];

            [self.facebook setTitle:@"       Facebook Connected" forState:UIControlStateNormal];

            for (UIView*subview in self.facebook.subviews) {
                if([subview isMemberOfClass:[UILabel class]]) {
                    [subview removeFromSuperview];
                }
            }
            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowColor = Rgb2UIColor(19, 32, 38, .19);
            shadow.shadowOffset = CGSizeMake(0, -1);
            NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

            UILabel * glyphFB = [UILabel new];
            [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
            [glyphFB setFrame:CGRectMake(17, 8, 26, 30)];
            glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes1];
            [glyphFB setTextColor:[UIColor whiteColor]];
            [self.facebook addSubview:glyphFB];

            UILabel * glyph_check = [UILabel new];
            [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
            [glyph_check setFrame:CGRectMake(39, 8, 20, 30)];
            glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:textAttributes1];
            [glyph_check setTextColor:[UIColor whiteColor]];

            [self.facebook addSubview:glyph_check];
            [self.facebook setUserInteractionEnabled:NO];
        }

        else if ([loginResult objectForKey:@"Result"] &&
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
            [getDetails getMemIdFromuUsername:[self.facebook_info objectForKey:@"email"]];
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
       // [log loginwithFB:[self.facebook_info objectForKey:@"email"] FBId:[self.facebook_info objectForKey:@"id"] remember:YES lat:0.0 lon:0.0 uid:udid];

        [[NSUserDefaults standardUserDefaults] setObject:[self.facebook_info objectForKey:@"email"] forKey:@"UserName"];

        user = [NSUserDefaults standardUserDefaults];

        NSMutableDictionary * automatic = [[NSMutableDictionary alloc] init];
        [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"MemberId"];
        [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserName"] forKey:@"UserName"];
        [automatic writeToFile:[self autoLogin] atomically:YES];
        
        me = [core new];
        [me birth];
        
        [[me usr] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [[me usr] setObject:[self.facebook_info objectForKey:@"email"] forKey:@"UserName"];

        serve * enc_user = [serve new];
        [enc_user setDelegate:self];
        [enc_user setTagName:@"username"];
        [enc_user getEncrypt:[self.facebook_info objectForKey:@"email"]];
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

    else if ([tagName isEqualToString:@"check_dup"])
    {
        [self.hud hide:YES];
        NSError *error;
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (![[loginResult objectForKey:@"Result"] isEqualToString:@"Not a nooch member."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email in Use" message:@"That email address you are attempting to sign up with is already in use. Do you want to login now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Login", nil];
            [av setTag:20];
            [av show];
            return;
        }

        NSString * first_name;
        NSString * last_name;
        NSArray * arr = [[self.name_field.text lowercaseString]componentsSeparatedByString:@" "];

        if ([arr count] > 1) {
            first_name = [arr objectAtIndex:0];
            last_name = [arr objectAtIndex:1];
        }
        else
        {
            first_name = [arr objectAtIndex:0];
            last_name = @"";
        }

        NSDictionary *user;

        if (![self.facebook_info objectForKey:@"id"]) {
            user = @{@"first_name":first_name,
                     @"last_name":last_name,
                     @"email":[self.email_field.text lowercaseString],
                     @"password":self.password_field.text};
        }
        else {
            user = @{@"first_name":first_name,
                     @"last_name":last_name,
                     @"email":self.email_field.text,
                     @"password":self.password_field.text,
                     @"facebook_id":[self.facebook_info objectForKey:@"id"],
                     @"image":[self.facebook_info objectForKey:@"image"]};
        }

        SelectPicture *picture = [[SelectPicture alloc] initWithData:user];
        [self.navigationController pushViewController:picture animated:YES];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 16 & buttonIndex == 1)
    {
        [self open_terms_webview];
    }
    else if (alertView.tag == 20 & buttonIndex == 1)
    {
        [self loginFromAlertView];
    }
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.name_field.text length] > 1 && [self.email_field.text length] > 2 && [self.email_field.text rangeOfString:@"@"].location != NSNotFound && [self.email_field.text rangeOfString:@"."].location != NSNotFound) {
        [self.cont setAlpha:1];
    }
    if ([self.name_field.text length] > 1 && [self.email_field.text length] > 2 && [self.email_field.text rangeOfString:@"@"].location != NSNotFound && [self.email_field.text rangeOfString:@"."].location != NSNotFound
        && [self.password_field.text length] > 6)
    {
        [self.cont setEnabled:YES];
        [self.cont setAlpha:1];
    }
    else {
        [self.cont setEnabled:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 1:
            [self.email_field becomeFirstResponder];
            break;
        case 2:
            [self.password_field becomeFirstResponder];
            break;
        case 3:
            [textField resignFirstResponder];
            break;
        default:
            break;
    }
    return YES;
}
#pragma mark - file paths
- (NSString *)autoLogin{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    }
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.name_field.text = self.name_field.text.capitalizedString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end