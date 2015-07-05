//  LeftMenu.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "LeftMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "HistoryFlat.h"
#import "SettingsOptions.h"
#import "LimitsAndFees.h"
#import "Statistics.h"
#import "SendInvite.h"
#import "ProfileInfo.h"
#import "UIImageView+WebCache.h"
#import "assist.h"
#import "privacy.h"
#import "terms.h"
#import "webView.h"
#import "tour.h"
#import "Appirater.h"
#import "SelectApt.h"
#import "MyApartment.h"

@interface LeftMenu ()
@property(nonatomic,strong) UITableView *menu;
@property(nonatomic) NSIndexPath *selected;
@property(nonatomic,strong) UILabel *name;
@property(nonatomic,strong) UILabel *lastName;
@property(nonatomic,strong) UILabel *glyph_noBank;
@property(nonatomic,strong) UIButton * settings;
@end
@implementation LeftMenu

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

    self.selected = 0,0;
    [self.view setBackgroundColor:kNoochMenu];

    self.menu = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, 320, [[UIScreen mainScreen] bounds].size.height-145)];
    [self.menu setBackgroundColor:kNoochMenu]; [self.menu setDelegate:self]; [self.menu setDataSource:self]; [self.menu setSeparatorColor:kNoochGrayLight];
    [self.menu setRowHeight:45];
    [self.view addSubview:self.menu];

    user_bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    [user_bar setStyleId:@"lside_topbar_background"];
    [self.view addSubview:user_bar];

    self.name = [[UILabel alloc] initWithFrame:CGRectMake(65, 40, 150, 20)];
    [self.name setStyleId:@"lside_firstname"];
    [self.name setText:[[user objectForKey:@"firstName"] capitalizedString]];
    [user_bar addSubview:self.name];

    self.lastName = [[UILabel alloc] initWithFrame:CGRectMake(60, 48, 150, 10)];
    [self.lastName setStyleId:@"lside_lastName"];
    [self.view addSubview:self.lastName];

    UIView * shadowUnder = [[UIView alloc] initWithFrame:CGRectMake(18, 21, 61, 61)];
    shadowUnder .backgroundColor = [Helpers hexColor:@"505257"];
    shadowUnder.layer.cornerRadius = 30;
    shadowUnder.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowUnder.layer.shadowOffset = CGSizeMake(0, 2);
    shadowUnder.layer.shadowOpacity = 0.82;
    shadowUnder.layer.shadowRadius = 4.0;
    shadowUnder.alpha = .8;
    [user_bar addSubview:shadowUnder];

    UIView * bottom_bar = [UIView new];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [bottom_bar setStyleId:@"lside_bottombar_background_4"];
    } 
    else {
        [bottom_bar setStyleId:@"lside_bottombar_background"];
    }
    [self.view addSubview:bottom_bar];

    self.settings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.settings setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cogs"] forState:UIControlStateNormal];
    [self.settings addTarget:self action:@selector(go_settings) forControlEvents:UIControlEventTouchUpInside];
    [self.settings setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.25) forState:UIControlStateNormal];
    self.settings.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    UIImageView * logo = [UIImageView new];
    UILabel * version = [UILabel new];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [logo setStyleId:@"nooch_whitelogo_4"];
        [version setStyleId:@"version_label_4"];
    }
    else
    {
        [logo setStyleId:@"nooch_whitelogo"];
        [version setStyleId:@"version_label"];
    }

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textShadow = @{NSShadowAttributeName: shadow };

    NSString * versionTxt = NSLocalizedString(@"LeftSidebar_VersionTxt", @"Left Sidebar 'Version' Text");
    version.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",versionTxt,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] attributes:textShadow];
    [self.view addSubview:version];
    [self.view addSubview:logo];

    self.glyph_noBank = [UILabel new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.screenName = @"Left Sidebar";

    [self.name setText:[[user objectForKey:@"firstName"] capitalizedString]];
    [self.lastName setText:[[user objectForKey:@"lastName"] capitalizedString]];

    if ([[user objectForKey:@"Photo"] length] > 0 && [user objectForKey:@"Photo"] != nil)
    {
        user_pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 60, 60)];
        [user_pic setStyleId:@"lside_userpic"];
        [user_pic sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
        user_pic.layer.cornerRadius = 30;
        user_pic.layer.borderWidth = 2;
        user_pic.layer.borderColor = [UIColor whiteColor].CGColor;
        user_pic.clipsToBounds = YES;
        [user_pic setUserInteractionEnabled:YES];
        [user_bar addSubview:user_pic];
        [user_pic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(go_profile)]];
    }

    if ( ![[user valueForKey:@"Status"]isEqualToString:@"Active"]  ||
         ![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ||
         ([[user valueForKey:@"firstName"]length] < 1 || [[user valueForKey:@"lastName"] length] < 1) )
    {
        user_pic.layer.borderWidth = 3;
        user_pic.layer.borderColor = kNoochRed.CGColor;
    }

    if ([[user valueForKey:@"firstName"] length] < 1 && [[user valueForKey:@"lastName"] length] < 1)
    {
        [self.name setText:[NSString stringWithFormat:@"Some"]];
        [self.lastName setText:[NSString stringWithFormat:@"Person"]];
    }

    [self.menu reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    settingsIconPosition = [ARPowerHookManager getValueForHookById:@"settingsCogIconPos"];

    if ([settingsIconPosition isEqualToString:@"topBar"])
    {
        [self.settings setStyleId:@"settings_icon_topBarPosition"];
        [user_bar addSubview:self.settings];
    }
    else if ([[UIScreen mainScreen] bounds].size.height > 500)
    {
        [self.settings setStyleId:@"settings_icon"];
        [self.view addSubview:self.settings];
    }
    else
    {
        [self.settings setStyleId:@"settings_icon_4"];
        [self.view addSubview:self.settings]; 
    }

    if ((isKnoxOn && [user boolForKey:@"IsKnoxBankAvailable"]) ||
        (isSynapseOn && [user boolForKey:@"IsSynapseBankAvailable"]))
    {
        [self.glyph_noBank removeFromSuperview];
    }
    else
    {
        [self.glyph_noBank setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation"]];
        [self.glyph_noBank setStyleId:@"glyph_noBank_sidebar"];

        if ([settingsIconPosition isEqualToString:@"topBar"])
        {
            [self.glyph_noBank setFrame:CGRectMake(238, 31, 22, 22)];
            [user_bar addSubview:self.glyph_noBank];
            [user_bar bringSubviewToFront:self.glyph_noBank];
        }
        else
        {
            [self.glyph_noBank setFrame:CGRectMake(5, [[UIScreen mainScreen] bounds].size.height - 50, 22, 22)];
            [self.view addSubview:self.glyph_noBank];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void) go_profile
{
    isProfileOpenFromSideBar = YES;
    isFromSettingsOptions = NO;

    ProfileInfo * prof = [ProfileInfo new];
    [nav_ctrl pushViewController:prof animated:YES];
    [self.slidingViewController resetTopView];
}

- (void)go_settings
{
    SettingsOptions *sets = [SettingsOptions new];
    [nav_ctrl pushViewController:sets animated:YES];
    [self.slidingViewController resetTopView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,300,22)];
    [title setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    title.textColor = [UIColor whiteColor];
    
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .28);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
    
    if (section == 0) {
        title.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Hdr_Account", @"Left Sidebar Section Header - 'Account'")//@"ACCOUNT"
            attributes:textAttributes];
    }
    else if(section == 1) {
        title.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Hdr_Social", @"Left Sidebar Section Header - 'Social'")//@"SOCIAL"
            attributes:textAttributes];
    }
    else if(section == 2) {
        title.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Hdr_About", @"Left Sidebar Section Header - 'About'")//@"ABOUT"
            attributes:textAttributes];
    }
    else {
        title.text = @"";
    }

    [headerView addSubview:title];
    [title setBackgroundColor:[UIColor clearColor]];
    [headerView setStyleClass:@"sectionheader_bckgrnd"];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (shouldDisplayAptsSection) {
            return 4;
        }
        else {
            return 3;
        }
    }
    else if (section == 1)
    {
        return 2;
    }
    else if (section == 2)
    {
        return 4;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView * selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
    }
    if ([cell.contentView subviews])
    {
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    cell.indentationLevel = 1;
    cell.indentationWidth = 30;
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:kNoochMenu];
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Light" size:18];

    arrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrow setFrame:CGRectMake(242, 14, 16, 18)];
    [arrow setStyleClass:@"lside_arrow"];
    [arrow setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"] forState:UIControlStateNormal];
    [arrow setTitleShadowColor:Rgb2UIColor(31, 32, 33, 0.45) forState:UIControlStateNormal];
    arrow.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [cell.contentView addSubview:arrow];

    UILabel *iv = [UILabel new];
    [iv setStyleClass:@"lside_menu_icons"];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = kLeftMenuShadow;
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Home", @"Left Sidebar Row Title - 'Home'")//@"Home"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-home"] attributes:textAttributes];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Hist", @"Left Sidebar Row Title - 'Transaction History'")//@"Transaction History"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"] attributes:textAttributes];

            UILabel * pending_notif = [UILabel new];

            if ([user boolForKey:@"hasPendingItems"] == true)
            {
                //  NSLog(@"The current pending count is: %@",[defaults objectForKey:@"Pending_count"]);
                [pending_notif setText:[NSString stringWithFormat:@"%@",[user objectForKey:@"Pending_count"]]];
                [pending_notif setFrame:CGRectMake(212, 10, 22, 22)];
                [pending_notif setStyleId:@"pending_notif"];
                [pending_notif setStyleId:@"pending_notif_lsideMenu"];
                [cell.contentView addSubview:pending_notif];
            }
            else {
                [pending_notif removeFromSuperview];
            }
            
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Stats", @"Left Sidebar Row Title - 'Statistics'")//@"Statistics"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-line-chart"] attributes:textAttributes];
            [iv setStyleClass:@"lside_menu_icons_sm"];
        }
        else if (shouldDisplayAptsSection && indexPath.row == 3)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Rent", @"Left Sidebar Row Title - 'Pay Rent'")//@"Pay Rent"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-building-o"] attributes:textAttributes];
            [iv setStyleClass:@"lside_menu_icons_sm"];
        }
    }
    /*else if(indexPath.section == 9)
    {
        if (indexPath.row == 0) {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Donate", @"Left Sidebar Row Title - 'Donate to a Cause'")//@"Donate to a Cause"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-globe"];
        }
    }*/
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Refer", @"Left Sidebar Row Title - 'Refer a Friend'")//@"Refer a Friend"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"] attributes:textAttributes];
            [iv setStyleClass:@"lside_menu_icons_sm"];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Rate", @"Left Sidebar Row Title - 'Rate Nooch'")//@"Rate Nooch"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"] attributes:textAttributes];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_HowItWrks", @"Left Sidebar Row Title - 'How Nooch Works'")//@"How Nooch Works"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question"] attributes:textAttributes];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Support", @"Left Sidebar Row Title - 'Support'")//@"Support"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope"] attributes:textAttributes];
            [iv setStyleClass:@"lside_menu_icons_sm"];
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Limits", @"Left Sidebar Row Title - 'Limits & Fees'")//@"Limits & Fees"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-usd"] attributes:textAttributes];
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LSidebar_Legal", @"Left Sidebar Row Title - 'Legal Info'")//@"Legal Info"
                                                                            attributes:textAttributes];
            iv.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-gavel"] attributes:textAttributes];
        }
    }
    [cell.contentView addSubview:iv];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [nav_ctrl popToRootViewControllerAnimated:NO];
            [self.slidingViewController resetTopView];
        }
        else if (indexPath.row == 1)
        {
            //Rlease memory cache
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache clearMemory];
            [imageCache clearDisk];
            [imageCache cleanDisk];

            isFromTransferPIN = NO;
            HistoryFlat *hist = [[HistoryFlat alloc] init];
            [nav_ctrl pushViewController:hist animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if (indexPath.row == 2)
        {
            Statistics *stats = [[Statistics alloc] init];
            [nav_ctrl pushViewController:stats animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if (indexPath.row == 3)
        {
            if (hasAptSet)
            {
                isFromPropertySearch = NO;
                MyApartment * myApt = [[MyApartment alloc] init];
                [nav_ctrl pushViewController: myApt animated:NO];
                [self.slidingViewController resetTopView];
            }
            else
            {
                SelectApt * selectApt = [[SelectApt alloc] init];
                [nav_ctrl pushViewController:selectApt animated:NO];
                [self.slidingViewController resetTopView];
            }
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            sentFromStatsScrn = false;
            SendInvite *inv = [SendInvite new];
            [nav_ctrl pushViewController:inv animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if (indexPath.row == 1) {
            [Appirater forceShowPrompt:false];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            tour *tour1 = [tour new];
            [nav_ctrl pushViewController:tour1 animated:YES];
            [self.slidingViewController resetTopView];
        }
        else if (indexPath.row == 1)
        {
            //contact support
            UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LSidebar_SupportActShtTitle", @"Left Sidebar contact support Action Sheet Title")
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Cancel"
                                                             destructiveButtonTitle:nil
                                                                  otherButtonTitles:NSLocalizedString(@"LSidebar_SupportActShtSupprtCtr", @"Left Sidebar contact support Action Sheet - 'Go to Support Center'"), NSLocalizedString(@"LSidebar_SupportActShtBug", @"Left Sidebar contact support Action Sheet - 'Report a Bug'"), NSLocalizedString(@"LSidebar_SupportActShtEmail", @"Left Sidebar contact support Action Sheet - 'Email Nooch Support'"), nil];
            actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheetObject setTag:1];
            [actionSheetObject showInView:self.view];
        }
        else if (indexPath.row == 2)
        {
            LimitsAndFees *laf = [LimitsAndFees new];
            [nav_ctrl pushViewController:laf animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if (indexPath.row == 3)
        {
            UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:nil
                                                                           delegate:self
                                                                  cancelButtonTitle:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text")
                                                             destructiveButtonTitle:nil
                                                                  otherButtonTitles:NSLocalizedString(@"LSidebar_LegalActSht1", @"Left Sidebar Legal Action Sheet - 'User Agreement'"), NSLocalizedString(@"LSidebar_LegalActSht2", @"Left Sidebar Legal Action Sheet - 'Privacy Policy'"), nil];
            actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheetObject setTag:2];
            [actionSheetObject showInView:self.view];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark actionsheet delegation

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet tag] == 1)
    {
        if (buttonIndex == 0)
        {
            //support center
            webView * wb = [[webView alloc]init];
            [nav_ctrl pushViewController:wb animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if (buttonIndex == 1)
        {
            //report bug
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
            
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setSubject:[NSString stringWithFormat:@"Bug Report: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
            
            mailComposer.navigationBar.tintColor=[UIColor whiteColor];
            [mailComposer setMessageBody:@"" isHTML:NO];
            [mailComposer setToRecipients:[NSArray arrayWithObjects:@"bugs@nooch.com",nil]];
            [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        else if (buttonIndex == 2)
        {
            //email support
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

            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            mailComposer.navigationBar.tintColor=[UIColor whiteColor];
            [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
            [mailComposer setMessageBody:@"" isHTML:NO];
            [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
            [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
    }
    else if ([actionSheet tag] == 2)
    {
        if (buttonIndex == 0)
        {
            isfromRegister = NO;
            terms * term = [terms new];
            [nav_ctrl pushViewController:term animated:NO];
            [self.slidingViewController resetTopView];
        } 
        else if (buttonIndex == 1) {
            privacy * priv = [privacy new];
            [nav_ctrl pushViewController:priv animated:NO];
            [self.slidingViewController resetTopView];
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
            [alert setTitle:@"Mail saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"\xF0\x9F\x93\xA4  Email Sent Successfully"];
            [alert show];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end