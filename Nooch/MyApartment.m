//
//  MyApartment.m
//  Nooch
//
//  Created by Cliff Canan on 1/14/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "MyApartment.h"
#import "Home.h"
#import "ProfileInfo.h"
#import "SelectApt.h"
#import "ECSlidingViewController.h"
#import "knoxWeb.h"
#import "UIImageView+WebCache.h"

@interface MyApartment (){
    UILabel * introText;
    UILabel * aptName;
    UILabel * aptAddress;
    UILabel * aptWebsite;
    UILabel * autoPaySetting;
    UILabel * lastPymntDate;
    NSString * aptWebsiteUrl;
    UIImageView * bank_image;
    UITableView * menu;
    UIView * topSectionContainer;
    UIButton * unlink_account;
    UIButton * payRentBtn;
    UILabel *glyph_noBank;
    UIScrollView * scroll;
}
@property(atomic,weak)UIButton *logout;

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
    
    if ( ![[[NSUserDefaults standardUserDefaults] objectForKey:@"IsBankAvailable"]isEqualToString:@"1"])
    {
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
        [introText setText:@"Attach a bank account to send or receive payments. Just select your bank, login to your online banking, and you're done."];
        [introText setTextAlignment:NSTextAlignmentCenter];
        [introText setStyleId:@"settings_introText"];
        [self.view addSubview:introText];
    }
    else
    {
        isBankAttached = YES;
        [glyph_noBank removeFromSuperview];
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

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 250, 20)];
    [title setStyleClass:@"refer_header"];
    [title setText:@"My Apartment"];
    [self.view addSubview:title];

    UIButton * glyph_add = [[UIButton alloc] initWithFrame:CGRectMake(290, 12, 22, 21)];
    [glyph_add setStyleClass:@"glyphAdd"];
    [glyph_add setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"] forState:UIControlStateNormal];
    [glyph_add addTarget:self action:@selector(goToSelectApt) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:glyph_add];

    topSectionContainer = [[UIView alloc] initWithFrame:CGRectMake(8, 42, 304, 168)];
    topSectionContainer.backgroundColor = [UIColor whiteColor];
    [topSectionContainer setStyleClass:@"raised_view_AptScrn"];
    [self.view addSubview:topSectionContainer];

    aptName = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 200, 22)];
    [aptName setFont:[UIFont fontWithName:@"Roboto-medium" size:17]];
    [aptName setTextColor:kNoochGrayDark];
    aptName.text = @"Belmont Village";
    [topSectionContainer addSubview:aptName];

    aptAddress = [[UILabel alloc] initWithFrame:CGRectMake(9, 28, 188, 18)];
    [aptAddress setFont:[UIFont fontWithName:@"Roboto-regular" size:12]];
    [aptAddress setTextColor:kNoochGrayDark];
    aptAddress.text = @"7246 Dresden Ave, Philadelphia, PA 19876";
    [topSectionContainer addSubview:aptAddress];

    aptWebsite = [[UILabel alloc] initWithFrame:CGRectMake(9, 46, 188, 18)];
    [aptWebsite setFont:[UIFont fontWithName:@"Roboto-regular" size:12]];
    [aptWebsite setTextColor:kNoochBlue];
    [aptWebsite setUserInteractionEnabled:YES];
    aptWebsite.text = @"www.BelmontVillage.com";
    aptWebsiteUrl = @"https://www.nooch.com";
    [aptWebsite addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAptWebsite)]];
    [topSectionContainer addSubview:aptWebsite];

    UILabel * autoPayLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, 70, 100, 15)];
    [autoPayLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 12]];
    [autoPayLbl setTextColor:kNoochGrayLight];
    autoPayLbl.text = @"Auto Pay:";
    [topSectionContainer addSubview:autoPayLbl];

    autoPaySetting = [[UILabel alloc] initWithFrame:CGRectMake(64, 70, 30, 15)];
    [autoPaySetting setFont:[UIFont fontWithName:@"Roboto-light" size: 12]];
    [autoPaySetting setTextColor:kNoochRed];
    autoPaySetting.text = @"Off";
    [topSectionContainer addSubview:autoPaySetting];

    UILabel * lastPymntLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, 89, 100, 15)];
    [lastPymntLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 12]];
    [lastPymntLbl setTextColor:kNoochGrayLight];
    lastPymntLbl.text = @"Last Payment:";
    [topSectionContainer addSubview:lastPymntLbl];

    lastPymntDate = [[UILabel alloc] initWithFrame:CGRectMake(88, 89, 90, 15)];
    [lastPymntDate setFont:[UIFont fontWithName:@"Roboto-light" size: 12]];
    [lastPymntDate setTextColor:kNoochGrayDark];
    lastPymntDate.text = @"Jan 3, 2015";
    [topSectionContainer addSubview:lastPymntDate];

    UIView * rentBox = [[UIView alloc] initWithFrame:CGRectMake(196, 6, 100, 80)];
    rentBox.layer.cornerRadius = 4;
    rentBox.clipsToBounds = YES;
    rentBox.backgroundColor = kNoochGreen;
    [rentBox setStyleClass:@"raised_view_AptScrn"];
    [topSectionContainer addSubview:rentBox];

    UILabel * monthlyRentLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, rentBox.bounds.size.width, 18)];
    [monthlyRentLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 14]];
    [monthlyRentLbl setTextColor:[UIColor whiteColor]];
    [monthlyRentLbl setTextAlignment:NSTextAlignmentCenter];
    monthlyRentLbl.text = @"Monthly Rent:";
    [rentBox addSubview:monthlyRentLbl];

    UILabel * monthlyRentAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, rentBox.bounds.size.width, 31)];
    [monthlyRentAmount setFont:[UIFont fontWithName:@"Roboto-medium" size: 23]];
    [monthlyRentAmount setTextColor:[UIColor whiteColor]];
    [monthlyRentAmount setTextAlignment:NSTextAlignmentCenter];
    monthlyRentAmount.text = @"$ 650";
    [rentBox addSubview:monthlyRentAmount];

    UILabel * monthlyRentEdit = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, rentBox.bounds.size.width, 15)];
    [monthlyRentEdit setFont:[UIFont fontWithName:@"Roboto-regular" size: 11]];
    [monthlyRentEdit setTextColor:[UIColor whiteColor]];
    [monthlyRentEdit setTextAlignment:NSTextAlignmentCenter];
    monthlyRentEdit.text = @"EDIT";
    [rentBox addSubview:monthlyRentEdit];

    payRentBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [payRentBtn setFrame:CGRectMake(0, 159, 0, 0)];
    if (isBankAttached)
    {
        [payRentBtn setTitle:@"Pay Rent Now" forState:UIControlStateNormal];
        [payRentBtn addTarget:self action:@selector(attach_bank) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [payRentBtn setTitle:@"Link a Bank Now" forState:UIControlStateNormal];
        [payRentBtn addTarget:self action:@selector(attach_bank) forControlEvents:UIControlEventTouchUpInside];
    }
    [payRentBtn setStyleClass:@"button_green_shorter"];
    [payRentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payRentBtn setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    payRentBtn.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };
    
    UILabel * glyph = [UILabel new];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph setFrame:CGRectMake(35, 0, 30, 42)];
    glyph.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"]
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"My Apartment"];
    self.screenName = @"My Apartment Screen";
    [self getBankInfo];
}

-(void)attach_bank
{
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
    }
    
    UILabel *title = [UILabel new];
    [title setStyleClass:@"settings_table_label"];
    
    UILabel *glyph = [UILabel new];
    [glyph setStyleClass:@"table_glyph"];
    
    if (indexPath.row == 0) {
        title.text = @"Profile Info";
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"]];
    }
    else if (indexPath.row == 1) {
        title.text = @"Security Settings";
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    }
    else if (indexPath.row == 2) {
        title.text = @"Notification Settings";
        [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bell"]];
    }
    else if(indexPath.row == 3) {
        title.text = @"Social Settings";
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self profile];
    }
}

- (void)profile
{
    isProfileOpenFromSideBar = NO;
    sentFromHomeScrn = NO;
    ProfileInfo * info = [ProfileInfo new];
    [self performSelector:@selector(navigate_to:) withObject:info afterDelay:0.01];
}

-(void)getBankInfo
{
    serve * serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"knox_bank_info";
    [serveOBJ GetKnoxBankAccountDetails];
}

-(void) goToSelectApt
{
    SelectApt * selectApt = [SelectApt new];
    [self.navigationController pushViewController:selectApt animated:YES];
}

-(void) openAptWebsite
{
    UIApplication * mySafari = [UIApplication sharedApplication];
    NSURL * myURL = [[NSURL alloc]initWithString:aptWebsiteUrl];

    NSLog(@"myURL is: %@",myURL);
    [mySafari openURL:myURL];
}
- (void) navigate_to:(id)view
{
    [self.navigationController pushViewController:view animated:YES];
}

-(void)Error:(NSError *)Error{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
    
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    /*if ([tagName isEqualToString:@"knox_bank_info"])
    {
        NSError * error;
        NSMutableDictionary*dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        NSLog(@"dicResponse is: %@",dictResponse);
        
        if (![[dictResponse valueForKey:@"AccountName"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"BankImageURL"] isKindOfClass:[NSNull class]] &&
            ![[dictResponse valueForKey:@"BankName"] isKindOfClass:[NSNull class]])
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"IsBankAvailable"];
            isBankAttached = YES;
            
            [aptName setText:@"Bank"];
            [aptAddress setText:@"linked_account_last4"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"IsBankAvailable"];
    
            isBankAttached = NO;
        }
    }*/
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
    
    if (alertView.tag == 15)
    {
        if (buttonIndex == 1)
        {
            blankView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
            [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
            
            UIActivityIndicatorView * actv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2) - 10, 40, 40)];
            [actv startAnimating];
            [blankView addSubview:actv];
            
            [self.view addSubview:blankView];
            [self.view bringSubviewToFront:blankView];
            [[assist shared]setisloggedout:YES];
            [timer invalidate];
            timer = nil;
            
            serve *  serveOBJ = [serve new];
            serveOBJ.Delegate = self;
            serveOBJ.tagName = @"logout";
            [serveOBJ LogOutRequest:[[NSUserDefaults standardUserDefaults ]valueForKey:@"MemberId"]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
