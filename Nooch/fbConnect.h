//
//  fbConnect.h
//  Nooch
//
//  Created by Vicky Mathneja on 13/11/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "SpinKit/RTSpinKitView.h"
#import "MBProgressHUD.h"
#import "NSString+FontAwesome.h"
#import <Accounts/Accounts.h>
#import "serve.h"
#define Rgb2UIColor(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]
@interface fbConnect : GAITrackedViewController<MBProgressHUDDelegate,serveD,UIAlertViewDelegate>

@end