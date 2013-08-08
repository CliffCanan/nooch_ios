///Users/pdhults/Dropbox/Preston Hults/Source/nooch-ios/nooch-ios-storyboard/Nooch/Nooch/LoginViewController.h
//  LoginViewController.h
//  Nooch
//
//  Created by Preston Hults on 9/7/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GAITrackedViewController.h"
#import "core.h"

NSString *passwordEncrypted;
NSString *pinEncrypted;

@interface LoginViewController : GAITrackedViewController<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,serveD>
{
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavButton;
    UIAlertView *writeMemo;
    NSMutableData *responseData;
    NSString *getEncryptedPasswordValue;
}
@property (strong, nonatomic) IBOutlet UIView *inputAccessory;

@property (weak, nonatomic) IBOutlet UITableView *loginTable;
@property (weak, nonatomic) IBOutlet UIImageView *checkBox;
@property (retain, nonatomic) IBOutlet UITextField *emailAddress;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassword;
@property (weak, nonatomic) IBOutlet UILabel *keepLoggedIn;
@property (weak, nonatomic) IBOutlet UILabel *forgotPassLabel;



@end
