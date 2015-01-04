//
//  NotificationSettings.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

@interface NotificationSettings : GAITrackedViewController<UITableViewDataSource,UITableViewDelegate,serveD,UIScrollViewDelegate,MBProgressHUDDelegate>
{
    NSString*serviceType;
    NSDictionary*dictInput;
    NSDictionary*dictSettings;
    NSString*servicePath;
    BOOL allOn_sec1_email,allOn_sec2_email,allOn_sec2_push;
}
@end
