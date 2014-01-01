//
//  SelectCause.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface SelectCause : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,serveD>
{
    BOOL isSearching;
    NSString*SearchText;
    NSMutableArray*arrSearchedRecords;
    
    
    NSMutableArray *causesArr;
    NSMutableArray *FeaturedcausesArr;
    UIImageView *feat;
}
@end
