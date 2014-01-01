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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.nooch_transfers = [[UITableView alloc] initWithFrame:CGRectMake(0, 22, 320, 145)];
    [self.nooch_transfers setDataSource:self]; [self.nooch_transfers setDelegate:self];
    [self.nooch_transfers setUserInteractionEnabled:NO];
    [self.view addSubview:self.nooch_transfers]; [self.nooch_transfers reloadData];
    
    self.email_received = [[UISwitch alloc] initWithFrame:CGRectMake(180, 30, 40, 30)];
    
    self.push_received = [[UISwitch alloc] initWithFrame:CGRectMake(260, 30, 40, 30)];
    
    self.email_sent = [[UISwitch alloc] initWithFrame:CGRectMake(180, 80, 40, 30)];
    
    self.email_unclaimed = [[UISwitch alloc] initWithFrame:CGRectMake(180, 130, 40, 30)];
    
    self.bank_transfers = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, 250)];
    [self.bank_transfers setDataSource:self]; [self.bank_transfers setDelegate:self];
    [self.bank_transfers setUserInteractionEnabled:NO];
    [self.view addSubview:self.bank_transfers]; [self.bank_transfers reloadData];
    
    self.email_withdraw_requested = [[UISwitch alloc] initWithFrame:CGRectMake(180, 210, 40, 30)];
    
    self.email_withdraw_submitted = [[UISwitch alloc] initWithFrame:CGRectMake(180, 260, 40, 30)];
    
    self.push_withdraw_submitted = [[UISwitch alloc] initWithFrame:CGRectMake(260, 260, 40, 30)];
    
    self.email_deposit_requested = [[UISwitch alloc] initWithFrame:CGRectMake(180, 310, 40, 30)];
    
    self.email_deposit_completed = [[UISwitch alloc] initWithFrame:CGRectMake(180, 360, 40, 30)];
    
    self.push_deposit_completed = [[UISwitch alloc] initWithFrame:CGRectMake(260, 360, 40, 30)];
    
    self.email_failure = [[UISwitch alloc] initWithFrame:CGRectMake(180, 410, 40, 30)];
    
    self.push_failure = [[UISwitch alloc] initWithFrame:CGRectMake(260, 410, 40, 30)];
    
    [self.view addSubview:self.email_received]; [self.view addSubview:self.push_received]; [self.view addSubview:self.email_sent]; [self.view addSubview:self.email_unclaimed];
    [self.view addSubview:self.email_withdraw_requested]; [self.view addSubview:self.email_withdraw_submitted]; [self.view addSubview:self.push_withdraw_submitted];
    [self.view addSubview:self.email_deposit_requested]; [self.view addSubview:self.email_deposit_completed]; [self.view addSubview:self.push_deposit_completed];
    [self.view addSubview:self.email_failure]; [self.view addSubview:self.push_failure];
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
