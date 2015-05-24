//
//  MyApartment.m
//  Nooch
//
//  Created by Cliff Canan on 1/14/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "MyApartment.h"
#import "ECSlidingViewController.h"
#import "UIImageView+WebCache.h"
#import "Home.h"
#import "ProfileInfo.h"
#import "SelectApt.h"
#import "HistoryFlat.h"
#import "SetAptDetails.h"
#import "knoxWeb.h"
#import "HowMuch.h"

@interface MyApartment (){
    UILabel * introText;
    UILabel * aptName;
    UILabel * aptAddress;
    UILabel * aptWebsite;
    UILabel * autoPaySetting;
    UILabel * lastPymntDate;
    UILabel * monthlyRentAmount;
    NSString * aptWebsiteUrl;
    UIImageView * bank_image;
    UITableView * menu;
    UIView * topSectionContainer;
    UIButton * unlink_account;
    UIButton * payRentBtn;
    UILabel *glyph_noBank;
    UIScrollView * scroll;
}
@property(nonatomic,strong) NSMutableArray * lastPayments;
@property(nonatomic,strong) UIButton * rentBox;

@end

@implementation MyApartment

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isBankAttached = NO;
    
    if ((isKnoxOn && [user boolForKey:@"IsKnoxBankAvailable"]) ||
        (isSynapseOn && [user boolForKey:@"IsSynapseBankAvailable"]))
    {
        isBankAttached = YES;
    }
    else
    {
        isBankAttached = NO;
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

    [self.navigationItem setRightBarButtonItem:Nil];

    UIButton * glyph_add = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [glyph_add setStyleClass:@"navbar_rightside_icon"];
    [glyph_add addTarget:self action:@selector(goToSelectAptScrn) forControlEvents:UIControlEventTouchUpInside];
    [glyph_add setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"] forState:UIControlStateNormal];
    [glyph_add setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.24) forState:UIControlStateNormal];
    glyph_add.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    UIBarButtonItem * addProperty = [[UIBarButtonItem alloc] initWithCustomView:glyph_add];
    [self.navigationItem setRightBarButtonItem: addProperty];

    [self.navigationItem setTitle:@"Settings"];
    [self.slidingViewController.panGesture setEnabled:YES];

    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.view setStyleClass:@"background_gray"];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 250, 20)];
    [title setStyleClass:@"refer_header"];
    [title setText:@"My Apartment"];
    [self.view addSubview:title];

    topSectionContainer = [[UIView alloc] initWithFrame:CGRectMake(8, 42, 304, 168)];
    topSectionContainer.backgroundColor = [UIColor whiteColor];
    [topSectionContainer setStyleClass:@"raised_view_AptScrn"];
    [self.view addSubview:topSectionContainer];

    aptName = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 200, 21)];
    [aptName setFont:[UIFont fontWithName:@"Roboto-medium" size:18]];
    [aptName setTextColor:kNoochGrayDark];
    aptName.text = @"Belmont Village";
    [topSectionContainer addSubview:aptName];

    aptAddress = [[UILabel alloc] initWithFrame:CGRectMake(9, 26, 170, 36)];
    [aptAddress setFont:[UIFont fontWithName:@"Roboto-regular" size:13]];
    [aptAddress setTextColor:kNoochGrayDark];
    [aptAddress setText:@"7246 Dresden Ave, Philadelphia, PA 19876"];
    [aptAddress setNumberOfLines:0];
    [topSectionContainer addSubview:aptAddress];

    aptWebsite = [[UILabel alloc] initWithFrame:CGRectMake(9, 62, 188, 16)];
    [aptWebsite setFont:[UIFont fontWithName:@"Roboto-regular" size:13]];
    [aptWebsite setTextColor:kNoochBlue];
    [aptWebsite setUserInteractionEnabled:YES];
    aptWebsite.text = @"www.BelmontVillage.com";
    aptWebsiteUrl = @"https://www.nooch.com";
    [aptWebsite addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAptWebsite)]];
    [topSectionContainer addSubview:aptWebsite];

    UILabel * autoPayLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, 81, 100, 16)];
    [autoPayLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 13]];
    [autoPayLbl setTextColor:kNoochGrayLight];
    autoPayLbl.text = @"Auto Pay:";
    [topSectionContainer addSubview:autoPayLbl];

    autoPaySetting = [[UILabel alloc] initWithFrame:CGRectMake(67, 81, 30, 17)];
    [topSectionContainer addSubview:autoPaySetting];

    UILabel * lastPymntLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, 89, 100, 15)];
    [lastPymntLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 12]];
    [lastPymntLbl setTextColor:kNoochGrayLight];
    lastPymntLbl.text = @"Last Payment:";
    //[topSectionContainer addSubview:lastPymntLbl];

    lastPymntDate = [[UILabel alloc] initWithFrame:CGRectMake(88, 89, 90, 15)];
    [lastPymntDate setFont:[UIFont fontWithName:@"Roboto-light" size: 12]];
    [lastPymntDate setTextColor:kNoochGrayDark];
    lastPymntDate.text = @"Jan 2, 2015";
    //[topSectionContainer addSubview:lastPymntDate];

    self.rentBox = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.rentBox setFrame:CGRectMake(190, 6, 102, 82)];
    [self.rentBox addTarget:self action:@selector(goSetAptDetails) forControlEvents:UIControlEventTouchUpInside];
    [self.rentBox addTarget:self action:@selector(stayPressed:) forControlEvents:UIControlEventTouchDown];
    self.rentBox.layer.cornerRadius = 4;
    self.rentBox.backgroundColor = kNoochBlue;
    [self.rentBox setStyleClass:@"raised_view_AptScrn"];

    [topSectionContainer addSubview:self.rentBox];

    UILabel * monthlyRentLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.rentBox.bounds.size.width, 18)];
    [monthlyRentLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 14]];
    [monthlyRentLbl setTextColor:[UIColor whiteColor]];
    [monthlyRentLbl setTextAlignment:NSTextAlignmentCenter];
    monthlyRentLbl.text = @"Monthly Rent:";
    [self.rentBox addSubview:monthlyRentLbl];

    monthlyRentAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, self.rentBox.bounds.size.width, 31)];
    [monthlyRentAmount setFont:[UIFont fontWithName:@"Roboto-medium" size: 23]];
    [monthlyRentAmount setTextColor:[UIColor whiteColor]];
    [monthlyRentAmount setTextAlignment:NSTextAlignmentCenter];
    monthlyRentAmount.text = @"$ 650";
    [self.rentBox addSubview:monthlyRentAmount];

    UILabel * monthlyRentEdit = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.rentBox.bounds.size.width, 15)];
    [monthlyRentEdit setFont:[UIFont fontWithName:@"Roboto-regular" size: 11]];
    [monthlyRentEdit setTextColor:[UIColor whiteColor]];
    [monthlyRentEdit setTextAlignment:NSTextAlignmentCenter];
    monthlyRentEdit.text = @"EDIT";
    [self.rentBox addSubview:monthlyRentEdit];

    payRentBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [payRentBtn setFrame:CGRectMake(0, 159, 0, 0)];
    if (isBankAttached)
    {
        [payRentBtn setTitle:@"Pay Rent Now" forState:UIControlStateNormal];
        [payRentBtn addTarget:self action:@selector(goToHowMuch) forControlEvents:UIControlEventTouchUpInside];
        [payRentBtn setStyleClass:@"button_green_shorter"];
    }
    else
    {
        [payRentBtn setTitle:@"Link a Bank Now" forState:UIControlStateNormal];
        [payRentBtn addTarget:self action:@selector(attach_bank) forControlEvents:UIControlEventTouchUpInside];
        [payRentBtn setStyleClass:@"button_blue_shorter"];
    }
    [payRentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payRentBtn setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    payRentBtn.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };
    
    UILabel * glyph = [UILabel new];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [glyph setFrame:CGRectMake(40, 0, 30, 42)];
    glyph.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-square-o"]
                                                           attributes:textAttributes1];
    [glyph setTextColor:[UIColor whiteColor]];
    [payRentBtn addSubview:glyph];
    [self.view addSubview:payRentBtn];

    UILabel * lastPaymentHdr = [[UILabel alloc] initWithFrame:CGRectMake(15, 224, 250, 20)];
    [lastPaymentHdr setStyleClass:@"refer_header"];
    [lastPaymentHdr setText:@"Last Payments"];
    [self.view addSubview:lastPaymentHdr];

    menu = [UITableView new];
    [menu setStyleId:@"myAptLastPayments"];
    [menu setStyleClass:@"raised_view_AptScrn"];
    [menu setDelegate:self];
    [menu setDataSource:self];
    [menu setScrollEnabled:NO];
    [self.view addSubview:menu];

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

    serve *  serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"getAptDetails";
    //[serveOBJ getAptDetails:[[NSUserDefaults standardUserDefaults ]valueForKey:@"MemberId"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"My Apartment"];
    self.screenName = @"My Apartment Screen";
    self.artisanNameTag = @"My Apartment Screen";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([[user objectForKey:@"isAutoPayEnabled"]isEqualToString:@"1"])
    {
        [autoPaySetting setFont:[UIFont fontWithName:@"Roboto-medium" size: 13]];
        [autoPaySetting setTextColor:kNoochGreen];
        autoPaySetting.text = @"On";
    }
    else
    {
        [autoPaySetting setFont:[UIFont fontWithName:@"Roboto-regular" size: 13]];
        [autoPaySetting setTextColor:kNoochRed];
        autoPaySetting.text = @"Off";
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)attach_bank
{
    NSLog(@"My APARTMENT.M --> ATTACH BANK");
    if (isBankAttached)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Attach New Bank Account"
                                                     message:@"You can only have one bank account attached at a time.  If you link a new account, that will replace your current bank account. This cannot be undone.\n\nAre you sure you want to replace this bank account?"
                                                    delegate:self
                                           cancelButtonTitle:@"Yes - Replace"
                                           otherButtonTitles:@"Cancel", nil];
        [av setTag:32];
        [av show];
    }
    else
    {
        knoxWeb *knox = [knoxWeb new];
        [self.navigationController pushViewController:knox animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
        cell.indentationLevel = 1;
    }

    if (indexPath.row < 3)
    {
        cell.indentationWidth = 50;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView * pic = [[UIImageView alloc] initWithFrame:CGRectMake(14, 6, 36, 36)];
        pic.clipsToBounds = YES;
        pic.hidden = NO;
        pic.layer.cornerRadius = 6;
        [pic sd_setImageWithURL:[NSURL URLWithString:@"https://www.nooch.com/staging/web-app/images/apt1.jpg"]
               placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        [pic setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:pic];

        UILabel * month = [[UILabel alloc] initWithFrame:CGRectMake(66, 8, 100, 16)];
        [month setText:@"January 2015"];
        [month setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];

        UILabel * paymentAmount = [[UILabel alloc] initWithFrame:CGRectMake(66, 28, 100, 14)];
        [paymentAmount setFont:[UIFont fontWithName:@"Roboto-regular" size:13]];
        [paymentAmount setTextColor:kNoochRed];
        paymentAmount.text = @"$650";

        UIView * statusBar = [[UIView alloc] initWithFrame:CGRectMake(230, 8, 68, 12)];
        statusBar.backgroundColor = kNoochGreen;
        statusBar.layer.cornerRadius = 3;
        [cell.contentView addSubview: statusBar];

        UILabel * statusBarText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 68, 12)];
        [statusBarText setFont:[UIFont fontWithName:@"Roboto-medium" size:9]];
        [statusBarText setText: @"PAID"];
        [statusBarText setTextColor:[UIColor whiteColor]];
        [statusBarText setTextAlignment:NSTextAlignmentCenter];
        [statusBar addSubview:statusBarText];

        UILabel * glyph_status = [[UILabel alloc] initWithFrame:CGRectMake(231, 22, 20, 18)];
        [glyph_status setTextColor:kNoochGreen];
        [glyph_status setFont:[UIFont fontWithName:@"FontAwesome" size:11]];
        [glyph_status setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"]];

        UILabel * statusBarDate = [[UILabel alloc] initWithFrame:CGRectMake(246, 22, 60, 18)];
        [statusBarDate setFont:[UIFont fontWithName:@"Roboto-regular" size:10]];
        [statusBarDate setTextColor:kNoochGrayDark];
        statusBarDate.text = @"Jan 2, 2015";

        [cell.contentView addSubview: month];
        [cell.contentView addSubview: paymentAmount];
        [cell.contentView addSubview: glyph_status];
        [cell.contentView addSubview: statusBarDate];

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    else if (indexPath.row == 3)
    {
        UILabel * seeAll = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, menu.bounds.size.width, 18)];
        [seeAll setTextAlignment:NSTextAlignmentCenter];
        [seeAll setTextColor:kNoochBlue];
        [seeAll setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];
        [seeAll setText:@"See All"];
        [cell.contentView addSubview:seeAll];

        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3)
    {
        isFromApts = YES;
        listType = @"REQUESTS";
        HistoryFlat * history = [HistoryFlat new];
        [self.navigationController pushViewController:history animated:NO];
    }
}

-(void)goToSelectAptScrn
{
    if (isFromPropertySearch)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        SelectApt * selectApt = [SelectApt new];
        [self.navigationController pushViewController:selectApt animated:YES];
    }
}

-(void)goToHowMuch
{
    NSMutableDictionary * aptToPay = [NSMutableDictionary new];
    [aptToPay setObject:@"MemberId" forKey:@"MemberId"];
    [aptToPay setObject:@"Bellevue Apartments" forKey:@"AptName"];
    [aptToPay setObject:@"650" forKey:@"RentAmount"];
    //[aptToPay setObject:[NSString stringWithFormat:@"https://www.nooch.com/staging/web-app/images/apt1.jpg"] forKey:@"Photo"];

    isFromMyApt = YES;
    HowMuch * howMuch = [[HowMuch alloc] initWithReceiver: aptToPay];
    [self.navigationController pushViewController:howMuch animated:YES];
}

-(void)goSetAptDetails
{
    [self.rentBox setFrame:CGRectMake(190, 6, 102, 82)];
    SetAptDetails * setAptsDetails = [SetAptDetails new];
    [self performSelector:@selector(navigate_to:) withObject:setAptsDetails afterDelay:0.12];
}

-(void)openAptWebsite
{
    UIApplication * mySafari = [UIApplication sharedApplication];
    NSURL * aptURL = [[NSURL alloc]initWithString: aptWebsiteUrl];
    [mySafari openURL:aptURL];
}

-(void)stayPressed:(UIButton *) sender
{
    [self.rentBox setFrame:CGRectMake(190, 9, 102, 82)];
}

- (void) navigate_to:(id)view
{
    [self.navigationController pushViewController:view animated:YES];
}

-(void)Error:(NSError *)Error
{
    /*UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];*/
}

-(void)loadDelay
{
    NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];
    [arrNav removeLastObject];
    [nav_ctrl setViewControllers:arrNav animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    NSLog(@"Result is: %@", result);

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];
        
        [timer invalidate];
        
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        
        [[assist shared]setPOP:YES];
        [self performSelector:@selector(loadDelay) withObject:Nil afterDelay:1.0];
    }

    if ([tagName isEqualToString:@"getAptDetials"])
    {
        NSError * error;

        NSMutableDictionary * dictResponse = [NSJSONSerialization
                                              JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                              options:kNilOptions
                                              error:&error];

        if (![[dictResponse valueForKey:@"aptName"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"aptAddress"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"aptWebsite"] isKindOfClass:[NSNull class]])
        {
            [user setObject:@"1" forKey:@"HasAptSelected"];
            [user synchronize];

            isBankAttached = YES;
            aptName.text = [dictResponse valueForKey:@"aptName"];
            aptAddress.text = [dictResponse valueForKey:@"aptAddress"];
            aptWebsite.text = [dictResponse valueForKey:@"aptWebsite"];
            aptWebsiteUrl = [dictResponse valueForKey:@"aptWebsite"];

            monthlyRentAmount.text = [dictResponse valueForKey:@"monthlyRentAmount"];
            autoPaySetting.text = [dictResponse valueForKey:@"autoPaySetting"];
            lastPymntDate.text = @"";
        }
    }

    else if ([tagName isEqualToString:@"getLastPayments"])
    {
        NSError * error;
        
        self.lastPayments = [NSJSONSerialization
                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                             options:kNilOptions
                             error:&error];
    }
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 32)
    {
        if (buttonIndex == 0)
        {
            knoxWeb *knox = [knoxWeb new];
            [self.navigationController pushViewController:knox animated:YES];
        }
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
}
@end
