//
//  DonationAmount.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "DonationAmount.h"
#import "Home.h"
#import "TransferPIN.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
@interface DonationAmount ()
@property(nonatomic,strong) NSDictionary *receiver;
@property(nonatomic,strong) UITextField *amount;
@property(nonatomic,strong) UITextField *memo;
@property(nonatomic,strong) UIButton *camera;
@property(nonatomic,strong) UIButton *send;
@property(nonatomic) NSMutableString *amnt;
@property(nonatomic) BOOL decimals;
@end

@implementation DonationAmount

- (id)initWithReceiver:(NSDictionary *)receiver
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.receiver = [receiver copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    

    [self.navigationItem setTitle:@"How Much"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.amnt = [@"" mutableCopy];
    self.decimals = YES;
    
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 200)];
    [back setStyleClass:@"raised_view"];
    [back setStyleClass:@"how_much_mainbox"];
    [back setBackgroundColor:[UIColor whiteColor]]; back.layer.cornerRadius = 5;
    [self.view addSubview:back];
    
    UIView *bar = [UIView new];
    [bar setStyleId:@"barbackground_purp"];
    [self.view addSubview:bar];
    
    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    [to_label setTextAlignment:NSTextAlignmentCenter];
    [to_label setText:[NSString stringWithFormat:@"%@",[self.receiver valueForKey:@"OrganizationName"]]];
    [to_label setStyleId:@"nonprofit_howmuch_orgname"];
    [self.view addSubview:to_label];
    
    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 60, 60)];
    [pic setImage:[UIImage imageNamed:@"4KforCancer.png"]];
    [pic setStyleId:@"nonprofit_orgpic"];
    NSLog(@"%@",self.receiver);
    [pic setImageWithURL:[NSURL URLWithString:[self.receiver valueForKey:@"PhotoIcon"]]
         placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    

   // [pic setStyleCSS:@"background-image : url(4KforCancer.png)"];
    [self.view addSubview:pic];
    
    self.amount = [[UITextField alloc] initWithFrame:CGRectMake(30, 40, 260, 80)];
    [self.amount setPlaceholder:@"$ 0.00"];
    [self.amount setDelegate:self]; [self.amount setTag:1];
    [self.amount setKeyboardType:UIKeyboardTypeNumberPad];
    [self.amount setStyleId:@"nonprofit_amountfield"];
    [self.view addSubview:self.amount];
    
    self.memo = [[UITextField alloc] initWithFrame:CGRectMake(10, 120, 260, 40)];
    [self.memo setTextColor:[UIColor whiteColor]]; [self.memo setBackgroundColor:kNoochGrayLight];
    [self.memo setTextAlignment:NSTextAlignmentCenter]; [self.memo setPlaceholder:@"Enter a memo"];
    [self.memo setFont:[UIFont systemFontOfSize:16]]; [self.memo setDelegate:self]; [self.memo setTag:2];
    [self.memo setKeyboardType:UIKeyboardTypeDefault];
    //[self.view addSubview:self.memo];
    
    self.camera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.camera setFrame:CGRectMake(270, 120, 40, 40)]; [self.camera setBackgroundColor:kNoochGrayDark];
    
    self.send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.send setFrame:CGRectMake(160, 160, 150, 50)]; [self.send setBackgroundColor:kNoochGreen];
    [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; [self.send setTitle:@"Donate" forState:UIControlStateNormal];
    [self.send addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    [self.send setStyleId:@"nonprofit_donatebutton"];
    [self.view addSubview:self.send];
    [self.send setEnabled:YES];
    
    UIButton *dedicaiton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dedicaiton setBackgroundImage:[UIImage imageNamed:@"memo-nonprofits"] forState:UIControlStateNormal];
    [dedicaiton setTitle:@"" forState:UIControlStateNormal];
    [dedicaiton setFrame:CGRectMake(30, 170, 40, 40)];
    [dedicaiton setStyleId:@"nonprofit_dedication_icon"];
    [dedicaiton addTarget:self action:@selector(dedicate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dedicaiton];
    
    UILabel *ded = [UILabel new];
    [ded setText:@"+ Dedication"];
    [ded setStyleId:@"nonprofit_dedication_label"];
    [self.view addSubview:ded];
    
    UIButton *five = [UIButton new]; UIButton *ten = [UIButton new]; UIButton *twentyfive = [UIButton new]; UIButton *fifty = [UIButton new];
    [five setStyleClass:@"nonprofit_quicktapbuttons"]; [ten setStyleClass:@"nonprofit_quicktapbuttons"]; [twentyfive setStyleClass:@"nonprofit_quicktapbuttons"]; [fifty setStyleClass:@"nonprofit_quicktapbuttons"];
    [five setStyleId:@"nonprofit_quicktapbuttons_5"];
    [ten setStyleId:@"nonprofit_quicktapbuttons_10"];
    [twentyfive setStyleId:@"nonprofit_quicktapbuttons_25"];
    [fifty setStyleId:@"nonprofit_quicktapbuttons_50"];
    
    [five addTarget:self action:@selector(five_dollars) forControlEvents:UIControlEventTouchUpInside];
    [ten addTarget:self action:@selector(ten_dolalrs) forControlEvents:UIControlEventTouchUpInside];
    [twentyfive addTarget:self action:@selector(twentyfive_dollars) forControlEvents:UIControlEventTouchUpInside];
    [fifty addTarget:self action:@selector(fifty_dollars) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:five];
    [self.view addSubview:ten];
    [self.view addSubview:twentyfive];
    [self.view addSubview:fifty];
    
    [self.amount becomeFirstResponder];
    //set default string memo
    Donation_memo=@"In Honor Of ";
}

- (void) five_dollars
{
    [self.send setEnabled:YES];
    self.amount.text = @"$5.00";
    self.amnt = [@"500" mutableCopy];
}

- (void) ten_dolalrs
{
    [self.send setEnabled:YES];
    self.amount.text = @"$10.00";
    self.amnt = [@"1000" mutableCopy];
}

- (void) twentyfive_dollars
{
    [self.send setEnabled:YES];
    self.amount.text = @"$25.00";
    self.amnt = [@"2500" mutableCopy];
}

- (void) fifty_dollars
{
    [self.send setEnabled:YES];
    self.amount.text = @"$50.00";
    self.amnt = [@"5000" mutableCopy];
}
-(void)completed_or_pending:(UISegmentedControl*)segment{
    if ([segment selectedSegmentIndex]==0) {
        Donation_memo=@"In Honor Of ";
    }
    else
    {
        Donation_memo=@"In Memory Of ";
    }
}
-(void)add_Dedication{
    if ([txtDedicate.text length]>0) {
        [self.amount becomeFirstResponder];
        Donation_memo=[Donation_memo stringByAppendingString:txtDedicate.text];
        [UIView beginAnimations:@"bucketsOff" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        dedicateView.alpha=0;
        [UIView commitAnimations];
        
        [dedicateView removeFromSuperview];
    }
   
}
-(void)cancel_dedication{
    Donation_memo=@"";
    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    dedicateView.alpha=0;
    [UIView commitAnimations];

    [dedicateView removeFromSuperview];
    [self.amount becomeFirstResponder];
}
- (void) dedicate
{
    [self.amount resignFirstResponder];
    [dedicateView removeFromSuperview];
    dedicateView=[[UIView alloc] initWithFrame:CGRectMake(10, 64, 300, 220)];
    dedicateView.backgroundColor=[UIColor whiteColor];
    dedicateView.alpha=0;
    [self.view addSubview:dedicateView];
    
    
    //Segment control
    NSArray *seg_items = @[@"In Honor Of",@"In Memory Of"];
    UISegmentedControl *completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [completed_pending setStyleId:@"dedicate_segcontrol"];
    [completed_pending addTarget:self action:@selector(completed_or_pending:) forControlEvents:UIControlEventValueChanged];
    [dedicateView addSubview:completed_pending];
    [completed_pending setSelectedSegmentIndex:0];
    
    //Textbox
    txtDedicate = [[UITextView alloc] initWithFrame:CGRectMake(10,45, 280, 100)];
    [txtDedicate setText:[NSString stringWithFormat:@"%@",@"Type your dedication here..."]];
    [txtDedicate setBackgroundColor:[UIColor clearColor]];
    txtDedicate.textColor=[UIColor grayColor];
    //[txtDedicate becomeFirstResponder];
    txtDedicate.layer.borderColor=[[UIColor grayColor]CGColor];
    txtDedicate.layer.borderWidth=2.0f;
    txtDedicate.font=[UIFont systemFontOfSize:15.0f];
    txtDedicate.layer.cornerRadius=5.0f;
    txtDedicate.delegate=self;
    [txtDedicate setStyleClass:@"dedicate_textview"];
    [dedicateView addSubview:txtDedicate];
    
    //Cancel Button
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setFrame:CGRectMake(0, 170, 40, 40)];
    [cancel setStyleClass:@"dedication_buttons_cancel_dedication"];
    [cancel addTarget:self action:@selector(cancel_dedication) forControlEvents:UIControlEventTouchUpInside];
    [dedicateView addSubview:cancel];
    
    //Add Dedication
    UIButton *dedicaiton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [dedicaiton setTitle:@"Add Dedication" forState:UIControlStateNormal];
    [dedicaiton setFrame:CGRectMake(150, 170, 40, 40)];
    [dedicaiton setStyleClass:@"dedication_buttons_add"];
    
    [dedicaiton addTarget:self action:@selector(add_Dedication) forControlEvents:UIControlEventTouchUpInside];
    [dedicateView addSubview:dedicaiton];
    
    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
     dedicateView.alpha=1;
  
    [UIView commitAnimations];
    
    
   }
- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text=@"";
}
- (void) donate
{
    if ([[self.amount text] length] < 3) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:@"Please enter a valid amount" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    NSMutableDictionary *transaction = [self.receiver mutableCopy];
    [transaction setObject:Donation_memo forKey:@"memo"];
    float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
    TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"donation" amount:input_amount];
    [self.navigationController pushViewController:pin animated:YES];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setGeneratesDecimalNumbers:YES];
        [formatter setUsesGroupingSeparator:YES];
        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        //        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        [formatter setGeneratesDecimalNumbers:YES];
//        [formatter setUsesGroupingSeparator:YES];
//        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
//        [formatter setGroupingSeparator:groupingSeparator];
//        [formatter setGroupingSize:3];
        
        if([string length] == 0){ //backspace
            if ([self.amnt length] > 0) {
                self.amnt = [[self.amnt substringToIndex:[self.amnt length]-1] mutableCopy];
            }
        }else{
            NSString *temp = [self.amnt stringByAppendingString:string];
            self.amnt = [temp mutableCopy];
        }
        float maths = [self.amnt floatValue];
        maths /= 100;
        if (maths > 1000) {
            self.amnt = [[self.amnt substringToIndex:[self.amnt length]-1] mutableCopy];
            return NO;
        }
        
        [textField setText:[formatter stringFromNumber:[NSNumber numberWithFloat:maths]]];
        
        return NO;
    }
    
    if (textField.tag == 2) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 25) ? NO : YES;
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
