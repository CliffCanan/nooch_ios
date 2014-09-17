//
//  terms.h
//  Nooch
//
//  Created by administrator on 12/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"


BOOL isfromRegister;

//@class signin;

@interface terms : GAITrackedViewController <serveD,UIWebViewDelegate,MBProgressHUDDelegate>

@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UIWebView *termsView;

-(IBAction)acceptButtonAction;

@end
