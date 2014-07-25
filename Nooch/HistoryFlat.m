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
@interface HistoryFlat ()<GMSMapViewDelegate>
{
    GMSMapView * mapView_;
    GMSCameraPosition *camera;
    GMSMarker *markerOBJ;
}
@property (strong, nonatomic) GMSMapView *mapView;
@property(nonatomic,strong) UISearchBar *search;
@property(nonatomic,strong) UITableView *list;
@property(nonatomic,strong) UIButton *completed;
@property(nonatomic,strong) UIButton *pending;
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
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (isMapOpen) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.1];
        self.list.frame=CGRectMake(-276, 84, 320, self.view.frame.size.height);
        mapArea.frame=CGRectMake(0, 84,320,self.view.frame.size.height);
        // mapArea.frame=CGRectMake(0, 84,320,self.view.frame.size.height);
        [UIView commitAnimations];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"History"];
   // [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
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
   subTypestr=@"Success";
    listType=@"ALL";
    index=1;
    isStart=YES;
    isLocalSearch=NO;
    self.completed_selected = YES;

    UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filter setStyleClass:@"label_filter"];
    [filter setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-filter"] forState:UIControlStateNormal];
    [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];
    [self.navigationItem setRightBarButtonItem:filt];

    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
    [self.list setStyleId:@"history"]; [self.list setRowHeight:70];
    [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list]; [self.list reloadData];

    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideright:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer * recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideleft:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer2];

    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    [self.search setStyleId:@"history_search"];
    [self.search setDelegate:self];
    self.search.searchBarStyle=UISearchBarIconSearch;
    [self.search setPlaceholder:@"Search Transaction History"];
    [self.view addSubview:self.search];

    mapArea=[[UIView alloc]initWithFrame:CGRectMake(0, 84, 320, self.view.frame.size.height)];
    [mapArea setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mapArea];
    [self.view bringSubviewToFront:self.list];

    // Google map
    camera = [GMSCameraPosition cameraWithLatitude:39.952360
                                         longitude:-75.163602
                                              zoom:6];
    mapView_=[GMSMapView mapWithFrame:self.view.frame camera:camera];
    [mapView_ animateToZoom:10];
    [mapView_ animateToViewingAngle:10];
    mapView_.myLocationEnabled = YES;
    mapView_.delegate=self;
    [mapArea addSubview:mapView_];

    NSArray *seg_items = @[@"Completed",@"Pending"];
     completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [completed_pending setStyleId:@"history_segcontrol"];
    [completed_pending addTarget:self action:@selector(completed_or_pending:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:completed_pending];
    
    [completed_pending setSelectedSegmentIndex:0];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
   [self loadHist:@"ALL" index:index len:20 subType:subTypestr];

    //Export History
    exportHistory=[UIButton buttonWithType:UIButtonTypeCustom];
    [exportHistory setTitle:@" Export History" forState:UIControlStateNormal];
    [exportHistory setFrame:CGRectMake(10, 420, 150, 20)];
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        [exportHistory setStyleClass:@"exportHistorybutton"];
    } else {
        [exportHistory setStyleClass:@"exportHistorybutton_4"];
    }
    UILabel *glyph = [UILabel new];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
    [glyph setFrame:CGRectMake(3, 7, 15, 15)];
    [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-download"]];
    [glyph setTextColor:[UIColor whiteColor]];
    [exportHistory addSubview:glyph];
    [exportHistory addTarget:self action:@selector(ExportHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportHistory];
    [self.view bringSubviewToFront:exportHistory];
    // Row count for scrolling
    countRows=0;
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
    isMapOpen=NO;
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
- (void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSDictionary*dictRecord=[histArrayCommon objectAtIndex:[[marker title]intValue]];
    //NSDictionary *transaction = [NSDictionary new];
    TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
    [self.navigationController pushViewController:details animated:YES];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    customView.layer.borderColor=[[UIColor whiteColor]CGColor];
    customView.layer.borderWidth=1.0f;
    customView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mapBack.png"]];

    UIImageView*imgV=[[UIImageView alloc]initWithFrame:CGRectMake(5, 8, 52, 52)];
    imgV.layer.cornerRadius = 26; imgV.layer.borderColor = [UIColor whiteColor].CGColor; imgV.layer.borderWidth = 2;
    imgV.clipsToBounds = YES;

    NSString*urlImage=[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Photo"];
    [imgV setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
    [customView addSubview:imgV];

    NSString*TransactionType=@"";

        if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"MemberId"]]) {
            if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                TransactionType=@"Paid to :";
            }
        }
        else {
            if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                TransactionType=@"Payment From :";
            }
        }
        if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
            TransactionType=@"Donate to :";   
        }
        else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Request"]){
            if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"RecepientId"]])
                TransactionType=@"Request Sent to:";
            else
                TransactionType=@"Request From:";
        }
        else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Invite"]){
            TransactionType=@"Invited to :";
        }

        UILabel*lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(66, 8, 135, 16)];
        lblTitle.text=[NSString stringWithFormat:@"%@",TransactionType];
        lblTitle.textAlignment=NSTextAlignmentCenter;
        lblTitle.textColor=[UIColor whiteColor];
        lblTitle.font=[UIFont systemFontOfSize:14];
        [customView addSubview:lblTitle];
    
        UILabel*lblName=[[UILabel alloc]initWithFrame:CGRectMake(66, 26, 135, 16)];
        lblName.text=[NSString stringWithFormat:@"%@ %@",[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"FirstName"] capitalizedString],[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"LastName"]];
        lblName.textAlignment=NSTextAlignmentCenter;
        lblName.font=[UIFont systemFontOfSize:12];
        lblName.textColor=kNoochBlue;
        [customView addSubview:lblName];

        UILabel*lblAmt=[[UILabel alloc]initWithFrame:CGRectMake(66, 43, 135, 20)];
        lblAmt.text=[NSString stringWithFormat:@"$%.02f",[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Amount"] floatValue]];
        lblAmt.textColor= kNoochGreen;
        lblAmt.textAlignment=NSTextAlignmentCenter;
        lblAmt.font=[UIFont systemFontOfSize:18];
        [customView addSubview:lblAmt];

        UILabel*lblmemo=[[UILabel alloc]initWithFrame:CGRectMake(66, 60, 135, 25)];
        lblmemo.font=[UIFont systemFontOfSize:11];
        lblmemo.textAlignment=NSTextAlignmentCenter;
        lblmemo.numberOfLines=2;
        lblmemo.textAlignment=NSTextAlignmentCenter;

    if ([[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]!=NULL && ![[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] isKindOfClass:[NSNull class]]) {
        lblmemo.text=[NSString stringWithFormat:@"\"%@\"",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]];
        if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] length]==0) {
            lblmemo.text=@"";
        }
    }
    else {
        lblmemo.text=@"";
    }
    lblmemo.textColor=[UIColor lightGrayColor];
    [customView addSubview:lblmemo];

    UILabel*lblloc=[[UILabel alloc]initWithFrame:CGRectMake(15, 75, 170, 30)];
    lblloc.textColor=[UIColor whiteColor];
    lblloc.font=[UIFont systemFontOfSize:10.0f];
    [customView addSubview:lblloc];
     NSString*statusstr;
    if ([[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionDate"]!=NULL) {
        ////nslog(@"%@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionDate"]);
       
       

        if ([[[histArrayCommon objectAtIndex:[[marker title]intValue] ]valueForKey:@"TransactionType"] isEqualToString:@"Request"]) {
            if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"RecepientId"] isEqualToString:[user objectForKey:@"MemberId"]]) {
                if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]]valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                    statusstr=@"Cancelled:";
                    [lblloc setStyleClass:@"red_text"];
                }
                else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                    statusstr=@"Rejected:";
                    [lblloc setStyleClass:@"red_text"];
                }
                else {
                    statusstr=@"Pending:";
                    [lblloc setStyleClass:@"green_text"];
                }
            }
            else {
                if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                    statusstr=@"Cancelled:";
                    [lblloc setStyleClass:@"red_text"];
                }
                else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                    statusstr=@"Rejected:";
                    [lblloc setStyleClass:@"red_text"];
                }
				else {
					statusstr=@"Pending:";
					[lblloc setStyleClass:@"green_text"];
				}
			} 
		}
    }
    else if([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Donation"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Received"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Transfer"]){
        statusstr=@"Completed on:";
        [lblloc setStyleClass:@"green_text"];
    }
    else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Invite"]) {  
        statusstr=@"Invited on:";
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

    if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Request"]) {
        //details_label1
        [lblloc setText:[NSString stringWithFormat:@"%@",statusstr]];
        UILabel *datelbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 75, 150, 30)];
        [datelbl setTextColor:[UIColor lightGrayColor]];
        [customView addSubview:datelbl];
        [datelbl setFont:[UIFont systemFontOfSize:10.0f]];
        datelbl.text=[NSString stringWithFormat:@"(Sent on %@ %@,%@)",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]]; 
    }
    else {
        [lblloc setText:[NSString stringWithFormat:@"%@ %@ %@,%@",statusstr,[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]]];
    }

return customView;    
}

-(void)mapPoints{
    
    if (self.completed_selected) {
        if ([histShowArrayCompleted count]==0) {
            for (GMSMarker*marker in mapView_.markers ) {
                marker.map=nil;
            }
            return;
        }
        histArrayCommon=[histShowArrayCompleted copy];
    }
    else {
        if ([histShowArrayPending count]==0) {
            for (GMSMarker*marker in mapView_.markers ) {
                marker.map=nil;
            }
            return;
        }
        histArrayCommon=[histShowArrayPending copy];
    }
    for (GMSMarker*marker in mapView_.markers ) {
        marker.map=nil;
    }
    for (int i=0; i<histArrayCommon.count; i++) {
        //Latitude = 0;

        NSDictionary* tempDict = [histArrayCommon objectAtIndex:i];
        markerOBJ = [[GMSMarker alloc] init];
        markerOBJ.position = CLLocationCoordinate2DMake([[tempDict objectForKey:@"Latitude"] floatValue], [[tempDict objectForKey:@"Longitude"] floatValue]);
        [markerOBJ setTitle:[NSString stringWithFormat:@"%d",i]];

        if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]&&[[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:i] valueForKey:@"MemberId"]]) {
            markerOBJ.icon=[UIImage imageNamed:@"blue-pin.png"];
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]&&[[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:i] valueForKey:@"RecepientId"]]) {
            markerOBJ.icon=[UIImage imageNamed:@"orange-pin.png"];
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Requested"]) {
            markerOBJ.icon=[UIImage imageNamed:@"green-pin.png"];
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Donation"]) {
            markerOBJ.icon=[UIImage imageNamed:@"red-pin.png"];
        }
        //        marker.title = [tempDict objectForKey:@"fname"];
        //        marker.snippet = [tempDict objectForKey:@"lname"];
        //        marker.icon=[UIImage imageNamed:@"crossblue.png"];
        //        marker.userData = [tempDict objectForKey:@"lname"];
        //        marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
        //        marker.groundAnchor = CGPointMake(0.5, 1.0);
        markerOBJ.animated=YES;
        markerOBJ.map = mapView_;
    }
}
-(void)move:(id)sender {
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
    ////nslog(@"float  %f",firstX+translatedPoint.x);
    CGFloat animationDuration = 0.2;
    CGFloat velocityX = (0.0*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
    
    CGFloat finalX = translatedPoint.x + velocityX;
    ////nslog(@"%f",finalX);
    CGFloat finalY = firstY;
    [[sender view] setCenter:translatedPoint];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    //  [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
    [[sender view] setCenter:CGPointMake(finalX, finalY)];
    [UIView commitAnimations];
    /*
     if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
     CGFloat velocityX = (0.0*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);

     CGFloat finalX = translatedPoint.x + velocityX;
     ////nslog(@"%f",finalX);
     CGFloat finalY = firstY;// translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
     
     //      if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
     //          if (finalX < 0) {
     //              //finalX = 0;
     //          } else if (finalX > 768) {
     //              //finalX = 768;
     //          }
     //          if (finalY < 0) {
     //              finalY = 0;
     //          } else if (finalY > 1024) {
     //              finalY = 1024;
     //          }
     //      } else {
     //          if (finalX < 0) {
     //              //finalX = 0;
     //          } else if (finalX > 1024) {
     //              //finalX = 768;
     //          }
     //          if (finalY < 0) {
     //              finalY = 0;
     //          } else if (finalY > 768) {
     //              finalY = 1024;
     //          }
     //      }
     
     CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
     
     ////nslog(@"the duration is: %f", animationDuration);
     
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:animationDuration];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
     [UIView setAnimationDelegate:self];
     //  [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
     [[sender view] setCenter:CGPointMake(finalX, finalY)];
     [UIView commitAnimations];
     }*/
}
-(void)FilterHistory:(id)sender{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    isHistFilter=YES;
    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = nil;
    fp =  [[FPPopoverController alloc] initWithViewController:popOver];
    fp.border = NO;
    fp.tint = FPPopoverWhiteTint;
    fp.arrowDirection = FPPopoverArrowDirectionUp;
    fp.contentSize = CGSizeMake(200, 335);
    [fp presentPopoverFromPoint:CGPointMake(280, 45)];
    
}
-(void)dismissFP:(NSNotification *)notification{
    [fp dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismissPopOver" object:nil];
    isSearch=NO;
    if (![listType isEqualToString:@"CANCEL"]&& isFilterSelected) {
        [self.search setShowsCancelButton:NO];
        [self.search setText:@""];
        [self.search resignFirstResponder];
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        //histShowArrayCompleted=[[NSMutableArray alloc]init];
        // histShowArrayPending=[[NSMutableArray alloc]init];
        isLocalSearch=NO;
        isFilter=YES;
        index=1;
        isFilterSelected=NO;
        //Rlease memory cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        countRows=0;
        [self loadHist:listType index:index len:20 subType:subTypestr];
    }
    else
        isFilter=NO;
}

-(void)loadHist:(NSString*)filter index:(int)ind len:(int)len subType:(NSString*)subType{
    
    //if (![self.navigationController.view.subviews containsObject:self.hud]) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        
        [self.navigationController.view addSubview:self.hud];
        
        self.hud.delegate = self;
        
        self.hud.labelText = @"Loading Transaction Histroy...";
        
        [self.hud show:YES];
        

   // }
    
    
//    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
//    [spinner setHidden:NO];
//    [self.view addSubview:spinner];
//    [spinner startAnimating];
    isSearch=NO;
    isLocalSearch=NO;
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"hist";
    [serveOBJ histMore:filter sPos:ind len:len subType:subTypestr];
}
#pragma mark - transaction type switching
- (void) completed_or_pending:(id)sender
{
    [self.list removeFromSuperview];
    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
    [self.list setStyleId:@"history"]; [self.list setRowHeight:70];
    [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list]; [self.list reloadData];
    [self.view bringSubviewToFront:exportHistory];
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([segmentedControl selectedSegmentIndex] == 0) {
        subTypestr=@"Success";
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        self.completed_selected = YES;
        index=1;
        countRows=0;
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }
    else {
        subTypestr=@"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
         index=1;
          countRows=0;
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
    } else {
        if (isLocalSearch) {
            return [histTempPending count]+1;
        }
        return [histShowArrayPending count]+1;
    }
    return 0;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
  }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
   // if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        if (self.completed_selected) {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier
                                      containingTableView:self.list // For row height and selection
                                       leftUtilityButtons:nil
                                      rightUtilityButtons:nil];
        }
        else {
            NSMutableArray *temp = [NSMutableArray new];
            if (isLocalSearch) {
                temp = [histTempPending mutableCopy];
            } 
            else {
                temp = [histShowArrayPending mutableCopy];
            }
            if ([temp count]>indexPath.row) {
                NSDictionary*dictRecord=[temp objectAtIndex:indexPath.row];
                if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
                    if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) {
                        //cancel or remind						
						[rightUtilityButtons sw_addUtilityButtonWithColor:kNoochBlue
                        title:@"Remind"];
                        [rightUtilityButtons sw_addUtilityButtonWithColor:
                            [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                        title:@"Cancel"];
                    }
                    else {
                        //accept or decline
                        [rightUtilityButtons sw_addUtilityButtonWithColor:kNoochGreen
                        title:@"Accept"];
                        [rightUtilityButtons sw_addUtilityButtonWithColor:
							[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                        title:@"Decline"];
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
   // }
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    if (self.completed_selected) {
        if (isLocalSearch) {
            if ([histTempCompleted count]>indexPath.row)
            {
                NSDictionary*dictRecord=[histTempCompleted objectAtIndex:indexPath.row];

                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]|| [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]
                    ||[[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] ) {

                    UIView *indicator = [UIView new];
                    [indicator setStyleClass:@"history_sidecolor"];

                    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [amount setBackgroundColor:[UIColor clearColor]];
                    [amount setTextAlignment:NSTextAlignmentRight];
                    [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                    [amount setStyleClass:@"history_transferamount"];
                    
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]) {
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                            [amount setStyleClass:@"history_transferamount_neg"];
                            [indicator setStyleClass:@"history_sidecolor_neg"];
                            [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        }  
                    }
                    else  {
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                            [amount setStyleClass:@"history_transferamount_pos"];
                            [indicator setStyleClass:@"history_sidecolor_pos"];
                            [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        }
                    }
                    
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]) {
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_donate"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL){
                        //ADDED BY CLIFF
						if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
							[amount setStyleClass:@"history_transferamount_neutral"];
							[indicator setStyleClass:@"history_sidecolor_neutral"];
							[amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
						}
						else {
							[amount setStyleClass:@"history_transferamount_pos"];
							[indicator setStyleClass:@"history_sidecolor_pos"];
							[amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
						}
					}
                    [cell.contentView addSubview:amount];
                    [cell.contentView addSubview:indicator];
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];

                    // 'updated_balance' now for displaying transfer STATUS, only if status is "cancelled" or "rejected" (this used to display the user's updated balance, which no longer exists
                    UILabel *updated_balance = [UILabel new];
                    if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {

						[updated_balance setStyleClass:@"history_updatedbalance"];
                        [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                        [cell.contentView addSubview:updated_balance];
                    }
                

                    NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];

                    if ((long)[components day]>3) {
                        
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
                    else if ((long)[components day]==0) {
                        NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit 
                                fromDate:addeddate
                                toDate:ServerDate      
                                options:0];
                        ////nslog(@"%ld  %ld", (long)[components hour],(long)[components minute]);
                        if ((long)[components hour]==0) {
                            NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit
                                fromDate:addeddate
                                toDate:ServerDate
                                options:0];
                            ////nslog(@"%ld ",(long)[components minute]);
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

                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 52, 52)];
                    pic.layer.borderColor = kNoochGrayDark.CGColor;
                    pic.layer.borderWidth = 1;
                    pic.layer.cornerRadius = 26;
                    pic.clipsToBounds = YES;
                    [cell.contentView addSubview:pic];

                    UILabel *transferTypeLabel = [UILabel new];
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];

                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    [name setStyleClass:@"history_recipientname"];

					//transfer SENT
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]) {
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                            [transferTypeLabel setText:@"Transfer to"];
							[transferTypeLabel setTextColor:kNoochRed];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                    }
                    else {  //transfer RECEIVED
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                            [transferTypeLabel setText:@"Transfer from"];
							[transferTypeLabel setTextColor: kNoochGreen];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                    }

                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
                        [transferTypeLabel setText:@"Donation to"];
						[transferTypeLabel setTextColor: kNoochPurple];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]){
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                            [transferTypeLabel setText:@"Request sent to"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                        else {
                            [transferTypeLabel setText:@"Request from"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
						[transferTypeLabel setTextColor:kNoochBlue];
                        [updated_balance setStyleClass:@"history_RequestStatus"];
                        [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                        [cell.contentView addSubview:updated_balance];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]){
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                            [transferTypeLabel setText:@"Request sent to"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                        else {
                            [transferTypeLabel setText:@"Request from"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
						[transferTypeLabel setTextColor:kNoochBlue];
                        [updated_balance setStyleClass:@"history_RequestStatus"];
                        [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                        [cell.contentView addSubview:updated_balance];
                    }
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL){
                        [pic setImage:[UIImage imageNamed:@"RoundLoading"]];
                         [transferTypeLabel setText:@"Invite sent to"];
						 [transferTypeLabel setTextColor:kNoochGrayDark];
                         [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                    }
                    [cell.contentView addSubview:transferTypeLabel];
                    [cell.contentView addSubview:name];
                }
            }
            else if([histTempCompleted count]==indexPath.row){
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabelEmpty"];
                [name setStyleClass:@"history_recipientname"];
                if (indexPath.row==0)
                    [name setText:@"No payments to report yet."];
                else if (indexPath.row==1) {
                    [name setText:@":("];
				}
				else {
                    [name setText:@""];
				}
                [cell.contentView addSubview:name];
            }
            return cell;
        }
        if ([histShowArrayCompleted count]>indexPath.row) {
            NSDictionary*dictRecord=[histShowArrayCompleted objectAtIndex:indexPath.row];

            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]|| [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]
                ||[[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] ) {

                UIView *indicator = [UIView new];
                [indicator setStyleClass:@"history_sidecolor"];

                UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                [amount setBackgroundColor:[UIColor clearColor]];
                [amount setTextAlignment:NSTextAlignmentRight];
                [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                [amount setStyleClass:@"history_transferamount"];
                
                if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]) {
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                        //send
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                }
                else {
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                        [amount setStyleClass:@"history_transferamount_pos"];
                        [indicator setStyleClass:@"history_sidecolor_pos"];
                        [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                }

                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]) {
                    [amount setStyleClass:@"history_transferamount_neg"];
                    [indicator setStyleClass:@"history_sidecolor_donate"];
                    [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
                    [amount setStyleClass:@"history_transferamount_neg"];
                    [indicator setStyleClass:@"history_sidecolor_neg"];
                    [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                }
				else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL){
                    //ADDED BY CLIFF
					if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
						[amount setStyleClass:@"history_transferamount_neutral"];
						[indicator setStyleClass:@"history_sidecolor_neutral"];
						[amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
					}
					else {
						[amount setStyleClass:@"history_transferamount_pos"];
						[indicator setStyleClass:@"history_sidecolor_pos"];
						[amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
					}
				}
                [cell.contentView addSubview:amount];
                [cell.contentView addSubview:indicator];
                UILabel *date = [UILabel new];
                [date setStyleClass:@"history_datetext"];

				//  'updated_balance' now for displaying transfer STATUS, only if status is "cancelled" or "rejected" (this used to display the user's updated balance, which no longer exists
                UILabel *updated_balance = [UILabel new];
                    if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                        [updated_balance setStyleClass:@"history_updatedbalance"];
                        [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                        [cell.contentView addSubview:updated_balance];
                    }

                NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                    fromDate:addeddate
                                                                      toDate:[NSDate date]
                                                                     options:0];
                if ((long)[components day]>3) {
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
                else if ((long)[components day]==0) {
                    NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                    ////nslog(@"%ld  %ld", (long)[components hour],(long)[components minute]);
                    if ((long)[components hour]==0) {
                        NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                        ////nslog(@"%ld ",(long)[components minute]);
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

                UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 52, 52)];
                pic.layer.borderColor = kNoochGrayDark.CGColor;
                pic.layer.borderWidth = 1;
                pic.layer.cornerRadius = 26;
                pic.clipsToBounds = YES;
                [cell.contentView addSubview:pic];

				UILabel *transferTypeLabel = [UILabel new];
                [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
					
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];

                if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]) {
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                        [transferTypeLabel setText:@"Transfer to"];
						[transferTypeLabel setTextColor:kNoochRed];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];   
                    }
                }
                else {
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                        [transferTypeLabel setText:@"Transfer from"];
						[transferTypeLabel setTextColor:kNoochGreen];
						[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                }
                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
                    [transferTypeLabel setText:@"Donation to"];
					[transferTypeLabel setTextColor:kNoochPurple];
                    [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                    [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                }
                else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL){
                    [pic setImage:[UIImage imageNamed:@"RoundLoading"]];
                    [transferTypeLabel setText:@"Invite sent to"];
					[transferTypeLabel setTextColor:kNoochGrayDark];
                    [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]){
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                        [transferTypeLabel setText:@"Request sent to"];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                    else {
                        [transferTypeLabel setText:@"Request from"];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
					[transferTypeLabel setTextColor:kNoochBlue];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]){
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                        [transferTypeLabel setText:@"Request sent to"];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                    else {
                        [transferTypeLabel setText:@"Request from"];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
					[transferTypeLabel setTextColor:kNoochBlue];
                }
                [cell.contentView addSubview:transferTypeLabel];
                [cell.contentView addSubview:name];
            }
        }
        else if (indexPath.row==[histShowArrayCompleted count]) {
            if(isEnd==YES) {
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabelEmpty"];
                [name setStyleClass:@"history_recipientname"];
                if (indexPath.row==0)
                    [name setText:@"No payments to report yet."];
                else if (indexPath.row==0){
                    [name setText:@":("];
				}
				else {
                    [name setText:@""];
				}
                [cell.contentView addSubview:name];
			}
            else {
                if (isSearch) {
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                    ishistLoading=YES;
                    index++;
                    [self loadSearchByName];
                }
                else {
                    if (indexPath.row!=0) {
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                    ishistLoading=YES;
                    index++;
                    [self loadHist:listType index:index len:20 subType:subTypestr];
                    }
                }
            }
        }
    }
    else if(self.completed_selected == NO) {
        if (isLocalSearch) {
            if ([histTempPending count]>indexPath.row) {
                NSDictionary*dictRecord=[histTempPending objectAtIndex:indexPath.row];
                ////nslog(@"%@",dictRecord);
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {
                    UIView *indicator = [UIView new];
                    [indicator setStyleClass:@"history_sidecolor"];

                    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [amount setBackgroundColor:[UIColor clearColor]];
                    [amount setTextAlignment:NSTextAlignmentRight];
                    [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                    [amount setStyleClass:@"history_pending_transferamount"];

                    [indicator setStyleClass:@"history_sidecolor_neutral"];
                    [amount setStyleClass:@"history_transferamount_neutral"];
                    [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    [cell.contentView addSubview:amount];
                    [cell.contentView addSubview:indicator];

					UILabel *transferTypeLabel = [UILabel new];
                    [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];

                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    [name setStyleClass:@"history_recipientname"];
					
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
                        if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]){
							[transferTypeLabel setText:@"Request sent to"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
						}
                        else {
                            [transferTypeLabel setText:@"Request from"];
                            [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        }
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL)
                    {
						[transferTypeLabel setText:@"Invite sent to"];
						[transferTypeLabel setTextColor:kNoochGrayDark];
                        [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                    }
					else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] ) {
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]){
                            [transferTypeLabel setText:@"You disputed a transfer to"];
							[transferTypeLabel setTextColor:kNoochRed];
							[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
						}
						else {
							[transferTypeLabel setText:@"Transfer disputed by"];
							[transferTypeLabel setTextColor:kNoochRed];
							[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
						}
					}

                    else {
                        [name setText:@""];
                    }
					[cell.contentView addSubview:transferTypeLabel];
                    [cell.contentView addSubview:name];

                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];

                    NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                           fromDate:addeddate                                               
                           toDate:ServerDate
                           options:0];
                    //nslog(@"%ld", (long)[components day]);
                    if ((long)[components day]>3) {
                        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
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
                    else if ((long)[components day]==0) {
                        NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                                fromDate:addeddate
                                toDate:ServerDate
                                options:0];
                        //nslog(@"%ld  %ld", (long)[components hour],(long)[components minute]);
                        if ((long)[components hour]==0) {
                            NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit                            
                                    fromDate:addeddate
                                    toDate:ServerDate
                                    options:0];
                            //nslog(@"%ld ",(long)[components minute]);
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
                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 52, 52)];
                    pic.layer.borderColor = kNoochGrayDark.CGColor;
                    pic.layer.borderWidth = 1;
                    pic.layer.cornerRadius = 26;
                    pic.clipsToBounds = YES;
                    [cell.contentView addSubview:pic];
                    [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                }
            }

            else if (indexPath.row==[histTempPending count]) {
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];

                if (indexPath.row==0) {
                    [name setText:@"No payments to report yet."];
				}
				else if (indexPath.row==1) {
                    [name setText:@":("];
				}
				else {
                    [name setText:@""];
                }
				[cell.contentView addSubview:name];
            }
            return cell;
        }

        if ([histShowArrayPending count]>indexPath.row) {
            NSDictionary*dictRecord=[histShowArrayPending objectAtIndex:indexPath.row];
            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {

				UIView *indicator = [UIView new];
                [indicator setStyleClass:@"history_sidecolor"];
                [indicator setStyleClass:@"history_sidecolor_neutral"];
                
                UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                [amount setBackgroundColor:[UIColor clearColor]];
                [amount setTextAlignment:NSTextAlignmentRight];
                [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                [amount setStyleClass:@"history_pending_transferamount"];
                [amount setStyleClass:@"history_transferamount_neutral"];
                [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];

                [cell.contentView addSubview:amount];
                [cell.contentView addSubview:indicator];

				UILabel *transferTypeLabel = [UILabel new];
                [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];

                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];

                if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
                    if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                    {
						[transferTypeLabel setText:@"Request sent to"];
						[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    }
					else {
                        [transferTypeLabel setText:@"Request from"];
						[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
					}
					[transferTypeLabel setTextColor:kNoochBlue];
				}
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL)
                {
					[transferTypeLabel setText:@"You invited"];
					[transferTypeLabel setTextColor:kNoochGrayDark];
					[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"]) {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]){
                        [transferTypeLabel setText:@"You disputed a transfer to"];
						[transferTypeLabel setTextColor:kNoochRed];
						[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    }
                    else {
						[transferTypeLabel setText:@"Transfer disputed by"];
						[transferTypeLabel setTextColor:kNoochRed];
						[name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    }
                }
                else {
                    [name setText:@""];
				}

                [cell.contentView addSubview:transferTypeLabel];
                [cell.contentView addSubview:name];

                UILabel *date = [UILabel new];
                [date setStyleClass:@"history_datetext"];
                NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                    fromDate:addeddate
                    toDate:ServerDate
                    options:0];

                if ((long)[components day]>3) {
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
                else if ((long)[components day]==0) {
                    NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                    //nslog(@"%ld  %ld", (long)[components hour],(long)[components minute]);
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

				UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 52, 52)];
                pic.layer.borderColor = kNoochGrayDark.CGColor;
                pic.layer.borderWidth = 1;
                pic.layer.cornerRadius = 26;
                pic.clipsToBounds = YES;
                [cell.contentView addSubview:pic];
                [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                    placeholderImage:[UIImage imageNamed:@"RoundLoading"]];

			}
        }
        else if (indexPath.row==[histShowArrayPending count]) {
            if(isEnd==YES) {
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];
                if (indexPath.row==0)
                    [name setText:@"No Records"];
                else
                    [name setText:@""];
                [cell.contentView addSubview:name];
                return cell;
            }
            else if(isStart==YES) {
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                [activityIndicator startAnimating];
                [cell.contentView addSubview:activityIndicator];
            }
            else {
                if (isSearch) {
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                    ishistLoading=YES;
                    index++;
                    [self loadSearchByName];
                }
                else {
                    if (indexPath.row!=0) {
                        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                        [activityIndicator startAnimating];
                        [cell.contentView addSubview:activityIndicator];
                        ishistLoading=YES;
                        index++;
                        [self loadHist:listType index:index len:20 subType:subTypestr];
                    }
                }
            }
        }
    }
    return cell;
}
#pragma mark- Date From String
- (NSDate*) dateFromString:(NSString*)aStr
{   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    //[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss a"];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"M/dd/yyyy hh:mm:ss a";
    //[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
 // [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-5]];
    
    NSLog(@"%@", aStr);
    NSDate   *aDate = [dateFormatter dateFromString:aStr];
      NSLog(@"%@", aDate);
    return aDate;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    
    if (self.completed_selected) {
        if (isLocalSearch) {
            NSDictionary*dictRecord=[histTempCompleted objectAtIndex:indexPath.row];
            //NSDictionary *transaction = [NSDictionary new];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
            return;
        }
        if ([histShowArrayCompleted count]>indexPath.row) {
            NSDictionary*dictRecord=[histShowArrayCompleted objectAtIndex:indexPath.row];
            //NSDictionary *transaction = [NSDictionary new];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
        }
    }
    else {
        if (isLocalSearch) {
            NSDictionary*dictRecord=[histTempPending objectAtIndex:indexPath.row];
            //NSDictionary *transaction = [NSDictionary new];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
            return;
        }
        if ([histShowArrayPending count]>indexPath.row) {
            NSDictionary*dictRecord=[histShowArrayPending objectAtIndex:indexPath.row];
            //NSDictionary *transaction = [NSDictionary new];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
        }
    }
   

}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)ind {
    NSMutableArray *temp = [NSMutableArray new];
    if (isLocalSearch) {
        temp = [histTempPending mutableCopy];
    }
    else {
        temp = [histShowArrayPending mutableCopy];
    }
    NSDictionary*dictRecord=[temp objectAtIndex:[self.list indexPathForCell:cell].row];
    if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
        if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) {
			
			// ADDED BY CLIFF
			if (ind == 0) {
                //remind
				self.responseDict = [dictRecord copy];
				UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send Reminder" message:@"Send a reminder about this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
				[av show];
				[av setTag:1012];
			}
			else {
				//cancel
				self.responseDict = [dictRecord copy];
				UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel Request" message:@"Are you sure you want to cancel this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
				[av show];
				[av setTag:1010];
			}
        }
        else {
            //accept/decline
            if (ind == 0) {
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
                if ( ![[[NSUserDefaults standardUserDefaults]
                        objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
                    UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Please Attach an Account" message:@"Before you can send or receive money, you must add a bank account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                    [set show];
                    return;
                }
                if ( ![[assist shared]isBankVerified]) {
                    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please Attach an Account" message:@"Before you can send or receive money, you must add a bank account." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                    [alert show];
                    return;
                }
                NSMutableDictionary *input = [dictRecord mutableCopy];
                [input setValue:@"accept" forKey:@"response"];
                //NSLog(@"%@",input);
                // isMutipleRequest=NO;
                [[assist shared]setRequestMultiple:NO];
                TransferPIN *trans = [[TransferPIN alloc] initWithReceiver:input type:@"requestRespond" amount:[[dictRecord objectForKey:@"Amount"] floatValue]];
                [nav_ctrl pushViewController:trans animated:YES];
            } 
            else {
                //decline
                self.responseDict = [dictRecord copy];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to reject this request?" delegate:self cancelButtonTitle:@"Yes - Reject" otherButtonTitles:@"No", nil];
                [av show];
                [av setTag:1011];
            }
        }
    }
}

#pragma mark - SWTableView

#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{

    [searchBar setShowsCancelButton:NO];
    [self.search resignFirstResponder];
    //if ([searchBar.text length]>0) {
    isSearch=NO;
    isFilter=NO;
    listType=@"ALL";
    index=1;
    [histShowArrayCompleted removeAllObjects];
    [histShowArrayPending removeAllObjects];
    self.search.text=@"";
    //Rlease memory cache
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    countRows=0;
    [self.search resignFirstResponder];
    [self loadHist:listType index:index len:20 subType:subTypestr];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([searchBar.text length]>0) {
        listType=@"ALL";
        SearchStirng=[self.search.text lowercaseString];
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        index=1;
        isSearch=YES;
        isLocalSearch=NO;
        isFilter=NO;
        //Rlease memory cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
         countRows=0;
        [self loadSearchByName];
    }
    [self.search resignFirstResponder];
}
- (void) searchTableView
{
    [histTempCompleted removeAllObjects];
    [histTempPending removeAllObjects];
    if ([subTypestr isEqualToString:@"Success"]) {
        for (NSMutableDictionary *tableViewBind in histShowArrayCompleted)
        {
            NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            NSComparisonResult result2 = [[tableViewBind valueForKey:@"LastName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            if (result == NSOrderedSame || result2 == NSOrderedSame) {
                [histTempCompleted addObject:tableViewBind];
            }
        }
    }
    else {
        for (NSMutableDictionary *tableViewBind in histShowArrayPending) {
            NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            NSComparisonResult result2 = [[tableViewBind valueForKey:@"LastName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
            if (result == NSOrderedSame || result2 == NSOrderedSame) {
                [histTempPending addObject:tableViewBind];
            }
        }
    }
    //[self loadSearchByName];
    [self.list reloadData];
}

-(void)loadSearchByName
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.delegate = self;
    
    self.hud.labelText = @"Searching History...";
    
    [self.hud show:YES];
//    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
//    [self.view addSubview:spinner];
//    [spinner startAnimating];
    listType=@"ALL";
    isLocalSearch=NO;
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"search";
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
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
        if ([searchText isEqualToString:@""]) {
            searchBar.text=@"";
            return;
        }
    if ([searchText length]>0) {
        SearchStirng=[self.search.text lowercaseString];
        isEnd=YES;
        isFilter=NO;
        isLocalSearch=YES;
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
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    
    
    NSError *error;
   
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Login Detected From New Device" message:@"It seems like you have logged in from another device, which automatically signs you out of any other active devices." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [Alert show];
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
        if ([tagName isEqualToString:@"csv"]) {
        NSDictionary*dictResponse=[NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([[[dictResponse valueForKey:@"sendTransactionInCSVResult"]valueForKey:@"Result"]isEqualToString:@"1"]) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Export Successful" message:@"Your personalized transaction report has been emailed to you." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
    else if ([tagName isEqualToString:@"hist"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
            // do work here
        });
        
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count]>0) {
            isEnd=NO;
            isStart=NO;
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] ||
                    [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] ||
                    [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ) {
                    
                    [histShowArrayCompleted addObject:dict];
                    
                }
                
            }
            int counter=0;
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {
                    [histShowArrayPending addObject:dict];
                    if ([[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"]) {
                        counter++;
                    }
                    
                }
            }
            if (counter>0) {
                
                [completed_pending setTitle:[NSString stringWithFormat:@"Pending (%d)",counter]forSegmentAtIndex:1];
                
            }
           }
        else {
            isEnd=YES;
        }
        if (isMapOpen) {
            [self mapPoints];
        }
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ setTagName:@"time"];
        [serveOBJ GetServerCurrentTime];
    }
    else if ([tagName isEqualToString:@"time"]){
        
        //ServerDate
         NSDictionary*dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        ServerDate=[self dateFromString:[dict valueForKey:@"Result"] ];
        [self.list removeFromSuperview];
        self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
        [self.list setStyleId:@"history"]; [self.list setRowHeight:70];
        [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
        [self.view addSubview:self.list];
        [self.list reloadData];
         if ([subTypestr isEqualToString:@"Pending"]) {
             [self.list scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countRows inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
         countRows=[histShowArrayPending count];
         }
         else{
            [self.list scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countRows inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        countRows=[histShowArrayCompleted count];
        }
        [self.view bringSubviewToFront:exportHistory];

        //[self.list scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.list numberOfRowsInSection:0]-4 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    else if([tagName isEqualToString:@"search"]){
         [self.hud hide:YES];
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count]>0) {
            isEnd=NO;
            isStart=NO;
            
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
            isEnd=YES;
        }
        if (isMapOpen) {
            [self mapPoints];
        }
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ setTagName:@"time"];
        [serveOBJ GetServerCurrentTime];
    } 
    else if ([tagName isEqualToString:@"reject"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Request Rejected" message:@"No problem, you have rejected this request successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        subTypestr=@"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        index=1;
        countRows=0;

        [self.list removeFromSuperview];
        self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
        [self.list setStyleId:@"history"]; [self.list setRowHeight:70];
        [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
        [self.view addSubview:self.list]; [self.list reloadData];
        [self.view bringSubviewToFront:exportHistory];
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];

    }
    else if ([tagName isEqualToString:@"cancel"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Request Cancelled" message:@"You got it. That request has been cancelled successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        subTypestr=@"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        index=1;
        countRows=0;
        [self.list removeFromSuperview];
        self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
        [self.list setStyleId:@"history"]; [self.list setRowHeight:70];
        [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
        [self.view addSubview:self.list]; [self.list reloadData];
        [self.view bringSubviewToFront:exportHistory];
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }
    else if ([tagName isEqualToString:@"remind"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Success!" message:@"Reminder Sent Successfully!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }

    
}
#pragma mark Exporting History
- (IBAction)ExportHistory:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Export Transfer Data" message:@"Where should we email your data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    alert.tag = 11;
    [alert show];
}
#pragma mark - alert view delegation
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 11) {
        if (buttonIndex == 0) {
            //nslog(@"Cancelled");
        }
        else {
            NSString * email = [[actionSheet textFieldAtIndex:0] text];
            serve * s = [[serve alloc] init];
            [s setTagName:@"csv"];
            [s setDelegate:self];
            [s sendCsvTrasactionHistory:email];
        }
    } 
    else if (actionSheet.tag==1010 && buttonIndex==0) {
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"cancel";
        [serveObj CancelRejectTransaction:[self.responseDict valueForKey:@"TransactionId"] resp:@"Cancelled"];        
    }
    else if (actionSheet.tag==1011 && buttonIndex==0) {
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"reject";
        [serveObj CancelRejectTransaction:[self.responseDict valueForKey:@"TransactionId"] resp:@"Rejected"];
    }
	// ADDED BY CLIFF Edited By Baljeet
	else if (actionSheet.tag==1012 && buttonIndex==0) {
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"remind";
        [serveObj SendReminderToRecepient:[self.responseDict valueForKey:@"TransactionId"]];
        // NEED TO ADD SERVER CALL
    }
    else if (actionSheet.tag == 50 && buttonIndex == 1) {
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