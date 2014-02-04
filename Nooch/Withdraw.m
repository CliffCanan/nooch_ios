//
//  Withdraw.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "Withdraw.h"
#import "Home.h"
#import "TransferPIN.h"
#import "ECSlidingViewController.h"
#import "NewBank.h"
@interface Withdraw ()
@property(nonatomic,strong)NSArray*banks;
@property(nonatomic,strong) UIButton *withdraw;
@property(nonatomic,strong) UITextField *amount;
@property(nonatomic) NSMutableString *amnt;
@end

@implementation Withdraw

- (id)initWithData:(NSArray *)bankinfo
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.banks = [bankinfo mutableCopy];
    }
    return self;
}
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
    [self.navigationItem setTitle:@"Withdraw Funds"];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    self.amnt = [@"" mutableCopy];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 0, 0)];
    [info setStyleClass:@"instruction_text"];
    [info setStyleClass:@"wd_dep_instruction"];
    [info setText:@"Enter the amount you wish to"];
    [self.view addSubview:info];
    
    UILabel *deposit = [UILabel new];
    [deposit setText:@"withdraw from"];
    [deposit setStyleId:@"wd_dep_withdrawtext"];
    [self.view addSubview:deposit];
    
    UILabel *into = [UILabel new];
    [into setStyleClass:@"wd_instruction_account"];
    [into setText:@"your Nooch account"];
    [self.view addSubview:into];
    
    self.amount = [[UITextField alloc] initWithFrame:CGRectMake(60, 100, 200, 60)];
    [self.amount setDelegate:self]; [self.amount setPlaceholder:@"$ 0.00"];
    [self.amount setKeyboardType:UIKeyboardTypeNumberPad];
    self.amount.tag=1;
    [self.amount setDelegate:self];
    [self.amount setStyleClass:@"wd_dep_amountfield"];
    [self.view addSubview:self.amount];
    
    UILabel *accnts = [UILabel new];
    [accnts setText:@"YOUR BANK ACCOUNTS"];
    [accnts setStyleClass:@"wd_dep_tableheader"];
    [self.view addSubview:accnts];
    
    UIButton *add_icon = [UIButton new];
    [add_icon setTitle:@"" forState:UIControlStateNormal];
    [add_icon addTarget:self action:@selector(addFundCall:) forControlEvents:UIControlEventTouchUpInside];
    [add_icon setStyleClass:@"wd_dep_addicon"];
    
    [self.view addSubview:add_icon];
    
    UITableView *banks = [UITableView new];
    [banks setStyleClass:@"wd_dep_tableview"];
    [banks setStyleClass:@"raised_view"];
    [banks setDataSource:self]; [banks setDelegate:self];
    [self.view addSubview:banks];
    [banks reloadData];
    
    self.withdraw = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.withdraw setFrame:CGRectMake(0, 200, 0, 0)];
    [self.withdraw setTitle:@"Withdraw Funds" forState:UIControlStateNormal];
    [self.withdraw setStyleClass:@"button_green"];
    [self.withdraw setStyleClass:@"wd_dep_button"];
    [self.withdraw addTarget:self action:@selector(withdraw_amount) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.withdraw];
    
    [self.amount becomeFirstResponder];
}

- (void) withdraw_amount
{
    NSMutableDictionary *transaction = [[NSMutableDictionary alloc] init];
    [transaction setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"MemberId"];
    
    [transaction setObject:[user objectForKey:@"firstName"]forKey:@"FirstName"];
    [transaction setObject:[user objectForKey:@"lastName"]forKey:@"LastName"];
    // [transaction setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"FirstName"];
    //[transaction setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"FirstName"];
    float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
    //  float input_amount = [[[self.amount text] substringFromIndex:2] floatValue];
    TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"withdrawfund" amount: input_amount];
    [self.navigationController pushViewController:pin animated:YES];
    
    
}
#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1) {
        //        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //        [formatter setNumberStyle:NSNumberFormatterNoStyle];
        //        [formatter setPositiveFormat:@"$ ##.##"];
        //        [formatter setLenient:YES];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setGeneratesDecimalNumbers:YES];
        [formatter setUsesGroupingSeparator:YES];
        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        
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
        if (maths != 0) {
            [textField setText:[formatter stringFromNumber:[NSNumber numberWithFloat:maths]]];
        } else {
            [textField setText:@""];
        }
        
        
        return NO;
    }
    return YES;
}
-(void)addFundCall:(id)sender
{
    NewBank *add_bank = [NewBank new];
    [self.navigationController pushViewController:add_bank animated:NO];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
    }
    
    //    UILabel *banktxt = [UILabel new];
    //    [banktxt setStyleClass:@"wd_dep_banklabel"];
    //    [banktxt setText:@"Account ending in 3456"];
    //    [cell.contentView addSubview:banktxt];
    
    NSDictionary *bank = [self.banks objectAtIndex:0];
    UILabel *banktxt = [UILabel new];
    [banktxt setStyleClass:@"wd_dep_banklabel"];
    [banktxt setText:[NSString stringWithFormat:@"Account ending in %@",[bank valueForKey:@"BankAcctNumber"]]];
    [cell.contentView addSubview:banktxt];
    
    
    // NSString*lastdigit=[NSString stringWithFormat:@"XXXX%@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length]-4]];
    // cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",[bank objectForKey:@"BankName"],lastdigit];
    //cell.textLabel.font=[UIFont fontWithName:@"Arial" size:12.0f];
    NSArray* bytedata = [bank valueForKey:@"BankPicture"];
    //XXXXXXXX2222
    unsigned c = bytedata.count;
    uint8_t *bytes = malloc(sizeof(*bytes) * c);
    
    unsigned i;
    for (i = 0; i < c; i++)
    {
        NSString *str = [bytedata objectAtIndex:i];
        int byte = [str intValue];
        bytes[i] = (uint8_t)byte;
    }
    
    NSData *datos = [NSData dataWithBytes:bytes length:c];
    UIImageView*img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tickR.png"]];
    img.frame=CGRectMake(10, 10, 40 , 40);
    [cell.contentView addSubview:img];
    
    img.image = [UIImage imageWithData:datos];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
