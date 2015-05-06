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

@interface SettingsOptions : GAITrackedViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,serveD>
{
    UIView * blankView;
    UIButton * arrow;
}
@end
