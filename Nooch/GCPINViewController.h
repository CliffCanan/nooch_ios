//
//  GCPINViewController.h
//  PINCode
//
//  Created by Caleb Davenport on 8/28/10.
//  Copyright 2010 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "core.h"
#import "serve.h"


@interface GCPINViewController : UIViewController <serveD,UIAlertViewDelegate,UITextFieldDelegate> {
@private
    __weak IBOutlet UIButton *leftNavButton;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UITextField *pinTextField;
    __weak IBOutlet UIView *keyboard;
    NSArray *pinFields;
	NSString *PINText;
    NSString *chckPage;
    NSString *pin;
    NSString *getEncryptedPassword;
	BOOL secureTextEntry;
	id userInfo;
    NSMutableData *responseData;
    NSString *encryptedPIN;
    NSString *newEncryptedPIN;
    //BOOL resPin;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *prompt;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *firstNumber;
@property (weak, nonatomic) IBOutlet UIImageView *secondNumber;
@property (weak, nonatomic) IBOutlet UIImageView *thirdNumber;
@property (weak, nonatomic) IBOutlet UIImageView *fourthNumber;
@property (nonatomic, assign) BOOL resPin;
@property (nonatomic, assign) BOOL secureTextEntry;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) NSString *PINText;
@property (nonatomic, retain) NSString *pin;
@property (nonatomic, retain) NSString *targetViewName;
@property (nonatomic, retain) NSString *chckPage;
@property (nonatomic, retain) NSString *comparePIN;
@property (nonatomic, retain) NSMutableDictionary *lastTransactionDictionary;
@property (nonatomic) BOOL secondEntry;
@property (nonatomic) BOOL confirmPIN;

-(void)resetPinFlag;

@end
