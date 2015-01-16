//
//  SetAptDetails.h
//  Nooch
//
//  Created by Cliff Canan on 1/14/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import <MessageUI/MessageUI.h>
#import "popSelect.h"
#import "FPPopoverController.h"

BOOL isBankAttached;
BOOL isAutoPayPopoverShowing;
NSString * autoPaySetting;
@interface SetAptDetails : GAITrackedViewController<UIAlertViewDelegate,UITextFieldDelegate,FPPopoverControllerDelegate,MFMailComposeViewControllerDelegate,serveD>
{
    int rowHeight;
    UIView * overlay;
    UIView * mainView;
    FPPopoverController * popoverAutoPayDate;
}
@end