//
//  GetLocation.m
//  Nooch
//
//  Created by Vicky Mathneja on 02/01/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "GetLocation.h"

@implementation GetLocation

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil)
    {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;

        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
            // Sending a message to avoid compile time error
            [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                       to:self.locationManager
                                                     from:self
                                                 forEvent:nil];
        }
        NSLog(@"3.) GetLocation.M --> Checkpoint REACHED");

        // send loc updates to myself
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"GetLocation.m --> LocationManager NEW didUpdateLocationS is: %@", locations);

    //- (void)transferPinLocationUpdateManager:(CLLocationManager *)managerdidUpdateLocations:(NSArray *)locationsArray

    [self.delegate transferPinLocationUpdateManager:manager didUpdateLocations:locations];
    //[self.delegate locationUpdate: locations];
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
    NSLog(@"LocationManager didFailWithError %@", error);
	[self.delegate locationError:error];
}

@end
