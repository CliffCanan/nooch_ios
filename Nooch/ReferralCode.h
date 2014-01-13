//
//  ReferralCode.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface ReferralCode : UIViewController<serveD,UITextFieldDelegate,serveD>
{
    NSString*getEncryptedPassword;
    float lat,lon;
    UIActivityIndicatorView*spinner;
    UIButton *enter;
}
- (id)initWithData:(NSDictionary *)usr;
@end
