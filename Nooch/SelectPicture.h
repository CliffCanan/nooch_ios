//
//  SelectPicture.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "Helpers.h"

@interface SelectPicture : GAITrackedViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    UIImage * imageShow;
}
- (id)initWithData:(NSDictionary *)user;

@end
