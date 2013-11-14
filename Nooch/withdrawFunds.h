//
//  withdrawFunds.h
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoochHome.h"
#import "serve.h"

@interface withdrawFunds : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,serveD>{

    __weak IBOutlet UILabel *headerTitle;
    __weak IBOutlet UILabel *amountReminder;
    __weak IBOutlet UIButton *doneEnteringButton;
    __weak IBOutlet UILabel *prompt;
    NSString *latitudeField;
    NSString *longitudeField;
    NSString *altitudeField;
    IBOutlet UIView *pinView;
    IBOutlet UIView *keyboardAccess;
    IBOutlet UIView *amountKeyboard;
    __weak IBOutlet UIButton *withdrawAll;
    __weak IBOutlet UITextField *amountField;
    __weak IBOutlet UIButton *withdrawGo;
    __weak IBOutlet UITableView *banksTable;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavButton;
    __weak IBOutlet UIButton *decimalButton;
    __weak IBOutlet UIImageView *firstPIN;
    __weak IBOutlet UIImageView *secondPIN;
    __weak IBOutlet UIImageView *thirdPIN;
    __weak IBOutlet UIImageView *fourthPIN;
    __weak IBOutlet UITextField *enterPINField;
}

@end
