//
//  Home.h
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "serve.h"
#import "core.h"
#import "NavControl.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "NSString+FontAwesome.h"
#import "FAImageView.h"
#import "iCarousel.h"
core *me;
#define kNoochBlue      [Helpers hexColor:@"41ABE1"]
#define kNoochGreen     [Helpers hexColor:@"72BF44"]
#define kNoochRed       [Helpers hexColor:@"EA2C28"]
#define kNoochPurple    [Helpers hexColor:@"5A538D"]
#define kNoochGrayLight [Helpers hexColor:@"939598"]
#define kNoochGrayDark  [Helpers hexColor:@"414042"]
#define kNoochLight     [Helpers hexColor:@"EBEBEB"]
#define kNoochMenu      [Helpers hexColor:@"58595b"]
#define kLeftMenuShadow [Helpers hexColor:@"202122"]
#define Rgb2UIColor(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]
#define kNoochFontBold [UIFont fontWithName:@"BrandonGrotesque-Bold" size:22]
#define kNoochFontMed [UIFont fontWithName:@"BrandonGrotesque-Medium" size:16]
#define kNoochFontLt [UIFont fontWithName:@"BrandonGrotesque-Light" size:18]
UINavigationController *nav_ctrl;
NSUserDefaults *user;
@interface Home : GAITrackedViewController<serveD,CLLocationManagerDelegate,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate,iCarouselDataSource,iCarouselDelegate,UIAlertViewDelegate>
{
    CLLocationManager*locationManager;
    float lat,lon;
    UIView*blankView;
    NSDate*ServerDate;
    NSTimer*timerHome;
    NSMutableArray *additions;
    NSMutableArray *favorites;
    NSString*emailID;
    UIButton *top_button;
    NSMutableArray *histArray;
}
//@property(nonatomic,strong) NSMutableArray *favorites;
//@property (nonatomic, strong) NSMutableArray *additions;
@end
