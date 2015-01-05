//  SettingsOptions.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.

#import "SettingsOptions.h"
#import "Home.h"
#import "Register.h"
#import "ProfileInfo.h"
#import "PINSettings.h"
#import "NotificationSettings.h"
#import "ECSlidingViewController.h"
#import "knoxWeb.h"
#import "UIImageView+WebCache.h"
#import "fbConnect.h"
@interface SettingsOptions (){
    UILabel * introText;
    UILabel * bank_name;
    UILabel * lastFour_label;
    UIImageView * bank_image;
    UITableView * menu;
    UIView * linked_background;
    UIButton * unlink_account;
    UIButton * link_bank;
    UILabel *glyph_noBank;
    UIScrollView * scroll;
}
@property(atomic,weak)UIButton *logout;


@end

@implementation SettingsOptions

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"Settings"];
    self.screenName = @"Settings Main Screen";
    [self getBankInfo];
}

-(void)getBankInfo
{
    serve * serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"knox_bank_info";
    [serveOBJ GetKnoxBankAccountDetails];
}

-(void)RemoveKnoxBankAccount
{
    serve * serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"RemoveKnoxBankAccount";
    [serveOBJ RemoveKnoxBankAccount];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // isBankAttached = NO;

    if ( ![[[NSUserDefaults standardUserDefaults] objectForKey:@"IsBankAvailable"]isEqualToString:@"1"])
    {
        isBankAttached = NO;

        glyph_noBank = [UILabel new];

        [glyph_noBank setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation"]];
        [glyph_noBank setFrame:CGRectMake(180, 17, 22, 22)];
        [glyph_noBank setStyleId:@"glyph_noBank_sidebar"];
        [glyph_noBank setStyleId:@"glyph_noBank_settings"];
        [self.view addSubview:glyph_noBank];

        introText = [UILabel new];
        [introText setFrame:CGRectMake(10, 38, 300, 76)];
        introText.numberOfLines = 0;
        [introText setText:@"Attach a bank account to send or receive payments. Just select your bank, login to your online banking, and you're done."];
        [introText setTextAlignment:NSTextAlignmentCenter];
        [introText setStyleId:@"settings_introText"];
        [self.view addSubview:introText];
    }
    else {
        isBankAttached = YES;
        [glyph_noBank removeFromSuperview];
    }

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .26);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    
    NSDictionary * titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSShadowAttributeName: shadowNavText};
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    [self.navigationItem setHidesBackButton:YES];

    UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.21) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem * menu1 = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu1];

	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Settings"];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    [self.view setStyleClass:@"background_gray"];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 250, 25)];
    [title setStyleClass:@"refer_header"];
    [title setText:@"Linked Bank Account"];
    [self.view addSubview:title];

    link_bank = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [link_bank setFrame:CGRectMake(0, 123, 0, 0)];
    if (isBankAttached) {
        [link_bank setTitle:@"Link a New Bank" forState:UIControlStateNormal];
    }
    else {
        [link_bank setTitle:@"Link a Bank Now" forState:UIControlStateNormal];
    }
    [link_bank setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    link_bank.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

    UILabel * glyph = [UILabel new];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph setFrame:CGRectMake(25, 9, 30, 30)];
    glyph.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"]
                                                                 attributes:textAttributes1];
    [glyph setTextColor:[UIColor whiteColor]];
    [link_bank addSubview:glyph];
    [link_bank addTarget:self action:@selector(attach_bank) forControlEvents:UIControlEventTouchUpInside];
    [link_bank setStyleClass:@"button_blue"];
    [link_bank setStyleId:@"link_new_account"];
    [link_bank setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:link_bank];
    
    menu = [UITableView new];
    [menu setStyleId:@"settings"];
    menu.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    menu.layer.borderWidth = 1;
    [menu setDelegate:self];
    [menu setDataSource:self];
    [menu setScrollEnabled:NO];
    [self.view addSubview:menu];
    
    self.logout = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logout setTitle:@"Sign Out" forState:UIControlStateNormal];
    [self.logout setTitleShadowColor:Rgb2UIColor(30, 31, 33, 0.24) forState:UIControlStateNormal];
    self.logout.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    UILabel * glyphLogout = [UILabel new];
    [glyphLogout setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [glyphLogout setFrame:CGRectMake(60, 7, 30, 30)];
    [glyphLogout setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-sign-out"]];
    [glyphLogout setTextColor:[UIColor whiteColor]];

    [self.logout addSubview:glyphLogout];
    [self.logout addTarget:self action:@selector(sign_out) forControlEvents:UIControlEventTouchUpInside];
    [self.logout setStyleClass:@"button_gray"];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [self.logout setStyleId:@"button_signout_4"];
    }
    else {
        [self.logout setStyleId:@"button_signout"];
    }

    [self.view addSubview: self.logout];


    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [scroll setDelegate:self];
        [scroll setContentSize:CGSizeMake(320, 545)];
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
            [scroll addSubview:subview];
        }
        [self.view addSubview:scroll];
    }
}

-(void)attach_bank
{
    if (isBankAttached)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Attach New Bank Account" message:@"You can only have one bank account attached at a time.  If you link a new account, that will replace your current bank account. This cannot be undone.\n\nAre you sure you want to replace this bank account?" delegate:self cancelButtonTitle:@"Yes - Replace" otherButtonTitles:@"Cancel", nil];
        [av setTag:32];
        [av show];
    }
    else
    {
        knoxWeb *knox = [knoxWeb new];
        [self.navigationController pushViewController:knox animated:YES];
    }
}

-(void)edit_attached_bank
{
    [unlink_account removeFromSuperview];
    [unlink_account setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-minus-circle"] forState:UIControlStateNormal];
    [unlink_account setStyleId:@"remove_account_glyph"];
    [unlink_account addTarget:self action:@selector(remove_attached_bank) forControlEvents:UIControlEventTouchUpInside];
    [linked_background addSubview:unlink_account];
}

-(void)remove_attached_bank
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Remove Bank Account" message:@"If you remove this bank account, you will not be able to send or receive money. This cannot be undone.\n\nAre you sure you want to remove this bank account?" delegate:self cancelButtonTitle:@"Yes - Remove" otherButtonTitles:@"Cancel", nil];
    [av setTag:2];
    [av show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
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
    
    UILabel *title = [UILabel new];
    [title setStyleClass:@"settings_table_label"];

    UILabel *glyph = [UILabel new];
    [glyph setStyleClass:@"table_glyph"];

    if (indexPath.row == 0) {
        title.text = @"Profile Info";
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"]];
    }
    else if (indexPath.row == 1) {
        title.text = @"Security Settings";
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    }
    else if (indexPath.row == 2) {
        title.text = @"Notification Settings";
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bell"]];
    }
    else if(indexPath.row == 3) {
        title.text = @"Social Settings";
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook"]];
    }

    arrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrow setStyleClass:@"table_arrow"];
    [arrow setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"] forState:UIControlStateNormal];
    [arrow setTitleShadowColor:Rgb2UIColor(3, 5, 8, 0.1) forState:UIControlStateNormal];
    arrow.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);

    [cell.contentView addSubview:title];
    [cell.contentView addSubview:glyph];
    [cell.contentView addSubview:arrow];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self profile];
    }
    else if (indexPath.row == 1) {
        [self pin];
    }
    else if(indexPath.row == 2){
        [self notifications];
    }
    else if(indexPath.row == 3){
        [self connect_fb];
    }
}

- (void)profile
{
    isProfileOpenFromSideBar = NO;
    sentFromHomeScrn = NO;
    ProfileInfo * info = [ProfileInfo new];
    [self performSelector:@selector(navigate_to:) withObject:info afterDelay:0.01];
}

- (void)pin
{
    PINSettings * pin = [PINSettings new];
    [self performSelector:@selector(navigate_to:) withObject:pin afterDelay:0.01];
}

- (void)notifications
{
    NotificationSettings * notes = [NotificationSettings new];
    [self performSelector:@selector(navigate_to:) withObject:notes afterDelay:0.01];
}
- (void)connect_fb
{
    fbConnect * fb = [fbConnect new];
    [self performSelector:@selector(navigate_to:) withObject:fb afterDelay:0.01];
}

- (void) navigate_to:(id)view
{
    [self.navigationController pushViewController:view animated:YES];
}

- (void)sign_out
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sign Out"
                                                 message:@"Are you sure you want to sign out?"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"I'm Sure", nil];
    [av setTag:15];
    [av show];
}

-(void)Error:(NSError *)Error{
  
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
    
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"logout"])
    {
        NSError* error;
        NSMutableDictionary*dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        if([dictResponse valueForKey:@"Result"])
        {
            if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Success."]) {
                
                [blankView removeFromSuperview];
                [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];

                [nav_ctrl performSelector:@selector(disable)];
                Register *reg = [Register new];
                [self.navigationController pushViewController:reg animated:YES];
                me = [core new];
            }
        }
    }
    
    else if ([tagName isEqualToString:@"RemoveKnoxBankAccount"])
    {
        NSError* error;
        NSMutableDictionary*dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Bank account deleted successfully."]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Bank Removed" message:@"This bank account is no longer linked to your Nooch account. To make or receive payments, you must link a new bank account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }
        else if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"No active bank account found for this user."]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Account Not Found" message:[dictResponse valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Nooch" message:[dictResponse valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }
        
        [self getBankInfo];
    }
    
    else if ([tagName isEqualToString:@"knox_bank_info"])
    {
        NSError * error;
        NSMutableDictionary*dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        NSLog(@"dicResponse is: %@",dictResponse);

        UILabel * glyph_shield = [[UILabel alloc] initWithFrame:CGRectMake(73, 6, 13, 32)];
        [glyph_shield setBackgroundColor:[UIColor clearColor]];
        [glyph_shield setTextAlignment:NSTextAlignmentLeft];
        [glyph_shield setFont:[UIFont fontWithName:@"FontAwesome" size:13]];
        [glyph_shield setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];


        if (![[dictResponse valueForKey:@"AccountName"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"BankImageURL"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"BankName"] isKindOfClass:[NSNull class]])
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"IsBankAvailable"];
            isBankAttached = YES;

            if (isBankAttached)
            {
                [introText removeFromSuperview];
                [linked_background removeFromSuperview];
                [bank_image removeFromSuperview];;
                [unlink_account removeFromSuperview];

                linked_background = [UIView new];
                [linked_background setStyleId:@"account_background"];

                if ([[UIScreen mainScreen] bounds].size.height == 480)
                {
                    [scroll addSubview:linked_background];
                }
                else {
                    [self.view addSubview:linked_background];
                }

                [glyph_shield setTextColor:kNoochGreen];
                [linked_background addSubview:glyph_shield];
                
                bank_image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 49, 48)];
                bank_image.contentMode = UIViewContentModeScaleToFill;
                [linked_background addSubview:bank_image];
                
                bank_name = [UILabel new];
                [bank_name setStyleId:@"linked_account_name"];
                [bank_name setText:@"Bank"];
                [linked_background addSubview:bank_name];
                
                lastFour_label = [UILabel new];
                [lastFour_label setStyleId:@"linked_account_last4"];
                [linked_background addSubview:lastFour_label];

                unlink_account = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [unlink_account setStyleId:@"remove_account"];
                [unlink_account setTitle:@"Edit" forState:UIControlStateNormal];
                [unlink_account addTarget:self action:@selector(edit_attached_bank) forControlEvents:UIControlEventTouchUpInside];
                [linked_background addSubview:unlink_account];
            }

            [bank_image sd_setImageWithURL:[NSURL URLWithString:[dictResponse valueForKey:@"BankImageURL"]] placeholderImage:[UIImage imageNamed:@"bank.png"]];
            [bank_image setFrame:CGRectMake(10, 7, 50, 50)];
            bank_image.layer.cornerRadius = 5;
            bank_image.clipsToBounds = YES;
            [bank_name setText:[dictResponse valueForKey:@"BankName"]];
            [lastFour_label setText:[NSString stringWithFormat:@"**** **** **** %@",[dictResponse valueForKey:@"AccountName"]  ]];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"IsBankAvailable"];
           
            isBankAttached = NO;
            if (!isBankAttached)
            {
                [self.view addSubview:introText];

                [linked_background removeFromSuperview];
                [bank_image removeFromSuperview];;
                [unlink_account removeFromSuperview];
            }
        }
    }
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2)
    {
        if (buttonIndex == 0)
        {
            //proceed to unlink
            [self RemoveKnoxBankAccount];
        }
        return;
    }
    
    if (alertView.tag == 32)
    {
        if (buttonIndex == 0)
        {
            knoxWeb *knox = [knoxWeb new];
            [self.navigationController pushViewController:knox animated:YES];
        }
        return;
    }

    if (alertView.tag == 15)
    {
        if (buttonIndex == 1)
        {
            blankView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
            [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];

            UIActivityIndicatorView * actv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2) - 10, 40, 40)];
            [actv startAnimating];
            [blankView addSubview:actv];

            [self.view addSubview:blankView];
            [self.view bringSubviewToFront:blankView];
            [[assist shared]setisloggedout:YES];
            [timer invalidate];
            timer = nil;

            serve *  serveOBJ = [serve new];
            serveOBJ.Delegate = self;
            serveOBJ.tagName = @"logout";
            [serveOBJ LogOutRequest:[[NSUserDefaults standardUserDefaults ]valueForKey:@"MemberId"]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end