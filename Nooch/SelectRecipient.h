//
//  SelectRecipient.h
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
#import "HowMuch.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
 BOOL isphoneBook;
NSMutableArray*arrRecipientsForRequest;
BOOL isAddRequest;
@interface SelectRecipient : UIViewController<UITableViewDelegate,UITableViewDataSource,serveD,UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate>
{
    
    UIView*loader;
    NSString*searchString;
    BOOL searching;
    BOOL emailEntry;
    NSMutableArray*arrSearchedRecords;
    UISearchBar *search;
    UIActivityIndicatorView*spinner;
    
    BOOL isRecentList;
    NSString*emailphoneBook;
   
    UIImageView *arrow;
    UILabel *em;
    NSArray *emailAddresses;
}
@end
