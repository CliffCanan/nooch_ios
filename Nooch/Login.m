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
@interface Login (){
    core*me;
}
@property(nonatomic,strong) UITextField *email;
@property(nonatomic,strong) UITextField *password;
@property(nonatomic,strong) UISwitch *stay_logged_in;
@property(nonatomic,strong) UIButton *login;
@property(nonatomic,strong) UIActivityIndicatorView *loading;
@property(nonatomic,strong) NSString *encrypted_pass;
@end

@implementation Login
@synthesize inputAccessory;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //[self.navigationItem setHidesBackButton:YES];
        
        // Custom initialization
    }
    return self;
}


- (void)check_credentials
{
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [spinner startAnimating];
    serve *log = [serve new];
    [log setDelegate:self];
    [log setTagName:@"encrypt"];
    [[assist shared]setPassValue:self.password.text];
    [log getEncrypt:self.password.text];
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //nslog(@"Error : %@",error);
    if ([error code] == kCLErrorDenied){
        //nslog(@"Error : %@",error);
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton* btnback=[UIButton buttonWithType:UIButtonTypeCustom];

    [btnback setImage:[UIImage imageNamed:@"back-arrow-blue.png"] forState:UIControlStateNormal];
    [btnback setStyleClass:@"back_button-icon"];
    btnback.frame=CGRectMake(0, 7, 50, 30);
    
    [btnback addTarget:self action:@selector(BackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnback];

    [self.navigationItem setTitle:@"LogIn"];
    self.loading = [UIActivityIndicatorView new];
    [self.loading setStyleId:@"loading"];

    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];

    self.email = [[UITextField alloc] initWithFrame:CGRectMake(30, 160, 300, 40)];
    [self.email setBackgroundColor:[UIColor clearColor]]; [self.email setPlaceholder:@"Email"];
    [self.email setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.email setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    //[self.email setTextColor:kNoochLight];
    [self.email setTextAlignment:NSTextAlignmentRight];
    [self.email setDelegate:self];
    //self.email.layer.borderColor = kNoochLight.CGColor; self.email.layer.borderWidth = 1;
    //self.email.layer.opacity = 0.75;
    //self.email.layer.cornerRadius = 1;
    [self.email setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.email];
    
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 195, 0, 0)];
    [div setStyleId:@"divider"];
    [self.view addSubview:div];

    UILabel *em = [UILabel new]; [em setStyleClass:@"table_view_cell_textlabel_1"];
    CGRect frame = em.frame; frame.origin.y = 160; //frame = CGRectMake(10, 100, 300, 30);
    [em setBackgroundColor:[UIColor clearColor]];
    [em setFrame:frame];
    [em setText:@"Email"];
    [self.view addSubview:em];

    self.password = [[UITextField alloc] initWithFrame:CGRectMake(30, 199, 260, 40)];
    [self.password setBackgroundColor:[UIColor clearColor]]; [self.password setPlaceholder:@"Password"];
    [self.password setSecureTextEntry:YES]; [self.password setTextAlignment:NSTextAlignmentRight];
    //[self.password setTextColor:kNoochLight];
    [self.password setDelegate:self];
    //self.password.layer.borderColor = kNoochLight.CGColor; self.password.layer.borderWidth = 1;
    //self.password.layer.opacity = 0.75;
    //self.password.layer.cornerRadius = 1;
    [self.password setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.password];

    UILabel *pass = [UILabel new]; [pass setStyleClass:@"table_view_cell_textlabel_1"];
    frame = pass.frame; frame.origin.y = 199;
    [pass setFrame:frame];
    [pass setText:@"Password"];
    [self.view addSubview:pass];

    self.login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.login setBackgroundColor:kNoochGreen]; [self.login setTitle:@"Log In" forState:UIControlStateNormal];
    [self.login setFrame:CGRectMake(10, 260, 300, 60)];
    self.login.layer.cornerRadius=5.0f;
    [self.login addTarget:self action:@selector(check_credentials) forControlEvents:UIControlEventTouchUpInside];
    [self.login setStyleClass:@"button_green"];
    [self.view addSubview:self.login];
    [self.login setEnabled:NO];

    self.stay_logged_in = [[UISwitch alloc] initWithFrame:CGRectMake(110, 321, 40, 40)];
    [self.stay_logged_in setStyleClass:@"login_switch"];
    self.stay_logged_in.transform = CGAffineTransformMakeScale(0.75, 0.75);
    [self.view addSubview:self.stay_logged_in];
    
    UILabel *remember_me = [[UILabel alloc] initWithFrame:CGRectMake(20, 330, 100, 35)];
    [remember_me setText:@"Remember Me"];
    [remember_me setFont:[UIFont fontWithName:@"Roboto-Regular" size:12]];
    [remember_me setTextColor:kNoochGrayLight];
    [remember_me setStyleId:@"label_rememberme"];
    [self.view addSubview:remember_me];
    
    UIButton *forgot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [forgot setBackgroundColor:[UIColor clearColor]];
    [forgot setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [forgot setFrame:CGRectMake(190, 330, 120, 30)];
    [forgot.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:12]];
    [forgot setTitleColor:kNoochGrayLight forState:UIControlStateNormal];
    [forgot addTarget:self action:@selector(forgot_pass) forControlEvents:UIControlEventTouchUpInside];
    [forgot setStyleId:@"label_forgotpw"];
    [self.view addSubview:forgot];
    
    /*UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [back addTarget:self action:@selector(go_back) forControlEvents:UIControlEventTouchUpInside];
     [back setBackgroundColor:[UIColor clearColor]];
     [back setTitle:@"<" forState:UIControlStateNormal];
     [back setTitleColor:kNoochBlue forState:UIControlStateNormal];
     [back.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:40]];
     [back setFrame:CGRectMake(10, 20, 40, 40)];
     [self.view addSubview:back];*/

    UILabel *encryption; [encryption setStyleId:@"label_encryption"];
    [self.view addSubview:encryption];

    UIImageView *encrypt_icon;
    [encrypt_icon setStyleId:@"icon_encryption"];
    [self.view addSubview:encrypt_icon];
}

- (void) go_back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) forgot_pass
{
    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Please enter your email and we will send you a reset link." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setText:self.email.text];
    [alert setTag:220011];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{    
    if(actionSheet.tag==220011&& buttonIndex==1){
        UITextField *emailField = [actionSheet textFieldAtIndex:0];
        if ([emailField.text length] > 0 && [emailField.text  rangeOfString:@"@"].location != NSNotFound && [emailField.text  rangeOfString:@"."].location != NSNotFound){
            [spinner startAnimating];
            [spinner setHidden:NO];
            serve *forgetful = [serve new];
            forgetful.Delegate = self; forgetful.tagName = @"ForgotPass";
            [forgetful forgotPass:emailField.text];   
        }
    }
    else if ((actionSheet.tag == 50 && buttonIndex == 1) || (actionSheet.tag == 500 && buttonIndex == 1) || (actionSheet.tag == 510 && buttonIndex == 1))
        {
            if (![MFMailComposeViewController canSendMail]){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have an email account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
        else
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Enter Valid Email ID" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle=UIAlertViewStylePlainTextInput;
            [alert setTag:220011];
            [alert show];
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
-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    if([tagName isEqualToString:@"ForgotPass"]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Please check your email for a reset password link." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [spinner stopAnimating];
        [spinner setHidden:YES];
    }
    
    else if ([tagName isEqualToString:@"encrypt"]) {
        NSError *error;
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        //nslog(@"json test %@",loginResult);
        self.encrypted_pass = [[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]];
        
        serve *log = [serve new];
        [log setDelegate:self];
        [log setTagName:@"login"];
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstName"];
        // NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *udid=[[UIDevice currentDevice] uniqueDeviceIdentifier];
        //nslog(@"%@",udid);
        [[assist shared]setlocationAllowed:YES];
        [[NSUserDefaults standardUserDefaults] setObject:self.email.text forKey:@"email"];

        if ([self.stay_logged_in isOn]) {
            [log login:[self.email.text lowercaseString] password:self.encrypted_pass remember:YES lat:lat lon:lon uid:udid];
        }
        else{
            [log login:[self.email.text lowercaseString] password:self.encrypted_pass remember:NO lat:lat lon:lon uid:udid];
        }
        
    }
    else if ([tagName isEqualToString:@"login"])
    {
        NSError *error;
        
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if([loginResult objectForKey:@"Result"] && ![[loginResult objectForKey:@"Result"] isEqualToString:@"Invalid user id or password."] && ![[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] && ![[loginResult objectForKey:@"Result"] isEqualToString:@"The password you have entered is incorrect."] && ![[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] && loginResult != nil)
        {
            serve *getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberId";
            [getDetails getMemIdFromuUsername:[self.email.text lowercaseString]];
        }
        
        else if([loginResult objectForKey:@"Result"] && [[loginResult objectForKey:@"Result"] isEqualToString:@"Invalid user id or password."] && loginResult != nil){
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Invalid Email or Password" message:@"We don't recognize that information, please double check your email is entered correctly and try again." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [spinner stopAnimating];
        }
        else if([loginResult objectForKey:@"Result"] && [[loginResult objectForKey:@"Result"] isEqualToString:@"The password you have entered is incorrect."] && loginResult != nil){
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"This Is Awkward" message:@"That doesn't appear to be the correct password. Please try again or contact us for futher help." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
            [alert setTag:510];
            [alert show];
            [spinner stopAnimating];
        }
        else if([loginResult objectForKey:@"Result"] && [[loginResult objectForKey:@"Result"] isEqualToString:@"Suspended"] && loginResult != nil){
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Suspended" message:@"Your account has been temporarily suspended pending a review. We will contact you as soon as possible, and you can always contact us via email if this is a mistake or error." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
            [alert setTag:500];
            [alert show];
            [spinner stopAnimating];
        }
        else if([loginResult objectForKey:@"Result"] && [[loginResult objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] && loginResult != nil){
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"For security your account has been temporarily suspended.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com if you would like more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
            [alert show];
            [alert setTag:50];
            [spinner stopAnimating];
        }        
    }
    
    
    else if([tagName isEqualToString:@"getMemberId"]){
        NSError *error;
        
        NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setObject:[self.email.text lowercaseString] forKey:@"UserName"];
        user = [NSUserDefaults standardUserDefaults];
        if (![self.stay_logged_in isOn]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        }else{
            NSMutableDictionary *automatic = [[NSMutableDictionary alloc] init];
            [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"MemberId"];
            [automatic setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserName"] forKey:@"UserName"];
            [automatic writeToFile:[self autoLogin] atomically:YES];
        }
        me = [core new];
        [me birth];
        
        [[me usr] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [[me usr] setObject:[self.email.text lowercaseString] forKey:@"UserName"];
        
        serve *enc_user = [serve new];
        [enc_user setDelegate:self];
        [enc_user setTagName:@"username"];
        [enc_user getEncrypt:[self.email.text lowercaseString]];
    } 
    
    else if ([tagName isEqualToString:@"username"]) {
        
       // NSError *error;
        //NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        //nslog(@"test: %@",loginResult);
        serve *details = [serve new];
        [details setDelegate:self];
        [details setTagName:@"info"];
        [details getDetails:[user objectForKey:@"MemberId"]];
    }
    
    else if ([tagName isEqualToString:@"info"]) {
        
       // NSError *error;
       // NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        //nslog(@"User response: %@",loginResult);
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
        [UIView setAnimationDelay:0.375];
        [nav_ctrl popToRootViewControllerAnimated:NO];
        
        [UIView commitAnimations];
        return;
    }
    
#pragma mark LOGIN CHECK.
    
    
}
#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([self.email.text length] > 0 && [self.email.text  rangeOfString:@"@"].location != NSNotFound && [self.email.text  rangeOfString:@"."].location != NSNotFound
        && [self.password.text length] > 5) {
        [self.login setEnabled:YES];
    }else {
        [self.login setEnabled:NO];
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
