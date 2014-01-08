//
//  ReEnterPin.m
//  Nooch
//
//  Created by Vicky Mathneja on 08/01/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "ReEnterPin.h"
#import <Pixate/Pixate.h>
@interface ReEnterPin ()<UITextFieldDelegate>
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
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
    UIView*navBar=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    [navBar setBackgroundColor:[UIColor colorWithRed:82.0f/255.0f green:176.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
    [self.view addSubview:navBar];
    UILabel*lbl=[[UILabel alloc]initWithFrame:CGRectMake(75, 20, 200, 30)];
    [lbl setText:@"PIN Confirmation"];
    [lbl setFont:[UIFont systemFontOfSize:22]];
    [lbl setTextColor:[UIColor whiteColor]];
    [navBar addSubview:lbl];
    
    // Do any additional setup after loading the view from its nib.
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];
    
    [self.navigationItem setTitle:@"PIN Confirmation"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 104, 300, 60)];
    [title setText:@"Please confirm your PIN."]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"Repin_instructiontext"];
    [self.view addSubview:title];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 194, 300, 30)];
    [self.prompt setText:@""]; [self.prompt setTextAlignment:NSTextAlignmentCenter];
    [self.prompt setStyleId:@"pin_instructiontext_send"];
    [self.view addSubview:self.prompt];
    
//    UIView *back = [UIView new];
//    [back setStyleClass:@"raised_view"];
//    [back setStyleClass:@"pin_recipientbox"];
//    [self.view addSubview:back];
//    
//    UIView *bar = [UIView new];
//    [bar setStyleClass:@"pin_recipientname_bar"];
//    [self.view addSubview:bar];
    
    //    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 300, 30)];
    //    if ([[self.receiver objectForKey:@"FirstName"] length] == 0) {
    //        [to_label setText:@"   4K For Cancer"];
    //        [to_label setBackgroundColor:kNoochPurple];
    //    } else {
    //        [to_label setText:[NSString stringWithFormat:@" %@ %@",[self.receiver objectForKey:@"FirstName"],[self.receiver objectForKey:@"LastName"]]];
    //    }
    //    [to_label setStyleClass:@"pin_recipientname_text"];
    //    [self.view addSubview:to_label];
    
    //    UILabel *memo_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 230, 300, 30)];
    //    if ([[self.receiver objectForKey:@"memo"] length] > 0) {
    //        [memo_label setText:[self.receiver objectForKey:@"memo"]];
    //    }else{
    //        [memo_label setText:@"No memo attached"];
    //    }
    //    [memo_label setTextAlignment:NSTextAlignmentCenter];
    //    [memo_label setStyleClass:@"pin_memotext"];
    //    [self.view addSubview:memo_label];
    //
    //    UIImageView *user_pic = [UIImageView new];
    //    [user_pic setFrame:CGRectMake(20, 204, 52, 52)];
    //    user_pic.layer.borderColor = [UIColor whiteColor].CGColor;
    //    user_pic.layer.borderWidth = 2; user_pic.clipsToBounds = YES;
    //    user_pic.layer.cornerRadius = 26;
    //    [self.view addSubview:user_pic];
    //
    //    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 290, 30)];
    //    [total setBackgroundColor:[UIColor clearColor]];
    //    [total setTextColor:[UIColor whiteColor]]; [total setTextAlignment:NSTextAlignmentRight];
    //    [total setText:[NSString stringWithFormat:@"$ %.02f",self.amnt]];
    //    [total setStyleClass:@"pin_amountfield"];
    //    [self.view addSubview:total];
    
    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(44,134,32,32)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(107,134,32,32)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(170,134,32,32)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(233,134,32,32)];
    
    //self.first_num.alpha = self.second_num.alpha = self.third_num.alpha = self.fourth_num.alpha = 0.5;
    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 16;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;
    
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
        
        serve *pin = [serve new];
        pin.Delegate = self;
        pin.tagName = @"ValidatePinNumber";
        [pin getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
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
    if ([tagName isEqualToString:@"ValidatePinNumber"]) {
        NSString *encryptedPIN=[dictResult valueForKey:@"Status"];
        
        serve *checkValid = [serve new];
        checkValid.tagName = @"checkValid";
        checkValid.Delegate = self;
        [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
    }
    else if ([tagName isEqualToString:@"checkValid"]){
        if([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"]){
            NSLog(@"%@",[me usr]);
            if ([[me usr] objectForKey:@"requiredImmediately"] == NULL || [[[me usr] objectForKey:@"requiredImmediately"] isKindOfClass:[NSNull class]]) {
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
            [spinner stopAnimating];
            [spinner setHidden:YES];
        }else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]){
            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.prompt.text=@"2 Failed Attempts";
        }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.prompt.text=@"Account suspended.";
        }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            self.prompt.text=@"Account suspended.";
        }
}
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        if (alertView.tag == 1) {
            if (buttonIndex == 0) {
                [[me usr] setObject:@"NO" forKey:@"requiredImmediately"];
            }else{
                [[me usr] setObject:@"YES" forKey:@"requiredImmediately"];
            }
             NSLog(@"%@",[me usr]);
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
