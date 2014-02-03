//
//  Statistics.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "Statistics.h"
#import "Home.h"
#import "ECSlidingViewController.h"

@interface Statistics ()
@property(nonatomic,retain) UIView *back;
@property(nonatomic,retain) UITableView *stats;
@property(nonatomic) int selected;
@property(nonatomic,retain) UIImageView *profile;
@property(nonatomic,retain) UIImageView *transfers;
@property(nonatomic,retain) UIImageView *donations;
@property(nonatomic,retain) UILabel *header;
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
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.view removeGestureRecognizer:self.navigationController.slidingViewController.panGesture];
    [self.view setStyleClass:@"background_gray"];
    
    dictAllStats=[[NSMutableDictionary alloc]init];
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setFrame:CGRectMake(0, 0, 40, 40)];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setStyleId:@"navbar_hamburger"];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    

    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"Total_P2P_transfers";
    [serveOBJ GetMemberStats:@"Total_P2P_transfers"];
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Statistics"];
    
    self.selected = 0;
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(change_stats:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(change_stats:)];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:right];
    
    self.back = [UIView new];
    [self.back setBackgroundColor:[UIColor whiteColor]];
    [self.back setFrame:CGRectMake(10, 10, 300, 425)];
    [self.back setStyleClass:@"raised_view"];
    [self.view addSubview:self.back];
    
    self.profile = [UIImageView new];
    [self.profile setStyleClass:@"stats_circle"];
    [self.profile setStyleId:@"stats_circle_profile_active"];
    [self.back addSubview:self.profile];
    
    self.transfers = [UIImageView new];
    [self.transfers setStyleClass:@"stats_circle"];
    [self.transfers setStyleId:@"stats_circle_transfers_inactive"];
    [self.back addSubview:self.transfers];
    
    self.donations = [UIImageView new];
    [self.donations setStyleClass:@"stats_circle"];
    [self.donations setStyleId:@"stats_circle_donations_inactive"];
    [self.back addSubview:self.donations];
    
    self.header = [UILabel new];
    [self.header setText:@"Profile Stats"];
    [self.header setStyleClass:@"stats_header"];
    [self.back addSubview:self.header];
    
    self.stats = [UITableView new];
    [self.stats setDelegate:self]; [self.stats setDataSource:self];
    [self.stats setStyleClass:@"stats"];
    [self.back addSubview:self.stats];
    [self.stats setUserInteractionEnabled:NO];
    [self.stats reloadData];
}

- (void) change_stats:(UISwipeGestureRecognizer *)slide
{
    [UIView beginAnimations:nil context:nil];
    CGRect frame = self.back.frame;
    [UIView setAnimationDuration:0.5];
    if (slide.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.selected == 0) {
            self.selected++;
            [self.profile setStyleId:@"stats_circle_profile_inactive"];
            [self.transfers setStyleId:@"stats_circle_transfers_active"];
            [self.donations setStyleId:@"stats_circle_donations_inactive"];
        } else if (self.selected == 1) {
            self.selected++;
            [self.profile setStyleId:@"stats_circle_profile_inactive"];
            [self.transfers setStyleId:@"stats_circle_transfers_inactive"];
            [self.donations setStyleId:@"stats_circle_donations_active"];
        } else {
            return;
        }
    } else if (slide.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.selected == 1) {
            self.selected--;
            [self.profile setStyleId:@"stats_circle_profile_active"];
            [self.transfers setStyleId:@"stats_circle_transfers_inactive"];
            [self.donations setStyleId:@"stats_circle_donations_inactive"];
        } else if (self.selected == 2) {
            self.selected--;
            [self.profile setStyleId:@"stats_circle_profile_inactive"];
            [self.transfers setStyleId:@"stats_circle_transfers_active"];
            [self.donations setStyleId:@"stats_circle_donations_inactive"];
        } else {
            return;
        }
    }
    if (slide.direction == UISwipeGestureRecognizerDirectionLeft) {
        frame.origin.x = -320;
    } else {
        frame.origin.x = 320;
    }
    [self.back setFrame:frame];
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(refocus)
                                   userInfo:nil
                                    repeats:NO];
    [self.stats reloadData];
}

- (void) refocus
{
    CGRect frame = self.back.frame;
    frame.origin.x = frame.origin.x * -1;
    self.back.frame = frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    frame.origin.x = 10;
    [self.back setFrame:frame];
    [UIView commitAnimations];
}

#pragma mark - UITableViewDataSource

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
    
    if (self.selected == 0) { //profile
        
        
        if (indexPath.row == 0) {
            [title setText:@"$ Added to Nooch"];
            [statistic setText:@"$ 105.00"];
             [statistic setText:[[dictAllStats valueForKey:@"Total_$_Added_to_Nooch"]  valueForKey:@"Result"]];
            //Total_$_Added_to_Nooch
        }
        else if (indexPath.row == 1) {
            [title setText:@"$ Cashed out of Nooch"];
            //[statistic setText:@"$ 200.00"];
             [statistic setText:[[dictAllStats valueForKey:@"Total_$_withdraw_from_Nooch"]  valueForKey:@"Result"]];
            //Total_$_withdraw_from_Nooch
        }
        else if (indexPath.row == 2) {
            [title setText:@"Friends Invited"];
            if ([dictAllStats valueForKey:@"Total_Friends_Invited"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Friends_Invited"]  valueForKey:@"Result"]];
            }
            //"
            // [statistic setText:@"4"];
        }
        else if (indexPath.row == 3) {
            [title setText:@"Invites Accepted"];
            if ([dictAllStats valueForKey:@"Total_Friends_Joined"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Friends_Joined"]  valueForKey:@"Result"]];
            }
           // [statistic setText:@"7"];
        }
        else if (indexPath.row == 4) {
            [title setText:@"$ Earned from Invites"];
            //[statistic setText:@"$ 25.00"];
        }
        else if (indexPath.row == 5) {
            if ([dictAllStats valueForKey:@"Total_Posts_To_TW"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Posts_To_TW"]  valueForKey:@"Result"]];
            }

            [title setText:@"Posts to Twitter"];
           // [statistic setText:@"0"];
        }
        else if (indexPath.row == 6) {
            if ([dictAllStats valueForKey:@"Total_Posts_To_FB"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_Posts_To_FB"]  valueForKey:@"Result"]];
            }

            [title setText:@"Posts to Facebook"];
           // [statistic setText:@"3"];
        }
    } else if (self.selected == 1) { //transfers
        
        
        if (indexPath.row == 0) {
            [title setText:@"Total # of Transfers"];
            //[statistic setText:@"27"];
            if ([dictAllStats valueForKey:@"Total_P2P_transfers"]) {
                [statistic setText:[[dictAllStats valueForKey:@"Total_P2P_transfers"]  valueForKey:@"Result"]];
            }
            

            //
        }
        else if (indexPath.row == 1) {
            [title setText:@"Transfers Sent"];
             [statistic setText:[[dictAllStats valueForKey:@"Total_no_of_transfer_Sent"]  valueForKey:@"Result"]];
           // [statistic setText:@"17"];
        }
        else if (indexPath.row == 2) {
            [title setText:@"Transfers Received"];
             [statistic setText:[[dictAllStats valueForKey:@"Total_no_of_transfer_Received"]  valueForKey:@"Result"]];
            //[statistic setText:@"4"];
        }
        else if (indexPath.row == 3) {
            [title setText:@"$ Amount Sent"];
             [statistic setText:[[dictAllStats valueForKey:@"Total_$_Sent"]  valueForKey:@"Result"]];
           // [statistic setText:@"$ 256.75"];
        }
        else if (indexPath.row == 4) {
            [title setText:@"$ Amount Received"];
            //Total_$_Received
           // [statistic setText:@"$ 123.00"];
             [statistic setText:[[dictAllStats valueForKey:@"Total_$_Received"] valueForKey:@"Result"]];
        }
        else if (indexPath.row == 5) {
            [title setText:@"Largest Transfer Sent"];
            //Largest_sent_transfer
            [statistic setText:[[dictAllStats valueForKey:@"Largest_sent_transfer"]  valueForKey:@"Result"]];
           // [statistic setText:@"$ 75.00"];
        }
        else if (indexPath.row == 6) {
          
            
            [title setText:@"Largest Transfer Received"];
             [statistic setText:[[dictAllStats valueForKey:@"Largest_received_transfer"]  valueForKey:@"Result"]];
          //  [statistic setText:@"$ 70.03"];
        }
    } else if (self.selected == 2) { //donations
        
        
        if (indexPath.row == 0) {
            [title setText:@"Total $ Donated"];
            //[statistic setText:@"$ 105.00"];
        }
        else if (indexPath.row == 1) {
            [title setText:@"Total Donations"];
            //[statistic setText:@"3"];
        }
        else if (indexPath.row == 2) {
            [title setText:@"Causes Donated to"];
            [statistic setText:@"4"];
        }
        else if (indexPath.row == 3) {
            [title setText:@"Largest Donation"];
           // [statistic setText:@"$ 125.00"];
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
    
    NSLog(@"%@",dictResult);
   [ dictAllStats setObject:dictResult forKey:tagName];
    NSLog(@"%@",dictAllStats);

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
   }//Total_Posts_To_FB
    //Total_$_Added_to_Nooch
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
