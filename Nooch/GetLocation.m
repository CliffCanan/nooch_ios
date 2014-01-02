//
//  GetLocation.m
//  Nooch
//
//  Created by Vicky Mathneja on 02/01/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "GetLocation.h"

@implementation GetLocation

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; // send loc updates to myself
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[self.delegate locationUpdate:newLocation];
    [locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	[self.delegate locationError:error];
}



@end
