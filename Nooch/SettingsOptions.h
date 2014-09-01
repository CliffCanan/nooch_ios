//
//  SettingsOptions.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//
BOOL isBankAttached;
#import <UIKit/UIKit.h>
#import "serve.h"
@interface SettingsOptions : GAITrackedViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,serveD>
{
    UIView* blankView;
    
}
@end
