//
//  ResetPIN.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.screenName = @"Reset Pin Screen";
    self.artisanNameTag = @"Reset PIN Screen";

    pinchangeProgress = 1;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView * backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .3;
    [self.view addSubview:backgroundImage];

    UIView * navBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    [navBar setBackgroundColor:[UIColor colorWithRed:63.0f/255.0f green:171.0f/255.0f blue:225.0f/255.0f alpha:1.0f]];
    [self.view addSubview:navBar];

    UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setStyleClass:@"backbutton_pinreset"];
    [back setTitle:NSLocalizedString(@"ResetPIN_cancelTxt", @"Reset PIN cancel btn text") forState:UIControlStateNormal];
    [back setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    back.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:back];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);

    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
    UILabel * lbl = [[UILabel alloc]initWithFrame:CGRectMake(105, 20, 200, 30)];
    lbl.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ResetPIN_scrnTitle", @"Reset PIN screen Scrn Title") attributes:textAttributes];
    [lbl setFont:[UIFont systemFontOfSize:22]];
    [lbl setTextColor:[UIColor whiteColor]];
    [navBar addSubview:lbl];

    self.pin = [UITextField new];
    [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    self.pin.inputAccessoryView = [[UIView alloc] init];
    [self.pin setDelegate:self];
    [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin];
    [self.pin becomeFirstResponder];

    title = [[UILabel alloc] initWithFrame:CGRectMake(10, 104, 300, 60)];
    [title setText:NSLocalizedString(@"ResetPIN_instruct", @"Reset PIN instructions")]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"Repin_instructiontext"];
    [self.view addSubview:title];

    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 245, 300, 30)];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [self.prompt setFrame:CGRectMake(10, 192, 300, 30)];
    }
    [self.prompt setText:@""];
    [self.prompt setTextAlignment:NSTextAlignmentCenter];
    [self.prompt setStyleId:@"pin_instructiontext_send"];
    [self.view addSubview:self.prompt];

    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(44,134,30,30)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(106,134,30,30)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(171,134,30,30)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(235,134,30,30)];

    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 15;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor whiteColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}

-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    short len = [textField.text length] + [string length];
    self.prompt.text = @"";
    UIColor *which;
    if([string length] == 0) //deleting
    {
        switch (len) {
            case 4:
                [self.fourth_num setBackgroundColor:[UIColor whiteColor]];
                break;
            case 3:
                [self.third_num setBackgroundColor:[UIColor whiteColor]];
                break;
            case 2:
                [self.second_num setBackgroundColor:[UIColor whiteColor]];
                break;
            case 1:
                [self.first_num setBackgroundColor:[UIColor whiteColor]];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    else
    {
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
    
    if (len == 4 && pinchangeProgress == 1)
    {
        serve *pin = [serve new];
        pin.Delegate = self;
        pin.tagName = @"ValidatePinNumber";
        [pin getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
    }
    else if (len == 4 && pinchangeProgress == 2)
    {
        [self.fourth_num setBackgroundColor:which];
        if ([newPinString length] != 4)
        {
            pinchangeProgress = 3;
            self.prompt.text=@"";
            newPinString = [NSString stringWithFormat:@"%@%@",textField.text,string];

            [title setText:NSLocalizedString(@"ResetPIN_cnfrmPINtxt", @"Reset PIN 'Confirm your PIN' text")];
            [self.pin setText:@""];
            [self.first_num setBackgroundColor:[UIColor whiteColor]];
            [self.second_num setBackgroundColor:[UIColor whiteColor]];
            [self.third_num setBackgroundColor:[UIColor whiteColor]];
            [self.fourth_num setBackgroundColor:[UIColor whiteColor]];
            return NO;
        }
        
    }
    else if (len == 4 && pinchangeProgress == 3)
    {
        if (![newPinString isEqualToString:[NSString stringWithFormat:@"%@%@",textField.text,string]])
        {
            [self.fourth_num setBackgroundColor:[UIColor whiteColor]];
            [self.third_num setBackgroundColor:[UIColor whiteColor]];
            [self.second_num setBackgroundColor:[UIColor whiteColor]];
            [self.first_num setBackgroundColor:[UIColor whiteColor]];
            self.pin.text = @"";
            newPinString = @"";

            self.prompt.text = NSLocalizedString(@"ResetPIN_noMatchTxt", @"Reset PIN pins don't match text");
            self.prompt.textColor = kNoochRed;
            pinchangeProgress = 2;
            title.text = NSLocalizedString(@"ResetPIN_enterNewPin", @"Reset PIN 'Enter new PIN' text");
            return NO;
        }
        else
        {
            serve *req = [[serve alloc] init];
            req.Delegate = self;
            req.tagName = @"GetEncryptedData";
            [req getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
        }
    }
    return YES;
}

-(void)pinChanged:(NSString*)status
{
    if ([status isEqualToString:@"Pin changed successfully."])
    {
        UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPIN_updatedAlrtTitle", @"Reset PIN updated successfully Alert Title")
                                                                   message:NSLocalizedString(@"ResetPIN_updatedAlrtBody", @"Reset PIN updated successfully Alert Body Text")
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
        [showAlertMessage show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)Error:(NSError *)Error
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Trouble"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    
    dictResult= [NSJSONSerialization
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                 error:&error];
    
    NSLog(@"Reset PIN result is: %@",dictResult);
    if ([tagName isEqualToString:@"GetEncryptedData"])
    {
        newEncryptedPIN=[dictResult objectForKey:@"Status"];
        serve *resPin = [[serve alloc] init];
        resPin.Delegate = self;
        resPin.tagName = @"resetpin";
        [resPin resetPIN:encryptedPIN new:newEncryptedPIN];
    }
    else if ([tagName isEqualToString:@"resetpin"])
    {
        NSString *statusData = (NSString *)[dictResult objectForKey:@"Result"];
        NSLog(@"Reset PIN Status: %@", statusData);
        [self pinChanged:statusData];
    }
    else if ([tagName isEqualToString:@"ValidatePinNumber"])
    {
        encryptedPIN = [dictResult valueForKey:@"Status"];
        serve *checkValid = [serve new];
        checkValid.tagName = @"checkValid";
        checkValid.Delegate = self;
        [checkValid pinCheck:[user stringForKey:@"MemberId"] pin:encryptedPIN];
    }
    else if ([tagName isEqualToString:@"checkValid"])
    {
        if ([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"])
        {
            pinchangeProgress=2;
            [self.fourth_num setBackgroundColor:[UIColor whiteColor]];
            [self.third_num setBackgroundColor:[UIColor whiteColor]];
            [self.second_num setBackgroundColor:[UIColor whiteColor]];
            [self.first_num setBackgroundColor:[UIColor whiteColor]];
            self.pin.text = @"";
            self.prompt.text = @"";

            title.text = NSLocalizedString(@"ResetPIN_enterNewPin", @"Reset PIN 'Enter new PIN' text");
        }
        else
        {
            [self.fourth_num setBackgroundColor:[UIColor whiteColor]];
            [self.third_num setBackgroundColor:[UIColor whiteColor]];
            [self.second_num setBackgroundColor:[UIColor whiteColor]];
            [self.first_num setBackgroundColor:[UIColor whiteColor]];
            self.pin.text = @"";
        }
        
        if([[dictResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
        {
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

            self.prompt.text = NSLocalizedString(@"ResetPIN_1stFailed", @"Reset PIN '1st Failed Attempt' text");
            self.prompt.textColor = kNoochRed;
        }
        else if ([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
        {
            self.fourth_num.layer.borderColor = kNoochRed.CGColor;
            self.third_num.layer.borderColor = kNoochRed.CGColor;
            self.second_num.layer.borderColor = kNoochRed.CGColor;
            self.first_num.layer.borderColor = kNoochRed.CGColor;
            [self.fourth_num setStyleClass:@"shakePin4"];
            [self.third_num setStyleClass:@"shakePin3"];
            [self.second_num setStyleClass:@"shakePin2"];
            [self.first_num setStyleClass:@"shakePin1"];

            self.prompt.text = NSLocalizedString(@"ResetPIN_2ndFailed", @"Reset PIN '2nd Failed Attempt' text");
            self.prompt.textColor = kNoochRed;
            
            UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ResetPIN_TryAgainAlrtTitle", @"Reset PIN Failed Alert Title")
                                                                  message:NSLocalizedString(@"ResetPIN_TryAgainAlrtBody", @"Reset PIN Failed Alert Body Text")
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
            [suspendedAlert show];
        }
        else if ([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."] || [[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])
        {
            [self accountSuspAlert];
        }
    }
}

-(void)accountSuspAlert
{
    [[assist shared]setSusPended:YES];

    self.prompt.text = NSLocalizedString(@"ResetPIN_AcntSuspLbl", @"Reset PIN account suspended text");

    self.fourth_num.layer.borderColor = kNoochRed.CGColor;
    self.third_num.layer.borderColor = kNoochRed.CGColor;
    self.second_num.layer.borderColor = kNoochRed.CGColor;
    self.first_num.layer.borderColor = kNoochRed.CGColor;
    [self.fourth_num setStyleClass:@"shakePin4"];
    [self.third_num setStyleClass:@"shakePin3"];
    [self.second_num setStyleClass:@"shakePin2"];
    [self.first_num setStyleClass:@"shakePin1"];

    UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPIN_SuspAlrtTitle", @"Reset PIN Failed account suspended Alert Title")
                                                 message:NSLocalizedString(@"ResetPIN_SuspAlrtBody", @"Reset PIN Failed account suspended Alert Body Text")
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:NSLocalizedString(@"ResetPIN_SuspAlrtBtn", @"Reset PIN Failed account suspended Alert 'Contact Support' Btn"),nil];
    [av setTag:202];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 202 && buttonIndex==0)
    {
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag == 202 && buttonIndex == 1)
    {
        if (![MFMailComposeViewController canSendMail])
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                          message:@"You don't have an email account configured for this device."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
            [av show];
            return;
        }

        NSString * memberId = [user valueForKey:@"MemberId"];
        NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
        NSString * userStatus = [user objectForKey:@"Status"];
        NSString * userEmail = [user objectForKey:@"UserName"];
        NSString * IsVerifiedPhone = [[user objectForKey:@"IsVerifiedPhone"] lowercaseString];
        NSString * iOSversion = [[UIDevice currentDevice] systemVersion];
        NSString * msgBody = [NSString stringWithFormat:@"<!doctype html> <html><body><br><br><br><br><br><br><small>• MemberID: %@<br>• Name: %@<br>• Status: %@<br>• Email: %@<br>• Is Phone Verified: %@<br>• iOS Version: %@<br></small></body></html>",memberId, fullName, userStatus, userEmail, IsVerifiedPhone, iOSversion];

        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [mailComposer setMessageBody:msgBody isHTML:YES];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else if (alertView.tag == 1)
    {
        if (buttonIndex == 0) {
            [user setObject:@"YES" forKey:@"requiredImmediately"];
        }
        else {
            [user setObject:@"YES" forKey:@"requiredImmediately"];
        }

        [self dismissViewControllerAnimated:YES completion:nil];
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
            [alert setTitle:@"\xF0\x9F\x93\xA4  Email Sent Successfully"];
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