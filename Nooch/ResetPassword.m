//  ResetPassword.m
//  Nooch
//
//  Copyright (c) 2014 Nooch Inc. All rights reserved.

#import "ResetPassword.h"
#import "Home.h"
#import "SpinKit/RTSpinKitView.h"
#import "Decryption.h"
@interface ResetPassword ()<DecryptionDelegate>
@property (nonatomic,strong) UITextField *old;
@property (nonatomic,strong) UITextField *pass;
@property (nonatomic,strong) UITextField *confirm;
@property (nonatomic,strong) UIButton *changepwbtn;
@property (nonatomic,strong) UIButton *helpGlyph;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation ResetPassword

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Reset Password Screen";
    
    UIView * navBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    [navBar setBackgroundColor:[UIColor colorWithRed:63.0f/255.0f green:171.0f/255.0f blue:225.0f/255.0f alpha:1.0f]];
    [self.view addSubview:navBar];
    
    UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setStyleClass:@"backbutton"];
    [back setTitle:@"Cancel" forState:UIControlStateNormal];
    [back setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    back.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    //[back setFrame:CGRectMake(0,5, 70, 30)];
    [navBar addSubview:back];
    
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(105, 24, 200, 30)];
    lbl.attributedText = [[NSAttributedString alloc] initWithString:@"Reset Password"
                                                         attributes:textAttributes];
    [lbl setFont:[UIFont systemFontOfSize:22]];
    [lbl setTextColor:[UIColor whiteColor]];
    [navBar addSubview:lbl];
    
    UITableView *menu = [UITableView new];
    [menu setStyleId:@"settings_resetpw"];
    menu.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    menu.layer.borderWidth = 1;
    [menu setDelegate:self];
    [menu setDataSource:self];
    [menu setScrollEnabled:NO];
    [self.view addSubview:menu];
    [menu reloadData];
    
    self.old = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
    [self.old setStyleClass:@"resetpw_right_label"];
    [self.old setDelegate:self];
    [self.old setPlaceholder:@"Enter Password"];
    [self.old setSecureTextEntry:YES];
    self.old.returnKeyType = UIReturnKeyNext;
    [self.old becomeFirstResponder];
    
    self.pass = [[UITextField alloc] initWithFrame:self.old.frame];
    [self.pass setStyleClass:@"resetpw_right_label"];
    [self.pass setDelegate:self];
    [self.pass setPlaceholder:@"New Password"];
    [self.pass setSecureTextEntry:YES];
    self.pass.returnKeyType = UIReturnKeyNext;
    
    self.confirm = [[UITextField alloc] initWithFrame:self.old.frame];
    [self.confirm setStyleClass:@"resetpw_right_label"];
    [self.confirm setDelegate:self];
    [self.confirm setPlaceholder:@"Confirm Password"];
    [self.confirm setSecureTextEntry:YES];
    self.confirm.returnKeyType = UIReturnKeyDone;
    
    self.changepwbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.changepwbtn setFrame:CGRectMake(0, 270, 0, 0)];
    [self.changepwbtn setStyleClass:@"button_green"];
    [self.changepwbtn setTitle:@"Change Password" forState:UIControlStateNormal];
    [self.changepwbtn setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    self.changepwbtn.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.changepwbtn addTarget:self action:@selector(finishResetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.changepwbtn setEnabled:NO];
    [self.view addSubview:self.changepwbtn];
    
    UIButton *forgot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [forgot setBackgroundColor:[UIColor clearColor]];
    [forgot setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [forgot setFrame:CGRectMake(20, 240, 280, 22)];
    [forgot.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
    [forgot setTitleColor:kNoochGrayLight forState:UIControlStateNormal];
    [forgot addTarget:self action:@selector(forgot_pass) forControlEvents:UIControlEventTouchUpInside];
    [forgot setStyleId:@"label_forgotpw"];
    [self.view addSubview:forgot];
    
    UIButton *helpGlyph = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [helpGlyph setStyleClass:@"navbar_rightside_icon"];
    [helpGlyph addTarget:self action:@selector(forgot_pass) forControlEvents:UIControlEventTouchUpInside];
    [helpGlyph setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question"] forState:UIControlStateNormal];
    UIBarButtonItem *help = [[UIBarButtonItem alloc] initWithCustomView:helpGlyph];
    [self.navigationItem setRightBarButtonItem:help];

}

-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    serve * serveOBJ = [serve new];
    serveOBJ.tagName = @"myset";
    [serveOBJ setDelegate:self];
    [serveOBJ getSettings];

    
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Reset Password"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .25;
    [self.view addSubview:backgroundImage];
}

- (IBAction)finishResetPassword:(id)sender
{
    NSCharacterSet * digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet * lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    
    if ([self.old.text length] == 0)
    {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Wait a Sec..." message:@"Please enter your current password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.old becomeFirstResponder];
        return;
    }

    if ([self.pass.text length] == 0)
    {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Need New Password" message:@"Please enter the shiniest new password you can think of!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.pass becomeFirstResponder];
        return;
    }

    if ([self.confirm.text length] == 0)
    {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Double Check" message:@"Please enter the NEW password twice to confirm." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.confirm becomeFirstResponder];
        return;
    }

     if (![[[assist shared]getPass] isEqualToString:self.old.text])
    {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"This Is Awkward" message:@"That doesn't appear to be the correct password. Please try again or contact us for futher help." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    if ([self.pass.text isEqualToString:self.confirm.text])
    {
        if ([self.pass.text length] < 8)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Almost There" message:@"For sucurity reasons, et cetera... we ask that passwords contain at least 8 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if ([self.pass.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sooo Close" message:@"For sucurity reasons, et cetera, et cetera... we ask that passwords contain at LEAST 1 number. We know it's annoying, but just trying to look out for you. Keep it safe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if ([self.pass.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Gotta Give Something" message:@"For fairly self-evident reasons, your password must have more than 0 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else {
            passwordReset = self.pass.text;
            
            [self resetPassword:self.pass.text];
        }
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Double Check" message:@"Please make sure the new passwords match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        passwordReset = @"";
    }
}

-(void) resetPassword:(NSString *)newPassword
{
    if([newPassword length] != 0)
    {
        newchangedPass = newPassword;
        GetEncryptionValue * encryPassword = [[GetEncryptionValue alloc] init];
        [encryPassword getEncryptionData:newPassword];
        encryPassword.Delegate = self;
        encryPassword->tag = [NSNumber numberWithInteger:3];
    }
    // NSLog(@"ecrypting password");
}

-(void)setEncryptedPassword:(NSString *) encryptedPwd
{
    getEncryptedPasswordValue = [[NSString alloc] initWithString:encryptedPwd];
}

-(void)encryptionDidFinish:(NSString *) encryptedData TValue:(NSNumber *) tagValue
{
    NSInteger value = [tagValue integerValue];
    if (value == 3)
    {
        getEncryptionNewPassword=encryptedData;
        [self resetNewPassword:(NSString *)getEncryptionNewPassword];
    }
}

-(void) resetNewPassword:(NSString *)encryptedNewPassword
{
    /* [self.view addSubview:[me waitStat:@"Attempting password reset..."]];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.delegate = self;
    self.hud.labelText = @"Attempting Password Reset...";
    [self.hud show:YES];*/
    
    serve * respass = [[serve alloc] init];
    respass.Delegate = self;
    respass.tagName = @"resetPasswordDetails";
    [respass resetPassword:getEncryptionOldPassword new:getEncryptionNewPassword];
}

- (void) forgot_pass
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Enter your email and we will send you a reset link." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]];
    [alert setTag:220011];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 220011 && buttonIndex == 1)
    {
        UITextField *emailField = [actionSheet textFieldAtIndex:0];
        
        if ([emailField.text length] > 0 && [emailField.text  rangeOfString:@"@"].location != NSNotFound && [emailField.text  rangeOfString:@"."].location != NSNotFound)
        {
            /* RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
            spinner1.color = [UIColor whiteColor];
            self.hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.navigationController.view addSubview:self.hud];
            
            self.hud.mode = MBProgressHUDModeCustomView;
            self.hud.customView = spinner1;
            self.hud.delegate = self;
            self.hud.labelText = @"One sec...";
            [self.hud show:YES];*/

            serve * forgetful = [serve new];
            forgetful.Delegate = self;
            forgetful.tagName = @"ForgotPass";
            [forgetful forgotPass:emailField.text];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle=UIAlertViewStylePlainTextInput;
            [alert setTag:220011];
            [alert show];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.indentationLevel = 1;
    [cell.textLabel setStyleClass:@"settings_resetpass_labels"];
    [cell.textLabel setStyleClass:@"resetpw_left_label"];
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"Current Password";
        [cell.contentView addSubview:self.old];
    }
    else if(indexPath.row == 1){
        cell.textLabel.text = @"New Password";
        [cell.contentView addSubview:self.pass];
    }
    else if(indexPath.row == 2){
        cell.textLabel.text = @"Confirm Password" ;
        [cell.contentView addSubview:self.confirm];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.old becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        [self.pass becomeFirstResponder];
    }
    else if(indexPath.row == 2){
        [self.confirm becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _old)
    {
        [_pass becomeFirstResponder];
    }
    else if (textField == _pass)
    {
        [_confirm becomeFirstResponder];
    }
    else if (textField == _confirm)
    {
        [_confirm resignFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.old.text length] > 4 && [self.pass.text length] > 4 && [self.confirm.text length] > 5)
    {
        [self.changepwbtn setEnabled:YES];
    }
    else {
        [self.changepwbtn setEnabled:NO];
    }
    return YES;
}

-(void)Error:(NSError *)Error
{
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
     NSError* error;
      [self.hud hide:YES];
     if ([tagName isEqualToString:@"myset"])
    {
        NSDictionary* dictProfileinfo = [NSJSONSerialization
                           JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                           options:kNilOptions
                           error:&error];
      if (![[dictProfileinfo valueForKey:@"Password"] isKindOfClass:[NSNull class]])
        {
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Password"]];
        }
    }
    else if ([tagName isEqualToString:@"ForgotPass"])
    {
        [self.hud hide:YES];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Please check your email for a reset password link." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }

    else if ([tagName isEqualToString:@"resetPasswordDetails"])
    {
        [self.hud hide:YES];
        NSLog(@"RESULT IS: %@",result);
        BOOL isResult = [result boolValue];
        if (isResult == 0)
        {
            isPasswordChanged = YES;
            UIAlertView * showAlertMessage = [[UIAlertView alloc] initWithTitle:@"Great Success" message:@"Your password has been changed successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
            [[assist shared]setPassValue:passwordReset];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            isPasswordChanged = NO;
            newchangedPass = @"";
            UIAlertView * showAlertMessage = [[UIAlertView alloc] initWithTitle:@"Incorrect Password" message:@"Please check your current password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
        }
    }
}
#pragma mark - password encryption

-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue
{
    [[assist shared]setPassValue:[sourceData objectForKey:@"Status"]];
    //NSLog(@"%@",[[assist shared] getPass]);

}
- (void)didReceiveMemoryWarning  {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end