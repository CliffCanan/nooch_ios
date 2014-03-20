//
//  ResetPassword.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

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
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Reset Password"];
    
    [self.view setStyleClass:@"background_gray"];
    
    UITableView *menu = [UITableView new];
    [menu setStyleId:@"settings"];
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
    [self.save setFrame:CGRectMake(0, 200, 0, 0)];
    [self.save setStyleClass:@"button_green"];
    [self.save setTitle:@"Change Password" forState:UIControlStateNormal];
    [self.save addTarget:self action:@selector(finishResetPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.save setEnabled:YES];
    [self.view addSubview:self.save];
    
    [self.old becomeFirstResponder];
}
- (IBAction)finishResetPassword:(id)sender {
    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    NSLog(@"sahi%@",self.old.text);
    NSLog(@"new%@",self.pass);
    
    if ([self.old.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Enter Old Password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.old becomeFirstResponder];
        
        return;
    }
    if ([self.pass.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Enter New Password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.pass becomeFirstResponder];
        
        return;
    }
    if ([self.confirm.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Enter Confirm Password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.confirm becomeFirstResponder];
        
        return;
    }
    
    if (![[[assist shared]getPass] isEqualToString:self.old.text]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Password incorrect!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if([self.pass.text isEqualToString:self.confirm.text]){
        if([self.pass.text length] < 8){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain minimum of 8 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }else if([self.pass.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain atleast one numeric character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if([self.pass.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain atleast one character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }else{
            passwordReset = self.pass.text;
            
            [self resetPassword:self.pass.text];
        }
    }else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Passwords do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        passwordReset = @"";
    }
}
-(void) resetPassword:(NSString *)newPassword{
    
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
    if(value ==3)
    {
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
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"New Password";
        [cell.contentView addSubview:self.pass];
    }else if(indexPath.row == 2){
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
    }else if(indexPath.row == 2){
        [self.confirm becomeFirstResponder];
    }
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if([tagName isEqualToString:@"resetPasswordDetails"]){
        BOOL isResult = [result boolValue];
        if(isResult == 0)
        {
            isPasswordChanged=YES;
            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:nil message:@"Your password has been changed successfully" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
            [[assist shared]setPassValue:passwordReset];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else
        {
            isPasswordChanged=NO;
            newchangedPass=@"";
            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:nil message:@"Incorrect password. Please check your current password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
