//
//  BankVerification.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "BankVerification.h"
#import "Home.h"
#import "assist.h"
#import "ECSlidingViewController.h"
@interface BankVerification ()


@property (nonatomic,strong) UIButton *verify;
@property(nonatomic,strong) UIButton*removeBank;
@property (nonatomic,strong) UITextField *micro1;
@property (nonatomic,strong) UITextField *micro2;
@end

@implementation BankVerification

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
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    

	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 0, 0)];
    [info setStyleClass:@"instruction_text"];
    [info setNumberOfLines:4];
    [info setText:@"Check your most recent bank statement and enter the amounts deposited by Nooch into your account into the boxes below."];
    [self.view addSubview:info];
    //Bank verifivation
    UILabel *micro1_lbl = [UILabel new]; [micro1_lbl setText:@"$ 0."];
    [micro1_lbl setStyleId:@"label_micro1"];
    [self.view addSubview:micro1_lbl];
    
    UILabel *micro2_lbl = [UILabel new]; [micro2_lbl setText:@"$ 0."];
    [micro2_lbl setStyleId:@"label_micro2"];
    [self.view addSubview:micro2_lbl];
    
    
    self.micro1 = [UITextField new];
    [self.micro1 setTextAlignment:NSTextAlignmentRight]; [self.micro1 setPlaceholder:@"00"];
    self.micro1.layer.cornerRadius=5.0f;
    self.micro1.layer.borderColor=[[UIColor grayColor]CGColor];
    self.micro1.layer.borderWidth=1.0f;

    [self.micro1 setDelegate:self]; [self.micro1 setTag:1];
    [self.micro1 setKeyboardType:UIKeyboardTypeNumberPad];
    [self.micro1 setStyleId:@"micro1_amountfield"];
    [self.view addSubview:self.micro1];
    
    [self.micro1 becomeFirstResponder];
    self.micro2 = [UITextField new];
    self.micro2.layer.cornerRadius=5.0f;
    self.micro2.layer.borderColor=[[UIColor grayColor]CGColor];
    self.micro2.layer.borderWidth=1.0f;
    [self.micro2 setTextAlignment:NSTextAlignmentRight]; [self.micro2 setPlaceholder:@"00"];
    [self.micro2 setDelegate:self]; [self.micro2 setTag:1];
    [self.micro2 setKeyboardType:UIKeyboardTypeNumberPad];
    [self.micro2 setStyleId:@"micro2_amountfield"];
    [self.view addSubview:self.micro2];
   // [self.micro2 becomeFirstResponder];
    
    self.verify = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.verify setFrame:CGRectMake(0, 200, 0, 0)];
    [self.verify setTitle:@"Verify Bank Account" forState:UIControlStateNormal];
    [self.verify setStyleClass:@"button_green"];
    [self.verify setStyleId:@"verifybank_button"];
    //if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"IsPrimaryBankVerified"]isEqualToString:@"YES"]) {
    if ([[assist shared]isBankVerified]) {
        
        [self.verify setTitle:@"Your bank is already Verified" forState:UIControlStateNormal];
        [self.verify setEnabled:NO];
        
    }
    else
    {
         [self.verify setEnabled:YES];
    }
    [self.verify addTarget:self action:@selector(verify_amounts) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.verify];
    
    self.removeBank = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.removeBank setFrame:CGRectMake(0, 270, 0, 0)];
    [self.removeBank setTitle:@"Remove Bank Account" forState:UIControlStateNormal];
    [self.removeBank setStyleClass:@"button_red"];
    [self.removeBank setStyleId:@"removebank_button"];
    
    [self.removeBank addTarget:self action:@selector(Remove_Bank) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.removeBank];

}
-(void)dismissKeyboard{
    [self.micro1 resignFirstResponder];
    [self.micro2 resignFirstResponder];
}
- (void) verify_amounts
{
   [self.micro1 resignFirstResponder];
    [self.micro2 resignFirstResponder];
    NSString *amountOne=[NSString stringWithFormat:@".%@", self.micro1.text];
    NSString *amountTwo=[NSString stringWithFormat:@".%@", self.micro2.text];
//    if((([amountOne intValue] < 100) && ([amountOne intValue] > 0)) && (([amountTwo intValue] < 100) && ([amountTwo intValue] > 0)))
//    {
        verifyAttempts++;
        serve *ver  = [serve new];
        ver.tagName = @"verification";
        ver.Delegate = self;
        [ver verifyBank:[[NSUserDefaults standardUserDefaults] objectForKey:@"choice"] microOne:amountOne microTwo:amountTwo];
        [me waitStat:@"Attempting to verify your account..."];
//    }
//    else
//    {
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter valid amounts." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//        [alertView sizeToFit];
//        [alertView show];
//        self.micro1.text=@"";
//        self.micro1.text=@"";
//    }

}
-(void)Remove_Bank{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You are attempting to remove this bank account from Nooch." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [av setTag:1];
    [av show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1 && buttonIndex == 1) {
        serve *bank = [serve new];
        bank.tagName = @"bDelete";
        bank.Delegate = self;
        [bank deleteBank:[[NSUserDefaults standardUserDefaults] objectForKey:@"choice"]];
    }
}
#pragma mark - server delegation
-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    //[me endWaitStat];
    NSError* error;
    NSMutableDictionary*dictResponse = [NSJSONSerialization
                                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                        options:kNilOptions
                                        error:&error];
   // NSDictionary *loginResult = [result JSONValue];
    if ([tagName isEqualToString:@"bDelete"]) {
       // [me getBanks];
        if([(NSString *)[dictResponse valueForKey:@"Result"] isEqualToString:@"Your bank account details has been deleted successfully."])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The bank account details have been deleted." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"IsPrimaryBankVerified"];
              for (UILocalNotification *localnoti in [[UIApplication sharedApplication] scheduledLocalNotifications] ) {
                if ([[localnoti.userInfo valueForKey:@"notificationId"]isEqualToString:@"Bank1"]) {
                    [[UIApplication sharedApplication]cancelLocalNotification:localnoti];
                }
                if ([[localnoti.userInfo valueForKey:@"notificationId"]isEqualToString:@"Bank2"]) {
                    [[UIApplication sharedApplication]cancelLocalNotification:localnoti];
                }
                if ([[localnoti.userInfo valueForKey:@"notificationId"]isEqualToString:@"Bank3"]) {
                    [[UIApplication sharedApplication]cancelLocalNotification:localnoti];
                }
                
            }
            
            
            [self.navigationController popViewControllerAnimated:YES];
            //            [navCtrl dismissViewControllerAnimated:YES anima
            //             ];
        }
    }else if([tagName isEqualToString:@"verification"]){
        if([[dictResponse objectForKey:@"Result"] isEqualToString:@"Your bank account is verified successfully."]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Eureka!"message:@"Your bank account information all checks out, you’re free to go. Nooch forth."delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [me getBanks];
            [self.navigationController popViewControllerAnimated:YES];
            //[navCtrl dismissModalViewControllerAnimated:YES];
            verifyAttempts = 0;
        }else if(verifyAttempts == 2){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Careful..."message:@"You've failed verification twice now. We're getting suspicious, one more failed verification attempt and this bank account will be deleted from our system."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
        }else if(verifyAttempts == 3) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh!"message:@"You've failed verification three times now. Not that we don't trust you, but it's starting to look like the account doesn't belong to you."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [me waitStat:@"Deleting this account for security purposes..."];
            serve *bank = [serve new];
            bank.tagName = @"bDelete";
            bank.Delegate = self;
            [bank deleteBank:[[NSUserDefaults standardUserDefaults] objectForKey:@"choice"]];
            verifyAttempts = 0;
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hmmm.."message:@"Verification failed, please check the two deposit amounts again."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
        }
    }
     
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
