//  Statistics.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "Statistics.h"
#import "Home.h"
#import "ECSlidingViewController.h"
#import "UIImageView+WebCache.h"

@interface Statistics ()
@property(nonatomic,retain) UIView *back_profile;
@property(nonatomic,retain) UIView *back_transfer;
@property(nonatomic,retain) UIView *back_donation;
@property(nonatomic,retain) UITableView *profile_stats;
@property(nonatomic,retain) UITableView *transfer_stats;
@property(nonatomic,retain) UITableView *top_friends_stats;
@property(nonatomic) int selected;
@property(nonatomic,retain) UIButton * exportHistory;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation Statistics

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.screenName = @"Statistics Screen";
}
-(void)viewDidDisappear:(BOOL)animated{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    IsAlertShown=NO;
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.view removeGestureRecognizer:self.navigationController.slidingViewController.panGesture];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .5;
    [self.view addSubview:backgroundImage];
    
    dictAllStats = [[NSMutableDictionary alloc]init];
    
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"Total_P2P_transfers";
    [serveOBJ GetMemberStats:@"Total_P2P_transfers"];
    
    [self.navigationItem setTitle:@"Statistics"];

    self.selected = 0;
    UISwipeGestureRecognizer * left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(change_stats:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:left];

    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(change_stats:)];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:right];

    // Panel #1: Transfer Stats
    self.back_transfer = [UIView new];
    [self.back_transfer setBackgroundColor:[UIColor whiteColor]];
    [self.back_transfer setFrame:CGRectMake(10, 10, 300, 400)];
    [self.back_transfer setStyleClass:@"raised_view"];
    [self.view addSubview:self.back_transfer];

    // Panel #2: Profile Stats
    self.back_profile = [UIView new];
    [self.back_profile setBackgroundColor:[UIColor whiteColor]];
    [self.back_profile setFrame:CGRectMake(330, 10, 300, 400)];
    [self.back_profile setStyleClass:@"raised_view"];
    [self.view addSubview:self.back_profile];

    // Panel #3: Top Friends Stats
    self.back_donation = [UIView new];
    [self.back_donation setBackgroundColor:[UIColor whiteColor]];
    [self.back_donation setFrame:CGRectMake(650, 10, 300, 400)];
    [self.back_donation setStyleClass:@"raised_view"];
    [self.view addSubview:self.back_donation];


    // ----------------
    //  ICONS - PANEL 1
    // ----------------
    
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    // Transfer ACTIVE Icon
    UIButton * transfersIcon_bckgrnd = [UIButton new];
    [transfersIcon_bckgrnd setStyleClass:@"stats_circle_transfers_Active"];
    transfersIcon_bckgrnd.userInteractionEnabled = NO;
    
    UILabel * glyph_transfers = [UILabel new];
    [glyph_transfers setFont:[UIFont fontWithName:@"FontAwesome" size:26]];
    [glyph_transfers setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_transfers.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-money"] attributes:textAttributes];
    [glyph_transfers setTextColor:[UIColor whiteColor]];
    [glyph_transfers setTextAlignment:NSTextAlignmentCenter];
    [transfersIcon_bckgrnd addSubview:glyph_transfers];
    
    // Profile INACTIVE Icon
    UIButton * profileIcon_bckgrnd = [UIButton new];
    UITapGestureRecognizer * tap_profile2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(go_2nd_panel_from_1st)];
    [profileIcon_bckgrnd setStyleClass:@"stats_circle_Profile_inActive"];
    profileIcon_bckgrnd.userInteractionEnabled = YES;
    [profileIcon_bckgrnd addGestureRecognizer:tap_profile2];
    
    UILabel * glyph_Profile = [UILabel new];
    [glyph_Profile setFont:[UIFont fontWithName:@"FontAwesome" size:28]];
    [glyph_Profile setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_Profile.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"] attributes:textAttributes];
    [glyph_Profile setTextColor:[UIColor whiteColor]];
    [glyph_Profile setAlpha:0.8];
    [glyph_Profile setTextAlignment:NSTextAlignmentCenter];
    [profileIcon_bckgrnd addSubview:glyph_Profile];

    // Top Friends INACTIVE Icon
    UIButton * topFriendsIcon_bckgrnd = [UIButton new];
    UITapGestureRecognizer * tap_donation2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(go_3rd_panel_from_1st)];
    [topFriendsIcon_bckgrnd setStyleClass:@"stats_circle_topFriends_inActive"];
    topFriendsIcon_bckgrnd.userInteractionEnabled = YES;
    [topFriendsIcon_bckgrnd addGestureRecognizer:tap_donation2];

    UILabel * glyph_topFriends = [UILabel new];
    [glyph_topFriends setFont:[UIFont fontWithName:@"FontAwesome" size:28]];
    [glyph_topFriends setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_topFriends.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"] attributes:textAttributes];
    [glyph_topFriends setTextColor:[UIColor whiteColor]];
    [glyph_topFriends setAlpha:0.8];
    [glyph_topFriends setTextAlignment:NSTextAlignmentCenter];
    [topFriendsIcon_bckgrnd addSubview:glyph_topFriends];
    
    [self.back_transfer addSubview:transfersIcon_bckgrnd];
    [self.back_transfer addSubview:profileIcon_bckgrnd];
    [self.back_transfer addSubview:topFriendsIcon_bckgrnd];
    

    // ----------------
    //  ICONS - PANEL 2
    // ----------------
    
    // Transfer INACTIVE Icon
    UIButton * transfersIcon_bckgrnd2 = [UIButton new];
    [transfersIcon_bckgrnd2 setStyleClass:@"stats_circle_transfers_inActive"];
    transfersIcon_bckgrnd2.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap_trans_from_profile = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(go_1st_panel_from_2nd)];
    [transfersIcon_bckgrnd2 addGestureRecognizer:tap_trans_from_profile];
    
    UILabel * glyph_transfers2 = [UILabel new];
    [glyph_transfers2 setFont:[UIFont fontWithName:@"FontAwesome" size:26]];
    [glyph_transfers2 setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_transfers2.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-money"] attributes:textAttributes];
    [glyph_transfers2 setTextColor:[UIColor whiteColor]];
    [glyph_transfers2 setAlpha:0.8];
    [glyph_transfers2 setTextAlignment:NSTextAlignmentCenter];
    [transfersIcon_bckgrnd2 addSubview:glyph_transfers2];

    // Profile ACTIVE Icon
    UIButton * profileIcon_bckgrnd2 = [UIButton new];
    [profileIcon_bckgrnd2 setStyleClass:@"stats_circle_Profile_Active"];
    profileIcon_bckgrnd2.userInteractionEnabled = NO;
    
    UILabel * glyph_Profile2 = [UILabel new];
    [glyph_Profile2 setFont:[UIFont fontWithName:@"FontAwesome" size:28]];
    [glyph_Profile2 setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_Profile2.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"] attributes:textAttributes];
    [glyph_Profile2 setTextColor:[UIColor whiteColor]];
    [glyph_Profile2 setTextAlignment:NSTextAlignmentCenter];
    [profileIcon_bckgrnd2 addSubview:glyph_Profile2];

    // Top Friends INACTIVE Icon
    UIButton * topFriendsIcon_bckgrnd2 = [UIButton new];
    UITapGestureRecognizer * tap_donation3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(go_3rd_panel_from_2nd)];
    [topFriendsIcon_bckgrnd2 setStyleClass:@"stats_circle_topFriends_inActive"];
    topFriendsIcon_bckgrnd2.userInteractionEnabled = YES;
    [topFriendsIcon_bckgrnd2 addGestureRecognizer:tap_donation3];
    
    UILabel * glyph_topFriends2 = [UILabel new];
    [glyph_topFriends2 setFont:[UIFont fontWithName:@"FontAwesome" size:28]];
    [glyph_topFriends2 setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_topFriends2.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"] attributes:textAttributes];
    [glyph_topFriends2 setTextColor:[UIColor whiteColor]];
    [glyph_topFriends2 setAlpha:0.8];
    [glyph_topFriends2 setTextAlignment:NSTextAlignmentCenter];
    [topFriendsIcon_bckgrnd2 addSubview:glyph_topFriends2];

    [self.back_profile addSubview:transfersIcon_bckgrnd2];
    [self.back_profile addSubview:profileIcon_bckgrnd2];
    [self.back_profile addSubview:topFriendsIcon_bckgrnd2];


    // ----------------
    //  ICONS - PANEL 3
    // ----------------

    // Transfer INACTIVE Icon
    UIButton * transfersIcon_bckgrnd3 = [UIButton new];
    [transfersIcon_bckgrnd3 setStyleClass:@"stats_circle_transfers_inActive"];
    transfersIcon_bckgrnd3.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap_trans_from_profile2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(go_1st_panel_from_3rd)];
    [transfersIcon_bckgrnd3 addGestureRecognizer:tap_trans_from_profile2];
    
    UILabel * glyph_transfers3 = [UILabel new];
    [glyph_transfers3 setFont:[UIFont fontWithName:@"FontAwesome" size:26]];
    [glyph_transfers3 setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_transfers3.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-money"] attributes:textAttributes];
    [glyph_transfers3 setTextColor:[UIColor whiteColor]];
    [glyph_transfers3 setAlpha:0.8];
    [glyph_transfers3 setTextAlignment:NSTextAlignmentCenter];
    [transfersIcon_bckgrnd3 addSubview:glyph_transfers3];

    // Profile INACTIVE Icon
    UIButton * profileIcon_bckgrnd3 = [UIButton new];
    UITapGestureRecognizer * tap_profile3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(go_2nd_panel_from_3rd)];
    [profileIcon_bckgrnd3 addGestureRecognizer:tap_profile3];
    [profileIcon_bckgrnd3 setStyleClass:@"stats_circle_Profile_inActive"];
    profileIcon_bckgrnd3.userInteractionEnabled = YES;
    
    UILabel * glyph_Profile3 = [UILabel new];
    [glyph_Profile3 setFont:[UIFont fontWithName:@"FontAwesome" size:28]];
    [glyph_Profile3 setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_Profile3.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"] attributes:textAttributes];
    [glyph_Profile3 setTextColor:[UIColor whiteColor]];
    [glyph_Profile3 setAlpha:0.8];
    [glyph_Profile3 setTextAlignment:NSTextAlignmentCenter];
    [profileIcon_bckgrnd3 addSubview:glyph_Profile3];

    // Top Friends ACTIVE Icon
    UIButton * topFriendsIcon_bckgrnd3 = [UIButton new];
    [topFriendsIcon_bckgrnd3 setStyleClass:@"stats_circle_topFriends_Active"];
    topFriendsIcon_bckgrnd3.userInteractionEnabled = NO;

    UILabel * glyph_topFriends3 = [UILabel new];
    [glyph_topFriends3 setFont:[UIFont fontWithName:@"FontAwesome" size:28]];
    [glyph_topFriends3 setFrame:CGRectMake(5, 5, 45, 45)];
    glyph_topFriends3.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"] attributes:textAttributes];
    [glyph_topFriends3 setTextColor:[UIColor whiteColor]];
    [glyph_topFriends3 setTextAlignment:NSTextAlignmentCenter];
    [topFriendsIcon_bckgrnd3 addSubview:glyph_topFriends3];

    [self.back_donation addSubview:transfersIcon_bckgrnd3];
    [self.back_donation addSubview:profileIcon_bckgrnd3];
    [self.back_donation addSubview:topFriendsIcon_bckgrnd3];

    
    // TABLE VIEWS (actual stats data)
    self.profile_stats = [UITableView new];
    [self.profile_stats setDelegate:self];
    [self.profile_stats setDataSource:self];
    [self.profile_stats setStyleClass:@"stats"];
    [self.profile_stats setUserInteractionEnabled:NO];
    [self.back_profile addSubview:self.profile_stats];
    [self.profile_stats reloadData];
    
    self.transfer_stats = [UITableView new];
    [self.transfer_stats setDelegate:self];
    [self.transfer_stats setDataSource:self];
    [self.transfer_stats setStyleClass:@"stats"];
    [self.transfer_stats setUserInteractionEnabled:NO];
    [self.back_transfer addSubview:self.transfer_stats];
    [self.transfer_stats reloadData];
    
    self.top_friends_stats = [UITableView new];
    [self.top_friends_stats setDelegate:self];
    [self.top_friends_stats setDataSource:self];
    [self.top_friends_stats setStyleClass:@"stats_top_friends"];
    [self.top_friends_stats setUserInteractionEnabled:NO];
    [self.back_donation addSubview:self.top_friends_stats];
    [self.top_friends_stats reloadData];
    
    //Export Stats
    self.exportHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exportHistory setTitle:@"      Export Account History" forState:UIControlStateNormal];
    [self.exportHistory setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    self.exportHistory.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.exportHistory setStyleId:@"exportStatsBtn"];
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        [self.exportHistory setFrame:CGRectMake(60, 445, 200, 38)];
    }
    else {
        [self.exportHistory setFrame:CGRectMake(60, 441, 200, 36)];
    }

    UILabel * glyph_export = [UILabel new];
    [glyph_export setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
    [glyph_export setFrame:CGRectMake(8, 1, 18, 36)];
    glyph_export.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-download"] attributes:textAttributes];
    [glyph_export setTextColor:[UIColor whiteColor]];
    [glyph_export setTextAlignment:NSTextAlignmentCenter];
    [self.exportHistory addSubview:glyph_export];
    [self.exportHistory addTarget:self action:@selector(ExportHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exportHistory];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [scroll setDelegate:self];
        [scroll setContentSize:CGSizeMake(320, 545)];
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
            [scroll addSubview:subview];
        }
        [self.view addSubview:scroll];
    }

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStylePulse];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Grabbing your account stats...";
    [self.hud show:YES];
    [spinner1 startAnimating];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    
    [self GetFavorite];

}


-(void)go_2nd_panel_from_1st
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
 
    [self.exportHistory setFrame:CGRectMake(60, 570, 200, 38)];
    
    self.selected++;

    CGRect frame;
    frame = self.back_profile.frame;
    frame.origin.x -= 320;
    [self.back_profile setFrame:frame];
    
    frame = self.back_transfer.frame;
    frame.origin.x -= 320;
    [self.back_transfer setFrame:frame];
    
    frame = self.back_donation.frame;
    frame.origin.x -= 320;
    [self.back_donation setFrame:frame];
    
    [UIView commitAnimations];
}

-(void)go_3rd_panel_from_1st
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.65];

    [self.exportHistory setFrame:CGRectMake(60, 570, 200, 38)];

    //[self.topFriends_active setStyleId:@"stats_circle_donations_active"];

    self.selected += 2;

    CGRect frame;
    frame = self.back_profile.frame;
    frame.origin.x -= 640;
    [self.back_profile setFrame:frame];

    frame = self.back_transfer.frame;
    frame.origin.x -= 640;
    [self.back_transfer setFrame:frame];

    frame = self.back_donation.frame;
    frame.origin.x -= 640;
    [self.back_donation setFrame:frame];

    [UIView commitAnimations];
}

-(void)go_3rd_panel_from_2nd
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    //[self.topFriends_active setStyleId:@"stats_circle_donations_active"];

    self.selected++;

    CGRect frame;
    frame = self.back_profile.frame;
    frame.origin.x -= 320;
    [self.back_profile setFrame:frame];

    frame = self.back_transfer.frame;
    frame.origin.x -= 320;
    [self.back_transfer setFrame:frame];

    frame = self.back_donation.frame;
    frame.origin.x -= 320;
    [self.back_donation setFrame:frame];

    [UIView commitAnimations];
}

-(void)go_1st_panel_from_2nd
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    [self.exportHistory setFrame:CGRectMake(60, 445, 200, 38)];

    //[self.profileIcon setStyleId:@"stats_circle_profile_active"];

    self.selected--;

    CGRect frame;
    frame = self.back_profile.frame;
    frame.origin.x += 320;
    [self.back_profile setFrame:frame];

    frame = self.back_transfer.frame;
    frame.origin.x += 320;
    [self.back_transfer setFrame:frame];

    frame = self.back_donation.frame;
    frame.origin.x += 320;
    [self.back_donation setFrame:frame];
    
    [UIView commitAnimations];
}

-(void)go_2nd_panel_from_3rd
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];

    self.selected--;

    CGRect frame;
    frame = self.back_profile.frame;
    frame.origin.x += 320;
    [self.back_profile setFrame:frame];
    
    frame = self.back_transfer.frame;
    frame.origin.x += 320;
    [self.back_transfer setFrame:frame];
    
    frame = self.back_donation.frame;
    frame.origin.x += 320;
    [self.back_donation setFrame:frame];

    [UIView commitAnimations];
}

-(void)go_1st_panel_from_3rd
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.65];
    
    [self.exportHistory setFrame:CGRectMake(60, 445, 200, 38)];

    self.selected -= 2;
    
    CGRect frame;
    frame = self.back_profile.frame;
    frame.origin.x += 640;
    [self.back_profile setFrame:frame];
    
    frame = self.back_transfer.frame;
    frame.origin.x += 640;
    [self.back_transfer setFrame:frame];
    
    frame = self.back_donation.frame;
    frame.origin.x += 640;
    [self.back_donation setFrame:frame];
    
    [UIView commitAnimations];
}

- (void) button_change:(int)num {}

- (void) change_stats:(UISwipeGestureRecognizer *)slide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];

    CGRect frame;
    
    if (slide.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if (self.selected == 0)
        {
            [self.exportHistory setFrame:CGRectMake(60, 570, 200, 38)];

            self.selected++;

            frame = self.back_profile.frame;
            frame.origin.x -= 320;
            [self.back_profile setFrame:frame];

            frame = self.back_transfer.frame;
            frame.origin.x -= 320;
            [self.back_transfer setFrame:frame];

            frame = self.back_donation.frame;
            frame.origin.x -= 320;
            [self.back_donation setFrame:frame];
        }
        else if (self.selected == 1)
        {
            self.selected++;

            frame = self.back_profile.frame;
            frame.origin.x -= 320;
            [self.back_profile setFrame:frame];

            frame = self.back_transfer.frame;
            frame.origin.x -= 320;
            [self.back_transfer setFrame:frame];

            frame = self.back_donation.frame;
            frame.origin.x -= 320;
            [self.back_donation setFrame:frame];
        }
    }
    else if (slide.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (self.selected == 1)
        {
            [self.exportHistory setFrame:CGRectMake(60, 445, 200, 38)];

            self.selected--;

            frame = self.back_profile.frame;
            frame.origin.x += 320;
            [self.back_profile setFrame:frame];

            frame = self.back_transfer.frame;
            frame.origin.x += 320;
            [self.back_transfer setFrame:frame];

            frame = self.back_donation.frame;
            frame.origin.x += 320;
            [self.back_donation setFrame:frame];
        }
        else if (self.selected == 2)
        {
            self.selected--;

            frame = self.back_profile.frame;
            frame.origin.x += 320;
            [self.back_profile setFrame:frame];

            frame = self.back_transfer.frame;
            frame.origin.x += 320;
            [self.back_transfer setFrame:frame];

            frame = self.back_donation.frame;
            frame.origin.x += 320;
            [self.back_donation setFrame:frame];
        }
    }
    [UIView commitAnimations];
    
}

-(void)GetFavorite
{
    serve *favoritesOBJ = [serve new];
    [favoritesOBJ setTagName:@"favorites"];
    [favoritesOBJ setDelegate:self];
    [favoritesOBJ get_favorites];
}

#pragma mark - UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    view.backgroundColor = [UIColor clearColor];

    UILabel * Title = [UILabel new];
    [Title setStyleClass:@"stats_header"];

    if (tableView == self.profile_stats) {
        Title.text = @"Profile Stats";
    }
    else if (tableView == self.top_friends_stats) {
        Title.text = @"Top Friends";
    }
    else if (tableView == self.transfer_stats) {
        Title.text = @"Transfer Stats";
    }
    [view addSubview:Title];
    return view;    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.profile_stats) {
        return 4;
    }
    if (tableView == self.transfer_stats) {
        return 7;
    }
    if (tableView == self.top_friends_stats) {
        return 5;
    }

    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    if ([cell.contentView subviews])
    {
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    UILabel *title = [UILabel new];
    UILabel *statistic = [UILabel new];
    [title setStyleClass:@"stats_table_left_lable"];
    [statistic setStyleClass:@"stats_table_right_lable"];

    UILabel * glyph = [[UILabel alloc] initWithFrame:CGRectMake(156, 2, 30, 44)];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:22]];
    [glyph setTextColor:kNoochBlue];
    [glyph setTextAlignment:NSTextAlignmentCenter];

    if (tableView == self.profile_stats)
    {
        if (indexPath.row == 0) {
           [title setText:@"Friends Invited"];
            if ([dictAllStats valueForKey:@"Total_Friends_Invited"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Friends_Invited"]  valueForKey:@"Result"]];
            }
            else if ([[[dictAllStats valueForKey:@"Total_Friends_Invited"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 1) {
            [title setText:@"Invites Accepted"];
            if ([dictAllStats valueForKey:@"Total_Friends_Joined"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Friends_Joined"]  valueForKey:@"Result"]];
            }
            else if ([[[dictAllStats valueForKey:@"Total_Friends_Joined"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 2) {
            if ([dictAllStats valueForKey:@"Total_Posts_To_TW"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Posts_To_TW"]  valueForKey:@"Result"]];
            }
            else if ([[[dictAllStats valueForKey:@"Total_Posts_To_TW"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
            [title setText:@"Posts to Twitter"];
            [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-twitter"]];
            [glyph setFrame:CGRectMake(144, 2, 30, 44)];
            [cell.contentView addSubview:glyph];
        }
        else if (indexPath.row == 3) {
            if ([dictAllStats valueForKey:@"Total_Posts_To_FB"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Posts_To_FB"]  valueForKey:@"Result"]];
            }
            else if ([[[dictAllStats valueForKey:@"Total_Posts_To_FB"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
            [title setText:@"Posts to Facebook"];
            [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook"]];
            [cell.contentView addSubview:glyph];
        }
    } 

    else if (tableView == self.transfer_stats) //transfers
    {
        if (indexPath.row == 0)
        {
            [title setText:@"Total Completed Payments"];
            if ([dictAllStats valueForKey:@"Total_P2P_transfers"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_P2P_transfers"]  valueForKey:@"Result"]];
            }
            else if ([[[dictAllStats valueForKey:@"Total_P2P_transfers"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 1)
        {
            [title setText:@"Payments Sent"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_no_of_transfer_Sent"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_no_of_transfer_Sent"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 2)
        {
            [title setText:@"Total Sent"];
            [statistic setText:[NSString stringWithFormat:@"$ %@",[[dictAllStats valueForKey:@"Total_$_Sent"]  valueForKey:@"Result"]]];
            
            if ([[[dictAllStats valueForKey:@"Total_$_Sent"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"$ 0"];
            }
        }
        else if (indexPath.row == 3)
        {
            [title setText:@"Payments Received"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_no_of_transfer_Received"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_no_of_transfer_Received"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 4)
        {
            [title setText:@"Total Received"];
            [statistic setText:[NSString stringWithFormat:@"$ %@",[[dictAllStats valueForKey:@"Total_$_Received"]  valueForKey:@"Result"]]];
            if ([[[dictAllStats valueForKey:@"Total_$_Received"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"$ 0"];
            }
        }
        else if (indexPath.row == 5)
        {
            [title setText:@"Largest Transfer Sent"];
            [statistic setText:[NSString stringWithFormat:@"$ %@",[[dictAllStats valueForKey:@"Largest_sent_transfer"]  valueForKey:@"Result"]]];
            if ([[[dictAllStats valueForKey:@"Largest_sent_transfer"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 6)
        {
            [title setText:@"Largest Transfer Received"];
            [statistic setText:[NSString stringWithFormat:@"$ %@",[[dictAllStats valueForKey:@"Largest_received_transfer"]  valueForKey:@"Result"]]];
            if ([[[dictAllStats valueForKey:@"Largest_received_transfer"]valueForKey:@"Result"] length] == 0) {
                [statistic setText:@"0"];
            }
        }
    } 

    else if (tableView == self.top_friends_stats)
    {
        int fav_count = [favorites count];
        
        if (fav_count > 0)
        {
            [self.top_friends_stats setStyleClass:@"stats_top_friends"];

            UIImageView * imageView = nil;
            UILabel * name = nil;
            UILabel * frequency = nil;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 54, 54)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.layer.cornerRadius = 27;
            // [imageView setStyleClass:@"animate_bubble"];

            name = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 140, 20)];
            [name setStyleClass:@"stats_topFriends_label"];

            frequency = [[UILabel alloc] initWithFrame:CGRectMake(80, 26, 140, 33)];
            frequency.textColor = [Helpers hexColor:@"313233"];
            frequency.textAlignment = NSTextAlignmentLeft;
            [frequency setFont:[UIFont fontWithName:@"Roboto-light" size:15]];

            if (indexPath.row == 0)
            {
                NSDictionary * favorite = [favorites objectAtIndex:0];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                          placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                
                name.text = [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]];
                frequency.text = [NSString stringWithFormat:@"%@ Payments",favorite[@"Frequency"]];
            }
            else if (fav_count > 1 && indexPath.row == 1)
            {
                NSDictionary * favorite = [favorites objectAtIndex:1];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                          placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                
                name.text = [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]];
                frequency.text = [NSString stringWithFormat:@"%@ Payments",favorite[@"Frequency"]];
            }
            else if (fav_count > 2 && indexPath.row == 2)
            {
                NSDictionary * favorite = [favorites objectAtIndex:2];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                          placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                
                name.text = [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]];
                frequency.text = [NSString stringWithFormat:@"%@ Payments",favorite[@"Frequency"]];
            }
            else if (fav_count > 3 && indexPath.row == 3)
            {
                NSDictionary * favorite = [favorites objectAtIndex:3];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                          placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                
                name.text = [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]];
                frequency.text = [NSString stringWithFormat:@"%@ Payments",favorite[@"Frequency"]];
            }
            else if (fav_count > 4 && indexPath.row == 4)
            {
                NSDictionary * favorite = [favorites objectAtIndex:4];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                          placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                
                name.text = [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]];
                frequency.text = [NSString stringWithFormat:@"%@ Payments",favorite[@"Frequency"]];
            }

            [imageView setClipsToBounds:YES];
            [cell.contentView addSubview:imageView];
            [cell.contentView addSubview:name];
            [cell.contentView addSubview:frequency];
            [self.top_friends_stats setStyleClass:@"stats_top_friends"];

        }
        else if (fav_count == 0)
        {
            if (indexPath.row == 0)
            {
                [self.top_friends_stats setStyleClass:@"stats_top_friends_empty"];

                UILabel * emptyText = nil;
                emptyText = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 120)];
                [emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
                [emptyText setNumberOfLines:3];
                emptyText.text = @"Once you make or receive some payments, your top friends will show up here.";
                [emptyText setTextAlignment:NSTextAlignmentCenter];
                [cell.contentView addSubview:emptyText];
            }
        }
    }

    [cell.contentView addSubview:title];
    [cell.contentView addSubview:statistic];
    return cell;
}

-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
    if (!IsAlertShown) {
        IsAlertShown=YES;
        UIAlertView * alert = [[UIAlertView alloc]
                               initWithTitle:@"Message"
                               message:@"Error connecting to server"
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [alert show];
    }
   
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    NSError * error;
    dictResult = [NSJSONSerialization
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                 error:&error];
    
    [ dictAllStats setObject:dictResult forKey:tagName];
    
    if ([tagName isEqualToString:@"Total_P2P_transfers"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Get_Member_Signup_Date";
        [serveOBJ GetMemberStats:@"Get_Member_Signup_Date"];
    }
    else if ([tagName isEqualToString:@"Get_Member_Signup_Date"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_$_Sent";
        [serveOBJ GetMemberStats:@"Total_$_Sent"];
    }
    else if ([tagName isEqualToString:@"Total_$_Sent"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_no_of_transfer_Sent";
        [serveOBJ GetMemberStats:@"Total_no_of_transfer_Sent"];
    }
    else if ([tagName isEqualToString:@"Total_no_of_transfer_Sent"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_$_Received";
        [serveOBJ GetMemberStats:@"Total_$_Received"];
    }
    else if ([tagName isEqualToString:@"Total_$_Received"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_no_of_transfer_Received";
        [serveOBJ GetMemberStats:@"Total_no_of_transfer_Received"];
    }
    else if ([tagName isEqualToString:@"Total_no_of_transfer_Received"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Smallest_sent_transfer";
        [serveOBJ GetMemberStats:@"Smallest_sent_transfer"];
    }
    else if ([tagName isEqualToString:@"Smallest_sent_transfer"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Smallest_received_transfer";
        [serveOBJ GetMemberStats:@"Smallest_received_transfer"];
    }
    else if ([tagName isEqualToString:@"Smallest_received_transfer"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Largest_sent_transfer";
        [serveOBJ GetMemberStats:@"Largest_sent_transfer"];
    }
    else if ([tagName isEqualToString:@"Largest_sent_transfer"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Largest_received_transfer";
        [serveOBJ GetMemberStats:@"Largest_received_transfer"];
    }
    else if ([tagName isEqualToString:@"Largest_received_transfer"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_$_Added_to_Nooch";
        [serveOBJ GetMemberStats:@"Total_$_Added_to_Nooch"];
    }
    else if ([tagName isEqualToString:@"Total_$_Added_to_Nooch"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_$_withdraw_from_Nooch";
        [serveOBJ GetMemberStats:@"Total_$_withdraw_from_Nooch"];
    }
    else if ([tagName isEqualToString:@"Total_$_withdraw_from_Nooch"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_Friends_Invited";
        [serveOBJ GetMemberStats:@"Total_Friends_Invited"];
    }
    else if ([tagName isEqualToString:@"Total_Friends_Invited"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_Friends_Joined";
        [serveOBJ GetMemberStats:@"Total_Friends_Joined"];
    }
    else if ([tagName isEqualToString:@"Total_Friends_Joined"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_Posts_To_FB";
        [serveOBJ GetMemberStats:@"Total_Posts_To_FB"];
    }
    else if ([tagName isEqualToString:@"Total_Posts_To_FB"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_Posts_To_TW";
        [serveOBJ GetMemberStats:@"Total_Posts_To_TW"];
    }
    else if ([tagName isEqualToString:@"Total_Posts_To_TW"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Largest_Donation_Made";
        [serveOBJ GetMemberStats:@"Largest_Donation_Made"];

        [self.profile_stats reloadData];
        [self.transfer_stats reloadData];
        [self.top_friends_stats reloadData];
    }
/*    else if ([tagName isEqualToString:@"Largest_Donation_Made"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_Donations_Count";
        [serveOBJ GetMemberStats:@"Total_Donations_Count"];
    }
    else if ([tagName isEqualToString:@"Total_Donations_Count"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName = @"Total_$_Donated";
        [serveOBJ GetMemberStats:@"Total_$_Donated"];
    }
    else if ([tagName isEqualToString:@"Total_$_Donated"]) {
        serve * serveOBJ = [serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName = @"DonatedTo";
        [serveOBJ GetMemberStats:@"DonatedTo"];
    } */
    
    if ([tagName isEqualToString:@"favorites"])
    {
        NSLog(@"favorites %@",favorites);

        NSError * error;
        favorites = [[NSMutableArray alloc] init];
        favorites = [NSJSONSerialization
                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                     options:kNilOptions
                     error:&error];
    }

    if ([tagName isEqualToString:@"csv"])
    {
        NSDictionary * dictResponse = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([[[dictResponse valueForKey:@"sendTransactionInCSVResult"]valueForKey:@"Result"]isEqualToString:@"1"])
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Export Successful" message:@"Your personalized transaction report has been emailed to you." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
}

#pragma mark Exporting History
- (IBAction)ExportHistory:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Export Transfer Data" message:@"Where should we email your data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 11;
    
    UITextField * textField = [alert textFieldAtIndex:0];
    textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    [alert show];
}

#pragma mark - alert view delegation
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 11 && buttonIndex == 1) // export history
    {
        NSString * email = [[actionSheet textFieldAtIndex:0] text];
        serve * s = [[serve alloc] init];
        [s setTagName:@"csv"];
        [s setDelegate:self];
        [s sendCsvTrasactionHistory:email];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end