//
//  Signup.h
//  Nooch
//
//  Created by Preston Hults on 10/3/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

NSString *email;
NSString *firstName;
NSString *lastName;
NSString *inviteCode;
BOOL creatingAcct;
UIImage *selectedPic;

@interface Signup : UIViewController<serveD,UITableViewDataSource,UITableViewDelegate>{
    
    __weak IBOutlet UIImageView *picture;
    __weak IBOutlet UINavigationBar *navBar;
     IBOutlet UIButton *leftNavButton;
}

@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeField;

@property (weak, nonatomic) IBOutlet UIButton *fbButton;

@property (weak, nonatomic) IBOutlet UITableView *signupTable;
@property (weak, nonatomic) IBOutlet UIButton *serviceButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UILabel *serviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkBox;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property (weak,nonatomic) IBOutlet UILabel *facebookCheck;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) UITextField *activeField;


@end
