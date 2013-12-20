//
//  sideMenu.h
//  Nooch
//
//  Created by Preston Hults on 5/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "core.h"
#import "NoochHome.h"
#import "ECSlidingViewController.h"
#import "history.h"
#import <MessageUI/MessageUI.h>

@interface sideMenu : UIViewController <UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,serveD> {
    UIImageView *shadow;
    UIStoryboard *storyboard;
    UISwipeGestureRecognizer *close;
    UIViewController *hist;
    __weak IBOutlet UILabel *versionNum;
    __weak IBOutlet UILabel *nameDisplay;
    __weak IBOutlet UILabel *emailDisplay;
    __weak IBOutlet UITableView *menuTable;
    IBOutlet UIView *menuPopup;
    __weak IBOutlet UIButton *firstButton;
    __weak IBOutlet UIButton *secondButton;
    __weak IBOutlet UIButton *thirdButton;
    __weak IBOutlet UIButton *fourthButton;
    __weak IBOutlet UIButton *cancelButton;

    __weak IBOutlet UIButton *cancelLegal;
    __weak IBOutlet UIButton *termsButton;
    __weak IBOutlet UIButton *privacyButton;
    IBOutlet UIView *legalInfoMenu;
    MFMailComposeViewController *mailComposer;
   
}

@end
