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
@property(nonatomic,strong) UISwitch *request_received_email;
@property(nonatomic,strong) UISwitch *request_received_push;
@property(nonatomic,strong) UISwitch *request_paid_email;
@property(nonatomic,strong) UISwitch *request_paid_push;
@property(nonatomic,strong) UISwitch *request_rejected_email;
@property(nonatomic,strong) UISwitch *request_rejected_push;
@property(nonatomic,strong) UISwitch *request_cancelled_email;
@property(nonatomic,strong) UISwitch *request_cancelled_push;
@property(nonatomic,strong) UITableView * transfers_table;
@property(nonatomic,strong) UITableView * request_table;
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

    self.transfers_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 26, 320, 145)];
    [self.transfers_table setDataSource:self];
    [self.transfers_table setDelegate:self];
    [self.transfers_table setUserInteractionEnabled:NO];
    [self.view addSubview:self.transfers_table];
    [self.transfers_table reloadData];
    
    self.request_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 203, 320, 199)];
    [self.request_table setDataSource:self];
    [self.request_table setDelegate:self];
    [self.request_table setUserInteractionEnabled:NO];
    [self.view addSubview:self.request_table];
    // [self.request_table reloadData];

    UILabel * glyphEmail_1 = [[UILabel alloc] initWithFrame:CGRectMake(180, 9, 50, 20)];
    [glyphEmail_1 setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphEmail_1 setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"]];
    [glyphEmail_1 setTextColor:kNoochGrayDark];
    [glyphEmail_1 setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:glyphEmail_1];

    UILabel * glyphPush_1 = [[UILabel alloc] initWithFrame:CGRectMake(260, 9, 50, 20)];
    [glyphPush_1 setFont:[UIFont fontWithName:@"FontAwesome" size:22]];
    [glyphPush_1 setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"]];
    [glyphPush_1 setTextColor:kNoochGrayDark];
    [glyphPush_1 setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:glyphPush_1];

    UILabel * glyphEmail_2 = [[UILabel alloc] initWithFrame:CGRectMake(180, 185, 50, 20)];
    [glyphEmail_2 setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphEmail_2 setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"]];
    [glyphEmail_2 setTextColor:kNoochGrayDark];
    [glyphEmail_2 setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:glyphEmail_2];

    UILabel * glyphPush_2 = [[UILabel alloc] initWithFrame:CGRectMake(260, 185, 50, 20)];
    [glyphPush_2 setFont:[UIFont fontWithName:@"FontAwesome" size:22]];
    [glyphPush_2 setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"]];
    [glyphPush_2 setTextColor:kNoochGrayDark];
    [glyphPush_2 setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:glyphPush_2];

    self.email_received = [[UISwitch alloc] initWithFrame:CGRectMake(180, 37, 40, 30)];
    self.email_received.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.email_received setOnTintColor:kNoochBlue];
    [self.email_received addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_received.tag = 101;

    self.push_received = [[UISwitch alloc] initWithFrame:CGRectMake(260, 37, 40, 30)];
    self.push_received.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.push_received setOnTintColor:kNoochGreen];
    [self.push_received addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.push_received.tag = 102;

    self.email_sent = [[UISwitch alloc] initWithFrame:CGRectMake(180, 87, 40, 30)];
    self.email_sent.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.email_sent setOnTintColor:kNoochBlue];
    [self.email_sent addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_sent.tag = 103;

    self.email_unclaimed = [[UISwitch alloc] initWithFrame:CGRectMake(180, 137, 40, 30)];
    self.email_unclaimed.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.email_unclaimed setOnTintColor:kNoochBlue];
    [self.email_unclaimed addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_unclaimed.tag = 104;

    self.request_received_email = [[UISwitch alloc] initWithFrame:CGRectMake(180, 214, 40, 30)];
    self.request_received_email.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_received_email setOnTintColor:kNoochBlue];
    [self.request_received_email addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_received_email.tag = 211;

    self.request_received_push = [[UISwitch alloc] initWithFrame:CGRectMake(260, 214, 40, 30)];
    self.request_received_push.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_received_push setOnTintColor:kNoochGreen];
    [self.request_received_push addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_received_push.tag = 212;

    self.request_paid_email = [[UISwitch alloc] initWithFrame:CGRectMake(180, 264, 40, 30)];
    self.request_paid_email.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_paid_email setOnTintColor:kNoochBlue];
    [self.request_paid_email addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_paid_email.tag = 221;

    self.request_paid_push = [[UISwitch alloc] initWithFrame:CGRectMake(260, 264, 40, 30)];
    self.request_paid_push.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_paid_push setOnTintColor:kNoochGreen];
    [self.request_paid_push addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_paid_push.tag = 222;

    self.request_rejected_email = [[UISwitch alloc] initWithFrame:CGRectMake(180, 314, 40, 30)];
    self.request_rejected_email.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_rejected_email setOnTintColor:kNoochBlue];
    [self.request_rejected_email addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_rejected_email.tag = 231;

    self.request_rejected_push = [[UISwitch alloc] initWithFrame:CGRectMake(260, 314, 40, 30)];
    self.request_rejected_push.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_rejected_push setOnTintColor:kNoochGreen];
    [self.request_rejected_push addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_rejected_push.tag = 232;

    self.request_cancelled_email = [[UISwitch alloc] initWithFrame:CGRectMake(180, 364, 40, 30)];
    self.request_cancelled_email.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_cancelled_email setOnTintColor:kNoochBlue];
    [self.request_cancelled_email addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_cancelled_email.tag = 241;

    self.request_cancelled_push = [[UISwitch alloc] initWithFrame:CGRectMake(260, 364, 40, 30)];
    self.request_cancelled_push.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.request_cancelled_push setOnTintColor:kNoochGreen];
    [self.request_cancelled_push addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.request_cancelled_push.tag = 242;

    [self.view addSubview:self.email_received];
    [self.view addSubview:self.push_received];
    [self.view addSubview:self.email_sent];
    [self.view addSubview:self.email_unclaimed];
    [self.view addSubview:self.request_received_email];
    [self.view addSubview:self.request_received_push];
    [self.view addSubview:self.request_paid_email];
    [self.view addSubview:self.request_paid_push];
    [self.view addSubview:self.request_rejected_email];
    [self.view addSubview:self.request_rejected_push];
    [self.view addSubview:self.request_cancelled_email];
    [self.view addSubview:self.request_cancelled_push];


    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Loading your settings...";
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
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
        case 101:
            servicePath = @"email";
            serviceType = @"email_received";
            [self setService];
            break;
        case 102:
            servicePath = @"push";
            serviceType = @"push_received";
            [self setService];
            break;
        case 103:
            servicePath = @"email";
            serviceType = @"email_sent";
            [self setService];
            break;
        case 104:
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
                             [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",
                             @"NoochToBank",@"BankToNooch",
                             [self.push_received isOn]?@"1":@"0",@"TransferReceived",
                             //[self.push_failure isOn]?@"1":@"0",@"TransferAttemptFailure",
                             nil];
    }
    else
    {
        transactionInput1 = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",
                             [self.email_received isOn]?@"1":@"0",@"EmailTransferReceived",
                             [self.email_sent isOn]?@"1":@"0",@"EmailTransferSent",
                             //[self.email_failure isOn]?@"1":@"0",@"EmailTransferAttemptFailure",
                             [self.email_unclaimed isOn]?@"1":@"0",
                             @"TransferUnclaimed",@"NoochToBankRequested",@"NoochToBankCompleted",@"BankToNoochCompleted",@"BankToNoochRequested",nil];
    }

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"setSettings";
    [serveOBJ MemberNotificationSettings:transactionInput1 type:servicePath];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.transfers_table)
    {
        return 3;
    }
    if (tableView == self.request_table)
    {
        return 4;
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
        cell.indentationLevel = 1;
        cell.indentationWidth = 10;
        [cell.textLabel setFont:kNoochFontMed];
    }

    [cell.textLabel setStyleClass:@"table_view_cell_textlabel_2"];

    if (tableView == self.transfers_table)
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
    
    if (tableView == self.request_table)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Request Received";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Request Paid";
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Request Rejected";
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = @"Request Cancelled";
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"getSettings"])
    {
        NSError * error;
        dictInput = [NSJSONSerialization
                   JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                   options:kNilOptions
                   error:&error];
        NSLog(@"%@",dictInput);
        
        [self.hud hide:YES];
        
        // Transfer Received
        if ([[dictInput objectForKey:@"EmailTransferReceived"]boolValue]) {
            [self.email_received setOn:YES];
        }
        else {
            [self.email_received setOn:NO];
        }
        if ([[dictInput objectForKey:@"TransferReceived"]boolValue]) {
            [self.push_received setOn:YES];
        }
        else {
            [self.push_received setOn:NO];
        }

        // Transfer Sent
        if ([[dictInput objectForKey:@"EmailTransferSent"]boolValue]) {
            [self.email_sent setOn:YES];
        }
        else {
            [self.email_sent setOn:NO];
        }

        // Transfer Unclaimed
        if ([[dictInput objectForKey:@"TransferUnclaimed"]boolValue]) {
            [self.email_unclaimed setOn:YES];
        }
        else {
            [self.email_unclaimed setOn:NO];
        }


        // Request Received
        if ([[dictInput objectForKey:@"TransferAttemptFailure"]boolValue]) {
            //[self.push_failure setOn:YES];
        }
        else {
            //[self.push_failure setOn:NO];
        }
        [self.request_received_email setOn:YES];
        [self.request_paid_email setOn:YES];
        [self.request_rejected_email setOn:YES];
        [self.request_cancelled_email setOn:YES];
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
