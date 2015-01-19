//
//  SetAptDetails.m
//  Nooch
//
//  Created by Cliff Canan on 1/14/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "SetAptDetails.h"
#import "Home.h"
#import "ProfileInfo.h"
#import "SelectApt.h"
#import "HistoryFlat.h"
#import "ECSlidingViewController.h"
#import "knoxWeb.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface SetAptDetails (){
    UILabel * aptName;
    UILabel * aptAddress;
    UILabel * aptWebsite;
    UIButton * emailApt;
    UIButton * callApt;
    NSString * aptWebsiteUrl;
    UIImageView * bank_image;
}
@property(nonatomic,strong) UILabel * bankName;;
@property(nonatomic,strong) UILabel * unitNumber;
@property(nonatomic,strong) UITextField * unitNumAmountTxtFld;
@property(nonatomic,strong) UITextField * roommatesTxtFld;
@property(nonatomic,strong) UISwitch * autoPaySwitch;
@property(nonatomic,strong) UIView * secondSectionContainer;
@property(nonatomic,strong) UIButton * rentBox;
@property(nonatomic,strong) UILabel * monthlyRentAmount;
@property(nonatomic,strong) UILabel * monthlyRentEdit;
@property(nonatomic,strong) UILabel * glyph_add;
@property(nonatomic,strong) UILabel * dateToPayLbl;
@property(nonatomic,strong) UILabel * dateToPay_date;
@property(nonatomic,strong) UILabel * noRoommatesTxt;
@property(nonatomic,strong) UILabel * glyph_dateToPayDropdown;
@property(nonatomic,strong) UIView * secondSectionDivider2;
@property(nonatomic,strong) UITextField * rentAmountTxtFld;
@property(nonatomic) NSMutableString * amnt;

@end

@implementation SetAptDetails

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)goBack
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
    }
    else
    {
        isBankAttached = YES;
    }

    [self.navigationItem setHidesBackButton:YES];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBackOneStep)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

    [self.navigationItem setRightBarButtonItem:Nil];
    
    UIButton * helpGlyph = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [helpGlyph setStyleClass:@"navbar_rightside_icon"];
    [helpGlyph addTarget:self action:@selector(deletePropertyAlert) forControlEvents:UIControlEventTouchUpInside];
    [helpGlyph setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-trash"] forState:UIControlStateNormal];
    [helpGlyph setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.24) forState:UIControlStateNormal];
    helpGlyph.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    UIBarButtonItem * help = [[UIBarButtonItem alloc] initWithCustomView:helpGlyph];
    [self.navigationItem setRightBarButtonItem:help];

    [self.navigationItem setTitle:@"Set My Apartment"];
    [self.slidingViewController.panGesture setEnabled:NO];

    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.view setStyleClass:@"background_gray"];

    aptName = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 21)];
    [aptName setFont:[UIFont fontWithName:@"Roboto-medium" size:18]];
    [aptName setTextColor:kNoochGrayDark];
    aptName.text = @"Belmont Village";
    [self.view addSubview:aptName];
    
    aptAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, 199, 17)];
    [aptAddress setFont:[UIFont fontWithName:@"Roboto-regular" size:12]];
    [aptAddress setTextColor:kNoochGrayDark];
    aptAddress.text = @"7246 Dresden Ave, Philadelphia, PA 19876";
    [self.view addSubview:aptAddress];
    
    aptWebsite = [[UILabel alloc] initWithFrame:CGRectMake(10, 46, 200, 15)];
    [aptWebsite setFont:[UIFont fontWithName:@"Roboto-regular" size:12]];
    [aptWebsite setTextColor:kNoochBlue];
    [aptWebsite setUserInteractionEnabled:YES];
    aptWebsite.text = @"www.BelmontVillage.com";
    aptWebsiteUrl = @"https://www.nooch.com";
    [aptWebsite addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAptWebsite)]];
    [self.view addSubview:aptWebsite];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, 0.22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textShadow = @{NSShadowAttributeName: shadow };

    emailApt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [emailApt setFrame:CGRectMake(10, 67, 76, 27)];
    [emailApt setTitle:@"     Email" forState:UIControlStateNormal];
    [emailApt addTarget:self action:@selector(emailProperty) forControlEvents:UIControlEventTouchUpInside];
    [emailApt setStyleClass:@"button_blue_small"];
    [emailApt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [emailApt setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    emailApt.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.view addSubview: emailApt];

    UILabel * glyphEmail = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 21, 25)];
    [glyphEmail setFont:[UIFont fontWithName:@"FontAwesome" size: 14]];
    glyphEmail.AttributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"] attributes:textShadow];
    [glyphEmail setTextAlignment:NSTextAlignmentCenter];
    [glyphEmail setTextColor:[UIColor whiteColor]];
    [emailApt addSubview:glyphEmail];

    callApt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callApt setFrame:CGRectMake(97, 67, 76, 27)];
    [callApt setTitle:@"    Call" forState:UIControlStateNormal];
    [callApt addTarget:self action:@selector(callProperty) forControlEvents:UIControlEventTouchUpInside];
    [callApt setStyleClass:@"button_green_small"];
    [callApt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [callApt setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    callApt.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.view addSubview: callApt];

    UILabel * glyphPhone = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 20, 26)];
    [glyphPhone setFont:[UIFont fontWithName:@"FontAwesome" size: 18]];
    glyphPhone.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"] attributes:textShadow];
    [glyphPhone setTextAlignment:NSTextAlignmentCenter];
    [glyphPhone setTextColor:[UIColor whiteColor]];
    [callApt addSubview:glyphPhone];

    self.rentBox = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rentBox setFrame:CGRectMake(207, 8, 106, 86)];
    self.rentBox.layer.cornerRadius = 4;
    self.rentBox.backgroundColor = Rgb2UIColor(220, 220, 221, .4);
    self.rentBox.layer.borderWidth = 1;
    self.rentBox.layer.borderColor = kNoochPurple.CGColor;
    [self.rentBox setStyleClass:@"raised_view_AptScrn"];
    [self.rentBox addTarget:self action:@selector(stayPressed:) forControlEvents:UIControlEventTouchDown];
    [self.rentBox addTarget:self action:@selector(enterRentPopup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rentBox];

    UILabel * monthlyRentLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.rentBox.bounds.size.width, 18)];
    [monthlyRentLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 14]];
    [monthlyRentLbl setTextColor:[UIColor whiteColor]];
    [monthlyRentLbl setTextAlignment:NSTextAlignmentCenter];
    monthlyRentLbl.text = @"Monthly Rent:";
    [self.rentBox addSubview:monthlyRentLbl];
    
    self.monthlyRentAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, self.rentBox.bounds.size.width, 34)];
    [self.monthlyRentAmount setFont:[UIFont fontWithName:@"Roboto-medium" size: 28]];
    [self.monthlyRentAmount setTextColor:[UIColor whiteColor]];
    [self.monthlyRentAmount setTextAlignment:NSTextAlignmentCenter];
    self.monthlyRentAmount.text = @"$ 0";
    [self.rentBox addSubview:self.monthlyRentAmount];
    
    self.monthlyRentEdit = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, self.rentBox.bounds.size.width, 23)];
    [self.monthlyRentEdit setFont:[UIFont fontWithName:@"Roboto-regular" size: 12]];
    [self.monthlyRentEdit setTextColor:kNoochGrayLight];
    [self.monthlyRentEdit setTextAlignment:NSTextAlignmentCenter];
    self.monthlyRentEdit.text = @"      Add Your Rent";
    [self.rentBox addSubview:self.monthlyRentEdit];

    self.glyph_add = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 22, 22)];
    [self.glyph_add setTextAlignment:NSTextAlignmentCenter];
    [self.glyph_add setFont:[UIFont fontWithName:@"FontAwesome" size: 14]];
    [self.glyph_add setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"]];
    [self.glyph_add setTextColor:kNoochGrayDark];
    [self.monthlyRentEdit addSubview:self.glyph_add];

    rowHeight = 53;

    // My Apartment Section
    UILabel * titleTopSection = [[UILabel alloc] initWithFrame:CGRectMake(15, 106, 250, 24)];
    [titleTopSection setStyleClass:@"refer_header"];
    [titleTopSection setText:@"My Apartment"];
    [self.view addSubview:titleTopSection];

    UIView * topSectionContainer = [[UIView alloc] initWithFrame:CGRectMake(8, 135, 304, (rowHeight * 2) + 1)];
    topSectionContainer.backgroundColor = [UIColor whiteColor];
    [topSectionContainer setStyleClass:@"raised_view_AptScrn"];
    [self.view addSubview:topSectionContainer];

    UILabel * unitNumLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 100, rowHeight)];
    [unitNumLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 15]];
    [unitNumLbl setTextColor:kNoochBlue];
    unitNumLbl.text = @"Unit Number:";
    [topSectionContainer addSubview:unitNumLbl];

    self.amnt = [@"" mutableCopy];

    self.unitNumber = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 212, rowHeight)];
    [self.unitNumber setTextAlignment:NSTextAlignmentRight];
    [self.unitNumber setStyleClass:@"tableViewCell_Apt_rightSide"];
    [self.unitNumber setText:@"206A"];
    [self.unitNumber setUserInteractionEnabled:YES];
    [self.unitNumber addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterUnitNumPopup)]];
    [topSectionContainer addSubview:self.unitNumber];

    UIView * topSectionDivider = [[UIView alloc] initWithFrame:CGRectMake(20, rowHeight, 284, 1)];
    topSectionDivider.backgroundColor = Rgb2UIColor(188, 190, 192, 0.7);
    [topSectionContainer addSubview:topSectionDivider];

    UILabel * roommatesLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, rowHeight + 1, 100, rowHeight)];
    [roommatesLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 15]];
    [roommatesLbl setTextColor:kNoochBlue];
    roommatesLbl.text = @"Roommates:";
    [topSectionContainer addSubview: roommatesLbl];

    self.noRoommatesTxt = [[UILabel alloc] initWithFrame:CGRectMake(80, rowHeight + 1, 195, rowHeight)];
    [self.noRoommatesTxt setFont:[UIFont fontWithName:@"Roboto-light" size: 15]];
    [self.noRoommatesTxt setText: @"No Roommates"];
    [self.noRoommatesTxt setTextColor:kNoochGrayDark];
    [self.noRoommatesTxt setTextAlignment:NSTextAlignmentRight];
    [self.noRoommatesTxt setUserInteractionEnabled:YES];
    [self.noRoommatesTxt addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterRoomatesPopup)]];
    [topSectionContainer addSubview: self.noRoommatesTxt];

    UILabel * glyph_addRoommate = [[UILabel alloc] initWithFrame:CGRectMake(278, rowHeight + 1, 20, rowHeight)];
    [glyph_addRoommate setFont:[UIFont fontWithName:@"FontAwesome" size: 18]];
    [glyph_addRoommate setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"]];
    [glyph_addRoommate setTextAlignment:NSTextAlignmentCenter];
    [glyph_addRoommate setTextColor:kNoochPurple];
    [topSectionContainer addSubview:glyph_addRoommate];


    // Funding Source Section
    UILabel * titleFundingSrcSection = [[UILabel alloc] initWithFrame:CGRectMake(15, 254, 91 + (rowHeight * 2) + 30, 24)];
    [titleFundingSrcSection setStyleClass:@"refer_header"];
    [titleFundingSrcSection setText:@"Funding Source"];
    [self.view addSubview: titleFundingSrcSection];

    self.secondSectionContainer = [[UIView alloc] initWithFrame:CGRectMake(8, 283, 304, (rowHeight * 2) + 1)];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoPayEnabled"]isEqualToString:@"1"])
    {
        [self.secondSectionContainer setFrame:CGRectMake(8, 283, 304, (rowHeight * 3) + 1)];
    }
    else
    {
        [self.secondSectionContainer setFrame:CGRectMake(8, 283, 304, (rowHeight * 2) + 1)];
    }
    self.secondSectionContainer.backgroundColor = [UIColor whiteColor];
    [self.secondSectionContainer setStyleClass:@"raised_view_AptScrn"];
    [self.view addSubview: self.secondSectionContainer];

    UILabel * useMyLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 90, rowHeight)];
    [useMyLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 15]];
    [useMyLbl setTextColor:kNoochBlue];
    useMyLbl.text = @"Use My:";
    [self.secondSectionContainer addSubview: useMyLbl];
    
    self.bankName = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 196, rowHeight)];
    [self.bankName setFont:[UIFont fontWithName:@"Roboto-medium" size: 15]];
    [self.bankName setText: @"PNC - 1234"];
    [self.bankName setTextColor:kNoochGreen];
    [self.bankName setTextAlignment:NSTextAlignmentRight];
    [self.secondSectionContainer addSubview: self.bankName];

    UILabel * glyph_bankDropdown = [[UILabel alloc] initWithFrame:CGRectMake(282, 0, 18, rowHeight)];
    [glyph_bankDropdown setFont:[UIFont fontWithName:@"FontAwesome" size: 17]];
    [glyph_bankDropdown setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-caret-down"]];
    [glyph_bankDropdown setTextAlignment:NSTextAlignmentCenter];
    [glyph_bankDropdown setTextColor:kNoochGreen];
    [self.secondSectionContainer addSubview:glyph_bankDropdown];

    UIView * secondSectionDivider = [[UIView alloc] initWithFrame:CGRectMake(20, rowHeight, 284, 1)];
    secondSectionDivider.backgroundColor = Rgb2UIColor(188, 190, 192, 0.7);
    [self.secondSectionContainer addSubview:secondSectionDivider];

    UILabel * autoPayLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, rowHeight + 1, 100, rowHeight)];
    [autoPayLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 15]];
    [autoPayLbl setTextColor:kNoochBlue];
    autoPayLbl.text = @"Autopay";
    [autoPayLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DateToAutoPaySelection:)]];
    [self.secondSectionContainer addSubview: autoPayLbl];

    self.autoPaySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(248, rowHeight + (rowHeight / 3) - 4, 34, 21)];
    [self.autoPaySwitch setStyleClass:@"login_switch"];
    [self.autoPaySwitch setOnTintColor:kNoochBlue];

    self.autoPaySwitch.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.autoPaySwitch addTarget:self
                      action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];

    self.secondSectionDivider2 = [[UIView alloc] initWithFrame:CGRectMake(20, (rowHeight * 2) + 1, 284, 1)];
    self.secondSectionDivider2.backgroundColor = Rgb2UIColor(188, 190, 192, 0.7);
    [self.secondSectionContainer addSubview:self.secondSectionDivider2];
    
    self.dateToPayLbl = [[UILabel alloc] initWithFrame:CGRectMake(9, (rowHeight * 2) + 1, 100, rowHeight)];
    [self.dateToPayLbl setFont:[UIFont fontWithName:@"Roboto-regular" size: 15]];
    [self.dateToPayLbl setTextColor:kNoochBlue];
    self.dateToPayLbl.text = @"Date to pay:";
    [self.dateToPayLbl setAlpha:0];
    [self.secondSectionContainer addSubview: self.dateToPayLbl];

    self.dateToPay_date = [[UILabel alloc] initWithFrame:CGRectMake(80, (rowHeight * 2) + 1, 196, rowHeight)];
    [self.dateToPay_date setFont:[UIFont fontWithName:@"Roboto-regular" size: 15]];
    [self.dateToPay_date setText: @"1st day of each month"];
    [self.dateToPay_date setTextColor:kNoochGrayDark];
    [self.dateToPay_date setTextAlignment:NSTextAlignmentRight];
    [self.dateToPay_date setUserInteractionEnabled:YES];
    [self.dateToPay_date addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DateToAutoPaySelection:)]];
    [self.secondSectionContainer addSubview: self.dateToPay_date];

    self.glyph_dateToPayDropdown = [[UILabel alloc] initWithFrame:CGRectMake(282, (rowHeight * 2) + 1, 18, rowHeight)];
    [self.glyph_dateToPayDropdown setFont:[UIFont fontWithName:@"FontAwesome" size: 17]];
    [self.glyph_dateToPayDropdown setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-caret-down"]];
    [self.glyph_dateToPayDropdown setTextAlignment:NSTextAlignmentCenter];
    [self.glyph_dateToPayDropdown setTextColor:kNoochBlue];
    [self.secondSectionContainer addSubview:self.glyph_dateToPayDropdown];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoPayEnabled"]isEqualToString:@"1"])
    {
        [self.glyph_dateToPayDropdown setAlpha:1];
        [self.secondSectionDivider2 setAlpha:1];
        [self.dateToPay_date setAlpha:1];
        [self.autoPaySwitch setOn: YES];
    }
    else
    {
        [self.glyph_dateToPayDropdown setAlpha:0];
        [self.secondSectionDivider2 setAlpha:0];
        [self.dateToPay_date setAlpha:0];
        [self.autoPaySwitch setOn: NO];
    }
    [self.secondSectionContainer addSubview: self.autoPaySwitch];

    /*if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [scroll setDelegate:self];
        [scroll setContentSize:CGSizeMake(320, 545)];
        for (UIView *subview in self.view.subviews)
        {
            [subview removeFromSuperview];
            [scroll addSubview:subview];
        }
        [self.view addSubview:scroll];
    }*/

    serve *  serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"getAptDetails";
    //[serveOBJ getAptDetails:[[NSUserDefaults standardUserDefaults ]valueForKey:@"MemberId"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"Set My Apartment"];
    self.screenName = @"Set My Apartment Screen";
}

-(void)DateToAutoPaySelection:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    isAutoPayPopoverShowing = YES;

    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = @"Auto Pay";
    
    popoverAutoPayDate = [[FPPopoverController alloc] initWithViewController:popOver];
    popoverAutoPayDate.border = NO;
    popoverAutoPayDate.tint = FPPopoverWhiteTint;
    popoverAutoPayDate.arrowDirection = FPPopoverArrowDirectionUp;
    popoverAutoPayDate.contentSize = CGSizeMake(200, 215);
    [popoverAutoPayDate presentPopoverFromPoint:CGPointMake(215, 478)];
}

-(void)dismissFP:(NSNotification *)notification
{
    [popoverAutoPayDate dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismissPopOver" object:nil];

    if (![autoPaySetting isEqualToString:@"CANCEL"])
    {
        [self.dateToPay_date setText: autoPaySetting];
    }
    isAutoPayPopoverShowing = NO;
/*    if (![listType isEqualToString:@"CANCEL"] && isFilterSelected)
    {
        [self.search setShowsCancelButton:NO];
        [self.search setText:@""];
        [self.search resignFirstResponder];
        
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];

        isFilterSelected = NO;
        
        [self loadHist:listType index:index len:20 subType:subTypestr];
    }
    else
        isFilter=NO;*/
}

-(void)enterRentPopup
{
    [self.rentBox setFrame:CGRectMake(207, 8, 106, 86)];

    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];
    
    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(9, -500, 302, 235);
    }
    else
    {
        mainView.frame = CGRectMake(9, -540, 302, 235);
    }
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;
    
    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }];
    
    [UIView animateWithDuration:0.38
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500)
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 235);
                         }
                         else
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 235);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.23
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500)
                                              {
                                                  mainView.frame = CGRectMake(9, 45, 302, 235);
                                              }
                                              else
                                              {
                                                  mainView.frame = CGRectMake(9, 55, 302, 235);
                                              }
                                          }];
                     }];
    
    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;
    
    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview: space_container];
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Enter Your Monthly Rent"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];
    
    UILabel * glyph_add = [UILabel new];
    [glyph_add setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyph_add setFrame:CGRectMake(14, 10, 22, 26)];
    [glyph_add setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-money"]];
    [glyph_add setTextColor:kNoochBlue];
    [head_container addSubview:glyph_add];
    
    UILabel * bodyHeader = [[UILabel alloc]initWithFrame:CGRectMake(11, head_container.bounds.size.height + 5, mainView.bounds.size.width - 22, 50)];
    [bodyHeader setBackgroundColor:[UIColor clearColor]];
    [bodyHeader setText:@"Enter the amount that you pay each month. You can adjust this amount any time."];
    [bodyHeader setFont:[UIFont fontWithName:@"Roboto-regular" size:14]];
    [bodyHeader setNumberOfLines:0];
    bodyHeader.textColor = [Helpers hexColor:@"313233"];
    bodyHeader.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:bodyHeader];

    self.rentAmountTxtFld = [[UITextField alloc] initWithFrame:CGRectMake(86, 102, 130, 40)];
    [self.rentAmountTxtFld setBackgroundColor:[UIColor clearColor]];
    [self.rentAmountTxtFld setPlaceholder:@"Ex: 550"];
    self.rentAmountTxtFld.inputAccessoryView = [[UIView alloc] init];
    [self.rentAmountTxtFld setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.rentAmountTxtFld setAutocorrectionType:UITextAutocorrectionTypeDefault];
    [self.rentAmountTxtFld setKeyboardType:UIKeyboardTypeDecimalPad];
    [self.rentAmountTxtFld setReturnKeyType:UIReturnKeyDone];
    [self.rentAmountTxtFld setTextAlignment:NSTextAlignmentCenter];
    [self.rentAmountTxtFld becomeFirstResponder];
    [self.rentAmountTxtFld setDelegate:self];
    [self.rentAmountTxtFld setTag:1];
    [self.rentAmountTxtFld setStyleId:@"enterRent_textField"];
    [mainView addSubview:self.rentAmountTxtFld];

    UILabel * glyph_Usd = [UILabel new];
    [glyph_Usd setFont:[UIFont fontWithName:@"FontAwesome" size:22]];
    [glyph_Usd setFrame:CGRectMake(6, 0, 22, 39)];
    [glyph_Usd setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-usd"]];
    [glyph_Usd setTextColor:kNoochBlue];
    [self.rentAmountTxtFld addSubview:glyph_Usd];

    UILabel * perMonthTxt = [[UILabel alloc]initWithFrame:CGRectMake(220, 102, 72, 40)];
    [perMonthTxt setBackgroundColor:[UIColor clearColor]];
    [perMonthTxt setText:@"per month"];
    [perMonthTxt setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];
    [perMonthTxt setNumberOfLines: 0];
    perMonthTxt.textColor = [Helpers hexColor:@"313233"];
    perMonthTxt.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:perMonthTxt];
    
    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnLink.frame = CGRectMake(20, 165, 260, 46);
    [btnLink setTitle:@"Send" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(close_PayRentLightBox) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(8, 40, 302, 440);
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_add.frame = CGRectMake(18, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height-51, 280, 44);
    }
    
    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(5, 5, 38, 39);
    
    UIView * btnClose_shell = [[UIView alloc] initWithFrame:CGRectMake(mainView.frame.size.width - 38, head_container.frame.origin.y - 21, 48, 46)];
    [btnClose_shell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close_PayRentLightBox)]];
    [btnClose_shell addSubview:btnClose];
    
    [mainView addSubview:btnClose_shell];
    [mainView addSubview:btnLink];
    [overlay addSubview:mainView];
}

-(void)close_PayRentLightBox
{
    if (self.rentAmountTxtFld.text.length > 0)
    {
        self.rentBox.backgroundColor = kNoochPurple;
        self.monthlyRentAmount.text = [NSString stringWithFormat:@"$%@", self.rentAmountTxtFld.text];
        [self.glyph_add setHidden:YES];
        [self.monthlyRentEdit setText: @"EDIT"];
        [self.monthlyRentEdit setTextColor:Rgb2UIColor(255, 254, 255, .95)];
    }

    [UIView animateWithDuration:0.15
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500) {
                             mainView.frame = CGRectMake(9, 70, 302, 240);
                         }
                         else {
                             mainView.frame = CGRectMake(9, 70, 302, 240);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.38
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                                  mainView.frame = CGRectMake(9, -500, 302, 240);
                                              }
                                              else {
                                                  mainView.frame = CGRectMake(9, -540, 302, 240);
                                              }
                                              overlay.alpha = 0.1;
                                          } completion:^(BOOL finished) {
                                              [overlay removeFromSuperview];
                                          }
                          ];
                     }
     ];
}

-(void)enterUnitNumPopup
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];

    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(9, -500, 302, 230);
    }
    else
    {
        mainView.frame = CGRectMake(9, -540, 302, 230);
    }
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;

    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }];
    
    [UIView animateWithDuration:0.38
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500)
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 230);
                         }
                         else
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 230);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.23
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500)
                                              {
                                                  mainView.frame = CGRectMake(9, 45, 302, 230);
                                              }
                                              else
                                              {
                                                  mainView.frame = CGRectMake(9, 55, 302, 230);
                                              }
                                          }];
                     }];

    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;

    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview: space_container];

    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Enter Your Monthly Rent"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];

    UILabel * glyph_add = [UILabel new];
    [glyph_add setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyph_add setFrame:CGRectMake(14, 10, 22, 26)];
    [glyph_add setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-money"]];
    [glyph_add setTextColor:kNoochBlue];
    [head_container addSubview:glyph_add];

    UILabel * bodyHeader = [[UILabel alloc]initWithFrame:CGRectMake(11, head_container.bounds.size.height + 5, mainView.bounds.size.width - 22, 40)];
    [bodyHeader setBackgroundColor:[UIColor clearColor]];
    [bodyHeader setText:@"Enter your room or unit number:"];
    [bodyHeader setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];
    [bodyHeader setNumberOfLines:0];
    bodyHeader.textColor = [Helpers hexColor:@"313233"];
    bodyHeader.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:bodyHeader];

    self.unitNumAmountTxtFld = [[UITextField alloc] initWithFrame:CGRectMake(86, 100, 130, 40)];
    [self.unitNumAmountTxtFld setBackgroundColor:[UIColor clearColor]];
    [self.unitNumAmountTxtFld setPlaceholder:@"    Ex: 107A"];
    self.unitNumAmountTxtFld.inputAccessoryView = [[UIView alloc] init];
    [self.unitNumAmountTxtFld setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.unitNumAmountTxtFld setReturnKeyType:UIReturnKeyDone];
    [self.unitNumAmountTxtFld setTextAlignment:NSTextAlignmentCenter];
    [self.unitNumAmountTxtFld becomeFirstResponder];
    [self.unitNumAmountTxtFld setDelegate:self];
    [self.unitNumAmountTxtFld setTag:2];
    [self.unitNumAmountTxtFld setStyleId:@"enterRent_textField"];
    [mainView addSubview:self.unitNumAmountTxtFld];

    UILabel * glyph_home = [UILabel new];
    [glyph_home setFont:[UIFont fontWithName:@"FontAwesome" size:22]];
    [glyph_home setFrame:CGRectMake(6, 0, 22, 39)];
    [glyph_home setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-home"]];
    [glyph_home setTextColor:kNoochBlue];
    [self.unitNumAmountTxtFld addSubview:glyph_home];

    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnLink.frame = CGRectMake(20, 165, 260, 46);
    [btnLink setTitle:@"Done" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(close_UnitNumLightBox) forControlEvents:UIControlEventTouchUpInside];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(8, 40, 302, 440);
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_add.frame = CGRectMake(18, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height-51, 280, 44);
    }

    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(5, 5, 38, 39);

    UIView * btnClose_shell = [[UIView alloc] initWithFrame:CGRectMake(mainView.frame.size.width - 38, head_container.frame.origin.y - 21, 48, 46)];
    [btnClose_shell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close_UnitNumLightBox)]];
    [btnClose_shell addSubview:btnClose];

    [mainView addSubview:btnClose_shell];
    [mainView addSubview:btnLink];
    [overlay addSubview:mainView];
}

-(void)close_UnitNumLightBox
{
    if (self.unitNumAmountTxtFld.text.length > 0)
    {
        [self.unitNumber setText: self.unitNumAmountTxtFld.text];
    }
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500) {
                             mainView.frame = CGRectMake(9, 70, 302, 240);
                         }
                         else {
                             mainView.frame = CGRectMake(9, 70, 302, 240);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.38
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                                  mainView.frame = CGRectMake(9, -500, 302, 240);
                                              }
                                              else {
                                                  mainView.frame = CGRectMake(9, -540, 302, 240);
                                              }
                                              overlay.alpha = 0.1;
                                          } completion:^(BOOL finished) {
                                              [overlay removeFromSuperview];
                                          }
                          ];
                     }
     ];
}

-(void)enterRoomatesPopup
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];
    
    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(9, -500, 302, 230);
    }
    else
    {
        mainView.frame = CGRectMake(9, -540, 302, 230);
    }
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;
    
    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }];
    
    [UIView animateWithDuration:0.38
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500)
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 230);
                         }
                         else
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 230);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.23
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500)
                                              {
                                                  mainView.frame = CGRectMake(9, 45, 302, 230);
                                              }
                                              else
                                              {
                                                  mainView.frame = CGRectMake(9, 55, 302, 230);
                                              }
                                          }];
                     }];
    
    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;
    
    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview: space_container];
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Add Roommates"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];
    
    UILabel * glyph_add = [UILabel new];
    [glyph_add setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyph_add setFrame:CGRectMake(14, 10, 22, 26)];
    [glyph_add setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"]];
    [glyph_add setTextColor:kNoochBlue];
    [head_container addSubview:glyph_add];
    
    UILabel * bodyHeader = [[UILabel alloc]initWithFrame:CGRectMake(11, head_container.bounds.size.height + 5, mainView.bounds.size.width - 22, 40)];
    [bodyHeader setBackgroundColor:[UIColor clearColor]];
    [bodyHeader setText:@"Enter the name or email of your roommate:"];
    [bodyHeader setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];
    [bodyHeader setNumberOfLines:0];
    bodyHeader.textColor = [Helpers hexColor:@"313233"];
    bodyHeader.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:bodyHeader];
    
    self.roommatesTxtFld = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 262, 40)];
    [self.roommatesTxtFld setBackgroundColor:[UIColor clearColor]];
    self.roommatesTxtFld.layer.cornerRadius = 4;
    self.roommatesTxtFld.textColor = [Helpers hexColor:@"313233"];
    [self.roommatesTxtFld setFont:[UIFont fontWithName:@"Roboto-regular" size:17]];
    [self.roommatesTxtFld setPlaceholder:@" Ex: Abe Lincoln"];
    [self.roommatesTxtFld setBorderStyle:UITextBorderStyleRoundedRect];
    self.roommatesTxtFld.layer.borderColor = Rgb2UIColor(188,190,192,0.8).CGColor;
    [self.roommatesTxtFld setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.roommatesTxtFld setReturnKeyType:UIReturnKeyDone];
    [self.roommatesTxtFld setTextAlignment:NSTextAlignmentCenter];
    self.roommatesTxtFld.inputAccessoryView = [[UIView alloc] init];
    [self.roommatesTxtFld becomeFirstResponder];
    [self.roommatesTxtFld setDelegate:self];
    [self.roommatesTxtFld setTag:2];
    [mainView addSubview:self.roommatesTxtFld];
    
    UILabel * glyph_user = [UILabel new];
    [glyph_user setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph_user setFrame:CGRectMake(7, 0, 22, 39)];
    [glyph_user setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"]];
    [glyph_user setTextColor:kNoochBlue];
    [self.roommatesTxtFld addSubview:glyph_user];
    
    UIButton * btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setStyleClass:@"button_green_welcome"];
    [btnDone setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnDone.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnDone.frame = CGRectMake(20, 165, 260, 46);
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(close_RoommatesLightBox) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_add.frame = CGRectMake(18, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        btnDone.frame = CGRectMake(10,mainView.frame.size.height-54, 280, 44);
    }

    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(5, 5, 38, 39);

    UIView * btnClose_shell = [[UIView alloc] initWithFrame:CGRectMake(mainView.frame.size.width - 38, head_container.frame.origin.y - 21, 48, 46)];
    [btnClose_shell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close_RoommatesLightBox)]];
    [btnClose_shell addSubview:btnClose];
    
    [mainView addSubview:btnClose_shell];
    [mainView addSubview:btnDone];
    [overlay addSubview:mainView];
}

-(void)close_RoommatesLightBox
{
    if (self.roommatesTxtFld.text.length > 0)
    {
        [self.noRoommatesTxt setText: self.roommatesTxtFld.text];
    }
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500) {
                             mainView.frame = CGRectMake(9, 70, 302, 240);
                         }
                         else {
                             mainView.frame = CGRectMake(9, 70, 302, 240);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.38
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                                  mainView.frame = CGRectMake(9, -500, 302, 240);
                                              }
                                              else {
                                                  mainView.frame = CGRectMake(9, -540, 302, 240);
                                              }
                                              overlay.alpha = 0.1;
                                          } completion:^(BOOL finished) {
                                              [overlay removeFromSuperview];
                                          }
                          ];
                     }
     ];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length + range.location > textField.text.length)
    {
        return NO;
    }

    if (textField.tag == 1)
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGeneratesDecimalNumbers:YES];
        [formatter setUsesGroupingSeparator:YES];

        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        
        if ([string length] == 0) //backspace
        {
            if ([self.amnt length] > 0) {
                self.amnt = [[self.amnt substringToIndex:[self.amnt length] - 1] mutableCopy];
            }
        }
        else
        {
            NSString *temp = [self.amnt stringByAppendingString:string];
            self.amnt = [temp mutableCopy];
        }
        
        float maths = [self.amnt floatValue];
        maths /= 100;
        
        if (maths > 1000) {
            self.amnt = [[self.amnt substringToIndex:[self.amnt length]-1] mutableCopy];
            return NO;
        }
        if (maths != 0) {
            [textField setText:[formatter stringFromNumber:[NSNumber numberWithFloat:maths]]];
        }
        else {
            [textField setText:@""];
        }
        return NO;
    }
    else if (textField.tag == 2)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength <= 6)
        {
            return newLength <= 6;
        }
    }
    return NO;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.rentAmountTxtFld)
    {
        [self close_PayRentLightBox];
    }
    else if (textField == self.unitNumAmountTxtFld)
    {
        [self close_UnitNumLightBox];
    }
    else if (textField == self.roommatesTxtFld)
    {
        [self close_RoommatesLightBox];
    }

    [textField resignFirstResponder];
    return YES;
}

-(void)stayPressed:(UIButton *) sender
{
    [self.rentBox setFrame:CGRectMake(207, 11, 106, 86)];
}

-(void)stateChanged:(UISwitch *)switchState
{
    if ([switchState isOn])
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.26];

        [self.secondSectionContainer setFrame:CGRectMake(8, 283, 304, (rowHeight * 3) + 1)];

        [UIView commitAnimations];

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];

        [self.dateToPayLbl setAlpha:1];
        [self.dateToPay_date setAlpha:1];
        [self.dateToPay_date addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DateToAutoPaySelection:)]];
        [self.glyph_dateToPayDropdown setAlpha:1];
        self.secondSectionDivider2.backgroundColor = Rgb2UIColor(188, 190, 192, 0.7);

        [UIView commitAnimations];

        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAutoPayEnabled"];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.26];

        [self.secondSectionContainer setFrame:CGRectMake(8, 283, 304, (rowHeight * 2) + 1)];

        [UIView commitAnimations];

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.08];

        [self.dateToPayLbl setAlpha:0];
        [self.dateToPay_date setAlpha:0];
        [self.glyph_dateToPayDropdown setAlpha:0];
        self.secondSectionDivider2.backgroundColor = Rgb2UIColor(188, 190, 192, 0);

        [UIView commitAnimations];

        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isAutoPayEnabled"];
    }
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

-(void)emailProperty
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                     message:@"You don't have a mail account configured for this device."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
        [av show];
        return;
    }
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Question About Your Property"];

    mailComposer.navigationBar.tintColor=[UIColor whiteColor];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"apartment@nooch.com",nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@"propertysupport@nooch.com"]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

-(void)callProperty
{
    UIApplication *myApp = [UIApplication sharedApplication];
    NSString *phoneNumber = @"6108041572";
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", cleanedString]];

    [myApp openURL:telURL];
}

-(void)deletePropertyAlert
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Delete This Property"
                                                 message:@"Are you sure you want to remove this property from your account?"
                                                delegate:self
                                       cancelButtonTitle:@"Yes - Remove"
                                       otherButtonTitles:@"Cancel", nil];
    [av setTag:41];
    [av show];
}

-(void)deletePropertyServerCall
{
    serve * serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"deleteProperty";
    //[serveOBJ deleteProperty];
}

-(void)goToSelectApt
{
    SelectApt * selectApt = [SelectApt new];
    [self.navigationController pushViewController:selectApt animated:YES];
}

-(void)openAptWebsite
{
    UIApplication * mySafari = [UIApplication sharedApplication];
    NSURL * myURL = [[NSURL alloc]initWithString: aptWebsiteUrl];
    [mySafari openURL:myURL];
}

-(void)goBackOneStep
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) navigate_to:(id)view
{
    [self.navigationController pushViewController:view animated:YES];
}

-(void)Error:(NSError *)Error
{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
    
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
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
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"HasAptSelected"];
            
            isBankAttached = YES;
            aptName.text = [dictResponse valueForKey:@"aptName"];
            aptAddress.text = [dictResponse valueForKey:@"aptAddress"];
            aptWebsite.text = [dictResponse valueForKey:@"aptWebsite"];
            aptWebsiteUrl = [dictResponse valueForKey:@"aptWebsite"];
            
            self.monthlyRentAmount.text = [dictResponse valueForKey:@"monthlyRentAmount"];
            [self.autoPaySwitch setOn: YES];
            //lastPymntDate.text = @"";
        }
    }
    
    else if ([tagName isEqualToString:@"getLastPayments"])
    {
        //NSError * error;
    }

    else if ([tagName isEqualToString:@"deleteProperty"])
    {
        NSError* error;
        NSMutableDictionary*dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        
        if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Property deleted successfully."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Property Removed"
                                                         message:@"This property is no longer linked to your Nooch account. To make rent payments, you must link a new property."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
        else if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"No property found for this user."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Account Not Found"
                                                         message:[dictResponse valueForKey:@"Result"]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Nooch"
                                                         message:[dictResponse valueForKey:@"Result"]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }

        [self goToSelectApt];
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
    else if (alertView.tag == 41) // Delete Property
    {
        if (buttonIndex == 0)
        {
            [self deletePropertyServerCall];
            [self.navigationController popViewControllerAnimated:YES];
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
