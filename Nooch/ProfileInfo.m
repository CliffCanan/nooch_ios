//  ProfileInfo.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import "ProfileInfo.h"
#import "Home.h"
#import "SettingsOptions.h"
#import <QuartzCore/QuartzCore.h>
#import "Decryption.h"
#import "NSString+AESCrypt.h"
#import "ResetPassword.h"
#import "UIImageView+WebCache.h"
#import "Welcome.h"
#import "Register.h"
#import "ECSlidingViewController.h"
#import "UIImage+Resize.h"
#import <FacebookSDK/FacebookSDK.h>
UIImageView *picture;
@interface ProfileInfo ()<FBLoginViewDelegate>{
    NSString * fbID;
}
@property(nonatomic) UIImagePickerController *picker;
@property(nonatomic,strong) UILabel *name;
@property(nonatomic,strong) UITextField *email;
@property(nonatomic,strong) UITextField *phone;
@property(nonatomic,strong) UITextField *address_one;
@property(nonatomic,strong) UITextField *address_two;
@property(nonatomic,strong) UITextField *city;
@property(nonatomic,strong) UITextField *zip;
@property(nonatomic,strong) UITableView * list;
@property(nonatomic,strong) UITableView * list2;
@property(nonatomic,strong) UIButton * save;
@property(nonatomic,strong) UIButton * resend_phone;
@property(nonatomic,strong) NSString * ServiceType;
@property(nonatomic,retain) NSString * SavePhoneNumber;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIView *member_since_back;
@property(nonatomic,strong) UIView * sectionHeaderBg2;
@property(nonatomic,strong) UIView * sectionHeaderBg;
@property(nonatomic,strong) UIView * email_NotValidated_YellowBg1;
@property(nonatomic,strong) UIView * email_NotValidated_YellowBg2;
@property(nonatomic,strong) UIView * phone_NotValidated_YellowBg1;
@property(nonatomic,strong) UIView * phone_NotValidated_YellowBg2;
@property(nonatomic,strong) UILabel * emailGlyphIndicator;
@property(nonatomic,strong) UILabel * phoneGlyphIndicator;

@end
@implementation ProfileInfo

@synthesize SavePhoneNumber;

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
    dictSavedInfo = [[NSMutableDictionary alloc]init];
    [dictSavedInfo setObject:@"NO" forKey:@"ImageChanged"];

    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setHidesBackButton:YES];

    if (isProfileOpenFromSideBar)
    {
        UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [hamburger setStyleId:@"navbar_hamburger"];
        [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
        [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
        [self.navigationItem setLeftBarButtonItem:menu];
    }
    else
    {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

        NSShadow * shadowNavText = [[NSShadow alloc] init];
        shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
        shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
        NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

        UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(savePrompt2)];

        UILabel * back_button = [UILabel new];
        [back_button setStyleId:@"navbar_back"];
        [back_button setUserInteractionEnabled:YES];
        [back_button addGestureRecognizer: backTap];
        back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

        UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

        [self.navigationItem setLeftBarButtonItem:menu];
    }

    if (!isSignup) {
        [self.slidingViewController.panGesture setEnabled:YES];
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    }

    [self.view setBackgroundColor:[UIColor whiteColor]];

    isPhotoUpdate = NO;

    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Profile_HUDloading", @"Profile Scrn initial HUD loading text");
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    [self.hud show:YES];

    [self.navigationItem setTitle:NSLocalizedString(@"Profile_ScrnTtl1", @"Profile Scrn Title")];

    int pictureRadius = 38;
    heightOfTopSection = 80;
    rowHeight = 50;
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        rowHeight = 46;
    }

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, heightOfTopSection, 320, [[UIScreen mainScreen] bounds].size.height - heightOfTopSection - 64)];
    [scrollView setBackgroundColor:Rgb2UIColor(255, 255, 255, 0)];
    // [scrollView setDelegate:self];
    scrollView.contentSize = CGSizeMake(320, [[UIScreen mainScreen] bounds].size.height);

    self.member_since_back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, heightOfTopSection)];
    if (![[assist shared] isProfileCompleteAndValidated])
    {
        [self.member_since_back setBackgroundColor:Rgb2UIColor(214, 25, 21, .55)];
        [self.member_since_back setStyleId:@"profileTopSectionBg_susp"];
    }
    else
    {
        [self.member_since_back setBackgroundColor:Rgb2UIColor(219, 220, 222, .38)];
        [self.member_since_back setStyleId:@"profileTopSectionBg"];
    }
    [self.view addSubview:self.member_since_back];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(249, 251, 252, .3);
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes_topShadow = @{NSShadowAttributeName: shadow };

    self.name = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 300, 40)];
    [self.name setTextAlignment:NSTextAlignmentCenter];
    [self.name setFont:[UIFont fontWithName:@"Roboto-regular" size:24]];
    [self.name setTextColor:kNoochGrayDark];
    self.name.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",[[user objectForKey:@"firstName"] capitalizedString],[[user objectForKey:@"lastName"] capitalizedString]] attributes:textAttributes_topShadow];
    [self.name setUserInteractionEnabled:NO];
    [self.name setTag:0];
    [self.member_since_back addSubview:self.name];

    shadowUnder = [[UIView alloc] initWithFrame:CGRectMake((160 - pictureRadius), heightOfTopSection - pictureRadius, pictureRadius * 2, (pictureRadius * 2))];
    shadowUnder.backgroundColor = Rgb2UIColor(31, 33, 32, .25);
    shadowUnder.layer.cornerRadius = pictureRadius;
    shadowUnder.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowUnder.layer.shadowOffset = CGSizeMake(0, 2);
    shadowUnder.layer.shadowOpacity = 0.3;
    shadowUnder.layer.shadowRadius = 3;
    [shadowUnder setStyleClass:@"animate_bubble"];
    [self.view addSubview:shadowUnder];

    picture = [UIImageView new];
    [picture setFrame:CGRectMake((160 - pictureRadius), heightOfTopSection - pictureRadius, pictureRadius * 2, (pictureRadius * 2))];
    picture.layer.cornerRadius = pictureRadius;
    picture.layer.borderColor = [UIColor whiteColor].CGColor;
    picture.layer.borderWidth = 2;
    picture.clipsToBounds = YES;
    [picture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change_pic)]];
    [picture setUserInteractionEnabled:YES];
    [self.view addSubview:picture];
    [picture setStyleClass:@"animate_bubble"];

    NSShadow * shadow_edit = [[NSShadow alloc] init];
    shadow_edit.shadowColor = Rgb2UIColor(33, 34, 35, .4);
    shadow_edit.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow_edit };

    UILabel * edit_label = [UILabel new];
    [edit_label setBackgroundColor:[UIColor clearColor]];
    edit_label.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profile_EditTxt", @"Profile 'Edit' Txt (for profile pic)") attributes:textAttributes];
    [edit_label setFont:[UIFont fontWithName:@"Roboto-regular" size:12]];
    [edit_label setFrame:CGRectMake(0, (pictureRadius * 2) - 18, pictureRadius * 2, 12)];
    [edit_label setTextAlignment:NSTextAlignmentCenter];
    [edit_label setTextColor:[UIColor whiteColor]];
    [picture addSubview:edit_label];

    UILabel * bankLinkedTxt = [[UILabel alloc] initWithFrame:CGRectMake(23, 4, 100, 32)];
    [bankLinkedTxt setBackgroundColor:[UIColor clearColor]];
    [bankLinkedTxt setTextColor:[Helpers hexColor:@"313233"]];
    [bankLinkedTxt setTextAlignment:NSTextAlignmentCenter];

    UILabel * glyph_bank = [[UILabel alloc] initWithFrame:CGRectMake(14, 6, 16, 27)];
    [glyph_bank setFont:[UIFont fontWithName:@"FontAwesome" size:12]];
    [glyph_bank setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bank"]];

    UIButton * goToSettings = [[UIButton alloc] initWithFrame:CGRectMake(1, 1, 101, 32)];
    goToSettings.backgroundColor = [UIColor clearColor];
    [goToSettings addTarget:self action:@selector(goToSettings1) forControlEvents:UIControlEventTouchUpInside];
    [goToSettings addSubview:bankLinkedTxt];
    [goToSettings addSubview:glyph_bank];

    if ((isKnoxOn && [user boolForKey:@"IsKnoxBankAvailable"]) ||
        (isSynapseOn && [user boolForKey:@"IsSynapseBankAvailable"]))
    {
        [bankLinkedTxt setFont:[UIFont fontWithName:@"Roboto-regular" size:13]];
        bankLinkedTxt.text = NSLocalizedString(@"Profile_BnkLnkd", @"Profile 'Bank Linked' text");

        [glyph_bank setTextColor:kNoochGreen];
        [glyph_bank setAlpha:1];
    }
    else
    {
        [bankLinkedTxt setFont:[UIFont fontWithName:@"Roboto-regular" size:11]];
        bankLinkedTxt.text = NSLocalizedString(@"Profile_NoBankTxt", @"Profile 'No Funding Source' text");

        [glyph_bank setTextColor:kNoochGrayDark];
        [glyph_bank setAlpha:.65];
        [glyph_bank setFrame:CGRectMake(5, 6, 15, 25)];

        UILabel * glyph_bankX = [[UILabel alloc] initWithFrame:CGRectMake(18, 5, 8, 22)];
        [glyph_bankX setFont:[UIFont fontWithName:@"FontAwesome" size:11]];
        [glyph_bankX setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation"]];
        [glyph_bankX setTextColor:kNoochRed];
        [goToSettings addSubview:glyph_bankX];
    }
    [scrollView addSubview:goToSettings];

    start = [[user valueForKey:@"DateCreated"] rangeOfString:@"("];
    end = [[user valueForKey:@"DateCreated"] rangeOfString:@")"];

    if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location)
    {
        betweenBraces = [[user valueForKey:@"DateCreated"] substringWithRange:NSMakeRange(start.location+1, end.location-(start.location + 1))];
    }

    newString = [betweenBraces substringToIndex:[betweenBraces length]-8];

    NSTimeInterval _interval = [newString doubleValue];

    NSDate * date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"M/d/yyyy"];
    NSString *_date=[_formatter stringFromDate:date];

    UILabel * memSincelbl = [[UILabel alloc] initWithFrame:CGRectMake(206, 5, 110, 19)];
    memSincelbl.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profile_MemSinceTxt", @"Profile 'Member Since' text")
                                                                 attributes:textAttributes_topShadow];
    memSincelbl.userInteractionEnabled = NO;
    [memSincelbl setBackgroundColor:[UIColor clearColor]];
    [memSincelbl setFont:[UIFont fontWithName:@"Roboto-regular" size:14]];
    [memSincelbl setTextColor:[Helpers hexColor:@"313233"]];
    [memSincelbl setTextAlignment:NSTextAlignmentCenter];
    [scrollView addSubview:memSincelbl];

    UILabel * dateText = [[UILabel alloc] initWithFrame:CGRectMake(206, 25, 110, 17)];
    dateText.userInteractionEnabled = NO;
    [dateText setBackgroundColor:[UIColor clearColor]];
    [dateText setText:[NSString stringWithFormat:@"%@",_date]];
    [dateText setFont:[UIFont fontWithName:@"Roboto-light" size:13]];
    [dateText setTextColor:[Helpers hexColor:@"313233"]];
    [dateText setTextAlignment:NSTextAlignmentCenter];
    [scrollView addSubview:dateText];

    self.email = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, rowHeight)];
    [self.email setTextAlignment:NSTextAlignmentRight];
    [self.email setPlaceholder:@"email@email.com"];
    [self.email setDelegate:self];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    self.email.returnKeyType = UIReturnKeyNext;
    [self.email setStyleClass:@"tableViewCell_Profile_rightSide"];
    [self.email setText:[user objectForKey:@"UserName"]];
    [self.email setUserInteractionEnabled:NO];
    [self.email setTag:0];
    [scrollView addSubview:self.email];

    /* // Recovery Mail
     self.recovery_email = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
     [self.recovery_email setTextAlignment:NSTextAlignmentRight];
     [self.recovery_email setBackgroundColor:[UIColor clearColor]];
     [self.recovery_email setPlaceholder:@"(Optional)"];
     [self.recovery_email setDelegate:self];
     [self.recovery_email setKeyboardType:UIKeyboardTypeEmailAddress];
     self.recovery_email.returnKeyType = UIReturnKeyNext;
     [self.recovery_email setStyleClass:@"table_view_cell_detailtext_1"];
     [self.recovery_email setTag:1];
     [self.view addSubview:self.recovery_email]; */

    self.phone = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, rowHeight)];
    [self.phone setTextAlignment:NSTextAlignmentRight];
    [self.phone setBackgroundColor:[UIColor clearColor]];
    [self.phone setPlaceholder:@"(215) 555-1234"];
    [self.phone setDelegate:self];
    [self.phone setKeyboardType:UIKeyboardTypeNumberPad];
    self.phone.returnKeyType = UIReturnKeyNext;
    [self.phone setStyleClass:@"tableViewCell_Profile_rightSide"];
    [self.phone setTag:2];

    self.save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.save setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    self.save.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.save addTarget:self action:@selector(save_changes) forControlEvents:UIControlEventTouchUpInside];
    [self.save setTitle:@"Save" forState:UIControlStateNormal];
    [self.save setStyleClass:@"nav_top_right"];
    [self.save setStyleClass:@"disabled_gray"];
    [self.save setEnabled:NO];
    [self.save setUserInteractionEnabled:NO];

    UIBarButtonItem * nav_save = [[UIBarButtonItem alloc] initWithCustomView:self.save];
    [self.navigationItem setRightBarButtonItem:nav_save animated:YES];

    GMTTimezonesDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Samoa Standard Time",@"GMT-11:00",
                              @"Hawaiian Standard Time",@"GMT-10:00",
                              @"Alaskan Standard Time",@"GMT-09:00",
                              @"Pacific Standard Time",@"GMT-08:00",
                              @"Mountain Standard Time",@"GMT-07:00",
                              @"Central Standard Time",@"GMT-06:00",
                              @"Eastern Standard Time",@"GMT-05:00",
                              @"Atlantic Standard Time",@"GMT-04:00",
                              nil];

    hdrHt = 30;
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        hdrHt = 26;
    }
    self.sectionHeaderBg = [[UIView alloc] initWithFrame:CGRectMake(0, pictureRadius + 16, 320, hdrHt)];
    self.sectionHeaderBg.backgroundColor = Rgb2UIColor(230, 231, 232, .4);

    UILabel * sectionHeaderTxt = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, self.sectionHeaderBg.frame.size.height)];
    sectionHeaderTxt.backgroundColor = [UIColor clearColor];
    sectionHeaderTxt.textColor = [UIColor darkGrayColor];
    sectionHeaderTxt.font = [UIFont fontWithName:@"Roboto-light" size:15];
    sectionHeaderTxt.text = NSLocalizedString(@"Profile_TblHdr_Contact", @"Profile 'CONTACT INFO' Txt");
    sectionHeaderTxt.textAlignment = NSTextAlignmentLeft;
    [self.sectionHeaderBg addSubview:sectionHeaderTxt];
    [scrollView addSubview:self.sectionHeaderBg];

    self.list = [UITableView new];
    [self.list setFrame:CGRectMake(0, self.sectionHeaderBg.frame.origin.y + self.sectionHeaderBg.frame.size.height, 320, rowHeight * 3)];
    [self.list setDelegate:self];
    [self.list setDataSource:self];
    [self.list setRowHeight:rowHeight];
    [self.list setAllowsSelection:YES];
    [self.list setScrollEnabled:NO];
    [self.list setBackgroundColor:[UIColor whiteColor]];

    if (![[user valueForKey:@"Status"] isEqualToString:@"Registered"] &&
         [[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"])
    {
        [self.list setFrame:CGRectMake(0, pictureRadius + 18 + self.sectionHeaderBg.frame.size.height, 320, rowHeight * 2)];
        numberOfRowsToDisplay = 2;
        emailVerifyRowIsShowing = false;
        smsVerifyRowIsShowing = false;
    }
    else if ((![[user valueForKey:@"Status"] isEqualToString:@"Registered"] &&
              ![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"]) ||
             ( [[user valueForKey:@"Status"] isEqualToString:@"Registered"] &&
               [[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"]) )
    {
        numberOfRowsToDisplay = 3;
        [self.list setFrame:CGRectMake(0, pictureRadius + 18 + self.sectionHeaderBg.frame.size.height, 320, rowHeight * 3)];
        
        if ([[user valueForKey:@"Status"] isEqualToString:@"Registered"])
        {
            emailVerifyRowIsShowing = true;
        }
        else if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"])
        {
            smsVerifyRowIsShowing = true;
        }
    }
    else if (![[user valueForKey:@"Status"] isEqualToString:@"Active"] &&
             ![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"])
    {
        numberOfRowsToDisplay = 4;
        [self.list setFrame:CGRectMake(0, pictureRadius + 18 + self.sectionHeaderBg.frame.size.height, 320, rowHeight * 4)];

        emailVerifyRowIsShowing = true;
        smsVerifyRowIsShowing = true;
    }

    self.sectionHeaderBg2 = [[UIView alloc] initWithFrame:CGRectMake(0, (self.list.frame.origin.y + self.list.frame.size.height), 320, self.sectionHeaderBg.frame.size.height)];
    self.sectionHeaderBg2.backgroundColor = Rgb2UIColor(230, 231, 232, .4);

    UILabel * sectionHeaderTxt2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, self.sectionHeaderBg2.frame.size.height)];
    sectionHeaderTxt2.backgroundColor = [UIColor clearColor];
    sectionHeaderTxt2.textColor = [UIColor darkGrayColor];
    sectionHeaderTxt2.font = [UIFont fontWithName:@"Roboto-light" size:15];
    sectionHeaderTxt2.text = NSLocalizedString(@"Profile_TblHdr_Address", @"Profile 'ADDRESS' Txt");
    sectionHeaderTxt2.textAlignment = NSTextAlignmentLeft;
    [self.sectionHeaderBg2 addSubview:sectionHeaderTxt2];
    [scrollView addSubview:self.sectionHeaderBg2];

    self.list2 = [UITableView new];
    [self.list2 setFrame:CGRectMake(0, self.sectionHeaderBg2.frame.origin.y + self.sectionHeaderBg2.frame.size.height, 320, (rowHeight * 4) + 15)];
    [self.list2 setDelegate:self];
    [self.list2 setDataSource:self];
    [self.list2 setRowHeight:rowHeight];
    [self.list2 setBackgroundColor:[UIColor whiteColor]];
    [self.list2 setAllowsSelection:YES];
    [self.list2 setScrollEnabled:NO];

    [scrollView addSubview:self.list];
    [scrollView addSubview:self.list2];
    [self.view addSubview:scrollView];

    [self.view bringSubviewToFront:shadowUnder];
    [self.view bringSubviewToFront:picture];

    self.emailGlyphIndicator = [UILabel new];
    self.phoneGlyphIndicator = [UILabel new];

    self.email_NotValidated_YellowBg1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, rowHeight)];
    [self.email_NotValidated_YellowBg1 setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];

    self.email_NotValidated_YellowBg2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, rowHeight)];
    [self.email_NotValidated_YellowBg2 setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];

    self.phone_NotValidated_YellowBg1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, rowHeight)];
    [self.phone_NotValidated_YellowBg1 setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];

    self.phone_NotValidated_YellowBg2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, rowHeight)];
    [self.phone_NotValidated_YellowBg2 setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterFG_Profile:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    self.screenName = @"Profile Screen";
    self.artisanNameTag = @"Profile Screen";

    [self.navigationItem setTitle:NSLocalizedString(@"Profile_ScrnTtl2", @"'Profile' Screen Title")];

    if ([[user objectForKey:@"Photo"] length] > 0 && [user objectForKey:@"Photo"] != nil && !isPhotoUpdate)
    {
        [picture sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self checkUsersStatus];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)applicationWillEnterFG_Profile:(NSNotification *)notification
{
    //NSLog(@"Checkpoint: applicationWillEnterFG notification");
    [self checkUsersStatus];
}

-(void)checkUsersStatus
{
    serve *serveOBJ = [serve new ];
    serveOBJ.tagName = @"myset";
    [serveOBJ setDelegate:self];
    [serveOBJ getSettings];
}

-(void)showMenu
{
    [self savePrompt];
}

-(void)GoBackOnce
{
    if (isSignup)
    {
        [[assist shared] setneedsReload:YES];

        [self.navigationController setNavigationBarHidden:NO];
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                         }];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
        isSignup = NO;
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)goToSettings1
{
    if (isProfileOpenFromSideBar || sentFromHomeScrn || isFromTransDetails)
    {
        SettingsOptions * sets = [SettingsOptions new];
        NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];
        [arrNav insertObject:sets atIndex:[arrNav count] - 1];
        [nav_ctrl setViewControllers:arrNav animated:NO];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)savePrompt2
{
    if ( [[dictSavedInfo valueForKey:@"ImageChanged"]isEqualToString:@"YES"] ||
         (self.address_one.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address1"]isEqualToString:self.address_one.text]) ||
         (self.address_two.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address2"]isEqualToString:self.address_two.text]) ||
         (self.zip.text.length > 2 && ![[dictSavedInfo valueForKey:@"zip"]isEqualToString:self.zip.text]) ||
         (self.city.text.length > 2 && ![[dictSavedInfo valueForKey:@"City"]isEqualToString:self.city.text]) ||
         (self.phone.text.length > 3 && ![[dictSavedInfo valueForKey:@"phoneno"]isEqualToString:self.phone.text]) )
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Profile_SaveAlrtTitle1", @"Profile 'Save Changes' Alert Title")
                                                        message:NSLocalizedString(@"Profile_SaveAlrtBody1", @"Profile Save Changes Alert Body Text")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Profile_AlrtBtnYes1", @"Profile 'Yes' Button Text")
                                              otherButtonTitles:NSLocalizedString(@"Profile_AlrtBtnNo1", @"Profile 'No' Button Text"), nil];
        [alert setTag:5021];
        [alert show];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self performSelector:@selector(GoBackOnce) withObject:nil];
    }
}

-(void)savePrompt
{
    if ( [[dictSavedInfo valueForKey:@"ImageChanged"]isEqualToString:@"YES"] ||
        (self.address_one.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address1"]isEqualToString:self.address_one.text]) ||
        (self.address_two.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address2"]isEqualToString:self.address_two.text]) ||
        (self.zip.text.length > 2 && ![[dictSavedInfo valueForKey:@"zip"]isEqualToString:self.zip.text]) ||
        (self.city.text.length > 2 && ![[dictSavedInfo valueForKey:@"City"]isEqualToString:self.city.text]) ||
        (self.phone.text.length > 3 && ![[dictSavedInfo valueForKey:@"phoneno"]isEqualToString:self.phone.text]) )
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Save Changes"
                                                        message:@"Do you want to save the changes in your profile?"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Profile_AlrtBtnYes2", @"Profile 'YES' Button Text")
                                              otherButtonTitles:NSLocalizedString(@"Profile_AlrtBtnNo2", @"Profile 'NO' Button Text"), nil];
        [alert setTag:5020];
        [alert show];

        return;
    }
    else
    {
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag == 5020 || alertView.tag == 5021) && buttonIndex == 0)
    {
        [self save_changes];
    }
    else if (alertView.tag == 5020 && buttonIndex == 1)
    {
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
    else if (alertView.tag == 5021 && buttonIndex == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 1001 && buttonIndex == 0)
    {
        [self.name setUserInteractionEnabled:YES];
        [self.name becomeFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.name resignFirstResponder];
    [self.email resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.address_one resignFirstResponder];
    [self.address_two resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zip resignFirstResponder];
}

-(void)resend_email
{
    serve *email_verify = [serve new];
    [email_verify setDelegate:self];
    [email_verify setTagName:@"email_verify"];
    [email_verify resendEmail];
}

-(void)resend_SMS
{
    if ([[dictSavedInfo valueForKey:@"phoneno"] length] > 9)
    {
        serve *sms_verify = [serve new];
        [sms_verify setDelegate:self];
        [sms_verify setTagName:@"sms_verify"];
        [sms_verify resendSMS];
    }
    else
    {
        [self.phone becomeFirstResponder];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Profile_PhnTrblAlrtTtl", @"Profile 'Phone Number Trouble' Alert Title")
                                                        message:NSLocalizedString(@"Profile_PhnTrblAlrtBody", @"Profile Phone Number Trouble Alert Body Text")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

-(BOOL)validateEmail:(NSString*)emailStr;
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,3}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailCheck];
    return [emailTest evaluateWithObject:emailStr];
}

-(void)save_changes
{
    [self.name resignFirstResponder];
    [self.email resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.address_one resignFirstResponder];
    [self.address_two resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zip resignFirstResponder ];

    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:CGRectMake(0,64, 320, 600)];
    [UIView commitAnimations];

    if ([self.name.text length] == 0)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_NoNameAlrtTtl", @"Profile 'Need A Name' Alert Title")
                                                      message:[NSString stringWithFormat:@"\xF0\x9F\x99\x87\n%@", NSLocalizedString(@"Profile_NoNameAlrtBody", @"Profile Need A Name Alert Body Text")]
                                                     delegate:Nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:Nil, nil];
        [av show];
        return;
    }

    if (![self validateEmail:[self.email text]])
    {
        [self.email becomeFirstResponder];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Profile_InvldEmlAlrtTtl", @"Profile 'Invalid Email Address' Alert Title")
                                                        message:NSLocalizedString(@"Profile_InvldEmlAlrtBdy", @"Profile 'Invalid Email Address' Alert Body Text")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    if ([self.address_one.text length] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Missing An Address"
                                                        message:@"To keep Nooch safe, we ask all users to provide an address as part of our ID verification process.\n\n(We never share your personal info with anyone.)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [self.address_one becomeFirstResponder];
        return;
    }
    else if ([self.city.text length] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"How Bout A City"
                                                        message:@"\xF0\x9F\x98\x89\nIt would be fantastic if you entered a city!\n\n(We only ask to help make sure people use their real identity so Nooch stays safe for everyone.)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [self.city becomeFirstResponder];
        return;
    }

    [self.save setEnabled:NO];
    [self.save setUserInteractionEnabled:NO];
    [self.save setStyleClass:@"disabled_gray"];

    strPhoneNumber = self.phone.text;
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (![self.SavePhoneNumber isEqualToString:strPhoneNumber] || [self.SavePhoneNumber length] == 0)
    {
        if ([strPhoneNumber length] != 10)
        {
            [self.phone becomeFirstResponder];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Profile_PhnTrblAlrtTtl2", @"Profile 'Phone Number Trouble' Alert Title (2nd)")
                                                            message:NSLocalizedString(@"Profile_PhnTrblAlrtBody2", @"Profile 'Phone Number Trouble' Alert Body Text (2nd)")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }

    if ([[me pic] isKindOfClass:[NSNull class]])
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_NoPicAlrtTitle", @"Profile 'I don't see you!' Alert Title")
                                                      message:[NSString stringWithFormat:@"\xF0\x9F\x91\x80\n\n%@", NSLocalizedString(@"Profile_NoPicAlrtBody", @"Profile 'I don't see you!' Alert Body Text")]
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Profile_NoPicAlrtBtnNo", @"Profile I don't see you Alert 'No Thanks' Btn")
                                            otherButtonTitles:NSLocalizedString(@"Profile_NoPicAlrtBtnYes", @"Profile I don't see you! Alert 'Yes - Set Now' Btn"),nil];
        [av setTag:20];
        [av show];
    }

    timezoneStandard = [NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone]];
    timezoneStandard = [[timezoneStandard componentsSeparatedByString:@", "] objectAtIndex:0];
    timezoneStandard = [GMTTimezonesDictionary objectForKey:timezoneStandard];
    timezoneStandard = @"";

    recoverMail = [[NSString alloc] init];

    if ([self.address_two.text length] != 0)
    {
        [[me usr] setObject:self.address_two.text forKey:@"Addr2"];
        [[me usr] setObject:self.address_two.text forKey:@"Addr1"];
    }
    else
    {
        [[me usr] removeObjectForKey:@"Addr2"];
    }

    NSArray *arrdivide = [self.name.text componentsSeparatedByString:@" "];
    
    if ([arrdivide count] == 2)
    {
        transactionInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[user stringForKey:@"MemberId"],@"MemberId",[arrdivide objectAtIndex:0],@"FirstName",[arrdivide objectAtIndex:1],@"LastName",self.email.text,@"UserName",nil];

        self.name.text = [NSString stringWithFormat:@"%@ %@",[[arrdivide objectAtIndex:0] capitalizedString],[[arrdivide objectAtIndex:1] capitalizedString]];
    }
    else
    {
        transactionInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[user stringForKey:@"MemberId"],@"MemberId",self.name.text,@"FirstName",@" ",@"LastName",self.email.text,@"UserName",nil];
    }

    [transactionInput setObject:[NSString stringWithFormat:@"%@/%@",self.address_one.text,self.address_two.text] forKey:@"Address"];
    if ([self.city.text length] > 0)
    {
        [transactionInput setObject:self.city.text forKey:@"City"];
    }
    else
    {
        [transactionInput setObject:@"" forKey:@"City"];
    }


    if ( [[assist shared]islocationAllowed])
    {
        [transactionInput setObject:[[assist shared]islocationAllowed]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"ShowInSearch"];
    }
    else
        [transactionInput setObject:[[assist shared]islocationAllowed]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"ShowInSearch"];
    [transactionInput setObject:strPhoneNumber forKey:@"ContactNumber"];
    [transactionInput setObject:self.zip.text forKey:@"Zipcode"];
    [transactionInput setObject:@"false" forKey:@"UseFacebookPicture"];
    [transactionInput setObject:@".png" forKey:@"fileExtension"];
    [transactionInput setObject:recoverMail forKey:@"RecoveryMail"];
    [transactionInput setObject:timezoneStandard forKey:@"TimeZoneKey"];
    
    if ([[assist shared] getTranferImage])
    {
        NSData *data;
        data = UIImagePNGRepresentation([[assist shared] getTranferImage]);

        NSUInteger len = data.length;
        uint8_t *bytes = (uint8_t *)[data bytes];
        NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];

        for (NSUInteger i = 0; i < len; i++)
        {
            if (i) {
                [result1 appendString:@","];
            }
            [result1 appendFormat:@"%d", bytes[i]];
        }
        NSArray * arr = [result1 componentsSeparatedByString:@","];
        [transactionInput setObject:arr forKey:@"Picture"];
    }

    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.delegate = self;
    self.hud.labelText = NSLocalizedString(@"Profile_HUDsaving", @"Profile HUD 'Saving Your Profile' Text");
    [self.hud show:YES];
    
    transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"mySettings", nil];
    serve * req = [serve new];
    req.Delegate = self;
    req.tagName = @"MySettingsResult";
    [req setSets:transaction];
}

-(void)change_pic
{
    UIActionSheet * actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"Add A Profile Picture"
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Profile_CancelTxt", @"Profile 'Cancel' Text")//
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Use Facebook Picture",NSLocalizedString(@"Profile_UseCamera", @"Profile 'Use Camera' Text"), NSLocalizedString(@"Profile_FrmLbry", @"Profile 'From iPhone Library' Text"), nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self toggleFacebookLogin];
    }
    else if (buttonIndex == 1)
    {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_ErrorTxt", @"Profile 'Error' Text")
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            [myAlertView show];
            return;
        }

        self.picker = [UIImagePickerController new];
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.picker animated:YES completion:Nil];
    }
    else if (buttonIndex == 2)
    {
        self.picker = [UIImagePickerController new];
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.picker animated:YES completion:Nil];
    }
}

-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;

    if (imgRatio != maxRatio)
    {
        if (imgRatio < maxRatio)
        {
            imgRatio = 115.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 115.0;
        }
        else
        {
            imgRatio = 75.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 75.0;
        }
    }

    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark-ImagePicker
-(void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    option = 1;
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(120,120) interpolationQuality:kCGInterpolationMedium];
    [picture setImage:image];
    [[assist shared]setTranferImage:image];

    isPhotoUpdate = YES;

    [self.save setEnabled:YES];
    [self.save setUserInteractionEnabled:YES];
    [self.save setStyleClass:@"nav_top_right"];
    [dictSavedInfo setObject:@"YES" forKey:@"ImageChanged"];

    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)toggleFacebookLogin
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [self userLoggedIn];
    }
    else // If the session state is NOT any of the two "open" states when the button is clicked
    {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Call the sessionStateChanged:state:error method to handle session state changes
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        NSLog(@"FB Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    // If the session is closed
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {
        NSLog(@"FB Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    // Handle errors
    if (error)
    {
        NSLog(@"FB Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");
            }
            // Handle session closures that happen outside of the app
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
            }
            // For simplicity, here we just show a generic message for all other errors
            // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\nIf the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Facebook: Show the user the logged-out UI
-(void)userLoggedOut
{
    [picture setImage:[UIImage imageNamed:@"silhouette.png"]];
}

// Facebook: Show the user the logged-in UI
-(void)userLoggedIn
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
        if (!error)
        {
            // Success! Now set the facebook_id to be the fb_id that was just returned & send to Nooch DB
            fbID = [result objectForKey:@"id"];
            [ARProfileManager setUserFacebook:fbID];

            [user setObject:fbID forKey:@"facebook_id"];
            [user synchronize];

            NSString * imgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", fbID];
            [ARProfileManager setUserAvatarUrl:imgURL];

            [picture sd_setImageWithURL:[NSURL URLWithString:imgURL]
                       placeholderImage:[UIImage imageNamed:@"RoundLoading"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  if (image) {
                                      [picture setImage:image];
                                      [[assist shared]setTranferImage:nil];
                                      [[assist shared]setTranferImage:image];
                                  }
            }];

            isPhotoUpdate = YES;

            [self.save setEnabled:YES];
            [self.save setUserInteractionEnabled:YES];
            [self.save setStyleClass:@"nav_top_right"];
            [dictSavedInfo setObject:@"YES" forKey:@"ImageChanged"];

            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache clearMemory];
            [imageCache clearDisk];
            [imageCache cleanDisk];
        }
        else
        {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
}

// Show an alert message (For Facebook methods)
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.list)
    {
        return numberOfRowsToDisplay;
    }
    else
    {
        return 4;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        cell.clipsToBounds = YES;
    }

    NSShadow * shadow_white = [[NSShadow alloc] init];
    shadow_white.shadowColor = Rgb2UIColor(255, 252, 252, .4);
    shadow_white.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes_white = @{NSShadowAttributeName: shadow_white };
    
    if (tableView == self.list)
    {
        if (indexPath.row == 0)
        {
            UILabel * mail = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
            [mail setBackgroundColor:[UIColor clearColor]];
            [mail setStyleClass:@"tableViewCell_Profile_leftSide"];
            mail.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profile_EmailTxt", @"Profile 'Email' Text")
                                                                  attributes:textAttributes_white];

            if ([[user valueForKey:@"Status"] isEqualToString:@"Registered"])
            {
                [cell.contentView addSubview:self.email_NotValidated_YellowBg1];
                [cell.contentView addSubview:self.emailGlyphIndicator];
            }
            else
            {
                [cell.contentView addSubview:self.emailGlyphIndicator];
            }

            [cell.contentView addSubview:mail];
            [cell.contentView addSubview:self.email];
        }
        /*else if (indexPath.row == 2)
        {
            UILabel * recover = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
            [recover setBackgroundColor:[UIColor clearColor]];
            [recover setText:@"Recovery Email"];

            [recover setStyleClass:@"table_view_cell_textlabel_1"];
            [cell.contentView addSubview:recover];
            [cell.contentView addSubview:self.recovery_email];
        }*/
        if ( indexPath.row == 1 &&
            [[user valueForKey:@"Status"] isEqualToString:@"Registered"])
        {
            [cell.contentView addSubview:self.email_NotValidated_YellowBg2];

            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowColor = Rgb2UIColor(255, 252, 249, .25);
            shadow.shadowOffset = CGSizeMake(0, 1);
            NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
    
            UILabel * emailVerifiedStatus = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 130, rowHeight)];
            [emailVerifiedStatus setBackgroundColor:[UIColor clearColor]];
            [emailVerifiedStatus setStyleClass:@"notVerifiedLabel"];
            emailVerifiedStatus.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profile_NotVerifTxt", @"Profile 'Not Verified' Text") attributes:textAttributes];
            [cell.contentView addSubview:emailVerifiedStatus];

            UIButton * resend_mail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [resend_mail setFrame:CGRectMake(200, ((rowHeight - 30) / 2), 105, 30)];
            [resend_mail setStyleClass:@"button_green_sm"];
            [resend_mail addTarget:self action:@selector(resend_email) forControlEvents:UIControlEventTouchUpInside];
            [resend_mail setTitle:NSLocalizedString(@"Profile_ResendEmBtn", @"Profile 'Resend Email' Text") forState:UIControlStateNormal];
            [resend_mail setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
            resend_mail.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
            [cell.contentView addSubview:resend_mail];
        }
        else if ( indexPath.row == 1 ||
                 (indexPath.row == 2 && [[user valueForKey:@"Status"] isEqualToString:@"Registered"]) )
        {
            UILabel * num = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
            [num setBackgroundColor:[UIColor clearColor]];
            [num setStyleClass:@"tableViewCell_Profile_leftSide"];
            num.attributedText = [[NSAttributedString alloc] initWithString:@"Phone" attributes:textAttributes_white];
            
            if (![[user objectForKey:@"IsVerifiedPhone"] isEqualToString:@"YES"])
            {
                [cell.contentView addSubview:self.phone_NotValidated_YellowBg1];

                [cell.contentView addSubview:self.phoneGlyphIndicator];
            }
            else
            {
                [cell.contentView addSubview:self.phoneGlyphIndicator];
            }

            [cell.contentView addSubview:num];
            [cell.contentView addSubview:self.phone];
        }

        if ( (indexPath.row == 2 && ![[user valueForKey:@"Status"] isEqualToString:@"Registered"]) ||
              (indexPath.row == 3 && ![[user objectForKey:@"IsVerifiedPhone"] isEqualToString:@"YES"] &&
               [[user valueForKey:@"Status"] isEqualToString:@"Registered"]) )
        {
            [cell.contentView addSubview:self.phone_NotValidated_YellowBg2];

            UILabel * phoneVerifiedStatus = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 130, rowHeight)];
            [phoneVerifiedStatus setBackgroundColor:[UIColor clearColor]];
            [phoneVerifiedStatus setStyleClass:@"notVerifiedLabel"];
            [cell.contentView addSubview:phoneVerifiedStatus];

            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowColor = Rgb2UIColor(255, 252, 249, .3);
            shadow.shadowOffset = CGSizeMake(0, 1);
            NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
            phoneVerifiedStatus.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Profile_NotVerifTxt2", @"Profile 'Not Verified' Text (2nd)") attributes:textAttributes];

            self.resend_phone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [self.resend_phone setTitle:NSLocalizedString(@"Profile_ResendSmsBtn", @"Profile 'Resend SMS' Btn Text") forState:UIControlStateNormal];
            [self.resend_phone addTarget:self action:@selector(resend_SMS) forControlEvents:UIControlEventTouchUpInside];
            [self.resend_phone setFrame:CGRectMake(200, ((rowHeight - 30) / 2), 105, 30)];
            if ([self.phone.text length] > 8)
            {
                [self.resend_phone setUserInteractionEnabled:YES];
                [self.resend_phone setStyleClass:@"button_green_sm"];
            }
            else
            {
                [self.resend_phone setHidden:YES];
                [self.resend_phone setUserInteractionEnabled:NO];
            }
            [self.resend_phone setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
            self.resend_phone.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
            [cell.contentView addSubview:self.resend_phone];
        }
    }

    else if (tableView == self.list2)
    {
        if (indexPath.row == 0)
        {
            UILabel * addr1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
            [addr1 setBackgroundColor:[UIColor clearColor]];
            [addr1 setText:NSLocalizedString(@"Profile_AddressTxt", @"Profile 'Address' Text")];
            [addr1 setStyleClass:@"tableViewCell_Profile_leftSide"];
            [cell.contentView addSubview:addr1];

            self.address_one = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, rowHeight)];
            [self.address_one setTextAlignment:NSTextAlignmentRight];
            [self.address_one setBackgroundColor:[UIColor clearColor]];
            [self.address_one setPlaceholder:NSLocalizedString(@"Profile_AdrsPlchldrt", @"Profile address placeholder Text")];//@"123 Nooch St"
            [self.address_one setDelegate:self];
            [self.address_one setKeyboardType:UIKeyboardTypeDefault];
            self.address_one.returnKeyType = UIReturnKeyNext;
            [self.address_one setStyleClass:@"tableViewCell_Profile_rightSide"];
            [self.address_one setTag:3];
            [self.address_one setUserInteractionEnabled:YES];
            [cell.contentView addSubview:self.address_one];
        }
        else if (indexPath.row == 1)
        {
            UILabel * addr2 = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
            [addr2 setBackgroundColor:[UIColor clearColor]];
            [addr2 setText:NSLocalizedString(@"Profile_Address2Txt", @"Profile 'Address2' Text")];
            [addr2 setStyleClass:@"tableViewCell_Profile_leftSide"];
            [cell.contentView addSubview:addr2];

            self.address_two = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, rowHeight)];
            [self.address_two setTextAlignment:NSTextAlignmentRight];
            [self.address_two setBackgroundColor:[UIColor clearColor]];
            [self.address_two setPlaceholder:NSLocalizedString(@"Profile_Adrs2Plchldr", @"Profile '(Optional)' Text")];
            [self.address_two setDelegate:self];
            [self.address_two setKeyboardType:UIKeyboardTypeDefault];
            self.address_two.returnKeyType = UIReturnKeyNext;
            [self.address_two setStyleClass:@"tableViewCell_Profile_rightSide"];
            [self.address_two setTag:4];
            [self.address_two setUserInteractionEnabled:YES];
            [cell.contentView addSubview:self.address_two];
        }
        else if (indexPath.row == 2)
        {
            UILabel * city_lbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
            [city_lbl setBackgroundColor:[UIColor clearColor]];
            [city_lbl setText:NSLocalizedString(@"Profile_CityTxt", @"Profile 'City' Text")];
            [city_lbl setStyleClass:@"tableViewCell_Profile_leftSide"];
            [cell.contentView addSubview:city_lbl];

            self.city = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, rowHeight)];
            [self.city setTextAlignment:NSTextAlignmentRight];
            [self.city setBackgroundColor:[UIColor clearColor]];
            [self.city setPlaceholder:NSLocalizedString(@"Profile_CityPlchldr", @"Profile 'City' Placeholder")];
            [self.city setDelegate:self];
            [self.city setTag:5];
            [self.city setKeyboardType:UIKeyboardTypeDefault];
            self.city.returnKeyType = UIReturnKeyNext;
            [self.city setStyleClass:@"tableViewCell_Profile_rightSide"];
            [self.city setUserInteractionEnabled:YES];
            [cell.contentView addSubview:self.city];
        }
        else if (indexPath.row == 3)
        {
            UILabel * zip_lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 140, rowHeight)];
            [zip_lbl setBackgroundColor:[UIColor clearColor]];
            [zip_lbl setText:NSLocalizedString(@"Profile_ZipTxt", @"Profile 'ZIP' Text")];
            [zip_lbl setStyleClass:@"tableViewCell_Profile_leftSide"];
            [cell.contentView addSubview:zip_lbl];

            self.zip = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, rowHeight)];
            [self.zip setTextAlignment:NSTextAlignmentRight];
            [self.zip setBackgroundColor:[UIColor clearColor]];
            [self.zip setPlaceholder:NSLocalizedString(@"Profile_ZipPlchldr", @"Profile '90210' placeholder text")];
            [self.zip setDelegate:self];
            [self.zip setKeyboardType:UIKeyboardTypeNumberPad];
            [self.zip setStyleClass:@"tableViewCell_Profile_rightSide"];
            [self.zip setUserInteractionEnabled:YES];
            if ([UIScreen mainScreen].bounds.size.height == 480) {
                [self.zip setTag:6];
            }
            else {
                [self.zip setTag:5];
            }
            [cell.contentView addSubview:self.zip];
        }

    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.email resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.address_one resignFirstResponder];
    [self.address_two resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zip resignFirstResponder];

    if (tableView == self.list)
    {
        if ( indexPath.row == 1 &&
            ![[user objectForKey:@"IsVerifiedPhone"] isEqualToString:@"YES"] &&
             [[dictSavedInfo valueForKey:@"phoneno"] length] > 0)
        {
            [self.phone setUserInteractionEnabled:YES];
        }
    }
}

-(void)deleteTableRow:(NSIndexPath*)rowNumber
{
    numberOfRowsToDisplay -= 1;
    [self.list deleteRowsAtIndexPaths:@[rowNumber] withRowAnimation:UITableViewRowAnimationFade];

    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self.list setFrame:CGRectMake(0, self.list.frame.origin.y, 320, rowHeight * numberOfRowsToDisplay)];
    [self.sectionHeaderBg2 setFrame:CGRectMake(0, self.sectionHeaderBg2.frame.origin.y - rowHeight, 320, hdrHt)];
    [self.list2 setFrame:CGRectMake(0, self.list2.frame.origin.y - rowHeight, 320, (rowHeight * 4) + 5)];
    [UIView commitAnimations];
}

#pragma mark - UITextField delegation
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];

    picture.alpha = 0;
    shadowUnder.alpha = 0;
    [self.member_since_back setFrame:CGRectMake(0, -10 - heightOfTopSection, 320, heightOfTopSection)];

    [scrollView setFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 10)];

    if (textField == self.address_one || textField == self.address_two || textField == self.city || textField == self.zip)
    {
        self.sectionHeaderBg.alpha = 0;
        [self.sectionHeaderBg2 setFrame:CGRectMake(0, 54, 320, hdrHt)];
        [self.list2 setFrame:CGRectMake(0, self.sectionHeaderBg2.frame.origin.y + hdrHt, 320, (rowHeight * 4) + 5)];
    }

    [UIView commitAnimations];

    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [scrollView addGestureRecognizer:tapGesture];
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [scrollView removeGestureRecognizer:tapGesture];
}

-(void)hideKeyBoard
{
    [self.phone resignFirstResponder];
    [self.address_one resignFirstResponder];
    [self.address_two resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zip resignFirstResponder];
    [scrollView removeGestureRecognizer:tapGesture];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];

    shadowUnder.alpha = 1;
    picture.alpha = 1;
    self.sectionHeaderBg.alpha = 1;
    [self.sectionHeaderBg2 setFrame:CGRectMake(0, (self.list.frame.origin.y + self.list.frame.size.height), 320, hdrHt)];
    [self.list2 setFrame:CGRectMake(0, self.sectionHeaderBg2.frame.origin.y + hdrHt, 320, (rowHeight * 4) + 5)];
    [self.member_since_back setFrame:CGRectMake(0, 0, 320, heightOfTopSection)];
    [scrollView setFrame:CGRectMake(0, heightOfTopSection, 320, [[UIScreen mainScreen] bounds].size.height - heightOfTopSection - 64)];
    [scrollView setContentOffset:CGPointZero animated:YES];

    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.save setEnabled:YES];
    [self.save setUserInteractionEnabled:YES];
    [self.save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (textField == self.phone)
    {
        if ([self.phone.text length] == 9 &&
            [self.phone.text rangeOfString:@"-"].location == NSNotFound &&
            [self.phone.text rangeOfString:@"("].location == NSNotFound)
        {
            self.phone.text = [NSString stringWithFormat:@"(%@) %@-%@",
                               [self.phone.text substringWithRange:NSMakeRange(0, 3)],
                               [self.phone.text substringWithRange:NSMakeRange(3, 3)],
                               [self.phone.text substringWithRange:NSMakeRange(6, 3)]];
        }
    }

    if ([self.phone.text length] < 8)
    {
        [self.resend_phone setStyleClass:@"button_gray_sm"];
        [self.resend_phone setUserInteractionEnabled:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _email)
    {
        [_phone becomeFirstResponder];
    }
    else if (textField == _phone)
    {
        [_address_one becomeFirstResponder];
    }
    else if (textField == _address_one)
    {
        [_address_two becomeFirstResponder];
    }
    else if (textField == _address_two)
    {
        [_city becomeFirstResponder];
    }
    else if (textField == _city )
    {
        [_zip becomeFirstResponder];
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
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
    [self.hud hide:YES];
    NSError * error;

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];
        [timer invalidate];
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];

        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }

    if ([tagName isEqualToString:@"email_verify"])
    {
        NSString *response = [[NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error] objectForKey:@"Result"];
        NSLog(@"resend Email Link response is: %@",response);
        if ([response isEqualToString:@"Already Activated."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"Profile_EmailAlrdyVerAlrtBody", @"Profile Email already verified Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [self deleteTableRow:indexPath];
            emailVerifyRowIsShowing = false;

            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Not a nooch member."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"Profile_NotAMbmrAlrtBody", @"Profile not a member Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Success"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_ChkEmlAlrtTitle", @"Profile 'Check Your Email' Alert Title")
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA5\n%@", [NSString stringWithFormat:NSLocalizedString(@"Profile_ChkEmlAlrtBody", @"Profile 'Check Your Email' Alert Body Text"),self.email.text]]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [self deleteTableRow:indexPath];
            emailVerifyRowIsShowing = false;

            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Failure"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"Profile_FailureAlrtBody", @"Profile failure Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    }

    else if ([tagName isEqualToString:@"sms_verify"])
    {
        NSString *response = [[NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error] objectForKey:@"Result"];
        
        if ([response isEqualToString:@"Already Verified."]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@  \xF0\x9F\x91\x8D", NSLocalizedString(@"Profile_SmsAlrdyVerAlrtTitle", @"Profile phone already verified Alert Title")]
                                                         message:NSLocalizedString(@"Profile_SmsAlrdyVerAlrtBody", @"Profile phone already verified Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];

            if (smsVerifyRowIsShowing)
            {
                NSIndexPath * indexPath = nil;
                if (emailVerifyRowIsShowing)
                {
                    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                }
                else if (!emailVerifyRowIsShowing)
                {
                    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                }

                [self deleteTableRow:indexPath];

                smsVerifyRowIsShowing = false;
            }
            
            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Not a nooch member."]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_UnexpErrorAlrtTitle1", @"Profile 'Unexpected Error' Alert Title")
                                                         message:NSLocalizedString(@"Profile_UnexpErrorAlrtBody1", @"Profile 'Unexpected Error' Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Success"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_ChkSmsAlrtTitle", @"Profile 'Check Your Texts' Alert Title")
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x93\xB2\n%@", NSLocalizedString(@"Profile_ChkSmsAlrtBody", @"Profile Check Your Texts Alert Body Text")]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];

            if (smsVerifyRowIsShowing == true)
            {
                NSIndexPath * indexPath = nil;
                if (emailVerifyRowIsShowing == true)
                {
                    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                }
                else if (emailVerifyRowIsShowing == false)
                {
                    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                }

                [self deleteTableRow:indexPath];

                smsVerifyRowIsShowing = false;
            }

            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Failure"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_UnexpErrorAlrtTitle2", @"Profile 'Unexpected Error' Alert Title (2nd)")
                                                         message:NSLocalizedString(@"Profile_UnexpErrorAlrtBody2", @"Profile 'Unexpected Error' Alert Body Text (2nd)")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Temporarily_Blocked"] ||
                 [response isEqualToString:@"Suspended"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_AcntSuspTitle", @"Profile 'Account Is Suspended' Alert Title")
                                                         message:NSLocalizedString(@"Profile_AcntSuspBody", @"Profile 'Account Is Suspended' Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    }

    else if ([tagName isEqualToString:@"MySettingsResult"]) // Saving Profile changes
    {
        dictProfileinfo = [NSJSONSerialization
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];

        [dictSavedInfo setObject:@"NO" forKey:@"ImageChanged"];

        NSDictionary *resultValue = [dictProfileinfo valueForKey:@"MySettingsResult"];

        getEncryptionOldPassword = [dictProfileinfo objectForKey:@"Password"];

        NSLog(@"My Settings Result:  %@",[resultValue valueForKey:@"Result"]);
        [[assist shared]setTranferImage:nil];

        if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Your details have been updated successfully."])
        {
            [self.save setEnabled:NO];
            [self.save setUserInteractionEnabled:NO];
            [self.save setStyleClass:@"disabled_gray"];
            
            serve * serveOBJ = [serve new];
            serveOBJ.tagName = @"myset";
            [serveOBJ setDelegate:self];
            [serveOBJ getSettings];
            
            if ([[user objectForKey:@"Photo"] length] > 0 && [user objectForKey:@"Photo"] != nil && !isPhotoUpdate)
            {
                [picture sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
            }

            if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] &&
                self.phone.text.length > 8)
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_SvdSucAlrtTtle", @"Profile 'Profile Saved' Alert Title")
                                                             message:[NSString stringWithFormat:@"%@\n\xF0\x9F\x93\xB2", NSLocalizedString(@"Profile_SvdSucAlrtBody", @"Profile Profile Saved and phone not yet verified Alert Body Text")]
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
            else
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_SvdSucAlrtTtle2", @"Profile 'Profile Saved' Alert Title (2nd)")
                                                             message:[NSString stringWithFormat:@"\xF0\x9F\x98\x8E\n%@",NSLocalizedString(@"Profile_SvdSucAlrtBody2", @"Profile Profile Saved Alert Body Text")]
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
        }
        else if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Phone Number already registered with Nooch"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_PhnAlrdRegAlrtTitle", @"Profile 'Phone Number Already Registered' Alert Title")
                                                         message:[NSString stringWithFormat:NSLocalizedString(@"Profile_PhnAlrdRegAlrtBody", @"Profile 'Phone Number Already Registered' Alert Body Text"),self.phone.text]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else
        {
            NSString * validated = @"YES";
            if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Profile Validation Failed! Please provide valid contact informations such as address, city, state and contact number details."])
            {
                [[me usr] setObject:validated forKey:@"validated"];
            }

            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_SmthngWrngAlrtTitle", @"Profile 'Something Went Wrong' Alert Title")
                                                         message:NSLocalizedString(@"Profile_SmthngWrngAlrtBody", @"Profile Something Went Wrong Alert Body Text")
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }

        if (isSignup)
        {
            [self.navigationController setNavigationBarHidden:NO];
            [UIView animateWithDuration:0.75
                             animations:^{
                                 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                             }];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
            isSignup = NO;
        }
    }

    else if ([tagName isEqualToString:@"myset"]) // Getting profile info from Server
    {
        dictProfileinfo = [NSJSONSerialization
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];
        
        //NSLog(@"Profile Get User Details --> dictProfileinfo is: %@",dictProfileinfo);

        if ( ![[dictProfileinfo valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]] &&
            ![[[dictProfileinfo valueForKey:@"ContactNumber"] lowercaseString] isEqualToString:@"null"])
        {
            if ([dictProfileinfo valueForKey:@"ContactNumber"] != NULL)
            {
                self.SavePhoneNumber = [dictProfileinfo valueForKey:@"ContactNumber"];
            }
            else {
                self.SavePhoneNumber = @"";
            }

            if ([[dictProfileinfo valueForKey:@"ContactNumber"] length] > 8 &&
                [[dictProfileinfo valueForKey:@"ContactNumber"] length] < 12)
            {
                self.phone.text = [NSString stringWithFormat:@"(%@) %@-%@",
                                   [[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(0, 3)],
                                   [[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(3, 3)],
                                   [[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(6, [[dictProfileinfo objectForKey:@"ContactNumber"] length] - 6)]
                                  ];

                self.phone.text = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                [self.resend_phone setHidden:NO];
                [self.resend_phone setUserInteractionEnabled:YES];
                [self.resend_phone setStyleClass:@"button_green_sm"];

                [dictSavedInfo setObject:self.phone.text forKey:@"phoneno"];
                [ARProfileManager setUserPhoneNumber:self.phone.text];
            }
            else if ([[dictProfileinfo valueForKey:@"ContactNumber"] length] > 0)
            {
                self.phone.text = [dictProfileinfo objectForKey:@"ContactNumber"];
                [dictSavedInfo setObject:self.phone.text forKey:@"phoneno"];
                [ARProfileManager setUserPhoneNumber:self.phone.text];
            }
            else
            {
                [self.resend_phone setHidden:YES];
                self.phone.text = @"";
                [self.resend_phone setStyleClass:@"button_gray_sm"];
                [self.resend_phone setUserInteractionEnabled:NO];
            }
         //   [self.list reloadData];
        }
        else
        {
            self.SavePhoneNumber = @"";
        }


        // The UserName value should never be NULL, so all the 'else if' statements
        // below this first 'if' *should* never be called, but are added just in case as backup
        if (![[dictProfileinfo valueForKey:@"UserName"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"email";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
        }
        else if (![[dictProfileinfo valueForKey:@"FirstName"] isKindOfClass:[NSNull class]])
        {
            NSLog(@"Checkpoint 'name'");
            self.ServiceType = @"name";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
        }
        else if (![[dictProfileinfo valueForKey:@"LastName"] isKindOfClass:[NSNull class]])
        {
            NSLog(@"Checkpoint 'lastname'");
            self.ServiceType = @"lastname";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"LastName"]];
        }
        else if (![[dictProfileinfo valueForKey:@"Address"] isKindOfClass:[NSNull class]])
        {
            NSLog(@"Checkpoint 'Address'");
            self.ServiceType = @"Address";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Address"]];
        }
        else if (![[dictProfileinfo valueForKey:@"City"] isKindOfClass:[NSNull class]])
        {
            NSLog(@"Checkpoint 'City'");
            self.ServiceType = @"City";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"City"]];
        }
        else if (![[dictProfileinfo valueForKey:@"State"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"State";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"State"]];
        }
        else if (![[dictProfileinfo valueForKey:@"Zipcode"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"zip";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
        }

        // Top Background Color (Red if Suspended)
        if (![[user valueForKey:@"Status"] isEqualToString:@"Active"] ||
            ![[user valueForKey:@"IsVerifiedPhone"] isEqualToString:@"YES"])
        {
            [self.member_since_back setBackgroundColor:Rgb2UIColor(214, 25, 21, .55)];
            [self.member_since_back setStyleId:@"profileTopSectionBg_susp"];
        }
        else
        {
            [self.member_since_back setBackgroundColor:Rgb2UIColor(219, 220, 222, .38)];
            [self.member_since_back setStyleId:@"profileTopSectionBg"];
        }


        // Email Glyph - ! or checkmark
        if ([[user valueForKey:@"Status"] isEqualToString:@"Registered"])
        {
            UIView * email_not_validated = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, rowHeight)];
            [email_not_validated setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];
            
            [self.emailGlyphIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
            [self.emailGlyphIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
            [self.emailGlyphIndicator setStyleClass:@"animate_bubble_slow"];
            [self.emailGlyphIndicator setFrame:CGRectMake(34, 6, 20, 38)];
            [self.emailGlyphIndicator setTextColor:kNoochRed];
        }
        else
        {
            [self.email_NotValidated_YellowBg1 removeFromSuperview];
            [self.email_NotValidated_YellowBg2 removeFromSuperview];
            
            [self.emailGlyphIndicator setBackgroundColor:[UIColor clearColor]];
            [self.emailGlyphIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
            [self.emailGlyphIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
            [self.emailGlyphIndicator setFrame:CGRectMake(40, 6, 20, 39)];
            [self.emailGlyphIndicator setTextColor:kNoochGreen];
            
            if (emailVerifyRowIsShowing)
            {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [self deleteTableRow:indexPath];
                
                emailVerifyRowIsShowing = false;
            }
        }

        // Phone Glyph: ! or checkmark
        if ([[dictProfileinfo valueForKey:@"IsVerifiedPhone"] boolValue] == 0)
        {
            UIView * unverified_phone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, rowHeight)];
            [unverified_phone setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];

            [self.phoneGlyphIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
            [self.phoneGlyphIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
            [self.phoneGlyphIndicator setStyleClass:@"animate_bubble_slow"];
            [self.phoneGlyphIndicator setFrame:CGRectMake(31, 6, 20, 38)];
            [self.phoneGlyphIndicator setTextColor:kNoochRed];
        }
        else
        {
            [self.phone_NotValidated_YellowBg1 removeFromSuperview];
            [self.phone_NotValidated_YellowBg2 removeFromSuperview];
            
            [self.phoneGlyphIndicator setBackgroundColor:[UIColor clearColor]];
            [self.phoneGlyphIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
            [self.phoneGlyphIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
            [self.phoneGlyphIndicator setFrame:CGRectMake(33, 6, 20, 40)];
            [self.phoneGlyphIndicator setTextColor:kNoochGreen];
            
            if (smsVerifyRowIsShowing)
            {
                NSIndexPath * indexPath = nil;
                if (emailVerifyRowIsShowing)
                {
                    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                }
                else if (!emailVerifyRowIsShowing)
                {
                    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                }
                
                [self deleteTableRow:indexPath];
                
                smsVerifyRowIsShowing = false;
            }
            
            [self.list beginUpdates];
            [self.list endUpdates];
        }

        [self.list reloadData];
    }
}

#pragma mark - password encryption

-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue
{
    //NSLog(@"DECRYPTION -> sourceData is: %@", [sourceData objectForKey:@"Status"]);

    if ([self.ServiceType isEqualToString:@"email"])
    {
        if (![self.email.text isEqualToString:[sourceData objectForKey:@"Status"]])
        {
            self.email.text = [sourceData objectForKey:@"Status"];
        }

        if (![[dictProfileinfo objectForKey:@"FirstName"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"firstname";
            Decryption * decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
        }
    }

    else  if ([self.ServiceType isEqualToString:@"firstname"]) // first name
    {
        if ( [[sourceData objectForKey:@"Status"] length] > 0)
        {
            if (![[[sourceData objectForKey:@"Status"] capitalizedString] isEqualToString:[[user objectForKey:@"firstName"] capitalizedString]])
            {
                NSLog(@"First name from server isn't the same as local First Name apparently");
                NSString * letterA = [[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];
                [ARProfileManager setUserFirstName:letterA];
                [dictSavedInfo setObject:self.name.text forKey:@"name"];

                self.name.text = [NSString stringWithFormat:@"%@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]];

                NSString * name = [self.name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSShadow * shadow = [[NSShadow alloc] init];
                shadow.shadowColor = Rgb2UIColor(249, 251, 252, .3);
                shadow.shadowOffset = CGSizeMake(0, 1);
                NSDictionary * textAttributes_topShadow = @{NSShadowAttributeName: shadow };

                self.name.attributedText = [[NSAttributedString alloc] initWithString:[name capitalizedString] attributes:textAttributes_topShadow];
            }

            if (![[dictProfileinfo objectForKey:@"LastName"] isKindOfClass:[NSNull class]])
            {
                self.ServiceType = @"lastname";
                Decryption * decry = [[Decryption alloc] init];
                decry.Delegate = self;
                decry->tag = [NSNumber numberWithInteger:2];
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"LastName"]];
            }
            else if (![[dictProfileinfo objectForKey:@"Address"] isKindOfClass:[NSNull class]])
            {
                self.ServiceType = @"Address";
                Decryption * decry = [[Decryption alloc] init];
                decry.Delegate = self;
                decry->tag = [NSNumber numberWithInteger:2];
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Address"]];
            }
        }
        else
        {
            UIAlertView * newUserNoName = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_NcToMtYouAlrtTitle", @"Profile 'Nice To Meet You' Alert Title")
                                                                     message:@"Thanks for joining Nooch! Please complete your profile to get started."
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [newUserNoName show];
            [newUserNoName setTag:1001];

            if (![[dictProfileinfo objectForKey:@"Address"] isKindOfClass:[NSNull class]])
            {
                self.ServiceType = @"Address";
                Decryption * decry = [[Decryption alloc] init];
                decry.Delegate = self;
                decry->tag = [NSNumber numberWithInteger:2];
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Address"]];
            }
        }
    }
    
    else  if ([self.ServiceType isEqualToString:@"lastname"]) //last name
    {
        if ( [[sourceData objectForKey:@"Status"] length] > 0 &&
            ![[[sourceData objectForKey:@"Status"] capitalizedString] isEqualToString:[[user objectForKey:@"lastName"] capitalizedString]])
        {
            NSLog(@"Last name from server isn't the same as Last name in app apparently");
            NSString * letterA = [[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];
            self.name.text = [self.name.text stringByAppendingString:[NSString stringWithFormat:@" %@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]]];

            [ARProfileManager setUserLastName:letterA];
            [dictSavedInfo setObject:self.name.text forKey:@"name"];
            
            NSString * name = [self.name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowColor = Rgb2UIColor(249, 251, 252, .3);
            shadow.shadowOffset = CGSizeMake(0, 1);
            NSDictionary * textAttributes_topShadow = @{NSShadowAttributeName: shadow };
            
            self.name.attributedText = [[NSAttributedString alloc] initWithString:[name capitalizedString] attributes:textAttributes_topShadow];
        }
        
        if (![[dictProfileinfo objectForKey:@"Address"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"Address";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Address"]];
        }
    }

    else if ([self.ServiceType isEqualToString:@"Address"])
    {
        if (![[[sourceData objectForKey:@"Status"] lowercaseString] isEqualToString:@"null"] &&
            ![[[sourceData objectForKey:@"Status"] lowercaseString] isEqualToString:@"declined"])
        {
            NSArray * arr = [[sourceData objectForKey:@"Status"] componentsSeparatedByString:@"/"];

            if ([arr count] == 2)
            {
                self.address_one.text = [arr objectAtIndex:0];
                self.address_two.text = [arr objectAtIndex:1];
            }
            else
            {
                self.address_one.text = [arr objectAtIndex:0];
                self.address_two.text = @"";
            }

            NSString * address1 = [self.address_one.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.address_one.text = [address1 capitalizedString];
            NSString* address2 = [self.address_two.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.address_two.text = [address2 capitalizedString];

            [dictSavedInfo setObject:self.address_one.text forKey:@"Address1"];
            [dictSavedInfo setObject:self.address_two.text forKey:@"Address2"];
        }
        else
        {
            self.address_one.text = @"";
            self.address_two.text = @"";
        }

        if (![[dictProfileinfo objectForKey:@"City"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"City";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"City"]];
        }
    }

    else if ([self.ServiceType isEqualToString:@"City"])
    {
        NSString * city = [[sourceData objectForKey:@"Status"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.city.text = [city capitalizedString];

        [ARProfileManager setUserCity:[city capitalizedString]];
        [dictSavedInfo setObject:self.city.text forKey:@"City"];
       
        if (![[dictProfileinfo objectForKey:@"State"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"State";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"State"]];
        }

        else if (![[dictProfileinfo objectForKey:@"Zipcode"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"zip";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
        }
    }

    else if ([self.ServiceType isEqualToString:@"State"])
    {
        if (![[dictProfileinfo objectForKey:@"Zipcode"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"zip";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
        }
    }

    else  if ([self.ServiceType isEqualToString:@"zip"])
    {
        NSString * zip = [[sourceData objectForKey:@"Status"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.zip.text = zip;

        [ARProfileManager setUserPostalCode:zip];
        [dictSavedInfo setObject:self.zip.text forKey:@"zip"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    // Dispose of any resources that can be recreated.
}
@end