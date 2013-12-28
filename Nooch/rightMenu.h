//
//  rightMenu.h
//  Nooch
//
//  Created by Preston Hults on 5/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "core.h"
#import "NoochHome.h"
#import "serve.h"

@interface rightMenu : UIViewController <UITableViewDelegate,UITableViewDelegate,serveD,UITextFieldDelegate,UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    UIStoryboard *storyboard;
    UIImageView *shadow;
    __weak IBOutlet UITextField *verifyAmount2;
    __weak IBOutlet UITextField *verifyAmount1;
    IBOutlet UIView *verifyView;
    __weak IBOutlet UILabel *detailsDescriptor;
    __weak IBOutlet UILabel *detailsTitle;
    __weak IBOutlet UIButton *updateExpire;
    __weak IBOutlet UIButton *makePrimary;
    __weak IBOutlet UIButton *removeSource;
    __weak IBOutlet UIButton *hideDetails;
    IBOutlet UIView *detailsPopup;
    __weak IBOutlet UITableView *menuTable;
    IBOutlet UIView *addSourceMenu;
    __weak IBOutlet UIButton *addBank;
    __weak IBOutlet UIButton *addCard;
    __weak IBOutlet UIButton *cancelSourceAdd;
    //venturepact
    BOOL isEditing;
    UISwitch *Switch;
    
    NSMutableArray*arrWithrawalOptions;
    
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
   // UISwitch*Switch;
}

@end
