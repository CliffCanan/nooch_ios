//
//  Login.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Server.h"
#import "serve.h"

@interface Login : UIViewController<UITextFieldDelegate,serveD,CLLocationManagerDelegate>
{
    float lat;
    float lon;
    CLLocationManager *locationManager;
    UIActivityIndicatorView*spinner;
    UIAlertView *writeMemo;
}
@property (strong, nonatomic) IBOutlet UIView *inputAccessory;
@end
