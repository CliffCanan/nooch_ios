//
//  NotificationSettings.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import "NotificationSettings.h"
#import "Home.h"

@interface NotificationSettings ()
@property(nonatomic,strong) UISwitch *email_received;
@property(nonatomic,strong) UISwitch *push_received;
@property(nonatomic,strong) UISwitch *email_sent;
@property(nonatomic,strong) UISwitch *email_unclaimed;
@property(nonatomic,strong) UISwitch *email_failure;
@property(nonatomic,strong) UISwitch *push_failure;
@property(nonatomic,strong) UITableView *nooch_transfers;
@property(nonatomic,strong) UITableView *bank_transfers;
@property(nonatomic,strong) MBProgressHUD *hud;
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.trackedViewName = @"Notification Settings Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Notification Settings"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.nooch_transfers = [[UITableView alloc] initWithFrame:CGRectMake(0, 26, 320, 145)];
    [self.nooch_transfers setDataSource:self];
    [self.nooch_transfers setDelegate:self];
    [self.nooch_transfers setUserInteractionEnabled:NO];
    [self.view addSubview:self.nooch_transfers];
    [self.nooch_transfers reloadData];

    UILabel * glyphEmail = [[UILabel alloc] initWithFrame:CGRectMake(180, 9, 50, 20)];
    [glyphEmail setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphEmail setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"]];
    [glyphEmail setTextColor:kNoochGrayDark];
    [glyphEmail setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:glyphEmail];

    UILabel * glyphPush = [[UILabel alloc] initWithFrame:CGRectMake(260, 9, 50, 20)];
    [glyphPush setFont:[UIFont fontWithName:@"FontAwesome" size:22]];
    [glyphPush setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"]];
    [glyphPush setTextColor:kNoochGrayDark];
    [glyphPush setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:glyphPush];
    
    self.email_received = [[UISwitch alloc] initWithFrame:CGRectMake(180, 38, 40, 30)];
    self.email_received.tag = 12000;
    [self.email_received addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.push_received = [[UISwitch alloc] initWithFrame:CGRectMake(260, 38, 40, 30)];
    self.push_received.tag = 12001;
    [self.push_received addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.email_sent = [[UISwitch alloc] initWithFrame:CGRectMake(180, 88, 40, 30)];
    self.email_sent.tag = 12002;
    [self.email_sent addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];

    self.email_unclaimed = [[UISwitch alloc] initWithFrame:CGRectMake(180, 138, 40, 30)];
    self.email_unclaimed.tag = 12003;
    [self.email_unclaimed addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];

    [self.push_failure addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.email_received];
    [self.view addSubview:self.push_received];
    [self.view addSubview:self.email_sent];
    [self.view addSubview:self.email_unclaimed];
    [self.view addSubview:self.email_failure];
    [self.view addSubview:self.push_failure];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.delegate = self;
    self.hud.labelText = @"Loading your settings";
    [self.hud show:YES];

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"getSettings";
    [serveOBJ MemberNotificationSettingsInput];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [scroll setDelegate:self];
        [scroll setContentSize:CGSizeMake(320, 530)];
        for (UIView *subview in self.view.subviews)
        {
            [subview removeFromSuperview];
            [scroll addSubview:subview];
        }
        [self.view addSubview:scroll];
    }
}

-(void)changeSwitch:(UISwitch*)switchRef
{
    int tag = switchRef.tag;
    switch (tag)
    {
        case 12000:
            servicePath = @"email";
            serviceType = @"email_received";
            [self setService];
            break;
        case 12001:
            servicePath = @"push";
            serviceType = @"push_received";
            [self setService];
            break;
        case 12002:
            servicePath = @"email";
            serviceType = @"email_sent";
            
            [self setService];
            break;
        case 12003:
            servicePath = @"email";
            serviceType = @"email_unclaimed";
            [self setService];
            break;
        default:
            break;
    }
}

-(void)setService
{
    NSDictionary *transactionInput1;

    if ([servicePath isEqualToString:@"push"])
    {
        transactionInput1 = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",@"NoochToBank",@"BankToNooch",[self.push_received isOn]?@"1":@"0",@"TransferReceived",[self.push_failure isOn]?@"1":@"0",@"TransferAttemptFailure", nil];
    }
    else
    {
        transactionInput1 = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[self.email_received isOn]?@"1":@"0",@"EmailTransferReceived",[self.email_sent isOn]?@"1":@"0",@"EmailTransferSent",[self.email_failure isOn]?@"1":@"0",@"EmailTransferAttemptFailure",[self.email_unclaimed isOn]?@"1":@"0",@"TransferUnclaimed",@"NoochToBankRequested",@"NoochToBankCompleted",@"BankToNoochCompleted",@"BankToNoochRequested",nil];
    }

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"setSettings";
    [serveOBJ MemberNotificationSettings:transactionInput1 type:servicePath];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.nooch_transfers)
    {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kNoochBlue];
        //[cell.detailTextLabel setTextColor:kNoochGrayLight];
        cell.indentationLevel = 1; cell.indentationWidth = 10;
        [cell.textLabel setFont:kNoochFontMed];
    }

    [cell.textLabel setStyleClass:@"table_view_cell_textlabel_2"];

    if (tableView == self.nooch_transfers)
    {
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
    if ([tagName isEqualToString:@"getSettings"])
    {
        NSError* error;
        dictInput = [NSJSONSerialization
                   JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                   options:kNilOptions
                   error:&error];
        NSLog(@"%@",dictInput);
        
        [self.hud hide:YES];
        
        if ([[dictInput objectForKey:@"TransferUnclaimed"]boolValue]) {
            [self.email_unclaimed setOn:YES];
        }
        else
        {
            [self.email_unclaimed setOn:NO];
            
        }
        if ([[dictInput objectForKey:@"TransferReceived"]boolValue]) {
            [self.push_received setOn:YES];
        }
        else
        {
            [self.push_received setOn:NO];
            
        }
        if ([[dictInput objectForKey:@"TransferSent"]boolValue]) {
            
        }
        
        if ([[dictInput objectForKey:@"TransferAttemptFailure"]boolValue]) {
            [self.push_failure setOn:YES];
        }
        else
        {
            [self.push_failure setOn:NO];
            
        }
        
        if ([[dictInput objectForKey:@"EmailTransferAttemptFailure"]boolValue]) {
            [self.email_failure setOn:YES];
            
        }
        else
        {
            [self.email_failure setOn:NO];
            
        }
        if ([[dictInput objectForKey:@"EmailTransferReceived"]boolValue]) {
            [self.email_received setOn:YES];
        }
        else
        {
            [self.email_received setOn:NO];
            
        }
        if ([[dictInput objectForKey:@"EmailTransferSent"]boolValue]) {
            [self.email_sent setOn:YES];
            
        }
        else
        {
            [self.email_sent setOn:NO];
            
        }
    }
    else if ([tagName isEqualToString:@"setSettings"])
    {
        NSError * error;
        dictSettings = [NSJSONSerialization
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
