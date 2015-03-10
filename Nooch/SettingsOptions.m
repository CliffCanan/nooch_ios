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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:NSLocalizedString(@"Settings_ScrnTitle", @"Settings Screen Title")];
    self.screenName = @"Settings Main Screen";
    [self getBankInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ARTrackingManager trackEvent:@"Settings_viewDidAppear"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
        [introText setText:NSLocalizedString(@"Settings_NoBankIntroTxt", @"Settings Screen instruction text when no bank is attached")];
        [introText setTextAlignment:NSTextAlignmentCenter];
        [introText setStyleId:@"settings_introText"];
        [self.view addSubview:introText];
    }
    else
    {
        isBankAttached = YES;
        if ([self.view.subviews containsObject:glyph_noBank])
        {
            [glyph_noBank removeFromSuperview];
        }
    }

    [self.navigationItem setHidesBackButton:YES];

    UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.21) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem * menu1 = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu1];

    [self.navigationItem setTitle:@"Settings"];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    [self.view setStyleClass:@"background_gray"];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 250, 25)];
    [title setStyleClass:@"refer_header"];
    [title setText:NSLocalizedString(@"Settings_LinkedBankHdr", @"Settings Screen header - 'Linked Bank Account'")];
    [self.view addSubview:title];

    link_bank = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [link_bank setFrame:CGRectMake(0, 123, 0, 0)];
    if (isBankAttached)
    {
        [link_bank setTitle:NSLocalizedString(@"Settings_LinkNewBnk", @"Settings Screen button text when bank is attached") forState:UIControlStateNormal];
    }
    else
    {
        [link_bank setTitle:NSLocalizedString(@"Settings_LinkBnkNow", @"Settings Screen button text when bank is NOT attached") forState:UIControlStateNormal];
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
    
    menu = [[UITableView alloc] initWithFrame:CGRectMake(-1, 194, 322, 200) style:UITableViewStylePlain];
    [menu setStyleId:@"settings"];
    menu.layer.borderColor = Rgb2UIColor(188, 190, 192, 0.85).CGColor;
    menu.layer.borderWidth = 1;
    [menu setDelegate:self];
    [menu setDataSource:self];
    [menu setScrollEnabled:NO];
    [self.view addSubview:menu];
    
    self.logout = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logout setTitle:NSLocalizedString(@"Settings_SignOutBtn", @"Settings Screen 'Sign Out' button text") forState:UIControlStateNormal];
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

    // PUSH NOTIFICATIONS
    BOOL notifsEnabled;
    // Try to use the newer isRegisteredForRemoteNotifications otherwise use the enabledRemoteNotificationTypes.
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        notifsEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        notifsEnabled = types & UIRemoteNotificationTypeAlert;
    }

    if (!notifsEnabled)
    {
        // PUSH NOTIFICATION REGISTRATION
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            // Register for push in iOS 8.
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            // Register for push in iOS 7 and under.
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                                                   UIUserNotificationTypeSound |
                                                                                   UIUserNotificationTypeAlert)];
        }
    }
}

-(void)attach_bank
{
    if (isBankAttached)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_AttchBnkAlrtTitle", @"Settings Screen attach a new bank Alert Title")
                                                     message:NSLocalizedString(@"Settings_AttchBnkAlrtBody", @"Settings Screen attach a new bank Alert Body Text")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Settings_AttchBnkAlrtYesBtn", @"Settings Screen attach a new bank Alert Btn - 'Yes - Replace'")
                                           otherButtonTitles:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text"), nil];
        [av setTag:32];
        [av show];
    }
    else
    {
        [ARTrackingManager trackEvent:@"Settings_TappedAddBankGoToKnoxWbvw"];
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
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_RemoveBnkAlrtTitle1", @"Settings Screen remove bank Alert Title")
                                                 message:NSLocalizedString(@"Settings_RemoveBnkAlrtBody1", @"Settings Screen remove bank Alert Body Text")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Settings_RemoveBnkAlrtYesBtn", @"Settings Screen remove bank Alert Btn - 'Yes - Remove'")
                                       otherButtonTitles:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text"), nil];
    [av setTag:2];
    [av show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        UIView * selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = Rgb2UIColor(63, 171, 245, .45);
        cell.selectedBackgroundView = selectionColor;
    }
    
    UILabel *title = [UILabel new];
    [title setStyleClass:@"settings_table_label"];

    UILabel *glyph = [UILabel new];
    [glyph setStyleClass:@"table_glyph"];

    if (indexPath.row == 0) {
        title.text = NSLocalizedString(@"Settings_TableRowLbl1", @"Settings Screen table label row 1 - 'Profile Info'");
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"]];
    }
    else if (indexPath.row == 1) {
        title.text = NSLocalizedString(@"Settings_TableRowLbl2", @"Settings Screen table label row 2 - 'Security Settings'");
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    }
    else if (indexPath.row == 2) {
        title.text = NSLocalizedString(@"Settings_TableRowLbl3", @"Settings Screen table label row 3 - 'Security Settings'");
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bell"]];
    }
    else if(indexPath.row == 3) {
        title.text = NSLocalizedString(@"Settings_TableRowLbl4", @"Settings Screen table label row 4 - 'Social Settings'");
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

    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
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

-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
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
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_SignOutAlrtTitle", @"Settings Screen sign out Alert Title")//@"Sign Out"
                                                 message:NSLocalizedString(@"Settings_SignOutAlrtBody", @"Settings Screen sign out Alert Body Text")//@"Are you sure you want to sign out?"
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text")
                                       otherButtonTitles:NSLocalizedString(@"Settings_SignOutAlrtBtn", @"Settings Screen sign out Alert Btn - 'I'm Sure'"), nil];//@"I'm Sure"
    [av setTag:15];
    [av show];
}

-(void)Error:(NSError *)Error
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"ConnectionErrorAlrtTitle", @"Any screen Connection Error Alert Text")
                          message:NSLocalizedString(@"ConnectionErrorAlrtBody", @"Any screen Connection Error Alert Body Text")
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
        if ([dictResponse valueForKey:@"Result"])
        {
            if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Success."])
            {
                [blankView removeFromSuperview];
                [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasPendingItems"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Pending_count"];

                [nav_ctrl performSelector:@selector(disable)];
                Register *reg = [Register new];
                [self.navigationController pushViewController:reg animated:YES];
                me = [core new];
                [ARProfileManager clearProfile];
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

        if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Bank account deleted successfully"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_RemoveBnkAlrtTitle2", @"Settings Screen 'Bank Removed' Alert Title")
                                                         message:NSLocalizedString(@"Settings_RemoveBnkAlrtBody2", @"Settings Screen 'Bank Removed' Alert Body Text")
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];

            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"IsBankAvailable"];
            
            [introText setHidden:NO];
            [glyph_noBank setHidden:NO];
            
            isBankAttached = NO;
            
            [linked_background removeFromSuperview];
            [bank_image removeFromSuperview];
            [unlink_account removeFromSuperview];
        }
        else if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"No active bank account found for this user."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_NoBnkFndAlrtTitle", @"Settings Screen 'Account Not Found' Alert Title")//@"Account Not Found"
                                                         message:[dictResponse valueForKey:@"Result"]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                         message:[dictResponse valueForKey:@"Result"]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
        
        [self getBankInfo];
    }
    
    else if ([tagName isEqualToString:@"knox_bank_info"])
    {
        NSError * error;
        NSMutableDictionary *dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        //NSLog(@"knox info is: %@",dictResponse);

        if (![[dictResponse valueForKey:@"AccountName"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"BankImageURL"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"BankName"] isKindOfClass:[NSNull class]])
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"IsBankAvailable"];
            isBankAttached = YES;

            [introText setHidden:YES];
            [glyph_noBank setHidden:YES];

            linked_background = [UIView new];
            [linked_background setStyleId:@"account_background"];

            if ([[UIScreen mainScreen] bounds].size.height == 480)
            {
                [scroll addSubview:linked_background];
            }
            else {
                [self.view addSubview:linked_background];
            }

            UILabel * glyph_lock = [[UILabel alloc] initWithFrame:CGRectMake(73, 6, 13, 32)];
            [glyph_lock setBackgroundColor:[UIColor clearColor]];
            [glyph_lock setTextAlignment:NSTextAlignmentLeft];
            [glyph_lock setFont:[UIFont fontWithName:@"FontAwesome" size:13]];
            [glyph_lock setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
            [glyph_lock setTextColor:kNoochGreen];
            [linked_background addSubview:glyph_lock];

            bank_image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 49, 48)];
            bank_image.contentMode = UIViewContentModeScaleToFill;
            [bank_image sd_setImageWithURL:[NSURL URLWithString:[dictResponse valueForKey:@"BankImageURL"]] placeholderImage:[UIImage imageNamed:@"bank.png"]];
            [bank_image setFrame:CGRectMake(10, 7, 50, 50)];
            bank_image.layer.cornerRadius = 5;
            bank_image.clipsToBounds = YES;
            [linked_background addSubview:bank_image];

            bank_name = [UILabel new];
            [bank_name setStyleId:@"linked_account_name"];
            [bank_name setText:[dictResponse valueForKey:@"BankName"]];
            [linked_background addSubview:bank_name];

            lastFour_label = [UILabel new];
            [lastFour_label setStyleId:@"linked_account_last4"];
            [lastFour_label setText:[NSString stringWithFormat:@"**** **** **** %@",[dictResponse valueForKey:@"AccountName"]  ]];
            [linked_background addSubview:lastFour_label];

            unlink_account = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [unlink_account setStyleId:@"remove_account"];
            [unlink_account setTitle:NSLocalizedString(@"Settings_EditTxt", @"Settings 'Edit' Txt") forState:UIControlStateNormal];
            [unlink_account addTarget:self action:@selector(edit_attached_bank) forControlEvents:UIControlEventTouchUpInside];
            [linked_background addSubview:unlink_account];

            [ARProfileManager registerString:@"Bank_Name" withValue:[dictResponse valueForKey:@"BankName"]];
            [ARProfileManager registerString:@"Bank_Logo" withValue:[dictResponse valueForKey:[dictResponse valueForKey:@"BankImageURL"]]];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"IsBankAvailable"];

            [introText setHidden:NO];
            [glyph_noBank setHidden:NO];

            isBankAttached = NO;

            [linked_background removeFromSuperview];
            [bank_image removeFromSuperview];
            [unlink_account removeFromSuperview];

            [ARProfileManager clearVariable:@"Bank_Name"];
            [ARProfileManager clearVariable:@"Bank_Logo"];
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
            [ARTrackingManager trackEvent:@"Settings_TappedAddBankGoToKnoxWbvw_ReplaceBnk"];
            knoxWeb *knox = [knoxWeb new];
            [self.navigationController pushViewController:knox animated:YES];
        }
        return;
    }

    if (alertView.tag == 15)
    {
        if (buttonIndex == 1)
        {
            [ARTrackingManager trackEvent:@"UserLoggedOutManually"];

            blankView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
            [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];

            UIActivityIndicatorView * actv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2) - 10, 40, 40)];
            [actv startAnimating];
            [blankView addSubview:actv];

            [self.view addSubview:blankView];
            [self.view bringSubviewToFront:blankView];

            [[assist shared] setisloggedout:YES];

            [timer invalidate];
            timer = nil;

            serve *  serveOBJ = [serve new];
            serveOBJ.Delegate = self;
            serveOBJ.tagName = @"logout";
            [serveOBJ LogOutRequest:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end