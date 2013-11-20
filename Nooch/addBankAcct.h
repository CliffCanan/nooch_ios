//
//  addBankAcct.h
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoochHome.h"


@interface addBankAcct : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,serveD,UIAlertViewDelegate>{
    
    UIView*loader;
   IBOutlet UIButton*btnAddBank;
    __weak IBOutlet UIButton *nextButton;
    __weak IBOutlet UIButton *previousButton;
    __weak IBOutlet UIButton *doneEntering;
    IBOutlet UIView *inputAccess;
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet UITextField *accountNum;
     __weak IBOutlet UITextField *bankName;
    __weak IBOutlet UITextField *routingNumber;
    __weak IBOutlet UITextField *firstLast;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UITableView *detailsTable;
    __weak IBOutlet UIButton *leftNavButton;
    __weak IBOutlet UINavigationBar *navBar;
    NSMutableArray*arrBankList;
}
@property (strong, nonatomic) IBOutlet UIView *bankListView;
@property (strong, nonatomic) IBOutlet UITableView *tbleBankList;

@end
