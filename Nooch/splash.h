//
//  splash.h
//  Nooch
//
//  Created by administrator on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Reachability;

@interface splash : UIViewController<CLLocationManagerDelegate>
{
    IBOutlet UIActivityIndicatorView *spinner;
    NSMutableData *responseData;
    Reachability* internetReachable;
    Reachability* hostReachable;
    NSTimer *idleTimer;
    
    CLLocationManager *locationManager;
    IBOutlet UILabel *latLabel;
    IBOutlet UILabel *longLabel;
    IBOutlet UILabel *altLabel;
    NSString *latlng;
    MKReverseGeocoder *reverseGeocoder;
    MKPlacemark *placeMarker;
}

@property (nonatomic, retain) MKPlacemark *placeMarker;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end




