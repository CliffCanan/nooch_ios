//  ReEnterPin.m
//  Nooch
//
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "ReEnterPin.h"
#import "Register.h"
#import "assist.h"
#import "ECSlidingViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SpinKit/RTSpinKitView.h"

@interface ReEnterPin ()<UITextFieldDelegate>
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@property(nonatomic,strong) NSString*pinNumber;

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
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.screenName = @"ReEnter Pin Screen";

    UIImageView *logoicon = [UIImageView new];
    [logoicon setStyleId:@"requireImmediatelyLogo"];
    [self.view addSubview:logoicon];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 108, 300, 40)];
    [title setText:NSLocalizedString(@"ReEnterPIN_instruct", @"'Enter Your PIN' Instruction Text")];
    [title setStyleClass:@"header_signupflow"];
    [title setStyleClass:@"animate_pulse"];
    [self.view addSubview:title];

    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 132, 280, 50)];
    [self.prompt setNumberOfLines:1];
    [self.prompt setText:@""];
    [self.prompt setStyleClass:@"pin_entry_feedback"];

    self.pin = [UITextField new];
    [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    self.pin.inputAccessoryView = [[UIView alloc] init];
    [self.pin setDelegate:self];
    [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin];
    [self.pin becomeFirstResponder];

    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(44,180,30,30)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(106,180,30,30)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(171,180,30,30)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(235,180,30,30)];

    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 15;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;

    [self.first_num setStyleClass:@"animate_bubble_slow"];
    [self.second_num setStyleClass:@"animate_bubble_slow"];
    [self.third_num setStyleClass:@"animate_bubble_slow"];
    [self.fourth_num setStyleClass:@"animate_bubble_slow"];

    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    [self.prompt removeFromSuperview];
    short len = [textField.text length] + [string length];

    if ([string length] == 0) //deleting
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
    else
    {
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
    
    if (len == 4)
    {
        self.pinNumber = [NSString stringWithFormat:@"%@%@",textField.text,string];
        serve * pin = [serve new];
        pin.Delegate = self;
        pin.tagName = @"ValidatePinNumber";
        [pin getEncrypt:[NSString stringWithFormat:@"%@",self.pinNumber]];
        
    }
    return YES;
}

-(void)Error:(NSError *)Error
{
    /*UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show]; */
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError * error;
    
    dictResult = [NSJSONSerialization
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                 error:&error];

    if ([tagName isEqualToString:@"ValidatePinNumber"])
    {
        NSString * encryptedPIN = [dictResult valueForKey:@"Status"];

        serve * checkValid = [serve new];
        checkValid.tagName = @"checkValid";
        checkValid.Delegate = self;
        [checkValid ValidatePinNumberToEnterForEnterForeground:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
    }
    
    else if ([tagName isEqualToString:@"checkValid"])
    {
        if ([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"])
        {
            if ( [user objectForKey:@"requiredImmediately"] == NULL ||
                [[user objectForKey:@"requiredImmediately"] isKindOfClass:[NSNull class]])
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReEnterPIN_RqrPinStngAlrtTtl", @"'Require PIN Setting' Alert Title")
                                                              message:NSLocalizedString(@"ReEnterPIN_RqrPinStngAlrtBody", @"Require PIN Setting Alert Body")//@"The Require Immediately function is an added security feature that prompts you for your PIN whenever you open Nooch.\n\nWould you like to keep this on or turn it off? You can change this setting in Settings."
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"ReEnterPIN_RqrPinStngAlrtOffBtn", @"Require PIN Setting Alert 'Turn Off' Btn Text")
                                                    otherButtonTitles:NSLocalizedString(@"ReEnterPIN_RqrPinStngAlrtOnBtn", @"Require PIN Setting Alert 'Keep On' Btn Text"), nil];
                [av setTag:1];
                [av show];
                return;
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }
        }

        else
        {
            [self.fourth_num setBackgroundColor:[UIColor clearColor]];
            [self.third_num setBackgroundColor:[UIColor clearColor]];
            [self.second_num setBackgroundColor:[UIColor clearColor]];
            [self.first_num setBackgroundColor:[UIColor clearColor]];
            self.pin.text = @"";

            if ([[dictResult objectForKey:@"Result"] isEqualToString:@"Invalid Pin"])
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
                self.prompt.text = NSLocalizedString(@"ReEnterPIN_IncrctPinLbl", @"ReEnter PIN 'Incorrect PIN - Please Try Again' Feedback Text");
                [self.view addSubview:self.prompt];
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
                self.prompt.text = NSLocalizedString(@"ReEnterPIN_IncrctPinLbl2nd", @"ReEnter PIN 'Incorrect PIN - 2nd Failed Attempt' Feedback Text");
                UIAlertView * suspendedAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ReEnterPIN_TryAgnAlrtTtl", @"'Please Try Again' Alert Title")
                                                                         message:NSLocalizedString(@"ReEnterPIN_TryAgnAlrtBody", @"Please Try Again Alert Body Text")//@"For security protection, your account will be suspended for 24 hours if you enter an incorrect PIN again."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                [suspendedAlert show];
            }
        }
    }
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0) {
            serve * serveOBJ = [serve new];
            [serveOBJ setTagName:@"requiredImmediately"];
            [serveOBJ setDelegate:self];
            [serveOBJ SaveImmediateRequire:NO];
            [user setObject:@"NO" forKey:@"requiredImmediately"];
        }
        else {
            serve * serveOBJ = [serve new];
            [serveOBJ setTagName:@"requiredImmediately"];
            [serveOBJ setDelegate:self];
            [serveOBJ SaveImmediateRequire:YES];
            [user setObject:@"YES" forKey:@"requiredImmediately"];
        }
        NSLog(@"%@",user);
        //reqImm = NO;

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
