//
//  HistoryFlat.h
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "popSelect.h"
#import "FPPopoverController.h"
#import "SWTableViewCell.h"
#import "Home.h"
#import <MessageUI/MessageUI.h>
#import "SpinKit/RTSpinKitView.h"

BOOL isHistFilter;
BOOL isFromApts;
NSString *listType;

@interface HistoryFlat : GAITrackedViewController<UITableViewDataSource,UITableViewDelegate,
serveD,FPPopoverControllerDelegate,UISearchBarDelegate,SWTableViewCellDelegate,MBProgressHUDDelegate,CLLocationManagerDelegate,MFMailComposeViewControllerDelegate>
{
    NSArray * histArrayCommon;
    NSMutableArray * histArray;
    NSMutableArray * histShowArrayCompleted;
    NSMutableArray * histShowArrayPending;
    NSMutableArray * histTempCompleted;
    NSMutableArray * histTempPending;

    BOOL ishistLoading;
    BOOL isEnd, isStart;
    BOOL isFilter, isSearch, isLocalSearch, isMapOpen;
    BOOL locUpdateSuccessfully;
    float firstX,firstY;
    float lat_hist,lon_hist;
    int totalDisplayedTransfers_completed,index;
    short countRows;

    FPPopoverController * fp;

    UIButton * exportHistory;
    UILabel * emptyText_localSearch;
    UISegmentedControl * completed_pending;
    UIView * mapArea;
    NSDate * ServerDate;
    NSIndexPath * indexPathForDeletion;
    NSString * subTypestr;
    NSString * SearchString;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D locationUser;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@end
