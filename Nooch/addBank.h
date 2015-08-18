//
//  addBank.h
//  Nooch
//
//  Created by crks on 3/13/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MMProgressHUD/MMProgressHUD.h>

@interface addBank : GAITrackedViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    UIView *overlay, *mainView;
}
@end
