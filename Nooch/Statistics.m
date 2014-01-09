//
//  Statistics.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "Statistics.h"
#import "Home.h"

@interface Statistics ()
@property(nonatomic,retain) UIView *back;
@property(nonatomic,retain) UITableView *stats;
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
    dictAllStats=[[NSMutableDictionary alloc]init];
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"getStats";
    [serveOBJ GetMemberStats:@"Total_P2P_transfers"];
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Statistics"];
    
    self.back = [UIView new];
    [self.back setBackgroundColor:[UIColor whiteColor]];
    [self.back setFrame:CGRectMake(10, 10, 300, 425)];
    [self.back setStyleClass:@"raised_view"];
    [self.view addSubview:self.back];
    
    UIImageView *profile = [UIImageView new];
    [profile setStyleClass:@"stats_circle"];
    [profile setStyleId:@"stats_circle_profile_active"];
    [self.back addSubview:profile];
    
    UIImageView *transfers = [UIImageView new];
    [transfers setStyleClass:@"stats_circle"];
    [transfers setStyleId:@"stats_circle_transfers_inactive"];
    [self.back addSubview:transfers];
    
    UIImageView *donations = [UIImageView new];
    [donations setStyleClass:@"stats_circle"];
    [donations setStyleId:@"stats_circle_donations_inactive"];
    [self.back addSubview:donations];
    
    UILabel *header = [UILabel new];
    [header setText:@"Profile Stats"];
    [header setStyleClass:@"stats_header"];
    [self.back addSubview:header];
    
    self.stats = [UITableView new];
    [self.stats setDelegate:self]; [self.stats setDataSource:self];
    [self.stats setStyleClass:@"stats"];
    [self.back addSubview:self.stats];
    [self.stats setUserInteractionEnabled:NO];
    [self.stats reloadData];
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
    
    UILabel *title = [UILabel new];
    UILabel *statistic = [UILabel new];
    [title setStyleClass:@"stats_table_left_lable"];
    [statistic setStyleClass:@"stats_table_right_lable"];
    
    if (indexPath.row == 0) {
        [title setText:@"$ Added to Nooch"];
        [statistic setText:@"$105.00"];
    }
    else if (indexPath.row == 1) {
        [title setText:@"$ Cashed out of Nooch"];
        [statistic setText:@"$200.00"];
    }
    else if (indexPath.row == 2) {
        [title setText:@"Friends Invited"];
        [statistic setText:@"4"];
    }
    else if (indexPath.row == 3) {
        [title setText:@"Invites Accepted"];
        [statistic setText:@"7"];
    }
    else if (indexPath.row == 4) {
        [title setText:@"$ Earned from Invites"];
        [statistic setText:@"$25.00"];
    }
    else if (indexPath.row == 5) {
        [title setText:@"Posts to Twitter"];
        [statistic setText:@"0"];
    }
    else if (indexPath.row == 6) {
        [title setText:@"Posts to Facebook"];
        [statistic setText:@"3"];
    }
    [cell.contentView addSubview:title];
    [cell.contentView addSubview:statistic];
    return cell;
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
   [ dictAllStats setObject:dictResult forKey:tagName];/*
 Get_Member_Signup_Date
 Malkit Says
 Total_P2P_transfers
 Malkit Says
 Total_$_Sent
 Malkit Says
 Total_#_of_transfer Sent
 Malkit Says
 Total_$_Received
 Malkit Says
 Total_#_of_transfer_Received
 Malkit Says
 Smallest_sent_transfer

 */
    
    if ([tagName isEqualToString:@"getStats"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats1";
        
        [serveOBJ GetMemberStats:@"Get_Member_Signup_Date"];
    }
    else if ([tagName isEqualToString:@"getStats1"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats2";
        
        [serveOBJ GetMemberStats:@"Total_$_Sent"];
    }
    else if ([tagName isEqualToString:@"getStats2"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats3";
        
        [serveOBJ GetMemberStats:@"Total_#_of_transfer Sent"];
    }
    else if ([tagName isEqualToString:@"getStats3"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats4";
        
        [serveOBJ GetMemberStats:@"Total_$_Received"];
    }
    else if ([tagName isEqualToString:@"getStats4"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats5";
        
        [serveOBJ GetMemberStats:@"Total_#_of_transfer_Received"];
    }
   else if ([tagName isEqualToString:@"getStats5"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats6";
        
        [serveOBJ GetMemberStats:@"Smallest_sent_transfer"];
    }
    else if ([tagName isEqualToString:@"getStats6"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats7";
        
        [serveOBJ GetMemberStats:@"Smallest_received_transfer"];
    }
    else if ([tagName isEqualToString:@"getStats7"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats8";
        
        [serveOBJ GetMemberStats:@"Largest_sent_transfer"];
    }
    
   else if ([tagName isEqualToString:@"getStats8"]) {
        serve*serveOBJ=[serve new];
        
        [serveOBJ setDelegate:self];
        
        serveOBJ.tagName=@"getStats10";
        
        [serveOBJ GetMemberStats:@"Largest_received_transfer"];
    }

    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
