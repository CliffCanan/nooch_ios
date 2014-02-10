//
//  NotificationSettings.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface NotificationSettings : UIViewController<UITableViewDataSource,UITableViewDelegate,serveD>
{
    NSString*serviceType;
    NSDictionary*dictInput;
    NSDictionary*dictSettings;
    NSString*servicePath;
    UIView*blankView;
}
@end
