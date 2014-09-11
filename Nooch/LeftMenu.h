//
//  LeftMenu.h
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "ECSlidingViewController.h"
#import <MessageUI/MessageUI.h>
@interface LeftMenu : GAITrackedViewController<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    UIImageView *user_pic;
    UIButton * arrow;
}
@end
