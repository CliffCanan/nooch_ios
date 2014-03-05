//
//  ReEnterPin.m
//  Nooch
//
//  Created by Vicky Mathneja on 08/01/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "ReEnterPin.h"
#import <Pixate/Pixate.h>
#import "Register.h"
#import "assist.h"
#import "ECSlidingViewController.h"
@interface ReEnterPin ()<UITextFieldDelegate>
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@property(nonatomic,strong)NSString*pinNumber;
@end

@implementation ReEnterPin

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
    // [nav_ctrl setNavigationBarHidden:NO];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //    UIView*navBar=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    //    [navBar setBackgroundColor:[UIColor colorWithRed:82.0f/255.0f green:176.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
    //    [self.view addSubview:navBar];
    //    UILabel*lbl=[[UILabel alloc]initWithFrame:CGRectMake(75, 20, 200, 30)];
    //    [lbl setText:@"PIN Confirmation"];
    //    [lbl setFont:[UIFont systemFontOfSize:22]];
    //    [lbl setTextColor:[UIColor whiteColor]];
    //    [navBar addSubview:lbl];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    [title setText:@"Enter your PIN"];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 280, 50)];
    [self.prompt setNumberOfLines:2];
    [self.prompt setText:@"Require Immediately is enabled, please enter your PIN to continue."];
    [self.prompt setStyleClass:@"instruction_text"];
    [self.view addSubview:self.prompt];
    
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];
    
    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(85,240,30,30)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(125,240,30,30)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(165,240,30,30)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(205,240,30,30)];
    
    //self.first_num.alpha = self.second_num.alpha = self.third_num.alpha = self.fourth_num.alpha = 0.5;
    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 16;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int len = [textField.text length] + [string length];
    if([string length] == 0) //deleting
    {
        switch (len) {
            case 4:
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 3:
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 2:
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 1:
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 0:
                break;
            default:
                break;
        }
    }else{
        UIColor *which;
        
        which = kNoochGreen;
        switch (len) {
            case 5:
                return NO;
                break;
            case 4:
                [self.fourth_num setBackgroundColor:which];
                //start pin validation
                break;
            case 3:
                [self.third_num setBackgroundColor:which];
                break;
            case 2:
                [self.second_num setBackgroundColor:which];
                break;
            case 1:
                [self.first_num setBackgroundColor:which];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    
    if (len==4) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:spinner];
        spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [spinner startAnimating];
        self.pinNumber=[NSString stringWithFormat:@"%@%@",textField.text,string];
        serve *pin = [serve new];
        pin.Delegate = self;
        pin.tagName = @"infopin";
        //[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]]
        [pin getDetails:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]];
        
    }
    return YES;
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    
    NSError* error;
    
    dictResult= [NSJSONSerialization
                 
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 
                 options:kNilOptions
                 
                 error:&error];
    
    NSLog(@"%@",dictResult);
    if ([tagName isEqualToString:@"infopin"]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"pincheck"];
        if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
            
            UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil                , nil];
            
            [Alert show];
            
            
            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
            
            NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
            [timer invalidate];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [nav_ctrl performSelector:@selector(disable)];
                Register *reg = [Register new];
                [nav_ctrl pushViewController:reg animated:YES];
                me = [core new];
            }];
            
        }
        
        else if ([[dictResult valueForKey:@"Status"]isEqualToString:@"Suspended"]) {
            [spinner stopAnimating];
            [spinner setHidden:YES];
            [self.fourth_num setBackgroundColor:[UIColor clearColor]];
            [self.third_num setBackgroundColor:[UIColor clearColor]];
            [self.second_num setBackgroundColor:[UIColor clearColor]];
            [self.first_num setBackgroundColor:[UIColor clearColor]];
            self.pin.text=@"";
            
            UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Nooch Money" message:@"You account has been suspended." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
            
            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
            
            NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
            [timer invalidate];
            // timer=nil;
            [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
            // [nav_ctrl performSelector:@selector(disable)];
            [nav_ctrl performSelector:@selector(reset)];
            Register *reg = [Register new];
            [nav_ctrl pushViewController:reg animated:YES];
            me = [core new];
            return;
            
        }
        else
        {
            serve *pin = [serve new];
            
            pin.Delegate = self;
            
            pin.tagName = @"ValidatePinNumber";
            
            [pin getEncrypt:[NSString stringWithFormat:@"%@",self.pinNumber]];
        }
    }
    else if ([tagName isEqualToString:@"ValidatePinNumber"]) {
        NSString *encryptedPIN=[dictResult valueForKey:@"Status"];
        
        serve *checkValid = [serve new];
        checkValid.tagName = @"checkValid";
        checkValid.Delegate = self;
        [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
    }
#pragma mark 9jan
    else if ([tagName isEqualToString:@"checkValid"]){
        if([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"]){
            NSLog(@"%@",user);
            if ([user objectForKey:@"requiredImmediately"] == NULL || [[user objectForKey:@"requiredImmediately"] isKindOfClass:[NSNull class]]) {
                [spinner stopAnimating];
                [spinner setHidden:YES];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"FYI" message:@"The Require Immediately function is an added security feature to prompt you for your PIN whenever you enter Nooch. Would you like to keep this on or turn it off? You can change this setting later in the PIN Settings page." delegate:self cancelButtonTitle:@"Turn Off" otherButtonTitles:@"Keep On", nil];
                [av setTag:1];
                [av show];
                return;
            }else{
                [spinner stopAnimating];
                [spinner setHidden:YES];
                NSLog(@"yuppppp");
                // reqImm = NO;
                [self dismissViewControllerAnimated:YES completion:nil];
                //[self dismissModalViewControllerAnimated:YES];
                return;
            }
        }
        
        else{
            
            [self.fourth_num setBackgroundColor:[UIColor clearColor]];
            [self.third_num setBackgroundColor:[UIColor clearColor]];
            [self.second_num setBackgroundColor:[UIColor clearColor]];
            [self.first_num setBackgroundColor:[UIColor clearColor]];
            self.pin.text=@"";
        }
        
        if([[dictResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]){
            self.prompt.text=@"1 failed attempt. Please try again.";
            self.prompt.textColor = [UIColor colorWithRed:169.0/255.0 green:68/255.0 blue:66/255.0 alpha:1];
            [spinner stopAnimating];
            [spinner setHidden:YES];
        }else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]){
            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.prompt.text=@"2 Failed Attempts";
            UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"Your account will be suspended for 24 hours if you enter another incorrect PIN." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [suspendedAlert show];
            
        }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av setTag:202320];
            [av show];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            [[assist shared]setSusPended:YES];

            self.prompt.text=@"Account suspended.";
            
        }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

            [av setTag:202320];
            [av show];
            [[assist shared]setSusPended:YES];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.prompt.text=@"Account suspended.";
            
        }
    }
}
#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==202320 && buttonIndex==0) {
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            serve*serveOBJ=[serve new];
            [serveOBJ setTagName:@"requiredImmediately"];
            [serveOBJ setDelegate:self];
            [serveOBJ SaveImmediateRequire:NO];
            [user setObject:@"NO" forKey:@"requiredImmediately"];
        }else{
            serve*serveOBJ=[serve new];
            [serveOBJ setTagName:@"requiredImmediately"];
            [serveOBJ setDelegate:self];
            [serveOBJ SaveImmediateRequire:YES];
            [user setObject:@"YES" forKey:@"requiredImmediately"];
        }
        NSLog(@"%@",user);
        //reqImm = NO;
        
        // [navCtrl popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
        //  [self dismissModalViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
