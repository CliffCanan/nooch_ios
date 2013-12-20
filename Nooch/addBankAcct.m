//
//  addBankAcct.m
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#define NUMBER @"1234567890"
#define ALPHA               @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#import "addBankAcct.h"
#import "serve.h"
#import <Foundation/Foundation.h>
@interface addBankAcct ()<UIAlertViewDelegate>
{
    NSString*SelectedBankName;
    serve*serveOBJ;
    NSArray *array;
    NSDictionary *transactionInput;
    NSString *first;
    NSString *last;
    NSMutableDictionary *transaction;
    
    NSString*ServiceType;
   }

@end

@implementation addBankAcct
@synthesize tbleBankList,bankListView;
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
    btnAddBank.enabled=YES;
    ServiceType=@"list";
    if (![self.view.subviews containsObject:bankListView]) {
        [self.view addSubview:bankListView];
    }
    
    
    
    //arrBankList=[[NSMutableArray alloc]init];
    serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    [serveOBJ getBankList];
    
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
    
    
    //charanjit's edit 26/11
//    if (![self CheckRoutingNo:[routingNumber text]]) {
//        [[[UIAlertView alloc] initWithTitle:@"Routing number not valid" message:@"Enter a valid Routing number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//        return;
//    }
//    
    btnAddBank.enabled=NO;
   
    if (![self.view.subviews containsObject:loader]) {
        loader=[me waitStat:@"Adding Bank Account Info..."];
        [self.view addSubview:loader];
    }
    firstLast.text=[firstLast.text lowercaseString];
    if ([accountNum.text length] < 5 || [accountNum.text length] > 17)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Account Number" message:@"Please double check your account number, it should ranges between 5 and 17 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        btnAddBank.enabled=YES;
        if ([self.view.subviews containsObject:loader]) {
            [loader removeFromSuperview];
            [me endWaitStat];
        }
    }

    else if ([routingNumber.text length] < 9  )
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Routing Number" message:@"Please double check your routing number, it should be 9 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        btnAddBank.enabled=YES;
        if ([self.view.subviews containsObject:loader]) {
            [loader removeFromSuperview];
            [me endWaitStat];
        }
    }

    else if(([firstLast.text isEqualToString:@""]) || ([firstLast.text isEqual:[NSNull null]]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter the name on the account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        btnAddBank.enabled=YES;
        if ([self.view.subviews containsObject:loader]) {
            [loader removeFromSuperview];
            [me endWaitStat];
        }
    }
    else
    {
        ServiceType=@"vBank";
        serve *vBank = [serve new];
        vBank.tagName = @"validateBank";
        vBank.Delegate = self;
      //  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
      //  [f setNumberStyle:NSNumberFormatterDecimalStyle];
       // NSNumber * myNumber = [f numberFromString:routingNumber.text];
        [vBank ValidateBank:SelectedBankName routingNo:routingNumber.text];

        
    }
}
//check validate Routing number

-(BOOL)CheckRoutingNo:(NSString *)routingNumber1 {
    NSLog(@"Routing number is %@",routingNumber1);
    //underlining formula used
    //3 (d_1 + d_4 + d_7) + 7 (d_2 + d_5 + d_8) + (d_3 + d_6 + d_9) \mod 10 = 0
    //3 (d_0 + d_3 + d_6) + 7 (d_1 + d_4 + d_7) + (d_2 + d_5 + d_8) \mod 10 = 0
    //3 (7 + 5 + 5)
    NSInteger num = [routingNumber1 integerValue];
    //getting digits in array
    NSMutableArray * arr_digits = [[NSMutableArray alloc] init];
    for (int i=0; i<9; i++) {
        [arr_digits addObject:[NSNumber numberWithInteger:num%10]];
        num=num/10;
    }
    NSLog(@"all array %@",arr_digits);
    
    //reversing the array
    NSArray *array2=[arr_digits mutableCopy];
    NSArray* reversed = [[array2 reverseObjectEnumerator] allObjects];
    [arr_digits removeAllObjects];
    arr_digits =[reversed mutableCopy];
    
    //performign the calculations
    int first_part = (3*([arr_digits[0] intValue] + [arr_digits[3] intValue] + [arr_digits[6] intValue]));
    
    int second_part = (7*([arr_digits[1] intValue] + [arr_digits[4] intValue] + [arr_digits[7] intValue]));
    
    int third_part = (([arr_digits[2] intValue] + [arr_digits[5] intValue] + [arr_digits[8] intValue]));
    
    //peforming modulous
    int modulous = fmod(first_part+second_part+third_part, 10);
    //checking mod
    if (modulous == 0) {
        return YES;
    }
    
    //returning negative
    return NO;
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    
    if ([ServiceType isEqualToString:@"vBank"]) {
        NSMutableDictionary*dictResponse=[result JSONValue];
        if ([[[dictResponse valueForKey:@"ValidateBankResult"] stringValue]isEqualToString:@"0"]) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Valid Bank Routing Number!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            btnAddBank.enabled=YES;
            if ([self.view.subviews containsObject:loader]) {
                [loader removeFromSuperview];
                [me endWaitStat];
            }

        }
        else
        {
            array = [firstLast.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            first = [array objectAtIndex:0];
            last = [array lastObject];
            transactionInput  =[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId", SelectedBankName,@"BankName",accountNum.text,@"BankAcctNumber", routingNumber.text,@"BankAcctRoutingNumber",first,@"FirstName",last,@"LastName",nil];
            
            transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"accountInput", nil];
            ServiceType=@"SaveBank";
            serve *addBank = [serve new];
            addBank.tagName = @"addBank";
            addBank.Delegate = self;
            [addBank saveBank:transaction];
        }
    }

    if ([ServiceType isEqualToString:@"list"]) {
        arrBankList =[[NSMutableArray alloc]initWithArray:[result JSONValue]];
        NSLog(@"list %@",arrBankList);
        [tbleBankList reloadData];
    }
    else
    {
    if([tagName isEqualToString:@"addBank"])
    {
         NSMutableDictionary *loginResult = [result JSONValue];
        NSDictionary *resultValue = [loginResult valueForKey:@"SaveBankAccountDetailsResult"];

        if([[resultValue valueForKey:@"Result"] isEqualToString:@"Your account details have been saved successfully."]){

            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:@"Bank Account Submitted" message:@"Your bank information has been successfully submitted to Nooch. For security, we must verify that you own this account. In two business days, check your bank statement to find two deposits of less than $1 from Nooch Inc. Then return here, punch in the amounts, and tap 'Verify Account.'" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [showAlertMessage setTag:2];
            [showAlertMessage show];
            routingNumber.text = @"";
            firstLast.text = @"";
            [self cancel];
            [detailsTable reloadData];
        }
        else if ([ServiceType isEqualToString:@"SaveBank"])
        {
            NSMutableDictionary *Result = [result JSONValue];
            if ([[[Result valueForKey:@"SaveBankAccountDetailsResult"]valueForKey:@"Result"]isEqualToString:@"Your account details have been saved successfully."]) {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:[[Result valueForKey:@"SaveBankAccountDetailsResult"]valueForKey:@"Result"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                if ([self.view.subviews containsObject:loader]) {
                    [loader removeFromSuperview];
                    [me endWaitStat];
                }

            }
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
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
 //   NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if(textField == routingNumber){
//        if([newString length] > 9)
//            return NO;
//    }else if(textField == accountNum){
//        if([newString length] > 16)
//            return NO;
//    }
    // self.searchText1=[NSString stringWithFormat:@"%@%@",textField.text, string] ;
    

    if (textField == routingNumber || textField == accountNum )
    {
        if ([string isEqualToString:@""]) {
            if (!textField.text.length)
                return NO;
            if ([[textField.text stringByReplacingCharactersInRange:range withString:string]rangeOfString:@""].length)
                return NO;
        }
        
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        if (textField==routingNumber) {
            if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 9) {
                return NO;
            }
            else if ([textField.text stringByReplacingCharactersInRange:range withString:string].length == 9)
            {
                if (![self CheckRoutingNo:[NSString stringWithFormat:@"%@%@",textField.text, string]]) {
                    [self.view setUserInteractionEnabled:NO];
                   UIAlertView*alert= [[UIAlertView alloc] initWithTitle:@"Routing number not valid" message:@"Enter a valid Routing number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] ;
                    [alert setTag:2300];
                    [alert show];
                    
                    return YES;
                }
                
                //[self CheckRoutingNo:[NSString stringWithFormat:@"%@%@",textField.text, string]];
            }
        }
        else if (textField==accountNum)
        {
            if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 16) {
                return NO;
            }
        }
        
        NSCharacterSet *charcter = [NSCharacterSet characterSetWithCharactersInString:NUMBER];
        if ([string rangeOfCharacterFromSet:charcter].location != NSNotFound) {
            return YES;
        }
        return NO;
    }

    if (textField == bankName || textField == firstLast )
    {
        if ([string isEqualToString:@""]) {
            if (!textField.text.length)
                return NO;
            if ([[textField.text stringByReplacingCharactersInRange:range withString:string]rangeOfString:@""].length)
                return NO;
        }
        
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
           //    if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 20) {
        //            return NO;
        //        }
        
        NSCharacterSet *charcter = [NSCharacterSet characterSetWithCharactersInString:ALPHA];
        if ([string rangeOfCharacterFromSet:charcter].location != NSNotFound) {
            return YES;
        }
        else
        {
            if ([string isEqualToString:@""]||[string isEqualToString:@" "]) {
                return YES;

            }
            else
            return NO;

        }
           }

    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:firstLast]) {
        [firstLast resignFirstResponder];
        [routingNumber becomeFirstResponder];
    }
    else if ([textField isEqual:routingNumber]){
        [routingNumber resignFirstResponder];
        [accountNum becomeFirstResponder];

    }
    else if ([textField isEqual:accountNum]){
        [accountNum resignFirstResponder];
        [bankName becomeFirstResponder];
        
    }
    else if ([textField isEqual:bankName]){
        [bankName resignFirstResponder];
      
        
    }

    [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == accountNum)
        [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    if (textField ==firstLast) {
        firstLast.text=[firstLast.text capitalizedString];
        
    }
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
    if ([tableView isEqual:tbleBankList]) {
        return arrBankList.count;
    }
    else
    {
    return 4;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    if ([tableView isEqual:tbleBankList]) {
        cell.textLabel.text=[arrBankList objectAtIndex:indexPath.row];
    }
    else
    {
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
    }else if(indexPath.row==2){
        [cell.textLabel setText:@"Account Number"];
    }
    else if (indexPath.row==3)
    {
        [cell.textLabel setText:@"Bank Name"];
       
        bankName.text=SelectedBankName;
        bankName.enabled=NO;
    }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:tbleBankList]) {
        [bankListView removeFromSuperview];
        SelectedBankName=[arrBankList objectAtIndex:indexPath.row];
        [detailsTable reloadData];
        
    }
    else
    {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
}

-(void)cancel{
    [[navCtrl.viewControllers objectAtIndex:0] performSelectorOnMainThread:@selector(showFundsMenu) withObject:nil waitUntilDone:YES];
    [navCtrl dismissViewControllerAnimated:YES completion:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag]==2300) {
        if (buttonIndex==0) {
            [self.view setUserInteractionEnabled:YES];
        }
    }
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
