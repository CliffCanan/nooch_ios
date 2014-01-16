//
//  Deposit.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "Deposit.h"
#import "Home.h"
#import "TransferPIN.h"
#import "ECSlidingViewController.h"
@interface Deposit ()
@property (nonatomic,strong) UIButton *deposit;
@property(nonatomic,strong)NSArray*banks;
@property (nonatomic,strong) UITextField *amount;

@end

@implementation Deposit
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
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    

    [self.navigationItem setTitle:@"Add Funds"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 0, 0)];
    [info setStyleClass:@"instruction_text"];
    [info setStyleClass:@"wd_dep_instruction"];
    [info setText:@"Enter the amount you wish to"];
    [self.view addSubview:info];
    
    UILabel *deposit = [UILabel new];
    [deposit setText:@"deposit into"];
    [deposit setStyleId:@"wd_dep_deposittext"];
    [self.view addSubview:deposit];
    
    UILabel *into = [UILabel new];
    [into setStyleClass:@"dep_instruction_account"];
    [into setText:@"your Nooch account"];
    [self.view addSubview:into];
    
    self.amount = [[UITextField alloc] initWithFrame:CGRectMake(60, 100, 200, 60)];
    [self.amount setDelegate:self]; [self.amount setPlaceholder:@"$ 0.00"];
    [self.amount setKeyboardType:UIKeyboardTypeNumberPad];
    [self.amount setStyleClass:@"wd_dep_amountfield"];
    [self.view addSubview:self.amount];
    
    UILabel *accnts = [UILabel new];
    [accnts setText:@"YOUR BANK ACCOUNTS"];
    [accnts setStyleClass:@"wd_dep_tableheader"];
    [self.view addSubview:accnts];
    
    UIButton *add_icon = [UIButton new];
    [add_icon setTitle:@"ADD Fund" forState:UIControlStateNormal];
    [add_icon setStyleClass:@"wd_dep_addicon"];
    
    [self.view addSubview:add_icon];
    
    self.deposit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.deposit setFrame:CGRectMake(0, 300, 300, 50)];
    [self.deposit setTitle:@"Submit" forState:UIControlStateNormal];
    [self.deposit setStyleClass:@"button_green"];
    [self.deposit setStyleClass:@"wd_dep_button"];
    [self.deposit addTarget:self action:@selector(deposit_amount) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deposit];
    UITableView *banks = [UITableView new];
    [banks setStyleClass:@"wd_dep_tableview"];
    [banks setStyleClass:@"raised_view"];
    [banks setDelegate:self]; [banks setDataSource:self];
    [self.view addSubview:banks];
    [banks reloadData];
    //class: wd_dep_bankicon
    //class wd_dep_banklabel
    
    [self.amount becomeFirstResponder];
}

- (void) deposit_amount
{
    
    NSMutableDictionary *transaction = [[NSMutableDictionary alloc] init];
    [transaction setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"MemberId"];
    
    [transaction setObject:[user objectForKey:@"firstName"]forKey:@"FirstName"];
    [transaction setObject:[user objectForKey:@"lastName"]forKey:@"LastName"];
    // [transaction setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"FirstName"];
    //[transaction setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] forKey:@"FirstName"];
    
  //  float input_amount = [[[self.amount text] substringFromIndex:2] floatValue];
    TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"addfund" amount: [self.amount.text floatValue]];
    [self.navigationController pushViewController:pin animated:YES];

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
    UILabel *banktxt = [UILabel new];
    [banktxt setStyleClass:@"wd_dep_banklabel"];
    [banktxt setText:@"Account ending in 3456"];
    [cell.contentView addSubview:banktxt];
    
     NSDictionary *bank = [self.banks objectAtIndex:0];
    // NSString*lastdigit=[NSString stringWithFormat:@"XXXX%@",[[bank objectForKey:@"BankAcctNumber"] substringFromIndex:[[bank objectForKey:@"BankAcctNumber"] length]-4]];
    // cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",[bank objectForKey:@"BankName"],lastdigit];
    // cell.textLabel.font=[UIFont fontWithName:@"Arial" size:12.0f];
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
    return 70.0;
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
