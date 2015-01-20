//
//  AppDelegate.m
//  Nooch
//
//  Created by Preston Hults on 9/7/12.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "AppDelegate.h"
#import <ArtisanSDK/ArtisanSDK.h>
#import <CoreTelephony/CTCallCenter.h>
#import "ReEnterPin.h"
#import "ProfileInfo.h"
#import "METoast.h"
#import "Appirater.h"
@implementation AppDelegate

static NSString *const kTrackingId = @"UA-36976317-2";
@synthesize tracker = tracker_;
@synthesize inactiveDate;
bool modal;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    inBack = NO;
    [Appirater setAppId:@"917955306"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:8];
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

    // Set the icon badge to zero on startup (optional)
    // [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    // GAMETHRIVE (Push Notifications)
    self.gameThrive = [[GameThrive alloc] initWithLaunchOptions:launchOptions handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
        UIAlertView * alertView;
        if (additionalData)
        {
            NSLog(@"APP DEL - GameThrieve --> ADDITIONALDATA: %@", additionalData);
            // Append AdditionalData at the end of the message
            NSString * messageTitle;
            if (additionalData[@"title"]) {
                messageTitle = additionalData[@"title"];
            }

            alertView = [[UIAlertView alloc] initWithTitle:messageTitle
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"Close"
                                         otherButtonTitles:nil, nil];
        }
        // If a push notification is received when the app is being used it does not go to the notifiction center so display in your app.
        if (alertView == nil && isActive)
        {
            alertView = [[UIAlertView alloc] initWithTitle:nil
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"Close"
                                         otherButtonTitles:nil, nil];
        }
        if (alertView != nil)
            [alertView show];
    }];

    //Google Analytics
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-36976317-2"];

    // Whenever a person opens the app, check for a cached FB session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email",@"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    [self application:nil handleOpenURL:[NSURL URLWithString:@"Nooch:"]];
    [self.window makeKeyAndVisible];

    [application setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    [Appirater appLaunched:YES];

    NSSetUncaughtExceptionHandler(&exceptionHandler);

    // ARTISAN SDK
//    [ARPowerHookManager registerHookWithId:@"serverURL" friendlyName:@"Server URL To Use" defaultValue:@"https://www.noochme.com/NoochService/NoochService.svc"];
    [ARPowerHookManager registerHookWithId:@"slogan" friendlyName:@"Slogan" defaultValue:@"Money Made Simple"];
    [ARPowerHookManager registerHookWithId:@"HUDcolor" friendlyName:@"HUD Color" defaultValue:@"black"];
    [ARPowerHookManager registerHookWithId:@"reqCodeSetting" friendlyName:@"Require Invite Code" defaultValue:@"no"];
    [ARPowerHookManager registerHookWithId:@"refCode" friendlyName:@"Referral Code" defaultValue:@"NOCODE"];
    [ARPowerHookManager registerHookWithId:@"versionNum" friendlyName:@"Most Recent Version Number" defaultValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [ARPowerHookManager registerHookWithId:@"homeBtnClr" friendlyName:@"Home Button Color" defaultValue:@"green"];
    [ARPowerHookManager registerHookWithId:@"settingsCogIconPos" friendlyName:@"Settings Cog Icon Position" defaultValue:@"bottomBar"];

    [ARPowerHookManager registerHookWithId:@"NV_HD" friendlyName:@"New Version Alert Header Txt" defaultValue:@"New Stuff Galore"];
    [ARPowerHookManager registerHookWithId:@"NV_BODY" friendlyName:@"New Version Alert Body Txt" defaultValue:@"Check out the latest updates and enhancements in the newest version of Nooch."];
    [ARPowerHookManager registerHookWithId:@"NV_IMG" friendlyName:@"New Version Alert Image URL" defaultValue:@"https://www.nooch.com/wp-content/uploads/2014/12/ReferralCode_NOCASH.gif"];
    [ARPowerHookManager registerHookWithId:@"NV_IMG_W" friendlyName:@"New Version Alert Img Width" defaultValue:@"180"];
    [ARPowerHookManager registerHookWithId:@"NV_IMG_H" friendlyName:@"New Version Alert Img Height" defaultValue:@"170"];

    [ARPowerHookManager registerHookWithId:@"transLimit" friendlyName:@"Transfer Limit" defaultValue:@"300"];
    [ARPowerHookManager registerHookWithId:@"srchRds" friendlyName:@"Search By Loc Radius (Miles)" defaultValue:@"12"];

    [ARPowerHookManager registerHookWithId:@"transSuccessAlertTitle" friendlyName:@"Alert Title After Transfer Success" defaultValue:@"Nice Work"];
    [ARPowerHookManager registerHookWithId:@"transSuccessAlertMsg" friendlyName:@"Alert Message After Transfer Success" defaultValue:@"\xF0\x9F\x92\xB8\nYour cash was sent successfully."];

    [ARManager startWithAppId:@"5487d09c2b22204361000011"];

    [self application:nil handleOpenURL:[NSURL URLWithString:@"Nooch:"]];
    [self.window makeKeyAndVisible];

    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"VersionUpdateNoticeDisplayed"];

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

void exceptionHandler(NSException *exception){
    NSLog(@"Caught exception: %@",exception.description);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
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

    if ([[UIScreen mainScreen] bounds].size.height > 500) {
        splashView.image = [UIImage imageNamed:@"splash@2x.png"];
    } else {
        splashView.image = [UIImage imageNamed:@"splash4.png"];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"App Delegate CheckPoint *applicationWillEnterForeground*");
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
    //[[UAPush shared] resetBadge];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];

    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        NSLog(@"FB Session opened");
        [self userLoggedIn];
        return;
    }

    // If the session is closed
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {
        NSLog(@"FB Session closed");
        [self userLoggedOut];
    }

    // Handle errors
    if (error)
    {
        NSLog(@"FB Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");
            }
            // Handle session closures that happen outside of the app
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
            }
            // For simplicity, here we just show a generic message for all other errors
            // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];

                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        [self userLoggedOut];
    }
}
// Facebook: Show the user the logged-out UI
- (void)userLoggedOut
{
    [user removeObjectForKey:@"facebook_id"];
    [user synchronize];
}

// Facebook: Show the user the logged-in UI
- (void)userLoggedIn
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            // Success! Now set the facebook_id to be the fb_id that was just returned
            [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:@"facebook_id"];
        }
        else
        {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
}
// Show an alert message (For Facebook methods)
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Close the FB Session if active (does not clear the cache of the FB Token)
    [FBSession.activeSession close];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokens = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokens = [deviceTokens stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokens forKey:@"DeviceToken"];
    NSLog(@"DeviceToken%@",deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"App Delegate -> Error in Remove Notification Registration: %@", error);
    [[NSUserDefaults standardUserDefaults] setValue:@"123456" forKey:@"DeviceToken"];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%@",notification.userInfo);
    
    if ([notification.userInfo valueForKey:@"Profile1"] ||
        [notification.userInfo valueForKey:@"Profile2"] ||
        [notification.userInfo valueForKey:@"Profile3"] ||
        [notification.userInfo valueForKey:@"Profile4"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"NotificationPush"];
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Remote Notification Recieved: %@", userInfo);
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        //NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        //[METoast resetToastAttribute];
        //[METoast toastWithMessage:message];
       
        NSLog(@"%d",[[UIApplication sharedApplication] applicationIconBadgeNumber]);
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    else
    {
        // Reset the badge if you are using that functionality
        NSLog(@"Badge Number: %d",[[UIApplication sharedApplication] applicationIconBadgeNumber]);

        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1]; 
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Reset the badge after a push is received in a active or inactive state
    if (application.applicationState != UIApplicationStateBackground)
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}

-(BOOL) application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"URL is: %@",url);
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
