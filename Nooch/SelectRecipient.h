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

@interface SelectRecipient : UIViewController<UITableViewDelegate,UITableViewDataSource,serveD,UISearchBarDelegate>
{
    UIView*loader;
    NSString*searchString;
    BOOL searching;
    BOOL emailEntry;
    NSMutableArray*arrSearchedRecords;
    UISearchBar *search;
}
@end
