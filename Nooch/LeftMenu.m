//  LeftMenu.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "LeftMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "HistoryFlat.h"
#import "SettingsOptions.h"
#import "LimitsAndFees.h"
#import "Statistics.h"
#import "SendInvite.h"
#import "Legal.h"
#import "ProfileInfo.h"
#import "UIImageView+WebCache.h"
#import "assist.h"
#import "privacy.h"
#import "terms.h"
#import "webView.h"
@interface LeftMenu ()
@property(nonatomic,strong) UITableView *menu;
@property(nonatomic) NSIndexPath *selected;
@property(nonatomic,strong) UILabel *name;
@property(nonatomic,strong) UILabel *balance;
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
    [self.menu reloadData];

    UIView *user_bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    [user_bar setStyleId:@"lside_topbar_background"];
    [self.view addSubview:user_bar];

    self.name = [[UILabel alloc] initWithFrame:CGRectMake(65, 40, 150, 20)];
    [self.name setStyleId:@"lside_firstname"];
    [self.name setText:[[user objectForKey:@"firstName"] capitalizedString]];
    [user_bar addSubview:self.name];

    self.balance = [[UILabel alloc] initWithFrame:CGRectMake(60, 48, 150, 10)];
    [self.balance setStyleId:@"lside_balance"];
    [self.view addSubview:self.balance];

    user_pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 60, 60)];
    user_pic.clipsToBounds = YES;
    user_pic.layer.cornerRadius = 30;
    user_pic.layer.borderWidth = 2; user_pic.layer.borderColor = [UIColor whiteColor].CGColor;
    [user_pic setUserInteractionEnabled:YES];
    [user_bar addSubview:user_pic];
    [user_pic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(go_profile)]];

    UIView *bottom_bar = [UIView new];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [bottom_bar setStyleId:@"lside_bottombar_background_4"];
    } 
    else {
        [bottom_bar setStyleId:@"lside_bottombar_background"];
    }
    [self.view addSubview:bottom_bar];

    UIButton *settings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [settings setStyleId:@"settings_icon_4"];
    } 
    else {
        [settings setStyleId:@"settings_icon"];
    }
    [settings setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cogs"] forState:UIControlStateNormal];
    [settings addTarget:self action:@selector(go_settings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settings];
    
    UIImageView *logo = [UIImageView new];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [logo setStyleId:@"nooch_whitelogo_4"];
    } 
    else {
        [logo setStyleId:@"nooch_whitelogo"];
    }
    [self.view addSubview:logo];
    
    UILabel *version = [UILabel new];
    if ([[UIScreen mainScreen] bounds].size.height < 520) {
        [version setStyleId:@"version_label_4"];
    } 
    else {
        [version setStyleId:@"version_label"];
    }
    [version setText:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [self.view addSubview:version];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.trackedViewName = @"LeftMenu Screen";

    [self.name setText:[[user objectForKey:@"firstName"] capitalizedString]];
    [self.balance setText:[[user objectForKey:@"lastName"] capitalizedString]];
    
    if ([[user objectForKey:@"Photo"] length]>0 && [user objectForKey:@"Photo"]!=nil) {
        [user_pic setStyleId:@"lside_userpic"];
        [user_pic setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
        user_pic.clipsToBounds = YES;
        user_pic.layer.cornerRadius = 30;
        user_pic.layer.borderWidth = 2; user_pic.layer.borderColor = [UIColor whiteColor].CGColor;
        user_pic.layer.shadowColor = [UIColor redColor].CGColor;
        user_pic.layer.shadowOffset = CGSizeMake(5, 3);
        user_pic.layer.shadowOpacity = 0.97;
        user_pic.layer.shadowRadius = 3.0;

        [user_pic setUserInteractionEnabled:YES];
    }
}
-(void) go_profile {
    isProfileOpenFromSideBar=YES;
    ProfileInfo *prof = [ProfileInfo new];
    [nav_ctrl pushViewController:prof animated:YES];
    [self.slidingViewController resetTopView];
}

- (void)go_settings
{
    SettingsOptions *sets = [SettingsOptions new];
    [nav_ctrl pushViewController:sets animated:YES];
    [self.slidingViewController resetTopView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 23;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,300,22)];
    [title setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    title.textColor = [UIColor whiteColor];
    
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(64, 65, 66, .6);
    shadow.shadowOffset = CGSizeMake(0, 1);

    NSDictionary * textAttributes =
    @{NSShadowAttributeName: shadow };
    if (section == 0) {
        title.attributedText = [[NSAttributedString alloc] initWithString:@"ACCOUNT"
                                                               attributes:textAttributes];
    }
    else if(section == 1){
        title.attributedText = [[NSAttributedString alloc] initWithString:@"SOCIAL"
                                                               attributes:textAttributes];
    }
    else if(section == 2){
        title.attributedText = [[NSAttributedString alloc] initWithString:@"ABOUT"
                                                               attributes:textAttributes];
    }
    else{
        title.text = @"";
    }

    [headerView addSubview:title];
    [title setBackgroundColor:[UIColor clearColor]];
    [headerView setStyleClass:@"sectionheader_bckgrnd"];
    return headerView;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"ACCOUNT";
    }
    else if(section == 1){
        return @"DISCOVER";
    }
    else if(section == 2){
        return @"SOCIAL";
    }
    else if(section == 3){
        return @"ABOUT";
    }
    else{
        return @"";
    }
} */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }
    else if(section == 1){
        return 2;
    }
    else if(section == 2){
        return 4;
    }
    else {
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
    }
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    cell.indentationLevel = 1;
    cell.indentationWidth = 30;
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:kNoochMenu];
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Light" size:18];

    UILabel *arrow = [UILabel new];
    [arrow setStyleClass:@"lside_arrow"];
    arrow.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-right"];
    [cell.contentView addSubview:arrow];
    
    UILabel *iv = [UILabel new];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = kLeftMenuShadow;
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    NSDictionary * textAttributes =
    @{NSShadowAttributeName: shadow };
    
    [iv setStyleClass:@"lside_menu_icons"];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Home"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-home"];
        }
        else if(indexPath.row == 1){
            cell.textLabel.text = @"Transaction History";
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Transaction History"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"];
        }
        else if (indexPath.row == 2){
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Statistics"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-tachometer"];
        }
    }
    else if(indexPath.section == 9) {
        if (indexPath.row == 0) {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Donate to a Cause"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-globe"];
        }
    }
    else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Refer a Friend"
                                                                            attributes:textAttributes];
            [iv setFont:[UIFont fontWithName:@"FontAwesome" size:12]];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"];
        }
        else if(indexPath.row == 1){
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-star"];
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Rate Nooch"
                                                                attributes:textAttributes];
        }
    }
    else if(indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"How Nooch Works"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-question"];
        }
        else if(indexPath.row == 1){
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Contact Support"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope"];
        }
        else if(indexPath.row == 2){
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Limits & Fees"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-usd"];
        }
        else if(indexPath.row == 3) {
            cell.textLabel.text = @"Legal Info";
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Legal Info"
                                                                            attributes:textAttributes];
            iv.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-gavel"];
        }
    }
    [cell.contentView addSubview:iv];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ //72bf44
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            [nav_ctrl popToRootViewControllerAnimated:NO];
            [self.slidingViewController resetTopView];
        }
        else if(indexPath.row == 1) {
            //Rlease memory cache
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache clearMemory];
            [imageCache clearDisk];
            [imageCache cleanDisk];

            HistoryFlat *hist = [[HistoryFlat alloc] init];
            [nav_ctrl pushViewController:hist animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if (indexPath.row == 2) {
            Statistics *stats = [[Statistics alloc] init];
            [nav_ctrl pushViewController:stats animated:NO];
            [self.slidingViewController resetTopView];
        }
    }
    else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            SendInvite *inv = [SendInvite new];
            [nav_ctrl pushViewController:inv animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if(indexPath.row == 1) {
            //rate nooch
        }
    }
    else if(indexPath.section == 2) {
        if (indexPath.row == 0) {
            //tutorial
        }
        else if(indexPath.row == 1) {
            //contact support
            UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report a Bug", @"Email Nooch Support", @"Go to Support Center", nil];
            actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheetObject setTag:1];
            [actionSheetObject showInView:self.view];
        }
        else if(indexPath.row == 2) {
            LimitsAndFees *laf = [LimitsAndFees new];
            [nav_ctrl pushViewController:laf animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if(indexPath.row == 3) {
            UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"User Agreement", @"Privacy Policy", nil];
            actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheetObject setTag:2];
            [actionSheetObject showInView:self.view];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark actionsheet delegation

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet tag] == 1) {
        if(buttonIndex == 0) {
            //report bug
            if (![MFMailComposeViewController canSendMail]){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
            [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        else if(buttonIndex == 1) {
            //email support
            if (![MFMailComposeViewController canSendMail]){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
            [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        else if(buttonIndex == 2) {
            //support center
            webView*wb=[[webView alloc]init];
            [nav_ctrl pushViewController:wb animated:NO];
            [self.slidingViewController resetTopView];
           // 
           // [[UIApplication sharedApplication] openURL: webURL];
        }
    }
    else if ([actionSheet tag] == 2) {
        if (buttonIndex == 0) {
            terms *term = [terms new];
            [nav_ctrl pushViewController:term animated:NO];
            [self.slidingViewController resetTopView];
        } 
        else if (buttonIndex == 1) {
            privacy *priv = [privacy new];
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

            [alert setTitle:@"Mail sent"];
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