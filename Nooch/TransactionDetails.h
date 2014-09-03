//
//  TransactionDetails.h
//  Nooch
//
//  Created by crks on 10/4/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>

@interface TransactionDetails : GAITrackedViewController<serveD,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate,UIScrollViewDelegate>{
    GMSMapView *mapView_;
    UIView *blankView;
    UILabel *amount;
    UIView *overlay,*mainView;
    double lat;
    double lon;
    NSMutableDictionary *loginResult;
}
- (id)initWithData:(NSDictionary *)trans;
@end
