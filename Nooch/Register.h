//
//  Register.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"
#import <MessageUI/MessageUI.h>

@interface Register : GAITrackedViewController<UITextFieldDelegate,serveD,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
{
    UIActivityIndicatorView*spinner;
    BOOL isTermsChecked;
    BOOL isloginWithFB;
    BOOL pwLength;
    int criteriaHit;
}
-(void)removeChild:(UIViewController *) child;
@end
