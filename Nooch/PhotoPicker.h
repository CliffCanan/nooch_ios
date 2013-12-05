//
//  PhotoPicker.h
//  Nooch
//
//  Created by Vicky Mathneja on 21/11/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "transfer.h"
#import "assist.h"
@class transfer;
@interface PhotoPicker : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    AppDelegate*delegate;
    int upstatus;

    transfer*transferOBJ;
}
@property(assign)BOOL isCamra;
@end
