//  Register.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "Register.h"
#import "Home.h"
#import "SelectPicture.h"
#import "Login.h"
#import "terms.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Appirater.h"
#import "UIDevice+IdentifierAddition.h"
#import <ArtisanSDK/ArtisanSDK.h>

@interface Register ()<FBLoginViewDelegate>{
    core*me;
    NSString*email_fb,*fbID,*firstname_fb,*lastname_fb;
}
@property(nonatomic,strong) UITextField *name_field;
@property(nonatomic,strong) UITextField *email_field;
@property(nonatomic,strong) UITextField *password_field;
@property(nonatomic,strong) __block NSMutableDictionary *facebook_info;
@property(nonatomic,strong) UIButton *facebookLogin;
@property(nonatomic,strong) UIButton *cont;
@property(nonatomic,strong) UIButton *login;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UILabel *or;
@property(nonatomic,strong) UILabel * emailValidator;
@property(nonatomic,strong) UILabel * nameValidator;
@property(nonatomic,strong) UILabel * fullNameInstruc;
@property(nonatomic,strong) UILabel * pwValidator;
@property(nonatomic,strong) UIView * pwValidator1, * pwValidator2, * pwValidator3, * pwValidator4;

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
    //NSLog(@"viewWillAppear Fired");
    [super viewWillAppear:animated];
    self.screenName = @"Register Screen";
    self.artisanNameTag = @"Register Screen";
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.login setFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height + 6, 300, 52)];
    [self.login setStyleId:@"label_small_register"];
    [self.login setBackgroundColor:[UIColor clearColor]];
    [self.login setTitle:NSLocalizedString(@"Register_loginTxt", @"Register Screen 'Already a member?  Sign in here ") forState:UIControlStateNormal];
    [self.login setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [self.login addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.login setAlpha:0.1];
    [self.view addSubview:self.login];

    UILabel * glyph_login = [UILabel new];
    [glyph_login setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph_login setFrame:CGRectMake(0, 38, 300, 25)];
    [glyph_login setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-circle-right"]];
    [glyph_login setTextColor:kNoochGreen];
    [glyph_login setTextAlignment:NSTextAlignmentCenter];
    [self.login addSubview:glyph_login];

    [UIView animateKeyframesWithDuration:.4
                                   delay:0
                                 options:2 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [self.login setAlpha:1];
                                      if ([[UIScreen mainScreen] bounds].size.height > 500)
                                      {
                                          [self.login setFrame:CGRectMake(10, 495, 300, 52)];
                                      }
                                      else
                                      {
                                          [self.login setFrame:CGRectMake(10, 426, 300, 40)];
                                          [glyph_login setFrame:CGRectMake(0, 30, 300, 22)];
                                      }
                                  }];
                              } completion: nil];

    [ARTrackingManager trackEvent:@"Register_viewDidAppear"];
}

- (void)viewDidLoad
{
    [Appirater appLaunched:NO];

    [super viewDidLoad];

    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.hud hide:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [nav_ctrl performSelector:@selector(disable)];

    // Do any additional setup after loading the view from its nib.

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:YES];

    self.facebook_info = [NSMutableDictionary new];

    UIView * boxOutline = [[UIView alloc] initWithFrame:CGRectMake(9, 244, 302, 175)];
    boxOutline.backgroundColor = [UIColor whiteColor];
    boxOutline.layer.cornerRadius = 8;
    boxOutline.layer.borderWidth = 0.5;
    boxOutline.layer.borderColor = Rgb2UIColor(188, 190, 192, .4).CGColor;
    [boxOutline setStyleClass:@"welcomeBoxShadow"];
    [self.view addSubview:boxOutline];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [logo setStyleClass:@"animate_bubble_logo"];
    [self.view addSubview:logo];

    UILabel * signup = [[UILabel alloc] initWithFrame:CGRectMake(10, 72, 300, 16)];
    [signup setText:NSLocalizedString(@"Register_SgnUpWthTxt", @"Register Screen 'Sign Up With")];
    [signup setStyleClass:@"instruction_text"];
    [signup setStyleId:@"instruction_text_lg"];
    [self.view addSubview:signup];

    self.facebookLogin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebookLogin setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.19) forState:UIControlStateNormal];
    self.facebookLogin.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.facebookLogin setTitle:@"  Facebook" forState:UIControlStateNormal];
    [self.facebookLogin setFrame:CGRectMake(0, 144, 0, 0)];
    [self.facebookLogin addTarget:self action:@selector(toggleFacebookLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookLogin setStyleClass:@"button_blue"];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(26, 38, 32, .18);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    UILabel * glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphFB setFrame:CGRectMake(58, 8, 30, 30)];
    [glyphFB setTextColor:[UIColor whiteColor]];
    glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];

    [self.facebookLogin addSubview:glyphFB];
    [self.view addSubview:self.facebookLogin];

    self.or = [UILabel new];
    [self.or setFrame:CGRectMake(0, 205, 320, 16)];
    [self.or setBackgroundColor:[UIColor clearColor]];
    [self.or setTextAlignment:NSTextAlignmentCenter];
    [self.or setText:NSLocalizedString(@"Register_OrTxt", @"Register Screen 'Or...' Text")];
    [self.or setStyleClass:@"label_small"];
    [self.view addSubview:self.or];

    UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(20, 252, 60, 20)];
    [name setBackgroundColor:[UIColor clearColor]];
    [name setTextColor:kNoochBlue];
    [name setText:NSLocalizedString(@"Register_NameLbl", @"Register Screen ' Full Name' Text")];
    [name setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:name];

    self.name_field = [[UITextField alloc] initWithFrame:CGRectMake(94, 252, 214, 40)];
    [self.name_field setBackgroundColor:[UIColor clearColor]];
    [self.name_field setDelegate:self];
    [self.name_field setPlaceholder:@"i.e. Abe Lincoln"];
    [self.name_field setKeyboardType:UIKeyboardTypeAlphabet];
    self.name_field .returnKeyType = UIReturnKeyNext;
    [self.name_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.name_field setStyleClass:@"table_view_cell_detailtext_register"];
    [self.name_field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [self.name_field setTag:1];
    [self.view addSubview:self.name_field];

    self.nameValidator = [UILabel new];
    [self.nameValidator setFrame:CGRectMake(12, 0, 21, 40)];
    [self.nameValidator setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [self.nameValidator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"]];
    [self.nameValidator setTextAlignment:NSTextAlignmentCenter];
    [self.nameValidator setTextColor:kNoochRed];
    [self.nameValidator setHidden:YES];
    [self.name_field addSubview:self.nameValidator];

    self.fullNameInstruc = [[UILabel alloc] initWithFrame:CGRectMake(40, 286, 263, 15)];
    [self.fullNameInstruc setBackgroundColor:[UIColor clearColor]];
    [self.fullNameInstruc setText:[NSString stringWithFormat:@"\xF0\x9F\x98\xB3  %@", NSLocalizedString(@"Register_NameInstruct", @"Register Screen Full Name Instructions Text")]];
    [self.fullNameInstruc setFont:[UIFont fontWithName:@"Roboto-regular" size:12]];
    [self.fullNameInstruc setTextColor:kNoochRed];
    [self.fullNameInstruc setTextAlignment:NSTextAlignmentRight];
    [self.fullNameInstruc setHidden:YES];
    [self.view addSubview:self.fullNameInstruc];

    UILabel * email = [[UILabel alloc] initWithFrame:CGRectMake(20, 293, 60, 20)];
    [email setBackgroundColor:[UIColor clearColor]];
    [email setTextColor:kNoochBlue];
    [email setText:NSLocalizedString(@"Register_EmailLbl", @"Register Screen ' Email' Text")];
    [email setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:email];

    self.email_field = [[UITextField alloc] initWithFrame:CGRectMake(94, 293, 214, 40)];
    [self.email_field setBackgroundColor:[UIColor clearColor]];
    [self.email_field setDelegate:self];
    [self.email_field setPlaceholder:@"example@email.com"];
    [self.email_field setKeyboardType:UIKeyboardTypeEmailAddress];
    self.email_field.returnKeyType = UIReturnKeyNext;
    [self.email_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.email_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.email_field setStyleClass:@"table_view_cell_detailtext_register"];
    [self.email_field setTag:2];
    [self.view addSubview:self.email_field];

    self.emailValidator = [UILabel new];
    [self.emailValidator setFrame:CGRectMake(72, 293, 21, 39)];
    [self.emailValidator setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [self.emailValidator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"]];
    [self.emailValidator setTextAlignment:NSTextAlignmentCenter];
    [self.emailValidator setTextColor:kNoochRed];
    [self.emailValidator setHidden:YES];
    [self.view addSubview:self.emailValidator];

    UILabel * password = [[UILabel alloc] initWithFrame:CGRectMake(20, 334, 80, 20)];
    [password setBackgroundColor:[UIColor clearColor]];
    [password setTextColor:kNoochBlue];
    [password setText:NSLocalizedString(@"Register_PwLbl", @"Register Screen ' Password' Text")];
    [password setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:password];

    self.password_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 334, 200, 40)];
    [self.password_field setBackgroundColor:[UIColor clearColor]];
    [self.password_field setDelegate:self];
    [self.password_field setPlaceholder:NSLocalizedString(@"Register_PwPlchldr", @"Register Screen 'Password ' Placeholder Text")];
    [self.password_field setKeyboardType:UIKeyboardTypeAlphabet];
    self.password_field .returnKeyType = UIReturnKeyDone;
    [self.password_field setSecureTextEntry:YES];
    [self.password_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.password_field setStyleClass:@"table_view_cell_detailtext_register"];
    [self.password_field setTag:3];
    [self.view addSubview:self.password_field];

    self.pwValidator1 = [[UIView alloc] initWithFrame:CGRectMake(20, 366, 69, 4)];
    [self.pwValidator1 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
    [self.pwValidator1 setHidden:YES];
    [self.view addSubview:self.pwValidator1];

    self.pwValidator2 = [[UIView alloc] initWithFrame:CGRectMake(91, 366, 69, 4)];
    [self.pwValidator2 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
    [self.pwValidator2 setHidden:YES];
    [self.view addSubview:self.pwValidator2];

    self.pwValidator3 = [[UIView alloc] initWithFrame:CGRectMake(162, 366, 69, 4)];
    [self.pwValidator3 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
    [self.pwValidator3 setHidden:YES];
    [self.view addSubview:self.pwValidator3];

    self.pwValidator4 = [[UIView alloc] initWithFrame:CGRectMake(233, 366, 69, 4)];
    [self.pwValidator4 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
    [self.pwValidator4 setHidden:YES];
    [self.view addSubview:self.pwValidator4];

    self.pwValidator = [UILabel new];
    [self.pwValidator setFrame:CGRectMake(202, 370, 100, 13)];
    [self.pwValidator setFont:[UIFont fontWithName:@"Roboto-regular" size:11]];
    [self.pwValidator setText:NSLocalizedString(@"Register_VryWk", @"Register Screen 'Very Weak' PW Validator Text")];
    [self.pwValidator setTextAlignment:NSTextAlignmentRight];
    [self.pwValidator setTextColor:kNoochRed];
    [self.pwValidator setHidden:YES];
    [self.view addSubview:self.pwValidator];

    UILabel * checkbox_box = [UILabel new];
    [checkbox_box setFrame:CGRectMake(35, 385, 21, 20)];
    [checkbox_box setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [checkbox_box setTextAlignment:NSTextAlignmentCenter];
    [checkbox_box setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-square-o"]];
    [checkbox_box setTextColor:kNoochGreen];
    [self.view addSubview:checkbox_box];

    UIButton * checkbox_dot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkbox_dot setBackgroundColor:[UIColor clearColor]];
    [checkbox_dot setTitle:@"  " forState:UIControlStateNormal];
    [checkbox_dot setFrame:CGRectMake(33, 377, 31, 30)];
    [checkbox_dot setStyleId:@"checkbox_dot"];
    [checkbox_dot addTarget:self action:@selector(termsAndConditions:) forControlEvents:UIControlEventTouchUpInside];
    isTermsChecked = NO;
    [self.view addSubview:checkbox_dot];

    UILabel * termsText1 = [UILabel new];
    [termsText1 setFont:[UIFont fontWithName:@"Roboto-light" size:13]];
    [termsText1 setFrame:CGRectMake(65, 388, 55, 14)];
    [termsText1 setText:NSLocalizedString(@"Register_AgreeTxt1", @"Register Screen 'I agree to ' Text")];
    [termsText1 setTextColor:kNoochGrayDark];
    [self.view addSubview:termsText1];

    UIButton * termsText2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [termsText2 setFrame:CGRectMake(122, 382, 150, 26)];
    [termsText2 setBackgroundColor:[UIColor clearColor]];
    [termsText2 setTitle:NSLocalizedString(@"Register_AgreeTxt2", @"Register Screen 'Nooch's Terms of Service.' Text") forState:UIControlStateNormal];
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
    [self.cont setTitle:NSLocalizedString(@"Register_CntnBtnWk", @"Register Screen 'Continue' Btm Text") forState:UIControlStateNormal];
    [self.cont setFrame:CGRectMake(10, 434, 300, 60)];
    [self.cont addTarget:self action:@selector(continue_to_signup) forControlEvents:UIControlEventTouchUpInside];
    [self.cont setStyleClass:@"button_green"];
    [self.view addSubview:self.cont];
    [self.cont setEnabled:NO];
    [self.cont setAlpha:0];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [signup setFrame:CGRectMake(0, 66, 320, 16)];
        [self.facebookLogin setFrame:CGRectMake(0, 126, 0, 0)];
        [self.or setFrame:CGRectMake(0, 182, 320, 16)];

        [boxOutline setFrame:CGRectMake(9, 219, 302, 153)];

        [name setFrame:CGRectMake(0, 219, 0, 0)];
        [self.name_field setFrame:CGRectMake(0, 219, 0, 0)];
        [self.fullNameInstruc setFrame:CGRectMake(40, 251, 263, 16)];

        [email setFrame:CGRectMake(0, 259, 0, 0)];
        [self.email_field setFrame:CGRectMake(0, 259, 0, 0)];
        [self.emailValidator setFrame:CGRectMake(72, 259, 21, 39)];

        [password setFrame:CGRectMake(0, 299, 0, 0)];
        [self.password_field setFrame:CGRectMake(0, 299, 0, 0)];

        [self.pwValidator setFrame:CGRectMake(202, 336, 100, 11)];
        [self.pwValidator1 setFrame:CGRectMake(20, 331, 69, 4)];
        [self.pwValidator2 setFrame:CGRectMake(91, 331, 69, 4)];
        [self.pwValidator3 setFrame:CGRectMake(162, 331, 69, 4)];
        [self.pwValidator4 setFrame:CGRectMake(233, 331, 69, 4)];

        [checkbox_box setFrame:CGRectMake(36, 345, 21, 20)];
        [checkbox_dot setFrame:CGRectMake(31, 340, 31, 30)];
        [termsText1 setFrame:CGRectMake(65, 347, 55, 14)];
        [termsText2 setFrame:CGRectMake(122, 341, 150, 26)];

        [self.cont setFrame:CGRectMake(0, 380, 0, 0)];
    }
}

- (void)toggleFacebookLogin:(id)sender
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else // If the session state is NOT any of the two "open" states when the button is clicked
    {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Call the sessionStateChanged:state:error method to handle session state changes
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        NSLog(@"FB Session opened");
        // Show the user the logged-in UI
        [self attemptFBLogin];
        return;
    }
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {  // If the session is closed
        NSLog(@"FB Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error)
    {
        NSLog(@"FB Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");
            }
            // Handle session closures that happen outside of the app
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current Facebook session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
            }
            // For simplicity, here we just show a generic message for all other errors
            // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Facebook: Show the user the logged-out UI (In theory this should never be called since the FB session is either already closed when the app is opened, or the user gets automatically logged in after clicking Login with FB button)
- (void)userLoggedOut
{
    for (UIView *subview in self.facebookLogin.subviews) {
        if ([subview isMemberOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }

    NSShadow * shadowFB = [[NSShadow alloc] init];
    shadowFB.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowFB.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * shadowFBdict = @{NSShadowAttributeName: shadowFB};

    [self.facebookLogin setTitle:@"  Facebook" forState:UIControlStateNormal];

    UILabel * glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyphFB setFrame:CGRectMake(58, 8, 30, 30)];
    [glyphFB setTextColor:[UIColor whiteColor]];
    [glyphFB setStyleClass:@"animate_bubble"];
    glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:shadowFBdict];

    [self.facebookLogin addSubview:glyphFB];
}

// Facebook: Show the user the logged-in UI
- (void)userLoggedIn
{
    for (UIView * subview in self.facebookLogin.subviews) {
        if ([subview isMemberOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }

    NSShadow * shadowFB = [[NSShadow alloc] init];
    shadowFB.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowFB.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * shadowFBdict = @{NSShadowAttributeName: shadowFB};

    [self.facebookLogin setTitle:@"       Facebook Connected" forState:UIControlStateNormal];

    UILabel * glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphFB setFrame:CGRectMake(17, 8, 26, 30)];
    glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:shadowFBdict];
    [glyphFB setTextColor:[UIColor whiteColor]];
    [self.facebookLogin addSubview:glyphFB];

    UILabel * glyph_check = [UILabel new];
    [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:13]];
    [glyph_check setFrame:CGRectMake(36, 8, 18, 30)];
    glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:shadowFBdict];
    [glyph_check setTextColor:[UIColor whiteColor]];

    [self.facebookLogin addSubview:glyph_check];
}

- (void)attemptFBLogin
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            // Success! Now Log User into Nooch using the FB ID
            [user setObject:[result objectForKey:@"id"] forKey:@"facebook_id"];
            NSLog(@"Login w FB successful --> fb id is %@",[result objectForKey:@"id"]);

            isloginWithFB = YES;

            RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
            spinner1.color = [UIColor whiteColor];
            self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:self.hud];
            self.hud.mode = MBProgressHUDModeCustomView;
            self.hud.customView = spinner1;
            self.hud.delegate = self;
            self.hud.labelText = @"Checking Login Credentials...";
            [self.hud show:YES];

            NSString * udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
            email_fb = [result objectForKey:@"email"];
            fbID = [result objectForKey:@"id"];
            firstname_fb = [result objectForKey:@"first_name"];
            lastname_fb = [result objectForKey:@"last_name"];

            serve * log = [serve new];
            [log setDelegate:self];
            [log setTagName:@"loginwithFB"];
            [log loginwithFB:email_fb FBId:fbID remember:YES lat:39.95 lon:-75.16 uid:udid];
        }
        else
        {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
}

// Show an alert message (For Facebook methods)
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

-(void)termsAndConditions:(UIButton*)sender
{
    if (isTermsChecked)
    {
         isTermsChecked = NO;
         [sender setTitle:@"" forState:UIControlStateNormal];
    }
    else
    {
        isTermsChecked = YES;
        [sender setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] forState:UIControlStateNormal];
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

    [ARTrackingManager trackEvent:@"OpenTerms_FrmRegisterScrn"];
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

#pragma mark - navigation
- (void)continue_to_signup
{
    if (([self.password_field.text length] == 0) || ([self.name_field.text length] == 0) || ([self.email_field.text length] == 0))
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Eager Beaver"
                                                     message:@"You have not filled out the sign up form!"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [self.name_field becomeFirstResponder];
        return;
    }

    else if ([self.name_field.text rangeOfString:@" "].location == NSNotFound)
    {
        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"Need a Full Name"
                                                       message:@"For security, we ask all Nooch users sign up with a full name (first and last name)."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        [self.name_field becomeFirstResponder];
        return;
    }

    else if ([[[self.name_field.text componentsSeparatedByString:@" "] objectAtIndex:0]length] < 2 ||
             [[[self.name_field.text componentsSeparatedByString:@" "] objectAtIndex:1]length] < 2)
    {
        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"Need a Full Name"
                                                       message:@"Nooch is currently only able to handle names greater than 3 letters.\n\nIf your first or last name has fewer than 3, please contact us and we'll be happy to manually create your account."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        [self.name_field becomeFirstResponder];
        return;
    }
    else
    {
        if ([self checkNameForNumsAndSpecChars] == false)
        {
            return;
        }
    }

    // CHECK IF EMAIL IS ONE OF THE SHADY DOMAINS
    if ([self checkEmailForShadyDomain] == false)
    {
        return;
    }

    NSCharacterSet * digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet * lettercaseCharSet = [NSCharacterSet letterCharacterSet];

    if ([self.password_field.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rgstr_InscrPwAlrtTtl", @"Register screen 'Insecure Password' Alert Title")
                                                     message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB3\n%@", NSLocalizedString(@"Rgstr_InscrPwAlrtBody", @"Register screen Insecure Pw Alert Body Text")]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [self.password_field becomeFirstResponder];
        return;
    }
    else if ([self.password_field.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rgstr_NeedLtrAlrtTtl", @"Register screen 'Letters Are Fun Too' Alert Title")
                                                     message:[NSString stringWithFormat:@"\xF0\x9F\x98\x8F\n%@", NSLocalizedString(@"Rgstr_NeedLtrAlrtBody", @"Register screen Letters Are Fun Too Alert Body Text")]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [self.password_field becomeFirstResponder];
        return;
    }

    if (!isTermsChecked)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rgstr_TrmsAlrtTtl", @"Register screen 'Who Loves Lawyers' Alert Title")
                                                     message:[NSString stringWithFormat:@"\xF0\x9F\x98\x81\n%@", NSLocalizedString(@"Rgstr_TrmsAlrtBody", @"Register screen 'Who Loves Lawyers' Alert Body Text")]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:@"Read Terms", nil];
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
        self.hud.labelText = NSLocalizedString(@"Rgstr_HUDchkngEml", @"Register screen 'Checking if email already in use' HUD Label");
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        [self.hud show:YES];

        [[assist shared] setIsloginFromOther:NO];

        serve * check_duplicate = [serve new];
        [check_duplicate setTagName:@"check_dup"];
        [check_duplicate setDelegate:self];
        [check_duplicate dupCheck:[self.email_field.text lowercaseString]];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.login removeFromSuperview];
}

-(void)login:(UIButton*)sender
{
    [UIView animateKeyframesWithDuration:0.22
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height > 500) {
                                          [sender setFrame:CGRectMake(-29, 495, 300, 52)];
                                      } else {
                                          [sender setFrame:CGRectMake(-28, 425, 300, 42)];
                                      }
                                  }];
                              } completion: ^(BOOL finished){
                                  [UIView animateKeyframesWithDuration:0.28
                                                                 delay:0.03
                                                               options:1 << 16
                                                            animations:^{
                                                                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                                                    if ([[UIScreen mainScreen] bounds].size.height > 500) {
                                                                        [sender setFrame:CGRectMake(321, 496, 300, 52)];
                                                                    } else {
                                                                        [sender setFrame:CGRectMake(321, 419, 300, 42)];
                                                                    }
                                                                }];
                                                            } completion: ^(BOOL finished){
                                                                [[UIApplication sharedApplication]setStatusBarHidden:YES];
                                                                Login * signin = [Login new];
                                                                [self.navigationController pushViewController:signin animated:YES];
                                                                [sender removeFromSuperview];
                                                            }
                                   ];
                              }
     ];
}

-(void)loginFromAlertView
{
    Login * signin = [Login new];
    [self.navigationController pushViewController:signin animated:YES];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Rgstr_CnctnErrAlrtTitle", @"Register screen 'Connection Error' Alert Text")
                          message:NSLocalizedString(@"Rgstr_CnctnErrAlrtBody", @"Register screen Connection Error Alert Body Text")
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
        
        NSLog(@"Register -> LoginwithFB Result is: %@",[loginResult objectForKey:@"Result"]);
      
        if ([[loginResult objectForKey:@"Result"] isEqualToString:@"FBID or EmailId not registered with Nooch"])
        {
            [self.hud hide:YES];

            self.name_field.text = [NSString stringWithFormat:@"%@ %@",firstname_fb,lastname_fb];
            [self.password_field becomeFirstResponder];

            self.email_field.text = email_fb;
            
            NSString * imgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbID];

            [user setObject:fbID forKey:@"facebook_id"];

            if (imgURL)
            {
                NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
                NSMutableDictionary * dictWithFbImage = [self.facebook_info mutableCopy];
                [dictWithFbImage setObject:imgData forKey:@"image"];
                self.facebook_info = [dictWithFbImage mutableCopy];
            }

            [self.or setText:NSLocalizedString(@"Rgstr_NwCrtPwTxt", @"Register screen 'Now just create a password...' Instruction Text")];

            [self.facebookLogin setTitle:@"       Facebook Connected" forState:UIControlStateNormal];

            for (UIView *subview in self.facebookLogin.subviews) {
                if ([subview isMemberOfClass:[UILabel class]]) {
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
            [glyphFB setTextColor:[UIColor whiteColor]];
            glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes1];

            UILabel * glyph_check = [UILabel new];
            [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
            [glyph_check setFrame:CGRectMake(39, 8, 20, 30)];
            [glyph_check setTextColor:[UIColor whiteColor]];
            glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:textAttributes1];

            [self.facebookLogin addSubview:glyphFB];
            [self.facebookLogin addSubview:glyph_check];
            [self.facebookLogin setUserInteractionEnabled:NO];
        }

        else if ([loginResult objectForKey:@"Result"] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Invalid user id or password."] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"The password you have entered is incorrect."] &&
            ![[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] &&
            [[loginResult objectForKey:@"Result"] rangeOfString:@"Your account has been temporarily blocked."].location == NSNotFound &&
            loginResult != nil && ![loginResult[@"Result"] isKindOfClass:[NSNull class]])
        {
            serve * getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberId";
            [getDetails getMemIdFromuUsername:email_fb];
        }
        else if (  loginResult[@"Result"] != NULL &&
                 ![loginResult[@"Result"] isKindOfClass:[NSNull class]])
        {
            if ([self.view.subviews containsObject:self.hud])
            {
                [self.hud hide:YES];
            }
            
            [FBSession.activeSession close];
            [FBSession setActiveSession:nil];
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Unable to Login"
                                                            message:@"We had trouble connecting to that Facebook account.  Please try signing up by entering your name and email."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            [alert show];
            
            [self.name_field becomeFirstResponder];
            return;
        }
        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] rangeOfString:@"Your account has been temporarily blocked."].location != NSNotFound &&
                 loginResult != nil)
        {
            [self.hud hide:YES];
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended"
                                                            message:@"To keep Nooch safe your account has been temporarily suspended because you entered an incorrect password too many times.\n\nIn most cases your account will be automatically un-suspended in 24 hours. You can always contact support if this is a mistake or error.\n\nWe apologize for this inconvenience, please understand it is only to protect your account."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Contact Support", nil];
            [alert setTag:50];
            [alert show];

            [spinner stopAnimating];
        }

        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] && loginResult != nil)
        {
            [self.hud hide:YES];
            

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Suspended"
                                                            message:@"Your account has been temporarily suspended pending a review. We will contact you as soon as possible, and you can always contact us via email if this is a mistake or error."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Contact Support", nil];
            [alert setTag:51];
            [alert show];

            [spinner stopAnimating];
        }

        else if ( [loginResult objectForKey:@"Result"] &&
                 [[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] && loginResult != nil)
        {
            [spinner stopAnimating];
            [self.hud hide:YES];

          /*if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:NSLocalizedString(@"Rgstr_SuspAlrtTtl1", @"Register screen 'Account Temporarily Suspended' Alert Title")
                                             message:NSLocalizedString(@"Rgstr_SuspAlrtBody1", @"Register screen Account Temporarily Suspended Alert Body Text")
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
                UIAlertAction * contactSupport = [UIAlertAction
                                                  actionWithTitle:NSLocalizedString(@"Rgstr_SuspAlrtBtn1", @"Register screen 'Contact Support' Alert Btn")
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                                  {
                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                      [self emailNoochSupport];
                                                  }];
                [alert addAction:ok];
                [alert addAction:contactSupport];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            else // iOS 7 and prior
            {
              */UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Rgstr_SuspAlrtTtl2", @"Register screen 'Account Temporarily Suspended' Alert Title (2nd)")
                                                                message:NSLocalizedString(@"Rgstr_SuspAlrtBody2", @"Register screen Account Temporarily Suspended Alert Body Text (2nd)")
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:NSLocalizedString(@"Rgstr_SuspAlrtBtn2", @"Register screen 'Contact Support' Alert Btn (2nd)"), nil];
                [alert show];
                [alert setTag:52];
          //}
        }
    }

    else if ([tagName isEqualToString:@"getMemberId"])
    {
        NSError *error;
        //user = [NSUserDefaults standardUserDefaults];

        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        [user setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [user setObject:email_fb forKey:@"UserName"];

        NSMutableDictionary * automatic = [[NSMutableDictionary alloc] init];
        [automatic setObject:[user valueForKey:@"MemberId"] forKey:@"MemberId"];
        [automatic setObject:[user valueForKey:@"UserName"] forKey:@"UserName"];
        [automatic writeToFile:[self autoLogin] atomically:YES];

        me = [core new];
        [me birth];

        [[me usr] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [[me usr] setObject:email_fb forKey:@"UserName"];

        serve * enc_user = [serve new];
        [enc_user setDelegate:self];
        [enc_user setTagName:@"username"];
        [enc_user getEncrypt:email_fb];
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
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rgstr_EmlInUseAlrtTtl", @"Register screen 'Email In Use Already' Alert Title")
                                                         message:NSLocalizedString(@"Rgstr_EmlInUseAlrtBody", @"Register screen 'Email In Use Already' Alert Body Text")
                                                        delegate:self
                                               cancelButtonTitle:@"No"
                                               otherButtonTitles:@"Login", nil];
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

        if (!fbID) {
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
                     @"facebook_id":fbID,
                     @"image":[self.facebook_info objectForKey:@"image"]};
        }

        SelectPicture *picture = [[SelectPicture alloc] initWithData:user];
        [self.navigationController pushViewController:picture animated:YES];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 16 && buttonIndex == 1)
    {
        [self open_terms_webview];
    }
    else if (alertView.tag == 20 && buttonIndex == 1)
    {
        [self loginFromAlertView];
    }
    else if ((alertView.tag == 50 || alertView.tag == 51 || alertView.tag == 52) && buttonIndex == 1)
    {
        [self emailNoochSupport];
    }
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length + range.location > textField.text.length)
    {
        return NO;
    }

    if ([self.name_field.text length] > 1 &&
        [self.email_field.text length] > 2 &&
        [self.email_field.text rangeOfString:@"@"].location != NSNotFound &&
        [self.email_field.text rangeOfString:@"."].location != NSNotFound)
    {
        [self.cont setAlpha:1];

        if ([self.password_field.text length] > 4)
        {
            [self.cont setEnabled:YES];
            [self.cont setAlpha:1];
        }
        else {
            [self.cont setEnabled:NO];
        }
    }

    if ([self.name_field.text length] > 3 &&
        [self.name_field.text rangeOfString:@" "].location != NSNotFound &&
        [self.name_field.text rangeOfString:@" "].location < [self.name_field.text length] - 1)
    {
        [self.fullNameInstruc setHidden:YES];
        [self.nameValidator setHidden:YES];
    }
    else if (textField != self.name_field)
    {
        [self.fullNameInstruc setHidden:NO];
        [self.nameValidator setHidden:NO];
    }

    if ([self.email_field.text length] > 4 &&
        [self.email_field.text rangeOfString:@"@"].location != NSNotFound &&
        [self.email_field.text rangeOfString:@"."].location != NSNotFound &&
        [self.email_field.text rangeOfString:@" "].location == NSNotFound &&
        [self.email_field.text rangeOfString:@"."].location < [self.email_field.text length] - 2 &&
        (([self.email_field.text rangeOfString:@"."].location - [self.email_field.text rangeOfString:@"@"].location) != abs(1)))
    {
        if (![self.emailValidator isHidden] || textField == self.password_field)
        {
            [self.emailValidator setHidden:NO];
            [self.emailValidator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
            [self.emailValidator setTextColor:kNoochGreen];
        }
    }
    else
    {
        if (![self.emailValidator isHidden] || textField == self.password_field)
        {
            [self.emailValidator setHidden:NO];
            [self.emailValidator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"]];
            [self.emailValidator setTextColor:kNoochRed];
        }
    }

    if (textField == self.password_field)
    {
        [self.pwValidator1 setHidden:NO];
        [self.pwValidator2 setHidden:NO];
        [self.pwValidator3 setHidden:NO];
        [self.pwValidator4 setHidden:NO];
        [self.pwValidator setHidden:NO];

        NSCharacterSet * digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet * lowercaseCharSet = [NSCharacterSet lowercaseLetterCharacterSet];
        NSCharacterSet * uppercaseCharSet = [NSCharacterSet uppercaseLetterCharacterSet];
        NSCharacterSet * symbolsCharSet = [NSCharacterSet symbolCharacterSet];
        NSCharacterSet * whtspcCharSet = [NSCharacterSet whitespaceCharacterSet];
        NSCharacterSet * punctCharSet = [NSCharacterSet punctuationCharacterSet];

        [self.pwValidator setHidden:NO];

        double score = 0;
        NSString * textToCheck = [NSString stringWithFormat:@"%@%@", self.password_field.text, string];

        if ([textToCheck length] > 5)
        {
            pwLength = true;
        } else {
            pwLength = false;
        }
        if ([textToCheck rangeOfCharacterFromSet:lowercaseCharSet].location != NSNotFound)
        {
            score += .5;
        }
        if ([textToCheck rangeOfCharacterFromSet:uppercaseCharSet].location != NSNotFound)
        {
            score += .85;
        }
        if ([textToCheck rangeOfCharacterFromSet:digitsCharSet].location != NSNotFound)
        {
            score += 1;
        }
        if ([textToCheck rangeOfCharacterFromSet:symbolsCharSet].location != NSNotFound)
        {
            score += 1.25;
        }
        if ([textToCheck rangeOfCharacterFromSet:punctCharSet].location != NSNotFound)
        {
            score += 1.35;
        }
        if ([textToCheck rangeOfCharacterFromSet:whtspcCharSet].location != NSNotFound)
        {
            score += 1.3;
        }
        if ([self.password_field.text length] > 10)
        {
            score += 1.2;;
        }

        //NSLog(@"Score is: %f",score);
        if (pwLength && score > 4)
        {
            [self.pwValidator1 setBackgroundColor:kNoochGreen];
            [self.pwValidator2 setBackgroundColor:kNoochGreen];
            [self.pwValidator3 setBackgroundColor:kNoochGreen];
            [self.pwValidator4 setBackgroundColor:kNoochGreen];
            [self.pwValidator setText:NSLocalizedString(@"Rgstr_ExtrStrngTxt", @"Register screen 'Extremely Strong' PW Validator Text")];
            [self.pwValidator setTextColor:kNoochGreen];
        }
        else if (pwLength && score > 2.9)
        {
            [self.pwValidator1 setBackgroundColor:kNoochGreen];
            [self.pwValidator2 setBackgroundColor:kNoochGreen];
            [self.pwValidator3 setBackgroundColor:kNoochGreen];
            [self.pwValidator4 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator setTextColor:kNoochGreen];
            [self.pwValidator setText:NSLocalizedString(@"Rgstr_GoodTxt", @"Register screen 'Good' PW Validator Text")];
        }
        else if (pwLength && score > 1.5)
        {
            [self.pwValidator1 setBackgroundColor:[UIColor orangeColor]];
            [self.pwValidator2 setBackgroundColor:[UIColor orangeColor]];
            [self.pwValidator3 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator4 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator setTextColor:[UIColor orangeColor]];
            [self.pwValidator setText:NSLocalizedString(@"Rgstr_FairTxt", @"Register screen 'Fair' PW Validator Text")];
        }
        else if (pwLength)
        {
            [self.pwValidator4 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator3 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator2 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator1 setBackgroundColor:kNoochRed];
            [self.pwValidator setTextColor:kNoochRed];
            [self.pwValidator setText:NSLocalizedString(@"Rgstr_WeakTxt", @"Register screen 'Weak' PW Validator Text")];
        }
        else
        {
            if ([textToCheck length] > 0)
            {
                [self.pwValidator setText:NSLocalizedString(@"Rgstr_VrWeakTxt", @"Register screen 'Very Weak' PW Validator Text (2nd)")];
            }
            else {
                [self.pwValidator setText:@""];
            }
            [self.pwValidator4 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator3 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator2 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator1 setBackgroundColor:Rgb2UIColor(188, 190, 192, .5)];
            [self.pwValidator setTextColor:kNoochRed];
        }

        return YES;
    }
    else
    {
        [self.pwValidator setHidden:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 1:
            if ([self.name_field.text length] < 4 ||
                [self.name_field.text rangeOfString:@" "].location == NSNotFound ||
                [self.name_field.text rangeOfString:@" "].location > [self.name_field.text length] - 3)// ||
                //[self.name_field.text rangeOfString:@"-"].location > [self.name_field.text length] - 3 ||
                //[self.name_field.text rangeOfString:@"."].location > [self.name_field.text length] - 3)
            {
                if ([self.name_field.text length] > 2)
                {
                    [self.fullNameInstruc setHidden:NO];
                }
                [self.nameValidator setHidden:NO];
                [self.name_field becomeFirstResponder];
            }
            else if (([self.name_field.text rangeOfString:@"-"].location != NSNotFound &&
                     ([self.name_field.text rangeOfString:@"-"].location > [self.name_field.text length] - 3 ||
                      [self.name_field.text rangeOfString:@"-"].location < 2)) ||
                     ([self.name_field.text rangeOfString:@"."].location != NSNotFound &&
                     ([self.name_field.text rangeOfString:@"."].location > [self.name_field.text length] - 3 ||
                      [self.name_field.text rangeOfString:@"."].location < 2)))
            {
                [self.nameValidator setHidden:NO];
                [self.name_field becomeFirstResponder];
            }
            else
            {
                [self checkNameForNumsAndSpecChars];
            }
            break;
        case 2:
            if ( [self.email_field.text length] < 4 ||
                 [self.email_field.text rangeOfString:@"@"].location == NSNotFound ||
                 [self.email_field.text rangeOfString:@"."].location == NSNotFound ||
                 [self.email_field.text rangeOfString:@" "].location != NSNotFound ||
                 [self.email_field.text rangeOfString:@"."].location > [self.email_field.text length] - 3 ||
                (([self.email_field.text rangeOfString:@"."].location - [self.email_field.text rangeOfString:@"@"].location) == 1))
            {
                [self.emailValidator setHidden:NO];
                [self.emailValidator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"]];
                [self.emailValidator setTextColor:kNoochRed];

                [self.email_field becomeFirstResponder];
            }
            else
            {
                [self.emailValidator setHidden:NO];
                [self.emailValidator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
                [self.emailValidator setTextColor:kNoochGreen];

                [self.password_field becomeFirstResponder];
            }

            break;
        case 3:
            [textField resignFirstResponder];
            break;
        default:
            break;
    }
    return YES;
}

-(BOOL)checkNameForNumsAndSpecChars
{
    BOOL containsPunctuation = NSNotFound != [self.name_field.text rangeOfCharacterFromSet:NSCharacterSet.punctuationCharacterSet].location;
    BOOL containsNumber = NSNotFound != [self.name_field.text rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location;
    BOOL containsSymbols = NSNotFound != [self.name_field.text rangeOfCharacterFromSet:NSCharacterSet.symbolCharacterSet].location;
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"'.-"];
    BOOL containsDash = NSNotFound != [self.name_field.text rangeOfCharacterFromSet:characterSet].location;
    
    if (containsNumber)
    {
        [self.nameValidator setHidden:NO];
        [self.name_field becomeFirstResponder];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\xF0\x9F\x98\x8F  %@", NSLocalizedString(@"Rgstr_ReallyAlrtTtl1", @"Register screen Really Alert Title")]
                                                     message:NSLocalizedString(@"Rgstr_ReallyAlrtBody1", @"Register screen Really Alert Body Text")
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return false;
    }
    else if ((containsSymbols || containsPunctuation) &&
             !containsDash)
    {
        [self.nameValidator setHidden:NO];
        [self.name_field becomeFirstResponder];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\xF0\x9F\x98\x8F  %@", NSLocalizedString(@"Rgstr_ReallyAlrtTtl2", @"Register screen Really Alert Title")]
                                                     message:NSLocalizedString(@"Rgstr_ReallyAlrtBody2", @"Register screen Really Alert Body (2nd - symbol)")
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return false;
    }
    else
    {
        [self.fullNameInstruc setHidden:YES];
        [self.nameValidator setHidden:YES];

        if ([self.email_field.text length] < 2)
        {
            [self.email_field becomeFirstResponder];
        }
        return true;
    }
}

-(bool)checkEmailForShadyDomain
{
    NSString * emailToCheck = self.email_field.text;

    if ([emailToCheck rangeOfString:@"sharklasers"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"grr.la"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"guerrillamail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"spam4"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"anonymousemail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"anonemail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"hmamail.com"].location != NSNotFound || // "hideMyAss.com"
        [emailToCheck rangeOfString:@"mailinator"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mailinater"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"sendspamhere"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"sogetthis"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mt2014.com"].location != NSNotFound ||  // "myTrashMail.com"
        [emailToCheck rangeOfString:@"hushmail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mailnesia"].location != NSNotFound)
    {
        [self.emailValidator setHidden:NO];
        [self.emailValidator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"]];
        [self.emailValidator setTextColor:kNoochRed];
        
        [self.email_field becomeFirstResponder];

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Try A Different Email"
                                                     message:@"To protect all Nooch accounts, we ask that you please use a regular email address to create your account."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return false;
    }
    else
    {
        return true;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.name_field.text = self.name_field.text.capitalizedString;
}

-(void)emailNoochSupport
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                      message:@"You don't have an email account configured for this device."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [av show];
        return;
    }

    MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor=[UIColor whiteColor];
    [mailComposer setSubject:[NSString stringWithFormat:@"Help Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end