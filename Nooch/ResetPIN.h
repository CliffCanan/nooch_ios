//
//  ResetPIN.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "Helpers.h"
#import "Home.h"
#import <MessageUI/MessageUI.h>

@interface ResetPIN : GAITrackedViewController<serveD,MFMailComposeViewControllerDelegate>
{
    UIActivityIndicatorView*spinner;
    NSDictionary*dictResult;
    UILabel *title;
    int pinchangeProgress;
    NSString*newPinString;
    NSString *encryptedPIN;
    NSString*newEncryptedPIN;
}
@end
