//
//  SelectRecipient.h
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
#import "HowMuch.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SpinKit/RTSpinKitView.h"

BOOL isphoneBook;
NSMutableArray*arrRecipientsForRequest;
BOOL isAddRequest;
@interface SelectRecipient : GAITrackedViewController<UITableViewDelegate,UITableViewDataSource,serveD,UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
{
    NSMutableDictionary*facebook_info;
    ACAccountStore*accountStore;
    //ACAccount*facebookAccount;
    UIView*loader;
    NSString*searchString;
    BOOL searching, navIsUp;
    BOOL emailEntry, shouldAnimate;
    NSMutableArray * arrSearchedRecords;
    UISearchBar * search;
    UIActivityIndicatorView * spinner;
    
    BOOL isRecentList;
    NSString * emailphoneBook, * firstNamePhoneBook, * lastNamePhoneBook;
    
    UIImageView *arrow;
    UILabel *em;
    NSArray *emailAddresses;
    NSMutableArray*arrRequestPersons;
}
@end
