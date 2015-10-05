//
//  ProfileInfo.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "Decryption.h"
#import "GetEncryptionValue.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

BOOL isProfileOpenFromSideBar, sentFromHomeScrn, isFromSettingsOptions, isFromTransDetails;
BOOL shouldFocusOnAddress, shouldFocusOnDob, shouldFocusOnSsn, hasSeenDobPopup;

@interface ProfileInfo : GAITrackedViewController<UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,serveD,DecryptionDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    BOOL isPhotoUpdate, wasSSNadded;
    BOOL emailVerifyRowIsShowing, smsVerifyRowIsShowing;
    BOOL hasSeenAddressPopup;
    short down,numberOfRowsToDisplay,heightOfTopSection;
    short hdrHt,rowHeight;

    NSMutableDictionary *transactionInput;
    NSMutableDictionary *dictProfileinfo;
    NSMutableDictionary *dictSavedInfo;
    NSString *recoverMail;
    NSString *strPhoneNumber;
    UIScrollView *scrollView;
    UITapGestureRecognizer * tapGesture;
    UIImagePickerController * picker;
    UIView * shadowUnder;
}
@end