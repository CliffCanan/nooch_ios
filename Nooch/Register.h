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

@interface Register : UIViewController<UITextFieldDelegate,serveD>
{
    UIActivityIndicatorView*spinner;
}

@end
