//
//  FundsMenu.h
//  Nooch
//
//  Created by crks on 10/3/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "ECSlidingViewController.h"
#import "serve.h"

@interface FundsMenu : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,serveD,UIActionSheetDelegate,UITextFieldDelegate>
{
    NSMutableArray*arrWithrawalOptions;
    //venturepact
    BOOL isEditing;
    UISwitch *on_off;
    
   
    
    int countsubRecords;
    
    NSString*SelectedOption;
    
    NSString*SelectedSubOption;
    
    NSMutableDictionary*dictSelectedWithdrawal;
    
    BOOL isWithdrawalSelected;
    
    NSArray *temp;
    
    NSArray*temp2;
    
    NSDictionary*dictResult;
    
    NSMutableArray*arrAutoWithdrawalF;
    
    NSMutableArray*arrAutoWithdrawalT;
    
    int tagForFrequency;
    
    NSDictionary*dictResponse;
    UITextField*textMyWithdrawal;
    int tagSelectedRow;
    NSString*strTimeFrequency;
    UIButton*Savebtn;
    NSMutableArray*ArrBankAccountCollection;
}
@end
