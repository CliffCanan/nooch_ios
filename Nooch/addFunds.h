//
//  addFunds.h
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoochHome.h"
#import "serve.h"

@interface addFunds : UIViewController<serveD,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    
    __weak IBOutlet UILabel *tableHeader;
    __weak IBOutlet UIButton *decimalButton;
    __weak IBOutlet UILabel *amountReminder;
    IBOutlet UIView *amountKeyboard;
    __weak IBOutlet UILabel *prompt;
    __weak IBOutlet UITextField *enterPINField;
    __weak IBOutlet UIImageView *fourthPIN;
    __weak IBOutlet UIImageView *thirdPIN;
    __weak IBOutlet UIImageView *secondPIN;
    __weak IBOutlet UIImageView *firstPIN;
    IBOutlet UIView *pinView;
    __weak IBOutlet UIButton *depositGo;
    __weak IBOutlet UITextField *amountField;
    __weak IBOutlet UITableView *banksTable;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavButton;
    __weak IBOutlet UIButton *doneEnteringButton;
}

@end
