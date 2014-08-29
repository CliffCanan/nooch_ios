//  ResetPassword.m
//  Nooch
//
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "ResetPassword.h"
#import "Home.h"

@interface ResetPassword ()
@property (nonatomic,strong) UITextField *old;
@property (nonatomic,strong) UITextField *pass;
@property (nonatomic,strong) UITextField *confirm;
@property (nonatomic,strong) UIButton *save;
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.trackedViewName = @"Reset Password Screen";
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Reset Password"];
    
    [self.view setStyleClass:@"background_gray"];
    
    UITableView *menu = [UITableView new];
    [menu setStyleId:@"settings_resetpw"];
    [menu setDelegate:self]; [menu setDataSource:self]; [menu setScrollEnabled:NO];
    [self.view addSubview:menu];
    [menu reloadData];

    self.old = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
    [self.old setStyleClass:@"resetpw_right_label"];
    [self.old setDelegate:self];
    [self.old setPlaceholder:@"Enter Password"];
    [self.old setSecureTextEntry:YES];

    self.pass = [[UITextField alloc] initWithFrame:self.old.frame];
    [self.pass setStyleClass:@"resetpw_right_label"];
    [self.pass setDelegate:self];
    [self.pass setPlaceholder:@"New Password"];
    [self.pass setSecureTextEntry:YES];

    self.confirm = [[UITextField alloc] initWithFrame:self.old.frame];
    [self.confirm setStyleClass:@"resetpw_right_label"];
    [self.confirm setDelegate:self];
    [self.confirm setPlaceholder:@"Confirm Password"];
    [self.confirm setSecureTextEntry:YES];

    self.save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.save setFrame:CGRectMake(0, 205, 0, 0)];
    [self.save setStyleClass:@"button_green"];
    [self.save setTitle:@"Change Password" forState:UIControlStateNormal];
    [self.save setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.3) forState:UIControlStateNormal];
    self.save.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [self.save addTarget:self action:@selector(finishResetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.save setEnabled:YES];
    [self.view addSubview:self.save];
    [self.old becomeFirstResponder];

    UIButton *forgot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [forgot setBackgroundColor:[UIColor clearColor]];
    [forgot setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [forgot setFrame:CGRectMake(20, 275, 280, 30)];
    [forgot.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
    [forgot setTitleColor:kNoochGrayLight forState:UIControlStateNormal];
    [forgot addTarget:self action:@selector(forgot_pass) forControlEvents:UIControlEventTouchUpInside];
    [forgot setStyleId:@"label_forgotpw"];
    [self.view addSubview:forgot];

}
- (IBAction)finishResetPassword:(id)sender {
    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    NSLog(@"sahi%@",self.old.text);
    NSLog(@"new%@",self.pass);
    
    if ([self.old.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Wait a Sec..." message:@"Please enter your current password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.old becomeFirstResponder];
        return;
    }
    if ([self.pass.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Need New Password" message:@"Please enter the shiniest new password you can think of!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.pass becomeFirstResponder];
        return;
    }
    if ([self.confirm.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Double Check" message:@"Please enter the NEW password twice to confirm." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.confirm becomeFirstResponder];
        return;
    }
    if (![[[assist shared]getPass] isEqualToString:self.old.text]) {
        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"This Is Awkward" message:@"That doesn't appear to be the correct password. Please try again or contact us for futher help." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if([self.pass.text isEqualToString:self.confirm.text]){
        if([self.pass.text length] < 8){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Almost There" message:@"For sucurity reasons, et cetera, et cetera... we ask that passwords contain at LEAST 8 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if([self.pass.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sooo Close" message:@"For sucurity reasons, et cetera, et cetera... we ask that passwords contain at LEAST 1 number. We know it's annoying, but just trying to look out for you. Keep it safe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if([self.pass.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Gotta Give Something" message:@"For fairly self-evident reasons, your password must have more than 0 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else{
            passwordReset = self.pass.text;
            
            [self resetPassword:self.pass.text];
        }
    }
    else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Double Check" message:@"Please make sure the new passwords match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        passwordReset = @"";
    }
}
-(void) resetPassword:(NSString *)newPassword {
    if([newPassword length]!=0){
        newchangedPass=newPassword;
        GetEncryptionValue *encryPassword = [[GetEncryptionValue alloc] init];
        [encryPassword getEncryptionData:newPassword];
        encryPassword.Delegate = self;
        encryPassword->tag = [NSNumber numberWithInteger:3];
    }
    NSLog(@"ecrypting password");
}
-(void)setEncryptedPassword:(NSString *) encryptedPwd{
    getEncryptedPasswordValue = [[NSString alloc] initWithString:encryptedPwd];
}
-(void)encryptionDidFinish:(NSString *) encryptedData TValue:(NSNumber *) tagValue{
    NSInteger value = [tagValue integerValue];
    //    [self setEncryptedPassword:encryptedData];
    if(value ==3) {
        getEncryptionNewPassword=encryptedData;
        [self resetNewPassword:(NSString *)getEncryptionNewPassword];
    }
    
}
-(void) resetNewPassword:(NSString *)encryptedNewPassword{
    [self.view addSubview:[me waitStat:@"Attempting password reset..."]];
    //  getEncryptionOldPassword=password.text;
    
    serve *respass = [[serve alloc] init];
    respass.Delegate = self;
    respass.tagName = @"resetPasswordDetails";
    [respass resetPassword:getEncryptionOldPassword new:getEncryptionNewPassword];
}

- (void) forgot_pass {
    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Enter your email and we will send you a reset link." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]];
    [alert setTag:220011];
    [alert show];
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag==220011&& buttonIndex==1){
        UITextField *emailField = [actionSheet textFieldAtIndex:0];
        if ([emailField.text length] > 0 && [emailField.text  rangeOfString:@"@"].location != NSNotFound && [emailField.text  rangeOfString:@"."].location != NSNotFound){
            serve *forgetful = [serve new];
            forgetful.Delegate = self;
            forgetful.tagName = @"ForgotPass";
            [forgetful forgotPass:emailField.text];
        }
        else
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"Enter Valid Email ID" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle=UIAlertViewStylePlainTextInput;
            [alert setTag:220011];
            [alert show];
        }
        
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
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
    if(indexPath.row == 0){
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName  {
    if([tagName isEqualToString:@"ForgotPass"]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Please check your email for a reset password link." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }

    else if([tagName isEqualToString:@"resetPasswordDetails"]){
        BOOL isResult = [result boolValue];
        if(isResult == 0) {
            isPasswordChanged=YES;
            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:@"Great Success" message:@"Your password has most assuredly been changed successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
            [[assist shared]setPassValue:passwordReset];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else {
            isPasswordChanged=NO;
            newchangedPass=@"";
            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:nil message:@"Incorrect password. Please check your current password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
        }
    }
}
- (void)didReceiveMemoryWarning  {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end