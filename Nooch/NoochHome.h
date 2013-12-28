//
//  NoochHome.h
//  Nooch
//
//  Created by Preston Hults on 9/14/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "AppDelegate.h"
#import "GAITrackedViewController.h"
#import <MessageUI/MessageUI.h>
#import "core.h"
#import "serve.h"
#import "ECSlidingViewController.h"
#import "sideMenu.h"
#import "rightMenu.h"
#import "AppSkel.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
BOOL isRequestmultiple;
NSString *fbUID;
NSMutableArray *addrBookUsername;
BOOL Updating;
BOOL searching;
BOOL transferFinished;
BOOL resetPIN;
bool getRequests;
bool viewDetails;
float transp;
bool fadeIn;
bool causes;
NSString *tId;
core *me;
UINavigationController *navCtrl;
UIStoryboard *storyboard;
BOOL sendingMoney;
BOOL suspended ;
bool signin;
BOOL reqImm;
BOOL initialLoad;
BOOL goPIN;
UIViewController *nHome;

@interface NoochHome : GAITrackedViewController<UITableViewDataSource, UITableViewDelegate,serveD,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate>{
    NSMutableArray *addrBook;
    __weak IBOutlet UIView *tutorialView;
    
    __weak IBOutlet UIButton *prevTut;
    __weak IBOutlet UIButton *nextTut;
    __weak IBOutlet UIImageView *tutorialImage;
    __weak IBOutlet UIImageView *progressImage;
    __weak IBOutlet UIImageView *requestBadge;
    __weak IBOutlet UIImageView *userBar;
    NSMutableArray *addrBookNooch;
    NSMutableArray *causesArr;
     NSMutableArray *FeaturedcausesArr;
    __weak IBOutlet UIImageView *sendMoneyOverlay;
    NSMutableArray *addrBookInvited;
    __weak IBOutlet UITextField *searchField;
    NSMutableArray *fbFriends;
    NSMutableArray *fbNoochFriends;
    NSMutableData *responseData;
    __weak IBOutlet UIButton *rightMenuButton;
    __weak IBOutlet UIImageView *peepsOrCauses;
    __weak IBOutlet UIButton *leftNavButton;
    UIRefreshControl *refreshControl;
    __weak IBOutlet UINavigationBar *navBar;
    MFMailComposeViewController *mailComposer;
    __weak IBOutlet UIButton *clearSearchButton;
    __weak IBOutlet UILabel *newRequests;
    __weak IBOutlet UIView *pendingRequestView;
    
    //venturepact
    UIView*loader;
    NSMutableDictionary*dictGroup;
    IBOutlet UIScrollView*scrollViewGroup;
    int imgcount;
    UIImageView*imgFeatureV;
    UIButton *btnRight;
    UIButton *btnLeft;
    UIView*FeaturedView;
    BOOL isSwipeLeft;
    int swipeAtRowAtIndex;
    BOOL iscauseDeSelected;
    BOOL isSearching;
    IBOutlet UIButton*btnX;
    IBOutlet UIButton*btnRequestM;
  
    NSMutableArray*arrSearchedRecords;
}
@property (strong, nonatomic)IBOutlet UIScrollView*scrollViewGroup;

@property (strong, nonatomic) IBOutlet UIButton *btnimgValidateNoti;

@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (retain, nonatomic) IBOutlet UIButton *connectFbButton;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic) BOOL emailSend;
@property (nonatomic) BOOL goSelectRecip;
@property (nonatomic, retain) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIView *sendMoneyView;
@property (retain, nonatomic) IBOutlet UITableView *friendTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *blankLabel;
@property (nonatomic) int display;
@property (nonatomic, retain) NSMutableArray *sorter;
@property (copy) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionsSearch;
@property(nonatomic,retain) MFMailComposeViewController *mailComposer;
- (IBAction)ShowLastLoginLocationUser:(id)sender;
@end
