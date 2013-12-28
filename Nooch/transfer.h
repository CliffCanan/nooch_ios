//
//  transfer.h
//  Nooch
//
//  Created by Preston Hults on 10/16/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "GAITrackedViewController.h"
#import "FPPopoverController.h"
#import "popSelect.h"
#import "serve.h"
#import "PhotoPicker.h"
#import "assist.h"
NSString*nonNooch;
NSString *receiverId;
NSData *receiverImgData;
NSString *receiverFirst;
NSString *receiverLast;
bool requestRespond;
bool cancelling;
NSString *requestId;
NSString *requestAmount;
NSString *acceptOrDeny;
@class PhotoPicker;
@interface transfer : GAITrackedViewController<CLLocationManagerDelegate,UITextFieldDelegate,FPPopoverControllerDelegate,UIAlertViewDelegate,serveD,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSString *actualAmount;
    __weak IBOutlet UIImageView *memoBack;
    NSString *latlng;
    __weak IBOutlet UIImageView *userBar;
    CLLocationManager *locationManager;
    MKPlacemark *placeMarker;
    __weak IBOutlet UIImageView *sendArrow1;
    __weak IBOutlet UIImageView *sendArrow2;
    __weak IBOutlet UIImageView *sendArrow3;
    __weak IBOutlet UIButton *memoDefaultButton;
    __weak IBOutlet UIButton *memoFoodButton;
    __weak IBOutlet UIButton *memoUtilitiesButton;
    __weak IBOutlet UIButton *memoTicketsButton;
    __weak IBOutlet UIButton *memoIOUButton;

    __weak IBOutlet UIImageView *promptForPIN;
    __weak IBOutlet UIImageView *requestBar;
    __weak IBOutlet UIImageView *requestArrows;
    __weak IBOutlet UIButton *sendToggle;
    __weak IBOutlet UIButton *requestToggle;
    NSString *country;
    NSString *city;
    NSString *state;
    NSString *zipcode;
    NSString *addressLine1;
    NSString *addressLine2;
    NSString *TransactionDate;
    __weak IBOutlet UIButton *leftNavButton;
    __weak IBOutlet UINavigationBar *navBar;

    __weak IBOutlet UIImageView *progressImage;
    __weak IBOutlet UIButton *sendButton;
    NSString *latitudeField;
    NSString *longitudeField;
    NSString *altitudeField;
    UIAlertView *writeMemo;
    PhotoPicker*photoPickerOBJ;
   IBOutlet UIButton*btn;
   IBOutlet UIImageView*imageToshow;
    IBOutlet UIButton*btnAttachImage;
    IBOutlet UIScrollView*scrollViewResp;
    IBOutlet UIView*RespView;
    IBOutlet UIView*RespImageV;
    
}
//added by venturepact
//Recipients
@property(nonatomic,retain)NSDictionary*dictResp;
@property(nonatomic,retain)UIImage*imagepickedOBJ;
@property(nonatomic,retain)UIImageView*imageToshow;
@property (weak, nonatomic) IBOutlet UIButton *decimal;
@property (weak, nonatomic) IBOutlet UITextField *enterAmountField;
@property (strong, nonatomic) IBOutlet UIView *inputAccess;
@property (strong, nonatomic) IBOutlet UIView *customKeyboard;
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (nonatomic) BOOL confirm;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UIImageView *recipImage;
@property (weak, nonatomic) IBOutlet UILabel *recipFirst;
@property (weak, nonatomic) IBOutlet UILabel *recipLast;
@property (weak, nonatomic) IBOutlet UIImageView *firstPIN;
@property (weak, nonatomic) IBOutlet UIImageView *secondPIN;
@property (weak, nonatomic) IBOutlet UIImageView *thirdPIN;
@property (weak, nonatomic) IBOutlet UIImageView *fourthPIN;
@property (weak, nonatomic) IBOutlet UILabel *amountToSend;
@property (weak, nonatomic) IBOutlet UILabel *prompt;
@property (weak, nonatomic) IBOutlet UIImageView *receiveBack;
@property (weak, nonatomic) IBOutlet UILabel *dollarSign;
@property (nonatomic, retain) NSString *PINText;
@property (nonatomic, retain) NSMutableData *respData;
@property (weak, nonatomic) IBOutlet UITextField *memoField;



@end
