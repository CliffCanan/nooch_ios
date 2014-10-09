//  HistoryFlat.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

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

@interface HistoryFlat ()<GMSMapViewDelegate>
{
    GMSMapView * mapView_;
    GMSCameraPosition *camera;
    GMSMarker *markerOBJ;
    UIRefreshControl *refreshControl;
}
@property (strong, nonatomic) GMSMapView *mapView;
@property(nonatomic,strong) UISearchBar *search;
@property(nonatomic,strong) UITableView *list;
@property(nonatomic,strong) UIButton *glyph_map;
@property(nonatomic) BOOL completed_selected;
@property(nonatomic,strong) NSDictionary *responseDict;
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
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (isMapOpen)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        
        self.list.frame = CGRectMake(-276, 84, 320, self.view.frame.size.height);
        mapArea.frame = CGRectMake(0, 84,320,self.view.frame.size.height);
        [UIView commitAnimations];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"History"];

    [super viewWillAppear:animated];
    self.trackedViewName = @"HistoryFlat Screen";
}

-(void)showMenu
{
    [self.search resignFirstResponder];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];

    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    [self.navigationItem setTitle:@"History"];
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
    
    NSArray *seg_items = @[@"Completed",@"Pending"];
    completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [completed_pending setStyleId:@"history_segcontrol"];
    [completed_pending addTarget:self action:@selector(completed_or_pending:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:completed_pending];
    
    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
    [self.list setStyleId:@"history"];
    [self.list setDataSource:self];
    [self.list setDelegate:self];
    [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list];

    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    [self.search setStyleId:@"history_search"];
    [self.search setDelegate:self];
    self.search.searchBarStyle=UISearchBarIconSearch;
    [self.search setPlaceholder:@"Search Transaction History"];
    [self.view addSubview:self.search];
    
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

    NSUserDefaults * defaults = [[NSUserDefaults alloc]init];

    if ([defaults boolForKey:@"hasPendingItems"] == true)
    {
        [completed_pending setSelectedSegmentIndex:1];
        
        [self.navigationItem setRightBarButtonItem:filt animated:NO ];
        
        UILabel *glyph_checkmark = [UILabel new];
        [glyph_checkmark setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_checkmark setFrame:CGRectMake(21, 12, 22, 16)];
        [glyph_checkmark setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
        [glyph_checkmark setTextColor: kNoochBlue];
        [self.view addSubview:glyph_checkmark];
        
        UILabel *glyph_pending = [UILabel new];
        [glyph_pending setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_pending setFrame:CGRectMake(178, 12, 20, 16)];
        [glyph_pending setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
        [glyph_pending setTextColor: [UIColor whiteColor]];
        [self.view addSubview:glyph_pending];
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];

        subTypestr = @"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        countRows = 0;
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];

    }
    else
    {
        subTypestr = @"";
        self.completed_selected = YES;

        UIButton *glyph_map = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [glyph_map setStyleId:@"glyph_map"];
        [glyph_map setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        glyph_map.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [glyph_map setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"] forState:UIControlStateNormal];
        [glyph_map addTarget:self action:@selector(toggleMapByNavBtn) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *map = [[UIBarButtonItem alloc] initWithCustomView:glyph_map];
        
        NSArray *topRightBtns = @[map,filt];
        [self.navigationItem setRightBarButtonItems:topRightBtns animated:YES ];

        [completed_pending setSelectedSegmentIndex:0];
    
        UILabel * glyph_checkmark = [UILabel new];
        [glyph_checkmark setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_checkmark setFrame:CGRectMake(21, 12, 22, 16)];
        [glyph_checkmark setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
        [glyph_checkmark setTextColor:[UIColor whiteColor]];
        [self.view addSubview:glyph_checkmark];
        
        UILabel * glyph_pending = [UILabel new];
        [glyph_pending setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_pending setFrame:CGRectMake(178, 12, 20, 16)];
        [glyph_pending setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
        [glyph_pending setTextColor: kNoochBlue];
        [self.view addSubview:glyph_pending];
    
        SDImageCache * imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
    
        [self loadHist:@"ALL" index:index len:20 subType:subTypestr];
        
        // Row count for scrolling
        countRows = 0;
    }

    //Export History
    exportHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    [exportHistory setTitle:@"     Export History" forState:UIControlStateNormal];
    [exportHistory setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    exportHistory.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [exportHistory setFrame:CGRectMake(10, 420, 132, 31)];
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        [exportHistory setStyleClass:@"exportHistorybutton"];
    }
    else {
        [exportHistory setStyleClass:@"exportHistorybutton_4"];
    }
    
    UILabel *glyph = [UILabel new];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
    [glyph setFrame:CGRectMake(7, 1, 15, 30)];
    [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-download"]];
    [glyph setTextColor:[UIColor whiteColor]];
    [exportHistory addSubview:glyph];
    [exportHistory addTarget:self action:@selector(ExportHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportHistory];
    [self.view bringSubviewToFront:exportHistory];
    
    
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideright:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer * recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideleft:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer2];
    
    mapArea = [[UIView alloc]initWithFrame:CGRectMake(0, 84, 320, self.view.frame.size.height)];
    [mapArea setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mapArea];
    [self.view bringSubviewToFront:self.list];
    
    // Google map
    camera = [GMSCameraPosition cameraWithLatitude:39.952360
                                         longitude:-75.163602
                                              zoom:8];
    mapView_ = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.delegate=self;
    [mapArea addSubview:mapView_];
}

-(void)toggleMapByNavBtn
{
    if (!self.completed_selected) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    
    if (!isMapOpen) {
        self.list.frame = CGRectMake(-276, 84, 320, self.view.frame.size.height);
        mapArea.frame = CGRectMake(0, 84,320,self.view.frame.size.height);
        isMapOpen = YES;
        [self mapPoints];
    }
    else {
        self.list.frame = CGRectMake(0, 84, 320, self.view.frame.size.height);
        [self.view bringSubviewToFront:self.list];
        mapArea.frame = CGRectMake(0, 84,320,self.view.frame.size.height);
        isMapOpen = NO;
    }
    [UIView commitAnimations];
    [self.view bringSubviewToFront:exportHistory];
    
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
-(void)sideleft:(id)sender
{
    if (!self.completed_selected) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    self.list.frame=CGRectMake(-276, 84, 320, self.view.frame.size.height);
    mapArea.frame=CGRectMake(0, 84,320,self.view.frame.size.height);
    [UIView commitAnimations];
    isMapOpen=YES;
    [self mapPoints];
    [self.view bringSubviewToFront:exportHistory];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSDictionary*dictRecord=[histArrayCommon objectAtIndex:[[marker title]intValue]];
    TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
    [self.navigationController pushViewController:details animated:YES];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 226)];
    customView.layer.borderColor = [[UIColor whiteColor]CGColor];
    customView.layer.borderWidth = 1.0f;
    customView.layer.cornerRadius = 6;
    [customView setStyleClass:@"raised_view"];
//    customView.layer.shadowOffset = CGSizeMake(1,2);
//    customView.layer.shadowRadius = 3.0f;
    customView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mapBack.png"]];

    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(68, 10, 82, 82)];
    imgV.layer.cornerRadius = 41;
    imgV.layer.borderColor = [UIColor whiteColor].CGColor;
    imgV.layer.borderWidth = 2;
    imgV.clipsToBounds = YES;

    NSString*urlImage=[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Photo"];
    [imgV sd_setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
    [customView addSubview:imgV];

    NSString *TransactionType = @"";

    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(5, 94, 210, 17)];
    [lblTitle setStyleClass:@"historyMap_marker_title"];
    [customView addSubview:lblTitle];
    
    UILabel *lblName=[[UILabel alloc]initWithFrame:CGRectMake(2, 112, 216, 20)];
    lblName.text = [NSString stringWithFormat:@"%@ %@",[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"FirstName"] capitalizedString],[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"LastName"]];
    [lblName setStyleClass:@"historyMap_marker_name"];
    [customView addSubview:lblName];

    UILabel *lblAmt = [[UILabel alloc]initWithFrame:CGRectMake(5, 135, 210, 26)];
    lblAmt.text = [NSString stringWithFormat:@"$%.02f",[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Amount"] floatValue]];
    lblAmt.textColor = kNoochGreen;
    [lblAmt setStyleClass:@"historyMap_marker_amnt"];
    [customView addSubview:lblAmt];

    if (  [[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] != NULL &&
        ![[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] isKindOfClass:[NSNull class]] )
    {
        UILabel *lblmemo = [[UILabel alloc]initWithFrame:CGRectMake(1, 159, 218, 30)];
        [lblmemo setStyleClass:@"historyMap_marker_memo"];
        lblmemo.textColor = [UIColor lightGrayColor];
        lblmemo.numberOfLines = 2;
        lblmemo.text = [NSString stringWithFormat:@"\"%@\"",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]];
        
        if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] length] == 0)
        {
            lblmemo.text = @"";
        }
        
        [customView addSubview:lblmemo];
    }
    
    UILabel *lblloc = [[UILabel alloc]initWithFrame:CGRectMake(15, 188, 190, 15)];
    lblloc.textColor = [UIColor whiteColor];
    [lblloc setStyleClass:@"historyMap_marker_dateIntro"];
    [customView addSubview:lblloc];

    NSString *statusstr;
    
    
    if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"])
    {
        if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"MemberId"]])
        {
            TransactionType = @"Sent to:";
        }
        else {
            TransactionType = @"Payment From:";
        }
    }
    else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Request"])
    {
        if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]]valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"])
        {
            statusstr = @"Cancelled:";
            [lblloc setStyleClass:@"red_text"];
        }
        else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
            statusstr = @"Rejected:";
            [lblloc setStyleClass:@"red_text"];
        }
        else {
            statusstr = @"Pending:";
            [lblloc setStyleClass:@"green_text"];
        }
        
        if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"RecepientId"]])
        {
            TransactionType = @"Request Sent to:";
        }
        else {
            TransactionType = @"Request From:";
        }
        
        if (  [[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"InvitationSentTo"] != NULL &&
            ![[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]] )
        {
            [imgV setImage:[UIImage imageNamed:@"profile_picture.png"]];
            lblName.text = [NSString stringWithFormat:@"%@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"InvitationSentTo"]];
        }
    }
    else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Invite"]) {
        TransactionType = @"Sent To:";
        [imgV setImage:[UIImage imageNamed:@"profile_picture.png"]];
        statusstr = @"Invited on:";
        [lblloc setStyleClass:@"green_text"];
    }
    lblTitle.text = [NSString stringWithFormat:@"%@",TransactionType];

    if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Donation"] ||
             [[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Sent"]     ||
             [[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Received"] ||
             [[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Transfer"] )
    {
        statusstr = @"Completed on:";
        [lblloc setStyleClass:@"green_text"];
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //Set the AM and PM symbols
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    
    NSDate *yourDate = [dateFormatter dateFromString:[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionDate"]];
    dateFormatter.dateFormat = @"dd-MMMM-yyyy";
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];

    //nslog(@"%@",[dateFormatter stringFromDate:yourDate]);
    NSArray*arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];

    if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Request"])
    {
        [lblloc setText:[NSString stringWithFormat:@"%@",statusstr]];
        
        UILabel *datelbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 198, 200, 22)];
        [datelbl setTextColor:[UIColor lightGrayColor]];
        [customView addSubview:datelbl];
        [datelbl setStyleClass:@"historyMap_marker_date"];
        datelbl.text = [NSString stringWithFormat:@"Sent on %@ %@, %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]];
    }
    else {
        [lblloc setText:[NSString stringWithFormat:@"%@ %@ %@, %@",statusstr,[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]]];
    }

return customView;    
}

-(void)mapPoints
{
    if (self.completed_selected)
    {
        if ([histShowArrayCompleted count] == 0) {
            [mapView_ clear];

            return;
        }
        histArrayCommon=[histShowArrayCompleted copy];
    }
    else
    {
        if ([histShowArrayPending count] == 0) {
            [mapView_ clear];

            return;
        }
        histArrayCommon=[histShowArrayPending copy];
    }
    [mapView_ clear];

    for (int i = 0; i < histArrayCommon.count; i++)
    {

        NSDictionary *tempDict = [histArrayCommon objectAtIndex:i];
        markerOBJ = [[GMSMarker alloc] init];
        markerOBJ.position = CLLocationCoordinate2DMake([[tempDict objectForKey:@"Latitude"] floatValue], [[tempDict objectForKey:@"Longitude"] floatValue]);
        [markerOBJ setTitle:[NSString stringWithFormat:@"%d",i]];

        if ( [[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"] &&
             [[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:i] valueForKey:@"MemberId"]] )
        {
            markerOBJ.icon = [UIImage imageNamed:@"blue-pin.png"];
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"] &&
                 [[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:i] valueForKey:@"RecepientId"]])
        {
            markerOBJ.icon = [UIImage imageNamed:@"orange-pin.png"];
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Requested"])
        {
            markerOBJ.icon = [UIImage imageNamed:@"green-pin.png"];
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Donation"]) {
            markerOBJ.icon=[UIImage imageNamed:@"red-pin.png"];
        }
        
        markerOBJ.map = mapView_;
    }
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
        //Rlease memory cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        countRows = 0;
        NSLog(@"ListType is: %@",listType);

        [self loadHist:listType index:index len:20 subType:subTypestr];
    }
    else
        isFilter=NO;
}

-(void)loadHist:(NSString*)filter index:(int)ind len:(int)len subType:(NSString*)subType
{
    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Loading Transaction History";
    [self.hud show:YES];
    [spinner1 startAnimating];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    isSearch = NO;
    isLocalSearch = NO;

    serve *serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"hist";
    [serveOBJ histMore:filter sPos:ind len:len subType:subTypestr];
    
}

#pragma mark - transaction type switching
- (void) completed_or_pending:(id)sender
{
    [self.list removeFromSuperview];
    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
    [self.list setDataSource:self];
    [self.list setDelegate:self];
    [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list];
    [self.list reloadData];
    [self.view bringSubviewToFront:exportHistory];
    
    [self.list setStyleId:@"history"];
    
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
        [self.navigationItem setRightBarButtonItems:topRightBtns animated:NO ];
        
        UILabel *glyph_checkmark = [UILabel new];
        [glyph_checkmark setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_checkmark setFrame:CGRectMake(21, 12, 22, 16)];
        [glyph_checkmark setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
        [glyph_checkmark setTextColor:[UIColor whiteColor]];
        [self.view addSubview:glyph_checkmark];
        
        UILabel *glyph_pending = [UILabel new];
        [glyph_pending setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_pending setFrame:CGRectMake(178, 12, 20, 16)];
        [glyph_pending setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
        [glyph_pending setTextColor: kNoochBlue];
        [self.view addSubview:glyph_pending];
        
        subTypestr = @"";
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        self.completed_selected = YES;
        countRows = 0;
        [self loadHist:@"ALL" index:1 len:28 subType:subTypestr];
    }
    else
    {
        [self.navigationItem setRightBarButtonItems:nil];
        UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [filter setStyleClass:@"label_filter"];
        [filter setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-filter"] forState:UIControlStateNormal];
        [filter setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        filter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];
        
        [self.navigationItem setRightBarButtonItem:filt animated:NO ];
        
        UILabel *glyph_checkmark = [UILabel new];
        [glyph_checkmark setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_checkmark setFrame:CGRectMake(21, 12, 22, 16)];
        [glyph_checkmark setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"]];
        [glyph_checkmark setTextColor: kNoochBlue];
        [self.view addSubview:glyph_checkmark];
        
        UILabel *glyph_pending = [UILabel new];
        [glyph_pending setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_pending setFrame:CGRectMake(178, 12, 20, 16)];
        [glyph_pending setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
        [glyph_pending setTextColor: [UIColor whiteColor]];
        [self.view addSubview:glyph_pending];

        subTypestr = @"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        countRows = 0;
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[Helpers hexColor:@"f8f8f8"]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section2
{
    if (self.completed_selected) {
        if (isLocalSearch) {
            return [histTempCompleted count]+1;
        }
        return [histShowArrayCompleted count]+1;
    }
    else {
        if (isLocalSearch) {
            return [histTempPending count]+1;
        }
        return [histShowArrayPending count]+1;
    }
    return 0;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
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
                    return 72;
                }
                else if ([[dictRecord_complete valueForKey:@"Memo"] length] > 32) {
                    return 85;
                }
                else
                   return 72;
            }
           
        }
        else if ([histTempCompleted count] == indexPath.row ||
                 [histShowArrayCompleted count] == 0)
        {
            return 200;
        }
    }
    else
    {
        if ([histShowArrayPending count] > indexPath.row) {
            return 80;
        }
    }

    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSLog(@"The cell is:  %@",cell);
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
    if (self.completed_selected)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier
                                      containingTableView:self.list // For row height and selection
                                       leftUtilityButtons:nil
                                      rightUtilityButtons:nil];
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
                if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                {
                    //cancel or remind
                    [rightUtilityButtons sw_addUtilityButtonWithColor:kNoochBlue
                                                                title:@"Remind"];
                    [rightUtilityButtons sw_addUtilityButtonWithColor:
                        [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                        title:@"Cancel"];
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
            reuseIdentifier:cellIdentifier
            containingTableView:self.list // For row height and selection
            leftUtilityButtons:leftUtilityButtons
            rightUtilityButtons:rightUtilityButtons];
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
       // UILabel * emptyText = nil;
        UILabel * emptyText_localSearch = nil;

//        UIImageView * emptyPic = [[UIImageView alloc] initWithFrame:CGRectMake(33, 105, 253, 256)];

        if (isLocalSearch)
        {
            if ([histTempCompleted count] > indexPath.row)
            {
                NSDictionary * dictRecord = [histTempCompleted objectAtIndex:indexPath.row];

                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]  ||
                    [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ||
                    [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]||
                    [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"] )
                {
                    
                    UIView *indicator = [UIView new];
                    
                    UILabel * statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(58, 8, 10, 11)];
                    [statusIndicator setBackgroundColor:[UIColor clearColor]];
                    [statusIndicator setTextAlignment:NSTextAlignmentCenter];
                    [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:10]];

                    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [amount setBackgroundColor:[UIColor clearColor]];
                    [amount setTextAlignment:NSTextAlignmentRight];
                    [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                    [amount setStyleClass:@"history_transferamount"];
                    
                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 9, 50, 50)];
                    pic.layer.cornerRadius = 25;
                    pic.clipsToBounds = YES;
                    [cell.contentView addSubview:pic];
                    
                    UILabel *transferTypeLabel = [UILabel new];
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
                    transferTypeLabel.layer.cornerRadius = 3;
                    transferTypeLabel .clipsToBounds = YES;
                    
                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];
                    
                    UILabel *glyphDate = [UILabel new];
                    [glyphDate setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
                    [glyphDate setFrame:CGRectMake(147, 9, 14, 10)];
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
                    else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]) {
                        [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"]];
                        [statusIndicator setTextColor:kNoochGreen];
                    }

                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"])
                    {
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                        {
                            // Sent Transfer
                            [amount setStyleClass:@"history_transferamount_neg"];
                            [indicator setStyleClass:@"history_sidecolor_neg"];
                            [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                            [transferTypeLabel setText:@"Transfer to"];
                            [transferTypeLabel setBackgroundColor:kNoochRed];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                            [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                        else
                        {
                            if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"])
                            {
                                // Received Transfer
                                [amount setStyleClass:@"history_transferamount_pos"];
                                [indicator setStyleClass:@"history_sidecolor_pos"];
                                [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                                [transferTypeLabel setText:@"Transfer from"];
                                [transferTypeLabel setBackgroundColor:kNoochGreen];
                                [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                                [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                    placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                            }
                        }
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                    {
                        [amount setTextColor:kNoochGrayDark];
                        [indicator setStyleClass:@"history_sidecolor_neutral"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]])
                        {
                            [transferTypeLabel setText:@"Request sent to"];
                            [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_wider"];
                            
                            if ([dictRecord valueForKey:@"InvitationSentTo"] == NULL || [[dictRecord objectForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]])
                            {
                                [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                                [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                    placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                            }
                            else
                            {
                                [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"] ]];
                                [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
                            }
                        }
                        else
                        {
                            [transferTypeLabel setText:@"Request from"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                            [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                        [transferTypeLabel setBackgroundColor:kNoochBlue];
                        
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
                              [dictRecord valueForKey:@"InvitationSentTo"] != NULL)
                    {
                        //ADDED BY CLIFF
                        if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                            [amount setTextColor:kNoochGrayDark];
                            [indicator setStyleClass:@"history_sidecolor_neutral"];
                            [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        }
                        else {
                            [amount setStyleClass:@"history_transferamount_neg"];
                            [indicator setStyleClass:@"history_sidecolor_neg"];
                            [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        }
                        [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
                        [transferTypeLabel setText:@"Invite sent to"];
                        [transferTypeLabel setBackgroundColor:kNoochGrayLight];
                        [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"]]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"])
                    {
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                        {
                            [transferTypeLabel setText:@"You disputed a transfer to"];
                        }
                        else {
                            [transferTypeLabel setText:@"Transfer disputed by"];
                        }

                        [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_evenWider"];
                        [transferTypeLabel setBackgroundColor:Rgb2UIColor(108, 109, 111, 1)];
                        [date setStyleClass:@"history_datetext_wide"];
                        [glyphDate setFrame:CGRectMake(173, 9, 14, 10)];
                        [indicator setStyleClass:@"history_sidecolor_neutral"];
                        [amount setTextColor:kNoochGrayDark];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
                    
                    [cell.contentView addSubview:amount];
                    [cell.contentView addSubview:statusIndicator];
                    [cell.contentView addSubview:transferTypeLabel];
                    [cell.contentView addSubview:name];

                    //  'updated_balance' now for displaying transfer STATUS, only if status is "cancelled" or "rejected" or "success" (for invites)
                    //  (this used to display the user's updated balance, which no longer exists)
                    
                    UILabel *updated_balance = [UILabel new];
                    
                    if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ||
                        [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"])
                    {
                        [updated_balance setStyleClass:@"transfer_status"];
                        [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                        [updated_balance setTextColor:kNoochGrayLight];
                        [cell.contentView addSubview:updated_balance];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] &&
                             [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] )
                    {
                        [updated_balance setText:@"Accepted"];
                        [updated_balance setStyleClass:@"transfer_status"];
                        [updated_balance setTextColor:kNoochGreen];
                        [cell.contentView addSubview:updated_balance];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] &&
                             [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"])
                    {
                        [updated_balance setStyleClass:@"transfer_status"];
                        [updated_balance setText:@"Resolved"];
                        [updated_balance setTextColor:kNoochGreen];
                        [cell.contentView addSubview:updated_balance];
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
                    else if ((long)[components day] == 0) {
                        NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit 
                                fromDate:addeddate
                                toDate:ServerDate      
                                options:0];
                        if ((long)[components hour] == 0) {
                            NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit
                                fromDate:addeddate
                                toDate:ServerDate
                                options:0];
                            if ((long)[components minute]==0) {
                                NSDateComponents *components = [gregorianCalendar components:NSSecondCalendarUnit                                
                                    fromDate:addeddate
                                    toDate:ServerDate
                                    options:0];
                                [date setText:[NSString stringWithFormat:@"%ld seconds ago",(long)[components second]]];
                                [cell.contentView addSubview:date];
                            }
                            else if ((long)[components minute]==1) {
                                [date setText:[NSString stringWithFormat:@"%ld minute ago",(long)[components minute]]];
                            }
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
                        if ((long)[components day]==1) {
                            [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                        }
                        else
                            [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                        [cell.contentView addSubview:date];
                    }

                    if ( [dictRecord valueForKey:@"Memo"] != NULL &&
                        ![[dictRecord objectForKey:@"Memo"] isKindOfClass:[NSNull class]] &&
                        ![[dictRecord valueForKey:@"Memo"] isEqualToString:@""] )
                    {
                        UILabel *label_memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                        [label_memo setBackgroundColor:[UIColor clearColor]];
                        [label_memo setTextAlignment:NSTextAlignmentRight];
                        label_memo.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"For  \"%@\" ",[dictRecord valueForKey:@"Memo"]]
                                                                                    attributes:nil];
                        label_memo.numberOfLines = 0;
                        label_memo.lineBreakMode = NSLineBreakByTruncatingTail;
                        [label_memo setStyleClass:@"history_memo"];
                        
                        if (label_memo.attributedText.length > 36) {
                            [label_memo setStyleClass:@"history_memo_long"];
                        }
                        [cell.contentView addSubview:label_memo];
                        [name setStyleClass:@"history_cell_textlabel_wMemo"];                    }
                }
            }
            else if ([histTempCompleted count] == indexPath.row)
            {
                if ([self.list subviews]) {
                    for (UILabel * subview in [self.list subviews]) {
                        [subview removeFromSuperview];
                    }
                }

                [self.list setStyleId:@"emptyTable"];

               // if (indexPath.row == 0) {
                
                    emptyText_localSearch = [[UILabel alloc] initWithFrame:CGRectMake(6, 5, 308, 70)];
                    [emptyText_localSearch setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
                    [emptyText_localSearch setNumberOfLines:0];
                    [emptyText_localSearch setText:@"No payments found for that name."];
                    [emptyText_localSearch setTextAlignment:NSTextAlignmentCenter];
            /*  }
                else {
                    [emptyText_localSearch setText:@""];
				} */
                
                [self.list addSubview:emptyText_localSearch];
            }
            return cell;
        }
        
        if ([histShowArrayCompleted count] > indexPath.row)
        {
            NSDictionary *dictRecord = [histShowArrayCompleted objectAtIndex:indexPath.row];

            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]  ||
                [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ||
                [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]||
                [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"] )
            {

                UIView * indicator = [UIView new];
                
                UILabel * statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(58, 8, 10, 11)];
                [statusIndicator setBackgroundColor:[UIColor clearColor]];
                [statusIndicator setTextAlignment:NSTextAlignmentCenter];
                [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:10]];

                UILabel * amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                [amount setBackgroundColor:[UIColor clearColor]];
                [amount setTextAlignment:NSTextAlignmentRight];
                [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                [amount setStyleClass:@"history_transferamount"];
                
                UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 9, 50, 50)];
                pic.layer.cornerRadius = 25;
                pic.clipsToBounds = YES;
                [cell.contentView addSubview:pic];
                
				UILabel *transferTypeLabel = [UILabel new];
                [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
                transferTypeLabel.layer.cornerRadius = 3;
                transferTypeLabel .clipsToBounds = YES;
                
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];

                UILabel *date = [UILabel new];
                [date setStyleClass:@"history_datetext"];

                UILabel *glyphDate = [UILabel new];
                [glyphDate setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
                [glyphDate setFrame:CGRectMake(147, 9, 14, 10)];
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
                else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]) {
                    [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"]];
                    [statusIndicator setTextColor:kNoochGreen];
                }
                
                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"])
                {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                    {
                        // Sent Transfer
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        [transferTypeLabel setText:@"Transfer to"];
						[transferTypeLabel setBackgroundColor:kNoochRed];
                        [name setText:[NSString stringWithFormat:@"%@",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
                    else
                    {
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"])
                        {
                            // Received Transfer
                            [amount setStyleClass:@"history_transferamount_pos"];
                            [indicator setStyleClass:@"history_sidecolor_pos"];
                            [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                            [transferTypeLabel setText:@"Transfer from"];
                            [transferTypeLabel setBackgroundColor:kNoochGreen];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                            [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                    }
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                {
                    [amount setTextColor:kNoochGrayDark];
                    [indicator setStyleClass:@"history_sidecolor_neutral"];
                    [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];

                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]])
                    {
                        [transferTypeLabel setText:@"Request sent to"];
                        [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_wider"];
                        
                        if ([dictRecord valueForKey:@"InvitationSentTo"] == NULL || [[dictRecord objectForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]])
                        {
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                            [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                        else
                        {
                            [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"] ]];
                            [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                    }
                    else
                    {
                        [transferTypeLabel setText:@"Request from"];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
					[transferTypeLabel setBackgroundColor:kNoochBlue];
                
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
                          [dictRecord valueForKey:@"InvitationSentTo"] != NULL)
                {
                    //ADDED BY CLIFF
                    if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                        [amount setTextColor:kNoochGrayDark];
                        [indicator setStyleClass:@"history_sidecolor_neutral"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    else {
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
                    [transferTypeLabel setText:@"Invite sent to"];
					[transferTypeLabel setTextColor:kNoochGrayDark];
                    [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"]]];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"])
                {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                    {
                        [transferTypeLabel setText:@"You disputed a transfer to"];
                    }
                    else {
                        [transferTypeLabel setText:@"Transfer disputed by"];
                    }
                    
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_evenWider"];
                    [transferTypeLabel setBackgroundColor:Rgb2UIColor(108, 109, 111, 1)];
                    [date setStyleClass:@"history_datetext_wide"];
                    [glyphDate setFrame:CGRectMake(173, 9, 14, 10)];
                    [indicator setStyleClass:@"history_sidecolor_neutral"];
                    [amount setTextColor:kNoochGrayDark];
                    [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                    [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                }

				//  'updated_balance' now for displaying transfer STATUS, only if status is "cancelled" or "rejected"
                //  (this used to display the user's updated balance, which no longer exists)
                
                UILabel *updated_balance = [UILabel new];
                
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ||
                    [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"])
                {
                    [updated_balance setStyleClass:@"transfer_status"];
                    [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                    [updated_balance setTextColor:kNoochGrayLight];
                    [cell.contentView addSubview:updated_balance];
                }
                else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] &&
                         [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] )
                {
                    [updated_balance setText:@"Accepted"];
                    [updated_balance setStyleClass:@"transfer_status"];
                    [updated_balance setTextColor:kNoochGreen];
                    [cell.contentView addSubview:updated_balance];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] &&
                         [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"])
                {
                    [updated_balance setStyleClass:@"transfer_status"];
                    [updated_balance setText:@"Resolved"];
                    [updated_balance setTextColor:kNoochGreen];
                    [cell.contentView addSubview:updated_balance];
                }

                NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
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

                    NSArray*arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
                    [date setText:[NSString stringWithFormat:@"%@ %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0]]];
                    [cell.contentView addSubview:date];
                }
                else if ((long)[components day] == 0)
                {
                    NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                    if ((long)[components hour] == 0) {
                        NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                        if ((long)[components minute] == 0) {
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
                    else {
                        if ((long)[components hour] == 1)
                            [date setText:[NSString stringWithFormat:@"%ld hour ago",(long)[components hour]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                        [cell.contentView addSubview:date];
                    }
                }
                else {
                    if ((long)[components day] == 1)
                        [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                    else
                        [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                    [cell.contentView addSubview:date];
                }
                
                if ( [dictRecord valueForKey:@"Memo"] != NULL &&
                    ![[dictRecord objectForKey:@"Memo"] isKindOfClass:[NSNull class]] &&
                    ![[dictRecord valueForKey:@"Memo"] isEqualToString:@""] )
                {
                    UILabel *label_memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [label_memo setBackgroundColor:[UIColor clearColor]];
                    [label_memo setTextAlignment:NSTextAlignmentRight];
                    label_memo.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"For  \"%@\" ",[dictRecord valueForKey:@"Memo"]]
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

                [cell.contentView addSubview:glyphDate];
                [cell.contentView addSubview:amount];
                [cell.contentView addSubview:statusIndicator];
                [cell.contentView addSubview:transferTypeLabel];
                [cell.contentView addSubview:name];

            }
        }
        else if (indexPath.row == [histShowArrayCompleted count])
        {
            if (isEnd == YES)
            {
                if ([histShowArrayCompleted count]==0) {
                    UILabel * emptyText = nil;
                    UIImageView * emptyPic = [[UIImageView alloc] initWithFrame:CGRectMake(33, 105, 253, 256)];
                    
                    [self.list setStyleId:@"emptyTable"];
                    
                    if ([[UIScreen mainScreen] bounds].size.height < 500)
                    {
                        emptyText = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, 304, 56)];
                        [emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:18]];
                        [emptyPic setFrame:CGRectMake(33, 78, 253, 256)];
                    } else {
                        emptyText = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 72)];
                        [emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
                    }
                    [emptyText setNumberOfLines:0];
                    [emptyText setText:@"Once you make or receive a payment, come here to see all the details."];
                    [emptyText setTextAlignment:NSTextAlignmentCenter];
                    
                    [emptyPic setImage:[UIImage imageNamed:@"history_img"]];
                    [emptyPic setStyleClass:@"animate_bubble"];
                    
                    [self.list  addSubview: emptyPic];
                    [self.list  addSubview: emptyText];
                    
                    [exportHistory removeFromSuperview];
                    
                    
                }
                
//                [self.list setStyleId:@"emptyTable"];
//
//                if ([[UIScreen mainScreen] bounds].size.height < 500)
//                {
//                    emptyText = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, 304, 56)];
//                    [emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:18]];
//                    [emptyPic setFrame:CGRectMake(33, 78, 253, 256)];
//                } else {
//                    emptyText = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 72)];
//                    [emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
//                }
//                [emptyText setNumberOfLines:0];
//                [emptyText setText:@"Once you make or receive a payment, come here to see all the details."];
//                [emptyText setTextAlignment:NSTextAlignmentCenter];
//
//                [emptyPic setImage:[UIImage imageNamed:@"history_img"]];
//                [emptyPic setStyleClass:@"animate_bubble"];
//
//                [self.list addSubview: emptyPic];
//                [self.list addSubview: emptyText];
//
//                [exportHistory removeFromSuperview];
            }
            else
            {
                if (isSearch)
                {
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                    ishistLoading = YES;
                    index++;
                    [self loadSearchByName];
                }
                else
                {
                    if (indexPath.row > 6)
                    {
                        ishistLoading=YES;
                        index++;
                        [self loadHist:listType index:index len:20 subType:subTypestr];
                    }
                }
            }
        }
    }
                
    else if (self.completed_selected == NO)
    {
//        UILabel * emptyText_Pending = nil;

        if (isLocalSearch)
        {
            if ([histTempPending count] > indexPath.row)
            {
                NSDictionary * dictRecord = [histTempPending objectAtIndex:indexPath.row];

                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"])
                {
                    UILabel * indicator = [[UILabel alloc] initWithFrame:CGRectMake(0, 311, 9, 72)];
                    [indicator setBackgroundColor:[UIColor clearColor]];
                    [indicator setFont:[UIFont fontWithName:@"FontAwesome" size:13]];
                    [indicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-caret-left"]];
                    [indicator setStyleClass:@"history_sidecolor_pending"];

                    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [amount setBackgroundColor:[UIColor clearColor]];
                    [amount setTextAlignment:NSTextAlignmentRight];
                    [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                    [amount setStyleClass:@"history_pending_transferamount"];

                    [amount setStyleClass:@"history_transferamount_neutral"];
                    [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    [cell.contentView addSubview:amount];

                    UILabel *transferTypeLabel = [UILabel new];
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
                    transferTypeLabel.layer.cornerRadius = 3;
                    transferTypeLabel .clipsToBounds = YES;

                    UILabel * statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(58, 8, 10, 11)];
                    [statusIndicator setBackgroundColor:[UIColor clearColor]];
                    [statusIndicator setTextAlignment:NSTextAlignmentCenter];
                    [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
                    [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle-o"]];
                    [statusIndicator setTextColor:kNoochBlue];
                    [cell.contentView addSubview:statusIndicator];

                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 9, 50, 50)];
                    pic.layer.cornerRadius = 25;
                    pic.clipsToBounds = YES;
                    [cell.contentView addSubview:pic];
                    [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];

                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    [name setStyleClass:@"history_recipientname"];
                    
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];
                    
                    UILabel *glyphDate = [UILabel new];
                    [glyphDate setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
                    [glyphDate setFrame:CGRectMake(147, 9, 14, 10)];
                    [glyphDate setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
                    [glyphDate setTextColor:kNoochGrayLight];
                    [cell.contentView addSubview:glyphDate];
					
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                    {
                        if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                        {
                            [transferTypeLabel setText:@"Request sent to"];
                            [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_wider"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                        }
                        else {
                            [transferTypeLabel setText:@"Request from"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                        }
                        [transferTypeLabel setBackgroundColor:kNoochBlue];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL)
                    {
                        [transferTypeLabel setText:@"Invite sent to"];
                        [transferTypeLabel setBackgroundColor:kNoochGrayDark];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] )
                    {
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                        {
                            [transferTypeLabel setText:@"You disputed a transfer to"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                        }
                        else {
                            [transferTypeLabel setText:@"Transfer disputed by"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                        }
                        
                        [statusIndicator setTextColor:kNoochRed];
                        [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_evenWider"];
                        [date setStyleClass:@"history_datetext_wide"];
                        [glyphDate setFrame:CGRectMake(173, 9, 14, 10)];
                        [transferTypeLabel setBackgroundColor:kNoochRed];
                    }

                    else {
                        [name setText:@""];
                    }
                    
                    [cell.contentView addSubview:transferTypeLabel];
                    [cell.contentView addSubview:name];

                    NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                           fromDate:addeddate                                               
                           toDate:ServerDate
                           options:0];
                    if ((long)[components day]>3)
                    {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                         [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                        //Set the AM and PM symbols
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
                        if ((long)[components hour]==0) {
                            NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit                            
                                    fromDate:addeddate
                                    toDate:ServerDate
                                    options:0];
                            if ((long)[components minute]==0) {
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
                    else
                    {
                        if ((long)[components day]==1)
                            [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                        [cell.contentView addSubview:date];
                    }
                    
                    if ( [dictRecord valueForKey:@"Memo"] != NULL &&
                        ![[dictRecord objectForKey:@"Memo"] isKindOfClass:[NSNull class]] &&
                        ![[dictRecord valueForKey:@"Memo"] isEqualToString:@""] )
                    {
                        UILabel *label_memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                        [label_memo setBackgroundColor:[UIColor clearColor]];
                        [label_memo setTextAlignment:NSTextAlignmentRight];
                        label_memo.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"For  \"%@\" ",[dictRecord valueForKey:@"Memo"]]
                                                                                    attributes:nil];
                        label_memo.numberOfLines = 0;
                        label_memo.lineBreakMode = NSLineBreakByTruncatingTail;
                        [label_memo setStyleClass:@"history_memo"];
                        
                        if (label_memo.attributedText.length > 42) {
                            [label_memo setStyleClass:@"history_memo_long"];
                        }
                        [cell.contentView addSubview:label_memo];
                        [name setStyleClass:@"history_cell_textlabel_wMemo"];
                    }
                    [cell.contentView addSubview:indicator];

                }
            }

            else if (indexPath.row == [histTempPending count])
            {
                [self.list setStyleId:@"emptyTable"];
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabelEmpty"];
                [name setStyleClass:@"history_recipientname"];

                if (indexPath.row == 0) {
                    [name setText:@"No pending payments found."];
				}
				else {
                    [name setText:@""];
                }
				[cell.contentView addSubview:name];
            }
            return cell;
        }

        if ([histShowArrayPending count] > indexPath.row)
        {
            NSDictionary *dictRecord = [histShowArrayPending objectAtIndex:indexPath.row];
            
            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"])
            {
				UILabel * indicator = [[UILabel alloc] initWithFrame:CGRectMake(0, 311, 9, 72)];
                [indicator setBackgroundColor:[UIColor clearColor]];
                [indicator setFont:[UIFont fontWithName:@"FontAwesome" size:13]];
                [indicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-caret-left"]];
                [indicator setStyleClass:@"history_sidecolor_pending"];

                UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                [amount setBackgroundColor:[UIColor clearColor]];
                [amount setTextAlignment:NSTextAlignmentRight];
                [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                [amount setStyleClass:@"history_pending_transferamount"];
                [amount setStyleClass:@"history_transferamount_neutral"];
                [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];

                UILabel *transferTypeLabel = [UILabel new];
                [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
                transferTypeLabel.layer.cornerRadius = 3;
                transferTypeLabel .clipsToBounds = YES;

                UILabel * statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(58, 8, 10, 11)];
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
                [glyphDate setFrame:CGRectMake(147, 9, 14, 10)];
                [glyphDate setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
                [glyphDate setTextColor:kNoochGrayLight];
                [cell.contentView addSubview:glyphDate];

                UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 9, 50, 50)];
                pic.layer.cornerRadius = 25;
                pic.clipsToBounds = YES;

                UILabel *label_memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                if ( [dictRecord valueForKey:@"Memo"] != NULL &&
                    ![[dictRecord objectForKey:@"Memo"] isKindOfClass:[NSNull class]] &&
                    ![[dictRecord valueForKey:@"Memo"] isEqualToString:@""] )
                {
                    
                    [label_memo setBackgroundColor:[UIColor clearColor]];
                    [label_memo setTextAlignment:NSTextAlignmentRight];
                    label_memo.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"For  \"%@\" ",[dictRecord valueForKey:@"Memo"]]
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
                    if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                    {
                        
                        [transferTypeLabel setText:@"Request sent to"];
                        [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_wider"];

                        if ([dictRecord valueForKey:@"InvitationSentTo"] == NULL || [[dictRecord objectForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]])
                        {
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                            [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                        else
                        {
                            [name setText:[NSString stringWithFormat:@"%@ ",[dictRecord valueForKey:@"InvitationSentTo"] ]];
                            [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
                        }
                    }
                    else
                    {
                        UIView * bgcolor = [[UIView alloc] init];
                        bgcolor.backgroundColor = Rgb2UIColor(240, 250, 30, .4);
                        
                        if (label_memo.attributedText.length > 42) {
                            [bgcolor setFrame:CGRectMake(0, 0, 320, 76)];
                        }
                        cell.backgroundView = bgcolor;
                        [cell.contentView addSubview:bgcolor];
                        
                        [transferTypeLabel setText:@"Request from"];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                        [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                    }
                    [transferTypeLabel setBackgroundColor:kNoochBlue];
                }
                
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL)
                {
                        [transferTypeLabel setText:@"You invited"];
                        [transferTypeLabel setBackgroundColor:kNoochGrayLight];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                        [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
                }
                
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"])
                {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                    {
                        [transferTypeLabel setText:@"You disputed a transfer to"];
                    }
                    else {
                        [transferTypeLabel setText:@"Transfer disputed by"];
                    }
                    [statusIndicator setTextColor:kNoochRed];
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_evenWider"];
                    [date setStyleClass:@"history_datetext_wide"];
                    [glyphDate setFrame:CGRectMake(173, 9, 14, 10)];
                    [transferTypeLabel setBackgroundColor:kNoochRed];
                    [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                    [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                }
                else {
                    [name setText:@""];
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
                    if ((long)[components hour]==0) {
                        NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit                  
                                    fromDate:addeddate
                                    toDate:ServerDate
                                    options:0];
                        if ((long)[components minute]==0) {
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
                [cell.contentView addSubview:indicator];
                [cell.contentView addSubview:transferTypeLabel];
                [cell.contentView addSubview:name];
                [cell.contentView addSubview:pic];
                [cell.contentView addSubview:label_memo];

			}
        }
        else if (indexPath.row == [histShowArrayPending count])
        {
            if (isEnd == YES)
            {
                if ([histShowArrayPending count]==0)
                {
                    UILabel * emptyText_Pending = nil;
                    
                    [self.list setStyleId:@"emptyTable"];
                    emptyText_Pending = [[UILabel alloc] initWithFrame:CGRectMake(6, 5, 308, 70)];
                    [emptyText_Pending setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
                    [emptyText_Pending setNumberOfLines:0];
                    [emptyText_Pending setText:@"No payments found for you at the moment."];
                    [emptyText_Pending setTextAlignment:NSTextAlignmentCenter];
                    [self.list addSubview:emptyText_Pending];
                    
                }
                
//                [self.list setStyleId:@"emptyTable"];
//                emptyText_Pending = [[UILabel alloc] initWithFrame:CGRectMake(6, 5, 308, 70)];
//                [emptyText_Pending setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
//                [emptyText_Pending setNumberOfLines:0];
//                [emptyText_Pending setText:@"No payments found for you at the moment."];
//                [emptyText_Pending setTextAlignment:NSTextAlignmentCenter];
//                [self.list addSubview:emptyText_Pending];

                return cell;
            }
            else if (isStart == YES)
            {}
            else
            {
                if (isSearch)
                {
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                    ishistLoading = YES;
                    index++;
                    [self loadSearchByName];
                }
                else
                {
                    if (indexPath.row > 5)
                    {
                        ishistLoading=YES;
                        index++;
                        [self loadHist:listType index:index len:20 subType:subTypestr];
                    }
                }
            }
        }
    }
    
    //NSLog(@"The CELL is:  %@",cell);

    return cell;
}

#pragma mark- Date From String
- (NSDate*) dateFromString:(NSString*)aStr
{   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"M/dd/yyyy hh:mm:ss a";
    
    NSDate   *aDate = [dateFormatter dateFromString:aStr];
    return aDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.completed_selected)
    {
        if (isLocalSearch)
        {
            NSDictionary *dictRecord = [histTempCompleted objectAtIndex:indexPath.row];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
            return;
        }
        if ([histShowArrayCompleted count]>indexPath.row)
        {
            NSDictionary *dictRecord = [histShowArrayCompleted objectAtIndex:indexPath.row];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
        }
    }
    else
    {
        if (isLocalSearch)
        {
            NSDictionary *dictRecord=[histTempPending objectAtIndex:indexPath.row];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
            return;
        }
        if ([histShowArrayPending count] > indexPath.row)
        {
            NSDictionary *dictRecord=[histShowArrayPending objectAtIndex:indexPath.row];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
        }
    }

}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)ind
{
    NSMutableArray *temp;

    if (isLocalSearch) {
        temp = [histTempPending mutableCopy];
    }
    else {
        temp = [histShowArrayPending mutableCopy];
    }
    NSDictionary * dictRecord = [temp objectAtIndex:[self.list indexPathForCell:cell].row];

    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
    {
        if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
        { // For the Sender of a Request

			if ( [dictRecord valueForKey:@"InvitationSentTo"] == NULL ||
                [[dictRecord valueForKey:@"InvitationSentTo"]  isKindOfClass:[NSNull class]] )
            {
                if (ind == 0)
                {  //remind
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"COMING SOON" message:@"Send a reminder about this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                    [av show];
//                    [av setTag:1012];
                }
                else
                {  //cancel
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel This Request" message:@"Are you sure you want to cancel this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                    [av show];
                    [av setTag:1010];
                }
            }
            else {
                if (ind == 0)
                { //remind
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"COMING SOON" message:@"Send a reminder about this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                    [av show];
//                    [av setTag:2012];
                }
                else
                {  // cancel
                    self.responseDict = [dictRecord copy];
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel This Request" message:@"Are you sure you want to cancel this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                    [av show];
                    [av setTag:2010];
                }
            }
        }
        else
        {  // For the Recipient of a Request
            if (ind == 0)
            {
                //accept
                NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
                
                if ([[assist shared]getSuspended]) {
                    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Suspended" message:@"Your account has been suspended for 24 hours from now. Please email support@nooch.com if you believe this was a mistake and we will be glad to help." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
                    [alert setTag:50];
                    [alert show];
                    return; 
                }
                if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {   
                    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Email Verification Needed" message:@"Please click the link we emailed you to verify your email address." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                    [alert show];
                    return;
                }
                if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
                    
                        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Profile Not Complete" message:@"Please validate your profile by completing all fields. This helps us keep Nooch safe!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
                        [alert setTag:147];
                        [alert show];
                        return;
                }
                else if ( ![[[NSUserDefaults standardUserDefaults] objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
                    UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Please Attach an Account" message:@"Before you can send or receive money, you must add a bank account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                    [set show];
                    return;
                }
                else {
                NSMutableDictionary *input = [dictRecord mutableCopy];
                [input setValue:@"accept" forKey:@"response"];
               
                [[assist shared]setRequestMultiple:NO];
                TransferPIN *trans = [[TransferPIN alloc] initWithReceiver:input type:@"requestRespond" amount:[[dictRecord objectForKey:@"Amount"] floatValue]];
                [nav_ctrl pushViewController:trans animated:YES];
                }
            }
            else
            {
                //decline
                self.responseDict = [dictRecord copy];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Reject This Request" message:@"Are you sure you want to reject this request?" delegate:self cancelButtonTitle:@"Yes - Reject" otherButtonTitles:@"No", nil];
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
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"COMING SOON" message:@"Send a reminder about this transfer?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            [av show];
//            [av setTag:312];
        }
        else
        {  //cancel
            self.responseDict = [dictRecord copy];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel This Transfer" message:@"Are you sure you want to cancel this transfer?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
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

#pragma mark - SWTableView

#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO];
    [self.search resignFirstResponder];
    isSearch = NO;
    isFilter = NO;
    listType = @"ALL";
    [histShowArrayCompleted removeAllObjects];
    [histShowArrayPending removeAllObjects];
    self.search.text=@"";
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    countRows = 0;
    [self.search resignFirstResponder];
    [self loadHist:listType index:1 len:20 subType:subTypestr];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text length] > 0)
    {
        listType = @"ALL";
        SearchStirng = [self.search.text lowercaseString];
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

- (void) searchTableView
{
    [histTempCompleted removeAllObjects];
    [histTempPending removeAllObjects];
    if ([subTypestr isEqualToString:@"Pending"])
    {
        for (NSMutableDictionary *tableViewBind in histShowArrayPending)
        {
            NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            NSComparisonResult result2 = [[tableViewBind valueForKey:@"LastName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            if (result == NSOrderedSame || result2 == NSOrderedSame) {
                [histTempPending addObject:tableViewBind];
            }
        }
    }
    else
    {
        for (NSMutableDictionary *tableViewBind in histShowArrayCompleted)
        {
            NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            NSComparisonResult result2 = [[tableViewBind valueForKey:@"LastName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            if (result == NSOrderedSame || result2 == NSOrderedSame) {
                [histTempCompleted addObject:tableViewBind];
            }
        }
    }
    [self.list reloadData];
}

-(void)loadSearchByName
{
    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Searching History...";
    [self.hud show:YES];
    [spinner1 startAnimating];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    listType = @"ALL";
    isLocalSearch = NO;
    serve * serveOBJ = [serve new];
    serveOBJ.tagName = @"search";
    [serveOBJ setDelegate:self];
    [serveOBJ histMoreSerachbyName:listType sPos:index len:20 name:SearchStirng subType:subTypestr];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
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
        SearchStirng = [self.search.text lowercaseString];
        isEnd = YES;
        isFilter = NO;
        isLocalSearch = YES;
        [self searchTableView];
        [self.list reloadData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
}

#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    /* UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show]; */
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
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
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Export Successful" message:@"Your personalized transaction report has been emailed to you." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
    
    /* else if ([tagName isEqualToString:@"histPending"])
    {
        [self.hud hide:YES];
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([histArray count] > 0)
        {
            isEnd = NO;
            isStart = NO;
            int counter = 0;
            for (NSDictionary *dict in histArray)
            {
                if (![[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]&& ![[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"])
                {
                    if ( ([[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] && ![[dict valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"]) ||
                        (([[dict valueForKey:@"TransactionType"]isEqualToString:@"Invite"] || [[dict valueForKey:@"TransactionType"]isEqualToString:@"Request"]) &&
                          [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]))
                    {
                        [histShowArrayPending addObject:dict];
                        
                        if (![[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"]) {
                            counter++;
                        }
                    }
                }
            }
            [completed_pending setTitle:[NSString stringWithFormat:@"Pending (%d)",counter]forSegmentAtIndex:1];

        }
    }
*/
    else if ([tagName isEqualToString:@"hist"])
    {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
        });
        [self.hud hide:YES];
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
  
        
        if ([histArray count] > 0)
        {
            isEnd = NO;
            isStart = NO;
            int counter = 0;
            int pending_notif_counter = 0;
            for (NSDictionary *dict in histArray)
            {
                if ( [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]   ||
                     [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] ||
                     [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]  ||
                     ( [[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] &&
                       [[dict valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"]) )
                {
                    [histShowArrayCompleted addObject:dict];
                }

                // For the Pending Notification in the Completed/Pending Segmented Control on History Screen
                if (  ([[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] && ![[dict valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"]) ||
                     (([[dict valueForKey:@"TransactionType"]isEqualToString:@"Invite"] || [[dict valueForKey:@"TransactionType"]isEqualToString:@"Request"]) &&
                       [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]))
                {
                    [histShowArrayPending addObject:dict];
                
                       if (![[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"]) {
                            counter++;
                        }
                    }
                // For the Red Pending Notification Bubble in the left menu  (different than "counter" above, this one
                // doesn't include Invites, or Requests this user Sent)
                if ( ( [[dict valueForKey:@"TransactionType"]isEqualToString:@"Request"] &&
                      [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"] ) &&
                    ![[dict valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                {
                    pending_notif_counter++;
                }
            }
            
            NSUserDefaults * defaults = [[NSUserDefaults alloc]init];
            if (pending_notif_counter > 0) {
                [defaults setBool:true forKey:@"hasPendingItems"];
            }
            else {
                [defaults setBool:false forKey:@"hasPendingItems"];

            }
            [defaults setValue: [NSString stringWithFormat:@"%d",pending_notif_counter] forKey:@"Pending_count"];
            [defaults synchronize];
            
            // NSLog(@"The Pending counter is: %d",counter);
            [completed_pending setTitle:[NSString stringWithFormat:@"  Pending  (%d)",counter]forSegmentAtIndex:1];
            
            
        }
            if ([histShowArrayCompleted count]==0 && ![subTypestr isEqualToString:@"Pending"]) {
            isEnd = YES;
            
            }
            else if([histShowArrayPending count]==0 && [subTypestr isEqualToString:@"Pending"]){
                 isEnd = YES;
            }
        
        if (isMapOpen) {
            [self mapPoints];
        }
        serve * serveOBJ = [serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ setTagName:@"time"];
        [serveOBJ GetServerCurrentTime];

//            if ([histShowArrayCompleted count]==0 && ![subTypestr isEqualToString:@"Pending"]) {
//                UILabel * emptyText = nil;
//                UIImageView * emptyPic = [[UIImageView alloc] initWithFrame:CGRectMake(33, 105, 253, 256)];
//                
//                [self.list setStyleId:@"emptyTable"];
//                
//                if ([[UIScreen mainScreen] bounds].size.height < 500)
//                {
//                    emptyText = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, 304, 56)];
//                    [emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:18]];
//                    [emptyPic setFrame:CGRectMake(33, 78, 253, 256)];
//                } else {
//                    emptyText = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 72)];
//                    [emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
//                }
//                [emptyText setNumberOfLines:0];
//                [emptyText setText:@"Once you make or receive a payment, come here to see all the details."];
//                [emptyText setTextAlignment:NSTextAlignmentCenter];
//                
//                [emptyPic setImage:[UIImage imageNamed:@"history_img"]];
//                [emptyPic setStyleClass:@"animate_bubble"];
//                
//                [self.view  addSubview: emptyPic];
//                [self.view  addSubview: emptyText];
//                
//                [exportHistory removeFromSuperview];
//                
//
//            }
//            if ([histShowArrayPending count]==0 && [subTypestr isEqualToString:@"Pending"])
//                {
//                UILabel * emptyText_Pending = nil;
//
//                [self.list setStyleId:@"emptyTable"];
//                emptyText_Pending = [[UILabel alloc] initWithFrame:CGRectMake(6, 5, 308, 70)];
//                [emptyText_Pending setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
//                [emptyText_Pending setNumberOfLines:0];
//                [emptyText_Pending setText:@"No payments found for you at the moment."];
//                [emptyText_Pending setTextAlignment:NSTextAlignmentCenter];
//                [self.view addSubview:emptyText_Pending];
//                
//            }
    
        

    }
    
    else if ([tagName isEqualToString:@"time"])
    {
        //ServerDate
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        ServerDate=[self dateFromString:[dict valueForKey:@"Result"] ];
        [self.list removeFromSuperview];
        self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
        [self.list setStyleId:@"history"];
        [self.list setDataSource:self]; [self.list setDelegate:self];
        [self.list setSectionHeaderHeight:0];
        [self.view addSubview:self.list];
        [self.list reloadData];
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
        [self.view bringSubviewToFront:exportHistory];
    }
    
    else if ([tagName isEqualToString:@"search"])
    {
        [self.hud hide:YES];
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count] > 0)
        {
            isEnd = NO;
            isStart = NO;
            
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]) {
                    [histShowArrayCompleted addObject:dict];
                }
            }
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {
                    [histShowArrayPending addObject:dict];
                }
            }
        }
        else {
            isEnd = YES;
        }
        if (isMapOpen) {
            [self mapPoints];
        }
        serve *serveOBJ = [serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ setTagName:@"time"];
        [serveOBJ GetServerCurrentTime];
    } 
    
    else if ([tagName isEqualToString:@"reject"])
    {
        [self.hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Request Rejected" message:@"No problem, you have rejected this request successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        subTypestr = @"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        index = 1;
        countRows = 0;

        [self.list removeFromSuperview];
        self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
        [self.list setStyleId:@"history"];
        [self.list setDataSource:self];
        [self.list setDelegate:self];
        [self.list setSectionHeaderHeight:0];
        [self.view addSubview:self.list];
        [self.list reloadData];
        [self.view bringSubviewToFront:exportHistory];
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }

    else if ([tagName isEqualToString:@"CancelMoneyTransferToNonMemberForSender"])
    {
        [self.hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Transfer Cancelled" message:@"Aye aye. That transfer has been cancelled successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    
        subTypestr = @"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        index = 1;
        countRows = 0;
        [self.list removeFromSuperview];
        self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
        [self.list setStyleId:@"history"];
        [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
        [self.view addSubview:self.list]; [self.list reloadData];
        [self.view bringSubviewToFront:exportHistory];
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }

    else if ([tagName isEqualToString:@"cancelRequestToExisting"] || [tagName isEqualToString:@"cancelRequestToNonNoochUser"])
    {
        [self.hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Request Cancelled" message:@"You got it. That request has been cancelled successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        subTypestr = @"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        index = 1;
        countRows = 0;
        [self.list removeFromSuperview];
        self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
        [self.list setStyleId:@"history"];
        [self.list setDataSource:self];
        [self.list setDelegate:self];
        [self.list setSectionHeaderHeight:0];
        [self.view addSubview:self.list];
        [self.list reloadData];
        [self.view bringSubviewToFront:exportHistory];
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }

    else if ([tagName isEqualToString:@"remind"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Reminder Sent Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

#pragma mark Exporting History
- (IBAction)ExportHistory:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Export Transfer Data" message:@"Where should we email your data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 11;

    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
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
    
    else if (actionSheet.tag == 147 && buttonIndex == 1)  // go to Profile
    {
        ProfileInfo *prof = [ProfileInfo new];
        isProfileOpenFromSideBar = NO;
        [self.navigationController pushViewController:prof animated:YES];
    }
    
    else if ((actionSheet.tag == 1010 || actionSheet.tag == 2010) && buttonIndex == 0) // CANCEL Request
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = @"Cancelling this request...";
        [self.hud show:YES];
        [spinner1 startAnimating];
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
            [serveObj CancelMoneyRequestForExistingNoochUser:[self.responseDict valueForKey:@"TransactionId"]];
        }
    }
    
    else if (actionSheet.tag == 310 && buttonIndex == 0) // CANCEL Transfer (Send) Invite
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = @"Cancelling this transfer...";
        [self.hud show:YES];
        [spinner1 startAnimating];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        
        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"CancelMoneyTransferToNonMemberForSender";  // Cancel Request for Existing User
        [serveObj CancelMoneyTransferToNonMemberForSender:[self.responseDict valueForKey:@"TransactionId"]];
    }
    
    else if (actionSheet.tag == 1011 && buttonIndex == 0)
    {
        serve * serveObj = [serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"reject";
        [serveObj CancelRejectTransaction:[self.responseDict valueForKey:@"TransactionId"] resp:@"Rejected"];
    }
    
	// ADDED BY CLIFF Edited By Baljeet
	else if (actionSheet.tag == 1012 && buttonIndex == 0) // Send Reminder
    {
        NSString * memId1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"];
        serve * serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName = @"remind";
        [serveObj SendReminderToRecepient:[self.responseDict valueForKey:@"TransactionId"] memberId:memId1];
    }
    
    else if (actionSheet.tag == 50 && buttonIndex == 1) // Contact Support
    {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}
@end