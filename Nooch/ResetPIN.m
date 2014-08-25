//
//  ResetPIN.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "ResetPIN.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import <AudioToolbox/AudioToolbox.h>
@interface ResetPIN ()<UITextFieldDelegate>
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@end

@implementation ResetPIN

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
    [self.navigationItem setTitle:@"Reset PIN"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    pinchangeProgress=1;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView*navBar=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    [navBar setBackgroundColor:[UIColor colorWithRed:82.0f/255.0f green:176.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
    [self.view addSubview:navBar];
    UIButton*back=[UIButton buttonWithType:UIButtonTypeCustom];
    [back setStyleClass:@"backbutton"];
    [back setTitle:@"Cancel" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [back setFrame:CGRectMake(0,5, 70, 30)];
    [navBar addSubview:back];
    UILabel*lbl=[[UILabel alloc]initWithFrame:CGRectMake(105, 20, 200, 30)];
    [lbl setText:@"Reset PIN"];
    [lbl setFont:[UIFont systemFontOfSize:22]];
    [lbl setTextColor:[UIColor whiteColor]];
    [navBar addSubview:lbl];
    
    // Do any additional setup after loading the view from its nib.
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];
    
    [self.navigationItem setTitle:@"Reset PIN "];
    title = [[UILabel alloc] initWithFrame:CGRectMake(10, 104, 300, 60)];
    [title setText:@"Please enter your old PIN."]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"Repin_instructiontext"];
    [self.view addSubview:title];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 245, 300, 30)];
    [self.prompt setText:@""];
    [self.prompt setTextAlignment:NSTextAlignmentCenter];
    [self.prompt setStyleId:@"pin_instructiontext_send"];
    [self.view addSubview:self.prompt];
    
    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(44,134,30,30)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(106,134,30,30)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(171,134,30,30)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(235,134,30,30)];
    
    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 15;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}
-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    int len = [textField.text length] + [string length];
    //    if ([self.pin.text isEqualToString:@""]) {
    //        len=1;
    //       // pinchangeProgress=0;
    //    }
    UIColor *which;
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
    }
    else{
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
    
    if (len==4 && pinchangeProgress==1) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:spinner];
        spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [spinner startAnimating];
        
        serve *pin = [serve new];
        pin.Delegate = self;
        pin.tagName = @"ValidatePinNumber";
        [pin getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
    }
    else if (len==4 && pinchangeProgress==2) {
        
        [self.fourth_num setBackgroundColor:which];
        if ([newPinString length] != 4) {
            pinchangeProgress=3;
            self.prompt.text=@"";
            newPinString = [NSString stringWithFormat:@"%@%@",textField.text,string];
            [title setText:@"Confirm your PIN"];
            [self.pin setText:@""];
            [self.first_num setBackgroundColor:[UIColor clearColor]];
            [self.second_num setBackgroundColor:[UIColor clearColor]];
            [self.third_num setBackgroundColor:[UIColor clearColor]];
            [self.fourth_num setBackgroundColor:[UIColor clearColor]];
            return NO;
        }
        
    }
    else if (len==4 && pinchangeProgress==3) {
        if (![newPinString isEqualToString:[NSString stringWithFormat:@"%@%@",textField.text,string]]) {
            [self.fourth_num setBackgroundColor:[UIColor clearColor]];
            [self.third_num setBackgroundColor:[UIColor clearColor]];
            [self.second_num setBackgroundColor:[UIColor clearColor]];
            [self.first_num setBackgroundColor:[UIColor clearColor]];
            self.pin.text=@"";
            newPinString=@"";
            self.prompt.text=@"Pin doesn't matched.";
            pinchangeProgress=2;
            title.text=@"Enter new Pin";
            return NO;
        }
        else
        {
            serve *req = [[serve alloc] init];
            req.Delegate = self;
            req.tagName=@"GetEncryptedData";
            [req getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
        }
        
    }
    return YES;
}
-(void)pinChanged:(NSString*)status
{
    if([status isEqualToString:@"Pin changed successfully."])
    {
        
        UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:nil message:@"Your PIN number has been changed successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        //  [showAlertMessage setTag:2];
        // [showAlertMessage setDelegate:self];
        [showAlertMessage show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    
    NSError* error;
    
    dictResult= [NSJSONSerialization
                 
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 
                 options:kNilOptions
                 
                 error:&error];
    
    NSLog(@"%@",dictResult);
    if ([tagName isEqualToString:@"GetEncryptedData"]) {
        newEncryptedPIN=[dictResult objectForKey:@"Status"];
        serve *resPin = [[serve alloc] init];
        resPin.Delegate = self;
        resPin.tagName = @"resetpin";
        [resPin resetPIN:encryptedPIN new:newEncryptedPIN];
    }
    else if ([tagName isEqualToString:@"resetpin"]) {
        
        // NSDictionary *loginResult = [result JSONValue];
        NSString *statusData= (NSString *)[dictResult objectForKey:@"Result"];
        NSLog(@"Status %@", statusData);
        [self pinChanged:statusData];
        
        
    }
    else if ([tagName isEqualToString:@"ValidatePinNumber"]) {
        encryptedPIN=[dictResult valueForKey:@"Status"];
        
        serve *checkValid = [serve new];
        checkValid.tagName = @"checkValid";
        checkValid.Delegate = self;
        [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
    }
    else if ([tagName isEqualToString:@"checkValid"]){
        if([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"]){
            [spinner stopAnimating];
            [spinner setHidden:YES];
            pinchangeProgress=2;
            [self.fourth_num setBackgroundColor:[UIColor clearColor]];
            [self.third_num setBackgroundColor:[UIColor clearColor]];
            [self.second_num setBackgroundColor:[UIColor clearColor]];
            [self.first_num setBackgroundColor:[UIColor clearColor]];
            self.pin.text=@"";
            self.prompt.text=@"";
            title.text=@"Enter New Pin";
        }
        
        
        else{
            
            [self.fourth_num setBackgroundColor:[UIColor clearColor]];
            [self.third_num setBackgroundColor:[UIColor clearColor]];
            [self.second_num setBackgroundColor:[UIColor clearColor]];
            [self.first_num setBackgroundColor:[UIColor clearColor]];
            self.pin.text=@"";
        }
        
        if([[dictResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            self.prompt.textColor = kNoochRed;
            self.fourth_num.layer.borderColor = kNoochRed.CGColor;
            self.third_num.layer.borderColor = kNoochRed.CGColor;
            self.second_num.layer.borderColor = kNoochRed.CGColor;
            self.first_num.layer.borderColor = kNoochRed.CGColor;
            [self.fourth_num setStyleClass:@"shakePin4"];
            [self.third_num setStyleClass:@"shakePin3"];
            [self.second_num setStyleClass:@"shakePin2"];
            [self.first_num setStyleClass:@"shakePin1"];
            self.prompt.text=@"1 failed attempt.";
            self.prompt.textColor = [UIColor colorWithRed:169 green:68 blue:66 alpha:1];
            [spinner stopAnimating];
            [spinner setHidden:YES];
        }else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]){
            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.fourth_num.layer.borderColor = kNoochRed.CGColor;
            self.third_num.layer.borderColor = kNoochRed.CGColor;
            self.second_num.layer.borderColor = kNoochRed.CGColor;
            self.first_num.layer.borderColor = kNoochRed.CGColor;
            [self.fourth_num setStyleClass:@"shakePin4"];
            [self.third_num setStyleClass:@"shakePin3"];
            [self.second_num setStyleClass:@"shakePin2"];
            [self.first_num setStyleClass:@"shakePin1"];
            self.prompt.text=@"2nd failed attempt.";
            UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"Your account will be suspended for 24 hours if you enter another incorrect PIN." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [suspendedAlert show];
            
        }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
            [av setTag:202320];
            
            [av show];
            [[assist shared]setSusPended:YES];
            self.fourth_num.layer.borderColor = kNoochRed.CGColor;
            self.third_num.layer.borderColor = kNoochRed.CGColor;
            self.second_num.layer.borderColor = kNoochRed.CGColor;
            self.first_num.layer.borderColor = kNoochRed.CGColor;
            [self.fourth_num setStyleClass:@"shakePin4"];
            [self.third_num setStyleClass:@"shakePin3"];
            [self.second_num setStyleClass:@"shakePin2"];
            [self.first_num setStyleClass:@"shakePin1"];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.prompt.text=@"Account suspended.";
        }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
            [av setTag:202320];
            [av show];
            [[assist shared]setSusPended:YES];

            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.prompt.text=@"Account suspended.";
        }
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==202320 && buttonIndex==0) {
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
    
    else if (alertView.tag == 202320 && buttonIndex == 1) {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [user setObject:@"YES" forKey:@"requiredImmediately"];
            // [[me usr] setObject:@"NO" forKey:@"requiredImmediately"];
        }else{
            [user setObject:@"YES" forKey:@"requiredImmediately"];
            //[[me usr] setObject:@"YES" forKey:@"requiredImmediately"];
        }
        NSLog(@"%@",[me usr]);
        //reqImm = NO;
        
        // [navCtrl popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
        //  [self dismissModalViewControllerAnimated:YES];
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
            
            [alert setTitle:@"Mail saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            
            [alert setTitle:@"Mail sent"];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
