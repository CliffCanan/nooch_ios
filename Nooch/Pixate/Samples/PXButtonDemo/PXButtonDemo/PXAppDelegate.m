//
//  PXAppDelegate.m
//  PXButtonDemo
//
//  Created by Paul Colton on 6/8/12.
//  Copyright (c) Pixate, Inc. All rights reserved.
//

#import "PXAppDelegate.h"
#import <PXEngine/PXEngine.h>

#import "PXViewController.h"
#import "PXLogoSplashViewController.h"

@implementation PXAppDelegate

@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set licensing information for Pixate Engine
    //[PXEngine licenseKey:@"LICENSE_SERIAL" forUser:@"LICENSE_EMAIL"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    PXLogoSplashViewController *viewController1;
    PXViewController *viewController2;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        viewController1 = [[PXLogoSplashViewController alloc]
                           initWithNibName:@"PXLogoSplashViewController" bundle:nil];

        viewController2 = [[PXViewController alloc]
                           initWithNibName:@"PXButtonDemoView" bundle:nil];
    }
    else
    {
        viewController1 = [[PXLogoSplashViewController alloc]
                           initWithNibName:@"PXLogoSplashViewController_ipad" bundle:nil];
        viewController2 = [[PXViewController alloc]
                           initWithNibName:@"PXButtonDemoView_ipad" bundle:nil];
    }
    

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, nil];
    self.window.rootViewController = self.tabBarController;

    [self.window makeKeyAndVisible];

    return YES;
}

@end
