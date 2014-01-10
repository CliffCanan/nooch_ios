//
//  HistoryFlat.h
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "popSelect.h"
#import "FPPopoverController.h"
BOOL isHistFilter;
NSString*listType;
@interface HistoryFlat : UIViewController<UITableViewDataSource,UITableViewDelegate,serveD,FPPopoverControllerDelegate,UISearchBarDelegate>
{
    NSMutableArray*histArray;
    NSMutableArray*histShowArrayCompleted;
    NSMutableArray*histShowArrayPending;
    BOOL ishistLoading;
    BOOL isEnd;
    BOOL isStart;
    int index;
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
}
@end
