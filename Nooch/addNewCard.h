//
//  addNewCard.h
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"
#import "NoochHome.h"

@interface addNewCard : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CardIOPaymentViewControllerDelegate,serveD>{
    NSMutableData *responseData;
    __weak IBOutlet UIButton *nextButton;
    __weak IBOutlet UIButton *previousButton;
    __weak IBOutlet UIButton *doneEntering;
    IBOutlet UIView *inputAccess;
    __weak IBOutlet UITextField *zipField;
    __weak IBOutlet UITextField *expirationField;
    __weak IBOutlet UITextField *secCodeField;
    __weak IBOutlet UITextField *cardNumField;
    __weak IBOutlet UITextField *nameOnCard;
    __weak IBOutlet UITableView *detailsTable;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavButton;
}

@end
