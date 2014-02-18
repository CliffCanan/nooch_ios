//
//  BankVerification.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
int bankNo;
@interface BankVerification : UIViewController<UITextFieldDelegate,serveD>
{
    int verifyAttempts;
    UIView*blankView;
}
@end
