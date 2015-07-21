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
#import "Appirater.h"
#import <AdSupport/AdSupport.h>
#import "SendInvite.h"
#import "HowMuch.h"
#import "Welcome.h"

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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    BOOL notifsEnabled;
    // Try to use the newer isRegisteredForRemoteNotifications otherwise use the enabledRemoteNotificationTypes.
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        notifsEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        notifsEnabled = types & UIRemoteNotificationTypeAlert;
    }

    // GAMETHRIVE (Push Notifications)
    if (notifsEnabled)
    {
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
    }

    // GOOGLE ANALYTICS
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-36976317-2"];
    //tracker_.allowIDFACollection = YES;


    // MOBILE APP TRACKING
    // Account Configuration info - must be set
    [MobileAppTracker initializeWithMATAdvertiserId:@"176306"
                                   MATConversionKey:@"ba7daac2db250d2e7f245ee528c7edb1"];

    // Pass the Apple Identifier for Advertisers (IFA) to MAT; enables accurate 1-to-1 attribution.
    // REQUIRED for attribution on iOS devices.
    [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                         advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
    NSLog(@"advertisingIdentifier is: %@",[[ASIdentifierManager sharedManager] advertisingIdentifier]);
    // enable MAT debug mode
    //[MobileAppTracker setDelegate:self];
    //[MobileAppTracker setDebugMode:NO];
    // Check if deferred deeplink can be opened, with a max timeout value in seconds
    // Uncomment this line if your MAT account has enabled deferred deeplinks
    //[MobileAppTracker checkForDeferredDeeplinkWithTimeout:0.75];

    [MobileAppTracker measureSession];

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
    [ARPowerHookManager registerHookWithId:@"slogan" friendlyName:@"Slogan" defaultValue:@"Money Made Simple"];
    [ARPowerHookManager registerHookWithId:@"HUDcolor" friendlyName:@"HUD Color" defaultValue:@"black"];
    [ARPowerHookManager registerHookWithId:@"reqCodeSetting" friendlyName:@"Require Invite Code" defaultValue:@"no"];
    [ARPowerHookManager registerHookWithId:@"refCode" friendlyName:@"Referral Code" defaultValue:@"NOCODE"];
    [ARPowerHookManager registerHookWithId:@"homeBtnClr" friendlyName:@"Home Button Color" defaultValue:@"green"];
    [ARPowerHookManager registerHookWithId:@"settingsCogIconPos" friendlyName:@"Settings Cog Icon Position" defaultValue:@"bottomBar"];
    [ARPowerHookManager registerHookWithId:@"DispApts" friendlyName:@"Display Apts Section" defaultValue:@"no"];
    [ARPowerHookManager registerHookWithId:@"UseTouchID" friendlyName:@"Enable TouchID as an option" defaultValue:@"no"];

    [ARPowerHookManager registerHookWithId:@"versionNum" friendlyName:@"Most Recent Version Number" defaultValue:@"8.5"];
    [ARPowerHookManager registerHookWithId:@"NV_YorN" friendlyName:@"New Version Alert - Should Display Y or N" defaultValue:@"no"];
    [ARPowerHookManager registerHookWithId:@"NV_HDR" friendlyName:@"New Version Alert Header Txt" defaultValue:@"New Stuff Galore"];
    [ARPowerHookManager registerHookWithId:@"NV_BODY" friendlyName:@"New Version Alert Body Txt" defaultValue:@"Check out the latest updates and enhancements in the newest version of Nooch."];
    [ARPowerHookManager registerHookWithId:@"NV_IMG" friendlyName:@"New Version Alert Image URL" defaultValue:@"https://www.nooch.com/wp-content/uploads/2014/12/ReferralCode_NOCASH.gif"];
    [ARPowerHookManager registerHookWithId:@"NV_IMG_W" friendlyName:@"New Version Alert Img Width" defaultValue:@"180"];
    [ARPowerHookManager registerHookWithId:@"NV_IMG_H" friendlyName:@"New Version Alert Img Height" defaultValue:@"170"];

    [ARPowerHookManager registerHookWithId:@"transLimit" friendlyName:@"Transfer Limit" defaultValue:@"300"];
    [ARPowerHookManager registerHookWithId:@"srchRds" friendlyName:@"Search By Loc Radius (Miles)" defaultValue:@"12"];

    [ARPowerHookManager registerHookWithId:@"transSuccessAlertTitle" friendlyName:@"Alert Title After Transfer Success" defaultValue:@"Nice Work"];
    [ARPowerHookManager registerHookWithId:@"transSuccessAlertMsg" friendlyName:@"Alert Message After Transfer Success" defaultValue:@"\xF0\x9F\x92\xB8\nYour cash was sent successfully."];

    [ARPowerHookManager registerHookWithId:@"knox_OnOff" friendlyName:@"Knox On or Off" defaultValue:@"on"];
    [ARPowerHookManager registerHookWithId:@"synps_OnOff" friendlyName:@"Synapse On or Off" defaultValue:@"off"];
    [ARPowerHookManager registerHookWithId:@"synps_baseUrl" friendlyName:@"Synapse Base URL" defaultValue:@"http://54.201.43.89/noochweb/MyAccounts/Add-Bank.aspx"];

    [ARPowerHookManager registerHookWithId:@"knox_baseUrl" friendlyName:@"Knox Base URL" defaultValue:@"https://knoxpayments.com/pay/index.php"];
    [ARPowerHookManager registerHookWithId:@"knox_Key" friendlyName:@"Knox API Key" defaultValue:@"7068_59cd5c1f5a75c31"];
    [ARPowerHookManager registerHookWithId:@"knox_Pw" friendlyName:@"Knox API Pw" defaultValue:@"7068_da64134cc66a5f0"];
    [ARPowerHookManager registerHookWithId:@"knox_xtraTime" friendlyName:@"Extra No. of days for Knox processing" defaultValue:@"1"];

    [ARPowerHookManager registerHookWithId:@"requireSSN_DOB" friendlyName:@"Should SSN & DoB be required - Y or N" defaultValue:@"no"];

    [ARPowerHookManager registerHookWithId:@"RefCmpgn_YorN" friendlyName:@"Referral Campaign Alert - Should Display Y or N" defaultValue:@"no"];

    [ARPowerHookManager registerHookWithId:@"wlcm_ArtPop" friendlyName:@"Welcome Scrn - Should Display Artisan Popup (or hard-coded bank popup)" defaultValue:@"no"];

    [ARPowerHookManager registerBlockWithId:@"wlcm_goProfile"
                               friendlyName:@"Send user to Profile screen from Welcome screen after signup"
                                       data:@{ @"empty" : @"empty"
                                               }
                                   andBlock:^(NSDictionary *data, id context) {
                                       //Go to Profile
                                       isSignup = YES;
                                       ProfileInfo * profileScrn = [ProfileInfo new];
                                       [nav_ctrl pushViewController:profileScrn animated:YES];
                                   }];
    [ARPowerHookManager registerBlockWithId:@"goToReferScrn"
                               friendlyName:@"Send user to Refer a Friend screen"
                                       data:@{ @"shouldDisplayAlert" : @"NO",
                                               @"alertText" : @"This screen shows your unique Referral Code. Send it out to anyone as often as you'd like and you'll get $5 for each new user who signs up with your code and makes a payment (up to 5 referrals)."
                                             }
                                   andBlock:^(NSDictionary *data, id context) {
                                       sentFromStatsScrn = false;
                                       SendInvite *inv = [SendInvite new];
                                       [nav_ctrl pushViewController:inv animated:YES];

                                       if ([[data[@"shouldDisplayAlert"] lowercaseString] isEqualToString:@"yes"])
                                       {
                                           NSString *message = data[@"alertText"];
                                           UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Like Getting Paid?"
                                                                                              message:message
                                                                                             delegate:context
                                                                                    cancelButtonTitle:@"Ok"
                                                                                    otherButtonTitles:nil, nil];
                                           [alertView show];
                                       }
                                   }];
    [ARPowerHookManager registerBlockWithId:@"MakeADonation"
                               friendlyName:@"Send user to How Much screen to donate to a Featured NonProfit"
                                       data:@{ @"shouldDisplayAlert" : @"NO",
                                               @"recipMembId": @"B3A6CF7B-561F-4105-99E4-406A215CCF60",
                                               @"firstName": @"First Name",
                                               @"lastName": @"Last Name",
                                               @"memo": @"",
                                               @"alertTitle": @"Thank You!",
                                               @"alertText" : @"100% of what you give in this transfer will go to supporting the cause!"
                                            }
                                   andBlock:^(NSDictionary *data, id context) {
                                       if (![[assist shared] getSuspended] &&
                                            [[assist shared] isProfileCompleteAndValidated] &&
                                           ([user boolForKey:@"IsSynapseBankAvailable"] && [user boolForKey:@"IsSynapseBankVerified"]))
                                       {
                                           NSMutableDictionary * recipient = [NSMutableDictionary new];
                                           if (data[@"recipMembId"] != NULL)
                                           {
                                               [recipient setObject:data[@"recipMembId"] forKey:@"MemberId"];
                                               [recipient setObject:data[@"firstName"] forKey:@"FirstName"];
                                               [recipient setObject:data[@"lastName"] forKey:@"LastName"];
                                               [recipient setObject:data[@"memo"] forKey:@"Memo"];
                                               [recipient setObject:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",data[@"recipMembId"]] forKey:@"Photo"];

                                               NSLog(@"AppDelegate --> MakeADonation Powerhook Block --> Recipient object is: %@", recipient);
                                               isFromHome = YES;
                                               isFromMyApt = NO;
                                               isFromArtisanDonationAlert = YES;

                                               HowMuch * howMuchScrn = [[HowMuch alloc] initWithReceiver:recipient];
                                               [nav_ctrl pushViewController:howMuchScrn animated:YES];

                                               if ([[data[@"shouldDisplayAlert"] lowercaseString] isEqualToString:@"yes"])
                                               {
                                                   NSString *avTitle = data[@"alertTitle"];
                                                   NSString *message = [NSString stringWithFormat:@"Awesome, %@!\n\n%@",
                                                                        [user objectForKey:@"firstName"],
                                                                        data[@"alertText"]];
                                                   
                                                   UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:avTitle
                                                                                                      message:message
                                                                                                     delegate:context
                                                                                            cancelButtonTitle:@"Ok"
                                                                                            otherButtonTitles:nil, nil];
                                                   [alertView show];
                                               }
                                           }
                                           else
                                           {
                                               NSLog(@"MEMBER ID WAS NULL :-(");
                                           }
                                       }
                                       else
                                       {
                                           NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];

                                           Home * goHomeScrn = [Home new];
                                           [arrNav replaceObjectAtIndex:0 withObject:goHomeScrn];
                                           [nav_ctrl setViewControllers:arrNav animated:NO];

                                           [nav_ctrl popToRootViewControllerAnimated:YES];
                                       }
                                   }];

    [ARManager startWithAppId:@"5487d09c2b22204361000011"];

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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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
            else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"requiredImmediately"] boolValue])
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
    NSLog(@"applicationDidBecomeActive fired");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        //[MobileAppTracker setExistingUser:YES];
        [[assist shared] getAcctInfo];
    }

    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];

    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

// This method will handle ALL the FB session state changes in the app
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

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
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
        NSLog(@"Badge # is: %ld",(long)[[UIApplication sharedApplication] applicationIconBadgeNumber]);

        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    else
    {
        // Reset the badge if you are using that functionality
        NSLog(@"Badge Number: %ld",(long)[[UIApplication sharedApplication] applicationIconBadgeNumber]);
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Remote Notification Recieved is: %@", userInfo);

    // Reset the badge after a push is received in active or inactive state
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

    if ([[url absoluteString] rangeOfString:@"facebook"].location != NSNotFound)
    {
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

    // If coming from Synapse add bank process
    if ([[url absoluteString] rangeOfString:@"banksuccess"].location != NSNotFound)
    {
        NSLog(@"Bank linked via Synapse successfully");
        //Send Notification to WebView so it can resign itself and to the parent view if desired to handle response and give success notification etc.
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SynapseResponse" object:self];
    }
    // If coming from old Knox add bank process
  /*else if ([[url absoluteString] rangeOfString:@"pay_id"].location != NSNotFound)
    {
        //Get the Response from Knox and parse it
        NSString *response = [[url absoluteString]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray *URLParse = [response componentsSeparatedByString:@"?"];
        NSString *responseBody = URLParse[1];
        NSLog(@"%@",URLParse);
        NSLog(@"%@",responseBody);

        NSArray *responseParse = [responseBody componentsSeparatedByString:@"&"];

        //Parse the components of the response
        NSLog(@"%@",responseParse);
        NSArray * isPaid = [responseParse[0] componentsSeparatedByString:@"pst="][1];
        NSLog(@"%@",isPaid);
        NSString * paymentID = [responseParse[2] componentsSeparatedByString:@"pay_id="][1];

        //Components of response are Logged here
        NSLog(@"fired in Delegate - URL Encoded --> IsPaid: %@   paymentID: %@", isPaid, paymentID);
        [user setObject:isPaid forKey:@"isPaid"];
        [user setObject:paymentID forKey:@"paymentID"];

        [user synchronize];

        //Send Notification to WebView so it can resign itself and to the parent view if desired to handle response and give success notification etc.
        [[NSNotificationCenter defaultCenter]
        postNotificationName:@"KnoxResponse" object:self];
    }*/

    [MobileAppTracker applicationDidOpenURL:[url absoluteString] sourceApplication:sourceApplication];

    return YES;
}

// MAT measurement request success callback
- (void)mobileAppTrackerDidSucceedWithData:(id)data
{
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"MAT.success: %@", response);
}
// MAT measurement request failure callback
- (void)mobileAppTrackerDidFailWithError:(NSError *)error
{
    NSLog(@"MAT.failure: %@", error);
}

@end