//
//  Signup.m
//  Nooch
//
//  Created by Preston Hults on 10/3/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "Signup.h"
#import "JSON.h"
#import "NoochHome.h"
#import "AppSkel.h"
#import <QuartzCore/QuartzCore.h>
#import "Tutorial1.h"
#import "settings.h"

@interface Signup ()

@end

@implementation Signup

//@synthesize email, firstName, lastName;
@synthesize accountStore, facebookAccount, emailTextField, firstNameTextField, lastNameTextField, passwordTextField, confirmPasswordTextField,facebookCheck,spinner,scrollView,activeField,checkBox,privacyLabel,serviceLabel,fbButton,signupTable,inviteCodeField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    CGRect frame = leftNavButton.frame;
    frame.size.width = 40;
    [leftNavButton setFrame:frame];
    facebookCheck.font = [UIFont fontWithName:@"Roboto" size:16];
    if (fbCreate) {
        [self gigyaButtonPressed:self];
    }
}
- (IBAction)choosePicture:(id)sender {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"signup loaded");
    emailTextField.font = [core nFont:@"Medium" size:13];
    firstNameTextField.font = [core nFont:@"Medium" size:13];
    lastNameTextField.font = [core nFont:@"Medium" size:13];
    passwordTextField.font = [core nFont:@"Medium" size:13];
    confirmPasswordTextField.font = [core nFont:@"Medium" size:13];
    serviceLabel.font = [core nFont:@"Medium" size:10];
    privacyLabel.font = [core nFont:@"Medium" size:10];
    checkBox.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkBoxTapped:)];
    [checkBox addGestureRecognizer:recognizer];
    signupTable.layer.cornerRadius = 10;
    signupTable.layer.borderWidth = 0;
    signupTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    picture.layer.cornerRadius = 15;
    picture.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    picture.layer.borderWidth = 0;
    picture.clipsToBounds = YES;
}

-(void)goBack
{
    [navCtrl popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if(indexPath.row == 0){
        [cell.textLabel setText:@"First Name"];
    }else if(indexPath.row == 1){
        [cell.textLabel setText:@"Last Name"];
    }else if(indexPath.row == 2){
        [cell.textLabel setText:@"Email"];
    }else if(indexPath.row == 3){
        [cell.textLabel setText:@"Password"];
    }else if(indexPath.row ==4){
        [cell.textLabel setText:@"Confirm Password"];
    }

    [cell.textLabel setFont:[core nFont:@"Medium" size:16]];
    return cell;
}


-(void)checkBoxTapped:(id)sender
{
    if(checkBox.isHighlighted)
        checkBox.highlighted = NO;
    else
        checkBox.highlighted = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gigyaButtonPressed:(id)sender {
    fbLogging = YES;
    fbUID = [[NSString alloc] init];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        self.accountStore = [[ACAccountStore alloc] init];
        self.facebookAccount = nil;
        me = [core new];
        [self.view addSubview:[me waitStat:@"Getting your Facebook info..."]];
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
                 NSLog(@"didnt grant cause: %@",e.description);
             }else{
                 
                 NSArray *accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
                 self.facebookAccount = [accounts lastObject];
                 [self renewFb];
                 
             }
         }];
        
    }else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"You do not have a Facebook account attached to this phone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}
-(void)renewFb{
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
-(void)finishFb{
    NSString *acessToken = [NSString stringWithFormat:@"%@",self.facebookAccount.credential.oauthToken];
    NSDictionary *parameters = @{@"access_token": acessToken,@"fields":@"id,username,first_name,last_name,email"};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodGET
                              URL:feedURL
                              parameters:parameters];
    feedRequest.account = self.facebookAccount;
    __block NSDictionary *d = [NSDictionary new];
    __block NSData *imgData = [NSData new];
    [feedRequest performRequestWithHandler:^(NSData *respData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         NSString *resp = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
         d = [resp JSONValue];
         NSLog(@"infoReturn %@",d);
         firstNameTextField.text = [d objectForKey:@"first_name"];
         lastNameTextField.text = [d objectForKey:@"last_name"];
         emailTextField.text = [d objectForKey:@"email"];
         NSString *imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [d objectForKey:@"id"]];
         imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
         if (![imgData isKindOfClass:[NSNull class]] && imgData.length > 0) {
             picture.image = [UIImage imageWithData:imgData];
             picture.layer.borderWidth = 1;
         }
         [me endWaitStat];
     }];
}

- (IBAction)createAccount:(id)sender {
    [spinner startAnimating];
    if(checkBox.isHighlighted){
        [self validation];
    }else{
        [spinner stopAnimating];
        UIAlertView *notAgreed = [[UIAlertView alloc] initWithTitle:nil message:@"Please agree to our Terms of Service and Privacy Policy." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notAgreed show];
    }

}

- (void)validation
{
    firstNameTextField.text = [firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    lastNameTextField.text = [lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    emailTextField.text = [emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    passwordTextField.text = [passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    confirmPasswordTextField.text = [confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    [spinner stopAnimating];
    if([firstNameTextField.text isEqualToString:@""]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter your first name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:1];
    }else if([lastNameTextField.text isEqualToString:@""]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter your last name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:2];
    }else if([emailTextField.text isEqualToString:@""]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter your email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:3];
    }else if (([emailTest evaluateWithObject:emailTextField.text] == NO) || (![self isValidEmail:emailTextField.text])){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:3];
    }else if([passwordTextField.text isEqualToString:@""]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please choose a password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:6];
    }else if([passwordTextField.text length] < 8){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain a minimum of 8 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:6];
    }else if([passwordTextField.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain at least one numeric character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:6];
    }else if([passwordTextField.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain at least one character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:6];
    }else{
        [spinner startAnimating];
        [[NSUserDefaults standardUserDefaults] setObject:firstNameTextField.text forKey:@"firstName"];
        [[NSUserDefaults standardUserDefaults] setObject:lastNameTextField.text forKey:@"lastName"];
        [[NSUserDefaults standardUserDefaults] setObject:emailTextField.text forKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] setObject:passwordTextField.text forKey:@"password"];

        serve *isDup = [serve new];
        isDup.tagName = @"duplicateCheck";
        isDup.Delegate = self;
        [isDup dupCheck:emailTextField.text];
    }
}

-(void)listen:(NSString *)result tagName:(NSString*)tagName
{
    NSDictionary *template =[result JSONValue];
    [spinner stopAnimating];
    if([[template objectForKey:@"Result"] isEqualToString:@"Not a nooch member."])
    {
        resetPIN = NO;
        if([fbUID length] != 0){
            [fbUID writeToFile:[self userEmailFile] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        [[NSUserDefaults standardUserDefaults] setObject:firstNameTextField.text forKey:@"firstName"];
        [[NSUserDefaults standardUserDefaults] setObject:lastNameTextField.text forKey:@"lastName"];
        [[NSUserDefaults standardUserDefaults] setObject:emailTextField.text forKey:@"UserName"];
        inviteCode = self.inviteCodeField.text;
        creatingAcct = YES;
        selectedPic = picture.image;
        [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"pin"] animated:YES];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[template objectForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}


-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    if(textField.tag > 1)
        [scrollView setContentOffset:CGPointMake(0.0,textField.frame.size.height+100) animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag +1;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    if(nextResponder){
        [nextResponder becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
        [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    }
    return NO;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch recognized");
    UITouch *touch = [[event allTouches] anyObject];
    if([firstNameTextField isFirstResponder]  &&  [touch view] != firstNameTextField)
    {
        [firstNameTextField resignFirstResponder];
    }
    else if([lastNameTextField isFirstResponder] && [touch view] != lastNameTextField)
    {
        [lastNameTextField resignFirstResponder];
    }
    else if([emailTextField isFirstResponder] && [touch view] != emailTextField)
    {
        [emailTextField resignFirstResponder];
    }
    else if([passwordTextField isFirstResponder] && [touch view] != passwordTextField)
    {
        [passwordTextField resignFirstResponder];
    }
    else if([confirmPasswordTextField isFirstResponder] && [touch view] != confirmPasswordTextField)
    {
        [confirmPasswordTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];


}
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

-(BOOL)isValidEmail:(NSString *)email
{
    NSArray *emailArray = [email componentsSeparatedByString:@"@"];
    NSRange titleResultsRange = [[emailArray objectAtIndex:1] rangeOfString:@".." options:NSCaseInsensitiveSearch];

    if( titleResultsRange.length >0 )
    {
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch([actionSheet tag])
    {
        case 1:
        {
            [firstNameTextField becomeFirstResponder];
            break;
        }
        case 2:
        {
            [lastNameTextField becomeFirstResponder];
            break;
        }
        case 3:
        {
            [emailTextField becomeFirstResponder];
            break;
        }
        case 6:
        {
            [passwordTextField becomeFirstResponder];
            break;
        }
        case 7:
        {
            [confirmPasswordTextField becomeFirstResponder];
            break;
        }
    }
}

- (void)viewDidUnload {
    [self setEmailTextField:nil];
    [self setFirstNameTextField:nil];
    [self setLastNameTextField:nil];
    [self setPasswordTextField:nil];
    [self setConfirmPasswordTextField:nil];
    [self setScrollView:nil];
    [self setCheckBox:nil];
    [self setServiceLabel:nil];
    [self setPrivacyLabel:nil];
    [self setServiceButton:nil];
    [self setPrivacyButton:nil];
    [self setFbButton:nil];
    [self setSignupTable:nil];
    [self setInviteCodeField:nil];
    leftNavButton = nil;
    navBar = nil;
    picture = nil;
    [super viewDidUnload];
}

- (NSString *)userEmailFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",emailTextField.text]];
}
@end
