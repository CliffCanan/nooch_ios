//
//  TransactionDetails.h
//  Nooch
//
//  Created by Cliff Canan on 10/4/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
@import GoogleMaps;

BOOL shouldDeletePendingRow;

@interface TransactionDetails : GAITrackedViewController<serveD,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate,UIScrollViewDelegate>{
    GMSMapView *mapView_;
    UIView *blankView;
    UILabel *amount;
    UIView *overlay,*mainView;
    double lat;
    double lon;
    NSMutableDictionary * tranDetailResult;
    NSData *datos;
}
@property (nonatomic, retain) ACAccount *twitterAccount;
@property (nonatomic) bool twitterAllowed;
@property (nonatomic, retain) ACAccountStore *accountStore;

-(id)initWithData:(NSDictionary *)trans;

@end