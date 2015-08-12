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
#import "serve.h"

@interface IdVerifyImageUpload : GAITrackedViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,serveD>
{
    UIImage * imageShow;
    BOOL isCancelled;
}

@end