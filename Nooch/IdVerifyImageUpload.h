//
//  IdVerifyImageUpload.h
//  Nooch
//
//  Created by Clifford Canan on 7/16/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "Helpers.h"
#import "SpinKit/RTSpinKitView.h"
#import "MBProgressHUD.h"
#import "serve.h"

@interface IdVerifyImageUpload : GAITrackedViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,serveD>
{
    UIImage * imageShow;
}

@end