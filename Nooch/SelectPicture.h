//
//  SelectPicture.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "Helpers.h"
#import "MBProgressHUD.h"

@interface SelectPicture : GAITrackedViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    UIImage * imageShow;
}
- (id)initWithData:(NSDictionary *)user;

@end