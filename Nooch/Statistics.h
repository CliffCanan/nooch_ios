//
//  Statistics.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface Statistics : GAITrackedViewController<serveD,UITableViewDataSource,UITableViewDelegate>
{
    NSDictionary*dictResult;
    NSMutableDictionary*dictAllStats;
    UIView*blankView;
    NSString*titlestr;
}
@end
