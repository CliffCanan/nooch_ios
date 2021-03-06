//
//  LeftMenu.h
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "ECSlidingViewController.h"
#import <MessageUI/MessageUI.h>
#import "EAIntroView.h"

@interface LeftMenu : GAITrackedViewController<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,EAIntroDelegate,MFMailComposeViewControllerDelegate>
{
    UIView * user_bar;
    UIImageView *user_pic;
    UIButton * arrow;
    NSString * settingsIconPosition;
}
@end
