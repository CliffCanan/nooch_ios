//
//  LeftMenu.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "LeftMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "HistoryFlat.h"
#import "SettingsOptions.h"
#import "LimitsAndFees.h"
#import "Statistics.h"
#import "SelectCause.h"
#import "SendInvite.h"
#import "Legal.h"
#import "ProfileInfo.h"
#import "UIImageView+WebCache.h"
@interface LeftMenu ()
@property(nonatomic,strong) UITableView *menu;
@property(nonatomic) NSIndexPath *selected;


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
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(65, 40, 150, 20)];
    [name setStyleId:@"lside_firstname"];
     [name setText:@"Preston"];
     [user_bar addSubview:name];
    
    
    
    UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(60, 48, 150, 10)];
    [email setStyleId:@"lside_balance"];
     [email setText:@"$ -20.00"];
     [self.view addSubview:email];
    
    user_pic = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 60, 60)];
    [user_pic setStyleId:@"lside_userpic"];
    [user_pic setStyleCSS:@"background-image : url(Preston.png)"];
    [user_pic setUserInteractionEnabled:YES];
    [user_bar addSubview:user_pic];
    
    [user_pic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(go_profile)]];
    
    UIView *bottom_bar = [UIView new];
    [bottom_bar setStyleId:@"lside_bottombar_background"];
    [self.view addSubview:bottom_bar];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [settings setStyleId:@"settings_icon"];
    [settings addTarget:self action:@selector(go_settings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settings];
    
    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"nooch_whitelogo"];
    [self.view addSubview:logo];
    
    UILabel *version = [UILabel new];
    [version setStyleId:@"version_label"];
    [version setText:@"version 1.1.1."];
    [self.view addSubview:version];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //me=[core new];
    NSLog(@"%@",strUrl);
    if ([strUrl length]>0 && strUrl!=nil) {
        [user_pic setStyleId:@"lside_userpic"];
        [user_pic setImageWithURL:[NSURL URLWithString:strUrl]
            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
        
    }
   }
-(void) go_profile {
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
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,300,23)];
    [title setFont:[UIFont fontWithName:@"VarelaRound-Regular" size:15]];
    title.textColor = [UIColor whiteColor];
    if (section == 0) {
        title.text = @"ACCOUNT";
    }else if(section == 1){
        title.text =  @"DISCOVER";
    }else if(section == 2){
        title.text = @"SOCIAL";
    }else if(section == 3){
        title.text = @"ABOUT";
    }else{
        title.text = @"";
    }
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 22, 320, 1)];
    [bottomLine setBackgroundColor:[UIColor blackColor]];
    [headerView addSubview:bottomLine];
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [topLine setBackgroundColor:[UIColor blackColor]];
    [headerView addSubview:topLine];
    
    [headerView addSubview:title];
    [headerView setBackgroundColor:kNoochBlue];
    [headerView setStyleClass:@"button_blue"];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"ACCOUNT";
    }else if(section == 1){
        return @"DISCOVER";
    }else if(section == 2){
        return @"SOCIAL";
    }else if(section == 3){
        return @"ABOUT";
    }else{
        return @"";
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else if(section == 1){
        return 1;
    }else if(section == 2){
        return 2;
    }else if(section == 3){
        return 4;
    }else{
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
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 25, 25)];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Home";
            iv.image = [UIImage imageNamed:@"nooch-icon.svg"];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Transaction History";
            iv.image = [UIImage imageNamed:@"Clock_Icon.png"];
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"Statistics";
            iv.image = [UIImage imageNamed:@"Stats_Icon.png"];
        }
    }else if(indexPath.section == 1){
        //[cell setAccessoryType:UITableViewCellAccessoryDetailButton];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Donate to a Cause";
            iv.image = [UIImage imageNamed:@"Ribbon_Icon.png"];
        }
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Refer a Friend";
            iv.image = [UIImage imageNamed:@"ReferAFriend_Icon.png"];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Rate Nooch";
            iv.image = [UIImage imageNamed:@"RateNooch_Icon.png"];
        }
    }else if(indexPath.section == 3){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"How Nooch Works";
            iv.image = [UIImage imageNamed:@"Help_Icon.png"];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Contact Support";
            iv.image = [UIImage imageNamed:@"Diamonds_Icon.png"];
        }else if(indexPath.row == 2){
            cell.textLabel.text =  @"Limits & Fees";
            iv.image = [UIImage imageNamed:@"LimitsAndFees_Icon.png"];
        }else if(indexPath.row == 3) {
            cell.textLabel.text = @"Legal Info";
            iv.image = [UIImage imageNamed:@"LegalStuff_Icon.png"];
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
        else if(indexPath.row == 1)
        {
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
    }
    else if(indexPath.section == 1)
    {
        SelectCause *donate = [SelectCause new];
        [nav_ctrl pushViewController:donate animated:NO];
        [self.slidingViewController resetTopView];
    }
    else if(indexPath.section == 2)
    {
        if (indexPath.row == 0) {
            SendInvite *inv = [SendInvite new];
            [nav_ctrl pushViewController:inv animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if(indexPath.row == 1)
        {
            //rate nooch
        }
    }
    else if(indexPath.section == 3)
    {
        if (indexPath.row == 0) {
            //tutorial
        }
        else if(indexPath.row == 1)
        {
            //contact support
        }
        else if(indexPath.row == 2)
        {
            LimitsAndFees *laf = [LimitsAndFees new];
            [nav_ctrl pushViewController:laf animated:NO];
            [self.slidingViewController resetTopView];
        }
        else if(indexPath.row == 3)
        {
            Legal *leg = [Legal new];
            [nav_ctrl pushViewController:leg animated:NO];
            [self.slidingViewController resetTopView];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
