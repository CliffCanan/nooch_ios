//  Statistics.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "Statistics.h"
#import "Home.h"
#import "ECSlidingViewController.h"

@interface Statistics ()
@property(nonatomic,retain) UIView *back_profile;
@property(nonatomic,retain) UIView *back_transfer;
@property(nonatomic,retain) UIView *back_donation;
@property(nonatomic,retain) UITableView *profile_stats;
@property(nonatomic,retain) UITableView *transfer_stats;
@property(nonatomic,retain) UITableView *donation_stats;
@property(nonatomic) int selected;
@property(nonatomic,retain) UIImageView *profile;
@property(nonatomic,retain) UIImageView *transfers;
@property(nonatomic,retain) UIImageView *donations;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.view removeGestureRecognizer:self.navigationController.slidingViewController.panGesture];
    [self.view setStyleClass:@"background_gray"];
    titlestr=@"Profile Stats";
    dictAllStats=[[NSMutableDictionary alloc]init];
    
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"Total_P2P_transfers";
    [serveOBJ GetMemberStats:@"Total_P2P_transfers"];
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Statistics"];

    self.selected = 1;
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(change_stats:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:left];

    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(change_stats:)];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:right];
    
    self.back_profile = [UIView new];
    [self.back_profile setBackgroundColor:[UIColor whiteColor]];
    [self.back_profile setFrame:CGRectMake(-310, 10, 300, 400)];
    [self.back_profile setStyleClass:@"raised_view"];
    [self.view addSubview:self.back_profile];
    
    self.back_transfer = [UIView new];
    [self.back_transfer setBackgroundColor:[UIColor whiteColor]];
    [self.back_transfer setFrame:CGRectMake(10, 10, 300, 400)];
    [self.back_transfer setStyleClass:@"raised_view"];
    [self.view addSubview:self.back_transfer];
    
    self.back_donation = [UIView new];
    [self.back_donation setBackgroundColor:[UIColor whiteColor]];
    [self.back_donation setFrame:CGRectMake(330, 10, 300, 400)];
    [self.back_donation setStyleClass:@"raised_view"];
    [self.view addSubview:self.back_donation];

    self.profile = [UIImageView new];
    [self.profile setStyleClass:@"stats_circle"];
    [self.profile setStyleId:@"stats_circle_profile_active"];
    [self.back_profile addSubview:self.profile];
    
    UIImageView *inactive_trans = [UIImageView new];
    [inactive_trans setStyleClass:@"stats_circle"];
    [inactive_trans setStyleId:@"stats_circle_transfers_inactive"];
    [self.back_profile addSubview:inactive_trans];
    
    UIImageView *inactive_donate = [UIImageView new];
    [inactive_donate setStyleClass:@"stats_circle"];
    [inactive_donate setStyleId:@"stats_circle_donations_inactive"];
    [self.back_profile addSubview:inactive_donate];

    self.transfers = [UIImageView new];
    [self.transfers setStyleClass:@"stats_circle"];
    [self.transfers setStyleId:@"stats_circle_transfers_active"];
    [self.back_transfer addSubview:self.transfers];
    
    UIImageView *inactive_profile = [UIImageView new];
    [inactive_profile setStyleClass:@"stats_circle"];
    [inactive_profile setStyleId:@"stats_circle_profile_inactive"];
    [self.back_transfer addSubview:inactive_profile];
    
    UIImageView *temp1 = [UIImageView new];
    [temp1 setStyleClass:@"stats_circle"];
    [temp1 setStyleId:@"stats_circle_donations_inactive"];
    [self.back_transfer addSubview:temp1];

    self.donations = [UIImageView new];
    [self.donations setStyleClass:@"stats_circle"];
    [self.donations setStyleId:@"stats_circle_donations_active"];
    [self.back_donation addSubview:self.donations];
    
    UIImageView *temp2 = [UIImageView new];
    [temp2 setStyleClass:@"stats_circle"];
    [temp2 setStyleId:@"stats_circle_transfers_inactive"];
    UIImageView *temp3 = [UIImageView new];
    [temp3 setStyleClass:@"stats_circle"];
    [temp3 setStyleId:@"stats_circle_profile_inactive"];
    [self.back_donation addSubview:temp2];
    [self.back_donation addSubview:temp3];

    UILabel *profile_header = [UILabel new];
    [profile_header setStyleClass:@"stats_header"];
    [profile_header setText:@"Profile Stats"];
    [self.back_profile addSubview:profile_header];
    
    UILabel *transfer_header = [UILabel new];
    [transfer_header setStyleClass:@"stats_header"];
    [transfer_header setText:@"Transfer Stats"];
    [self.back_transfer addSubview:transfer_header];
    
    UILabel *donation_header = [UILabel new];
    [donation_header setStyleClass:@"stats_header"];
    [donation_header setText:@"Donation Stats"];
    [self.back_donation addSubview:donation_header];
    
    self.profile_stats = [UITableView new];
    [self.profile_stats setDelegate:self]; [self.profile_stats setDataSource:self];
    [self.profile_stats setStyleClass:@"stats"];
    [self.back_profile addSubview:self.profile_stats];
    [self.profile_stats setUserInteractionEnabled:NO];
    [self.profile_stats reloadData];
    
    self.transfer_stats = [UITableView new];
    [self.transfer_stats setDelegate:self]; [self.transfer_stats setDataSource:self];
    [self.transfer_stats setStyleClass:@"stats"];
    [self.back_transfer addSubview:self.transfer_stats];
    [self.transfer_stats setUserInteractionEnabled:NO];
    [self.transfer_stats reloadData];
    
    self.donation_stats = [UITableView new];
    [self.donation_stats setDelegate:self]; [self.donation_stats setDataSource:self];
    [self.donation_stats setStyleClass:@"stats"];
    [self.back_donation addSubview:self.donation_stats];
    [self.donation_stats setUserInteractionEnabled:NO];
    [self.donation_stats reloadData];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [scroll setDelegate:self];
        [scroll setContentSize:CGSizeMake(320, 550)];
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
            [scroll addSubview:subview];
        }
        [self.view addSubview:scroll];
    }

    blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    UIActivityIndicatorView*actv=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2)-5, 40, 40)];
    [actv startAnimating];
    [blankView addSubview:actv];
    [self .view addSubview:blankView];
    [self.view bringSubviewToFront:blankView];
}

- (void) button_change:(int)num {}

- (void) change_stats:(UISwipeGestureRecognizer *)slide
{
    [UIView beginAnimations:nil context:nil];
    CGRect frame;
    [UIView setAnimationDuration:0.4];
    if (slide.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.selected == 0) {
            [self.transfers setStyleId:@"stats_circle_transfers_active"];
            self.selected++;
            titlestr=@"Transfer Stats";
            frame = self.back_profile.frame;
            frame.origin.x -= 320;
            [self.back_profile setFrame:frame];
            frame = self.back_transfer.frame;
            frame.origin.x -= 320;
            [self.back_transfer setFrame:frame];
            frame = self.back_donation.frame;
            frame.origin.x -= 320;
            [self.back_donation setFrame:frame];
        } else if (self.selected == 1) {
            [self.donations setStyleId:@"stats_circle_donations_active"];
            self.selected++;
            titlestr=@"Donation Stats";
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
    } else if (slide.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.selected == 1) {
            [self.profile setStyleId:@"stats_circle_profile_active"];
            self.selected--;
            titlestr=@"Profile Stats";
            frame = self.back_profile.frame;
            frame.origin.x += 320;
            [self.back_profile setFrame:frame];
            frame = self.back_transfer.frame;
            frame.origin.x += 320;
            [self.back_transfer setFrame:frame];
            frame = self.back_donation.frame;
            frame.origin.x += 320;
            [self.back_donation setFrame:frame];
        } else if (self.selected == 2) {
            [self.transfers setStyleId:@"stats_circle_transfers_active"];
            self.selected--;
            titlestr=@"Transfer Stats";
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

#pragma mark - UITableViewDataSource
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    view.backgroundColor=[UIColor clearColor];
    UILabel*Title=[UILabel new];
    [Title setStyleClass:@"titlelbl"];
    Title.text=titlestr;
    [view addSubview:Title];
    return view;    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:kNoochGrayLight];
    }
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    UILabel *title = [UILabel new];
    UILabel *statistic = [UILabel new];
    [title setStyleClass:@"stats_table_left_lable"];
    [statistic setStyleClass:@"stats_table_right_lable"];

    if (tableView == self.profile_stats) {
        if (indexPath.row == 0) {
           [title setText:@"Friends Invited"];
            if ([dictAllStats valueForKey:@"Total_Friends_Invited"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Friends_Invited"]  valueForKey:@"Result"]];
            }
            if ([[[dictAllStats valueForKey:@"Total_Friends_Invited"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 1) {
            [title setText:@"Invites Accepted"];
            if ([dictAllStats valueForKey:@"Total_Friends_Joined"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Friends_Joined"]  valueForKey:@"Result"]];
            }
            if ([[[dictAllStats valueForKey:@"Total_Friends_Joined"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 2) {
            if ([dictAllStats valueForKey:@"Total_Posts_To_TW"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Posts_To_TW"]  valueForKey:@"Result"]];
            }
            if ([[[dictAllStats valueForKey:@"Total_Posts_To_TW"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
            [title setText:@"Posts to Twitter"];
        }
        else if (indexPath.row == 3) {
            if ([dictAllStats valueForKey:@"Total_Posts_To_FB"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Posts_To_FB"]  valueForKey:@"Result"]];
            }
            if ([[[dictAllStats valueForKey:@"Total_Posts_To_FB"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
            [title setText:@"Posts to Facebook"];
        }
    } 

    else if (tableView == self.transfer_stats) { //transfers

        if (indexPath.row == 0) {
            [title setText:@"Total # of Transfers"];
            if ([dictAllStats valueForKey:@"Total_P2P_transfers"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_P2P_transfers"]  valueForKey:@"Result"]];
            }
            if ([[[dictAllStats valueForKey:@"Total_P2P_transfers"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 1) {
            [title setText:@"Transfers Sent"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_no_of_transfer_Sent"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_no_of_transfer_Sent"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 2) {
            [title setText:@"Transfers Received"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_no_of_transfer_Received"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_no_of_transfer_Received"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 3) {
            [title setText:@"$ Amount Sent"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_$_Sent"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_$_Sent"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 4) {
            [title setText:@"$ Amount Received"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_$_Received"] valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_$_Received"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 5) {
            [title setText:@"Largest Transfer Sent"];
            [statistic setText:[[dictAllStats valueForKey:@"Largest_sent_transfer"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Largest_sent_transfer"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 6) {
            [title setText:@"Largest Transfer Received"];
            [statistic setText:[[dictAllStats valueForKey:@"Largest_received_transfer"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Largest_received_transfer"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
    } 

    else if (tableView == self.donation_stats) { //donations
        if (indexPath.row == 0) {
            [title setText:@"Total $ Donated"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_$_Donated"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_$_Donated"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 1) {
            [title setText:@"Total Donations"];
            [statistic setText:[[dictAllStats valueForKey:@"Total_Donations_Count"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Total_Donations_Count"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 2) {
            [title setText:@"Causes Donated to"];
            [statistic setStyleClass:@"stats_table_right_lable1"];
            [statistic setText:[[[dictAllStats valueForKey:@"DonatedTo"]  valueForKey:@"Result"] capitalizedString]];
            if ([[[dictAllStats valueForKey:@"DonatedTo"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
            }
        }
        else if (indexPath.row == 3) {
            [title setText:@"Largest Donation"];
            [statistic setText:[[dictAllStats valueForKey:@"Largest_Donation_Made"]  valueForKey:@"Result"]];
            if ([[[dictAllStats valueForKey:@"Largest_Donation_Made"]valueForKey:@"Result"] length]==0) {
                [statistic setText:@"0"];
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
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    dictResult= [NSJSONSerialization
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
    }
    else if ([tagName isEqualToString:@"Largest_Donation_Made"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_Donations_Count";
        [serveOBJ GetMemberStats:@"Total_Donations_Count"];
    }
    else if ([tagName isEqualToString:@"Total_Donations_Count"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"Total_$_Donated";
        [serveOBJ GetMemberStats:@"Total_$_Donated"];
    }
    else if ([tagName isEqualToString:@"Total_$_Donated"]) {
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        serveOBJ.tagName=@"DonatedTo";
        [serveOBJ GetMemberStats:@"DonatedTo"];
        [blankView removeFromSuperview];
        [self.profile_stats reloadData];
        [self.transfer_stats reloadData];
        [self.donation_stats reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end