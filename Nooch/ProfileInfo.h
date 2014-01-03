//
//  ProfileInfo.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "Decryption.h"
#import "GetEncryptionValue.h"
@interface ProfileInfo : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,serveD,DecryptionDelegate,GetEncryptionValueDelegate>
{
    UIActivityIndicatorView*spinner;
    NSString *recoverMail;
    NSString *timezoneStandard;
    NSString*getEncryptedPasswordValue;
    NSMutableDictionary*transaction;
    NSMutableDictionary*transactionInput;
    NSMutableDictionary*dictProfileinfo;
     NSString*ServiceType;
    NSDictionary*GMTTimezonesDictionary;
    UIImageView *picture;
}
@end
