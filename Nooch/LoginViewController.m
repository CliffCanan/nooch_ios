//
//  LoginViewController.m
//  Nooch
//
//  Created by Preston Hults on 9/7/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "LoginViewController.h"
#import "NSString+SBJSON.h"
#import "NSData+AESCrypt.h"
#import "NSString+AESCrypt.h"
#import "NoochHome.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize emailAddress, password, forgotPassword, checkBox,spinner,keepLoggedIn,forgotPassLabel,loginTable,inputAccessory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"login loaded");
    self.trackedViewName = @"Login";
    spinner.hidesWhenStopped = YES;
    emailAddress.font = [core nFont:@"Medium" size:14];
    password.font = [core nFont:@"Medium" size:14];
    keepLoggedIn.font = [core nFont:@"Medium" size:12];
    forgotPassLabel.font = [core nFont:@"Medium" size:12];
    [checkBox setHighlighted:YES];
    checkBox.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkBoxTapped:)];
    [checkBox addGestureRecognizer:recognizer];
    loginTable.layer.cornerRadius = 10;
    loginTable.layer.borderWidth = 1;
    loginTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if(indexPath.row == 0){
        [cell.textLabel setText:@"Email"];
    }else{
        [cell.textLabel setText:@"Password"];
    }

    [cell.textLabel setFont:[core nFont:@"Medium" size:16]];
    return cell;
}

-(void)goBack{
    [navCtrl popViewControllerAnimated:YES];
}

-(void)checkBoxTapped:(id)sender{
    if(checkBox.isHighlighted)
        checkBox.highlighted = NO;
    else
        checkBox.highlighted = YES;
}

- (void)viewDidUnload{
    [self setCheckBox:nil];
    [self setEmailAddress:nil];
    [self setPassword:nil];
    [self setSpinner:nil];
    [self setForgotPassword:nil];
    [self setKeepLoggedIn:nil];
    [self setForgotPassLabel:nil];
    [self setLoginTable:nil];
    [self setInputAccessory:nil];
    navBar = nil;
    leftNavButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField == emailAddress){
        [password becomeFirstResponder];
    }else if(textField == password){
        [textField resignFirstResponder];
    }else{
        [textField resignFirstResponder];
        [writeMemo dismissWithClickedButtonIndex:0 animated:YES];
        if([textField.text length] != 0){
            [emailAddress setText:textField.text];
            serve *forgetful = [serve new];
            forgetful.Delegate = self; forgetful.tagName = @"ForgotPass";
            [forgetful forgotPass:emailAddress.text];
        }else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter an email address for us to send a recovery email to." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }

    }

    return YES;
}

- (IBAction)loginButton:(id)sender {
    [spinner startAnimating];

    emailAddress.text = [emailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password.text = [password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    if([emailAddress.text isEqualToString:@""]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter your email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:1];
        [spinner stopAnimating];
    }
    else if ([emailTest evaluateWithObject:emailAddress.text] == NO){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:1];
        [spinner stopAnimating];
    }
    else if([password.text isEqualToString:@""]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter your password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:2];
        [spinner stopAnimating];
    }
    else{
        [self getEncryptedPasswords];
    }
}

- (IBAction) getEncryptedPasswords{
    serve *req = [[serve alloc] init];
    req.Delegate = self;
    [req getEncrypt:password.text];
}
- (IBAction)forgotPass:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure you wish to reset your password?" message:@"An email will be sent to your address with a link for resetting your password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [av setTag:3];
    [av show];
}

-(void)listen:(NSString *)result tagName:(NSString*)tagName{
    NSLog(@"result %@",result);
    NSDictionary *loginResult = [result JSONValue];
    if([tagName isEqualToString:@"getMemberDetails"]){
        [[NSUserDefaults standardUserDefaults] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setObject:emailAddress.text forKey:@"UserName"];
        if (!checkBox.isHighlighted) {
            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        }else{
            NSMutableDictionary *automatic = [[NSMutableDictionary alloc] init];
            [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"MemberId"];
            [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserName"] forKey:@"UserName"];
            [automatic writeToFile:[self autoLogin] atomically:YES];
        }
        me = [core new];
        [me birth];
        [spinner stopAnimating];
        [[me usr] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [[me usr] setObject:emailAddress.text forKey:@"UserName"];
        signin = YES;
        transferFinished = YES;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:navCtrl.view cache:NO];
        [UIView commitAnimations];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.375];
        [navCtrl popToRootViewControllerAnimated:NO];
        rainbows = NO;
        [UIView commitAnimations];
        return;
    }
    if([[loginResult objectForKey:@"Result"] isEqualToString:@"Success"] || [[loginResult objectForKey:@"Result"] isEqualToString:@"Logged in successfully."] )
    {
        serve *getDetails = [serve new];
        getDetails.Delegate = self;
        getDetails.tagName = @"getMemberDetails";
        [getDetails getMemIdFromuUsername:emailAddress.text];
    }
    else if([loginResult objectForKey:@"Status"])
    {
        getEncryptedPasswordValue = [[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]];

        serve *login = [serve new];
        login.Delegate = self;
        login.tagName = @"loginRequest";
        [login login:emailAddress.text password:getEncryptedPasswordValue];
    } else if([tagName isEqualToString:@"ForgotPass"]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Check your email for a reset password link." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [spinner stopAnimating];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[loginResult objectForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [spinner stopAnimating];
    }
}

#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];

}
- (NSString *)userEmailFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",emailAddress.text]];
}

# pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
    NSLog(@"Data : %@",data);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
- (IBAction)cancelForgotPass:(id)sender {
    [writeMemo dismissWithClickedButtonIndex:0 animated:YES];
}

# pragma mark - AlertView Delegate Method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 3){
        if(buttonIndex == 1){
            writeMemo = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [writeMemo setBackgroundColor:[UIColor clearColor]];
            UIImageView *textBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 75)];
            UIImage *textBack2 = [UIImage imageNamed:@"FundsField.png"];
            [textBack setImage:textBack2];
            [writeMemo addSubview:textBack];
            UITextField *memoText = [[UITextField alloc] initWithFrame:CGRectMake(12, 30, 260, 25)];
            [memoText setTextAlignment:UITextAlignmentCenter];
            [writeMemo addSubview:memoText];
            [writeMemo show];
            [writeMemo setTag:12];
            [memoText setDelegate:self];
            [memoText setFont:[UIFont fontWithName:@"Roboto" size:14]];
            [memoText setPlaceholder:@"Email Address"];
            [memoText setText:emailAddress.text];
            [memoText setReturnKeyType:UIReturnKeyDone];
            [memoText setKeyboardType:UIKeyboardTypeEmailAddress];
            [memoText setInputAccessoryView:inputAccessory];
            [memoText setSpellCheckingType:UITextSpellCheckingTypeNo];
            [memoText setAutocorrectionType:UITextAutocorrectionTypeNo];
            [memoText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [memoText becomeFirstResponder];
        }
    }else if([actionSheet tag] == 1){
        //do thing for first alert view
        [emailAddress becomeFirstResponder];
    }else if([actionSheet tag] == 2){
        //do something for second alert view
        [password becomeFirstResponder];
    }
}

@end
