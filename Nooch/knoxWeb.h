//
//  knoxWeb.h
//  Nooch
//
//  Created by crks on 3/13/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"
#import <MessageUI/MessageUI.h>

@interface knoxWeb : GAITrackedViewController<MBProgressHUDDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    UIView*overlay,*mainView;
}
@end
