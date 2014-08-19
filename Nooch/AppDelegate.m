//
//  AppDelegate.m
//  Nooch
//
//  Created by Preston Hults on 9/7/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "AppDelegate.h"
#import "UAirship.h"
#import "UAPush.h"
#import <CoreTelephony/CTCallCenter.h>
#import "ReEnterPin.h"
#import "ProfileInfo.h"
#import "ECSlidingViewController.h"
#import "METoast.h"
@implementation AppDelegate

static NSString *const kTrackingId = @"UA-36976317-2";
@synthesize tracker = tracker_;
@synthesize inactiveDate;
bool modal;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    inBack = NO;//AIzaSyDC-JeglFaO1kbXc2Z3ztCgh1AnwfIla-8
    [GMSServices provideAPIKey:@"AIzaSyC4wAna1yxgCUsnqHmazama92ZTSz1qrIA"];
    inactiveDate = [NSDate date];
    [NSUserDefaults resetStandardUserDefaults];
    [self.window setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectCheck:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.google.com"];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    //google analytics
    [GAI sharedInstance].debug = NO;
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];

    // Override point for customization after application launch.
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    [UAirship takeOff:takeOffOptions];
    [[UAPush shared] resetBadge];
    [[UAPush shared] setPushEnabled:YES];
    [[UAPush shared] registerForRemoteNotificationTypes: UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    [self application:nil handleOpenURL:[NSURL URLWithString:@"Nooch:"]];
    [self.window makeKeyAndVisible];

    [application setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    NSSetUncaughtExceptionHandler(&exceptionHandler);
   // [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeNone];
    return YES;
}

-(void)connectCheck:(NSNotification *)notice{
    Reachability* curReach = [notice object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus netStat = [curReach currentReachabilityStatus];
    
    if ([self.window.subviews containsObject:noConnectionView] && (netStat == ReachableViaWWAN || netStat == ReachableViaWiFi)) {
        [noConnectionView removeFromSuperview];
        [self.window setUserInteractionEnabled:YES];
    }else if(![self.window.subviews containsObject:noConnectionView] && netStat == NotReachable){
        noConnectionView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, [[UIScreen mainScreen] bounds].size.height)];
        noConnectionView.image = [UIImage imageNamed:@"No.png"];
        [self.window addSubview:noConnectionView];
        [self.window setUserInteractionEnabled:NO];
    }
}

-(void)addRainbow{
    [self.window addSubview:rainbowTop];
}

-(void)remRainbow{
    [rainbowTop removeFromSuperview];
}

-(void)remTopRainbow{
    [rainbowTop removeFromSuperview];
}

-(void)showWait:(NSString*)label{
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
    //[loadingLabel setFont:[core nFont:@"Medium" size:15]];
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
}

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
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSTimeInterval timeAway = [inactiveDate timeIntervalSinceNow];
    [splashView removeFromSuperview];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] length] > 0) {
        if (timeAway > 30 || timeAway < -30) {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pincheck"];
            //init requireImmediately
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"requiredImmediately"]) {
                ReEnterPin *pin = [ReEnterPin new];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pin animated:YES completion:^{
                    
                }];
            }
            else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"requiredImmediately"] boolValue]){
                
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pincheck"];
                ReEnterPin *pin = [ReEnterPin new];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pin animated:YES completion:^{
                    
                }];
            }
        }
    }
    inBack = NO;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [UAirship land];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *deviceTokens = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokens = [deviceTokens stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UAPush shared] registerDeviceToken:deviceToken];
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokens forKey:@"DeviceToken"];
    NSLog(@"DeviceToken%@",deviceToken);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Error in registration. Error: %@", error);
    [[NSUserDefaults standardUserDefaults] setValue:@"123456" forKey:@"DeviceToken"];

}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%@",notification.userInfo);
    if ([notification.userInfo valueForKey:@"Profile1"]|| [notification.userInfo valueForKey:@"Profile2"]||[notification.userInfo valueForKey:@"Profile3"]||[notification.userInfo valueForKey:@"Profile4"]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"NotificationPush"];
        [nav_ctrl popToRootViewControllerAnimated:YES];
//        [UIView animateWithDuration:0.75
//                         animations:^{
//                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:nav_ctrl.view cache:NO];
//                         }];
//        
//        [nav_ctrl.view addGestureRecognizer:nav_ctrl.slidingViewController.panGesture];
//        
       // [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:profile animated:YES completion:^{
            
       // }];
        
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"userInfo%@", userInfo);
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        [METoast resetToastAttribute];
        [METoast toastWithMessage:message];
        NSLog(@"%d",[[UIApplication sharedApplication] applicationIconBadgeNumber]);
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    else{
    [[UAPush shared] handleNotification:userInfo
                       applicationState:application.applicationState];
    // Reset the badge if you are using that functionality
    
    [[UAPush shared] setBadgeNumber:0];
    [[UAPush shared] resetBadge];
        NSLog(@"%d",[[UIApplication sharedApplication] applicationIconBadgeNumber]);
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1]; 
    }// zero badge after push received
   
    
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"%@",url);
    //Get the Response from Knox and parse it
    NSString *response = [[url absoluteString]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *URLParse = [response componentsSeparatedByString:@"?"];
    NSLog(@"%@",URLParse);
    NSString *responseBody = URLParse[1];
     NSLog(@"%@",responseBody);
    NSArray *responseParse = [responseBody componentsSeparatedByString:@"&"];
    //Parse the components of the response
      NSLog(@"%@",responseParse);
    NSArray *isPaid = [responseParse[0] componentsSeparatedByString:@"pst="][1];
      NSLog(@"%@",isPaid);
    NSString *paymentID = [responseParse[2] componentsSeparatedByString:@"pay_id="][1];
    NSString *imageURL = [responseParse[5] componentsSeparatedByString:@"bank_image="][1];
    NSString *bname = [responseParse[4] componentsSeparatedByString:@"bank_name="][1];
    NSString *accountName = [responseParse[3] componentsSeparatedByString:@"account_name="][1];
    //Components of response are Logged here - you may want to store them in your Database or check to make sure the reponse includes "Paid"
    NSLog(@"fired in Delegate - URL Encoded %@ %@ %@ %@ %@", isPaid, paymentID,accountName,imageURL,bname);
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:isPaid forKey:@"isPaid"];
     [defaults setObject:imageURL forKey:@"BankImageURL"];
     [defaults setObject:bname forKey:@"BankName"];
     [defaults setObject:accountName forKey:@"AccountName"];
   [defaults setObject:paymentID forKey:@"paymentID"];
    [defaults synchronize];
    
        //Handle the response using our private API
    //    NSString *apiURL = [NSString stringWithFormat:@"http://paidez.com/api/trz.php?trans_id=%@",paymentID];
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //    [request setHTTPMethod:@"GET"];
    //    [request setURL:[NSURL URLWithString:apiURL]];
    //
    //    NSError *error = [[NSError alloc] init];
    //    NSHTTPURLResponse *responseCode = nil;
    //
    //    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    //
    //    if([responseCode statusCode] != 200){
    //        NSLog(@"Error getting %@, HTTP status code %li", apiURL, (long)[responseCode statusCode]);
    //    }
    //
    //    NSString *knoxpayments = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
    //
    //    NSData *data = [knoxpayments dataUsingEncoding:NSUTF8StringEncoding];
    //
    //    NSError *e = nil;
    //    NSLog(@"%@",data);
    //Send Notification to WebView so it can resign itself and to the parent view if desired to handle response and give success notification etc.
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"KnoxResponse" object:self];
    return YES;
}

@end
