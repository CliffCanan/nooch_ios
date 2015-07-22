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
#import "addBank.h"
#import "UIImageView+WebCache.h"
#import "fbConnect.h"
#import "IdVerifyImageUpload.h"
@interface SettingsOptions (){
    UILabel * introText;
    UILabel * bank_name;
    UILabel * lastFour_label;
    UILabel * bnkStatus_label;
    UILabel * bnkStatus_status;
    UIImageView * bank_image;
    UITableView * menu;
    UIView * linked_background;
    UIButton * unlink_account;
    UIButton * link_bank;
    UIButton * addAnotherBnk;
    UILabel *glyph_noBank;
    UIScrollView * scroll;
}
@property(atomic,weak)UIButton *logout;
@property(nonatomic) UIImagePickerController *picker;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UILabel * glyphProfileNotValidated;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([user boolForKey:@"IsSynapseBankAvailable"])
    {
        isBankAttached = YES;
        if ([self.view.subviews containsObject:glyph_noBank])
        {
            [glyph_noBank removeFromSuperview];
        }
        
        addAnotherBnk = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addAnotherBnk setStyleId:@"addAnotherBnk"];
        [addAnotherBnk setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"] forState:UIControlStateNormal];
        [addAnotherBnk addTarget:self action:@selector(attach_bank) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addAnotherBnk];
        
        if (![user boolForKey:@"IsSynapseBankVerified"])
        {
            helpText = [UILabel new];
            [helpText setFrame:CGRectMake(20, 128, 280, 48)];
            helpText.numberOfLines = 0;
            [helpText setStyleClass:@"helpText"];
            [helpText setText:@"As an extra security measure, your bank must be verified. Learn more."];
            [self.view addSubview:helpText];
            [helpText setHidden:YES];
        }
    }
    else
    {
        //NSLog(@"viewDidLoad -> Bank ain't attached!");
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

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

    link_bank = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [link_bank setFrame:CGRectMake(0, 123, 0, 0)];
    [link_bank setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    link_bank.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [link_bank addTarget:self action:@selector(attach_bank) forControlEvents:UIControlEventTouchUpInside];
    [link_bank setStyleClass:@"button_blue"];
    [link_bank setStyleId:@"link_new_account"];
    [link_bank setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (isBankAttached)
    {
        [link_bank setTitle:NSLocalizedString(@"Settings_LinkNewBnk", @"Settings Screen button text when bank is attached") forState:UIControlStateNormal];
    }
    else
    {
        [link_bank setTitle:NSLocalizedString(@"Settings_LinkBnkNow", @"Settings Screen button text when bank is NOT attached") forState:UIControlStateNormal];
        [self.view addSubview:link_bank];
    }

    UILabel * glyph = [UILabel new];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph setFrame:CGRectMake(26, 9, 30, 30)];
    [glyph setTextAlignment:NSTextAlignmentCenter];
    glyph.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"]
                                                           attributes:textAttributes1];
    [glyph setTextColor:[UIColor whiteColor]];
    [link_bank addSubview:glyph];

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterFG_Settings:) name:UIApplicationWillEnterForegroundNotification object:nil];

    // PUSH NOTIFICATIONS
    [self checkAndRegisterPushNotifs];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:NSLocalizedString(@"Settings_ScrnTitle", @"Settings Screen Title")];
    self.screenName = @"Settings Main Screen";
    
    [self getBankInfo];

    //NSLog(@"isBankAttahed is %d",isBankAttached);
    if (isBankAttached)
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleFadingCircleAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = @"Assebling Your Settings";
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        [self.hud show:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ARTrackingManager trackEvent:@"Settings_viewDidAppear"];

    if (shouldDisplayBankNotVerifiedLtBox)
    {
        shouldDisplayBankNotVerifiedLtBox = NO;
        [self bnkStatus_lightBox];
    }

    [ARTrackingManager trackEvent:@"SettingsMain_DidAppear_Finished"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

#pragma mark - Bank Functions
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

    //2. IS USER'S EMAIL VERIFIED?
    else if ([[user valueForKey:@"Status"]isEqualToString:@"Registered"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Please Verify Your Email"
                                                        message:@"Terribly sorry, but before you send money or add a bank account, please confirm your email address by clicking the link we sent to the email address you used to sign up.\n\xF0\x9F\x99\x8F"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    // 3. IS USER'S PHONE VERIFIED?
    else if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Blame The Lawyers"
                                                        message:@"To keep Nooch safe, we ask all users to verify a phone number before sending money.\n\nIf you've already added your phone number, just respond 'Go' to the text message we sent.\n\xF0\x9F\x93\xB2"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    // 4. HAS USER COMPLETED & VERIFIED PROFILE INFO? (EMAIL, PHONE, ADDRESS)?
    if (![[assist shared] isProfileCompleteAndValidated] ||  // this line covers: being suspended, IsVerifiedPhone, and status = active
        ![[user objectForKey:@"ProfileComplete"] isEqualToString:@"YES"]) // this line covers that the address is not empty or null
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Help Us Keep Nooch Safe"
                                                        message:@"Please take 1 minute to verify your identity by completing your Nooch profile."
                                                       delegate:self
                                              cancelButtonTitle:@"Later"
                                              otherButtonTitles:@"Go Now", nil];
        [alert setTag:41];
        [alert show];
        return;
    }

    // 5. HAS USER SUBMITTED DOB AND SSN LAST 4?
    if (![[assist shared] isUsersIdInfoSubmitted])
    {
        // Body text if both DoB and SSN are not submitted yet
        NSString * alertBody = @"Please take 30 seconds to verify your identity by entering your:\n\n• Date of birth, and\n• Just the LAST 4 digits of your SSN\n\nFederal regulations require us to verify each user's identity. We will only ask for this info once and all data is stored with encryption on secure servers.\n\xF0\x9F\x94\x92";

        if ([user boolForKey:@"wasSsnAdded"] == YES)
        {
            // Body text if SSN was submitted, but not DoB
            alertBody = @"Please take 30 seconds to finish verifying your identity by entering your:\n\n• Date of birth\n\nFederal regulations require us to verify each user's identity. We will only ask for this info once and all data is stored with encryption on secure servers.\n\xF0\x9F\x94\x92";
            shouldFocusOnDob = YES;
        }
        else if (![[user objectForKey:@"dob"] isKindOfClass:[NSNull class]] &&
                   [user objectForKey:@"dob"] != NULL)
        {
            // Body text if DoB was submitted, but not SSN
            alertBody = @"Please take 30 seconds to finish verifying your identity by entering your:\n\n• Just the LAST 4 digits of your SSN\n\nFederal regulations require us to verify each user's identity. We will only ask for this info once and all data is stored with encryption on secure servers.\n\xF0\x9F\x94\x92";
            shouldFocusOnSsn = YES;
        }

        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Help Us Keep Nooch Safe"
                                                        message:alertBody
                                                       delegate:self
                                              cancelButtonTitle:@"Later"
                                              otherButtonTitles:@"Go Now", nil];
        [alert setTag:42];
        [alert show];
        return;
    }

    // 6 DOES USER ALREADY HAVE A BANK ATTACHED?
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
        addBank * addBankWebview = [addBank new];
        [self.navigationController pushViewController:addBankWebview animated:YES];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

    if (indexPath.row == 0)
    {
        title.text = NSLocalizedString(@"Settings_TableRowLbl1", @"Settings Screen table label row 1 - 'Profile Info'");
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"]];

        if (![[assist shared] isProfileCompleteAndValidated] ||  // this line covers: being suspended, IsVerifiedPhone, and status = active
            ![[user objectForKey:@"ProfileComplete"] isEqualToString:@"YES"] || // this line covers that the address is not empty or null
            ![[assist shared] isUsersIdInfoSubmitted] )
        {
            self.glyphProfileNotValidated = [UILabel new];
            [self.glyphProfileNotValidated setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
            [self.glyphProfileNotValidated setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation"]];
            [self.glyphProfileNotValidated setFrame:CGRectMake(140, 14, 22, 22)];
            [self.glyphProfileNotValidated setStyleClass:@"animate_bubble"];
            [self.glyphProfileNotValidated setStyleId:@"glyph_noBank_sidebar"];
            [self.glyphProfileNotValidated setStyleId:@"glyph_noBank_settingsTbl"];

            [cell.contentView addSubview:self.glyphProfileNotValidated];
        }
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
        [self goToProfile];
    }
    else if (indexPath.row == 1) {
        [self goToPinSettings];
    }
    else if(indexPath.row == 2) {
        [self goToNotifSettings];
    }
    else if(indexPath.row == 3) {
        [self goToSocialSettings];
    }
}

-(void)getBankInfo
{
    serve * getBankInfo = [serve new];
    getBankInfo.Delegate = self;
    getBankInfo.tagName = @"synapse_bank_info";
    [getBankInfo GetSynapseBankAccountDetails];
    isSynapseOn = YES;
}

- (void)applicationWillEnterFG_Settings:(NSNotification *)notification
{
    [self getBankInfo];
}

-(void)RemoveBankAccount
{
    serve * serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"RemoveBankAccount";
    [serveOBJ RemoveSynapseBankAccount];

    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Removing bank account";
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    [self.hud show:YES];
}

#pragma mark - Navigation Functions
-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)goToProfile
{
    isProfileOpenFromSideBar = NO;
    sentFromHomeScrn = NO;
    isFromTransDetails = NO;
    isFromSettingsOptions = YES;

    ProfileInfo * info = [ProfileInfo new];
    [self performSelector:@selector(navigate_to:) withObject:info afterDelay:0.01];
}

- (void)goToPinSettings
{
    PINSettings * pin = [PINSettings new];
    [self performSelector:@selector(navigate_to:) withObject:pin afterDelay:0.01];
}

- (void)goToNotifSettings
{
    NotificationSettings * notes = [NotificationSettings new];
    [self performSelector:@selector(navigate_to:) withObject:notes afterDelay:0.01];
}

- (void)goToSocialSettings
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

#pragma mark - LightBox Handling
-(void)bnkStatus_lightBox
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];

    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        mainView.frame = CGRectMake(9, -500, 302, 440);
    }
    else {
        mainView.frame = CGRectMake(9, -540, 302, 464);
    }

    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;

    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];

    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Verify Your Bank"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];

    UILabel * glyph_lock = [UILabel new];
    [glyph_lock setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph_lock setFrame:CGRectMake(29, 10, 22, 29)];
    [glyph_lock setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    [glyph_lock setTextColor:kNoochBlue];
    [head_container addSubview:glyph_lock];


    UILabel * bodyText = [UILabel new];
    [bodyText setNumberOfLines:0];
    [bodyText setFont:[UIFont fontWithName:@"Roboto" size:16]];
    [bodyText setFrame:CGRectMake(15, 51, 272, 38)];
    [bodyText setTextAlignment:NSTextAlignmentCenter];
    [bodyText setText:@"Your bank account needs additional verification because either:"];
    [bodyText setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyText];

    UILabel * bodyText2 = [UILabel new];
    [bodyText2 setNumberOfLines:0];
    [bodyText2 setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [bodyText2 setFrame:CGRectMake(27, bodyText.frame.origin.y + bodyText.frame.size.height + 4, 264, 53)];
    [bodyText2 setText:@"we were unable to match the profile information you entered with the info listed on this bank account"];
    [bodyText2 setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyText2];

    UILabel * bodyTextBullet1 = [UILabel new];
    [bodyTextBullet1 setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [bodyTextBullet1 setFrame:CGRectMake(16, bodyText2.frame.origin.y, 15, 19)];
    [bodyTextBullet1 setText:@"•"];
    [bodyTextBullet1 setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyTextBullet1];

    UILabel * bodyText3 = [UILabel new];
    [bodyText3 setNumberOfLines:0];
    [bodyText3 setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [bodyText3 setFrame:CGRectMake(27, 149, 264, 36)];
    [bodyText3 setText:@"sometimes we just can't find any contact info from some accounts"];
    [bodyText3 setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyText3];

    UILabel * bodyTextBullet2 = [UILabel new];
    [bodyTextBullet2 setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [bodyTextBullet2 setFrame:CGRectMake(16, bodyText3.frame.origin.y, 15, 19)];
    [bodyTextBullet2 setText:@"•"];
    [bodyTextBullet2 setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyTextBullet2];

    UILabel * bodyText4 = [UILabel new];
    [bodyText4 setFont:[UIFont fontWithName:@"Roboto" size:16]];
    [bodyText4 setFrame:CGRectMake(17, 200, 270, 18)];
    [bodyText4 setText:@"What To Do Now..."];
    [bodyText4 setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyText4];

    UILabel * bodyText5 = [UILabel new];
    [bodyText5 setNumberOfLines:0];
    [bodyText5 setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [bodyText5 setFrame:CGRectMake(17, bodyText4.frame.origin.y + 23, 268, 88)];
    [bodyText5 setText:@"If we found an email address on your bank, we sent a verification link to that address (which may be different than the email you used for Nooch). Just click the the link in that email."];
    [bodyText5 setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyText5];

    UILabel * bodyText6 = [UILabel new];
    [bodyText6 setNumberOfLines:0];
    [bodyText6 setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [bodyText6 setFrame:CGRectMake(17, 318, 270, 72)];
    [bodyText6 setText:@"Or, if you didn't receive a verification email, just send us a picture of any photo ID. Email it to support@nooch.com, or tap \"Submit ID\" below."];
    [bodyText6 setTextColor:[Helpers hexColor:@"141515"]];
    [mainView addSubview:bodyText6];


    UIButton * takePic = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePic setStyleClass:@"button_LtBoxSm_left"];
    [takePic setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    takePic.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    takePic.frame = CGRectMake(10, mainView.frame.size.height - 56, 280, 50);
    [takePic setTitle:@"Submit ID" forState:UIControlStateNormal];
    [takePic addTarget:self action:@selector(goToIdVerScrn) forControlEvents:UIControlEventTouchUpInside];

    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLink.frame = CGRectMake(10, mainView.frame.size.height - 56, 280, 50);
    [btnLink setStyleClass:@"button_LtBoxSm_right"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [btnLink setTitle:@"OK" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(close_bnkStatusLb) forControlEvents:UIControlEventTouchUpInside];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_lock.frame = CGRectMake(28, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height - 51, 280, 44);
    }

    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(9, 6, 35, 35);

    UIButton * btnClose_shell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose_shell.frame = CGRectMake(mainView.frame.size.width - 35, head_container.frame.origin.y - 21, 48, 46);
    [btnClose_shell addTarget:self action:@selector(close_bnkStatusLb) forControlEvents:UIControlEventTouchUpInside];
    [btnClose_shell addSubview:btnClose];

    [mainView addSubview:btnClose_shell];
    [mainView addSubview:bodyText];
    [mainView addSubview:btnLink];
    [mainView addSubview:takePic];
    [overlay addSubview:mainView];

    [UIView animateKeyframesWithDuration:.55
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.8 animations:^{
                                      overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, 70, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, 70, 302, 464);
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.4 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, 35, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, 45, 302, 464);
                                      }
                                  }];
                              }
                              completion: ^(BOOL finished){
                                  
                              }
     ];

    [ARTrackingManager trackEvent:@"MainSettings_BnkStatusLtBx_Appeared"];
}

-(void)close_bnkStatusLb
{
    [UIView animateKeyframesWithDuration:0.6
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.35 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, 70, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, 70, 302, 460);
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.65 animations:^{
                                      overlay.alpha = 0;
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, -500, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, -540, 302, 400);
                                      }
                                  }];
                              }
                              completion:^(BOOL finished) {
                                  [overlay removeFromSuperview];

                                  if (shouldGoToIdVerScrn)
                                  {
                                      shouldGoToIdVerScrn = false;
                                      IdVerifyImageUpload * idVerifyScrn = [IdVerifyImageUpload new];
                                      [self.navigationController pushViewController:idVerifyScrn animated:YES];
                                  }
                              }
     ];
}

-(void)goToIdVerScrn
{
    shouldGoToIdVerScrn = true;
    [self close_bnkStatusLb];
}

#pragma mark - AlertView Handling
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11 && buttonIndex == 0)
    {
        [ARTrackingManager trackEvent:@"Settings_TappedAddBankGoToKnoxWbvw_ReplaceBnk"];
        addBank * addBankWebView = [addBank new];
        [self.navigationController pushViewController:addBankWebView animated:YES];
        return;
    }

    else if (alertView.tag == 41 && buttonIndex == 1)
    {
        shouldFocusOnAddress = YES;
        [self goToProfile];
    }

    else if (alertView.tag == 42 && buttonIndex == 1)
    {
        [self goToProfile];
    }

    else if (alertView.tag == 42 && buttonIndex == 0)
    {
        shouldFocusOnDob = NO;
        shouldFocusOnSsn = NO;
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
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                      message:@"You don't have an email account configured for this device."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
        [av show];
        return;
    }

    NSString * memberId = [user valueForKey:@"MemberId"];
    NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
    NSString * userStatus = [user objectForKey:@"Status"];
    NSString * userEmail = [user objectForKey:@"UserName"];
    NSString * IsVerifiedPhone = [[user objectForKey:@"IsVerifiedPhone"] lowercaseString];
    NSString * iOSversion = [[UIDevice currentDevice] systemVersion];
    NSString * msgBody = [NSString stringWithFormat:@"<!doctype html> <html><body><br><br><br><br><br><br><small>• MemberID: %@<br>• Name: %@<br>• Status: %@<br>• Email: %@<br>• Is Phone Verified: %@<br>• iOS Version: %@<br></small></body></html>",memberId, fullName, userStatus, userEmail, IsVerifiedPhone, iOSversion];

    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor=[UIColor whiteColor];
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:msgBody isHTML:YES];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

#pragma mark - Server Response Handling
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
            // if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Success."]) {
            [blankView removeFromSuperview];
            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];

            [timer invalidate];
            [nav_ctrl performSelector:@selector(disable)];
            [nav_ctrl performSelector:@selector(reset)];

            // Reset the values of all NSUserDefault items & keys
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[assist shared] setisloggedout:YES];

            Register *reg = [Register new];
            [nav_ctrl pushViewController:reg animated:YES];
            me = [core new];
            [ARProfileManager clearProfile];
            // }
        }
    }

    else if ([tagName isEqualToString:@"RemoveBankAccount"])
    {
        NSError * error;
        NSMutableDictionary * dictResponse = [NSJSONSerialization
                                              JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                              options:kNilOptions
                                              error:&error];
        NSLog(@"Settings -> Listen -> Remove Bank Account response was: %@", dictResponse);
        [self.hud setHidden:YES];

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

            if (![self.view.subviews containsObject:introText])
            {
                introText = [UILabel new];
                [introText setFrame:CGRectMake(10, 38, 300, 76)];
                introText.numberOfLines = 0;

                [introText setTextAlignment:NSTextAlignmentCenter];
                [introText setStyleId:@"settings_introText"];
                [self.view addSubview:introText];
            }

            [introText setText:NSLocalizedString(@"Settings_NoBankIntroTxt", @"Settings Screen instruction text when no bank is attached")];
            [introText setHidden:NO];

            [glyph_noBank setHidden:NO];

            isBankAttached = NO;

            [linked_background removeFromSuperview];
            [bank_image removeFromSuperview];
            [unlink_account removeFromSuperview];
            [addAnotherBnk removeFromSuperview];

            [self.view addSubview:link_bank];
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

    else if ([tagName isEqualToString:@"synapse_bank_info"])
    {
        NSError * error;
        NSMutableDictionary * responseForSynapseBank = [NSJSONSerialization
                                                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:kNilOptions
                                                        error:&error];

        if (   responseForSynapseBank != NULL &&
            ![[responseForSynapseBank valueForKey:@"BankName"] isKindOfClass:[NSNull class]])
        {
            //NSLog(@"Synapse info is: %@",responseForSynapseBank);

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
            else
            {
                [self.view addSubview:linked_background];
            }

            UILabel * glyph_lock = [[UILabel alloc] initWithFrame:CGRectMake(81, 7, 13, 22)];
            [glyph_lock setBackgroundColor:[UIColor clearColor]];
            [glyph_lock setTextAlignment:NSTextAlignmentLeft];
            [glyph_lock setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
            [glyph_lock setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
            [glyph_lock setTextColor:kNoochGreen];
            [linked_background addSubview:glyph_lock];

            bank_image = [[UIImageView alloc] initWithFrame:CGRectMake(11, 12, 49, 48)];
            bank_image.contentMode = UIViewContentModeScaleAspectFill;
            if (![[responseForSynapseBank valueForKey:@"BankImageURL"] isKindOfClass:[NSNull class]])
            {
                if ([[responseForSynapseBank valueForKey:@"BankImageURL"] rangeOfString:@"/no.png"].location != NSNotFound)
                {
                    [bank_image setImage:[UIImage imageNamed:@"bank.png"]];
                }
                else
                {
                    [bank_image setFrame:CGRectMake(8, 14, 61, 45)];
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

            bnkStatus_label = [UILabel new];
            [bnkStatus_label setStyleId:@"bnkStatus_lbl"];
            [bnkStatus_label setText:@"Status:"];
            [linked_background addSubview:bnkStatus_label];

            UILabel * bnkStatusStatus = [UILabel new];
            [bnkStatusStatus setStyleClass:@"bnkStatus_status"];

            if ([[responseForSynapseBank valueForKey:@"AccountStatus"] isEqualToString:@"Verified"] ||
                [user boolForKey:@"IsSynapseBankVerified"])
            {
                [bnkStatusStatus setStyleId:@"bnkstatus_verified"];
                [bnkStatusStatus setText:@"Verified"];
                if (![helpText isHidden]) {
                    [helpText setHidden:YES];
                }
            }
            else if ([[responseForSynapseBank valueForKey:@"AccountStatus"] isEqualToString:@"Pending Review"] ||
                     [user boolForKey:@"isIdVerDocSubmitted"])
            {
                [bnkStatusStatus setText:@"Pending ID Verification"];

                //[linked_background addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bnkStatus_lightBox)]];

                if (![self.view.subviews containsObject:helpText])
                {
                    helpText = [UILabel new];
                    helpText.numberOfLines = 0;
                    [helpText setStyleClass:@"helpText"];
                    [self.view addSubview:helpText];
                }
                [helpText setFrame:CGRectMake(10, 117, 300, 82)];
                [helpText setText:@"We are currently reviewing the information you submitted. This usually takes less than 48 hours in most circumstances."];
                [helpText setUserInteractionEnabled:YES];
                //[helpText addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bnkStatus_lightBox)]];
                [helpText setHidden:NO];
            }
            else
            {
                [bnkStatusStatus setText:@"Not Verified"];

                [linked_background addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bnkStatus_lightBox)]];

                if (![self.view.subviews containsObject:helpText])
                {
                    helpText = [UILabel new];
                    [helpText setFrame:CGRectMake(10, 120, 300, 80)];
                    helpText.numberOfLines = 0;
                    [helpText setStyleClass:@"helpText"];
                    [self.view addSubview:helpText];
                }
                [helpText setUserInteractionEnabled:YES];
                [helpText addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bnkStatus_lightBox)]];
                [helpText setHidden:NO];

                UIButton * helpGlyph = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [helpGlyph setFrame:CGRectMake(238, 20, 25, 25)];
                [helpGlyph setStyleId:@"settings_helpGlyph"];
                [helpGlyph addTarget:self action:@selector(bnkStatus_lightBox) forControlEvents:UIControlEventTouchUpInside];
                [helpGlyph setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"] forState:UIControlStateNormal];
                [helpText addSubview:helpGlyph];
            }

            [linked_background addSubview:bnkStatusStatus];

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
        
        [self.hud setHidden:YES];
    }
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

#pragma mark - Mail Controller
-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end