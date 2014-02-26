//
//  ProfileInfo.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "Decryption.h"
#import "GetEncryptionValue.h"
BOOL isProfileOpenFromSideBar;
@interface ProfileInfo : UIViewController<UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,serveD,DecryptionDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>
{
    int down;
    UIActivityIndicatorView*spinner;
    NSString *recoverMail;
    NSString *timezoneStandard;
    NSString*getEncryptedPasswordValue;
    NSMutableDictionary*transaction;
    NSMutableDictionary*transactionInput;
    NSMutableDictionary*dictProfileinfo;
    
    NSDictionary*GMTTimezonesDictionary;
    UIImageView *picture;
    BOOL isPhotoUpdate;
    UITextView *memSincelbl;
    NSRange start,end;
    NSString*newString;
    NSString *betweenBraces;
    NSString*strPhoneNumber;
    UIView*navBar;
    UILabel*lbl;
    UIButton*crossbtn;
}
@end
