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

    if ((isKnoxOn && ![user boolForKey:@"IsKnoxBankAvailable"]) ||
        (isSynapseOn && ![user boolForKey:@"IsSynapseBankAvailable"]))
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
    [glyph setFrame:CGRectMake(26, 9, 30, 30)];
    [glyph setTextAlignment:NSTextAlignmentCenter];
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
    [self checkAndRegisterPushNotifs];
}

-(void)checkAndRegisterPushNotifs
{
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
    // 1. IS USER SUSPENDED?
    if ([[assist shared] getSuspended])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Suspended  \xF0\x9F\x98\xA7"
                                                        message:@"Your account has been suspended pending a review. Please email support@nooch.com if you believe this was a mistake and we will be glad to help."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Contact Support", nil];
        [alert setTag:10];
        [alert show];
        return;
    }

    // 2. IS USER's PHONE VERIFIED?
    else if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Blame The Lawyers"
                                                        message:@"To keep Nooch safe, we ask all users to verify a phone number before sending money.\n\nIf you've already added your phone number, just respond 'Go' to the text message we sent."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    // 3. HAS USER COMPLETED & VERIFIED PROFILE INFO? (EMAIL, PHONE)
    if (![[assist shared] isProfileCompleteAndValidated])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Help Us Keep Nooch Safe"
                                                        message:@"Please take 1 minute to verify your identity by completing your Nooch profile (just 4 fields)."
                                                       delegate:self
                                              cancelButtonTitle:@"Later"
                                              otherButtonTitles:@"Go Now", nil];
        [alert setTag:41];
        [alert show];
        return;
    }

    // 4. DOES USER ALREADY HAVE A BANK ATTACHED?
    else if (isBankAttached)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_AttchBnkAlrtTitle", @"Settings Screen attach a new bank Alert Title")
                                                     message:NSLocalizedString(@"Settings_AttchBnkAlrtBody", @"Settings Screen attach a new bank Alert Body Text")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Settings_AttchBnkAlrtYesBtn", @"Settings Screen attach a new bank Alert Btn - 'Yes - Replace'")
                                           otherButtonTitles:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text"), nil];
        [av setTag:11];
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

#pragma mark - Table Handling
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
    else if (indexPath.row == 3) {
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
    NSString * knoxOnOff = [[ARPowerHookManager getValueForHookById:@"knox_OnOff"] lowercaseString];
    NSString * SynapseOnOff = [[ARPowerHookManager getValueForHookById:@"synps_OnOff"] lowercaseString];

    serve * getBankInfo = [serve new];
    getBankInfo.Delegate = self;

    if ([knoxOnOff isEqualToString:@"on"])
    {
        getBankInfo.tagName = @"knox_bank_info";
        [getBankInfo GetKnoxBankAccountDetails];
        isKnoxOn = YES;
        return;
    }
    else {
        isKnoxOn = NO;
    }

    if ([SynapseOnOff isEqualToString:@"on"])
    {
        getBankInfo.tagName = @"synapse_bank_info";
        [getBankInfo GetSynapseBankAccountDetails];
        isSynapseOn = YES;
    }
    else
    {
        isSynapseOn = NO;
    }
}

-(void)RemoveBankAccount
{
    NSString * knoxOnOff = [ARPowerHookManager getValueForHookById:@"knox_OnOff"];
    NSString * SynapseOnOff = [ARPowerHookManager getValueForHookById:@"synps_OnOff"];
    
    serve * serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"RemoveBankAccount";
    
    if ([knoxOnOff isEqualToString:@"on"])
    {
        [serveOBJ RemoveKnoxBankAccount];
    }
    
    else if ([SynapseOnOff isEqualToString:@"on"])
    {
        [serveOBJ RemoveSynapseBankAccount];
    }
}

- (void)profile
{
    isProfileOpenFromSideBar = NO;
    sentFromHomeScrn = NO;
    isFromTransDetails = NO;
    isFromSettingsOptions = YES;

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

- (void)navigate_to:(id)view
{
    [self.navigationController pushViewController:view animated:YES];
}

- (void)sign_out
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_SignOutAlrtTitle", @"Settings Screen sign out Alert Title")
                                                 message:NSLocalizedString(@"Settings_SignOutAlrtBody", @"Settings Screen sign out Alert Body Text")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text")
                                       otherButtonTitles:NSLocalizedString(@"Settings_SignOutAlrtBtn", @"Settings Screen sign out Alert Btn - 'I'm Sure'"), nil];
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

                // Reset the values of all NSUserDefault items & keys
                NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [[assist shared] setisloggedout:YES];

                [nav_ctrl performSelector:@selector(disable)];
                Register *reg = [Register new];
                [self.navigationController pushViewController:reg animated:YES];
                me = [core new];
                [ARProfileManager clearProfile];
            }
        }
    }

    else if ([tagName isEqualToString:@"RemoveBankAccount"])
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

            [user setBool:NO forKey:@"IsKnoxBankAvailable"];
            [user setBool:NO forKey:@"IsSynapseBankAvailable"];

            [user synchronize];

            [introText setHidden:NO];
            [glyph_noBank setHidden:NO];

            isBankAttached = NO;

            [linked_background removeFromSuperview];
            [bank_image removeFromSuperview];
            [unlink_account removeFromSuperview];
        }
        else if ([[dictResponse valueForKey:@"Result"] rangeOfString:@"No active bank account found"].length != 0)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings_NoBnkFndAlrtTitle", @"Settings Screen 'Account Not Found' Alert Title")
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
        NSLog(@"Knox info is: %@",dictResponse);

        if (dictResponse != NULL &&
            (![[dictResponse valueForKey:@"AccountName"] isKindOfClass:[NSNull class]] &&
             ![[dictResponse valueForKey:@"BankImageURL"] isKindOfClass:[NSNull class]] &&
             ![[dictResponse valueForKey:@"BankName"] isKindOfClass:[NSNull class]]))
        {
            [user setBool:YES forKey:@"IsKnoxBankAvailable"];
            [user synchronize];

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
            [ARProfileManager registerString:@"Bank_Logo" withValue:[dictResponse valueForKey:@"BankImageURL"]];
        }
        else
        {
            NSLog(@"Knox response was null.");
            [user setBool:NO forKey:@"IsKnoxBankAvailable"];

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

    else if ([tagName isEqualToString:@"synapse_bank_info"])
    {
        NSError * error;
        NSMutableDictionary * responseForSynapseBank = [NSJSONSerialization
                                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                             options:kNilOptions
                                             error:&error];
        NSLog(@"Synapse info is: %@",responseForSynapseBank);

        if (responseForSynapseBank != NULL &&
            (![[responseForSynapseBank valueForKey:@"BankName"] isKindOfClass:[NSNull class]] &&
             ![[responseForSynapseBank valueForKey:@"AccountStatus"] isKindOfClass:[NSNull class]]))
        {
            [user setBool:YES forKey:@"IsSynapseBankAvailable"];
            [user synchronize];

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

            bank_image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 49, 48)];
            bank_image.contentMode = UIViewContentModeScaleToFill;
            if (![[responseForSynapseBank valueForKey:@"BankImageURL"] isKindOfClass:[NSNull class]])
            {
                if ([[responseForSynapseBank valueForKey:@"BankImageURL"] rangeOfString:@"/no.png"].location != NSNotFound)
                {
                    [bank_image setImage:[UIImage imageNamed:@"bank.png"]];
                }
                else
                {
                    [bank_image setFrame:CGRectMake(10, 7, 50, 50)];
                    [bank_image sd_setImageWithURL:[NSURL URLWithString:[responseForSynapseBank valueForKey:@"BankImageURL"]] placeholderImage:[UIImage imageNamed:@"bank.png"]];
                }
            }
            else
            {
                [bank_image setImage:[UIImage imageNamed:@"bank.png"]];
            }
            bank_image.layer.cornerRadius = 5;
            bank_image.clipsToBounds = YES;
            [linked_background addSubview:bank_image];

            bank_name = [UILabel new];
            [bank_name setStyleId:@"linked_account_name"];
            [bank_name setText:[responseForSynapseBank valueForKey:@"BankName"]];
            [linked_background addSubview:bank_name];

            lastFour_label = [UILabel new];
            [lastFour_label setStyleId:@"linked_account_last4"];
            if (![[responseForSynapseBank valueForKey:@"BankNickName"] isKindOfClass:[NSNull class]])
            {
                [lastFour_label setText:[responseForSynapseBank valueForKey:@"BankNickName"]];
            }
            else if (![[responseForSynapseBank valueForKey:@"AccountName"] isKindOfClass:[NSNull class]])
            {
                [lastFour_label setText:[responseForSynapseBank valueForKey:@"AccountName"]];
            }
            [linked_background addSubview:lastFour_label];

            unlink_account = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [unlink_account setStyleId:@"remove_account"];
            [unlink_account setTitle:NSLocalizedString(@"Settings_EditTxt", @"Settings 'Edit' Txt") forState:UIControlStateNormal];
            [unlink_account addTarget:self action:@selector(edit_attached_bank) forControlEvents:UIControlEventTouchUpInside];
            [linked_background addSubview:unlink_account];

            [ARProfileManager registerString:@"Bank_Name" withValue:[responseForSynapseBank valueForKey:@"BankName"]];
            [ARProfileManager registerString:@"Bank_Logo" withValue:[responseForSynapseBank valueForKey:@"BankImageURL"]];
        }
        else
        {
            NSLog(@"Synapse response was null.");
            [user setBool:NO forKey:@"IsSynapseBankAvailable"];

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

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

#pragma mark - AlertView Handling
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11 && buttonIndex == 0)
    {
        [ARTrackingManager trackEvent:@"Settings_TappedAddBankGoToKnoxWbvw_ReplaceBnk"];
        knoxWeb *knox = [knoxWeb new];
        [self.navigationController pushViewController:knox animated:YES];
        return;
    }

    else if( alertView.tag == 41 && buttonIndex == 1)
    {
        [self profile];
    }

    else if (alertView.tag == 2 && buttonIndex == 0)
    {
        [self RemoveBankAccount];
    }

    else if (alertView.tag == 10 && buttonIndex == 1)
    {
        [self contactSupport_SetOpt];
    }

    else if (alertView.tag == 15 &&buttonIndex == 1)
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
        [serveOBJ LogOutRequest:[user valueForKey:@"MemberId"]];
    }

}

-(void)contactSupport_SetOpt
{
    if (![MFMailComposeViewController canSendMail])
    {
        if ([UIAlertController class]) // for iOS 8
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No Email Detected"
                                         message:@"You don't have an email account configured for this device."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * ok = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                  }];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else
        {
            if (![MFMailComposeViewController canSendMail])
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                              message:@"You don't have an email account configured for this device."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
                [av show];
                return;
            }
        }
    }

    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor=[UIColor whiteColor];

    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];

    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end