//
//  refer.h
//  Nooch
//
//  Created by Preston Hults on 7/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "NoochHome.h"

@interface refer : UIViewController<serveD,UITableViewDelegate>{
    
    __weak IBOutlet UILabel *referCode;
    __weak IBOutlet UITableView *options;
    __weak IBOutlet UINavigationBar *navBar;
}

@end
