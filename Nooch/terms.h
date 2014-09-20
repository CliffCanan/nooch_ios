//
//  terms.h
//  Nooch
//
//  Created by administrator on 12/05/13.
//  Copyright 2014 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"

BOOL isfromRegister;

@interface terms : GAITrackedViewController <serveD,UIWebViewDelegate,MBProgressHUDDelegate>

@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UIWebView *termsView;

@end
