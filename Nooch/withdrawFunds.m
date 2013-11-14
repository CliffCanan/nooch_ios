//
//  withdrawFunds.m
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "withdrawFunds.h"

@interface withdrawFunds ()

@end

@implementation withdrawFunds

NSMutableDictionary *selectedBank;
NSString *actualAmount;
bool pinCheck;

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
    banksTable.layer.cornerRadius = 10;
    banksTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    banksTable.layer.borderWidth = 1.0f;
    [withdrawAll addTarget:self action:@selector(entireBalance) forControlEvents:UIControlEventTouchUpInside];
    [withdrawGo addTarget:self action:@selector(finishProcess) forControlEvents:UIControlEventTouchUpInside];
    [amountField setInputView:amountKeyboard];
    [enterPINField setInputView:amountKeyboard];
    amountReminder.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    [leftNavButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [amountReminder setFont:[core nFont:@"Medium" size:14]];
    [headerTitle setTextColor:[core hexColor:@"737b80"]];
}

-(void)cancel{
    pinCheck = NO;
    amountField.text = @"";
    [[navCtrl.viewControllers objectAtIndex:0] performSelectorOnMainThread:@selector(showFundsMenu) withObject:nil waitUntilDone:YES];
    [navCtrl dismissViewControllerAnimated:YES completion:nil];

   // [navCtrl dismissModalViewControllerAnimated:YES];
}
- (IBAction)doneEnteringAmount:(id)sender {
    [amountField resignFirstResponder];
}

-(void)entireBalance{
    amountField.text = [[me usr] objectForKey:@"Balance"];
    [amountField resignFirstResponder];
}

-(void)finishProcess{
    if([amountField.text doubleValue] < 1 || [amountField.text length] == 0){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid amount entered!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    if([amountField.text doubleValue] > [[[me usr] objectForKey:@"Balance"] doubleValue]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Check Your Math" message:@"Unfortunately, we cannot let you withdraw an amount that exceeds your current Nooch balance. It’s money made simple, not the free money app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    if([amountField.text doubleValue] > 100){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Withdrawal Limit Reached" message:@"You may only withdraw $100 from your Nooch account at a time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    CGRect pinFrame = pinView.frame;
    pinFrame.origin.x = 0;
    pinFrame.origin.y = 40;
    pinView.frame = pinFrame;
    [self.view addSubview:pinView];
    firstPIN.highlighted = NO;
    secondPIN.highlighted = NO;
    thirdPIN.highlighted = NO;
    fourthPIN.highlighted = NO;
    withdrawAll.hidden = YES;
    [enterPINField becomeFirstResponder];
    pinCheck = YES;
    [decimalButton setEnabled:NO];
    [doneEnteringButton setHidden:YES];
    amountReminder.text = [NSString stringWithFormat:@"Withdrawing $%@",amountField.text];
    [amountReminder setTextColor:[UIColor whiteColor]];
    amountReminder.hidden = NO;
    //amountReminder.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([newString doubleValue] > 100){
        return NO;
    }
    return YES;
}

-(void)editAmount:(UIButton*)sender{
    if (pinCheck) {
        switch(sender.tag)
        {
            case 1:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"0"];
                break;
            }case 2:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"1"];
                break;
            }case 3:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"2"];
                break;
            }case 4:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"3"];
                break;
            }case 5:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"4"];
                break;
            }case 6:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"5"];
                break;
            }case 7:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"6"];
                break;
            }case 8:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"7"];
                break;
            }case 9:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"8"];
                break;
            }case 10:{
                enterPINField.text = [enterPINField.text stringByAppendingString:@"9"];
                break;
            }case 11:{
                break;
            }case 12:{
                if(enterPINField.text.length != 0)
                    enterPINField.text = [enterPINField.text substringToIndex:[enterPINField.text length] - 1];
                break;
            }
        }
        if (enterPINField.text.length == 0) {
            firstPIN.highlighted = NO;
            secondPIN.highlighted = NO;
            thirdPIN.highlighted = NO;
            fourthPIN.highlighted = NO;
        }else if(enterPINField.text.length == 1 ){
            firstPIN.highlighted = YES;
            secondPIN.highlighted = NO;
            thirdPIN.highlighted = NO;
            fourthPIN.highlighted = NO;
        }else if(enterPINField.text.length == 2){
            firstPIN.highlighted = YES;
            secondPIN.highlighted = YES;
            thirdPIN.highlighted = NO;
            fourthPIN.highlighted = NO;
        }else if(enterPINField.text.length == 3){
            firstPIN.highlighted = YES;
            secondPIN.highlighted = YES;
            thirdPIN.highlighted = YES;
            fourthPIN.highlighted = NO;
        }else if (enterPINField.text.length == 4) {
            firstPIN.highlighted = YES;
            secondPIN.highlighted = YES;
            thirdPIN.highlighted = YES;
            fourthPIN.highlighted = YES;
            AppDelegate *appD = [UIApplication sharedApplication].delegate;
            [appD showWait:@"Processing your withdrawal..."];
            serve *withdraw = [serve new];
            withdraw.tagName = @"validPin";
            withdraw.Delegate = self;
            [withdraw getEncrypt:enterPINField.text];
        }
        return;
    }
    actualAmount = amountField.text;
    switch(sender.tag)
    {
        case 1:{
            actualAmount = [actualAmount stringByAppendingString:@"0"];
            break;
        }case 2:{
            actualAmount = [actualAmount stringByAppendingString:@"1"];
            break;
        }case 3:{
            actualAmount = [actualAmount stringByAppendingString:@"2"];
            break;
        }case 4:{
            actualAmount = [actualAmount stringByAppendingString:@"3"];
            break;
        }case 5:{
            actualAmount = [actualAmount stringByAppendingString:@"4"];
            break;
        }case 6:{
            actualAmount = [actualAmount stringByAppendingString:@"5"];
            break;
        }case 7:{
            actualAmount = [actualAmount stringByAppendingString:@"6"];
            break;
        }case 8:{
            actualAmount = [actualAmount stringByAppendingString:@"7"];
            break;
        }case 9:{
            actualAmount = [actualAmount stringByAppendingString:@"8"];
            break;
        }case 10:{
            actualAmount = [actualAmount stringByAppendingString:@"9"];
            break;
        }case 11:{
            actualAmount = [actualAmount stringByAppendingString:@"."];
            break;
        }case 12:{
            if(actualAmount.length != 0)
                actualAmount = [actualAmount substringToIndex:[actualAmount length] - 1];
            break;
        }
    }
    NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:actualAmount
                                                        options:0
                                                          range:NSMakeRange(0, [actualAmount length])];
    if (numberOfMatches != 0)
        amountField.text = actualAmount;
    else
        [actualAmount substringToIndex:[actualAmount length] -1];
}

-(void) listen:(NSString *)result tagName:(NSString *)tagName{
    NSMutableDictionary *loginResult = [result JSONValue];
    if([tagName isEqualToString:@"withdraw"])
    {
        NSDictionary *resultValue = [loginResult valueForKey:@"WithDrawFundResult"];
        NSLog(@"resultValue is : %@", loginResult);
        AppDelegate *appD = [UIApplication sharedApplication].delegate;
        [appD endWait];
        if([[resultValue valueForKey:@"Result"] isEqualToString:[NSString stringWithFormat:@"You have withdrawn $%.02f from your nooch account successfully.",[amountField.text floatValue]]])
        {
            [me histUpdate];
            NSString *alertTitleString = [NSString stringWithFormat:@"Success, your request to withdraw $"];
            NSString *amt = [NSString stringWithFormat:@"%.02f", [amountField.text floatValue]];
            alertTitleString = [alertTitleString stringByAppendingFormat:@"%@ from your Nooch account has been submitted.", amt];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:alertTitleString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [av setTag:9];
            updateHistory = YES;
            [navCtrl popViewControllerAnimated:YES];
        }else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }else if([tagName isEqualToString:@"validPin"] ){
        NSString *encryptedPIN=[loginResult objectForKey:@"Status"];
        serve *checkValid = [serve new];
        checkValid.tagName = @"checkValid";
        checkValid.Delegate = self;
        [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
    }else if([tagName isEqualToString:@"checkValid"] ){
        if([[loginResult objectForKey:@"Result"] isEqualToString:@"Success"]){
            pinCheck = NO;
            serve *processWithdraw = [serve new];
            processWithdraw.Delegate = self;
            processWithdraw.tagName = @"withdraw";
            [processWithdraw withdrawFund:amountField.text];
        }else{
            firstPIN.highlighted = NO;
            secondPIN.highlighted = NO;
            thirdPIN.highlighted = NO;
            fourthPIN.highlighted = NO;
            enterPINField.text = @"";
            AppDelegate *appD = [UIApplication sharedApplication].delegate;
            [appD endWait];
        }

        if([[loginResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]){
            prompt.text=@"1 Failed Attempt";
        }else if([[loginResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]){
            prompt.text=@"2 Failed Attempts";
        }else if(([[loginResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            prompt.text=@"Account suspended.";
        }else if(([[loginResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            prompt.text=@"Account suspended.";
        }
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[me usr] objectForKey:@"banks"] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    NSLog(@"reloading");
    cell.detailTextLabel.text = @"";
    cell.indentationLevel = 1;
    cell.indentationWidth = 40;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 34, 35)];
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = 6;
    [cell.textLabel setFont:[core nFont:@"Medium" size:13.0]];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    NSMutableDictionary *bank = [[NSMutableDictionary alloc] init];
    bank = [[[me usr] objectForKey:@"banks"] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Account **** %@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length] -4]];
    if (bank == selectedBank) {
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(260,13,20,20)];
        arrow.image = [UIImage imageNamed:@"GreenDot.png"];
        [cell.contentView addSubview:arrow];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedBank = [[[me usr] objectForKey:@"banks"] objectAtIndex:indexPath.row];
    [banksTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEntering:(id)sender {
    [amountField resignFirstResponder];
}
//kustom keyboard shit
- (IBAction)one:(id)sender {
    [self editAmount:sender];
}
- (IBAction)two:(id)sender {
    [self editAmount:sender];
}
- (IBAction)three:(id)sender {
    [self editAmount:sender];
}
- (IBAction)four:(id)sender {
    [self editAmount:sender];
}
- (IBAction)five:(id)sender {
    [self editAmount:sender];
}
- (IBAction)six:(id)sender {
    [self editAmount:sender];
}
- (IBAction)seven:(id)sender {
    [self editAmount:sender];
}
- (IBAction)eight:(id)sender {
    [self editAmount:sender];
}
- (IBAction)nine:(id)sender {
    [self editAmount:sender];
}
- (IBAction)zero:(id)sender {
    [self editAmount:sender];
}
- (IBAction)decimal:(id)sender {
    [self editAmount:sender];
}
- (IBAction)backspace:(id)sender {
    [self editAmount:sender];
}


- (void)viewDidUnload {
    leftNavButton = nil;
    navBar = nil;
    banksTable = nil;
    withdrawGo = nil;
    amountField = nil;
    withdrawAll = nil;
    amountKeyboard = nil;
    keyboardAccess = nil;
    pinView = nil;
    decimalButton = nil;
    firstPIN = nil;
    secondPIN = nil;
    thirdPIN = nil;
    fourthPIN = nil;
    enterPINField = nil;
    prompt = nil;
    doneEnteringButton = nil;
    amountReminder = nil;
    headerTitle = nil;
    [super viewDidUnload];
}
@end
