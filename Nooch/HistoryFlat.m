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
    // [nav_ctrl performSelector:@selector(disable)];
	// Do any additional setup after loading the view.
//    [self.slidingViewController.panGesture setEnabled:YES];
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    histArray=[[NSMutableArray alloc]init];
    histShowArrayCompleted=[[NSMutableArray alloc]init];
    histShowArrayPending=[[NSMutableArray alloc]init];
    listType=@"ALL";
    index=1;
    isStart=YES;

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
    NSLog(@"%@",[self.search subviews]);
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
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:spinner];
    [spinner stopAnimating];
    [spinner setHidden:YES];
//    //clear Image cache
//    SDImageCache *imageCache = [SDImageCache sharedImageCache];
//    [imageCache clearMemory];
//    [imageCache clearDisk];
//    [imageCache cleanDisk];
    [self loadHist:@"ALL" index:index len:20];
    //    //Export History
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
    
}
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    customView.layer.borderColor=[[UIColor whiteColor]CGColor];
    customView.layer.borderWidth=1.0f;
    
    customView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mapBack.png"]];
    UIImageView*imgV=[[UIImageView alloc]initWithFrame:CGRectMake(5, 15, 50, 50)];
    
    imgV.layer.cornerRadius = 25; imgV.layer.borderColor = kNoochBlue.CGColor; imgV.layer.borderWidth = 1;
    imgV.clipsToBounds = YES;
    NSString*urlImage=[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Photo"];
    [imgV setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
    
    [customView addSubview:imgV];
    
    UILabel*lblName=[[UILabel alloc]initWithFrame:CGRectMake(5, 70, 250, 17)];
    NSLog(@"%d",[[marker title]intValue]);
    lblName.text=[NSString stringWithFormat:@"%@ %@",[[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"FirstName"] capitalizedString],[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"LastName"]];
    lblName.font=[UIFont systemFontOfSize:15];
    lblName.textColor=[UIColor whiteColor];
    [customView addSubview:lblName];
    
    
    //
    UILabel*lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(90, 10, 150, 17)];
    lblTitle.text=[NSString stringWithFormat:@"%@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.font=[UIFont systemFontOfSize:17];
    [customView addSubview:lblTitle];
    //
    UILabel*lblAmt=[[UILabel alloc]initWithFrame:CGRectMake(100, 25, 100, 20)];
    lblAmt.text=[NSString stringWithFormat:@"$%@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Amount"]];
    lblAmt.textColor=[UIColor greenColor];
    lblAmt.font=[UIFont systemFontOfSize:18];
    [customView addSubview:lblAmt];
    //
    UILabel*lblmemo=[[UILabel alloc]initWithFrame:CGRectMake(85, 55, 150, 15)];
    if ([[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]!=NULL && ![[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"] isKindOfClass:[NSNull class]]) {
        lblmemo.text=[NSString stringWithFormat:@"%@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]];
        
    }
    else
    {
        lblmemo.text=@"";
    }
    lblmemo.textColor=[UIColor whiteColor];
    [customView addSubview:lblmemo];
    //
    UILabel*lblloc=[[UILabel alloc]initWithFrame:CGRectMake(80, 50, 200, 30)];
    lblloc.text=[NSString stringWithFormat:@"%@ %@",[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"City"],[[histArrayCommon objectAtIndex:[[marker title]intValue]] valueForKey:@"Country"]];
    lblloc.textColor=[UIColor whiteColor];
    lblloc.font=[UIFont systemFontOfSize:12.0f];
    lblloc.numberOfLines=2;
    [customView addSubview:lblloc];
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
        
        if ([[[histArrayCommon objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Received"]) {
            markerOBJ.icon=[UIImage imageNamed:@"blue-pin.png"];
        }
        else if ([[[histShowArrayCompleted objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Sent"]) {
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
        else
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
    NSLog(@"float  %f",firstX+translatedPoint.x);
     CGFloat animationDuration = 0.2;
    CGFloat velocityX = (0.0*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
    
    
    CGFloat finalX = translatedPoint.x + velocityX;
    NSLog(@"%f",finalX);
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
      NSLog(@"%f",finalX);
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
      
      NSLog(@"the duration is: %f", animationDuration);

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
    isSearch=NO;
    if (![listType isEqualToString:@"CANCEL"]) {
        histShowArrayCompleted=[[NSMutableArray alloc]init];
        histShowArrayPending=[[NSMutableArray alloc]init];

        isFilter=YES;
        index=1;
        [self loadHist:listType index:index len:20];
    }
    else
        isFilter=NO;
    
}

-(void)loadHist:(NSString*)filter index:(int)ind len:(int)len{
    
    if (index!=1 || isFilter==YES) {
        [spinner setHidden:NO];
        [spinner startAnimating];
        

    }
    isSearch=NO;
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName=@"hist";
    [serveOBJ histMore:filter sPos:ind len:len];
}
#pragma mark - transaction type switching
- (void) completed_or_pending:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([segmentedControl selectedSegmentIndex] == 0) {
        
        self.completed_selected = YES;
    }
    else
    {
        self.completed_selected = NO;
    }
    if (isMapOpen) {
        [self mapPoints];
    }
    [self.list removeFromSuperview];
    [self.view addSubview:self.list];
    [self.list reloadData];
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
        return [histShowArrayCompleted count]+1;
    } else {
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
        
        if ([histShowArrayCompleted count]>indexPath.row) {
                NSDictionary*dictRecord=[histShowArrayCompleted objectAtIndex:indexPath.row];
            NSLog(@"%@",dictRecord);
                if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]) {
                    UIView *indicator = [UIView new];
                    [indicator setStyleClass:@"history_sidecolor"];
                    
                    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                    [amount setBackgroundColor:[UIColor clearColor]];
                    [amount setTextAlignment:NSTextAlignmentRight];
                    [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
                    [amount setStyleClass:@"history_transferamount"];
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
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Received"])
                    {
                        [amount setStyleClass:@"history_transferamount_pos"];
                         [indicator setStyleClass:@"history_sidecolor_pos"];
                        [amount setText:[NSString stringWithFormat:@"+$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Sent"])
                    {
                        [amount setStyleClass:@"history_transferamount_neg"];
                       [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"])
                    {
                        [amount setStyleClass:@"history_transferamount_neg"];
                        [indicator setStyleClass:@"history_sidecolor_neg"];
                        [amount setText:[NSString stringWithFormat:@"-$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]  ]];
                    }
                    
                    
                    [cell.contentView addSubview:amount];
                    [cell.contentView addSubview:indicator];
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];
                    
               
                    
                    NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    
                    
                    
                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    
                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                    
                                                                        fromDate:addeddate
                                                    
                                                                          toDate:[NSDate date]
                                                    
                                                                         options:0];
                    
                    
                    
                    NSLog(@"%ld", (long)[components day]);
                    if ((long)[components day]>3) {
                        
                        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
                        NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                        dateFormatter.dateFormat = @"dd-MMMM-yyyy";
                        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                        NSLog(@"%@",[dateFormatter stringFromDate:yourDate]);
                        NSArray*arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
                        [date setText:[NSString stringWithFormat:@"%@ %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0]]];
                        [cell.contentView addSubview:date];
                       

  
                 }
                   else if ((long)[components day]==0)
                   {
                       NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                                                       
                                                                           fromDate:addeddate
                                                       
                                                                             toDate:[NSDate date]
                                                       
                                                                            options:0];
                         NSLog(@"%ld", (long)[components hour]);
                       [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                        [cell.contentView addSubview:date];

                       
                   }
                   else
                   {
                       NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                       
                                                                           fromDate:addeddate
                                                       
                                                                             toDate:[NSDate date]
                                                       
                                                                            options:0];
                       NSLog(@"%ld", (long)[components day]);
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
                     if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Received"]) {

                           [name setText:[NSString stringWithFormat:@"%@ Paid You",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                           [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                               placeholderImage:[UIImage imageNamed:@"RoundLoading"]];

                       
                     }
                   else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Sent"]) {
                       
                            [name setText:[NSString stringWithFormat:@"You Paid %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                            [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                     
                    }
                    

                 
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]){
                        [name setText:@"Deposit into Nooch"];
                        [pic setImage:[UIImage imageNamed:@"Icon.png"]];
                        
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]){
                        [name setText:@"Withdraw from  Nooch"];
                        [pic setImage:[UIImage imageNamed:@"Icon.png"]];
                        
                    }
                    else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
                        [name setText:[NSString stringWithFormat:@"%@ Donate to",[[dictRecord valueForKey:@"FirstName"]capitalizedString]]];
                        [pic setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                            placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                        
                    }
                    
                    
                    [cell.contentView addSubview:name];
                   
//                    UILabel *updated_balance = [UILabel new];
//                    [updated_balance setText:@"$50.00"];
//                    [updated_balance setStyleClass:@"history_updatedbalance"];
//                    [cell.contentView addSubview:updated_balance];
                }
        }
     else if (indexPath.row==[histShowArrayCompleted count]) {
         
          if(isEnd==YES)
         {
             UILabel *name = [UILabel new];
             [name setStyleClass:@"history_cell_textlabel"];
             [name setStyleClass:@"history_recipientname"];
             if (indexPath.row == 0) {
                 [name setText:@"No Records"];
             }
             [cell.contentView addSubview:name];
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
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2, cell.contentView.frame.size.height / 2);
            [activityIndicator startAnimating];
            [cell.contentView addSubview:activityIndicator];
           ishistLoading=YES;
           index++;
           [self loadHist:listType index:index len:20];
             }
         }
        }
       
        }
    else
    {
        
        
        if ([histShowArrayPending count]>indexPath.row) {
           
                NSDictionary*dictRecord=[histShowArrayPending objectAtIndex:indexPath.row];
            NSLog(@"%@",dictRecord);
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
                    if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Donation"]) {
                        if ([[dictRecord valueForKey:@"MemberId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) {
                            [name setText:[NSString stringWithFormat:@"Donate to %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                        }
                        else
                        {
                           [name setText:[NSString stringWithFormat:@"Donation From %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                            
                        }
                        
                    }
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Request"]|| [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@""])
                    {
                        if ([[dictRecord valueForKey:@"MemberId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) {
                            [name setText:[NSString stringWithFormat:@"%@ Requested From You",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                            
                        }
                        else
                        {
                             [name setText:[NSString stringWithFormat:@"You Requested From %@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                           
                            
                        }
                   
                    }
                    else if([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Deposit"])
                    {
                        [name setText:[NSString stringWithFormat:@"Deposit into Nooch%@",[[dictRecord valueForKey:@"FirstName"] capitalizedString]]];
                    }
                    [cell.contentView addSubview:name];
                    
                    
                    UILabel *date = [UILabel new];
                    [date setStyleClass:@"history_datetext"];
                    //[date setText:[dictRecord valueForKey:@"TransactionDate"]];
                   // [cell.contentView addSubview:date];
                    NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    
                    
                    
                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    
                    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                    
                                                                        fromDate:addeddate
                                                    
                                                                          toDate:[NSDate date]
                                                    
                                                                         options:0];
                    
                    
                    
                    NSLog(@"%ld", (long)[components day]);
                    if ((long)[components day]>3) {
                        
                        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
                        NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                        dateFormatter.dateFormat = @"dd-MMMM-yyyy";
                        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                        NSLog(@"%@",[dateFormatter stringFromDate:yourDate]);
                        NSArray*arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
                        [date setText:[NSString stringWithFormat:@"%@ %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0]]];
                        [cell.contentView addSubview:date];
                        
                        
                        
                    }
                    else if ((long)[components day]==0)
                    {
                        NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                                                        
                                                                            fromDate:addeddate
                                                        
                                                                              toDate:[NSDate date]
                                                        
                                                                             options:0];
                        NSLog(@"%ld", (long)[components hour]);
                        [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                        [cell.contentView addSubview:date];
                        
                        
                    }
                    else
                    {
                        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        
                                                                            fromDate:addeddate
                                                        
                                                                              toDate:[NSDate date]
                                                        
                                                                             options:0];
                        NSLog(@"%ld", (long)[components day]);
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

                if (indexPath.row == 0) {
                    [name setText:@"No Records"];
                }
                
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
           [self loadHist:listType index:index len:20];
               }
            }
        }
    }
    
       return cell;
}
- (NSDate*) dateFromString:(NSString*)aStr
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    //[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss a"];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSLog(@"%@", aStr);
    NSDate   *aDate = [dateFormatter dateFromString:aStr];
    
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
        self.search.text=@"";
        [self.search resignFirstResponder];
        [self loadHist:listType index:index len:20];
    
   // }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([searchBar.text length]>0) {
        listType=@"ALL";
        SearchStirng=self.search.text;
        histShowArrayCompleted=[[NSMutableArray alloc]init];
        histShowArrayPending=[[NSMutableArray alloc]init];
        index=1;
        isSearch=YES;
        isFilter=NO;
        [self loadSearchByName];
        
    }
    [self.search resignFirstResponder];
    }
-(void)loadSearchByName
{
    
        [spinner setHidden:NO];
        [spinner startAnimating];
    
    
    listType=@"ALL";
   
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"search";
    [serveOBJ setDelegate:self];
    [serveOBJ histMoreSerachbyName:listType sPos:index len:20 name:SearchStirng];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
}
-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
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
    [spinner setHidden:YES];
    [spinner stopAnimating];

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [Alert show];
        
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
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
        //   {"sendTransactionInCSVResult":{"Result":"1"}}
    }
    else if ([tagName isEqualToString:@"hist"]) {
        //[histArray removeAllObjects];
        NSLog(@"%@",result);
       histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%d",[histArray count]);
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
            NSLog(@"%@",histArray);
            NSLog(@"%@",histShowArrayPending);
            
        }
        else
        {
            isEnd=YES;
        }
        if (isMapOpen) {
            [self mapPoints];
        }
        [self.list reloadData];
    }
    else if([tagName isEqualToString:@"search"]){
        //[histArray removeAllObjects];
        NSLog(@"%@",result);
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%d",[histArray count]);
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
            NSLog(@"%@",histArray);
            NSLog(@"%@",histShowArrayPending);
            
        }
        else
        {
            isEnd=YES;
        }
        if (isMapOpen) {
            [self mapPoints];
        }
        [self.list reloadData];
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
            NSLog(@"Cancelled");
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
    // Dispose of any resources that can be recreated.
}

@end
