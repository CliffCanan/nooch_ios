//
//  LeftMenu.h
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "ECSlidingViewController.h"

@interface LeftMenu : UIViewController<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    UIImageView *user_pic;
}
@end
