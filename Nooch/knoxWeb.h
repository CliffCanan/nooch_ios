//
//  knoxWeb.h
//  Nooch
//
//  Created by crks on 3/13/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

@interface knoxWeb : GAITrackedViewController<MBProgressHUDDelegate>
{
    UIView*overlay,*mainView;
}
@end
