//
//  Statistics.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

@interface Statistics : GAITrackedViewController<serveD,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    NSDictionary * dictResult;
    NSMutableDictionary * dictAllStats;
    NSString * titlestr;
    NSMutableArray * favorites;
    UILabel * topFriendsTotalPayments;
    UILabel * topFriendsPieTotalLabel;
    BOOL IsAlertShown;
    int statsLoadedSoFar, fav_count, totalPayments;
}
@end
