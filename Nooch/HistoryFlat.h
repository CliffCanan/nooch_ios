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
serveD,FPPopoverControllerDelegate,UISearchBarDelegate,SWTableViewCellDelegate,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
{
    UISegmentedControl *completed_pending;
    int countRows;
    NSMutableArray *histArray;
    NSMutableArray *histShowArrayCompleted;
    NSMutableArray *histShowArrayPending;
    BOOL ishistLoading;
    BOOL isEnd;
    BOOL isStart;
    int totalDisplayedTransfers_completed,index;
    BOOL isFilter;
    BOOL isSearch;
    FPPopoverController*fp;
    NSString*SearchStirng;
    UIActivityIndicatorView *spinner;
    UIView*mapArea;
    float firstX,firstY;
    BOOL isMapOpen;
    NSArray*histArrayCommon;
    UIButton*exportHistory;
    NSMutableArray*histTempCompleted;
    NSMutableArray*histTempPending;
    BOOL isLocalSearch;
    NSString*subTypestr;
    NSDate*ServerDate;
    UILabel * emptyText_localSearch;
    NSIndexPath * indexPathForDeletion;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@end
