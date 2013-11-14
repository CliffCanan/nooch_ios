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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                           longitude:151.20
                                                                zoom:6];
    mapView_ = [GMSMapView mapWithFrame:[self.mapView frame] camera:camera];
    mapView_.myLocationEnabled = YES;
    self.mapView = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;


    
    
    
    
    
    
    
    
    
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

@end
