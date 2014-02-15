//
//  NewBank.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "NewBank.h"
#import "ECSlidingViewController.h"
#import "Home.h"
#define NUMBER @"1234567890"
#define ALPHA               @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
@interface NewBank ()
@property(nonatomic,strong) UIButton *add;
@property(nonatomic,strong) UIButton *nevermind;
@property(nonatomic,strong) UITextField *name;
@property(nonatomic,strong) UITextField *account_number;
@property(nonatomic,strong) UITextField *routing_number;
@end

@implementation NewBank

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
    
    [self.navigationItem setTitle:@"Add Bank"];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tapped:)];
    [self.view addGestureRecognizer: tap];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 0, 0)];
    [header setNumberOfLines:2]; [header setText:@"Enter your bank info below to\n attach a bank account"];
    [header setStyleClass:@"instruction_text"];
    [header setStyleId:@"addbank_instruction"];
    [self.view addSubview:header];
    
    UIView *back = [UIView new];
    [back setBackgroundColor:[UIColor whiteColor]];
    [back setStyleClass:@"raised_view"];
    [back setFrame:CGRectMake(8, 66, 304, 148)];
    [self.view addSubview:back];
    
    UILabel *name_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 76, 0, 0)];
    [name_label setStyleClass:@"table_view_cell_textlabel_1"];
    [name_label  setText:@"Name on Account"];
    [self.view addSubview:name_label];
    
    self.name = [[UITextField alloc] initWithFrame:CGRectMake(0, 76, 0, 0)];
    [self.name setStyleClass:@"table_view_cell_detailtext_1"];
    [self.name setDelegate:self];
    [self.name setPlaceholder:@"First & Last"];
    [self.view addSubview:self.name];
    
    UILabel *routing = [[UILabel alloc] initWithFrame:CGRectMake(0, 124, 0, 0)];
    [routing setStyleClass:@"table_view_cell_textlabel_1"]; [routing setText:@"Routing No."];
    [self.view addSubview:routing];
    
    self.routing_number = [[UITextField alloc] initWithFrame:routing.frame];
    [self.routing_number setStyleClass:@"table_view_cell_detailtext_1"];
    [self.routing_number setDelegate:self]; [self.routing_number setKeyboardType:UIKeyboardTypeNumberPad];
    [self.routing_number setPlaceholder:@"9 Digits"];
    [self.view addSubview:self.routing_number];
    
    UIButton *inf1 = [UIButton new];
    [inf1 setStyleClass:@"infobutton"];
    [inf1 setStyleId:@"addbank_infobutton1"];
    [self.view addSubview:inf1];
    
    UIButton *inf2 = [UIButton new];
    [inf2 setStyleClass:@"infobutton"];
    [inf2 setStyleId:@"addbank_infobutton2"];
    [self.view addSubview:inf2];
    
    UILabel *account = [[UILabel alloc] initWithFrame:CGRectMake(0, 172, 0, 0)];
    [account setText:@"Account No."]; [account setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:account];
    
    self.account_number = [[UITextField alloc] initWithFrame:account.frame];
    [self.account_number setDelegate:self]; [self.account_number setStyleClass:@"table_view_cell_detailtext_1"];
    [self.account_number setPlaceholder:@"Account No."]; [self.account_number setKeyboardType:UIKeyboardTypeNumberPad];
    [self.view addSubview:self.account_number];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, 0, 0)];
    [info setStyleId:@"addbank_disclaimer_text"]; [info setNumberOfLines:0];
    [info setText:@"By selecting 'Add Bank Account' you are confirming the account is a checking account and are authorizing Nooch to initiate entries to the above bank account on your behalf."];
    [self.view addSubview:info];
    
    self.add = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.add setFrame:CGRectMake(0, 310, 0, 0)];
    [self.add setStyleClass:@"button_green"];
    [self.add setStyleId:@"addbank_button"];
    [self.add setEnabled:NO];
    [self.add addTarget:self action:@selector(addBank:) forControlEvents:UIControlEventTouchUpInside];
    [self.add setTitle:@"Add Bank Account" forState:UIControlStateNormal];
    [self.view addSubview:self.add];
    
    UILabel *encryption = [UILabel new];
    [encryption setStyleClass:@"label_encryption"];
    [encryption setText:@"Sent using a 196-bit secure connection"];
    [self.view addSubview:encryption];
    
    UIImageView *encrypt_icon = [UIImageView new];
    [encrypt_icon setStyleClass:@"icon_encryption"];
    [self.view addSubview:encrypt_icon];
}
-(void)addBank:(id)sender{
    self.name.text=[self.name.text lowercaseString];
    NSArray*arr=[self.name.text componentsSeparatedByString:@" "];
    if ([arr count]==1) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Enter First Name and Last Name in Account Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.name becomeFirstResponder];
        [av show];
        return;
    }
    
    if ([self.account_number.text length] < 5 || [self.account_number.text length] > 17)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Account Number" message:@"Please double check your account number, it should ranges between 5 and 17 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
        
    }
    
    else if ([self.routing_number.text length] < 9  )
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Routing Number" message:@"Please double check your routing number, it should be 9 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    else if(([self.name.text isEqualToString:@""]) || ([self.name.text isEqual:[NSNull null]]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter the name on the account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //        btnAddBank.enabled=YES;
        //        if ([self.view.subviews containsObject:loader]) {
        //            [loader removeFromSuperview];
        //            [me endWaitStat];
        //        }
    }
    else
    {
        
        NSArray* array = [self.name.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([array count]==2) {
            transactionInput  =[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId", @"",@"BankName",self.account_number.text,@"BankAcctNumber", self.routing_number.text,@"BankAcctRoutingNumber",[array objectAtIndex:0],@"FirstName",[array objectAtIndex:1],@"LastName",nil];
            
            
        }
        [self.name resignFirstResponder];
        [self.routing_number resignFirstResponder];
        [self.account_number resignFirstResponder];
        blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
        [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        UIActivityIndicatorView*actv=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2)-5, 40, 40)];
        [actv startAnimating];
        [blankView addSubview:actv];
        [self .view addSubview:blankView];
        [self.view bringSubviewToFront:blankView];
        transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"accountInput", nil];
        serve *addBank = [serve new];
        addBank.tagName = @"addBank";
        addBank.Delegate = self;
        [addBank saveBank:transaction];
        
        
    }
    
}
-(void)checkRoutingNumberService:(NSString*)RoutingString{
    serve *vBank = [serve new];
    vBank.tagName = @"validateBank";
    vBank.Delegate = self;
    
    [vBank ValidateBank:@"" routingNo:RoutingString];
}
// UITapGestureRecognizer
-(void) Tapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.name resignFirstResponder];
    [self.routing_number resignFirstResponder];
    [self.account_number resignFirstResponder];
}
#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{if (textField == self.routing_number || textField == self.account_number )
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
    if (textField==self.routing_number) {
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 9) {
            return NO;
        }
        else if ([textField.text stringByReplacingCharactersInRange:range withString:string].length == 9)
        {
            
            if (![self CheckRoutingNo:[NSString stringWithFormat:@"%@%@",textField.text, string]]) {
                //[self.view setUserInteractionEnabled:NO];
                
                UIAlertView*alert= [[UIAlertView alloc] initWithTitle:@"Routing number not valid" message:@"Enter a valid Routing number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] ;
                [alert setTag:2300];
                [alert show];
                self.routing_number.text=@"";
                
                return YES;
            }
            else{
                [self checkRoutingNumberService:[NSString stringWithFormat:@"%@%@",self.routing_number.text,string]];
            }
            //[self CheckRoutingNo:[NSString stringWithFormat:@"%@%@",textField.text, string]];
        }
    }
    else if (textField==self.account_number)
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
    
    if (textField == self.name )
    {
        if ([string isEqualToString:@""]) {
            if (!textField.text.length)
                return NO;
            if ([[textField.text stringByReplacingCharactersInRange:range withString:string]rangeOfString:@""].length)
                return NO;
        }
        
        if ([string isEqualToString:@" "]) {
            if ([textField.text rangeOfString:@" "].location!=NSNotFound) {
                return NO;
            }
        }
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag]==2300) {
        if (buttonIndex==0) {
            [self.routing_number becomeFirstResponder];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField==self.name) {
        NSArray*arr=[self.name.text componentsSeparatedByString:@" "];
        if ([arr count]==2) {
            self.name.text=[[arr objectAtIndex:0] capitalizedString];
            self.name.text=[self.name.text stringByAppendingString:[NSString stringWithFormat:@" %@",[[arr objectAtIndex:1] capitalizedString]]];
        }
        
    }
}
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    if ([tagName isEqualToString:@"validateBank"]) {
        
        NSMutableDictionary*dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        
        if ([[[dictResponse valueForKey:@"ValidateBankResult"] stringValue]isEqualToString:@"0"]) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Valid Bank Routing Number!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            self.routing_number.text=@"";
            
        }
        else
        {
            [self.add setEnabled:YES];
        }
        
    }
    else if([tagName isEqualToString:@"addBank"])
    {
        NSMutableDictionary *loginResult = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        ;
        NSDictionary *resultValue = [loginResult valueForKey:@"SaveBankAccountDetailsResult"];
        
        if([[resultValue valueForKey:@"Result"] isEqualToString:@"Your account details have been saved successfully."]){
            [blankView removeFromSuperview];
            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:@"Bank Account Submitted" message:@"Your bank information has been successfully submitted to Nooch. For security, we must verify that you own this account. In two business days, check your bank statement to find two deposits of less than $1 from Nooch Inc. Then return here, punch in the amounts, and tap 'Verify Account.'" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
          
            [showAlertMessage show];
            self.routing_number.text = @"";
            self.name .text = @"";
            self.account_number.text=@"";
           
            
//            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"ContactNumber"]) {
//                serve*serveOBJ=[serve new];
//                NSLog(@"Contact number %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"ContactNumber"]);
//                
//                [ serveOBJ SendSMSApi:[[NSUserDefaults standardUserDefaults] valueForKey:@"ContactNumber"] msg:@"You have added New Bank Account.Please verify it."];
//            }
            [[assist shared]setneedsReload:YES];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
