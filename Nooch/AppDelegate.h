//
//  AppDelegate.h
//  Nooch
//
//  Created by Preston Hults on 9/7/12.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GAI.h"
#import "Reachability.h"
#import <FacebookSDK/FacebookSDK.h>

UIImageView *splashView;
bool rainbows;
bool inBack;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIActivityIndicatorView * activityView;
    UIView * loadingView;
    UILabel * loadingLabel;
    UIImageView * noConnectionView;
    Reachability * hostReach;
    Reachability * internetReach;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) id<GAITracker> tracker;
@property (nonatomic,retain) NSDate *inactiveDate;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;

@end
