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
BOOL shouldFocusOnAddress, shouldFocusOnDob, shouldFocusOnSsn;

@interface ProfileInfo : GAITrackedViewController<UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,serveD,DecryptionDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    short down,option,numberOfRowsToDisplay,heightOfTopSection;
    short hdrHt,rowHeight;
    NSString *recoverMail;
    NSString *timezoneStandard;
    NSString*getEncryptedPasswordValue;
    NSMutableDictionary*transaction;
    NSMutableDictionary*transactionInput;
    NSMutableDictionary*dictProfileinfo;
    NSDictionary*GMTTimezonesDictionary;
    UIScrollView *scrollView;
    BOOL isPhotoUpdate, wasSSNadded;
    BOOL emailVerifyRowIsShowing,smsVerifyRowIsShowing;
    NSRange start,end;
    NSString*strPhoneNumber;
    UIView*navBar;
    NSMutableDictionary*dictSavedInfo;
    UIView * shadowUnder;
    UITapGestureRecognizer * tapGesture;
}

@end
