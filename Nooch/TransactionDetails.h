//
//  TransactionDetails.h
//  Nooch
//
//  Created by crks on 10/4/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "serve.h"
#import <MessageUI/MessageUI.h>

@interface TransactionDetails : UIViewController<serveD,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate>{
    GMSMapView *mapView_;
    UIView*blankView;
    UILabel *amount;
    UIView*overlay,*mainView;
    double lat;
    double lon;
}
- (id)initWithData:(NSDictionary *)trans;

@end
