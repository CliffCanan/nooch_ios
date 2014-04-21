//
//  Home.h
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
// 333b42

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import <Pixate/Pixate.h>
#import "serve.h"
#import "core.h"
#import "NavControl.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "NSString+FontAwesome.h"
#import "FAImageView.h"
core *me;
#define kNoochBlue      [Helpers hexColor:@"41ABE1"]
#define kNoochGreen     [Helpers hexColor:@"72BF44"]
#define kNoochRed       [Helpers hexColor:@"41ABE1"]
#define kNoochPurple    [Helpers hexColor:@"5A538D"]
#define kNoochGrayLight [Helpers hexColor:@"939598"]
#define kNoochGrayDark  [Helpers hexColor:@"414042"]
#define kNoochLight     [Helpers hexColor:@"EBEBEB"]
#define kNoochMenu      [Helpers hexColor:@"58595b"]
#define kNoochFontBold [UIFont fontWithName:@"BrandonGrotesque-Bold" size:22]
#define kNoochFontMed [UIFont fontWithName:@"BrandonGrotesque-Medium" size:16]
#define kNoochFontLt [UIFont fontWithName:@"BrandonGrotesque-Light" size:18]
UINavigationController *nav_ctrl;
NSUserDefaults *user;
@interface Home : UIViewController<serveD,CLLocationManagerDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>
{
    CLLocationManager*locationManager;
    float lat,lon;
    UIView*blankView;
    NSDate*ServerDate;
    NSTimer*timerHome;
}
@end
