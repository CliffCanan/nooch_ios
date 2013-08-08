//
//  addBankAcct.m
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "addBankAcct.h"

@interface addBankAcct ()

@end

@implementation addBankAcct

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)securityLink:(id)sender {
    NSURL *webURL = [NSURL URLWithString:@"http://support.nooch.com/customer/portal/articles/285024-how-does-nooch-secure-my-data"];
    [[UIApplication sharedApplication] openURL: webURL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    scrollView.contentSize = CGSizeMake(320,600);

}

-(void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    [leftNavButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [doneEntering addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [previousButton addTarget:self action:@selector(prevField) forControlEvents:UIControlEventTouchUpInside];
    [nextButton addTarget:self action:@selector(nextField) forControlEvents:UIControlEventTouchUpInside];
    [firstLast setInputAccessoryView:inputAccess];
    [routingNumber setInputAccessoryView:inputAccess];
    [accountNum setInputAccessoryView:inputAccess];
    detailsTable.layer.cornerRadius = 10;
    detailsTable.layer.borderWidth = 1.0f;
    detailsTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
}
- (IBAction)addBank:(id)sender {
    if ([accountNum.text length] < 3 || [accountNum.text length] > 17)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Account Number" message:@"Please double check your account number, it should ranges between 3 and 17 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }

    else if ([routingNumber.text length] < 9  )
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Routing Number" message:@"Please double check your routing number, it should be 9 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }

    else if(([firstLast.text isEqualToString:@""]) || ([firstLast.text isEqual:[NSNull null]]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter the name on the account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSArray *array = [firstLast.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *first = [array objectAtIndex:0];
        NSString *last = [array lastObject];
        NSDictionary *transactionInput  =[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId", @"test",@"BankName",accountNum.text,@"BankAcctNumber", routingNumber.text,@"BankAcctRoutingNumber",first,@"FirstName",last,@"LastName",nil];

        NSMutableDictionary *transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"accountInput", nil];
        serve *addBank = [serve new];
        addBank.tagName = @"addBank";
        addBank.Delegate = self;
        [addBank saveBank:transaction];
    }
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    NSMutableDictionary *loginResult = [result JSONValue];
    if([tagName isEqualToString:@"addBank"])
    {
        NSDictionary *resultValue = [loginResult valueForKey:@"SaveBankAccountDetailsResult"];

        if([[resultValue valueForKey:@"Result"] isEqualToString:@"Your account details have been saved successfully."]){

            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:@"Bank Account Submitted" message:@"Your bank information has been successfully submitted to Nooch. For security, we must verify that you own this account. In two business days, check your bank statement to find two deposits of less than $1 from Nooch Inc. Then return here, punch in the amounts, and tap 'Verify Account.'" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [showAlertMessage setTag:2];
            [showAlertMessage show];
            routingNumber.text = @"";
            firstLast.text = @"";
            [self cancel];
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == firstLast) {
        return;
    }
    [scrollView setContentOffset:CGPointMake(0.0,textField.frame.size.height+10*textField.tag) animated:YES];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField == routingNumber){
        if([newString length] > 9)
            return NO;
    }else if(textField == accountNum){
        if([newString length] > 16)
            return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == accountNum)
        [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:YES];
}

- (void)closeKeyboard{
    [accountNum resignFirstResponder];
    [firstLast resignFirstResponder];
    [routingNumber resignFirstResponder];

}
- (void)prevField {
    if(routingNumber.isFirstResponder){
        [firstLast becomeFirstResponder];
    }else if(accountNum.isFirstResponder){
        [routingNumber becomeFirstResponder];
    }
}
- (void)nextField {
    if(firstLast.isFirstResponder){
        [routingNumber becomeFirstResponder];
    }else if(routingNumber.isFirstResponder){
        [accountNum becomeFirstResponder];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.detailTextLabel.text = @"";
    cell.indentationLevel = 1;
    cell.indentationWidth = 40;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 34, 35)];
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = 6;
    [cell.textLabel setFont:[core nFont:@"Regular" size:15.0]];
    [cell.textLabel setTextColor:[core hexColor:@"003c5e"]];
    cell.indentationWidth = 5;
    if(indexPath.row == 0){
        [cell.textLabel setText:@"Name on Account"];
    }else if(indexPath.row == 1){
        [cell.textLabel setText:@"Routing Number"];
    }else{
        [cell.textLabel setText:@"Account Number"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)cancel{
    [[navCtrl.viewControllers objectAtIndex:0] performSelectorOnMainThread:@selector(showFundsMenu) withObject:nil waitUntilDone:YES];
    [navCtrl dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    navBar = nil;
    leftNavButton = nil;
    detailsTable = nil;
    scrollView = nil;
    firstLast = nil;
    routingNumber = nil;
    accountNum = nil;
    saveButton = nil;
    inputAccess = nil;
    doneEntering = nil;
    previousButton = nil;
    nextButton = nil;
    [super viewDidUnload];
}
@end
