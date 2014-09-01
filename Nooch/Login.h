//
//  Login.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>

@interface Login : GAITrackedViewController<UIAlertViewDelegate,UITextFieldDelegate,serveD,CLLocationManagerDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate>
{
    float lat;
    float lon;
    CLLocationManager *locationManager;
    UIActivityIndicatorView*spinner;
    UIAlertView *writeMemo;
}
@property (strong, nonatomic) IBOutlet UIView *inputAccessory;
@end
