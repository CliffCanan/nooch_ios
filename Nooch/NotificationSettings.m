//
//  NotificationSettings.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "NotificationSettings.h"
#import "Home.h"

@interface NotificationSettings ()
@property(nonatomic,strong)UISwitch *email_received;
@property(nonatomic,strong)UISwitch *push_received;
@property(nonatomic,strong)UISwitch *email_sent;
@property(nonatomic,strong)UISwitch *email_unclaimed;
@property(nonatomic,strong)UISwitch *email_withdraw_requested;
@property(nonatomic,strong)UISwitch *email_withdraw_submitted;
@property(nonatomic,strong)UISwitch *push_withdraw_submitted;
@property(nonatomic,strong)UISwitch *email_deposit_requested;
@property(nonatomic,strong)UISwitch *email_deposit_completed;
@property(nonatomic,strong)UISwitch *push_deposit_completed;
@property(nonatomic,strong)UISwitch *email_failure;
@property(nonatomic,strong)UISwitch *push_failure;
@property(nonatomic,strong)UITableView *nooch_transfers;
@property(nonatomic,strong)UITableView *bank_transfers;
@end

@implementation NotificationSettings

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
    [self.navigationItem setTitle:@"Notification Settings"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.nooch_transfers = [[UITableView alloc] initWithFrame:CGRectMake(0, 18, 320, 145)];
    [self.nooch_transfers setDataSource:self]; [self.nooch_transfers setDelegate:self];
    [self.nooch_transfers setUserInteractionEnabled:NO];
    [self.view addSubview:self.nooch_transfers]; [self.nooch_transfers reloadData];
    
    UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(180, 10, 50, 20)];
    [email setText:@"Email"]; [email setFont:[UIFont fontWithName:@"Roboto-Thin" size:14]];
    [email setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:email];
    
    UILabel *push = [[UILabel alloc] initWithFrame:CGRectMake(260, 10, 50, 20)];
    [push setTextAlignment:NSTextAlignmentCenter]; [push setText:@"Push"];
    [push setFont:[UIFont fontWithName:@"Roboto-Thin" size:14]];
    [self.view addSubview:push];
    
    self.email_received = [[UISwitch alloc] initWithFrame:CGRectMake(180, 30, 40, 30)];
    self.email_received.tag=12000;
   
    [self.email_received addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.push_received = [[UISwitch alloc] initWithFrame:CGRectMake(260, 30, 40, 30)];
    self.push_received.tag=12001;
  
    [self.push_received addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_sent = [[UISwitch alloc] initWithFrame:CGRectMake(180, 80, 40, 30)];
    self.email_sent.tag=12002;
 
    [self.email_sent addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_unclaimed = [[UISwitch alloc] initWithFrame:CGRectMake(180, 130, 40, 30)];
     self.email_unclaimed.tag=12003;
    [ self.email_unclaimed addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.bank_transfers = [[UITableView alloc] initWithFrame:CGRectMake(0, 196, 320, 250)];
    [self.bank_transfers setDataSource:self]; [self.bank_transfers setDelegate:self];
    [self.bank_transfers setUserInteractionEnabled:NO];
    [self.view addSubview:self.bank_transfers]; [self.bank_transfers reloadData];
    
    self.email_withdraw_requested = [[UISwitch alloc] initWithFrame:CGRectMake(180, 210, 40, 30)];
    self.email_withdraw_requested.tag=12004;
  
    [self.email_withdraw_requested addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_withdraw_submitted = [[UISwitch alloc] initWithFrame:CGRectMake(180, 260, 40, 30)];
    self.email_withdraw_submitted.tag=12005;
  

    [self.email_withdraw_submitted addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.push_withdraw_submitted = [[UISwitch alloc] initWithFrame:CGRectMake(260, 260, 40, 30)];
    self.push_withdraw_submitted.tag=12006;
       [self.push_withdraw_submitted addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_deposit_requested = [[UISwitch alloc] initWithFrame:CGRectMake(180, 310, 40, 30)];
    self.email_deposit_requested.tag=12007;
   
    [self.email_deposit_requested addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_deposit_completed = [[UISwitch alloc] initWithFrame:CGRectMake(180, 360, 40, 30)];
     self.email_deposit_completed.tag=12008;
    
    [ self.email_deposit_completed addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.push_deposit_completed = [[UISwitch alloc] initWithFrame:CGRectMake(260, 360, 40, 30)];
    self.push_deposit_completed.tag=12009;
    
    [self.push_deposit_completed addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_failure = [[UISwitch alloc] initWithFrame:CGRectMake(180, 410, 40, 30)];
    self.email_failure.tag=12010;
   
    [self.email_failure addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.push_failure = [[UISwitch alloc] initWithFrame:CGRectMake(260, 410, 40, 30)];
    self.push_failure.tag=12011;
    
    [self.push_failure addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.email_received]; [self.view addSubview:self.push_received]; [self.view addSubview:self.email_sent]; [self.view addSubview:self.email_unclaimed];
    [self.view addSubview:self.email_withdraw_requested]; [self.view addSubview:self.email_withdraw_submitted]; [self.view addSubview:self.push_withdraw_submitted];
    [self.view addSubview:self.email_deposit_requested]; [self.view addSubview:self.email_deposit_completed]; [self.view addSubview:self.push_deposit_completed];
    [self.view addSubview:self.email_failure]; [self.view addSubview:self.push_failure];
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"getSettings";
    [serveOBJ MemberNotificationSettingsInput];
    
}
-(void)changeSwitch:(UISwitch*)switchRef{
   
       int tag=switchRef.tag;
    switch (tag) {
        case 12000:
            servicePath=@"email";
             serviceType=@"email_received";
            [self setService];
            break;
        case 12001:
             servicePath=@"push";
         serviceType=@"push_received";
            [self setService];
            break;
        case 12002:
             servicePath=@"email";
            serviceType=@"email_sent";

            [self setService];
            break;
        case 12003:
             servicePath=@"email";
            serviceType=@"email_unclaimed";
            [self setService];
            break;
        case 12004:
             servicePath=@"email";
            serviceType=@"email_withdraw_requested";

            [self setService];
            break;
        case 12005:
             servicePath=@"email";
             serviceType=@"email_withdraw_submitted";
            [self setService];
            break;
        case 12006:
             servicePath=@"push";
           serviceType=@"push_withdraw_submitted";
            [self setService];
            break;
        case 12007:
             servicePath=@"email";
            serviceType=@"email_deposit_requested";

            [self setService];
            break;
        case 12008:
             servicePath=@"email";
             serviceType=@"email_deposit_completed";
            [self setService];
            break;
        case 12009:
             servicePath=@"push";
            serviceType=@"push_deposit_completed";
            [self setService];
            break;
        case 12010:
             servicePath=@"email";
            serviceType=@"email_failure";
            [self setService];
            break;
        case 12011:
             servicePath=@"push";
            serviceType=@"push_failure";
            [self setService];
            break;
           
            

        default:
            break;
    }
}
-(void)setService
{
   
    NSDictionary *transactionInput1;
    if ([servicePath isEqualToString:@"push"]) {
       
    
        NSLog(@"%hhd",[self.push_withdraw_submitted isOn]);
//      transactionInput1=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[self.push_withdraw_submitted isOn]?@"1":@"0",@"NoochToBank",[self.push_deposit_completed isOn]?@"1":@"0",@"BankToNooch",[self.push_received isOn]?@"1":@"0",@"TransferReceived",[self.push_failure isOn]?@"1":@"0",@"TransferAttemptFailure", nil];
        transactionInput1=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[self.push_withdraw_submitted isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"NoochToBank",[self.push_deposit_completed isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"BankToNooch",[self.push_received isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"TransferReceived",[self.push_failure isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"TransferAttemptFailure", nil];
        
    }
    else
    {
        
        transactionInput1=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[self.email_received isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"EmailTransferReceived",[self.email_sent isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"EmailTransferSent",[self.email_failure isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"EmailTransferAttemptFailure",[self.email_unclaimed isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"TransferUnclaimed", [self.email_withdraw_requested isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"TransferUnclaimed",[self.email_withdraw_submitted isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"NoochToBankCompleted",[self.email_deposit_completed isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"BankToNoochCompleted",[self.email_deposit_requested isOn]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"BankToNoochRequested",nil];

    
        
//        transactionInput1=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[self.email_received isOn]?1:0,@"EmailTransferReceived",[self.email_sent isOn]?1:0,@"EmailTransferSent",[self.email_failure isOn]?1:0,@"EmailTransferAttemptFailure",[self.email_unclaimed isOn]?1:0,@"TransferUnclaimed", [self.email_withdraw_requested isOn]?@"true":@"false",@"TransferUnclaimed",[self.email_withdraw_submitted isOn]?1:0,@"NoochToBankCompleted",[self.email_deposit_completed isOn]?1:0,@"BankToNoochCompleted",[self.email_deposit_requested isOn]?@"true":@"false",@"BankToNoochRequested",nil];
//    
        
             //   transactionInput1=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[self.email_received isOn],@"EmailTransferReceived",[self.email_sent isOn],@"EmailTransferSent",[self.email_failure isOn],@"EmailTransferAttemptFailure",[self.email_unclaimed isOn],@"TransferUnclaimed", [self.email_withdraw_requested isOn],@"TransferUnclaimed",[self.email_withdraw_submitted isOn],@"NoochToBankCompleted",[self.email_deposit_completed isOn],@"BankToNoochCompleted",[self.email_deposit_requested isOn],@"BankToNoochRequested",nil];
        
        
            }
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"setSettings";
    [serveOBJ MemberNotificationSettings:transactionInput1 type:servicePath];

    
      }
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.nooch_transfers) {
        return 3;
    }
    else if(tableView == self.bank_transfers) {
        return 5;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kNoochBlue];
        //[cell.detailTextLabel setTextColor:kNoochGrayLight];
        cell.indentationLevel = 1; cell.indentationWidth = 10;
        [cell.textLabel setFont:kNoochFontMed];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*cell.textLabel.textColor = [UIColor colorWithRed:51./255.
         green:153./255.
         blue:204./255.
         alpha:1.0];*/
    }
    [cell.textLabel setStyleClass:@"table_view_cell_textlabel_2"];
    if (tableView == self.nooch_transfers) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Transfer Received";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Transfer Sent";
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Transfer Unclaimed";
        }
    }
    else if (tableView == self.bank_transfers) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Withdraw Requested";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Withdraw Submitted";
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Deposit Requested";
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = @"Deposit Completed";
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = @"Transfer Failure";
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50.0;
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"getSettings"]) {
        NSError* error;
        dictInput=[NSJSONSerialization
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];
        NSLog(@"%@",dictInput);
        
        
        if ([[dictInput objectForKey:@"BankToNooch"]boolValue]) {
            [self.push_deposit_completed setOn:YES];
        }
        if ([[dictInput objectForKey:@"TransferUnclaimed"]boolValue]) {
            [self.email_unclaimed setOn:YES];
        }
        if ([[dictInput objectForKey:@"TransferReceived"]boolValue]) {
            [self.push_received setOn:YES];
        }
        if ([[dictInput objectForKey:@"TransferSent"]boolValue]) {
          //  [self.push setOn:YES];

            
        }if ([[dictInput objectForKey:@"TransferAttemptFailure"]boolValue]) {
            [self.push_failure setOn:YES];
        }
        if ([[dictInput objectForKey:@"EmailTransferAttemptFailure"]boolValue]) {
            [self.email_failure setOn:YES];
            
        }

        if ([[dictInput objectForKey:@"NoochToBankRequested"]boolValue]) {
            [self.email_withdraw_requested setOn:YES];
        }
        if ([[dictInput objectForKey:@"NoochToBankCompleted"]boolValue]) {
            [self.email_withdraw_submitted setOn:YES];
        }
        if ([[dictInput objectForKey:@"NoochToBank"]boolValue]) {
            [self.push_withdraw_submitted setOn:YES];
            
        }if ([[dictInput objectForKey:@"BankToNoochCompleted"]boolValue]) {
            [self.email_deposit_completed setOn:YES];
            
        }if ([[dictInput objectForKey:@"BankToNoochRequested"]boolValue]) {
             [self.email_deposit_requested setOn:YES];
        }
            if ([[dictInput objectForKey:@"EmailTransferReceived"]boolValue]) {
             [self.email_received setOn:YES];
        }
        if ([[dictInput objectForKey:@"EmailTransferSent"]boolValue]) {
            [self.email_sent setOn:YES];

        }
           }
    else if ([tagName isEqualToString:@"setSettings"])
    {
        NSError* error;
        dictSettings=[NSJSONSerialization
                   JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                   options:kNilOptions
                   error:&error];
        NSLog(@"%@",dictSettings);

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
