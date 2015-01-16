//
//  SelectApt.h
//  Nooch
//
//  Created by Cliff Canan on 1/13/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
#import "HowMuch.h"
#import "SpinKit/RTSpinKitView.h"

BOOL hasAptSet;

@interface SelectApt : GAITrackedViewController<UITableViewDelegate,UITableViewDataSource,serveD,UISearchBarDelegate,UITextFieldDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
{
    NSString*searchString;
    BOOL searching;
    NSMutableArray * arrSearchedRecords;
    UISearchBar * search;
    UIImageView *arrow;
    UILabel *em;
    NSArray *emailAddresses;
    NSMutableArray*arrRequestPersons;
    UIView * overlay;
    UIView * mainView;
}
@end

