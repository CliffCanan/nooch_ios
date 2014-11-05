//
//  AppDelegate.m
//  Nooch
//
//  Created by Preston Hults on 9/7/12.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "AppDelegate.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import <CoreTelephony/CTCallCenter.h>
#import "ReEnterPin.h"
#import "ProfileInfo.h"
#import "METoast.h"
#import "Appirater.h"
#import <FacebookSDK/FacebookSDK.h>
@implementation AppDelegate

static NSString *const kTrackingId = @"UA-36976317-2";
@synthesize tracker = tracker_;
@synthesize inactiveDate;
bool modal;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    inBack = NO;
    [Appirater setAppId:@"917955306"];
    [Appirater setDaysUntilPrompt:8];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    //[Appirater setDebug:YES];
    [GMSServices provideAPIKey:@"AIzaSyDC-JeglFaO1kbXc2Z3ztCgh1AnwfIla-8"];
    inactiveDate = [NSDate date];
    [NSUserDefaults resetStandardUserDefaults];
    [self.window setUserInteractionEnabled:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectCheck:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.google.com"];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];

    //Urban Airship 5+
    UAConfig *config = [UAConfig defaultConfig];
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];
    [UAPush shared].userNotificationTypes = (UIUserNotificationTypeAlert |
                                             UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound);
    //[UAPush shared].userPushNotificationsEnabled = YES;
    // Set the icon badge to zero on startup (optional)
    [[UAPush shared] resetBadge];
    
    //Google Analytics
    [GAI sharedInstance].dispatchInterval = 30;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-36976317-2"];
    
    [self application:nil handleOpenURL:[NSURL URLWithString:@"Nooch:"]];
    [self.window makeKeyAndVisible];

    [application setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    [Appirater appLaunched:YES];
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    return YES;
}

-(void)connectCheck:(NSNotification *)notice
{
    Reachability* curReach = [notice object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus netStat = [curReach currentReachabilityStatus];
    
    if ([self.window.subviews containsObject:noConnectionView] && (netStat == ReachableViaWWAN || netStat == ReachableViaWiFi)) {
        [noConnectionView removeFromSuperview];
        [self.window setUserInteractionEnabled:YES];
    }
    else if (![self.window.subviews containsObject:noConnectionView] && netStat == NotReachable)
    {
        noConnectionView = [[UIImageView alloc] initWithFrame:CGRectMake(0,20,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20)];
        if ([[UIScreen mainScreen] bounds].size.height < 500) {
            noConnectionView.image = [UIImage imageNamed:@"No-Internet-Full-Screen_sm"];
        }
        else if ([[UIScreen mainScreen] bounds].size.height < 1200) {
            noConnectionView.image = [UIImage imageNamed:@"No-Internet-Full-Screen_medium"];
        }
        else if ([[UIScreen mainScreen] bounds].size.height > 1200) {
            noConnectionView.image = [UIImage imageNamed:@"No-Internet-Full-Screen_lg"];
        }
        [self.window addSubview:noConnectionView];
        
        [self.window setUserInteractionEnabled:NO];
    }
}
/*
-(void)showWait:(NSString*)label
{
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(75,( [[UIScreen mainScreen] bounds].size.height/2)-165, 170, 130)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 15.0;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 20, activityView.bounds.size.width, activityView.bounds.size.height);
    [activityView setBackgroundColor:[UIColor clearColor]];
    [loadingView addSubview:activityView];
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 130, 50)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    [loadingLabel setNumberOfLines:2];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
    loadingLabel.text = label;
    [activityView startAnimating];
    [self.window addSubview:loadingView];
}

-(void)endWait{
    [loadingView removeFromSuperview];
} */

void exceptionHandler(NSException *exception){
    NSLog(@"Caught exception: %@",exception.description);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
    /*if (!url) {  return NO; }
     NSString *URLString = [url absoluteString];
     [[NSUserDefaults standardUserDefaults] setObject:URLString forKey:@"url"];5
     [[NSUserDefaults standardUserDefaults] synchronize];
     return YES;*/
}

- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    inBack = YES;
    inactiveDate = [NSDate date];
    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, [[UIScreen mainScreen] bounds].size.height)];
    splashView.image = [UIImage imageNamed:@"Default.png"];
    if ([[UIScreen mainScreen] bounds].size.height > 500) {
        splashView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSTimeInterval timeAway = [inactiveDate timeIntervalSinceNow];
    [splashView removeFromSuperview];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] length] > 0)
    {
        if (timeAway > 30 || timeAway <-30)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pincheck"];
            //init requireImmediately
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"requiredImmediately"])
            {
                ReEnterPin *pin = [ReEnterPin new];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pin animated:YES completion:^{
                    
                }];
            }
            else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"requiredImmediately"] boolValue])
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pincheck"];
                ReEnterPin *pin = [ReEnterPin new];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pin animated:YES completion:^{
                    
                }];
            }
        }
    }
    inBack = NO;
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Set the icon badge to zero on resume (optional)
    [[UAPush shared] resetBadge];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //[UAirship land];
    [FBSession.activeSession close];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokens = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokens = [deviceTokens stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UAPush shared] appRegisteredForRemoteNotificationsWithDeviceToken:deviceToken];
    
  //  [[UAPush shared] registerDeviceToken:deviceToken];
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokens forKey:@"DeviceToken"];
    NSLog(@"DeviceToken%@",deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error in registration. Error: %@", error);
    [[NSUserDefaults standardUserDefaults] setValue:@"123456" forKey:@"DeviceToken"];

}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%@",notification.userInfo);
    
    if ([notification.userInfo valueForKey:@"Profile1"] || [notification.userInfo valueForKey:@"Profile2"] || [notification.userInfo valueForKey:@"Profile3"] || [notification.userInfo valueForKey:@"Profile4"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"NotificationPush"];
        [nav_ctrl popToRootViewControllerAnimated:YES];
        
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userInfo%@", userInfo);
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        [METoast resetToastAttribute];
        [METoast toastWithMessage:message];
        NSLog(@"%d",[[UIApplication sharedApplication] applicationIconBadgeNumber]);
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    else
    {
        [[UAPush shared] appReceivedRemoteNotification:userInfo applicationState:application.applicationState];
        // Reset the badge if you are using that functionality
        [[UAPush shared] resetBadge];
        NSLog(@"%d",[[UIApplication sharedApplication] applicationIconBadgeNumber]);
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1]; 
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
    
    // Optionally provide a delegate that will be used to handle notifications received while the app is running
    // [UAPush shared].pushNotificationDelegate = your custom push delegate class conforming to the UAPushNotificationDelegate protocol
    
    // Reset the badge after a push is received in a active or inactive state
    if (application.applicationState != UIApplicationStateBackground) {
        [[UAPush shared] resetBadge];
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}
/*
- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location != NSNotFound) {
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                            message:@"You will not be able to receive push notifications in the simulator."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        // Let the UI finish launching first so it doesn't complain about the lack of a root view controller
        // Delay execution of the block for 1/2 second.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [someError show];
        });
    }
}*/

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"%@",url);
    if ([[url absoluteString] rangeOfString:@"facebook"].location!=NSNotFound) {
        return [FBAppCall handleOpenURL:url
                      sourceApplication:sourceApplication
                        fallbackHandler:^(FBAppCall *call) {
                            NSLog(@"In fallback handler");
                        }];
   
    }
    if ([sourceApplication isEqualToString:@"com.apple.mobilesafari"] ||
        [sourceApplication isEqualToString:@"com.apple.mobilemail"]) {
        return YES;
    }

    //Get the Response from Knox and parse it
    NSString *response = [[url absoluteString]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *URLParse = [response componentsSeparatedByString:@"?"];
    NSLog(@"%@",URLParse);
    NSString *responseBody = URLParse[1];
    NSLog(@"%@",responseBody);
    NSArray *responseParse = [responseBody componentsSeparatedByString:@"&"];
    
    //Parse the components of the response
    NSLog(@"%@",responseParse);
    NSArray * isPaid = [responseParse[0] componentsSeparatedByString:@"pst="][1];
    NSLog(@"%@",isPaid);
    NSString * paymentID = [responseParse[2] componentsSeparatedByString:@"pay_id="][1];

    //Components of response are Logged here
    NSLog(@"fired in Delegate - URL Encoded --> IsPaid: %@   paymentID: %@", isPaid, paymentID);
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:isPaid forKey:@"isPaid"];
    [defaults setObject:paymentID forKey:@"paymentID"];

    [defaults synchronize];
    
    //Send Notification to WebView so it can resign itself and to the parent view if desired to handle response and give success notification etc.
    [[NSNotificationCenter defaultCenter]
    postNotificationName:@"KnoxResponse" object:self];
    return YES;
}

@end
