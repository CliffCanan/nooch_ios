//
//  GetLocation.h
//  Nooch
//
//  Created by Vicky Mathneja on 02/01/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
 @protocol GetLocationDelegate <NSObject>
 @required
 - (void)locationUpdate:(CLLocation *)location;
 - (void)locationError:(NSError *)error;
 @end
 
 @interface GetLocation : NSObject <CLLocationManagerDelegate> {
 CLLocationManager *locationManager;
 id delegate;
 }
 
 @property (nonatomic, retain) CLLocationManager *locationManager;
 @property (nonatomic, retain) id <GetLocationDelegate> delegate;
 
 - (void)locationManager:(CLLocationManager *)manager
 didUpdateToLocation:(CLLocation *)newLocation
 fromLocation:(CLLocation *)oldLocation;
 
 - (void)locationManager:(CLLocationManager *)manager
 didFailWithError:(NSError *)error;
 
 @end
