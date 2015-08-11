//
//  AppDelegate.m
//  Nooch
//
//  Created by Cliff Canan on 9/7/12.
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
#import "HistoryFlat.h"
#import "SettingsOptions.h"
#import "IdVerifyImageUpload.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/Analytics.h>
@import GoogleMaps;

@implementation AppDelegate

static NSString *const kTrackingId = @"UA-36976317-2";
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

    // Google Maps
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
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);

    [GAI sharedInstance].dispatchInterval = 15;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];

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

    [ARPowerHookManager registerHookWithId:@"synps_OnOff" friendlyName:@"Synapse On or Off" defaultValue:@"off"];
    [ARPowerHookManager registerHookWithId:@"synps_baseUrl" friendlyName:@"Synapse Base URL" defaultValue:@"http://54.201.43.89/noochweb/MyAccounts/Add-Bank.aspx"];

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

    [ARPowerHookManager registerBlockWithId:@"goTo_IdVerScrn"
                               friendlyName:@"Send user to ID Verification screen to submit image of photo ID."
                                       data:@{ @"empty" : @"empty"
                                               }
                                   andBlock:^(NSDictionary *data, id context) {
                                       if ([user boolForKey:@"IsSynapseBankAvailable"])
                                       {
                                           NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];

                                           for (short i = [arrNav count]; i > 1; i--)
                                           {
                                               [arrNav removeLastObject];
                                           }

                                           SettingsOptions * settingScrn = [SettingsOptions new];
                                           [arrNav addObject: settingScrn];
                                           [nav_ctrl setViewControllers:arrNav animated:NO];

                                           //Go to ID Verify screen
                                           IdVerifyImageUpload * idVer = [IdVerifyImageUpload new];
                                           [nav_ctrl pushViewController:idVer animated:YES];
                                       }
                                   }];


    IdVerifyImageUpload * idVer = [IdVerifyImageUpload new];
    [nav_ctrl pushViewController:idVer animated:YES];

    [ARManager startWithAppId:@"5487d09c2b22204361000011"];

    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"VersionUpdateNoticeDisplayed"];

    if ([FBSDKAccessToken currentAccessToken])
    {
        NSLog(@"App didFinishLaunching -> FB Token Found");
        [self userLoggedIn];
    }
    else
    {
        NSLog(@"App didFinishLaunching -> FB Token NOT Found");
        [self userLoggedOut];
    }

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
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
    [FBSDKAppEvents activateApp];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook Methods

// Facebook: Show the user the logged-in UI
- (void)userLoggedIn
{
    [user setObject:[[FBSDKAccessToken currentAccessToken] userID] forKey:@"facebook_id"];
}

// Facebook: Show the user the logged-out UI
- (void)userLoggedOut
{
    [user removeObjectForKey:@"facebook_id"];
    [user synchronize];
}

#pragma mark - Notification Handling Methods
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokens = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokens = [deviceTokens stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokens forKey:@"DeviceToken"];
    NSLog(@"DeviceToken%@",deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
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

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
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

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Remote Notification Recieved is: %@", userInfo);

    // Reset the badge after a push is received in active or inactive state
    if (application.applicationState != UIApplicationStateBackground)
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark Link Handling
-(BOOL) application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"URL is: %@",url);

    if ([[url absoluteString] rangeOfString:@"facebook"].location != NSNotFound)
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }

    // If coming from Synapse add bank process
    if ([[url absoluteString] rangeOfString:@"banksuccess"].location != NSNotFound)
    {
        NSLog(@"Bank linked via Synapse successfully");
        //Send Notification to WebView so it can resign itself and to the parent view if desired to handle response and give success notification etc.
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SynapseResponse" object:self];
        return YES;
    }

    // DEEP LINK ROUTING
    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path] &&
         [user valueForKey:@"MemberId"] != NULL)
    {
        NSLog(@"AppDelegate -> Open URL checkpoint #2");
        // The user is logged in and we have a MemberId.  Now direct to the right screen...

        // Go to Profile
        if ([[url absoluteString] rangeOfString:@"goprofile"].location != NSNotFound)
        {
            NSLog(@"AppDelegate -> Open URL checkpoint #3");
            sentFromHomeScrn = NO;
            isFromSettingsOptions = NO;
            isProfileOpenFromSideBar = NO;
            isFromTransDetails = NO;

            ProfileInfo * goToProfile = [ProfileInfo new];
            [nav_ctrl pushViewController:goToProfile animated:YES];
        }
        // Go to History
        else if ([[url absoluteString] rangeOfString:@"gohistory"].location != NSNotFound)
        {
            HistoryFlat * goToHistory = [HistoryFlat new];
            [nav_ctrl pushViewController:goToHistory animated:NO];
        }
        // Go to Refer A Friend
        else if ([[url absoluteString] rangeOfString:@"gorefer"].location != NSNotFound)
        {
            SendInvite * goToReferAFriend = [SendInvite new];
            [nav_ctrl pushViewController:goToReferAFriend animated:YES];
        }
        // Go to Settings Main
        else if ([[url absoluteString] rangeOfString:@"gosettings"].location != NSNotFound)
        {
            SettingsOptions * mainSettingsScrn = [SettingsOptions new];
            [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
        }
        // Go to ID Verification Screen
        else if ([[url absoluteString] rangeOfString:@"idver"].location != NSNotFound)
        {
            IdVerifyImageUpload * idVer = [IdVerifyImageUpload new];
            [nav_ctrl pushViewController:idVer animated:YES];
        }
    }

    if ([sourceApplication isEqualToString:@"com.apple.mobilesafari"] ||
        [sourceApplication isEqualToString:@"com.apple.mobilemail"])
    {
        NSLog(@"AppDelegate -> Open URL: Coming from Mobile Safari or Mobile Mail");
        return YES;
    }

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