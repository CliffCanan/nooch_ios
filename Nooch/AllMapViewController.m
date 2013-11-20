//
//  AllMapViewController.m
//  Nooch
//
//  Created by Charanjit Singh Bhalla on 11/11/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "AllMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AllMapViewController ()
{
    GMSMapView * mapView_;
    GMSCameraPosition *camera;
    GMSMarker *marker;
    NSDictionary * tempDict;
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
	// Do any additional setup after loading the view.
    
//    [self.navigationController setNavigationBarHidden:NO];
    
    //maps implementation
    if (self.pointsList.count>0) {
        NSDictionary*camposition=[self.pointsList objectAtIndex:0];
        camera = [GMSCameraPosition cameraWithLatitude:[[camposition valueForKey:@"lat"] floatValue]
                                             longitude:[[camposition valueForKey:@"lng"] floatValue]
                                                  zoom:1];
    }
    
    mapView_ = [GMSMapView mapWithFrame:[self.mapView frame] camera:camera];
    mapView_.myLocationEnabled = YES;
    [self.mapView addSubview:mapView_];
    
    // Creates a marker in the center of the map.

    NSLog(@"%@",self.pointsList);
    
    
    for (int i=0; i<self.pointsList.count; i++) {
        tempDict = [self.pointsList objectAtIndex:i];
        marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([[tempDict objectForKey:@"lat"] floatValue], [[tempDict objectForKey:@"lng"] floatValue]);
        marker.title = [tempDict objectForKey:@"fname"];
        marker.snippet = [tempDict objectForKey:@"lname"];
        marker.animated=YES;
        marker.map = mapView_;

    }
    
    
    
    
    
    
    
    
    
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
