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

@interface Register ()
@property(nonatomic,strong) UITextField *name_field;
@property(nonatomic,strong) UITextField *email_field;
@property(nonatomic,strong) UITextField *password_field;
@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;
@property(nonatomic,strong) __block NSMutableDictionary *facebook_info;
@property(nonatomic,strong) UIButton *facebook;
@property(nonatomic,strong) UIButton *cont;
@property(nonatomic,strong) MBProgressHUD *hud;
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
    self.trackedViewName = @"Register Screen";
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewDidLoad
{
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

    UILabel *signup = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, 320, 15)];
    [signup setText:@"Sign Up Below With"];
    [signup setStyleClass:@"instruction_text"];
    [self.view addSubview:signup];

    self.facebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebook setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.26) forState:UIControlStateNormal];
    self.facebook.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.facebook setTitle:@"  Facebook" forState:UIControlStateNormal];
    [self.facebook setFrame:CGRectMake(0, 153, 0, 0)];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [self.facebook setFrame:CGRectMake(0, 145, 0, 0)];
    }
    [self.facebook addTarget:self action:@selector(connect_to_facebook) forControlEvents:UIControlEventTouchUpInside];
    [self.facebook setStyleClass:@"button_blue"];
    
    UILabel *glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphFB setFrame:CGRectMake(60, 8, 30, 30)];
    [glyphFB setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"]];
    [glyphFB setTextColor:[UIColor whiteColor]];
    
    [self.facebook addSubview:glyphFB];
    [self.view addSubview:self.facebook];

    UILabel *or = [[UILabel alloc] initWithFrame:CGRectMake(0, 216, 320, 15)];
    [or setBackgroundColor:[UIColor clearColor]];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [or setFrame:CGRectMake(0, 218, 0, 0)];
    }
    [or setTextAlignment:NSTextAlignmentCenter];
    [or setText:@"Or..."];
    [or setStyleClass:@"label_small"];
    [self.view addSubview:or];

    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, 254, 60, 20)];
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

    UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(20, 294, 60, 20)];
    [email setBackgroundColor:[UIColor clearColor]]; [email setTextColor:kNoochBlue]; [email setText:@"Email"];
    [email setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:email];

    self.email_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 294, 200, 30)];
    [self.email_field setBackgroundColor:[UIColor clearColor]];
    [self.email_field setDelegate:self];
    [self.email_field setPlaceholder:@"Email Address"];
    [self.email_field setKeyboardType:UIKeyboardTypeEmailAddress];
    self.email_field .returnKeyType = UIReturnKeyNext;
    [self.email_field setTag:2];
    [self.email_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.email_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.email_field setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.email_field];

    UILabel *password = [[UILabel alloc] initWithFrame:CGRectMake(20, 334, 80, 20)];
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

    UIButton *checkbox_dot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkbox_dot setBackgroundColor:[UIColor clearColor]];
    [checkbox_dot setTitle:@"  " forState:UIControlStateNormal];
    [checkbox_dot setFrame:CGRectMake(31, 381, 31, 30)];
    [checkbox_dot setStyleId:@"checkbox_dot"];
    [self.view addSubview:checkbox_dot];
    [checkbox_dot addTarget:self action:@selector(termsAndConditions:) forControlEvents:UIControlEventTouchUpInside];
    isTermsChecked = NO;
    
    UILabel * termsText1 = [UILabel new];
    [termsText1 setFont:[UIFont fontWithName:@"Roboto-light" size:13]];
    [termsText1 setFrame:CGRectMake(65, 388, 55, 14)];
    [termsText1 setText:@"I agree to "];
    [termsText1 setTextColor:kNoochGrayDark];
    [self.view addSubview:termsText1];

    UIButton * termsText2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [termsText2 setFrame:CGRectMake(122, 388, 150, 14)];
    [termsText2 setBackgroundColor:[UIColor clearColor]];
    [termsText2 setTitle:@"Nooch's Terms of Service." forState:UIControlStateNormal];
    [termsText2 setStyleClass:@"termsCheckText"];
    [termsText2 addTarget:self action:@selector(open_terms_webview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:termsText2];
    
    UIView * blankView = [UIView new];
    blankView.frame = CGRectMake(0, 13, 147, 1);
    [blankView setBackgroundColor:kNoochGrayDark];
    [blankView setAlpha:0.6];
    [termsText2 addSubview:blankView];
    
    self.cont = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cont setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.26) forState:UIControlStateNormal];
    self.cont.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.cont setTitle:@"Continue" forState:UIControlStateNormal];
    [self.cont setFrame:CGRectMake(10, 424, 300, 60)];
    [self.cont addTarget:self action:@selector(continue_to_signup) forControlEvents:UIControlEventTouchUpInside];
    [self.cont setStyleClass:@"button_green"];
    [self.view addSubview:self.cont];
    [self.cont setEnabled:NO];

    UIButton *login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [login setBackgroundColor:[UIColor clearColor]];
    [login setTitle:@"Already a Member?  Sign in here " forState:UIControlStateNormal];
    [login setFrame:CGRectMake(10, 490, 280, 30)];
    [login addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [login setStyleClass:@"label_small"];
    [self.view addSubview:login];
    
    UILabel *glyph_login = [UILabel new];
    [glyph_login setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    [glyph_login setFrame:CGRectMake(264, 0, 18, 30)];
    [glyph_login setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-circle-right"]];
    [glyph_login setTextColor:kNoochGreen];
    [login addSubview:glyph_login];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [name setFrame:CGRectMake(0, 246, 0, 0)];
        [self.name_field setFrame:CGRectMake(0, 246, 0, 0)];
        
        [email setFrame:CGRectMake(0, 286, 0, 0)];
        [self.email_field setFrame:CGRectMake(0, 286, 0, 0)];
        
        [password setFrame:CGRectMake(0, 326, 0, 0)];
        [self.password_field setFrame:CGRectMake(0, 326, 0, 0)];
        
        [self.cont setFrame:CGRectMake(0, 379, 0, 0)];
        
        [login setFrame:CGRectMake(0, 438, 320, 20)];
    }
}
-(void)termsAndConditions:(UIButton*)sender{
    if (isTermsChecked) {
         isTermsChecked=NO;
         [sender setTitle:@"" forState:UIControlStateNormal];
    }
    else{
        isTermsChecked=YES;
        [sender setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle"] forState:UIControlStateNormal];
        [sender setStyleId:@"checkbox_dot"];
    }
}
- (void)open_terms_webview
{
   // [self.navigationController setNavigationBarHidden:NO];
    isfromRegister = YES;
    terms *term = [terms new];
    [nav_ctrl presentViewController:term animated:YES completion: nil];
    
    
}

#pragma mark - facebook integration
- (void)connect_to_facebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
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
                     self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                     [self.navigationController.view addSubview:self.hud];
                     self.hud.delegate = self;
                     self.hud.labelText = @"Loading Facebook Info...";
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
            NSLog(@"error from renew credentials%@",error);
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
                               JSONObjectWithData:respData //1
                               options:kNilOptions
                               error:&error];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.hud hide:YES];
             self.name_field.text = [NSString stringWithFormat:@"%@ %@",[self.facebook_info objectForKey:@"first_name"],[self.facebook_info objectForKey:@"last_name"]];
             [self.name_field becomeFirstResponder];
             self.email_field.text = [self.facebook_info objectForKey:@"email"];
             NSString *imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [self.facebook_info objectForKey:@"id"]];
             [[NSUserDefaults standardUserDefaults] setObject:[self.facebook_info objectForKey:@"id"] forKey:@"facebook_id"];
             NSData *imgData = [NSData new];
             imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
             NSMutableDictionary *d = [self.facebook_info mutableCopy];
             [d setObject:imgData forKey:@"image"];
             self.facebook_info = [d mutableCopy];
             [self.facebook setTitle:@"Facebook Connected" forState:UIControlStateNormal];
             [self.facebook setUserInteractionEnabled:NO];
         });
        
     }];
}

#pragma mark - navigation
- (void)continue_to_signup
{
    if (!isTermsChecked) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Nooch" message:@"Please check Nooch's terms of service to proceed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
         return;
    }
    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:CGRectMake(0,0, 320, 600)];
    [UIView commitAnimations];
    
    if ([[[self.name_field.text componentsSeparatedByString:@" "] objectAtIndex:0]length] < 3)
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Need a Full Name" message:@"Nooch is currently only able to handle names greater than 3 letters.\n\nIf your first or last name has fewer than 3, please contact us and we'll be happy to manually create your account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    if ([self.password_field.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"So Close" message:@"For security reasons, et cetera, we ask that passwords contain at least 1 number.\n\nWe know it's annoying, but we're just looking out for you. Keep it safe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.password_field becomeFirstResponder];
        return;
    }
    else if([self.password_field.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Letters Are Fun Too" message:@"Regrettably, your Nooch password must contain at least one actual letter." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.password_field becomeFirstResponder];
        return;
    }
    else
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = @"Registering your account";
        [spinner1 startAnimating];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        [self.hud show:YES];

        [[assist shared]setIsloginFromOther:NO];

        serve *check_duplicate = [serve new];
        [check_duplicate setTagName:@"check_dup"];
        [check_duplicate setDelegate:self];
        [check_duplicate dupCheck:[self.email_field.text lowercaseString]];
    }
}

- (void)login
{
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    Login *signin = [Login new];
    [self.navigationController pushViewController:signin animated:YES];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"check_dup"])
    {
        [self.hud hide:YES];
        NSError *error;
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (![[loginResult objectForKey:@"Result"] isEqualToString:@"Not a nooch member."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email in Use" message:@"The email address you are attempting to sign up with is already in use." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }

        NSString *first_name;
        NSString *last_name;
        NSArray *arr = [[self.name_field.text lowercaseString]componentsSeparatedByString:@" "];
        if ([arr count]>1) {
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
        else{
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

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.name_field.text length] > 0 && [self.email_field.text length] > 0 && [self.email_field.text  rangeOfString:@"@"].location != NSNotFound && [self.email_field.text  rangeOfString:@"."].location != NSNotFound
        && [self.password_field.text length] > 6)
    {
        [self.cont setEnabled:YES];
    }
    else {
        [self.cont setEnabled:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.name_field.text.capitalizedString;
    if (textField == self.password_field)
    {
        [UIView beginAnimations:@"bucketsOff" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelegate:self];
        [self.view setFrame:CGRectMake(0,0, 320, 600)];
        [UIView commitAnimations];
        return;
    }
   // [self animateTextField:textField up:NO];
}

#pragma mark - adjusting for textfield view
- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
/*    const int movementDistance = textField.frame.origin.y/2; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];*/
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end