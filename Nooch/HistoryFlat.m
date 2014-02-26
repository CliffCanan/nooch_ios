//
//  HistoryFlat.m
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "HistoryFlat.h"
#import "Home.h"
#import "Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import "TransactionDetails.h"
#import "UIImageView+WebCache.h"
#import "ECSlidingViewController.h"
#import "Register.h"
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
    [hamburger setFrame:CGRectMake(0, 0, 40, 40)];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setStyleId:@"navbar_hamburger"];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    [self.navigationItem setTitle:@"History"];
     [nav_ctrl performSelector:@selector(disable)];
	// Do any additional setup after loading the view.
    //    [self.slidingViewController.panGesture setEnabled:YES];
    //    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
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
    
    
    
    listType=@"ALL";
    index=1;
    isStart=YES;
    isLocalSearch=NO;
    self.completed_selected = YES;
    
    UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filter setStyleClass:@"label_filter"];
    [filter setTitle:@"Filter" forState:UIControlStateNormal];
    [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];
    [self.navigationItem setRightBarButtonItem:filt];
    
    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [UIScreen mainScreen].bounds.size.height-80)];
    [self.list setStyleId:@"history"];
    [self.list setDataSource:self]; [self.list setDelegate:self]; [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list]; [self.list reloadData];
    
    
    
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideright:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.list addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer * recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideleft:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.list addGestureRecognizer:recognizer2];
    
    
    
    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    [self.search setStyleId:@"history_search"];
    
    [self.search setDelegate:self];
    self.search.searchBarStyle=UISearchBarIconSearch;
   // //nslog(@"%@",[self.search subviews]);
    //  [[[self.search subviews] objectAtIndex:0] removeFromSuperview];
    [self.search setPlaceholder:@"Search Transaction History"];
    [self.view addSubview:self.search];
    
    mapArea=[[UIView alloc]initWithFrame:CGRectMake(0, 84, 320, self.view.frame.size.height)];
    [mapArea setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mapArea];
    //[mapArea addSubview:self.mapView];
    [self.view bringSubviewToFront:self.list];
    
    // Google map
    camera = [GMSCameraPosition cameraWithLatitude:[@"0" floatValue]
                                         longitude:[@"0" floatValue]
                                              zoom:1];
    
    mapView_=[GMSMapView mapWithFrame:self.view.frame camera:camera];
    
    mapView_.myLocationEnabled = YES;
    mapView_.delegate=self;
    [mapArea addSubview:mapView_];
    /*self.completed =  [UIButton buttonWithType:UIButtonTypeRoundedRect]; self.pending = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [self.completed setFrame:CGRectMake(0, 0, 160, 40)]; [self.pending setFrame:CGRectMake(160, 0, 160, 40)];
     [self.completed setBackgroundColor:kNoochBlue]; [self.pending setBackgroundColor:kNoochGrayLight];
     [self.completed setTitle:@"COMPLETED" forState:UIControlStateNormal]; [self.pending setTitle:@"PENDING" forState:UIControlStateNormal];
     [self.completed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; [self.pending setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [self.pending addTarget:self action:@selector(switch_to_pending) forControlEvents:UIControlEventTouchUpInside];
     [self.completed addTarget:self action:@selector(switch_to_completed) forControlEvents:UIControlEventTouchUpInside];
     
     [self.completed.titleLabel setFont:kNoochFontMed]; [self.pending.titleLabel setFont:kNoochFontMed];
     [self.view addSubview:self.completed]; [self.view addSubview:self.pending];*/
    
    NSArray *seg_items = @[@"Completed",@"Pending"];
    UISegmentedControl *completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [completed_pending setStyleId:@"history_segcontrol"];
    [completed_pending addTarget:self action:@selector(completed_or_pending:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:completed_pending];
    [completed_pending setSelectedSegmentIndex:0];
    
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    subTypestr=@"Success";
    [self loadHist:@"ALL" index:index len:20 subType:subTypestr];
    //Export History
    exportHistory=[UIButton buttonWithType:UIButtonTypeCustom];
    [exportHistory setTitle:@"Export History" forState:UIControlStateNormal];
    [exportHistory setFrame:CGRectMake(10, 420, 70, 20)];
    [exportHistory setStyleClass:@"exportHistorybutton"];
    [exportHistory addTarget:self action:@selector(ExportHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportHistory];
    [self.view bringSubviewToFront:exportHistory];
    
}

-(void)sideright:(id)sender
{
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
    
    //Right indicator 
    UILabel *RightArrowlbl = [[UILabel alloc] initWithFrame:CGRectMake(180, 2, 20,22)];
    [RightArrowlbl setTextColor:[UIColor whiteColor]];
    [customView addSubview:RightArrowlbl];
    [RightArrowlbl setFont:[UIFont systemFontOfSize:20.0f]];
    RightArrowlbl.text=@">";
    
    UIImageView*imgV=[[UIImageView alloc]initWithFrame:CGRectMake(5, 25, 50, 50)];
    
    imgV.layer.cornerRadius = 25; imgV.layer.borderColor = kNoochBlue.CGColor; imgV.layer.borderWidth = 1;
    imgV.clipsToBounds = YES;
     if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]){
         NSArray* bytedata = [[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"BankPicture"];
         unsigned c = bytedata.count;
         uint8_t *bytes = malloc(sizeof(*bytes) * c);
         
         unsigned i;
         for (i = 0; i < c; i++)
         {
             NSString *str = [bytedata objectAtIndex:i];
             int byte = [str intValue];
             bytes[i] = (uint8_t)byte;
         }
         
         NSData *datos = [NSData dataWithBytes:bytes length:c];
         
         
         [imgV setImage:[UIImage imageWithData:datos]];
       
    }

    else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]){
        [imgV setImage:[UIImage imageNamed:@"Icon.png"]];
     }
   else
   {
    NSString*urlImage=[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Photo"];
    [imgV setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
   }
    [customView addSubview:imgV];
    
   
    NSString*TransactionType=@"";
    
    
     if ([[user valueForKey:@"MemberId"] isEqualToString:[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"MemberId"]])
     {
     if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
        TransactionType=@"Paid to :";
     
     }
    }
    
     else
     {
     if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
     TransactionType=@"Payment From :";
        }
     }
    
     if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]){
      TransactionType=@"Deposit Into:";
     }
     else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]){
    
      TransactionType=@"Withdrawal to :";
     }
     else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
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
    
    UILabel*lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(70, 10, 150, 15)];
    
    lblTitle.text=[NSString stringWithFormat:@"%@",TransactionType];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.font=[UIFont systemFontOfSize:13];
    [customView addSubview:lblTitle];
    //
    
    UILabel*lblName=[[UILabel alloc]initWithFrame:CGRectMake(80, 25,150, 15)];
    ////nslog(@"%d",[[marker title]intValue]);
     if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
     {
         lblName.text=@"Nooch";
     }
     else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]&& [[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"BankName"]!=NULL && ![[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"BankName"]isKindOfClass:[NSNull class]]){
         lblName.text=[NSString stringWithFormat:@"%@",[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"BankName"] capitalizedString]];
   
     }
    else
    lblName.text=[NSString stringWithFormat:@"%@ %@",[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"FirstName"] capitalizedString],[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"LastName"]];
    
    lblName.font=[UIFont systemFontOfSize:12];
    lblName.textColor=[UIColor colorWithRed:58.0f/255.0f green:170.0f/255.0f blue:227.0/255.0 alpha:1.0];
    [customView addSubview:lblName];
    
    UILabel*lblAmt=[[UILabel alloc]initWithFrame:CGRectMake(100, 40, 100, 20)];
    lblAmt.text=[NSString stringWithFormat:@"$%@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Amount"]];
    lblAmt.textColor=[UIColor greenColor];
    
    lblAmt.font=[UIFont systemFontOfSize:18];
    [customView addSubview:lblAmt];
    //
    UILabel*lblmemo=[[UILabel alloc]initWithFrame:CGRectMake(65, 60, 150, 25)];
    lblmemo.font=[UIFont systemFontOfSize:10];
    lblmemo.numberOfLines=2;
    
    //lblmemo.textAlignment=NSTextAlignmentCenter;
    if ([[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]!=NULL && ![[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] isKindOfClass:[NSNull class]]) {
        lblmemo.text=[NSString stringWithFormat:@"\"%@\"",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]];
        if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] length]==0) {
            lblmemo.text=@"";
        }
    }
    else
    {
        lblmemo.text=@"";
    }
    lblmemo.textColor=[UIColor lightGrayColor];
    [customView addSubview:lblmemo];
    
    
    UILabel*lblloc=[[UILabel alloc]initWithFrame:CGRectMake(15, 75, 170, 30)];
    
    
//    NSString*address=[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"AddressLine1"] stringByReplacingOccurrencesOfString:@"," withString:@""];
//    address=[address stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSString*city=[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"City"] stringByReplacingOccurrencesOfString:@"," withString:@""];
//    city=[city stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
//    lblloc.text=[NSString stringWithFormat:@"%@,%@",address,city];
     lblloc.textColor=[UIColor whiteColor];
     lblloc.font=[UIFont systemFontOfSize:10.0f];
    
     [customView addSubview:lblloc];
    
     if ([[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionDate"]!=NULL) {
         ////nslog(@"%@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionDate"]);
     NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
         //Set the AM and PM symbols
         [dateFormatter setAMSymbol:@"AM"];
         [dateFormatter setPMSymbol:@"PM"];
         dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
     NSDate *yourDate = [dateFormatter dateFromString:[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionDate"]];
     dateFormatter.dateFormat = @"dd-MMMM-yyyy";
     //[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
     ////nslog(@"%@",[dateFormatter stringFromDate:yourDate]);
      NSString*statusstr;
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
      else
      {
      statusstr=@"Pending:";
      [lblloc setStyleClass:@"green_text"];
      }
      
      }
      else{
      if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
      statusstr=@"Cancelled:";
      [lblloc setStyleClass:@"red_text"];
      }
      else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
      statusstr=@"Rejected:";
      [lblloc setStyleClass:@"red_text"];
      }
      else
      {
      statusstr=@"Pending:";
      [lblloc setStyleClass:@"green_text"];
      }
      }
      
      }
      else if([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Donation"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Received"]||[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Transfer"])
      {
      statusstr=@"Completed on:";
      [lblloc setStyleClass:@"green_text"];
      }
      else if([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"] || [[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Deposit"])
      {
      statusstr=@"Submitted on:";
      [lblloc setStyleClass:@"green_text"];
      }
      else if ([[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"] isEqualToString:@"Invite"]) {
      
      statusstr=@"Invited on:";
      [lblloc setStyleClass:@"green_text"];
      }

      
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
     else
     {
     [lblloc setText:[NSString stringWithFormat:@"%@ %@ %@,%@",statusstr,[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]]];
     }
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
    else
    {
        
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
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]) {
            markerOBJ.icon=[UIImage imageNamed:@"pink-pin.png"];
            
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]) {
            markerOBJ.icon=[UIImage imageNamed:@"Black-pin.png"];
            
        }
        else if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Donation"])
        {
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
     //
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
     //
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
    fp.contentSize = CGSizeMake(200, 355);
    [fp presentPopoverFromPoint:CGPointMake(280, 45)];

}
-(void)dismissFP:(NSNotification *)notification{
    [fp dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismissPopOver" object:nil];
    isSearch=NO;
    if (![listType isEqualToString:@"CANCEL"]&& isFilterSelected) {
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
        [self loadHist:listType index:index len:20 subType:subTypestr];
    }
    else
        isFilter=NO;
    
}

-(void)loadHist:(NSString*)filter index:(int)ind len:(int)len subType:(NSString*)subType{
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([segmentedControl selectedSegmentIndex] == 0) {
        subTypestr=@"Success";
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        self.completed_selected = YES;
        
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }
    else
    {
        subTypestr=@"Pending";
        self.completed_selected = NO;
        [histShowArrayCompleted removeAllObjects];
        [histShowArrayPending removeAllObjects];
        [self loadHist:@"ALL" index:1 len:20 subType:subTypestr];
    }
//    if (isMapOpen) {
//        [self mapPoints];
//    }
   // [self.list removeFromSuperview];
   // [self.view addSubview:self.list];
   // [self.list reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Recent";
    }else{
        return @"";
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,200,30)];
    title.textColor = kNoochGrayDark;
    if (section == 0) {
        title.text = @"Recent";
    }else{
        title.text = @"";
    }
    [headerView addSubview:title];
    [headerView setBackgroundColor:[Helpers hexColor:@"f8f8f8"]];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
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
                ////nslog(@"%@",dictRecord);
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]|| [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]||[[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] ) {
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
                            [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                            
                        }
                        
                    }
                    else
                    {
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                            [amount setStyleClass:@"history_transferamount_pos"];
                            [indicator setStyleClass:@"history_sidecolor_pos"];
                            [amount setText:[NSString stringWithFormat:@"+$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                        }
                    }
                    
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]) {
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue] ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
                    {
                        [amount setStyleClass:@"history_transferamount_pos"];
                        [indicator setStyleClass:@"history_sidecolor_pos"];
                        [amount setText:[NSString stringWithFormat:@"+$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"])
                    {
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                    {
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    
                    [cell.contentView addSubview:amount];
                    [cell.contentView addSubview:indicator];
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];
                    ////nslog(@"%@",[user valueForKey:@"MemberId"]);
                    ////nslog(@"%@",[dictRecord valueForKey:@"MemberId"]);
                    //Updated Balance after Transaction
                    UILabel *updated_balance = [UILabel new];
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]) {
                        [updated_balance setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"] floatValue]]];
                    }
                    else
                    {
                        if (![[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]&& ![[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                            if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]) {
                                if(![[dictRecord valueForKey:@"SenderUpdatedBalanceAfterTransaction"]isKindOfClass:[NSNull class]]&& [dictRecord valueForKey:@"SenderUpdatedBalanceAfterTransaction"]!=NULL){
                                    [updated_balance setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"SenderUpdatedBalanceAfterTransaction"] floatValue]]];
                                    
                                }
                                else{
                                    [updated_balance setText:@""];
                                }

                            }
                            else
                            {
                            if(![[dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"]isKindOfClass:[NSNull class]]&& [dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"]!=NULL){
                                [updated_balance setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"] floatValue]]];
                                
                            }
                            else{
                                
                                [updated_balance setText:@""];
                            }

                            }
                            
                            [updated_balance setStyleClass:@"history_updatedbalance"];
                            [cell.contentView addSubview:updated_balance];
                        }
                        else {
                            [updated_balance setStyleClass:@"history_RequestStatus"];
                            
                            [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                            [cell.contentView addSubview:updated_balance];
                            //[updated_balance removeFromSuperview];
                        }
                    }
                    
                    
                    NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    
                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    
                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                    
                                                                        fromDate:addeddate
                                                    
                                                                          toDate:ServerDate
                                                    
                                                                         options:0];
                    
                    
                    
                    ////nslog(@"%ld", (long)[components day]);
                
                    if ((long)[components day]>3) {
                        
                        
                        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                        //Set the AM and PM symbols
                        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                        [dateFormatter setAMSymbol:@"AM"];
                        [dateFormatter setPMSymbol:@"PM"];
                        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
                        NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                        dateFormatter.dateFormat = @"dd-MMMM-yyyy";
                        //[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                        ////nslog(@"%@",[dateFormatter stringFromDate:yourDate]);
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
                        else{
                            if ((long)[components hour]==1)
                            [date setText:[NSString stringWithFormat:@"%ld hour ago",(long)[components hour]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                            [cell.contentView addSubview:date];
                        }
                        
                    }
                    else
                    {
                        
                        if ((long)[components day]==1) {
                          [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                        }
                        else
                        [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                        [cell.contentView addSubview:date];
                        
                    }
                    
                    
                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
                    pic.layer.borderColor = kNoochGrayDark.CGColor;
                    pic.layer.borderWidth = 1;
                    pic.layer.cornerRadius = 25;
                    pic.clipsToBounds = YES;
                    [cell.contentView addSubview:pic];
                    
                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    [name setStyleClass:@"history_recipientname"];
                    
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]) {
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                            [name setText:[NSString stringWithFormat:@"You Paid %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                            //[pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                              //  placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                            
                        }
                        
                        
                    }
                    else
                    {
                        if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                            [name setText:[NSString stringWithFormat:@"%@ Paid You",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                           //[pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                               // placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                    }
                    
                    
                    
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]){
                        [name setText:@"Deposit into Nooch"];
                        [pic setImage:[UIImage imageNamed:@"Icon.png"]];
                        
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]){
                        [name setText:@"Withdraw from  Nooch"];
                        NSArray* bytedata = [dictRecord valueForKey:@"BankPicture"];
                        unsigned c = bytedata.count;
                        uint8_t *bytes = malloc(sizeof(*bytes) * c);
                        
                        unsigned i;
                        for (i = 0; i < c; i++)
                        {
                            NSString *str = [bytedata objectAtIndex:i];
                            int byte = [str intValue];
                            bytes[i] = (uint8_t)byte;
                        }
                        
                        NSData *datos = [NSData dataWithBytes:bytes length:c];
                        
                        
                        [pic setImage:[UIImage imageWithData:datos]];
                        
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
                        [name setText:[NSString stringWithFormat:@"Donate to %@",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        
                    }
                    
                    
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]){
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                            [name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                        else {
                            [name setText:[NSString stringWithFormat:@"%@ Requested",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                        
                        
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]){
                        
                        
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                            [name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                        else
                        {
                            [name setText:[NSString stringWithFormat:@"%@ Requested",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        }
                        
                    }
                    [cell.contentView addSubview:name];
                    
                }
                
            }
            else if([histTempCompleted count]==indexPath.row){
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];
                

                if (indexPath.row==0)
                [name setText:@"No Records"];
                else
                    [name setText:@""];
                [cell.contentView addSubview:name];

            }
            return cell;
        }
        if ([histShowArrayCompleted count]>indexPath.row) {
            NSDictionary*dictRecord=[histShowArrayCompleted objectAtIndex:indexPath.row];
            ////nslog(@"%@",dictRecord);
            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]|| [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]||[[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] ) {
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
                          [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                          
                      }
                     
                 }
                else
                {
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                        [amount setStyleClass:@"history_transferamount_pos"];
                        [indicator setStyleClass:@"history_sidecolor_pos"];
                        [amount setText:[NSString stringWithFormat:@"+$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                }
                
                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]) {
                    [amount setStyleClass:@"history_transferamount_neg"];
                    [indicator setStyleClass:@"history_sidecolor_neg"];
                    [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue] ]];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
                {
                    [amount setStyleClass:@"history_transferamount_pos"];
                    [indicator setStyleClass:@"history_sidecolor_pos"];
                    [amount setText:[NSString stringWithFormat:@"+$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                }

                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"])
                {
                    [amount setStyleClass:@"history_transferamount_neg"];
                    [indicator setStyleClass:@"history_sidecolor_neg"];
                    [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                {
                    [amount setStyleClass:@"history_transferamount_neg"];
                    [indicator setStyleClass:@"history_sidecolor_neg"];
                    [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                }
                
                [cell.contentView addSubview:amount];
                [cell.contentView addSubview:indicator];
                UILabel *date = [UILabel new];
                [date setStyleClass:@"history_datetext"];
                ////nslog(@"%@",[user valueForKey:@"MemberId"]);
                ////nslog(@"%@",[dictRecord valueForKey:@"MemberId"]);
                //Updated Balance after Transaction
                UILabel *updated_balance = [UILabel new];
                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
                     [updated_balance setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"] floatValue]]];
                else
                {
                    if (![[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]&& ![[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                        if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                        {
                            if(![[dictRecord valueForKey:@"SenderUpdatedBalanceAfterTransaction"]isKindOfClass:[NSNull class]]&& [dictRecord valueForKey:@"SenderUpdatedBalanceAfterTransaction"]!=NULL){
                                [updated_balance setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"SenderUpdatedBalanceAfterTransaction"] floatValue]]];
                                
                            }
                            else{
                                [updated_balance setText:@""];
                            }
                          
                        }
                        else
                        {
                            if(![[dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"]isKindOfClass:[NSNull class]]&& [dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"]!=NULL){
                                [updated_balance setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"ReceiverUpdatedBalanceAfterTransaction"] floatValue]]];
                                
                            }
                            else{
                               
                            [updated_balance setText:@""];
                            }
                        }
                    
                    [updated_balance setStyleClass:@"history_updatedbalance"];
                    [cell.contentView addSubview:updated_balance];
                    }
                    else {
                        [updated_balance setStyleClass:@"history_RequestStatus"];

                        [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                          [cell.contentView addSubview:updated_balance];
                        //[updated_balance removeFromSuperview];
                    }
                }
                
                
                
                NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                
                NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                
                                                                    fromDate:addeddate
                                                
                                                                      toDate:[NSDate date]
                                                
                                                                     options:0];
                
                
                
               // ////nslog(@"%ld", (long)[components day]);
                if ((long)[components day]>3) {
                    
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    //Set the AM and PM symbols
                     [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                    [dateFormatter setAMSymbol:@"AM"];
                    [dateFormatter setPMSymbol:@"PM"];
                    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
                    NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    dateFormatter.dateFormat = @"dd-MMMM-yyyy";
                    //[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                    ////nslog(@"%@",[dateFormatter stringFromDate:yourDate]);
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
                    else{
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
                
                
                UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
                pic.layer.borderColor = kNoochGrayDark.CGColor;
                pic.layer.borderWidth = 1;
                pic.layer.cornerRadius = 25;
                pic.clipsToBounds = YES;
                [cell.contentView addSubview:pic];
                
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];
                if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]]) {
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                        [name setText:[NSString stringWithFormat:@"You Paid %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        
                    }
                    
                    
                }
                else
                {
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
                        [name setText:[NSString stringWithFormat:@"%@ Paid You",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                }
                
                
                
                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]){
                    [name setText:@"Deposit into Nooch"];
                    [pic setImage:[UIImage imageNamed:@"Icon.png"]];
                    
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]){
                    [name setText:@"Withdraw from  Nooch"];
                    NSArray* bytedata = [dictRecord valueForKey:@"BankPicture"];
                    unsigned c = bytedata.count;
                    uint8_t *bytes = malloc(sizeof(*bytes) * c);
                    
                    unsigned i;
                    for (i = 0; i < c; i++)
                    {
                        NSString *str = [bytedata objectAtIndex:i];
                        int byte = [str intValue];
                        bytes[i] = (uint8_t)byte;
                    }
                    
                    NSData *datos = [NSData dataWithBytes:bytes length:c];
                    
                    
                    [pic setImage:[UIImage imageWithData:datos]];

                    
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
                    [name setText:[NSString stringWithFormat:@"Donate to %@",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                    [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    
                }
                /*
                 \[name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]]
                 [name setText:[NSString stringWithFormat:@"%@ Requested",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                 */
                
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]){
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                        [name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                    else {
                        [name setText:[NSString stringWithFormat:@"%@ Requested",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                   
                    
                }
                else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]&& [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]){
                   
                        
                     if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"RecepientId"]]) {
                         [name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                         [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                             placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                     }
                    else
                    {
                    [name setText:[NSString stringWithFormat:@"%@ Requested",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                    [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                    }
                    
                }
                [cell.contentView addSubview:name];
                
                           }
        }
        else if (indexPath.row==[histShowArrayCompleted count]) {
            
            if(isEnd==YES)
            {
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];
                
                
                if (indexPath.row==0)
                    [name setText:@"No Records"];
                else
                    [name setText:@""];
                [cell.contentView addSubview:name];            }
            else if(isStart==YES)
            {
                
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                [activityIndicator startAnimating];
                [cell.contentView addSubview:activityIndicator];
            }
            else
            {
                if (isSearch) {
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                    ishistLoading=YES;
                    index++;
                    [self loadSearchByName];
                }
                else
                {
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
    else
    {
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
                    
                    
                    UILabel *name = [UILabel new];
                    [name setStyleClass:@"history_cell_textlabel"];
                    [name setStyleClass:@"history_recipientname"];
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"])
                        [name setText:[NSString stringWithFormat:@"Donate to %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                    {
                        if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                            [name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                        else
                           [name setText:[NSString stringWithFormat:@"%@ Requested",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                        
                    }
                    
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
                        [name setText:[NSString stringWithFormat:@"Deposit into Nooch%@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL)
                        [name setText:[NSString stringWithFormat:@"You Invited %@",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] )
                    {
                         if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                             [name setText:[NSString stringWithFormat:@"You Disputed a Transfer"]];
                        else
                             [name setText:[NSString stringWithFormat:@"%@ Disputed a Transfer",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    }
                    
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
                      //  [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                        //nslog(@"%@",[dateFormatter stringFromDate:yourDate]);
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
                        else{
                            if ((long)[components hour]==1)
                                [date setText:[NSString stringWithFormat:@"%ld hour ago",(long)[components hour]]];
                            else
                                [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                                [cell.contentView addSubview:date];
                        }
                        
                    }
                    else
                    {
//                        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
//                                                        
//                                                                            fromDate:addeddate
//                                                        
//                                                                              toDate:ServerDate
//                                                        
//                                                                             options:0];
                        //nslog(@"%ld", (long)[components day]);
                        if ((long)[components day]==1)
                            [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                        [cell.contentView addSubview:date];
                        
                    }
                    
                    
                    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
                    pic.layer.borderColor = kNoochGrayDark.CGColor;
                    pic.layer.borderWidth = 1;
                    pic.layer.cornerRadius = 25;
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
                    
                    
                    if (indexPath.row==0)
                        [name setText:@"No Records"];
                    else
                        [name setText:@""];
                    [cell.contentView addSubview:name];
                    
                    
                }
            return cell;
            }
        
        if ([histShowArrayPending count]>indexPath.row) {
            
            NSDictionary*dictRecord=[histShowArrayPending objectAtIndex:indexPath.row];
           // //nslog(@"%@",dictRecord);
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
                
                
                UILabel *name = [UILabel new];
                [name setStyleClass:@"history_cell_textlabel"];
                [name setStyleClass:@"history_recipientname"];
                if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"])
                    [name setText:[NSString stringWithFormat:@"Donate to %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"])
                {
                    if ([[dictRecord valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                        [name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    else
                    [name setText:[NSString stringWithFormat:@"%@ Requested",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    
                }
                else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
                    [name setText:[NSString stringWithFormat:@"Deposit into Nooch%@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
    
                else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] && [dictRecord valueForKey:@"InvitationSentTo"]!=NULL)
                    [name setText:[NSString stringWithFormat:@"You Invited %@",[[dictRecord valueForKey:@"InvitationSentTo"] lowercaseString]]];
                
                else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] )
                {
                    if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                        [name setText:[NSString stringWithFormat:@"You Disputed a Transfer"]];
                    else
                        [name setText:[NSString stringWithFormat:@"%@ Disputed a Transfer",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                }

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
                    //Set the AM and PM symbols
                     [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                    [dateFormatter setAMSymbol:@"AM"];
                    [dateFormatter setPMSymbol:@"PM"];
                    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
                    NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    dateFormatter.dateFormat = @"dd-MMMM-yyyy";
                   // [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                    //nslog(@"%@",[dateFormatter stringFromDate:yourDate]);
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
                    else{
                        if ((long)[components hour]==1)
                            [date setText:[NSString stringWithFormat:@"%ld hour ago",(long)[components hour]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                        [cell.contentView addSubview:date];
                    }
                    
                }
                else
                {
//                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
//                                                    
//                                                                        fromDate:addeddate
//                                                    
//                                                                          toDate:ServerDate
//                                                    
//                                                                         options:0];
                    //nslog(@"%ld", (long)[components day]);
                    if ((long)[components day]==1)
                        [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                    else
                        [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                    [cell.contentView addSubview:date];
                    
                }
                
                
                
                UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
                pic.layer.borderColor = kNoochGrayDark.CGColor;
                pic.layer.borderWidth = 1;
                pic.layer.cornerRadius = 25;
                pic.clipsToBounds = YES;
                [cell.contentView addSubview:pic];
                [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                    placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
            }
        }
        else if (indexPath.row==[histShowArrayPending count]) {
            
            if(isEnd==YES)
            {
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
            else if(isStart==YES)
            {
                
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                [activityIndicator startAnimating];
                [cell.contentView addSubview:activityIndicator];
            }
            else
            {
                if (isSearch) {
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                    ishistLoading=YES;
                    index++;
                    [self loadSearchByName];
                }
                else
                {
                    // [self loadSearchByName];
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
        
        if ([histShowArrayCompleted count]>indexPath.row) {
            NSDictionary*dictRecord=[histShowArrayCompleted objectAtIndex:indexPath.row];
            //NSDictionary *transaction = [NSDictionary new];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
        }
    }
    else
    {
        if ([histShowArrayPending count]>indexPath.row) {
            NSDictionary*dictRecord=[histShowArrayPending objectAtIndex:indexPath.row];
            //NSDictionary *transaction = [NSDictionary new];
            TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
            [self.navigationController pushViewController:details animated:YES];
        }
    }
    
    
}
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
        
        [self loadSearchByName];
        
    }
    [self.search resignFirstResponder];
}
- (void) searchTableView
{
    [histTempCompleted removeAllObjects];
    [histTempPending removeAllObjects];
    for (NSMutableDictionary *tableViewBind in histShowArrayCompleted)
    {
        
        NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
        if (result == NSOrderedSame)
        {
            [histTempCompleted addObject:tableViewBind];
           // NSLog(@"%@",histTempCompleted);
        }
    }
    for (NSMutableDictionary *tableViewBind in histShowArrayPending)
    {
        
        NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchStirng options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchStirng length])];
        if (result == NSOrderedSame)
        {
            [histTempPending addObject:tableViewBind];
        }
    }
    
   
}


-(void)loadSearchByName
{
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
        //isSearch=YES;
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
{  NSError *error;
    [spinner removeFromSuperview];
    //Rlease memory cache
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [Alert show];
        
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        //nslog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
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
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Success!" message:@"Email is in queue.Please check the mail" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
            
        }
        
    }
    else if ([tagName isEqualToString:@"hist"]) {
        //[histArray removeAllObjects];
        //nslog(@"%@",result);
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        //nslog(@"%d",[histArray count]);
        if ([histArray count]>0) {
            isEnd=NO;
            isStart=NO;
            
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]||[[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]||[[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ) {
                    [histShowArrayCompleted addObject:dict];
                }
            }
            for (NSDictionary*dict in histArray) {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"]) {
                    [histShowArrayPending addObject:dict];
                }
            }
            //nslog(@"%@",histArray);
            //nslog(@"%@",histShowArrayPending);
            
        }
        else
        {
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
         [self.list reloadData];
    }
    else if([tagName isEqualToString:@"search"]){
        //[histArray removeAllObjects];
        //nslog(@"%@",result);
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        //nslog(@"%d",[histArray count]);
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
            //nslog(@"%@",histArray);
            //nslog(@"%@",histShowArrayPending);
            
        }
        else
        {
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
    
}
#pragma mark Exporting History
- (IBAction)ExportHistory:(id)sender {
    
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter email ID" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 11;
    [alert show];
    
}
#pragma mark - alert view delegation
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 11)
    {
        if (buttonIndex == 0) {
            //nslog(@"Cancelled");
        }
        else
        {
            NSString * email = [[actionSheet textFieldAtIndex:0] text];
            serve * s = [[serve alloc] init];
            [s setTagName:@"csv"];
            [s setDelegate:self];
            [s sendCsvTrasactionHistory:email];
        }
    }
    
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
