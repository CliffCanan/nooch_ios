//
//  settings.h
//  Nooch
//
//  Created by Preston Hults on 10/21/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NoochHome.h"
#import "Decryption.h"
#import <MessageUI/MessageUI.h>
#import "serve.h"
#import "GetEncryptionValue.h"
#import "Base64.h"
#import "AppDelegate.h"
#import "GAITrackedViewController.h"
#import "assist.h"

NSData *tempImg;

@interface settings : GAITrackedViewController<UIAlertViewDelegate,GetEncryptionValueDelegate,serveD,
UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate,DecryptionDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,UITableViewDelegate,UITextFieldDelegate>{
    NSString *getEncryptedPasswordValue;
    __weak IBOutlet UILabel *accountSettingsTitle;
    __weak IBOutlet UIButton *cPinButton;
    UIImagePickerController *picker;
    __weak IBOutlet UIImageView *userBar;
    NSData *imageData;
    NSString *encodedString;
    __weak IBOutlet UILabel *labelChangePIN;
    bool useFacebookPic;
    NSDictionary *GMTTimezonesDictionary;
    __weak IBOutlet UIButton *saveButton;
    NSString *getEncryptionOldPassword;
    NSString *getEncryptionNewPassword;
    NSString *tz;
    NSString *decryptedPassword;
    NSString *passwordReset;
    NSString *notificationID;
    __weak IBOutlet UILabel *labelReqImm;
    MFMailComposeViewController *mailComposer;
    __weak IBOutlet UIButton *profileSettingsButton;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavButton;
    assist* assistOBJ;
    NSString*ServiceType;
}
@property(strong,nonatomic)NSString *decryptedPassword;
@property (weak, nonatomic) IBOutlet UIImageView *validationBadge;
@property (weak, nonatomic) IBOutlet UIPageControl *tutorialPage;
@property (weak, nonatomic) IBOutlet UITextField *addressLine2;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITextField *firstNewPass;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UIView *resetPasswordView;
@property (weak, nonatomic) IBOutlet UITableView *resetPasswordTable;
@property (weak, nonatomic) IBOutlet UITableView *logoutTable;
@property (retain, nonatomic) IBOutlet UITextField *contactPhone;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;
@property (weak, nonatomic) IBOutlet UITableView *bankNotesTable;
@property (weak, nonatomic) IBOutlet UITableView *networkTable;
@property (weak, nonatomic) IBOutlet UITableView *noochTransfersTable;
@property (weak, nonatomic) IBOutlet UITableView *profileTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITableView *aboutTable;
@property (strong, nonatomic) IBOutlet UIView *inputAccessory;
@property(nonatomic) BOOL runOnce;
@property (weak, nonatomic) IBOutlet UITableView *accountSettingsTable;
@property(nonatomic,retain) MFMailComposeViewController *mailComposer;
@property(nonatomic,retain) NSData *imageData;
@property (weak, nonatomic) IBOutlet UITableView *helpTable;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swiper2;
@property (weak, nonatomic) IBOutlet UIView *tutorialView;
@property (nonatomic) int position;
@property (weak, nonatomic) IBOutlet UILabel *info1;
@property (weak, nonatomic) IBOutlet UILabel *info2;
@property (nonatomic, retain) NSMutableArray *info1Array;
@property (nonatomic, retain) NSMutableArray *info2Array;
@property (nonatomic, retain) NSMutableArray *stepArray;
@property (nonatomic, retain) NSArray *backgroundArray;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swiper1;
@property (weak, nonatomic) IBOutlet UIView *fbNotConnectedView;
@property (weak, nonatomic) IBOutlet UIView *fbConnectView;
@property (weak, nonatomic) IBOutlet UISwitch *fbSharingSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *b2nRequestEmail;
@property (weak, nonatomic) IBOutlet UIImageView *b2nEmail;
@property (weak, nonatomic) IBOutlet UIImageView *b2nPush;
@property (weak, nonatomic) IBOutlet UIImageView *n2bRequestEmail;
@property (weak, nonatomic) IBOutlet UIImageView *n2bEmail;
@property (weak, nonatomic) IBOutlet UIImageView *failEmail;
@property (weak, nonatomic) IBOutlet UIImageView *n2bPush;
@property (weak, nonatomic) IBOutlet UIImageView *failPush;
@property (weak, nonatomic) IBOutlet UIImageView *inviteEmail;
@property (weak, nonatomic) IBOutlet UIImageView *invitePush;
@property (weak, nonatomic) IBOutlet UIImageView *joinedEmail;
@property (weak, nonatomic) IBOutlet UIImageView *joinedPush;
@property (weak, nonatomic) IBOutlet UIImageView *lowPush;
@property (weak, nonatomic) IBOutlet UIImageView *lowEmail;
@property (weak, nonatomic) IBOutlet UIImageView *validEmail;
@property (weak, nonatomic) IBOutlet UIImageView *validPush;
@property (weak, nonatomic) IBOutlet UIImageView *updateEmail;
@property (weak, nonatomic) IBOutlet UIImageView *updatePush;
@property (weak, nonatomic) IBOutlet UIImageView *newsEmail;
@property (weak, nonatomic) IBOutlet UIImageView *newsPush;
@property (weak, nonatomic) IBOutlet UIImageView *receivedEmail;
@property (weak, nonatomic) IBOutlet UIImageView *unclaimedEmail;
@property (weak, nonatomic) IBOutlet UIImageView *sentEmail;
@property (weak, nonatomic) IBOutlet UIImageView *receivedPush;
@property (weak, nonatomic) IBOutlet UIScrollView *notificationsScroll;
@property (weak, nonatomic) IBOutlet UISwitch *reqImmSwitch;
@property (weak, nonatomic) IBOutlet UIView *pinSettingsView;
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *profileScroll;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *recoveryEmail;
@property (strong, nonatomic) IBOutlet UITextField *address;
@property (strong, nonatomic) IBOutlet UITextField *city;
@property (strong, nonatomic) IBOutlet UITextField *state;
@property (strong, nonatomic) IBOutlet UITextField *zip;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *editPicButton;

@property (strong, nonatomic) NSMutableDictionary *transactionInput;
@property (strong, nonatomic) NSMutableDictionary *transaction;

@end
