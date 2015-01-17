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

BOOL isProfileOpenFromSideBar, sentFromHomeScrn, isFromSettingsOptions;
@interface ProfileInfo : GAITrackedViewController<UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,serveD,DecryptionDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    int down,option,rowHeight,numberOfRowsToDisplay,heightOfTopSection;
    NSString *recoverMail;
    NSString *timezoneStandard;
    NSString*getEncryptedPasswordValue;
    NSMutableDictionary*transaction;
    NSMutableDictionary*transactionInput;
    NSMutableDictionary*dictProfileinfo;
    
    NSDictionary*GMTTimezonesDictionary;
    UIScrollView *scrollView;
    BOOL isPhotoUpdate,emailVerifyRowIsShowing,smsVerifyRowIsShowing;
    NSRange start,end;
    NSString*newString;
    NSString*betweenBraces;
    NSString*strPhoneNumber;
    UIView*navBar;
    UILabel*lbl;
    UIButton*crossbtn;
    NSMutableDictionary*dictSavedInfo;
    UIView * shadowUnder;
    UITapGestureRecognizer * tapGesture;
}

@end
