//
//  LocationBasedSearchViewController.h
//  Nooch
//
//  Created by Charanjit Singh Bhalla on 15/11/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//
BOOL isLocationSearch;
#import <UIKit/UIKit.h>
#import "serve.h"

@interface LocationBasedSearchViewController : UIViewController <serveD>
{
    
}
@property (strong, nonatomic) IBOutlet UITableView *location_tbl;
- (IBAction)GoBack:(id)sender;

@end
