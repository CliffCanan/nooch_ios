//
//  SelectRecipient.h
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
#import "HowMuch.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SpinKit/RTSpinKitView.h"

BOOL isphoneBook, isAddRequest, isFromBankWebView;
NSMutableArray*arrRecipientsForRequest;
int screenLoadedTimes;

@interface SelectRecipient : GAITrackedViewController<UITableViewDelegate,UITableViewDataSource,serveD,UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
{
    NSMutableDictionary*facebook_info;
    UIView*loader;
    NSString*searchString;
    BOOL searching, navIsUp, isRecentList;
    BOOL emailEntry, shouldAnimate, phoneNumEntry;
    NSMutableArray * arrSearchedRecords;
    UISearchBar * search;
    UIActivityIndicatorView * spinner;
    NSString * emailphoneBook, * phoneBookPhoneNum , * firstNamePhoneBook, * lastNamePhoneBook;
    UIImageView *arrow;
    UILabel *em;
    NSArray *emailAddresses;
    NSMutableArray*arrRequestPersons;
    CLLocationManager*locationManager;
    float locationUpdateDelay;
}
@end
