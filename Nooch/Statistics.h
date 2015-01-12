//
//  Statistics.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
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
    UILabel * titleTopFriends;
    UIView * pieGraphMiddleOverlay;
    BOOL IsAlertShown;
    int statsLoadedSoFar, fav_count, totalPayments, rowNumber, pieSlice_count;
}
@end
