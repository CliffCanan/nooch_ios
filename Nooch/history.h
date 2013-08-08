//
//  history.h
//  Nooch
//
//  Created by Preston Hults on 10/21/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoochHome.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "GAITrackedViewController.h"
#import "assist.h"
#import "FPPopoverController.h"
#import "popSelect.h"

int newTransfers;
int newTransfersDecrement;
bool updateHistory;
bool loadingHide;
NSString *filterPick;
FPPopoverController *fp;


@interface history : GAITrackedViewController<UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate,UITextViewDelegate,UISearchBarDelegate,FPPopoverControllerDelegate,MFMailComposeViewControllerDelegate>{
    GMSMapView *mapView_;
    NSMutableArray *historyArray;
    MFMailComposeViewController *mailComposer;
    NSMutableArray *historyImages;
    __weak IBOutlet UIImageView *userBar;
    UIAlertView *writeMemo;
    NSString *transactionId;
    NSString *recipId;
    NSString *sendId;
    NSMutableData *respData;
    __weak IBOutlet UIImageView *whichArrows;
    __weak IBOutlet UILabel *requestBadgeName;
    __weak IBOutlet UIImageView *senderRequestBadge;
    __weak IBOutlet UIImageView *recipRequestBadge;
    IBOutlet UIButton *startNewTransfer;
    __weak IBOutlet UIButton *payButton;
    __weak IBOutlet UIButton *ignoreButton;
    __weak IBOutlet UIButton *cancelButton;
    bool isRequest;

    __weak IBOutlet UIButton *filterButton;
    __weak IBOutlet UIImageView *cancelledRequestBadge;
    NSString *latitudeField;
    NSString *longitudeField;
    NSString *altitudeField;
    NSString *country;
    NSString *city;
    NSString *state;
    NSString *zipcode;
    NSString *addressLine1;
    NSString *addressLine2;
    NSString *TransactionDate;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavBar;
}
@property (weak, nonatomic) IBOutlet UILabel *statusOfTransfer;
@property (weak, nonatomic) IBOutlet UIImageView *secondPartyImage;
@property (weak, nonatomic) IBOutlet UIImageView *youImage;
@property(nonatomic,retain) NSData *partyTransferImage;
@property (weak, nonatomic) IBOutlet UITableView *detailsTable;
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *dipusteNote;
@property (weak, nonatomic) IBOutlet UIButton *goDisputeButton;
@property (weak, nonatomic) IBOutlet UIButton *disputeDetailsButton;
@property (weak, nonatomic) IBOutlet UITextView *disputeMessage;
@property (weak, nonatomic) IBOutlet UITextField *disputeSubject;
@property (weak, nonatomic) IBOutlet UIView *disputeRequest;
@property (weak, nonatomic) IBOutlet UILabel *resDate;
@property (weak, nonatomic) IBOutlet UILabel *reviewDate;
@property (weak, nonatomic) IBOutlet UILabel *dispId;
@property (weak, nonatomic) IBOutlet UILabel *dispDate;
@property (weak, nonatomic) IBOutlet UILabel *dispStatus;
@property (weak, nonatomic) IBOutlet UIView *disputeDetailsView;
@property (weak, nonatomic) IBOutlet UILabel *memo;
@property (weak, nonatomic) IBOutlet UILabel *disputeStatus;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *transerAmount;
@property (weak, nonatomic) IBOutlet UILabel *recipient;
@property (weak, nonatomic) IBOutlet UILabel *sender;
@property (weak, nonatomic) IBOutlet UIView *transferDetails;
@property (weak, nonatomic) IBOutlet UILabel *blankLabel;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic) BOOL allTrans;
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

-(void)dismissFP:(NSNotification *)notification;
@end
