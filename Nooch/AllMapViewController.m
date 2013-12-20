//
//  AllMapViewController.m
//  Nooch
//
//  Created by Charanjit Singh Bhalla on 11/11/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "AllMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "popSelect.h"
#import "FPPopoverController.h"
#import "history.h"
@interface AllMapViewController ()<GMSMapViewDelegate,FPPopoverControllerDelegate>
{
    history*hist;
    GMSMapView * mapView_;
    GMSCameraPosition *camera;
    GMSMarker *markerOBJ;
    NSDictionary * tempDict;
    FPPopoverController *fp;
}
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;


@end

@implementation AllMapViewController

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
    filterString=@"ALL";
    [self loadMapPoints:filterString];
	// Do any additional setup after loading the view.
    
//    [self.navigationController setNavigationBarHidden:NO];
    
    //maps implementation
    
    
    
   
}
-(void)loadMapPoints:(NSString*)filterStr{
    if (self.pointsList.count>0) {
        NSDictionary*camposition=[self.pointsList objectAtIndex:0];
        camera = [GMSCameraPosition cameraWithLatitude:[[camposition valueForKey:@"lat"] floatValue]
                                             longitude:[[camposition valueForKey:@"lng"] floatValue]
                                                  zoom:1];
    }
    
    mapView_ = [GMSMapView mapWithFrame:[self.mapView frame] camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.delegate=self;
    [self.mapView addSubview:mapView_];
    
    // Creates a marker in the center of the map.
    
    NSLog(@"%@",self.pointsList);
    NSLog(@"filtered %@",filterStr);
    if ([filterStr isEqualToString:@"ALL"]) {
        filterStr=@"All";
    }
    else if ([filterStr isEqualToString:@"SENT"]){
        filterStr=@"Sent";
    }
    else if ([filterStr isEqualToString:@"RECEIVED"]){
      filterStr=@"Received";
    }
    else if ([filterStr isEqualToString:@"REQUEST"]){
        filterStr=@"Request";
    }
    else if ([filterStr isEqualToString:@"DEPOSIT"]){
        filterStr=@"Deposit";
    }
    else if ([filterStr isEqualToString:@"WITHDRAW"]){
        filterStr=@"Withdraw";
    }
    else if ([filterStr isEqualToString:@"DISPUTED"]){
        filterStr=@"Disputed";
    }
    arrFiltered=[[NSMutableArray alloc]init];
    for (NSDictionary*dict in self.pointsList) {
        if (![filterStr isEqualToString:@"All"]) {
            if ([[dict valueForKey:@"TransactionType"]isEqualToString:filterStr]) {
                [arrFiltered addObject:dict];
            }
        }
        else
            [arrFiltered addObject:dict];
    }
    
    for (int i=0; i<arrFiltered.count; i++) {
        
        tempDict = [self.pointsList objectAtIndex:i];
        markerOBJ = [[GMSMarker alloc] init];
        markerOBJ.position = CLLocationCoordinate2DMake([[tempDict objectForKey:@"lat"] floatValue], [[tempDict objectForKey:@"lng"] floatValue]);
        [markerOBJ setTitle:[NSString stringWithFormat:@"%d",i]];
        
        if ([[[arrFiltered objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Received"]) {
            markerOBJ.icon=[UIImage imageNamed:@"blue-pin.png"];
        }
        else if ([[[arrFiltered objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Sent"]) {
            markerOBJ.icon=[UIImage imageNamed:@"orange-pin.png"];
            
        }
        else if ([[[arrFiltered objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Requested"]) {
            markerOBJ.icon=[UIImage imageNamed:@"green-pin.png"];
            
        }
        else if ([[[arrFiltered objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Deposit"]) {
            markerOBJ.icon=[UIImage imageNamed:@"pink-pin.png"];
            
        }
        else if ([[[arrFiltered objectAtIndex:i] valueForKey:@"TransactionType"]isEqualToString:@"Withdraw"]) {
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
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 150)];
    customView.backgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.8];
    UIImageView*imgV=[[UIImageView alloc]initWithFrame:CGRectMake(5, 25, 80, 80)];
    imgV.image=[UIImage imageNamed:@"avtar.png"];
    //imgV.layer.cornerRadius=50.0;
   
    [customView addSubview:imgV];
    UILabel*lblName=[[UILabel alloc]initWithFrame:CGRectMake(5, 105, 250, 17)];
    NSLog(@"%d",[[marker title]intValue]);
    lblName.text=[NSString stringWithFormat:@"%@ %@",[[arrFiltered objectAtIndex:[[marker title]intValue]] valueForKey:@"fname"],[[arrFiltered objectAtIndex:[[marker title]intValue]] valueForKey:@"lname"]];
    lblName.font=[UIFont systemFontOfSize:15];
    lblName.textColor=[UIColor whiteColor];
    [customView addSubview:lblName];
    
    
    //
    UILabel*lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(115, 15, 150, 22)];
    lblTitle.text=[NSString stringWithFormat:@"%@",[[arrFiltered objectAtIndex:[[marker title]intValue]] valueForKey:@"TransactionType"]];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.font=[UIFont systemFontOfSize:20];
    [customView addSubview:lblTitle];
    //
    UILabel*lblAmt=[[UILabel alloc]initWithFrame:CGRectMake(130, 35, 100, 28)];
    lblAmt.text=[NSString stringWithFormat:@"$%@",[[arrFiltered objectAtIndex:[[marker title]intValue]] valueForKey:@"Amount"]];
    lblAmt.textColor=[UIColor greenColor];
    lblAmt.font=[UIFont systemFontOfSize:25];
    [customView addSubview:lblAmt];
    //
    UILabel*lblmemo=[[UILabel alloc]initWithFrame:CGRectMake(100, 85, 150, 15)];
    lblmemo.text=[NSString stringWithFormat:@"%@",[[arrFiltered objectAtIndex:[[marker title]intValue]] valueForKey:@"Memo"]];
    lblmemo.textColor=[UIColor whiteColor];
    [customView addSubview:lblmemo];
    //
    UILabel*lblloc=[[UILabel alloc]initWithFrame:CGRectMake(90, 65, 200, 15)];
    lblloc.text=[NSString stringWithFormat:@"%@ %@",[[arrFiltered objectAtIndex:[[marker title]intValue]] valueForKey:@"City"],[[arrFiltered objectAtIndex:[[marker title]intValue]] valueForKey:@"Country"]];
    lblloc.textColor=[UIColor whiteColor];
    [customView addSubview:lblloc];
    return customView;

}
-(IBAction)filterCLicked:(id)sender{
    //[[NSNotificationCenter defaultCenter]removeObserver:hist];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    mapfilter=YES;
    memoList=YES;
    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = nil;
    fp =  [[FPPopoverController alloc] initWithViewController:popOver];
    fp.border = NO;
    fp.delegate=self;
    fp.tint = FPPopoverWhiteTint;
    fp.arrowDirection = FPPopoverArrowDirectionUp;
    fp.contentSize = CGSizeMake(200, 355);
    [fp presentPopoverFromPoint:CGPointMake(280, 45)];

}
-(void)dismissFP:(NSNotification *)notification{
    [fp dismissPopoverAnimated:YES];
     [self loadMapPoints:filterString];
   }

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LeftBarbuttonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
