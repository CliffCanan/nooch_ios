//
//  AppDelegate.h
//  Nooch
//
//  Created by Preston Hults on 9/7/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GAI.h"
#import "Reachability.h"

UIImageView *splashView;
bool rainbows;
bool inBack;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIActivityIndicatorView * activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
    UIImageView *noConnectionView;
    UIImageView *rainbowTop;
    UIImageView *rainbowBot;
    Reachability* hostReach;
    Reachability* internetReach;
}
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, retain) id<GAITracker> tracker;
@property(nonatomic,retain) NSDate *inactiveDate;

-(void)showWait:(NSString*)label;
-(void)endWait;
-(void)addRainbow;
-(void)remRainbow;
//-(void)remTopRainbow;
@end
