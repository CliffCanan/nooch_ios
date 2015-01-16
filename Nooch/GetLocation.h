//
//  GetLocation.h
//  Nooch
//
//  Created by Vicky Mathneja on 02/01/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GetLocationDelegate <NSObject>

@required
//- (void)locationUpdate:(NSArray *)locations;
- (void)locationError:(NSError *)error;
- (void)transferPinLocationUpdateManager:(CLLocationManager *)manager
                      didUpdateLocations:(NSArray *)locationsArray;
@end
 
@interface GetLocation : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    id delegate;
}
 
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) id <GetLocationDelegate> delegate;

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end