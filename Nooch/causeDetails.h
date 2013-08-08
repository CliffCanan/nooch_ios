//
//  causeDetails.h
//  Nooch
//
//  Created by Preston Hults on 6/27/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoochHome.h"
#import "transfer.h"

@interface causeDetails : UIViewController{
    
    __weak IBOutlet UILabel *header1;
    __weak IBOutlet UILabel *header2;
    __weak IBOutlet UIWebView *webview;
    __weak IBOutlet UIScrollView *scroller;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavButton;
    __weak IBOutlet UIButton *donateToCharity;
    __weak IBOutlet UIButton *charityTwitter;
    __weak IBOutlet UIButton *charityFB;
    __weak IBOutlet UIButton *charityWebsite;
    __weak IBOutlet UILabel *charityInfo;
    __weak IBOutlet UILabel *charityName;
    __weak IBOutlet UIImageView *charityPicture;
}

@property (nonatomic,retain) NSString *site;
@property (nonatomic,retain) NSString *fbpage;
@property (nonatomic,retain) NSString *twitpage;
@end
