//  Register.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "Register.h"
#import "Home.h"
#import "SelectPicture.h"
#import "Login.h"

@interface Register ()
@property(nonatomic,strong) UITextField *name_field;
@property(nonatomic,strong) UITextField *email_field;
@property(nonatomic,strong) UITextField *password_field;
@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;
@property(nonatomic,strong) __block NSMutableDictionary *facebook_info;
@property(nonatomic,strong) UIButton *facebook;
@property(nonatomic,strong) UIButton *cont;
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
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [nav_ctrl performSelector:@selector(disable)];
    
    // Do any additional setup after loading the view from its nib.

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:YES];
    self.facebook_info = [NSMutableDictionary new];

    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];

    UILabel *signup = [[UILabel alloc] initWithFrame:CGRectMake(0, 115, 320, 15)];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [signup setFrame:CGRectMake(0, 105, 0, 0)];
    }
    [signup setText:@"Sign Up Below With"];
    [signup setStyleClass:@"instruction_text"];
    [self.view addSubview:signup];

    self.facebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebook setTitle:@"Facebook" forState:UIControlStateNormal];
    [self.facebook setFrame:CGRectMake(0, 180, 0, 0)];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [self.facebook setFrame:CGRectMake(0, 165, 0, 0)];
    }
    [self.facebook addTarget:self action:@selector(connect_to_facebook) forControlEvents:UIControlEventTouchUpInside];
    [self.facebook setStyleClass:@"button_blue"];
    [self.view addSubview:self.facebook];

    UILabel *or = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 320, 15)]; [or setBackgroundColor:[UIColor clearColor]];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [or setFrame:CGRectMake(0, 220, 0, 0)];
    }
    [or setTextAlignment:NSTextAlignmentCenter]; [or setText:@"Or..."];
    [or setStyleClass:@"label_small"];
    [self.view addSubview:or];

    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, 285, 60, 20)];
    [name setBackgroundColor:[UIColor clearColor]]; [name setTextColor:kNoochBlue]; [name setText:@"Name"];
    [name setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:name];

    self.name_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 285, 200, 30)];
    [self.name_field setBackgroundColor:[UIColor clearColor]]; [self.name_field setDelegate:self];
    [self.name_field setPlaceholder:@"First and Last Name"];
    [self.name_field setKeyboardType:UIKeyboardTypeAlphabet]; [self.name_field setTag:1];
    [self.name_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.name_field setStyleClass:@"table_view_cell_detailtext_1"];
    [self.name_field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [self.view addSubview:self.name_field];

    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [name setFrame:CGRectMake(0, 250, 0, 0)];
        [self.name_field setFrame:CGRectMake(0, 250, 0, 0)];
    }

    UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(20, 325, 60, 20)];
    [email setBackgroundColor:[UIColor clearColor]]; [email setTextColor:kNoochBlue]; [email setText:@"Email"];
    [email setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:email];

    self.email_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 325, 200, 30)];
    [self.email_field setBackgroundColor:[UIColor clearColor]]; [self.email_field setDelegate:self];
    [self.email_field setPlaceholder:@"Email Address"];
    [self.email_field setKeyboardType:UIKeyboardTypeEmailAddress]; [self.email_field setTag:2];
    [self.email_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.email_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.email_field setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.email_field];

    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [email setFrame:CGRectMake(0, 290, 0, 0)];
        [self.email_field setFrame:CGRectMake(0, 290, 0, 0)];
    }

    UILabel *password = [[UILabel alloc] initWithFrame:CGRectMake(20, 365, 80, 20)];
    [password setBackgroundColor:[UIColor clearColor]]; [password setTextColor:kNoochBlue]; [password setText:@"Password"];
    [password setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:password];

    self.password_field = [[UITextField alloc] initWithFrame:CGRectMake(90, 365, 200, 30)];
    [self.password_field setBackgroundColor:[UIColor clearColor]]; [self.password_field setDelegate:self];
    [self.password_field setPlaceholder:@"Password"]; [self.password_field setKeyboardType:UIKeyboardTypeAlphabet];
    [self.password_field setSecureTextEntry:YES]; [self.password_field setTag:3];
    [self.password_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.password_field setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.password_field];

    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [password setFrame:CGRectMake(0, 330, 0, 0)];
        [self.password_field setFrame:CGRectMake(0, 330, 0, 0)];
    }

    self.cont = [UIButton buttonWithType:UIButtonTypeRoundedRect]; [self.cont setTitle:@"Continue" forState:UIControlStateNormal];
    [self.cont setFrame:CGRectMake(10, 420, 300, 60)]; [self.cont addTarget:self action:@selector(continue_to_signup) forControlEvents:UIControlEventTouchUpInside];
    [self.cont setStyleClass:@"button_green"];
    [self.view addSubview:self.cont];
    [self.cont setEnabled:NO];

    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [self.cont setFrame:CGRectMake(0, 375, 0, 0)];
    }

    UIButton *login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [login setBackgroundColor:[UIColor clearColor]]; //[login setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [login setTitle:@"Already a Member? Sign in." forState:UIControlStateNormal];
    [login setFrame:CGRectMake(0, 510, 320, 20)]; [login addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [login setStyleClass:@"label_small"];
    [self.view addSubview:login];
    
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [login setFrame:CGRectMake(0, 445, 320, 20)];
    }
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
             else{
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
    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:CGRectMake(0,0, 320, 600)];
    [UIView commitAnimations];
    
    if ([[[self.name_field.text componentsSeparatedByString:@" "] objectAtIndex:0]length]<3) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:nil message:@"Our system is currently only able to handle names greater than 3 letters. Please email us if your first or last name has fewer than 3." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (([self.password_field.text length] == 0) || ([self.name_field.text length] == 0) || ([self.email_field.text length] == 0)) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Eager Beaver" message:@"You have not filled out the sign up form!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    if([self.password_field.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sooo Close" message:@"For sucurity reasons, et cetera, et cetera... we ask that passwords contain at LEAST 1 number. We know it's annoying, but just trying to look out for you. Keep it safe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    else if([self.password_field.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Letters Are Fun Too" message:@"Regrettably, your Nooch password must contain at least one actual letter." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    else{
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:spinner];
        spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [spinner startAnimating];

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
    if ([tagName isEqualToString:@"check_dup"]) {
        NSError *error;
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (![[loginResult objectForKey:@"Result"] isEqualToString:@"Not a nooch member."]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email in Use" message:@"The email address you are attempting to sign up with is already in use." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [spinner stopAnimating];
            [spinner setHidden:YES];
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
        }else{
            user = @{@"first_name":first_name,
                     @"last_name":last_name,
                     @"email":self.email_field.text,
                     @"password":self.password_field.text,
                     @"facebook_id":[self.facebook_info objectForKey:@"id"],
                     @"image":[self.facebook_info objectForKey:@"image"]};
        }
        [spinner stopAnimating];
        [spinner setHidden:YES];
        SelectPicture *picture = [[SelectPicture alloc] initWithData:user];
        [self.navigationController pushViewController:picture animated:YES];
    }
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //int len = [textField.text length] + [string length];
    //NSString *new_string;
    if([string length] == 0) //deleting
    {
        //new_string = [textField.text substringToIndex:[textField.text length]-1];
    }else{
        
    }
    if ([self.name_field.text length] > 0 && [self.email_field.text length] > 0 && [self.email_field.text  rangeOfString:@"@"].location != NSNotFound && [self.email_field.text  rangeOfString:@"."].location != NSNotFound
        && [self.password_field.text length] > 6) {
        [self.cont setEnabled:YES];
    }else {
        [self.cont setEnabled:NO];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[textField resignFirstResponder];
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
    if (textField== self.password_field) {
        [UIView beginAnimations:@"bucketsOff" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelegate:self];
        [self.view setFrame:CGRectMake(0,0, 320, 600)];
        [UIView commitAnimations];
        return;
    }
    [self animateTextField:textField up:NO];
}

#pragma mark - adjusting for textfield view
- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = textField.frame.origin.y/2; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end