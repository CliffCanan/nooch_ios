//
//  ReferralCode.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface ReferralCode : GAITrackedViewController<serveD,UITextFieldDelegate>
{
    float lat,lon;

    NSString * getEncryptedPassword;
    NSString * refCodeFromArtisan;
    UIButton * enter;
}
- (id)initWithData:(NSDictionary *)usr;
@end
