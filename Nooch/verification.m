//
//  verification.m
//  Nooch
//
//  Created by Preston Hults on 7/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "verification.h"

@interface verification ()

@end

@implementation verification
int verifyAttempts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)cancel:(id)sender {
    [[navCtrl.viewControllers objectAtIndex:0] performSelectorOnMainThread:@selector(showFundsMenu) withObject:nil waitUntilDone:YES];
    [navCtrl dismissViewControllerAnimated:YES completion:nil];
   // [navCtrl dismissModalViewControllerAnimated:YES];
}
- (IBAction)submitButton:(id)sender {
    [amount1 resignFirstResponder];
    [amount2 resignFirstResponder];
    NSString *amountOne=amount1.text;
    NSString *amountTwo=amount2.text;
    if((([amountOne intValue] < 100) && ([amountOne intValue] > 0)) && (([amountTwo intValue] < 100) && ([amountTwo intValue] > 0)))
    {
        verifyAttempts++;
        serve *ver  = [serve new];
        ver.tagName = @"verification";
        ver.Delegate = self;
        [ver verifyBank:[[NSUserDefaults standardUserDefaults] objectForKey:@"choice"] microOne:amountOne microTwo:amountTwo];
        [me waitStat:@"Attempting to verify your account..."];
    }
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter valid amounts." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView sizeToFit];
        [alertView show];
        amount1.text=@"";
        amount2.text=@"";
    }
}
- (IBAction)removeAccount:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You are attempting to remove this bank account from Nooch." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [av setTag:1];
    [av show];
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    [me endWaitStat];
    NSDictionary *loginResult = [result JSONValue];
    if ([tagName isEqualToString:@"bDelete"]) {
        [me getBanks];
        if([(NSString *)[loginResult valueForKey:@"Result"] isEqualToString:@"Your bank account details has been deleted successfully."])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"The bank account details have been deleted." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [navCtrl dismissViewControllerAnimated:YES completion:nil];
//            [navCtrl dismissViewControllerAnimated:YES anima
//             ];
        }
    }else if([tagName isEqualToString:@"verification"]){
        if([[loginResult objectForKey:@"Result"] isEqualToString:@"Your bank account is verified successfully."]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Eureka!"message:@"Your bank account information all checks out, you’re free to go. Nooch forth."delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView sizeToFit];
            [alertView show];
            [navCtrl dismissViewControllerAnimated:YES completion:nil];
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1 && buttonIndex == 1) {
        serve *bank = [serve new];
        bank.tagName = @"bDelete";
        bank.Delegate = self;
        [bank deleteBank:[[NSUserDefaults standardUserDefaults] objectForKey:@"choice"]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillAppear:(BOOL)animated{
    [amount1 becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    navBar = nil;
    amount1 = nil;
    amount2 = nil;
    [super viewDidUnload];
}
@end
