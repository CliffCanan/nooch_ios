//  HistoryFlat.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "HistoryFlat.h"
#import "Home.h"
#import "Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import "TransactionDetails.h"
#import "UIImageView+WebCache.h"
#import "ECSlidingViewController.h"
#import "Register.h"
#import "TransferPIN.h"
#import "ProfileInfo.h"
#import "addBank.h"
#import "SettingsOptions.h"

@interface HistoryFlat ()<GMSMapViewDelegate>
{
    GMSMapView * mapView_;
    GMSCameraPosition *camera;
    GMSMarker *markerOBJ;
}
@property(nonatomic,strong) UISearchBar *search;
@property(nonatomic,strong) UITableView *list;
@property(nonatomic,strong) UIButton *glyph_map;
@property(nonatomic,strong) UILabel * glyph_checkmark;
@property(nonatomic,strong) UILabel * glyph_pending;
@property(nonatomic) BOOL completed_selected;
@property(nonatomic,strong) NSDictionary *responseDict;
@property(nonatomic,strong) UILabel * glyph_emptyTable;
@property(nonatomic, strong) UILabel * glyph_emptyLoc;
@property(nonatomic, strong) UILabel * emptyLocBody;
@property(nonatomic, strong) UILabel * emptyLocHdr;
@property(nonatomic, strong) UILabel * emptyText;
@property(nonatomic, strong) UIImageView * emptyPic;
@property(nonatomic, strong) NSMutableArray * markers;
@property(nonatomic,strong) UIView * tableShadow;

@end

@implementation HistoryFlat

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

    if (!isFromApts)
    {
        UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [hamburger setStyleId:@"navbar_hamburger"];
        [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];

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

        UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToApts)];

        UILabel * back_button = [UILabel new];
        [back_button setStyleId:@"navbar_back"];
        [back_button setUserInteractionEnabled:YES];
        [back_button addGestureRecognizer: backTap];
        back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

        UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

        [self.navigationItem setLeftBarButtonItem:menu];
    }

    [self.navigationItem setTitle:NSLocalizedString(@"History_ScrnTitle", @"History screen title")];
    [nav_ctrl performSelector:@selector(disable)];

    if (!histArray) {
        histArray=[[NSMutableArray alloc]init];
    }
    if (!histShowArrayCompleted) {
        histShowArrayCompleted=[[NSMutableArray alloc]init];
    }
    if (!histShowArrayPending) {
        histShowArrayPending=[[NSMutableArray alloc]init];
    }
    if (!histTempCompleted) {
        histTempCompleted=[[NSMutableArray alloc]init];
    }
    if (!histTempPending) {
        histTempPending=[[NSMutableArray alloc]init];
    }

    NSArray * seg_items = @[NSLocalizedString(@"History_SegControl_Completed", @"History screen segmented control toggle - Completed"),
                            NSLocalizedString(@"History_SegControl_Pending", @"History screen segmented control toggle - Pending")];
    completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [completed_pending setStyleId:@"history_segcontrol"];
    [completed_pending addTarget:self action:@selector(completed_or_pending:) forControlEvents:UIControlEventValueChanged];

    //[self.view bringSubviewToFront:self];

    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
    [self.list setStyleId:@"history"];
    [self.list setDataSource:self];
    [self.list setDelegate:self];
    [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list];

    self.tableShadow = [[UIView alloc] initWithFrame:self.list.frame];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.tableShadow.bounds];
    self.tableShadow.layer.masksToBounds = NO;
    self.tableShadow.layer.shadowColor = Rgb2UIColor(32, 33, 34, 0.4).CGColor;
    self.tableShadow.layer.shadowOpacity = 1;
    self.tableShadow.layer.shadowOffset = CGSizeMake(2,3);
    self.tableShadow.layer.shadowRadius = 2;
    self.tableShadow.layer.shadowPath = path.CGPath;
    self.tableShadow.layer.shouldRasterize = YES;
    [self.view addSubview:self.tableShadow];
    [self.view bringSubviewToFront:self.list];


    UIView * whiteFillerSpace = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 320, 72)];
    [whiteFillerSpace setBackgroundColor:Rgb2UIColor(250, 250, 250, .25)];
    //[self.view addSubview:whiteFillerSpace];
    //[self.view bringSubviewToFront:whiteFillerSpace];

    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    [self.search setStyleId:@"history_search"];
    [self.search setDelegate:self];
    self.search.searchBarStyle = UISearchBarStyleMinimal;
    [self.search setPlaceholder:NSLocalizedString(@"History_SearchPlaceholder", @"History screen search bar placeholder text")];
    [self.search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.search setTintColor:kNoochBlue];

    [self.view addSubview:completed_pending];
    [self.view addSubview:self.search];
    [self.view bringSubviewToFront:completed_pending];
    [self.view bringSubviewToFront:self.search];

    UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filter setStyleClass:@"label_filter"];
    [filter setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    filter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [filter setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-filter"] forState:UIControlStateNormal];
    [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];

    listType = @"ALL";
    index = 1;
    isStart = YES;
    isLocalSearch = NO;

    self.glyph_checkmark = [[UILabel alloc] initWithFrame:CGRectMake(22, 13, 22, 18)];
    [self.glyph_checkmark setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [self.glyph_checkmark setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];

    self.glyph_pending = [[UILabel alloc] initWithFrame:CGRectMake(174, 13, 20, 18)];
    [self.glyph_pending setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [self.glyph_pending setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];

    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];

    // Row count for scrolling
    countRows = 0;

    if ([user boolForKey:@"hasPendingItems"] == true)
    {
        subTypestr = @"Pending";
        self.completed_selected = NO;
        [completed_pending setSelectedSegmentIndex:1];

        [self.navigationItem setRightBarButtonItem:nil animated:YES];

        [self.glyph_checkmark setTextColor: kNoochBlue];
        [self.glyph_pending setTextColor: [UIColor whiteColor]];

        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];

        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }
    else
    {
        subTypestr = @"";
        self.completed_selected = YES;
        [completed_pending setSelectedSegmentIndex:0];

        UIButton * glyph_map = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [glyph_map setStyleId:@"glyph_map"];
        [glyph_map setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        glyph_map.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [glyph_map setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"] forState:UIControlStateNormal];
        [glyph_map addTarget:self action:@selector(toggleMapByNavBtn) forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem * map = [[UIBarButtonItem alloc] initWithCustomView:glyph_map];

        NSArray * topRightBtns = @[map,filt];
        [self.navigationItem setRightBarButtonItems:topRightBtns animated:YES];

        [self.glyph_checkmark setTextColor:[UIColor whiteColor]];
        [self.glyph_pending setTextColor: kNoochBlue];

        [self loadHist:@"ALL" index:index len:20 subType:subTypestr];
    }
    [self.view addSubview:self.glyph_checkmark];
    [self.view addSubview:self.glyph_pending];

    //Export History
    exportHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    [exportHistory setTitle:@"     Export History" forState:UIControlStateNormal];
    [exportHistory setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    exportHistory.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [exportHistory setFrame:CGRectMake(10, 420, 132, 31)];
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        [exportHistory setStyleClass:@"exportHistorybutton"];
    }
    else {
        [exportHistory setStyleClass:@"exportHistorybutton_4"];
    }

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    UILabel * glyph_export = [UILabel new];
    [glyph_export setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
    [glyph_export setFrame:CGRectMake(7, 1, 15, 30)];
    glyph_export.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-download"] attributes:textAttributes];
    [glyph_export setTextColor:[UIColor whiteColor]];
    [exportHistory addSubview:glyph_export];
    [exportHistory addTarget:self action:@selector(ExportHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportHistory];
    [self.view bringSubviewToFront:exportHistory];

    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideright:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer * recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMapByNavBtn)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer2];
    
    mapArea = [[UIView alloc]initWithFrame:CGRectMake(0, 84, 320, self.view.frame.size.height - 84)];

    // Google map
    //if ([[assist shared] checkIfLocAllowed])
    //{
        [mapArea setBackgroundColor:[UIColor clearColor]];
        camera = [GMSCameraPosition cameraWithLatitude:39.952360
                                             longitude:-75.163602
                                                  zoom:8
                                               bearing:0
                                          viewingAngle:30];

        mapView_ = [GMSMapView mapWithFrame:CGRectMake(43, 0, 277, mapArea.frame.size.height + 5) camera:camera];
    if ([[assist shared] checkIfLocAllowed])
    {
        mapView_.myLocationEnabled = YES;
    } else {
        mapView_.myLocationEnabled = NO;
    }
        mapView_.delegate = self;
        [mapView_ setMinZoom:3 maxZoom:17];
        [mapArea addSubview:mapView_];
    /*}
    else
    {
        [self displayEmptyMapArea];
    }*/

    [self.view addSubview:mapArea];
    [self.view bringSubviewToFront:self.tableShadow];
    [self.view bringSubviewToFront:self.list];

    _emptyText = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, 70)];
    _emptyPic = [[UIImageView alloc] initWithFrame:CGRectMake(33, 102, 253, 256)];

    [ARTrackingManager trackEvent:@"HistoryMain_viewDidLoad_End"];

    indexPathForDeletion = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:NSLocalizedString(@"History_ScrnTitle", @"History screen title")];

    [super viewWillAppear:animated];
    self.screenName = @"HistoryFlat Screen";
    self.artisanNameTag = @"History Screen";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (shouldDeletePendingRow)
    {
        [self deleteTableRow:indexPathForDeletion];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.hud hide:YES];

    if (isMapOpen)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];

        self.list.frame = CGRectMake(-276, 84, 320, self.view.frame.size.height);
        mapArea.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}

#pragma mark - Navigation Handlers
-(void)showMenu
{
    [self.search resignFirstResponder];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)backToApts
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sideright:(id)sender
{
    if (!self.completed_selected) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    self.list.frame=CGRectMake(0, 84, 320, self.view.frame.size.height);
    [self.view bringSubviewToFront:self.list];
    mapArea.frame=CGRectMake(0, 84,320,self.view.frame.size.height);
    isMapOpen = NO;
    [UIView commitAnimations];
    [self.view bringSubviewToFront:exportHistory];
}

#pragma mark - Map Area Related Methods
-(void)displayEmptyMapArea
{
    //NSLog(@"displayEmptyMapArea FIRED");
    [mapArea setBackgroundColor:[Helpers hexColor:@"efeff4"]];
    
    NSShadow * shadow_white = [[NSShadow alloc] init];
    shadow_white.shadowColor = [UIColor whiteColor];
    shadow_white.shadowOffset = CGSizeMake(0, 1.0);
    NSDictionary * shadowWhite = @{NSShadowAttributeName: shadow_white};
    
    NSShadow * shadow_Dark = [[NSShadow alloc] init];
    shadow_Dark.shadowColor = Rgb2UIColor(88, 90, 92, .85);
    shadow_Dark.shadowOffset = CGSizeMake(0, -2.5);
    NSDictionary * shadowDark = @{NSShadowAttributeName: shadow_Dark};
    
    self.glyph_emptyLoc = [[UILabel alloc] initWithFrame:CGRectMake(44, 35, 276, 72)];
    [self.glyph_emptyLoc setFont:[UIFont fontWithName:@"FontAwesome" size:68]];
    self.glyph_emptyLoc.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"] attributes:shadowDark];
    [self.glyph_emptyLoc setTextAlignment:NSTextAlignmentCenter];
    [self.glyph_emptyLoc setTextColor: kNoochGrayLight];
    [mapArea addSubview:self.glyph_emptyLoc];
    
    self.emptyLocHdr = [[UILabel alloc] initWithFrame:CGRectMake(44, 112, 276, 38)];
    [self.emptyLocHdr setFont:[UIFont fontWithName:@"Roboto-regular" size: 22]];
    self.emptyLocHdr.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"History_EmptyTableTitleHdr", @"History screen no results to show header text") attributes:shadowWhite];
    [self.emptyLocHdr setTextColor:kNoochGrayLight];
    [self.emptyLocHdr setTextAlignment:NSTextAlignmentCenter];
    [mapArea addSubview: self.emptyLocHdr];
    
    self.emptyLocBody = [[UILabel alloc] initWithFrame:CGRectMake(46, 151, 270, 80)];
    [self.emptyLocBody setFont:[UIFont fontWithName:@"Roboto-light" size: 17]];
    if ([[assist shared] checkIfLocAllowed])
    {
        self.emptyLocBody.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"History_EmptyMapViewTitleBody", @"History screen no results to show on map view body text")attributes:shadowWhite];
    }
    else
    {
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
        {
            self.emptyLocBody.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"History_NoLocationAccess", @"History screen no location access text") attributes:shadowWhite];
        }
    }
    [self.emptyLocBody setTextColor:kNoochGrayLight];
    [self.emptyLocBody setTextAlignment:NSTextAlignmentCenter];
    [self.emptyLocBody setNumberOfLines:0];
    [mapArea addSubview: self.emptyLocBody];
}

-(void)toggleMapByNavBtn
{
    if (!self.completed_selected) {
        return;
    }

    if (!isMapOpen)
    {
        if (![[assist shared] checkIfLocAllowed])
        {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
            {
                //location
                locationManager = [[CLLocationManager alloc] init];
                
                locationManager.delegate = self;
                locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m

                if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
                    // Sending a message to avoid compile time error
                    
                    [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                               to:locationManager
                                                             from:self
                                                         forEvent:nil];
                }
                [locationManager startUpdatingLocation];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"History_NeedLocAlrtTitle", @"History screen need location access Alert Title")
                                                                message:NSLocalizedString(@"History_NeedLocAlrtBody", @"History screen need location access Body Text")
                                                               delegate:Nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:Nil, nil];
                [alert show];
            }
        }
        else
        {
            locationManager = [[CLLocationManager alloc] init];

            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m

            [locationManager startUpdatingLocation];
        }
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.4];
    if (!isMapOpen)
    {
        if ([self.view.subviews containsObject:emptyText_localSearch])
        {
            [emptyText_localSearch setAlpha:0];
            [self.glyph_emptyTable setAlpha:0];
        }

        self.tableShadow.frame = CGRectMake(-276, 84, 320, self.view.frame.size.height);
        self.list.frame = CGRectMake(-276, 84, 320, self.view.frame.size.height);
        mapArea.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        isMapOpen = YES;
        [self mapPoints];
    }
    else
    {
        self.tableShadow.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        self.list.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        [self.view bringSubviewToFront:self.list];
        mapArea.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        isMapOpen = NO;
    }
    [UIView commitAnimations];
    [self.view bringSubviewToFront:exportHistory];

    [ARTrackingManager trackEvent:@"History_tggleMapSlide"];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    point.y -= 46;
    GMSCameraUpdate * cameraNew =
    [GMSCameraUpdate setTarget:[mapView.projection coordinateForPoint:point]];
    [mapView animateWithCameraUpdate:cameraNew];

    mapView.selectedMarker = marker;

    marker.zIndex += 30;
    //[self.view bringSubviewToFront:marker];
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSDictionary * dictRecord = [histArrayCommon objectAtIndex:[[marker title]intValue]];
    TransactionDetails * details = [[TransactionDetails alloc] initWithData:dictRecord];
    [self.navigationController pushViewController:details animated:YES];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    short markerNum = [[marker title] intValue];
    short custViewWidth = 234;

    UIView * customViewShell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, custViewWidth + 13, 250)];
    customViewShell.clipsToBounds = NO;

    UIView * customView = [[UIView alloc] initWithFrame:CGRectMake(6, 3, custViewWidth, 240)];
    customView.layer.borderWidth = 2.0f;
    customView.layer.cornerRadius = 12;
    customView.clipsToBounds = NO;
    customView.backgroundColor = Rgb2UIColor(31,32,32,.9);
    [customView setStyleId:@"historyMap_CustView_shadow"];


    UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake((custViewWidth/2) - 41, 10, 82, 82)];
    imgV.layer.cornerRadius = 41;
    imgV.layer.borderColor = [UIColor whiteColor].CGColor;
    imgV.layer.borderWidth = 2;
    imgV.clipsToBounds = YES;

    NSString * urlImage = [[histArrayCommon objectAtIndex: markerNum] valueForKey:@"Photo"];
    [imgV sd_setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];

    NSString * TransactionType = @"";

    UILabel * lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(2, 99, custViewWidth - 4, 16)];
    [lblTitle setStyleClass:@"historyMap_marker_title"];

    UILabel * lblName=[[UILabel alloc]initWithFrame:CGRectMake(2, 117, custViewWidth - 4, 20)];
    [lblName setStyleClass:@"historyMap_marker_name"];

    UILabel * lblAmt = [[UILabel alloc]initWithFrame:CGRectMake(2, 141, custViewWidth - 4, 27)];
    lblAmt.text = [NSString stringWithFormat:@"$%.02f",[[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"Amount"] floatValue]];
    lblAmt.textColor = kNoochGreen;
    [lblAmt setStyleClass:@"historyMap_marker_amnt"];

    UILabel *lblloc = [[UILabel alloc]initWithFrame:CGRectMake(2, 194, custViewWidth - 4, 16)];
    lblloc.textColor = [UIColor whiteColor];
    [lblloc setStyleClass:@"historyMap_marker_dateIntro"];

    // Set the Name Label (of the other party)
    if (  [[histArrayCommon objectAtIndex: markerNum] valueForKey:@"InvitationSentTo"] != NULL &&
        ![[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]] )
    {
        [imgV setImage:[UIImage imageNamed:@"profile_picture.png"]];

        NSString * invitationSentToStng = [NSString stringWithFormat:@"%@", [[histArrayCommon objectAtIndex: markerNum] valueForKey:@"InvitationSentTo"]];

        BOOL containsLetters = NSNotFound != [invitationSentToStng rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
        BOOL containsPunctuation = NSNotFound != [invitationSentToStng rangeOfCharacterFromSet:NSCharacterSet.punctuationCharacterSet].location;
        BOOL containsNumbers = NSNotFound != [invitationSentToStng rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location;
        BOOL containsSymbols = NSNotFound != [invitationSentToStng rangeOfCharacterFromSet:NSCharacterSet.symbolCharacterSet].location;
        
        // Check if it's a phone number
        if (containsNumbers && !containsLetters && !containsPunctuation && !containsSymbols)
        {
            NSMutableString * mu = [NSMutableString stringWithString: invitationSentToStng];
            [mu insertString:@"(" atIndex:0];
            [mu insertString:@")" atIndex:4];
            [mu insertString:@" " atIndex:5];
            [mu insertString:@"-" atIndex:9];

            NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];

            [lblName setText:phoneWithSymbolsAddedBack];
        }
        else
        {
            [lblName setText:[NSString stringWithFormat:@"%@ ", invitationSentToStng]];
        }
    }
    else
    {
        lblName.text = [NSString stringWithFormat:@"%@ %@",
                        [[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"FirstName"] capitalizedString],
                        [[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"LastName"] capitalizedString] ];
    }

    // Set Memo if one exists and add to Custom View
    if (  [[histArrayCommon objectAtIndex: markerNum] valueForKey:@"Memo"] != NULL &&
        ![[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"Memo"] isKindOfClass:[NSNull class]] )
    {
        UILabel *lblmemo = [[UILabel alloc]initWithFrame:CGRectMake(2, 163, custViewWidth - 4, 30)];
        [lblmemo setStyleClass:@"historyMap_marker_memo"];
        lblmemo.textColor = [UIColor lightGrayColor];
        lblmemo.numberOfLines = 2;
        lblmemo.text = [NSString stringWithFormat:@"\"%@\"",[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"Memo"]];

        if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"Memo"] length] == 0)
        {
            lblmemo.text = @"";
        }

        [customView addSubview:lblmemo];
    }

    NSString *statusstr;

    if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Transfer"])
    {
        if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"MemberId"]])
        {
            customView.layer.borderColor = [kNoochRed CGColor];
            TransactionType = NSLocalizedString(@"History_SentToTxt", @"History screen 'Sent To' Text");
        }
        else
        {
            customView.layer.borderColor = [kNoochGreen CGColor];
            TransactionType = NSLocalizedString(@"History_PaymentFromTxt", @"History screen 'Payment From' text");
        }
    }
    else if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Request"])
    {
        customView.layer.borderColor = [kNoochBlue CGColor];
        if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionStatus"] isEqualToString:@"Cancelled"])
        {
            statusstr = NSLocalizedString(@"History_CancelledTxt", @"History screen 'Cancelled' Text");
            [lblloc setStyleClass:@"red_text"];
        }
        else if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionStatus"] isEqualToString:@"Rejected"])
        {
            statusstr = NSLocalizedString(@"History_RejectedTxt", @"History screen 'Rejected' Text");
            [lblloc setStyleClass:@"red_text"];
        }
        else
        {
            statusstr = NSLocalizedString(@"History_PendingTxt", @"History screen 'Pending' Text");
            [lblloc setStyleClass:@"green_text"];
        }

        if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"RecepientId"]])
        {
            TransactionType = NSLocalizedString(@"History_RequestSentToTxt", @"History screen 'Request Sent To' Text");
        }
        else
        {
            TransactionType = NSLocalizedString(@"History_RequestFromTxt", @"History screen 'Request From' Text");
        }
    }
    else if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Invite"])
    {
        customView.layer.borderColor = [[UIColor whiteColor] CGColor];
        TransactionType = NSLocalizedString(@"History_SentToTxt", @"History screen 'Sent To' Text");
        [imgV setImage:[UIImage imageNamed:@"profile_picture.png"]];
        statusstr = NSLocalizedString(@"History_InvitedOnTxt", @"History screen 'Invited On' Text");
        [lblloc setStyleClass:@"green_text"];
    }
    else if ([[[histArrayCommon objectAtIndex:markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Disputed"])
    {
        customView.layer.borderColor = [kNoochGrayDark CGColor];
        TransactionType = @"Disputed ";
        [lblloc setStyleClass:@"orange_text"];
    }
    lblTitle.text = [NSString stringWithFormat:@"%@",TransactionType];

    if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Donation"] ||
        [[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Sent"]     ||
        [[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Received"] ||
        [[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Transfer"] )
    {
        statusstr = NSLocalizedString(@"History_CompletedOnTxt", @"History screen 'Completed On' Text");
        [lblloc setStyleClass:@"green_text"];
    }
    
    //Set the AM and PM symbols
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    
    NSDate * yourDate = [dateFormatter dateFromString:[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionDate"]];
    dateFormatter.dateFormat = @"dd-MMMM-yyyy";
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];

    NSArray * arrdate = [[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];

    if ([[[histArrayCommon objectAtIndex: markerNum] valueForKey:@"TransactionType"] isEqualToString:@"Request"])
    {
        [lblloc setText:[NSString stringWithFormat:@"%@",statusstr]];
        
        UILabel *datelbl = [[UILabel alloc] initWithFrame:CGRectMake(2, 207, custViewWidth - 4, 22)];
        [datelbl setTextColor:[UIColor lightGrayColor]];
        [customView addSubview:datelbl];
        [datelbl setStyleClass:@"historyMap_marker_date"];
        datelbl.text = [NSString stringWithFormat:@"Sent on: %@ %@, %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]];
    }
    else
    {
        [lblloc setText:[NSString stringWithFormat:@"%@ %@ %@, %@",statusstr,[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]]];
    }

    [customView addSubview:imgV];
    [customView addSubview:lblTitle];
    [customView addSubview:lblName];
    [customView addSubview:lblAmt];
    [customView addSubview:lblloc];
    [customViewShell addSubview:customView];

    return customViewShell;
}

-(void)mapPoints
{
    [mapView_ clear];

    if (self.completed_selected)
    {
        if ([histShowArrayCompleted count] == 0)
        {
            return;
        }
        histArrayCommon = [histShowArrayCompleted copy];
    }
    else
    {
        if ([histShowArrayPending count] == 0)
        {
            return;
        }
        histArrayCommon = [histShowArrayPending copy];
    }

    [mapView_ setAlpha:1];
    [mapArea bringSubviewToFront:mapView_];
    _markers = [[NSMutableArray alloc] init];
    [_markers removeAllObjects];

    for (int i = 0; i < histArrayCommon.count; i++)
    {
        NSDictionary *tempDict = [histArrayCommon objectAtIndex:i];

        markerOBJ = [[GMSMarker alloc] init];

        // IF transaction has a location, OR if the transfer is type "Reward", meaning paid directly from Nooch
        if (([[tempDict objectForKey:@"Latitude"] floatValue] != 0 && [[tempDict objectForKey:@"Longitude"] floatValue] != 0) ||
            [[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Reward"])
        {
            if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Reward"])
            {
                markerOBJ.icon=[UIImage imageNamed:@"n_Icon.png"];
                markerOBJ.position = CLLocationCoordinate2DMake(39.9526f, -75.1634f);
            }
            else
            {
                markerOBJ.position = CLLocationCoordinate2DMake([[tempDict objectForKey:@"Latitude"] floatValue], [[tempDict objectForKey:@"Longitude"] floatValue]);
            }
            markerOBJ.infoWindowAnchor = CGPointMake(0.5, -0.05);
            markerOBJ.appearAnimation = kGMSMarkerAnimationPop;
            markerOBJ.zIndex = 10 + i;
            markerOBJ.map = mapView_;
            markerOBJ.title = [NSString stringWithFormat:@"%d",i];

            [_markers addObject:markerOBJ];

            if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"])
            {
                if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:i] valueForKey:@"RecepientId"]])
                {
                    markerOBJ.icon = [GMSMarker markerImageWithColor:kNoochGreen];
                    markerOBJ.rotation = 11;
                }
                else
                {
                    markerOBJ.icon = [GMSMarker markerImageWithColor:kNoochRed];
                    markerOBJ.rotation = -11;
                }
            }
            else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"] isEqualToString:@"Request"])
            {
                markerOBJ.icon = [GMSMarker markerImageWithColor:kNoochBlue];
                markerOBJ.rotation = -6;
            }
            else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"] isEqualToString:@"Disputed"])
            {
                markerOBJ.icon = [GMSMarker markerImageWithColor:kNoochGrayDark];
                markerOBJ.rotation = 5;
            }
            else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"] isEqualToString:@"Invite"])
            {
                markerOBJ.icon = [GMSMarker markerImageWithColor:[UIColor whiteColor]];
                markerOBJ.rotation = -4;
            }
            else
            {
                //NSLog(@"Transaction Type is: %@", [[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]);
                markerOBJ.rotation = 1;
                markerOBJ.icon=[UIImage imageNamed:@"n_Icon.png"];
            }
        }
    }
}

- (void)focusMapToShowAllMarkers
{
    if (locUpdateSuccessfully == true)
    {
        //NSLog(@"locationUser is: %f,%f", lat_hist,lon_hist);
    }
    else
    {
        CLLocationDegrees latitude = 39.9515;
        CLLocationDegrees longitude = -75.1636;
        
        CLLocationCoordinate2D defaultLocation = CLLocationCoordinate2DMake(latitude, longitude);
        locationUser = defaultLocation;
    }

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:locationUser coordinate:locationUser];

    for (GMSMarker *marker in _markers)
    {
        if (marker.position.latitude != 0 &&
            marker.position.longitude != 0)
        {
            bounds = [bounds includingCoordinate:marker.position];
        }
    }

    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f]
                     forKey:kCATransactionAnimationDuration];
    [CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                     forKey:kCATransactionAnimationTimingFunction];
    // change the camera, set the zoom, whatever. Just make sure to call an animateTo* method.
    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:35]];
    [mapView_ animateToViewingAngle:30];
    [mapView_ animateToBearing:1];
    [CATransaction commit];
}

# pragma mark - LocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    
    locationUser = manager.location.coordinate;
    lat_hist = [[[NSString alloc] initWithFormat:@"%f",locationUser.latitude] floatValue];
    lon_hist = [[[NSString alloc] initWithFormat:@"%f",locationUser.longitude] floatValue];
    
    //NSLog(@"Hist -DidUpdateLocation --> locationUser is: %f,%f", lat_hist,lon_hist);
    locUpdateSuccessfully = true;
    [self performSelector:@selector(focusMapToShowAllMarkers) withObject:nil afterDelay:0.4];

    [[assist shared] setlocationAllowed:YES];
    
    serve * serveOBJ = [serve new];
    [serveOBJ UpDateLatLongOfUser:[[NSString alloc] initWithFormat:@"%f",locationUser.latitude]
                              lng:[[NSString alloc] initWithFormat:@"%f",locationUser.longitude]];

    [ARProfileManager setLocationValue:locationUser forVariable:@"lastKnownLocation"];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [[assist shared] setlocationAllowed:NO];

    if ([error code] == kCLErrorDenied) {
        NSLog(@"History --> Location Mgr Error: %@", error);
    }
    else {
        NSLog(@"History --> Location Mgr Error: %@",error);
    }

    locUpdateSuccessfully = false;
    [self performSelector:@selector(focusMapToShowAllMarkers) withObject:nil afterDelay:0.4];
}

-(void)move:(id)sender
{
    [self.view bringSubviewToFront:mapArea];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
    }
    if (firstX+translatedPoint.x==150.500000) {
        return;
    }
    if (firstX+translatedPoint.x==572.500000) {
        return;
    }
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY);

    CGFloat animationDuration = 0.2;
    CGFloat velocityX = (0.0*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
    
    CGFloat finalX = translatedPoint.x + velocityX;
    CGFloat finalY = firstY;
    [[sender view] setCenter:translatedPoint];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [[sender view] setCenter:CGPointMake(finalX, finalY)];
    [UIView commitAnimations];
}

-(void)FilterHistory:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    isHistFilter = YES;

    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = nil;
    
    fp =  [[FPPopoverController alloc] initWithViewController:popOver];
    fp.border = NO;
    fp.tint = FPPopoverDefaultTint;
    fp.arrowDirection = FPPopoverArrowDirectionUp;
    fp.contentSize = CGSizeMake(160, 303);
    [fp presentPopoverFromPoint:CGPointMake(258, 50)];
}

-(void)dismissFP:(NSNotification *)notification
{
    [fp dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismissPopOver" object:nil];
    isSearch = NO;

    if (isMapOpen)
    {
        [UIView animateKeyframesWithDuration:0.35
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                                          self.tableShadow.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
                                          self.list.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
                                          [self.view bringSubviewToFront:self.list];
                                          mapArea.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
                                      }];
                                  } completion: ^(BOOL finished) {
                                      isMapOpen = NO;

                                      if (![listType isEqualToString:@"CANCEL"] && isFilterSelected)
                                      {
                                          [self.search setShowsCancelButton:NO];
                                          [self.search setText:@""];
                                          [self.search resignFirstResponder];
                                          
                                          [histShowArrayCompleted removeAllObjects];
                                          [histShowArrayPending removeAllObjects];
                                          
                                          isLocalSearch = NO;
                                          isFilter = YES;
                                          index = 1;
                                          isFilterSelected = NO;
                                          
                                          //Release memory cache
                                          SDImageCache *imageCache = [SDImageCache sharedImageCache];
                                          [imageCache clearMemory];
                                          [imageCache clearDisk];
                                          [imageCache cleanDisk];
                                          countRows = 0;
                                          //NSLog(@"ListType is: %@",listType);
                                          
                                          [self loadHist:listType index:index len:20 subType:subTypestr];
                                      }
                                      else {
                                          isFilter = NO;
                                      }
                                  }
         ];
    }

    else if (![listType isEqualToString:@"CANCEL"] && isFilterSelected)
    {
        [self.search setShowsCancelButton:NO];
        [self.search setText:@""];
        [self.search resignFirstResponder];

        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];

        isLocalSearch = NO;
        isFilter = YES;
        index = 1;
        isFilterSelected = NO;

        //Release memory cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        countRows = 0;
        //NSLog(@"ListType is: %@",listType);

        [self loadHist:listType index:index len:20 subType:subTypestr];
    }
    else {
        isFilter = NO;
    }
}

-(void)loadHist:(NSString*)filter index:(int)ind len:(int)len subType:(NSString*)subType
{
    if (!isFromTransferPIN && ![self.view.subviews containsObject:self.hud])
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = NSLocalizedString(@"History_HUDloadingTxt", @"History screen HUD loading text");
        [self.hud show:YES];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
    }

    isSearch = NO;
    isLocalSearch = NO;

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"hist";
    [serveOBJ histMore:filter sPos:ind len:len subType:subTypestr];
}

#pragma mark - transaction type switching
- (void) completed_or_pending:(id)sender
{
    listType = @"ALL";

    if (isMapOpen) {
        [self toggleMapByNavBtn];
    }

    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([segmentedControl selectedSegmentIndex] == 0)
    {
        UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [filter setStyleClass:@"label_filter"];
        [filter setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-filter"] forState:UIControlStateNormal];
        [filter setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        filter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];
        
        UIButton *glyph_map = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [glyph_map setStyleId:@"glyph_map"];
        [glyph_map setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"] forState:UIControlStateNormal];
        [glyph_map setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        glyph_map.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [glyph_map addTarget:self action:@selector(toggleMapByNavBtn) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *map = [[UIBarButtonItem alloc] initWithCustomView:glyph_map];
        
        NSArray *topRightBtns = @[map,filt];
        [self.navigationItem setRightBarButtonItems:topRightBtns animated:YES];
        
        [self.glyph_checkmark setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
        [self.glyph_checkmark setTextColor:[UIColor whiteColor]];
        
        [self.glyph_pending setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
        [self.glyph_pending setTextColor: kNoochBlue];
        
        subTypestr = @"";
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        self.completed_selected = YES;
        countRows = 0;
        [self loadHist:listType index:1 len:28 subType:subTypestr];
    }
    else
    {
        [self.navigationItem setRightBarButtonItems:nil animated:YES];

     /* UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [filter setStyleClass:@"label_filter"];
        [filter setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-filter"] forState:UIControlStateNormal];
        [filter setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        filter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];

        [self.navigationItem setRightBarButtonItem:filt animated:NO ];*/

        [self.glyph_checkmark setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
        [self.glyph_checkmark setTextColor: kNoochBlue];

        [self.glyph_pending setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
        [self.glyph_pending setTextColor: [UIColor whiteColor]];

        subTypestr = @"Pending";
        self.completed_selected = NO;

        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        [self loadHist:listType index:1 len:20 subType:subTypestr];

        countRows = 0;
        index = 1;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
     return @"";
}

/*- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[Helpers hexColor:@"f8f8f8"]];
    return headerView;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section2
{
    if (self.completed_selected)
    {
        if (isLocalSearch) {
            return [histTempCompleted count];
        }
        return [histShowArrayCompleted count] + 1;
    }
    else
    {
        if (isLocalSearch) {
            return [histTempPending count];
        }
        return [histShowArrayPending count] + 1;
    }
    return 0;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.completed_selected)
    {
        if ([histShowArrayCompleted count] > indexPath.row)
        {
            NSDictionary * dictRecord_complete = [histShowArrayCompleted objectAtIndex:indexPath.row];
            if (![[dictRecord_complete valueForKey:@"Memo"] isKindOfClass:[NSNull class]])
            {
                if ([[dictRecord_complete valueForKey:@"Memo"] length] < 2) {
                    return 74;
                }
                else if ([[dictRecord_complete valueForKey:@"Memo"] length] > 26) {
                    return 86;
                }
                else
                   return 74;
            }
            else
            {
                return 74;
            }
        }
        else if ([histTempCompleted count] == indexPath.row ||
                 [histShowArrayCompleted count] == 0)
        {
            return 200;
        }
    }
    else // For Pending Tab
    {
        if ([histShowArrayPending count] > indexPath.row)
        {
            return 81;
        }
    }

    return 74;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"Cell";
    SWTableViewCell * cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell != NULL && tableView == NULL)
    {
        NSLog(@"The cell is:  %@",cell);
    }

    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
    if (self.completed_selected)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    else
    {
        NSMutableArray *temp;
        if (isLocalSearch) {
            temp = [histTempPending mutableCopy];
        }
        else {
            temp = [histShowArrayPending mutableCopy];
        }

        if ([temp count] > indexPath.row)
        {
            NSDictionary *dictRecord = [temp objectAtIndex:indexPath.row];
            
            if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"] ||
                [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] )
            {
                if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[user objectForKey:@"MemberId"]])
                {
                    //cancel or remind
                    [rightUtilityButtons sw_addUtilityButtonWithColor:kNoochBlue
                                                                title:NSLocalizedString(@"History_RemindTxt", @"History screen 'Remind' Button Text")];
                    [rightUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                                title:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text")];
                }
                else
                {
                    //accept or decline
                    [rightUtilityButtons sw_addUtilityButtonWithColor:kNoochGreen
                                                                 icon:[UIImage imageNamed:@"check.png"]];
                    [rightUtilityButtons sw_addUtilityButtonWithColor:
                        [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                                 icon:[UIImage imageNamed:@"cross.png"]];
                }
            }
        }

        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                    reuseIdentifier:cellIdentifier];
        cell.rightUtilityButtons = rightUtilityButtons;
        cell.delegate = self;

    }
    [cell setDelegate:self];

    if ([cell.contentView subviews])
    {
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    if (self.completed_selected)
    {
        if ([histShowArrayCompleted count] > indexPath.row)
        {
            NSDictionary * dictRecord = nil;

            if (!isLocalSearch)
            {
                dictRecord = [histShowArrayCompleted objectAtIndex:indexPath.row];
            }
            else
            {
                dictRecord = [histTempCompleted objectAtIndex:indexPath.row];
            }

            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]  ||
                [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ||
                [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]||
                [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"] )
            {
                UILabel * statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(58, 7, 10, 11)];
                [statusIndicator setBackgroundColor:[UIColor clearColor]];
                [statusIndicator setTextAlignment:NSTextAlignmentCenter];
                [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:10]];

                UILabel * amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                [amount setBackgroundColor:[UIColor clearColor]];
                [amount setTextAlignment:NSTextAlignmentRight];
                [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                [amount setStyleClass:@"history_transferamount"];
                [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]]];

                UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 50, 50)];
                pic.layer.cornerRadius = 25;
                pic.clipsToBounds = YES;

				UILabel *transferTypeLabel = [UILabel new];
                [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
                transferTypeLabel.layer.cornerRadius = 4;
                transferTypeLabel.clipsToBounds = YES;

                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];

                UILabel *date = [UILabel new];
                [date setStyleClass:@"history_datetext"];

                UILabel *glyphDate = [UILabel new];
                [glyphDate setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
                [glyphDate setFrame:CGRectMake(155, 7, 14, 11)];
                [glyphDate setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
                [glyphDate setTextColor:kNoochGrayLight];
                [cell.contentView addSubview:glyphDate];
                
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                    [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-minus-circle"]];
                    [statusIndicator setTextColor:kNoochRed];
                }
                else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                    [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"]];
                    [statusIndicator setTextColor:kNoochRed];
                }
                else if ( [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] ||
                         ![[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Reward"]) {
                    [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"]];
                    [statusIndicator setTextColor:kNoochGreen];
                }
    
                NSString * username = [NSString stringWithFormat:@"%@",[user valueForKey:@"UserName"]];
                NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
                NSString * invitationSentTo = [NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"InvitationSentTo"]];

                if ( [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"] ||
                    ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
                     invitationSentTo != NULL && ![invitationSentTo isEqualToString:username] &&
                    ![[dictRecord valueForKey:@"Name"] isEqualToString:fullName]))
                {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                    {
                        // Sent Transfer
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [transferTypeLabel setText:NSLocalizedString(@"History_TransferToTxt", @"History screen 'Transfer To' Text")];
						[transferTypeLabel setBackgroundColor:kNoochRed];
                        [name setText:[NSString stringWithFormat:@"%@",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
                    else
                    {
                        // Received Transfer
                        [amount setStyleClass:@"history_transferamount_pos"];
                        [transferTypeLabel setText:NSLocalizedString(@"History_TransferFromTxt", @"History screen 'Transfer From' Text")];
                        [transferTypeLabel setBackgroundColor:kNoochGreen];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                {
                    [amount setTextColor:kNoochGrayDark];
                    
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]])
                    {
                        [transferTypeLabel setText:NSLocalizedString(@"History_RequestSentToTxt", @"History screen 'Request Sent To' Text")];
                        [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_wider"];
                        
                        if ([dictRecord valueForKey:@"InvitationSentTo"] == NULL ||
                            [[dictRecord objectForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]])
                        {
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                            [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                        else
                        {
                            [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];

                            BOOL containsLetters = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
                            BOOL containsPunctuation = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.punctuationCharacterSet].location;
                            BOOL containsNumbers = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location;
                            BOOL containsSymbols = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.symbolCharacterSet].location;
                            
                            // Check if it's a phone number
                            if (containsNumbers && !containsLetters && !containsPunctuation && !containsSymbols)
                            {
                                NSMutableString * mu = [NSMutableString stringWithString:[dictRecord valueForKey:@"InvitationSentTo"]];
                                [mu insertString:@"(" atIndex:0];
                                [mu insertString:@")" atIndex:4];
                                [mu insertString:@" " atIndex:5];
                                [mu insertString:@"-" atIndex:9];
                                
                                NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                                
                                [name setText:phoneWithSymbolsAddedBack];
                            }
                            else
                            {
                                [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"]]];
                            }
                        }
                    }
                    else
                    {
                        [transferTypeLabel setText:NSLocalizedString(@"History_RequestFromTxt", @"History screen 'Request From' Text")];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
					[transferTypeLabel setBackgroundColor:kNoochBlue];
                
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
                          [dictRecord valueForKey:@"InvitationSentTo"] != NULL)
                {
                    if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                        [amount setTextColor:kNoochGrayDark];
                    }
                    else {
                        [amount setStyleClass:@"history_transferamount_neg"];
                    }
                    [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];

                    [transferTypeLabel setText:NSLocalizedString(@"History_InviteSentToTxt", @"History screen 'Invite Sent To' Text")];
					[transferTypeLabel setTextColor:kNoochGrayDark];

                    BOOL containsLetters = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
                    BOOL containsPunctuation = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.punctuationCharacterSet].location;
                    BOOL containsNumbers = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location;
                    BOOL containsSymbols = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.symbolCharacterSet].location;
                    
                    // Check if it's a phone number
                    if (containsNumbers && !containsLetters && !containsPunctuation && !containsSymbols)
                    {
                        NSMutableString * mu = [NSMutableString stringWithString:[dictRecord valueForKey:@"InvitationSentTo"]];
                        [mu insertString:@"(" atIndex:0];
                        [mu insertString:@")" atIndex:4];
                        [mu insertString:@" " atIndex:5];
                        [mu insertString:@"-" atIndex:9];

                        NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];

                        [name setText:phoneWithSymbolsAddedBack];
                    }
                    else if (containsLetters)
                    {
                        [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"]]];
                    }
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Reward"])
                {
                    [amount setStyleClass:@"history_transferamount_pos"];
                    [transferTypeLabel setText:@"REWARD FROM"];
                    [transferTypeLabel setTextColor:kNoochGrayDark];
                    [transferTypeLabel setBackgroundColor:[UIColor yellowColor]];
                    [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                    [pic setFrame:CGRectMake(9, 7, 44, 44)];
                    [pic setImage:[UIImage  imageNamed:@"Icon.png"]];
                    pic.layer.cornerRadius = 7;
                    [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-star"]];
                    [statusIndicator setTextColor:[UIColor yellowColor]];
                    [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:10]];
                    [statusIndicator setStyleId:@"rewardIconShadow"];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"])
                {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                    {
                        //@"You disputed a transfer to"
                        [transferTypeLabel setText:NSLocalizedString(@"History_YouDisputedTxt", @"History screen 'You disputed...' Text")];
                    }
                    else
                    {
                        //@"Transfer disputed by"
                        [transferTypeLabel setText:NSLocalizedString(@"History_DisputedByTxt", @"History screen 'Transfer disputed by' Text")];
                    }
                    
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_evenWider"];
                    [transferTypeLabel setBackgroundColor:Rgb2UIColor(193, 32, 39, .98)];
                    [date setStyleClass:@"history_datetext_wide"];
                    [glyphDate setFrame:CGRectMake(180, 7, 14, 11)];
                    [amount setTextColor:kNoochGrayDark];
                    [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                    [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                }

				//  'updated_balance' now for displaying transfer STATUS, only if status is "cancelled" or "rejected"
                //  (this used to display the user's updated balance, which no longer exists)
                UILabel * updated_balance = [UILabel new];
                [updated_balance setStyleClass:@"transfer_status"];
                
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ||
                    [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"])
                {
                    [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                    [updated_balance setTextColor:kNoochGrayLight];
                    [cell.contentView addSubview:updated_balance];
                }
                else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] &&
                         [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"] )
                {
                    [updated_balance setText:NSLocalizedString(@"History_PaidTxt", @"History screen 'Paid' Text")];
                    [updated_balance setTextColor:kNoochGreen];
                    [cell.contentView addSubview:updated_balance];
                }
                else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] &&
                         [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] )
                {
                    [updated_balance setText:NSLocalizedString(@"History_AcceptedTxt", @"History screen 'Accepted' Text")];
                    [updated_balance setTextColor:kNoochGreen];
                    [cell.contentView addSubview:updated_balance];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] &&
                         [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"])
                {
                    [updated_balance setText:NSLocalizedString(@"History_ResolvedTxt", @"History screen 'Resolved' Text")];
                    [updated_balance setTextColor:kNoochGreen];
                    [cell.contentView addSubview:updated_balance];
                }

                NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                if (![addeddate isKindOfClass:[NSNull class]] && addeddate != NULL)
                {

                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                        fromDate:addeddate
                                                                          toDate:[NSDate date]
                                                                         options:0];

                    if ((long)[components day] > 3)
                    {
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                        //Set the AM and PM symbols
                        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                        [dateFormatter setAMSymbol:@"AM"];
                        [dateFormatter setPMSymbol:@"PM"];
                        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
                        NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                        dateFormatter.dateFormat = @"dd-MMMM-yyyy";

                        if (![yourDate isKindOfClass:[NSNull class]] && yourDate != NULL)
                        {
                            NSArray * arrdate = [[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
                            [date setText:[NSString stringWithFormat:@"%@ %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0]]];
                            [cell.contentView addSubview:date];
                        }
                    }
                    else if ((long)[components day] == 0)
                    {
                        NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                                fromDate:addeddate
                                toDate:ServerDate
                                options:0];
                        if ((long)[components hour] == 0)
                        {
                            NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit
                                fromDate:addeddate
                                toDate:ServerDate
                                options:0];
                            if ((long)[components minute] == 0)
                            {
                                NSDateComponents *components = [gregorianCalendar components:NSSecondCalendarUnit                                
                                    fromDate:addeddate
                                    toDate:ServerDate
                                    options:0];
                                [date setText:[NSString stringWithFormat:@"%ld seconds ago",(long)[components second]]];
                                [cell.contentView addSubview:date];
                            }
                            else if ((long)[components minute] == 1)
                                [date setText:[NSString stringWithFormat:@"%ld minute ago",(long)[components minute]]];
                            else
                                [date setText:[NSString stringWithFormat:@"%ld minutes ago",(long)[components minute]]];
                            [cell.contentView addSubview:date];
                        }
                        else
                        {
                            if ((long)[components hour] == 1)
                                [date setText:[NSString stringWithFormat:@"%ld hour ago",(long)[components hour]]];
                            else
                                [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                            [cell.contentView addSubview:date];
                        }
                    }
                    else
                    {
                        if ((long)[components day] == 1)
                            [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                        [cell.contentView addSubview:date];
                    }

                    [cell.contentView addSubview:glyphDate];
                }


                if ( [dictRecord valueForKey:@"Memo"] != NULL &&
                    ![[dictRecord objectForKey:@"Memo"] isKindOfClass:[NSNull class]] &&
                    ![[dictRecord valueForKey:@"Memo"] isEqualToString:@""] )
                {
                    UILabel *label_memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [label_memo setBackgroundColor:[UIColor clearColor]];
                    [label_memo setTextAlignment:NSTextAlignmentRight];
                    NSString * forText = NSLocalizedString(@"History_ForTxt", @"History screen 'For' Text");
                    label_memo.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  \"%@\" ",forText,[dictRecord valueForKey:@"Memo"]]
                                                                           attributes:nil];
                    label_memo.numberOfLines = 0;
                    label_memo.lineBreakMode = NSLineBreakByTruncatingTail;
                    [label_memo setStyleClass:@"history_memo"];
                    
                    if (label_memo.attributedText.length > 36) {
                        [label_memo setStyleClass:@"history_memo_long"];
                    }
                    [cell.contentView addSubview:label_memo];
                    [name setStyleClass:@"history_cell_textlabel_wMemo"];
                }

                [cell.contentView addSubview:pic];
                [cell.contentView addSubview:amount];
                [cell.contentView addSubview:statusIndicator];
                [cell.contentView addSubview:transferTypeLabel];
                [cell.contentView addSubview:name];
            }

            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        }

        else if (!isLocalSearch && indexPath.row == [histShowArrayCompleted count])
        {
            if (isEnd == YES)
            {
                if ([histShowArrayCompleted count] == 0)
                {
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
            else
            {
                if (isSearch)
                {
                    ishistLoading = YES;
                    index++;
                }
                else
                {
                    if (indexPath.row > 9)
                    {
                        ishistLoading = YES;
                        index++;
                        [self loadHist:listType index:index len:20 subType:subTypestr];
                    }
                }
            }
        }

    }

    else if (self.completed_selected == NO)
    {
        if ([histShowArrayPending count] > indexPath.row)
        {
            NSDictionary * dictRecord = nil;

            if (!isLocalSearch)
            {
                dictRecord = [histShowArrayPending objectAtIndex:indexPath.row];
            }
            else
            {
                dictRecord = [histTempPending objectAtIndex:indexPath.row];
            }

            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"])
            {
                UILabel * amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                [amount setBackgroundColor:[UIColor clearColor]];
                [amount setTextAlignment:NSTextAlignmentRight];
                [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                [amount setStyleClass:@"history_pending_transferamount"];
                [amount setStyleClass:@"history_transferamount_neutral"];
                [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]]];

                UILabel * transferTypeLabel = [UILabel new];
                [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
                transferTypeLabel.layer.cornerRadius = 3;
                transferTypeLabel .clipsToBounds = YES;

                UILabel * statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(58, 7, 10, 11)];
                [statusIndicator setBackgroundColor:[UIColor clearColor]];
                [statusIndicator setTextAlignment:NSTextAlignmentCenter];
                [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
                [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle-o"]];
                [statusIndicator setTextColor:kNoochBlue];

                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];

                UILabel *date = [UILabel new];
                [date setStyleClass:@"history_datetext"];

                UILabel *glyphDate = [UILabel new];
                [glyphDate setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
                [glyphDate setFrame:CGRectMake(155, 7, 14, 11)];
                [glyphDate setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
                [glyphDate setTextColor:kNoochGrayLight];
                [cell.contentView addSubview:glyphDate];

                UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 9, 50, 50)];
                pic.layer.cornerRadius = 25;
                pic.clipsToBounds = YES;

                UILabel * label_memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                if ( [dictRecord valueForKey:@"Memo"] != NULL &&
                    ![[dictRecord objectForKey:@"Memo"] isKindOfClass:[NSNull class]] &&
                    ![[dictRecord valueForKey:@"Memo"] isEqualToString:@""] )
                {
                    [label_memo setBackgroundColor:[UIColor clearColor]];
                    [label_memo setTextAlignment:NSTextAlignmentRight];
                    NSString * forText = NSLocalizedString(@"History_ForTxt", @"History screen 'For' Text");
                    label_memo.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  \"%@\" ",forText,[dictRecord valueForKey:@"Memo"]]
                                                                                attributes:nil];
                    label_memo.numberOfLines = 0;
                    label_memo.lineBreakMode = NSLineBreakByTruncatingTail;
                    [label_memo setStyleClass:@"history_memo"];
                    
                    if (label_memo.attributedText.length > 42) {
                        [label_memo setStyleClass:@"history_memo_long"];
                    }
                    [name setStyleClass:@"history_cell_textlabel_wMemo"];
                }


                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                {
                    if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[user objectForKey:@"MemberId"]])
                    {
                        [transferTypeLabel setText:NSLocalizedString(@"History_RequestSentToTxt", @"History screen 'Request Sent To' Text")];
                        [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_wider"];

                        if ( [dictRecord valueForKey:@"InvitationSentTo"] == NULL ||
                            [[dictRecord objectForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]])
                        {
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                            [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                        else
                        {
                            [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];

                            NSString * invitationSentTo = [NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"InvitationSentTo"]];
                            
                            BOOL containsLetters = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
                            BOOL containsPunctuation = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.punctuationCharacterSet].location;
                            BOOL containsNumbers = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location;
                            BOOL containsSymbols = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.symbolCharacterSet].location;
                            
                            // Check if it's a phone number
                            if (containsNumbers && !containsLetters && !containsPunctuation && !containsSymbols)
                            {
                                NSMutableString * mu = [NSMutableString stringWithString:[dictRecord valueForKey:@"InvitationSentTo"]];
                                [mu insertString:@"(" atIndex:0];
                                [mu insertString:@")" atIndex:4];
                                [mu insertString:@" " atIndex:5];
                                [mu insertString:@"-" atIndex:9];
                                
                                NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                                
                                [name setText:phoneWithSymbolsAddedBack];
                            }
                            else
                            {
                                [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"]]];
                            }
                        }
                    }
                    else
                    {
                        UIView * bgcolor = [[UIView alloc] init]; // Yellow Highlight for Pending Reeceived Requests
                        bgcolor.backgroundColor = Rgb2UIColor(240, 250, 30, .35);
                        
                        if (label_memo.attributedText.length > 42) {
                            [bgcolor setFrame:CGRectMake(0, 0, 320, 78)];
                        }
                        cell.backgroundView = bgcolor;
                        [cell.contentView addSubview:bgcolor];

                        [transferTypeLabel setText:NSLocalizedString(@"History_RequestFromTxt", @"History screen 'Request From' Text")];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
                    [transferTypeLabel setBackgroundColor:kNoochBlue];
                }
                
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
                          [dictRecord valueForKey:@"InvitationSentTo"] != NULL)
                {
                    [transferTypeLabel setText:NSLocalizedString(@"History_InviteSentToTxt", @"History screen 'Invite Sent To' Text")];
                    [transferTypeLabel setBackgroundColor:kNoochGrayLight];
                    [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];

                    NSString * invitationSentTo = [NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"InvitationSentTo"]];

                    BOOL containsLetters = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
                    BOOL containsPunctuation = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.punctuationCharacterSet].location;
                    BOOL containsNumbers = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location;
                    BOOL containsSymbols = NSNotFound != [invitationSentTo rangeOfCharacterFromSet:NSCharacterSet.symbolCharacterSet].location;

                    // Check if it's a phone number
                    if (containsNumbers && !containsLetters && !containsPunctuation && !containsSymbols)
                    {
                        NSMutableString * mu = [NSMutableString stringWithString:[dictRecord valueForKey:@"InvitationSentTo"]];
                        [mu insertString:@"(" atIndex:0];
                        [mu insertString:@")" atIndex:4];
                        [mu insertString:@" " atIndex:5];
                        [mu insertString:@"-" atIndex:9];
                        
                        NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                        
                        [name setText:phoneWithSymbolsAddedBack];
                    }
                    else
                    {
                        [name setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"InvitationSentTo"]]];
                    }
                }

                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"])
                {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                    {
                        [transferTypeLabel setText:NSLocalizedString(@"History_YouDisputedTxt", @"History screen 'You disputed...' Text")];
                    }
                    else {
                        [transferTypeLabel setText:NSLocalizedString(@"History_DisputedByTxt", @"History screen 'Transfer disputed by' Text")];
                    }
                    [statusIndicator setTextColor:kNoochRed];
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_evenWider"];
                    [date setStyleClass:@"history_datetext_wide"];
                    [glyphDate setFrame:CGRectMake(180, 7, 14, 11)];
                    [transferTypeLabel setBackgroundColor:kNoochRed];
                    [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                    [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                }

                else
                {
                    [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
                    [name setText:@""];
                }

                if (![[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"])
                {
                    UILabel * indicator = [[UILabel alloc] initWithFrame:CGRectMake(310, 0, 10, 80)];
                    [indicator setBackgroundColor:kNoochBlue];
                    [indicator setFont:[UIFont fontWithName:@"FontAwesome" size:13]];
                    [indicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-caret-left"]];
                    [indicator setTextColor:[UIColor whiteColor]];
                    [indicator setTextAlignment:NSTextAlignmentCenter];
                    [cell.contentView addSubview:indicator];
                }

                NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                    fromDate:addeddate
                    toDate:ServerDate
                    options:0];

                if ((long)[components day] > 3)
                {
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    //Set the AM and PM symbols
                     [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                    [dateFormatter setAMSymbol:@"AM"];
                    [dateFormatter setPMSymbol:@"PM"];
                    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
                    NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    dateFormatter.dateFormat = @"dd-MMMM-yyyy";

                    NSArray*arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
                    [date setText:[NSString stringWithFormat:@"%@ %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0]]];
                    [cell.contentView addSubview:date];
                }
                else if ((long)[components day]==0)
                {
                    NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                    if ((long)[components hour]==0)
                    {
                        NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit                  
                                    fromDate:addeddate
                                    toDate:ServerDate
                                    options:0];
                        if ((long)[components minute]==0)
                        {
                            NSDateComponents *components = [gregorianCalendar components:NSSecondCalendarUnit
                                    fromDate:addeddate
                                    toDate:ServerDate
                                    options:0];
                            [date setText:[NSString stringWithFormat:@"%ld seconds ago",(long)[components second]]];
                            [cell.contentView addSubview:date];
                        }
                        else if ((long)[components minute]==1)
                            [date setText:[NSString stringWithFormat:@"%ld minute ago",(long)[components minute]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld minutes ago",(long)[components minute]]];
                        [cell.contentView addSubview:date];
                    }
                    else {
                        if ((long)[components hour]==1)
                            [date setText:[NSString stringWithFormat:@"%ld hour ago",(long)[components hour]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                        [cell.contentView addSubview:date];
                    }
                }
                else {
                    if ((long)[components day]==1)
                        [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                    else
                        [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                    [cell.contentView addSubview:date];   
                }

                [cell.contentView addSubview:amount];
                [cell.contentView addSubview:statusIndicator];
                [cell.contentView addSubview:transferTypeLabel];
                [cell.contentView addSubview:name];
                [cell.contentView addSubview:pic];
                [cell.contentView addSubview:label_memo];
			}
        }
        else if (indexPath.row == [histShowArrayPending count])
        {
            if (isEnd != YES && isStart == YES)
            {}
            else
            {
                if (isSearch)
                {
                    ishistLoading = YES;
                    index++;
                }
                else
                {
                    if (indexPath.row > 18)
                    {
                        ishistLoading = YES;
                        index++;
                        [self loadHist:listType index:index len:20 subType:subTypestr];
                    }
                }
            }
        }
    }

    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];

    return rightUtilityButtons;
}

-(void)deleteTableRow:(NSIndexPath*)rowNumber
{
    short rowToRemove = rowNumber.row;
    [histShowArrayPending removeObjectAtIndex:rowToRemove];
    [self.list deleteRowsAtIndexPaths:@[rowNumber] withRowAnimation:UITableViewRowAnimationFade];
    
    serve * getPendingCount = [serve new];
    [getPendingCount setDelegate:self];
    [getPendingCount setTagName:@"getPendingTransfersCount"];
    [getPendingCount getPendingTransfersCount];
    
    shouldDeletePendingRow = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isMapOpen)
    {
        [self toggleMapByNavBtn];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (self.completed_selected)
        {
            if (indexPathForDeletion != nil) {
                indexPathForDeletion = nil;
            }

            if (isLocalSearch)
            {
                NSDictionary *dictRecord = [histTempCompleted objectAtIndex:indexPath.row];
                TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
                [self.navigationController pushViewController:details animated:YES];
                return;
            }
            if ([histShowArrayCompleted count] > indexPath.row)
            {
                NSDictionary * dictRecord = [histShowArrayCompleted objectAtIndex:indexPath.row];
                //NSLog(@"Selected Entry is: %@", dictRecord);
                TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
                [self.navigationController pushViewController:details animated:YES];
            }
        }
        else
        {
            indexPathForDeletion = indexPath;

            if (isLocalSearch)
            {
                NSDictionary * dictRecord = [histTempPending objectAtIndex:indexPath.row];
                TransactionDetails * details = [[TransactionDetails alloc] initWithData:dictRecord];
                [self.navigationController pushViewController:details animated:YES];
            }
            else if ([histShowArrayPending count] > indexPath.row)
            {
                NSDictionary * dictRecord = [histShowArrayPending objectAtIndex:indexPath.row];
                TransactionDetails * details = [[TransactionDetails alloc] initWithData:dictRecord];
                [self.navigationController pushViewController:details animated:YES];
            }
        }
    }
}

#pragma mark - SWTableView
- (void)swipeableTableViewCell:(SWTableViewCell *)cell
didTriggerRightUtilityButtonWithIndex:(NSInteger)ind
{
    NSMutableArray *temp;

    if (isLocalSearch) {
        temp = [histTempPending mutableCopy];
    }
    else {
        temp = [histShowArrayPending mutableCopy];
    }
    NSDictionary * dictRecord = [temp objectAtIndex:[self.list indexPathForCell:cell].row];

    indexPathForDeletion = [NSIndexPath indexPathForRow:[self.list indexPathForCell:cell].row inSection:0];

    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
    {
        if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[user objectForKey:@"MemberId"]])
        { // For the Sender of a Request

			if ( [dictRecord valueForKey:@"InvitationSentTo"] == NULL ||
                [[dictRecord valueForKey:@"InvitationSentTo"]  isKindOfClass:[NSNull class]] )
            {
                if (ind == 0)
                {  //remind
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send Reminder"
                                                                 message:[NSString stringWithFormat:@"Do you want to send %@ a reminder about this request?",[[self.responseDict valueForKey:@"FirstName"] capitalizedString]]
                                                                delegate:self
                                                       cancelButtonTitle:@"Yes"
                                                       otherButtonTitles:@"No", nil];
                    [av show];
                    [av setTag:2012];
                }
                else
                {  //cancel
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel This Request"
                                                                 message:[NSString stringWithFormat:@"Are you sure you want to cancel this request to %@?",[[self.responseDict valueForKey:@"FirstName"] capitalizedString]]
                                                                delegate:self
                                                       cancelButtonTitle:@"Yes"
                                                       otherButtonTitles:@"No", nil];
                    [av show];
                    [av setTag:1010];
                }
            }
            else
            {
                if (ind == 0)
                { //remind
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send Reminder"
                                                                 message:@"Do you want to send a reminder about this request?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Yes"
                                                       otherButtonTitles:@"No", nil];
                    [av show];
                    [av setTag:2013];
                }
                else
                {  // cancel
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel This Request"
                                                                 message:@"Are you sure you want to cancel this request?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Yes"
                                                       otherButtonTitles:@"No", nil];
                    [av show];
                    [av setTag:2010];
                }
            }
        }
        else
        {  // For the Recipient of a Request
            if (ind == 0)
            { //accept

                if ([[assist shared] getSuspended])
                {
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Suspended"
                                                                    message:@"\xF0\x9F\x98\xA7\nYour account has been suspended pending a security review. We apologize for the inconvenience - our top priority is keeping Nooch safe for all users.\n\nPlease email support@nooch.com if you believe this was a mistake and we will be glad to help."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:@"Contact Support", nil];
                    [alert setTag:50];
                    [alert show];
                    return;
                }
                else if ([[user valueForKey:@"Status"]isEqualToString:@"Registered"])
                {
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Email Verification Needed"
                                                                    message:@"Please click the link we emailed you to verify your email address."
                                                                   delegate:Nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:@"Resend", nil];
                    [alert setTag:51];
                    [alert show];
                    return;
                }
                else if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] )
                {
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Phone Not Verified"
                                                                    message:@"To keep Nooch safe, we ask all users to verify a phone number before sending money.\n\nIf you've already added your phone number, just respond 'Go' to the text message we sent."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Later"
                                                          otherButtonTitles:@"Go Now" , nil];
                    [alert show];
                    return;
                }
                else if (![user boolForKey:@"IsSynapseBankAvailable"])
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Please Attach An Account"
                                                                  message:@"\xE2\x9A\xA1\nAdding a bank account to fund Nooch payments is lightning quick.\n\n• No routing or account number needed\n• Bank-grade encryption keeps your info safe\n\nWould you like to take care of this now?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:@"Add Bank Now", nil];
                    [alert setTag:52];
                    [alert show];
                    return;
                }
                // ... and check if that bank account is 'Verified'
                else if (![user boolForKey:@"IsSynapseBankVerified"])
                {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Bank Account Un-Verified"
                                                                 message:@"Looks like your bank account remains un-verified.  This usually happens when the contact info listed on the bank account does not match your Nooch profile information. Please contact Nooch support for more information."
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:@"Learn More", nil];
                    [av setTag:53];
                    [av show];
                }
                else
                {
                    NSMutableDictionary * input = [dictRecord mutableCopy];
                    [input setValue:@"accept" forKey:@"response"];
                   
                    [[assist shared]setRequestMultiple:NO];
                    TransferPIN *trans = [[TransferPIN alloc] initWithReceiver:input type:@"requestRespond" amount:[[dictRecord objectForKey:@"Amount"] floatValue]];
                    [nav_ctrl pushViewController:trans animated:YES];
                }
            }
            else
            { // Reject
                self.responseDict = [dictRecord copy];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Reject %@'s Request",[self.responseDict valueForKey:@"FirstName"]]
                                                             message:[NSString stringWithFormat:@"Are you sure you want to reject this request from %@?",[self.responseDict valueForKey:@"Name"]]
                                                            delegate:self
                                                   cancelButtonTitle:@"Yes - Reject"
                                                   otherButtonTitles:@"No", nil];
                [av show];
                [av setTag:1011];
            }
        }
    }
    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"])
    {
        if (ind == 0)
        {  //remind
            self.responseDict = [dictRecord copy];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send Reminder" message:@"Send a reminder about this transfer?"
                                                        delegate:self
                                               cancelButtonTitle:@"Yes"
                                               otherButtonTitles:@"No", nil];
            [av show];
            [av setTag:2014];
        }
        else
        {  //cancel
            self.responseDict = [dictRecord copy];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel This Transfer"
                                                         message:@"Are you sure you want to cancel this transfer?"
                                                        delegate:self
                                               cancelButtonTitle:@"Yes"
                                               otherButtonTitles:@"No", nil];
            [av show];
            [av setTag:310];
        }
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

#pragma mark - Date From String
- (NSDate*) dateFromString:(NSString*)aStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"M/dd/yyyy hh:mm:ss a";

    NSDate *aDate = [dateFormatter dateFromString:aStr];
    return aDate;
}

#pragma mark - Search Related Methods
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO];
    [self.search resignFirstResponder];
    [self.search setText:@""];

    [UIView animateKeyframesWithDuration:0.2
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [emptyText_localSearch setAlpha:0];
                                      [self.glyph_emptyTable setAlpha:0];
                                  }];
                              } completion:^(BOOL finished){
                                  if ([self.view.subviews containsObject:emptyText_localSearch] ||
                                      [self.view.subviews containsObject:self.glyph_emptyTable])
                                  {
                                      [emptyText_localSearch setHidden:YES];
                                      [self.glyph_emptyTable setHidden:YES];
                                      
                                      [emptyText_localSearch removeFromSuperview];
                                      [self.glyph_emptyTable removeFromSuperview];
                                  }
                              }
     ];

    isSearch = NO;
    isFilter = NO;
    listType = @"ALL";

    [histShowArrayCompleted removeAllObjects];
    [histShowArrayPending removeAllObjects];

    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    countRows = 0;

    [self loadHist:listType index:1 len:20 subType:subTypestr];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text length] > 0)
    {
        listType = @"ALL";
        
        SearchString = [[self.search.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"] lowercaseString];

        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];

        index = 1;
        isSearch = YES;
        isLocalSearch = NO;
        isFilter = NO;
 
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        countRows = 0;
        [self loadSearchByName];
    }
    [self.search resignFirstResponder];
}

-(void)searchTableView
{
    [histTempCompleted removeAllObjects];
    [histTempPending removeAllObjects];

    NSMutableArray * dictToSearch = nil;

    if ([subTypestr isEqualToString:@"Pending"])
    {
        dictToSearch = [histShowArrayPending mutableCopy];
    }
    else
    {
        dictToSearch = [histShowArrayCompleted mutableCopy];
    }
    
    for (NSMutableDictionary * tableViewBind in dictToSearch)
    {
        NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchString length])];
        NSComparisonResult result2 = [[tableViewBind valueForKey:@"LastName"] compare:SearchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchString length])];
        NSComparisonResult result3 = [[NSString stringWithFormat:@"%@ %@",[tableViewBind valueForKey:@"FirstName"],[tableViewBind valueForKey:@"LastName"]] compare:SearchString
                                                                                                                                                            options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                                                                                                                              range:NSMakeRange(0, [SearchString length])];

        NSComparisonResult result4 = 1;
        if (![[tableViewBind valueForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]])
        {
            result4 = [[tableViewBind valueForKey:@"InvitationSentTo"] compare:SearchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchString length])];
        }

        if (result == NSOrderedSame || result2 == NSOrderedSame || result3 == NSOrderedSame || result4 == NSOrderedSame)
        {
            if (self.completed_selected)
            {
                [histTempCompleted addObject:tableViewBind];
            }
            else
            {
                [histTempPending addObject:tableViewBind];
            }
        }
    }

    if (self.completed_selected)
    {
        if ([histTempCompleted count] == 0)
        {
            if ([self.list subviews])
            {
                NSArray * viewsToHide = [self.list subviews];
                for (UIView * v in viewsToHide)
                {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.15];
                    [v setAlpha:0];
                    [UIView commitAnimations];
                }
            }

            [self.list setStyleId:@"emptyTable"];

            if (![self.view.subviews containsObject:emptyText_localSearch])
            {
                NSShadow * shadow_Dark = [[NSShadow alloc] init];
                shadow_Dark.shadowColor = Rgb2UIColor(88, 90, 92, .7);
                shadow_Dark.shadowOffset = CGSizeMake(0, -1.5);
                NSDictionary * shadowDark = @{NSShadowAttributeName: shadow_Dark};

                emptyText_localSearch = [[UILabel alloc] initWithFrame:CGRectMake(40, 78, 240, 60)];
                [emptyText_localSearch setFont:[UIFont fontWithName:@"Roboto-regular" size:20]];
                [emptyText_localSearch setText:NSLocalizedString(@"History_NoPaymentsFoundByName", @"History screen 'No payments found for that name' Text")];
                [emptyText_localSearch setTextColor:kNoochGrayLight];
                [emptyText_localSearch setTextAlignment:NSTextAlignmentCenter];
                [emptyText_localSearch setNumberOfLines:0];
                [emptyText_localSearch setHidden:NO];
                [emptyText_localSearch setAlpha:0];
                [self.view addSubview:emptyText_localSearch];

                self.glyph_emptyTable = [[UILabel alloc] initWithFrame:CGRectMake(40, 140, 240, 70)];
                [self.glyph_emptyTable setFont:[UIFont fontWithName:@"FontAwesome" size: 58]];
                self.glyph_emptyTable.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-frown-o"] attributes:shadowDark];
                [self.glyph_emptyTable setTextAlignment:NSTextAlignmentCenter];
                [self.glyph_emptyTable setTextColor: kNoochGrayLight];
                [self.glyph_emptyTable setHidden:NO];
                [self.glyph_emptyTable setAlpha:0];
                [self.view addSubview:self.glyph_emptyTable];
            }
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            [emptyText_localSearch setAlpha:1];
            [self.glyph_emptyTable setAlpha:1];
            [UIView commitAnimations];
        }
        else if ([histTempCompleted count] > 0)
        {
            [self.list setStyleId:@"history"];

            if ([self.list subviews])
            {
                NSArray * viewsToShow = [self.list subviews];
                for (UIView * v in viewsToShow)
                {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.15];
                    [v setAlpha:1];
                    [UIView commitAnimations];
                }
            }

            [UIView animateKeyframesWithDuration:0.1
                                           delay:0
                                         options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                              [emptyText_localSearch setAlpha:0];
                                              [self.glyph_emptyTable setAlpha:0];
                                          }];
                                      } completion:^(BOOL finished){
                                          if ([self.view.subviews containsObject:emptyText_localSearch] ||
                                              [self.view.subviews containsObject:self.glyph_emptyTable])
                                          {
                                              [emptyText_localSearch setHidden:YES];
                                              [self.glyph_emptyTable setHidden:YES];

                                              [emptyText_localSearch removeFromSuperview];
                                              [self.glyph_emptyTable removeFromSuperview];
                                          }
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.list reloadData];
                                          });
                                      }
             ];
        }
    }
    else
    {
        histShowArrayPending = dictToSearch;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.list reloadData];
        });
    }
}

-(void)loadSearchByName
{
    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"History_HUDsearching", @"History screen HUD when searching Text");
    [self.hud show:YES];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    listType = @"ALL";
    isLocalSearch = NO;
    serve * serveOBJ = [serve new];
    serveOBJ.tagName = @"search";
    [serveOBJ setDelegate:self];
    [serveOBJ histMoreSerachbyName:listType sPos:index len:20 name:SearchString subType:subTypestr];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];

    if (isMapOpen)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.35];

        self.tableShadow.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        self.list.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        [self.view bringSubviewToFront:self.list];
        mapArea.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        isMapOpen = NO;
        
        [UIView commitAnimations];
    }
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
    {
        searchBar.text=@"";
        return;
    }
    if ([searchText length] > 0)
    {
        SearchString = [self.search.text lowercaseString];
        //isEnd = YES;
        isLocalSearch = YES;
        [self searchTableView];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
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
                          initWithTitle:NSLocalizedString(@"ConnectionErrorAlrtTitle", @"Any screen Connection Error Alert Text")
                          message:NSLocalizedString(@"ConnectionErrorAlrtBody", @"Any screen Connection Error Alert Body Text")
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError *error;
    [self.hud hide:YES];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];
        [timer invalidate];
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        [nav_ctrl popViewControllerAnimated:YES];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }

    if ([tagName isEqualToString:@"csv"])
    {
        NSDictionary * dictResponse = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([[[dictResponse valueForKey:@"sendTransactionInCSVResult"]valueForKey:@"Result"]isEqualToString:@"1"])
        {
            [MMProgressHUD dismissWithSuccess:@"Success"];

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"History_ExprtSuccessAlrtTitle", @"History screen export successful Alert Title")
                                                            message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA5\n%@", NSLocalizedString(@"History_ExprtSuccessAlrtBody", @"History screen export successful Alert Body Text")]
                                                           delegate:Nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:Nil, nil];
            [alert show];
        }
        else
        {
            [MMProgressHUD dismissWithError:@"Error!"];
        }
    }

    else if ([tagName isEqualToString:@"hist"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
        });

        if ([self.list subviews])
        {
            NSArray * viewsToShow = [self.list subviews];
            for (UIView * v in viewsToShow)
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.15];
                [v setAlpha:1];
                [UIView commitAnimations];
            }
        }

        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count] > 0)
        {
            [self.list setStyleId:@"history"];

            isEnd = NO;
            isStart = NO;

            for (NSDictionary * dict in histArray)
            {
                if ( [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]   ||
                     [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] ||
                     [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]  ||
                     ( [[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] &&
                       [[dict valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"]) )
                {
                    [histShowArrayCompleted addObject:dict];
                }

                if (  ([[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] && ![[dict valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"]) ||
                    ((([[dict valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && ![[dict valueForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]] ) || [[dict valueForKey:@"TransactionType"]isEqualToString:@"Request"]) &&
                       [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]))
                {
                    [histShowArrayPending addObject:dict];
                }
            }

            if ([self.list.subviews containsObject:_emptyPic])
            {
                [UIView animateKeyframesWithDuration:0.3
                                               delay:0
                                             options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                          animations:^{
                                              [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                                                  [_emptyText setAlpha:0];
                                                  [_emptyPic setAlpha:0];
                                              }];
                                          } completion: ^(BOOL finished) {
                                              [_emptyText removeFromSuperview];
                                              [_emptyPic removeFromSuperview];
                                          }
                 ];
            }

            if (![[assist shared] checkIfLocAllowed])
            {
                [self performSelector:@selector(focusMapToShowAllMarkers) withObject:nil afterDelay:0.4];
            }
        }
        else if ([histArray count] == 0)
        {
            isEnd = YES;
            [mapView_ setAlpha:0];
            [self displayEmptyMapArea];
        }

        if (isMapOpen) {
            [self mapPoints];
        }
        serve * serveOBJ = [serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ setTagName:@"time"];
        [serveOBJ GetServerCurrentTime];

        if (!isLocalSearch)
        {
            if (isEnd == YES)
            {
                if ((self.completed_selected && [histShowArrayCompleted count] == 0) ||
                   (!self.completed_selected && [histShowArrayPending count] == 0))
                {
                    [self.list setStyleId:@"emptyTable"];
                    [_emptyPic setImage:[UIImage imageNamed:@"HistoryPending"]];

                    if ([[UIScreen mainScreen] bounds].size.height > 500)
                    {
                        [_emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
                    }
                    else
                    {
                        [_emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:18]];
                        [_emptyPic setFrame:CGRectMake(33, 78, 253, 256)];
                    }
                    [_emptyText setNumberOfLines:0];
                    [_emptyText setTextAlignment:NSTextAlignmentCenter];
                    if (self.completed_selected)
                    {
                        if ([[UIScreen mainScreen] bounds].size.height > 500)
                        {
                            [_emptyText setFrame:CGRectMake(15, 14, 290, 68)];
                        }
                        else
                        {
                            [_emptyText setFrame:CGRectMake(15, 5, 290, 68)];
                        }
                        [_emptyText setText:NSLocalizedString(@"History_EmptyCompletedTxt", @"History screen when there are no Completed payments to display text")];
                        [_emptyPic setStyleClass:@"animate_bubble"];
                    }
                    else
                    {
                        if ([[UIScreen mainScreen] bounds].size.height > 500)
                        {
                            [_emptyText setFrame:CGRectMake(35, 14, 250, 68)];
                        }
                        else
                        {
                            [_emptyText setFrame:CGRectMake(35, 5, 250, 68)];
                        }
                        [_emptyText setText:NSLocalizedString(@"History_EmptyPendingTxt", @"History screen when there are no Pending payments to display text")];
                    }

                    if (![self.list.subviews containsObject:_emptyPic] ||
                        ![self.list.subviews containsObject:_emptyText])
                    {
                        [self.list addSubview: _emptyPic];
                        [self.list addSubview: _emptyText];

                        [UIView animateKeyframesWithDuration:0.3
                                                       delay:0
                                                     options:0 << 16
                                                  animations:^{
                                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                                                          [_emptyText setAlpha:1];
                                                          [_emptyPic setAlpha:1];
                                                      }];
                                                  } completion: nil
                         ];
                        
                    }

                    [exportHistory removeFromSuperview];
                }
            }
        }
    }

    else if ([tagName isEqualToString:@"time"])
    {
        //ServerDate
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        ServerDate = [self dateFromString:[dict valueForKey:@"Result"] ];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.list reloadData];
        });
        
        if ((self.completed_selected && [histShowArrayCompleted count] > 0) ||
            (!self.completed_selected && [histShowArrayPending count] > 0))
        {
            if ([subTypestr isEqualToString:@"Pending"])
            {
                [self.list scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countRows inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                countRows = [histShowArrayPending count];
            }
            else
            {
                [self.list scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countRows inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                 countRows = [histShowArrayCompleted count];
            }
        }
        [self.view bringSubviewToFront:exportHistory];

        serve * getPendingCount = [serve new];
        [getPendingCount setDelegate:self];
        [getPendingCount setTagName:@"getPendingTransfersCount"];
        [getPendingCount getPendingTransfersCount];
    }

    else if ([tagName isEqualToString:@"getPendingTransfersCount"])
    {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        int pendingDisputes = [[dict valueForKey:@"pendingDisputesNotSolved"] intValue];
        int pendingInvitations = [[dict valueForKey:@"pendingInvitationsSent"] intValue];
        int pendingRequestsSent = [[dict valueForKey:@"pendingRequestsSent"] intValue];
        int pendingRequestsReceived = [[dict valueForKey:@"pendingRequestsReceived"] intValue];
        int totalPending = pendingDisputes + pendingInvitations + pendingRequestsSent + pendingRequestsReceived;

        // TOTAL PENDING PAYMENTS
        if (totalPending > 0)
        {
            [completed_pending setTitle:[NSString stringWithFormat:@"  Pending  (%d)", totalPending] forSegmentAtIndex:1];
        }
        else
        {
            [completed_pending setTitle:@" Pending" forSegmentAtIndex:1];
        }

        // PENDING REQUESTS RECEIVED (SET DEFAULT VALUE FOR LEFT SIDE MENU)
        if (pendingRequestsReceived > 0)
        {
            [user setBool:true forKey:@"hasPendingItems"];

            NSString * count;
            count = [NSString stringWithFormat:@"%@", [dict valueForKey:@"pendingRequestsReceived"]];

            [user setValue: count forKey:@"Pending_count"];
            [user synchronize];
        }
        else
        {
            [user setBool:false forKey:@"hasPendingItems"];
        }
    }

    else if ([tagName isEqualToString:@"search"])
    {
        [self.hud hide:YES];
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count] > 0)
        {
            isEnd = NO;
            isStart = NO;
            
            for (NSDictionary * dict in histArray)
            {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"])
                {
                    [histShowArrayCompleted addObject:dict];
                }
            }
            for (NSDictionary * dict in histArray)
            {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"])
                {
                    [histShowArrayPending addObject:dict];
                }
            }

            serve * serveOBJ = [serve new];
            [serveOBJ setDelegate:self];
            [serveOBJ setTagName:@"time"];
            [serveOBJ GetServerCurrentTime];
        }
        else {
            isEnd = YES;
        }
        if (isMapOpen) {
            [self mapPoints];
        }
    }

    else if ([tagName isEqualToString:@"reject"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"History_RequestRejectedAlrtTitle", @"History screen request rejected successfully Alert Title")
                                                        message:NSLocalizedString(@"History_RequestRejectedAlrtBody", @"History screen request rejected successfully Alert Body Text")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];

        subTypestr = @"Pending";
        self.completed_selected = NO;

        [self deleteTableRow:indexPathForDeletion];
    }

    else if ([tagName isEqualToString:@"CancelMoneyTransferToNonMemberForSender"])
    {
        [self.hud hide:YES];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"History_TransferCancelledAlrtTitle", @"History screen transfer/invite cancelled successfully Alert Title")
                                                        message:NSLocalizedString(@"History_TransferCancelledAlrtBody", @"History screen transfer/invite cancelled successfully Alert Body Text")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];

        subTypestr = @"Pending";
        self.completed_selected = NO;

        [self deleteTableRow:indexPathForDeletion];
    }

    else if ([tagName isEqualToString:@"cancelRequestToExisting"] ||
             [tagName isEqualToString:@"cancelRequestToNonNoochUser"])
    {
        [self.hud hide:YES];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"History_RequestCancelledAlrtTitle", @"History screen request cancelled successfully Alert Title")
                                                        message:NSLocalizedString(@"History_RequestCancelledAlrtBody", @"History screen request cancelled successfully Alert Body Text")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];

        subTypestr = @"Pending";
        self.completed_selected = NO;

        [self deleteTableRow:indexPathForDeletion];
    }

    else if ([tagName isEqualToString:@"remind"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"History_ReminderSuccessAlrtTitle", @"History screen reminder sent successfully Alert Title")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }

    if ([tagName isEqualToString:@"email_verify"])
    {
        NSString *response = [[NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error] objectForKey:@"Result"];
        if ([response isEqualToString:@"Already Activated."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Your email has already been verified."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Not a nooch member."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"History_ErrorAlrtBody", @"History screen generic error Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Success"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Check Your Email"
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA5\nA verifiction link has been sent to %@.",[user objectForKey:@"UserName"]]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Failure"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"History_ErrorAlrtBody", @"History screen generic error Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    }
}

-(IBAction)ExportHistory:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"History_ExportAlrtTitle", @"History screen export transfer data Alert Title")
                                                     message:NSLocalizedString(@"History_ExportAlrtBody", @"History screen export transfer data Alert Body Text")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text")
                                           otherButtonTitles:NSLocalizedString(@"History_SendTxt", @"History screen 'Send' Button Text"), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 11;

    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = [user objectForKey:@"UserName"];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    [alert show];
}

#pragma mark - Alert View Handling
-(void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 11 && buttonIndex == 1) // export history
    {
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:@"Preparing Secure Connection"
                              status:nil
                 confirmationMessage:@"Cancel Adding A Bank?"
                         cancelBlock:^{
                             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Export Cancelled"
                                                                              message:@""
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles: nil];
                             alert.tag = 11;
                         }
         ];

        NSString * email = [[actionSheet textFieldAtIndex:0] text];
        serve * s = [[serve alloc] init];
        [s setTagName:@"csv"];
        [s setDelegate:self];
        [s sendCsvTrasactionHistory:email];
    }

    if (actionSheet.tag == 2012 && buttonIndex == 0)  // REMIND Request to Existing User
    {
        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"remind";
        [serveObj SendReminderToRecepient:[self.responseDict valueForKey:@"TransactionId"] reminderType:@"RequestMoneyReminderToExistingUser"];
    }
    
    else if (actionSheet.tag == 2013 && buttonIndex == 0)  // REMIND Request to New User
    {
        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"remind";
        [serveObj SendReminderToRecepient:[self.responseDict valueForKey:@"TransactionId"] reminderType:@"RequestMoneyReminderToNewUser"];
    }
    
    else if (actionSheet.tag == 2014 && buttonIndex == 0)  // REMIND Transfer/Invite to New User
    {
        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"remind";
        [serveObj SendReminderToRecepient:[self.responseDict valueForKey:@"TransactionId"] reminderType:@"InvitationReminderToNewUser"];
    }

    else if (actionSheet.tag == 51 && buttonIndex == 1)  // Resend Email Verificaiton Link
    {
        serve * email_verify = [serve new];
        [email_verify setDelegate:self];
        [email_verify setTagName:@"email_verify"];
        [email_verify resendEmail];
    }

    else if (actionSheet.tag == 52 && buttonIndex == 1)  // No bank attached, go to Settings
    {
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
        [self.slidingViewController resetTopView];
    }

    else if (actionSheet.tag == 53 && buttonIndex == 1)  // No bank attached, go to Settings
    {
        shouldDisplayBankNotVerifiedLtBox = YES;
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
        [self.slidingViewController resetTopView];
    }

    else if ((actionSheet.tag == 1010 || actionSheet.tag == 2010) && buttonIndex == 0) // CANCEL Request
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = NSLocalizedString(@"History_HUDcancellingReq", @"History screen HUD text for cancelling a request");
        [self.hud show:YES];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        
        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        
        if (actionSheet.tag == 1010) {
            serveObj.tagName = @"cancelRequestToExisting";  // Cancel Request for Existing User
            [serveObj CancelMoneyRequestForExistingNoochUser:[self.responseDict valueForKey:@"TransactionId"]];
        }
        else if (actionSheet.tag == 2010) {  // CANCEL Request to NonNoochUser
            serveObj.tagName = @"cancelRequestToNonNoochUser";
            [serveObj CancelMoneyRequestForNonNoochUser:[self.responseDict valueForKey:@"TransactionId"]];
        }
    }

    else if (actionSheet.tag == 310 && buttonIndex == 0) // CANCEL Transfer (Send) Invite
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = NSLocalizedString(@"History_HUDcancelling", @"History screen HUD text for cancelling a transfer/invite");
        [self.hud show:YES];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        
        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"CancelMoneyTransferToNonMemberForSender";  // Cancel Request for Existing User
        [serveObj CancelMoneyTransferToNonMemberForSender:[self.responseDict valueForKey:@"TransactionId"]];
    }

    else if (actionSheet.tag == 1011 && buttonIndex == 0)  // REJECT Request
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = NSLocalizedString(@"History_HUDrejecting", @"History screen HUD text for rejecting a request");
        [self.hud show:YES];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;

        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"reject";
        [serveObj CancelRejectTransaction:[self.responseDict valueForKey:@"TransactionId"] resp:@"Rejected"];
    }
    
    else if (actionSheet.tag == 50 && buttonIndex == 1) // Contact Support
    {
        if (![MFMailComposeViewController canSendMail])
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                                message:@"You don't have an email account configured for this device."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [av show];
                return;
        }

        NSString * memberId = [user valueForKey:@"MemberId"];
        NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
        NSString * userStatus = [user objectForKey:@"Status"];
        NSString * userEmail = [user objectForKey:@"UserName"];
        NSString * IsVerifiedPhone = [[user objectForKey:@"IsVerifiedPhone"] lowercaseString];
        NSString * iOSversion = [[UIDevice currentDevice] systemVersion];
        NSString * msgBody = [NSString stringWithFormat:@"<!doctype html> <html><body><br><br><br><br><br><br><small>• MemberID: %@<br>• Name: %@<br>• Status: %@<br>• Email: %@<br>• Is Phone Verified: %@<br>• iOS Version: %@<br></small></body></html>",memberId, fullName, userStatus, userEmail, IsVerifiedPhone, iOSversion];

        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [mailComposer setMessageBody:msgBody isHTML:YES];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

#pragma mark - Mail Controller
-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;

        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [alert setTitle:@"Email Draft Saved"];
            [alert show];
            break;

        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"Email Sent Successfully"];
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

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}
@end