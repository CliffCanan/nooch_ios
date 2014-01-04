//
//  ResetPassword.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//
NSString*userPass;
NSString*getEncryptionOldPassword;
NSString*newchangedPass;
BOOL isPasswordChanged;
#import <UIKit/UIKit.h>
#import "serve.h"
#import "GetEncryptionValue.h"

@interface ResetPassword : UIViewController<UITextFieldDelegate,serveD,UITableViewDelegate,UITableViewDataSource,GetEncryptionValueDelegate>
{
    NSString* passwordReset;
    NSString*getEncryptedPasswordValue;
    NSString*getEncryptionNewPassword;
    NSString*getEncryptionOldPassword;
}
@end