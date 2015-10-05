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
    BOOL searching, navIsUp, isRecentList;
    BOOL emailEntry, shouldAnimate, phoneNumEntry;
    float locationUpdateDelay;

    NSArray *emailAddresses;
    NSMutableArray*arrRequestPersons;
    NSMutableArray * arrSearchedRecords;
    NSString * emailphoneBook, * phoneBookPhoneNum , * firstNamePhoneBook, * lastNamePhoneBook;
    NSString * searchString;

    UISearchBar * search;
    UIImageView *arrow;
    UILabel *em;

    CLLocationManager*locationManager;
}
@end
