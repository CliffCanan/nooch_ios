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
    UISegmentedControl *completed_pending;
    short countRows;
    NSMutableArray *histArray;
    NSMutableArray *histShowArrayCompleted;
    NSMutableArray *histShowArrayPending;
    BOOL ishistLoading;
    BOOL isEnd, isStart;
    int totalDisplayedTransfers_completed,index;
    BOOL isFilter, isSearch, isLocalSearch, isMapOpen;
    FPPopoverController*fp;
    NSString*SearchString;
    UIView*mapArea;
    float firstX,firstY;
    float lat_hist,lon_hist;
    BOOL locUpdateSuccessfully;
    NSArray*histArrayCommon;
    UIButton*exportHistory;
    NSMutableArray*histTempCompleted;
    NSMutableArray*histTempPending;
    NSString*subTypestr;
    NSDate*ServerDate;
    UILabel * emptyText_localSearch;
    NSIndexPath * indexPathForDeletion;
    CLLocationManager*locationManager;
    CLLocationCoordinate2D locationUser;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@end
