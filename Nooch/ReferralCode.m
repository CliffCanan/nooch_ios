//
//  ReferralCode.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "ReferralCode.h"
#import "Home.h"
#import "Welcome.h"
#import "GetLocation.h"
@interface ReferralCode ()<GetLocationDelegate>
{
    GetLocation*getLocation;
}
@property(nonatomic,strong) NSMutableDictionary *user;
@property(nonatomic,strong) UITextField *code_field;
@end

@implementation ReferralCode

- (id)initWithData:(NSDictionary *)usr
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.user = [usr mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    getLocation = [[GetLocation alloc] init];
	getLocation.delegate = self;
	[getLocation.locationManager startUpdatingLocation];
    
	// Do any additional setup after loading the view.
    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    [title setTextColor:kNoochGrayDark]; [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Enter Referral Code"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, 280, 70)];
    [prompt setTextColor:kNoochGrayDark]; [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setNumberOfLines:3];
    [prompt setFont:[UIFont systemFontOfSize:14]];
    [prompt setText:@"Nooch is currently invite only. If you have a referral code enter it below to sign up."]; [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setStyleClass:@"instruction_text"];
    [self.view addSubview:prompt];
    
    UIButton *enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setBackgroundColor:kNoochGreen];
    [enter setTitle:@"Continue" forState:UIControlStateNormal];
    [enter addTarget:self action:@selector(enter_code) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 350, 300, 60)];
    [enter setStyleClass:@"button_green"];
    [self.view addSubview:enter];
    
    UIButton *request = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [request setFrame:CGRectMake(10, 420, 300, 60)];
    [request setBackgroundColor:kNoochGrayLight];
    [request setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [request setTitle:@"Don't Have a Code" forState:UIControlStateNormal];
    [request addTarget:self action:@selector(request_code) forControlEvents:UIControlEventTouchUpInside];
    [request setStyleClass:@"button_gray"];
    [self.view addSubview:request];
    
    self.code_field = [[UITextField alloc] initWithFrame:CGRectMake(55, 250, 210, 60)];
    [self.code_field setBackgroundColor:[UIColor whiteColor]]; [self.code_field setTextColor:kNoochGrayLight];
    [self.code_field setKeyboardType:UIKeyboardTypeAlphabet]; [self.code_field setDelegate:self];
    [self.code_field setTextAlignment:NSTextAlignmentCenter]; [self.code_field setPlaceholder:@"ENTER CODE"];
    self.code_field.layer.borderWidth = 1; self.code_field.layer.borderColor = kNoochGrayLight.CGColor;
    self.code_field.layer.cornerRadius = 2;
    [self.code_field setAutocorrectionType:UITextAutocorrectionTypeNo]; [self.code_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.code_field.layer.borderColor = kNoochBlue.CGColor;
    self.code_field.layer.cornerRadius = 15;
    [self.view addSubview:self.code_field];
}
#pragma mark-Location Tracker Delegates

- (void)locationUpdate:(CLLocation *)location{
    
    lat=location.coordinate.latitude;
    lon=location.coordinate.longitude;
    [getLocation.locationManager stopUpdatingLocation];;
}
-(void)locationError:(NSError *)error{
    
}
- (void)enter_code
{
    if ([self.code_field.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Referral Code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSString*get4chr=[self.code_field.text substringToIndex:3];
    if ([[get4chr uppercaseStringWithLocale:[NSLocale currentLocale]]isEqualToString:get4chr]) {
        //ServiceType=@"invitecheck";
        serve *inv_code = [serve new];
        [inv_code setDelegate:self];
        [inv_code setTagName:@"inv_check"];
        [inv_code validateInviteCode:self.code_field.text];
    }
    else
    {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Check Your Referral Code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }

    
    ///delete when server communication is done
    //Welcome *welc = [Welcome new];
    //[self.navigationController pushViewController:welc animated:YES];
    ///end delete
    
   
}

- (void)request_code
{
    
}

- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
     NSError *error;
    if ([tagName isEqualToString:@"inv_check"]) {
       
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([[response objectForKey:@"validateInvitationCodeResult"] boolValue]) {
            
            serve * serveOBJ=[serve new];
            [serveOBJ setDelegate:self];
            serveOBJ.tagName=@"validate";
            [serveOBJ getTotalReferralCode:self.code_field.text];
            
           
        } else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Code" message:@"The referall code you entered is invalid. Please try again or request a code if you do not have one." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    if ([tagName isEqualToString:@"validate"]) {
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([[[response valueForKey:@"getTotalReferralCodeResult"] valueForKey:@"Result"] isEqualToString:@"True"]) {
           
            serve *create = [serve new];
            [create setDelegate:self];
            [create setTagName:@"encrypt"];
            [create getEncrypt:[self.user objectForKey:@"password"]];
           // Signup*pNooch=[self.storyboard instantiateViewControllerWithIdentifier:@"signup"];
            //[self.navigationController pushViewController:pNooch animated:YES];
            
        }
        else
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Sorry! Referral Code Expired" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
     else if ([tagName isEqualToString:@"encrypt"])
     {
         serve *create = [serve new];
         [create setDelegate:self];
         [create setTagName:@"create_account"];
         NSError *error;
         NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
         [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"email"] forKey:@"email"];
         [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"first_name"] forKey:@"first_name"];
         [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"last_name"] forKey:@"last_name"];
         [[NSUserDefaults standardUserDefaults] setObject:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] forKey:@"password"];
         if ([self.user objectForKey:@"facebook_id"]) [[NSUserDefaults standardUserDefaults] setObject:[self.user objectForKey:@"facebook_id"] forKey:@"facebook_id"];
         if (![[loginResult objectForKey:@"Status"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"Status"]!=NULL) {
               getEncryptedPassword=[loginResult objectForKey:@"Status"];
         }
       
         [create newUser:[self.user objectForKey:@"email"] first:[self.user objectForKey:@"first_name" ] last:[self.user objectForKey:@"last_name"] password:[[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]] pin:[self.user objectForKey:@"pin_number"] invCode:self.code_field.text fbId:[self.user objectForKey:@"facebook_id"] ? [self.user objectForKey:@"facebook_id"] : @"" ];
         self.code_field.text=@"";
     }
    else if ([tagName isEqualToString:@"create_account"])
    {
        NSLog(@"login result %@",result);
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if([[[response objectForKey:@"MemberRegistrationResult"]objectForKey:@"Result"] isEqualToString:@"Thanks for registering! Check your email to complete activation."])
        {
            
            //[decline setTag:1];
            [[NSUserDefaults standardUserDefaults] setObject:@"asdfa" forKey:@"setPrompt"];
            //[spinner stopAnimating];
            serve *login = [serve new];
            login.Delegate = self;
            login.tagName = @"login";
            
           // [login login:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] password:getEncryptedPassword remember:YES lat:lat lon:lon];
             NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [login login:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] password:getEncryptedPassword remember:YES lat:lat lon:lon uid:udid];
        }
        else if([[[response objectForKey:@"MemberRegistrationResult"] objectForKey:@"Result"] isEqualToString:@"You are already a nooch member."])
        {
            UIAlertView *decline= [[UIAlertView alloc] initWithTitle:@"Well..." message:@"This address already exists in our system, we do not support cloning you."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [decline show];
            [decline setTag:1];
           // [spinner stopAnimating];
            return;
        }
            //keyboard.userInteractionEnabled = NO;
            //leftNavButton.userInteractionEnabled = NO;
            
       
    }
    else if ([tagName isEqualToString:@"login"]) {
        serve *req = [[serve alloc] init];
        req.Delegate = self;
        req.tagName = @"getMemId";
      // NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]);
       // NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]);

        [req getMemIdFromuUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
       
    }
    if ([tagName isEqualToString:@"getMemId"]) {
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",response);
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"Result"] forKey:@"MemberId"];
      //  [spinner stopAnimating];
        me = [core new];
        [me birth];
        [[me usr] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"] forKey:@"firstName"];
        [[me usr] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"] forKey:@"lastName"];
        [[me usr] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
        [[me usr] setObject:@"0.00" forKey:@"Balance"];
        //tempImg = UIImagePNGRepresentation(selectedPic);
        [me stamp];
       // [navCtrl popToRootViewControllerAnimated:NO];
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self dismissModalViewControllerAnimated:YES];
        Welcome *welc = [Welcome new];
        [self.navigationController pushViewController:welc animated:YES];
        UIAlertView *decline= [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Thanks for joining us here at Nooch!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [decline show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [[me usr] setObject:@"NO" forKey:@"requiredImmediately"];
        }else{
            [[me usr] setObject:@"YES" forKey:@"requiredImmediately"];
        }
       // reqImm = NO;
        
      //  [navCtrl popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
        //  [self dismissModalViewControllerAnimated:YES];
    }else if(alertView.tag == 2){
        [self dismissViewControllerAnimated:YES completion:nil];
        //[self dismissModalViewControllerAnimated:YES];
    }
    else if (alertView.tag==2022)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
        
        //sendingMoney = NO;
        
        //[navCtrl dismissViewControllerAnimated:YES completion:nil];
        
        // [navCtrl dismissModalViewControllerAnimated:NO];
        
        //[navCtrl performSelector:@selector(disable)];
        
       // [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"tutorial"] animated:YES];
        
        me = [core new];
        
    }
}
#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    
}
#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //int len = [textField.text length] + [string length];
    if([string length] == 0) //deleting
    {
        
    }else{
        
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