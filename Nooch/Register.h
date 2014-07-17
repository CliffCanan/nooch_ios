//
//  Register.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "serve.h"
#import "MBProgressHUD.h"
@interface Register : UIViewController<UITextFieldDelegate,serveD,MBProgressHUDDelegate>
{
    UIActivityIndicatorView*spinner;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@end
