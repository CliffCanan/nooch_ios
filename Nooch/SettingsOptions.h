//
//  SettingsOptions.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//
BOOL isBankAttached;
#import <UIKit/UIKit.h>
#import "serve.h"
#import <MessageUI/MessageUI.h>

BOOL fromHomeShowLtBox;
@interface SettingsOptions : GAITrackedViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,UIImagePickerControllerDelegate,MBProgressHUDDelegate,serveD>
{
    UIView * blankView, * overlay, * mainView;
    UIButton * arrow;
    UILabel * helpText;
    BOOL shouldGoToIdVerScrn;
}
@end
