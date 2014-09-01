//
//  ReferralCode.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"

@interface ReferralCode : GAITrackedViewController<serveD,UITextFieldDelegate,MBProgressHUDDelegate>
{
    NSString*getEncryptedPassword;
    float lat,lon;
    UIActivityIndicatorView*spinner;
    UIButton *enter;
}
- (id)initWithData:(NSDictionary *)usr;
@end
