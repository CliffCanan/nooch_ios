//
//  Register.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

@interface Register : GAITrackedViewController<UITextFieldDelegate,serveD,MBProgressHUDDelegate>
{
    UIActivityIndicatorView*spinner;
    BOOL isTermsChecked;
}
-(void)removeChild:(UIViewController *) child;
@end
