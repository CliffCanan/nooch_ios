//
//  splash.m
//  Nooch
//
//  Created by administrator on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "splash.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "JSON.h"

@implementation splash

@synthesize placeMarker, locationManager;

NSString *latitudeField;
NSString *longitudeField;
NSString *altitudeField;

# pragma mark - View lifecycle

- (void)dealloc 
{
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[spinner startAnimating];
    self.navigationController.navigationBar.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"MemberId"];
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [hostReachable startNotifier];

    // getting the current location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];

    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(proceed) userInfo:nil repeats:NO];
    NSLog(@"splash loadedL");
}

- (void)proceed
{
    //[self performSegueWithIdentifier:@"tutPush" sender:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

# pragma mark - Custom Methods

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            break;
        }
        case ReachableViaWiFi:
        {
            break;
        }
        case ReachableViaWWAN:
        {
            break;
        }
    }
}

-(void) updateLocation:latitudeField:longitudeField{
    NSString *fetchURL = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@,%@&amp;output=json&amp;sensor=true", latitudeField, longitudeField];
    NSURL *url = [NSURL URLWithString:fetchURL];
    NSString *htmlData = [NSString stringWithContentsOfURL:url];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:htmlData error:nil];
    NSArray *placemark = [json objectForKey:@"Placemark"];
    
    NSString *state;
    NSString *city;
    
    if ([[[[[placemark objectAtIndex:0]     objectForKey:@"AddressDetails"]objectForKey:@"Country"]objectForKey:@"AdministrativeArea"]objectForKey:@"SubAdministrativeArea"] == NULL){
        NSLog(@"Current location %@",[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"]objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"ThoroughfareName"]);
        
        NSLog(@"Thorough fare %@", [[ NSString alloc] initWithFormat:@"%@",[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"Thoroughfare"] objectForKey:@"ThoroughfareName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"LocalityName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"LocalityName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"AdministrativeAreaName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"CountryName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"PostalCode"] objectForKey:@"PostalCodeNumber"]]);

        state = [[ NSString alloc] initWithFormat:@"%@",[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"AdministrativeAreaName"]];
        city = [[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"LocalityName"]];

    }
    else {
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"Thoroughfare"] objectForKey:@"ThoroughfareName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"LocalityName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"SubAdministrativeAreaName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"AdministrativeAreaName"]]);
        
        NSLog(@"Thorough fare %@",[[ NSString alloc] initWithFormat:@"%@",[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"CountryName"]]);
        
        NSLog(@"Thorough fare %@", [[ NSString alloc] initWithFormat:@"%@",[[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"PostalCode"] objectForKey:@"PostalCodeNumber"]]);
        
        state = [[ NSString alloc] initWithFormat:@"%@",[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"AdministrativeAreaName"]];
        city = [[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"SubAdministrativeAreaName"]];
    }
    
    [[NSUserDefaults standardUserDefaults]setValue:state forKey:@"State"];
    
        
    [[NSUserDefaults standardUserDefaults]setValue:city forKey:@"City"];
    
   }


# pragma mark - CLLocation Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
    
    CLLocationCoordinate2D loc = [newLocation coordinate];
	latitudeField = [NSString stringWithFormat:@"%f",loc.latitude];
	longitudeField = [NSString stringWithFormat:@"%f",loc.longitude];
	altitudeField = [NSString stringWithFormat:@"%f",newLocation.altitude];
    
        
    [locationManager stopUpdatingLocation];
    
    [self updateLocation:latitudeField:longitudeField];
    
}

@end