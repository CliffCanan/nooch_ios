//
//  settings.m
//  Nooch
//
//  Created by Preston Hults on 10/21/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "settings.h"
#import "Base64Encoding.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#import "Base64.h"
#import "Base64Transcoder.h"
#import "initViews.h"

@interface settings ()

@end

//static NSString *pUnreservedCharsString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~";
static	const   char	*Base64Chars	=	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/0=";
static	unsigned char	Base64Inverted[128];

@implementation settings

@synthesize logoutButton,scrollView,firstName,lastName,balance,userPic,profileScroll,name,email,recoveryEmail,password,address,city,state,zip,editPicButton,pinSettingsView,reqImmSwitch,notificationsScroll,b2nRequestEmail,b2nEmail,b2nPush,n2bEmail,n2bPush,n2bRequestEmail,failEmail,failPush,inviteEmail,invitePush,joinedEmail,joinedPush,lowEmail,lowPush,validEmail,validPush,updateEmail,updatePush,newsEmail,newsPush,receivedEmail,receivedPush,unclaimedEmail,sentEmail,fbConnectView,fbSharingSwitch,fbNotConnectedView,swiper1,swiper2,position,stepArray,info1Array,info2Array,backgroundArray,stepLabel,info1,info2,tutorialView,tutorialImage,mailComposer,runOnce,imageData,spinner,accountSettingsTable,helpTable,inputAccessory,aboutTable,profileTable,noochTransfersTable,networkTable,contactsTable,bankNotesTable,contactPhone,logoutTable,resetPasswordTable,resetPasswordView,oldPassword,confirmNewPassword,firstNewPass;
@synthesize addressLine2,tutorialPage,validationBadge;

bool prompt;
bool firstTime;
#pragma mark - inits
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.trackedViewName = @"Settings";
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.trackedViewName = @"Settings";
    [resetPasswordView setHidden:YES];
    [self setSettingsInfoList:[[me usr] objectForKey:@"sets"]];
    [accountSettingsTable setScrollEnabled:NO];
    [accountSettingsTitle setTextColor:[core hexColor:@"737b80"]];
    [accountSettingsTitle setFont:[core nFont:@"Medium" size:16]];
    labelReqImm.layer.cornerRadius = 10;
    labelReqImm.layer.borderWidth = 1;
    labelReqImm.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    labelReqImm.font = [core nFont:@"Medium" size:16];
    labelReqImm.text = @"      Required Immediately";
    [labelChangePIN setHidden:YES];
    /*labelChangePIN.layer.cornerRadius = 10;
    labelChangePIN.layer.borderWidth = 1;
    labelChangePIN.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    labelChangePIN.font = [core nFont:@"Medium" size:16];
    labelChangePIN.text = @"       Change PIN";*/
    [zip setInputAccessoryView:inputAccessory];
    [contactPhone setInputAccessoryView:inputAccessory];
    [name setInputAccessoryView:inputAccessory];
    [email setInputAccessoryView:inputAccessory];
    [address setInputAccessoryView:inputAccessory];
    [addressLine2 setInputAccessoryView:inputAccessory];
    [state setInputAccessoryView:inputAccessory];
    [recoveryEmail setInputAccessoryView:inputAccessory];
    [city setInputAccessoryView:inputAccessory];
    [oldPassword setInputAccessoryView:inputAccessory];
    [firstNewPass setInputAccessoryView:inputAccessory];
    [confirmNewPassword setInputAccessoryView:inputAccessory];

    [logoutTable setUserInteractionEnabled:YES];
    useFacebookPic = YES;
    b2nRequestEmail.userInteractionEnabled = YES;
    b2nEmail.userInteractionEnabled = YES;
    b2nPush.userInteractionEnabled = YES;
    n2bEmail.userInteractionEnabled = YES;
    n2bPush.userInteractionEnabled = YES;
    n2bRequestEmail.userInteractionEnabled = YES;
    failEmail.userInteractionEnabled = YES;
    failPush.userInteractionEnabled = YES;
    inviteEmail.userInteractionEnabled = YES;
    invitePush.userInteractionEnabled = YES;
    joinedEmail.userInteractionEnabled = YES;
    joinedPush.userInteractionEnabled = YES;
    lowEmail.userInteractionEnabled = YES;
    lowPush.userInteractionEnabled = YES;
    validEmail.userInteractionEnabled = YES;
    validPush.userInteractionEnabled = YES;
    updateEmail.userInteractionEnabled = YES;
    updatePush.userInteractionEnabled = YES;
    newsEmail.userInteractionEnabled = YES;
    newsPush.userInteractionEnabled = YES;
    receivedEmail.userInteractionEnabled = YES;
    receivedPush.userInteractionEnabled = YES;
    unclaimedEmail.userInteractionEnabled = YES;
    sentEmail.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer10 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer11 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer22 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer12 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer13 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer14 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer15 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer16 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer17 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer18 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer19 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer20 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer21 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer23 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    UITapGestureRecognizer *recognizer24 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberTapped:)];
    [b2nRequestEmail addGestureRecognizer:recognizer];
    [b2nEmail addGestureRecognizer:recognizer2];
    [b2nPush addGestureRecognizer:recognizer3];
    [n2bEmail addGestureRecognizer:recognizer4];
    [n2bPush addGestureRecognizer:recognizer5];
    [n2bRequestEmail addGestureRecognizer:recognizer6];
    [failEmail addGestureRecognizer:recognizer7];
    [failPush addGestureRecognizer:recognizer8];
    [inviteEmail addGestureRecognizer:recognizer9];
    [invitePush addGestureRecognizer:recognizer10];
    [joinedEmail addGestureRecognizer:recognizer11];
    [joinedPush addGestureRecognizer:recognizer12];
    [lowEmail addGestureRecognizer:recognizer13];
    [lowPush addGestureRecognizer:recognizer14];
    [validEmail addGestureRecognizer:recognizer15];
    [validPush addGestureRecognizer:recognizer16];
    [updateEmail addGestureRecognizer:recognizer17];
    [updatePush addGestureRecognizer:recognizer18];
    [newsEmail addGestureRecognizer:recognizer19];
    [newsPush addGestureRecognizer:recognizer20];
    [receivedEmail addGestureRecognizer:recognizer21];
    [receivedPush addGestureRecognizer:recognizer22];
    [unclaimedEmail addGestureRecognizer:recognizer23];
    [sentEmail addGestureRecognizer:recognizer24];

    firstName.font = [core nFont:@"Medium" size:16];
    lastName.font =  [core nFont:@"Bold" size:17];
    balance.font = [core nFont:@"Medium" size:20];
    name.font = email.font = recoveryEmail.font = state.font = city.font = zip.font = contactPhone.font = [core nFont:@"Medium" size:14];
    address.font = addressLine2.font = [core nFont:@"Medium" size:13];
    password.font = [core nFont:@"Medium" size:16];
    scrollView.contentSize = CGSizeMake(320,860);
    profileScroll.contentSize = CGSizeMake(320,715);
    notificationsScroll.contentSize = CGSizeMake(320,989);
    userPic.clipsToBounds = YES;
    userPic.layer.cornerRadius = 4;

    accountSettingsTable.layer.cornerRadius = 10;
    accountSettingsTable.layer.borderWidth = 1;
    accountSettingsTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    resetPasswordTable.layer.cornerRadius = 10;
    resetPasswordTable.layer.borderWidth = 1;
    resetPasswordTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;

    profileTable.layer.cornerRadius = 10;
    profileTable.layer.borderWidth = 1;
    profileTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    noochTransfersTable.layer.cornerRadius = 10;
    noochTransfersTable.layer.borderWidth = 1;
    noochTransfersTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    networkTable.layer.cornerRadius = 10;
    networkTable.layer.borderWidth = 1;
    networkTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    bankNotesTable.layer.cornerRadius = 10;
    bankNotesTable.layer.borderWidth = 1;
    bankNotesTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    contactsTable.layer.cornerRadius = 10;
    contactsTable.layer.borderWidth = 1;
    contactsTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    logoutTable.layer.cornerRadius = 10;
    logoutTable.layer.borderWidth = 1;
    logoutTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;

    getEncryptedPasswordValue = [[NSString alloc] init];
    imageData = [[NSData alloc] init];
    encodedString = [[NSString alloc] init];
    getEncryptionOldPassword = [[NSString alloc] init];
    getEncryptionNewPassword = [[NSString alloc] init];
    tz = [[NSString alloc] init];
    decryptedPassword = [[NSString alloc] init];
    passwordReset = [[NSString alloc] init];
    notificationID = [[NSString alloc] init];
    GMTTimezonesDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Samoa Standard Time",@"GMT-11:00",
                              @"Hawaiian Standard Time",@"GMT-10:00",
                              @"Alaskan Standard Time",@"GMT-09:00",
                              @"Pacific Standard Time",@"GMT-08:00",
                              @"Mountain Standard Time",@"GMT-07:00",
                              @"Central Standard Time",@"GMT-06:00",
                              @"Eastern Standard Time",@"GMT-05:00",
                              @"Atlantic Standard Time",@"GMT-04:00",
                              @"Tasmania Standard Time",@"GMT+10:00",
                              @"West Pacific Standard Time",@"GMT+10:00",
                              nil];
    picker = [UIImagePickerController new];
    picker.delegate = self;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    if([[[me usr] objectForKey:@"Balance"] length] != 0)
        balance.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    firstName.text=[[me usr] objectForKey:@"firstName"];
    lastName.text=[[me usr] objectForKey:@"lastName"];
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
        [editPicButton setTitle:@"EDIT" forState:UIControlStateNormal];
    }else{
        userPic.image = [UIImage imageNamed:@"profile_picture.png"];
        [editPicButton setTitle:@"ADD" forState:UIControlStateNormal];
    }

    navBar.topItem.title = @"Settings";
    [leftNavButton addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateBanner) userInfo:nil repeats:YES];
}
-(void)goHome{
    [navCtrl dismissModalViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
   
    saveButton.hidden = YES;
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    if(suspended){
        [userBar setHighlighted:YES];
    }else{
        [userBar setHighlighted:NO];
    }
    balance.textColor = [UIColor whiteColor];
    if(profileGO){
        [self goProfile:self];
    }else{
        
    }

    cPinButton.layer.cornerRadius    = 10;
    cPinButton.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    [[cPinButton titleLabel] setFont:[core nFont:@"Medium" size:16]];
    cPinButton.layer.borderWidth = 1;
}
- (IBAction)validationInfo:(id)sender {
    if (validationBadge.isHighlighted) {
        return;
    }
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Account Validation" message:@"To keep Nooch secure, we must verify each user’s identity.  Please complete the following profile to unlock additional features. (We will not share your information with anyone without your explicit permission. Ever.)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
}
-(void)viewDidAppear:(BOOL)animated{
    [self hideMenu];
}
-(void)hideMenu{
    [self.slidingViewController resetTopView];
}

#pragma mark - tableviews delegation
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == accountSettingsTable)
        return 3;
    if(tableView == profileTable)
        return 9;
    if(tableView == noochTransfersTable)
        return 3;
    if(tableView == networkTable)
        return 4;
    if(tableView == contactsTable)
        return 2;
    if(tableView == bankNotesTable)
        return 5;
    if(tableView == logoutTable)
        return 1;
    if(tableView == resetPasswordTable)
        return 3;
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.detailTextLabel.text = @"";
    cell.indentationLevel = 1;
    cell.indentationWidth = 50;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 30, 30)];
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = 6;
    iv.layer.borderWidth = 0;
    //[cell.textLabel setFont:[core nFont:@"Medium" size:24.0]];
    if(tableView == bankNotesTable|| tableView==contactsTable || tableView == networkTable || tableView == noochTransfersTable)
        [cell.textLabel setFont:[core nFont:@"Medium" size:13.0]];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(275,13,13,20)];
    arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
    if(tableView == accountSettingsTable){
        [cell.textLabel setFont:[core nFont:@"Mediumr" size:18.0]];
        [cell.textLabel setTextColor:[core hexColor:@"003c5e"]];
        if(indexPath.row == 0){
            iv.image = [UIImage imageNamed:@"ProfileIcon.png"];
            [cell.contentView addSubview:iv];
            [cell.textLabel setText:@"Profile Info"];
        }else if(indexPath.row == 1){
            iv.image = [UIImage imageNamed:@"PrivacyIcon.png"];
            [cell.contentView addSubview:iv];
            [cell.textLabel setText:@"PIN Settings"];
        }else if(indexPath.row == 2){
            iv.image = [UIImage imageNamed:@"NotificationsIcon.png"];
            [cell.contentView addSubview:iv];
            [cell.textLabel setText:@"Notifications"];
        }
        [cell.contentView addSubview:arrow];
    }else if(tableView == profileTable){
        cell.indentationWidth = 10;
        [cell.textLabel setFont:[core nFont:@"Medium" size:15.5]];
        if(indexPath.row == 0){
            [cell.textLabel setText:@"Name"];
        }else if(indexPath.row ==1){
            [cell.textLabel setText:@"Email"];
        }else if(indexPath.row ==2){
            [cell.textLabel setText:@"Recovery Email"];
        }else if(indexPath.row ==3){
            [cell.contentView addSubview:arrow];
            [cell.textLabel setText:@"Password"];
        }else if(indexPath.row ==4){
            [cell.textLabel setText:@"Cell Number"];
        }else if(indexPath.row ==5){
            [cell.textLabel setText:@"Home Address"];
        }else if(indexPath.row ==6){
            [cell.textLabel setText:@"Home Address 2"];
        }else if(indexPath.row == 7){
            [cell.textLabel setText:@"City"];
        }else if(indexPath.row ==8){
            [cell.textLabel setText:@"State                       Zip"];
        }
    }else if(tableView == noochTransfersTable){
        cell.indentationWidth = 10;
        if(indexPath.row == 0){
            [cell.textLabel setText:@"Transfer Received"];
        }else if(indexPath.row == 1){
            [cell.textLabel setText:@"Transfer Sent"];
        }else if(indexPath.row ==2){
            [cell.textLabel setText:@"Transfer Unclaimed"];
        }
    }else if(tableView == networkTable){
        cell.indentationWidth = 10;
        if(indexPath.row == 0){
            [cell.textLabel setText:@"Low Balance"];
        }else if(indexPath.row == 1){
            [cell.textLabel setText:@"Validation Reminder"];
        }else if(indexPath.row ==2){
            [cell.textLabel setText:@"Product Updates"];
        }else if(indexPath.row ==3){
            [cell.textLabel setText:@"News & Updates"];
        }
    }else if(tableView == contactsTable){
        cell.indentationWidth = 10;
        if(indexPath.row == 0){
            [cell.textLabel setText:@"Invite Request Accepted"];
        }else if(indexPath.row == 1){
            [cell.textLabel setText:@"Contact Joined Nooch"];
        }
    }else if(tableView == bankNotesTable){
        cell.indentationWidth = 10;
        if(indexPath.row == 0){
            [cell.textLabel setText:@"Bank To Nooch Requested"];
        }else if(indexPath.row == 1){
            [cell.textLabel setText:@"Bank To Nooch Completed"];
        }else if(indexPath.row ==2){
            [cell.textLabel setText:@"Nooch To Bank Requested"];
        }else if(indexPath.row ==3){
            [cell.textLabel setText:@"Nooch To Bank Completed"];
        }else if(indexPath.row ==4){
            [cell.textLabel setText:@"Transfer Attempt Failure"];
        }
    }else if(tableView == logoutTable){
        if(indexPath.row == 0){
            [cell setIndentationWidth:110];
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
            [cell.textLabel setText:@"Logout"];
        }
    }else if(tableView == resetPasswordTable){
        cell.indentationWidth = 10;
        [cell.textLabel setFont:[core nFont:@"Medium" size:13.0]];
        if(indexPath.row == 0){
            [cell.textLabel setText:@"Old Password"];
        }else if(indexPath.row == 1){
            [cell.textLabel setText:@"New Password"];
        }else if(indexPath.row == 2){
            [cell.textLabel setText:@"Confirm Password"];
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"selected something");
    if(tableView == accountSettingsTable){
        if(indexPath.row == 0)
            [self goProfile:self];
        else if(indexPath.row == 1)
            [self pinSettings:self];
        else if(indexPath.row == 2)
            [self notificationsSettings:self];
        else if(indexPath.row == 4){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Coming Soon" message:@"You can't invite people just yet. In the meantime, use word of mouth! Add us on Facebook, Twitter, Google+, Instagram, and tell your friends!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}

#pragma mark - textfield delegation
-(void) textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == confirmNewPassword){
        [resetPasswordView setFrame:CGRectMake(0,50,320,600)];
    }
    if(textField == password){
        [resetPasswordView setHidden:NO];
        navBar.topItem.title = @"Reset Password";
        [leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
        [leftNavButton setFrame:CGRectMake(0, 0, 43, 43)];
        //[leftNavButton setBackgroundImage:[UIImage imageNamed:@"ProfileBack.png"] forState:UIControlStateNormal];
        //[leftNavButton setFrame:CGRectMake(0, 0, 63, 30)];
        [leftNavButton removeTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftNavButton addTarget:self action:@selector(goBack2) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setHidden:NO];
        [saveButton removeTarget:self action:@selector(saveProfile) forControlEvents:UIControlEventTouchUpInside];
        [saveButton addTarget:self action:@selector(finishResetPassword:) forControlEvents:UIControlEventTouchUpInside];
        [textField resignFirstResponder];
        firstNewPass.text = @"";
        confirmNewPassword.text = @"";
        oldPassword.text = @"";
        return;
    }
    if(textField.tag > 2 && textField.tag <9){
        [profileScroll setContentOffset:CGPointMake(0.0,textField.frame.size.height+30*textField.tag) animated:YES];
        if(textField == recoveryEmail)
            [profileScroll setContentOffset:CGPointMake(0.0,textField.frame.size.height+15*textField.tag) animated:YES];
        if(textField == contactPhone)
            [profileScroll setContentOffset:CGPointMake(0.0,textField.frame.size.height+15*textField.tag) animated:YES];
    }else if(textField.tag == 9)
        [profileScroll setContentOffset:CGPointMake(0.0,315) animated:YES];

    if(textField == email){
        [recoveryEmail becomeFirstResponder];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Noooo!" message:@"If you would like to change your primary email address, please contact us with your request." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField == password){


    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == contactPhone){
        int length = [self getLength:textField.text];
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }

        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            //NSLog(@"%@",[num  substringToIndex:3]);
            //NSLog(@"%@",[num substringFromIndex:3]);
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    return YES;
}
-(NSString*)formatNumber:(NSString*)mobileNumber{

    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    NSLog(@"%@", mobileNumber);

    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);

    }


    return mobileNumber;
}
-(int)getLength:(NSString*)mobileNumber{

    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    int length = [mobileNumber length];

    return length;


}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [profileScroll setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    [resetPasswordView setFrame:CGRectMake(0,50,320,600)];
    if(resetPasswordView.isHidden){

    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if([name isFirstResponder]  &&  [touch view] != name)
    {
        [name resignFirstResponder];
    }
    else if([email isFirstResponder] && [touch view] != email)
    {
        [email resignFirstResponder];
    }
    else if([password isFirstResponder] && [touch view] != password)
    {
        [password resignFirstResponder];
    }
    else if([address isFirstResponder] && [touch view] != address)
    {
        [address resignFirstResponder];
    }else if([recoveryEmail isFirstResponder] && [touch view] != recoveryEmail)
    {
        [recoveryEmail resignFirstResponder];
    }else if([state isFirstResponder] && [touch view] != state)
    {
        [state resignFirstResponder];
    }else if([city isFirstResponder] && [touch view] != city)
    {
        [city resignFirstResponder];
    }else if([zip isFirstResponder] && [touch view] != zip)
    {
        [zip resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (IBAction)doneEditing:(id)sender {
    [name resignFirstResponder];
    [email resignFirstResponder];
    [recoveryEmail resignFirstResponder];
    [address resignFirstResponder];
    [addressLine2 resignFirstResponder];
    [contactPhone resignFirstResponder];
    [city resignFirstResponder];
    [state resignFirstResponder];
    [zip resignFirstResponder];
    [firstNewPass resignFirstResponder];
    [confirmNewPassword resignFirstResponder];
    [oldPassword resignFirstResponder];
    [self.tabBarController.navigationItem.rightBarButtonItem setEnabled:YES];
}
- (IBAction)previousField:(id)sender {
    if(name.isFirstResponder){
        return;
    }else if(email.isFirstResponder) {
        [name becomeFirstResponder];
    }else if(recoveryEmail.isFirstResponder){
        [name becomeFirstResponder];
    }else if(contactPhone.isFirstResponder){
        [recoveryEmail becomeFirstResponder];
    }else if(address.isFirstResponder){
        [contactPhone becomeFirstResponder];
    }else if(city.isFirstResponder){
        [addressLine2 becomeFirstResponder];
    }else if(addressLine2.isFirstResponder){
        [address becomeFirstResponder];
    }else if(state.isFirstResponder){
        [city becomeFirstResponder];
    }else if(zip.isFirstResponder){
        [state becomeFirstResponder];
    }else if(firstNewPass.isFirstResponder){
        [oldPassword becomeFirstResponder];
    }else if(confirmNewPassword.isFirstResponder){
        [firstNewPass becomeFirstResponder];
    }
}
- (IBAction)nextField:(id)sender {
    if(name.isFirstResponder){
        [recoveryEmail becomeFirstResponder];
    }else if(email.isFirstResponder) {
        [recoveryEmail becomeFirstResponder];
    }else if(recoveryEmail.isFirstResponder){
        [contactPhone becomeFirstResponder];
    }else if(contactPhone.isFirstResponder){
        [address becomeFirstResponder];
    }else if(address.isFirstResponder){
        [addressLine2 becomeFirstResponder];
    }else if(addressLine2.isFirstResponder){
        [city becomeFirstResponder];
    }else if(city.isFirstResponder){
        [state becomeFirstResponder];
    }else if(state.isFirstResponder){
        [zip becomeFirstResponder];
    }else if(zip.isFirstResponder){
        return;
    }else if(firstNewPass.isFirstResponder){
        [confirmNewPassword becomeFirstResponder];
    }else if(oldPassword.isFirstResponder){
        [firstNewPass becomeFirstResponder];
    }
}

#pragma mark - userbar buttons/navigation
-(void)updateBanner{
    if([[[me usr] objectForKey:@"Balance"] length] != 0)
        balance.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    firstName.text=[[me usr] objectForKey:@"firstName"];
    lastName.text=[[me usr] objectForKey:@"lastName"];
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
        [editPicButton setTitle:@"EDIT" forState:UIControlStateNormal];
    }else{
        if (!firstTime){
            userPic.image = [UIImage imageNamed:@"profile_picture.png"];
            //[me fetchPic];
        }
        [editPicButton setTitle:@"ADD" forState:UIControlStateNormal];
    }
}
-(void)inviteProcess{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Coming Soon" message:@"You can't invite people just yet. In the meantime, use word of mouth! Add us on Facebook, Twitter, Google+, Instagram, and tell your friends!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}
- (IBAction)fundsHighlight:(id)sender {
    balance.textColor = [core hexColor:@"6c92a6"];
}
- (IBAction)fundsDehighlight:(id)sender {
    balance.textColor = [UIColor whiteColor];
}
-(void)firstLoad{
    firstTime = YES;
    userPic.image = [UIImage imageWithData:tempImg];
    [self goProfile:self];
}
- (IBAction)goProfile:(id)sender {
    firstName.textColor = lastName.textColor = [core hexColor:@"6c92a6"];
    [profileSettingsButton setUserInteractionEnabled:NO];
    profileScroll.hidden = NO;
    notificationsScroll.hidden = YES;
    fbConnectView.hidden = YES;
    fbNotConnectedView.hidden = YES;
    tutorialView.hidden = YES;
    pinSettingsView.hidden = YES;
    editPicButton.hidden = NO;
    CGRect inFrame = [profileScroll frame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    inFrame.origin.x = 0;
    [profileScroll setFrame:inFrame];
    inFrame = scrollView.frame;
    inFrame.origin.x = -320;
    [scrollView setFrame:inFrame];
    inFrame = validationBadge.frame;
    inFrame.origin.x = 0;
    [validationBadge setFrame:inFrame];
    [UIView commitAnimations];
    navBar.topItem.title = @"Profile Info";
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [leftNavButton setFrame:CGRectMake(0, 0, 43, 43)];
    //[leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackSettings.png"] forState:UIControlStateNormal];
    //[leftNavButton setFrame:CGRectMake(0, 0, 70, 30)];
    [leftNavButton removeTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setHidden:NO];
    [saveButton addTarget:self action:@selector(saveProfile) forControlEvents:UIControlEventTouchUpInside];
    if(![[[me usr] objectForKey:@"validated"] boolValue]){
        [validationBadge setHighlighted:NO];
    }else{
        [validationBadge setHighlighted:YES];
    }
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(revertNameFlash) userInfo:nil repeats:NO];
}
-(void)revertNameFlash{
    firstName.textColor = lastName.textColor = [UIColor whiteColor];
}
-(void)goBack{
    [profileSettingsButton setUserInteractionEnabled:YES];
    navBar.topItem.title = @"Settings";
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"DoneGreen.png"] forState:UIControlStateNormal];
    [leftNavButton setFrame:CGRectMake(0, 0, 54, 30)];
    [leftNavButton removeTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setHidden:YES];
    [saveButton removeTarget:self action:@selector(saveProfile) forControlEvents:UIControlEventTouchUpInside];
    [saveButton removeTarget:self action:@selector(saveNotificationSettings) forControlEvents:UIControlEventTouchUpInside];
    if(prompt){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Save changes?" message:@"You've left the profile information screen without saving. Would you like to save the changes you made?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [av setTag:21];
        [av show];
    }
    CGRect inFrame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if(!profileScroll.hidden){
        inFrame = profileScroll.frame;
        inFrame.origin.x = 320;
        [profileScroll setFrame:inFrame];
        inFrame = validationBadge.frame;
        inFrame.origin.x = 320;
        [validationBadge setFrame:inFrame];
    }else if(!notificationsScroll.hidden){
        inFrame = notificationsScroll.frame;
        inFrame.origin.x = 320;
        [notificationsScroll setFrame:inFrame];
    }else if(!pinSettingsView.hidden){
        inFrame = pinSettingsView.frame;
        inFrame.origin.x = 320;
        [pinSettingsView setFrame:inFrame];
    }else if(!fbNotConnectedView.hidden){
        inFrame = fbNotConnectedView.frame;
        inFrame.origin.x = 320;
        [fbNotConnectedView setFrame:inFrame];
    }else if(!fbConnectView.hidden){
        inFrame = fbConnectView.frame;
        inFrame.origin.x = 320;
        [fbConnectView setFrame:inFrame];
    }else if(!tutorialView.hidden){
        inFrame = tutorialView.frame;
        inFrame.origin.x = 320;
        [tutorialView setFrame:inFrame];
    }
    inFrame = scrollView.frame;
    inFrame.origin.x = 0;
    [scrollView setFrame:inFrame];
    [UIView commitAnimations];

    [name resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    [recoveryEmail resignFirstResponder];
    [address resignFirstResponder];
    [addressLine2 resignFirstResponder];
    [state resignFirstResponder];
    [city resignFirstResponder];
    [zip resignFirstResponder];

    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(hideviews) userInfo:nil repeats:NO];
}
-(void)hideviews{
    profileScroll.hidden = YES;
    editPicButton.hidden = YES;
    pinSettingsView.hidden = YES;
    notificationsScroll.hidden = YES;
    fbNotConnectedView.hidden = YES;
    fbConnectView.hidden = YES;
    tutorialView.hidden = YES;
}
-(void)goBack2{
    [firstNewPass resignFirstResponder];
    [confirmNewPassword resignFirstResponder];
    [oldPassword resignFirstResponder];
    [resetPasswordView setHidden:YES];
    navBar.topItem.title = @"Profile Info";
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [leftNavButton setFrame:CGRectMake(0, 0, 43, 43)];
    //[leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackSettings.png"] forState:UIControlStateNormal];
    //[leftNavButton setFrame:CGRectMake(0, 0, 70, 30)];
    [leftNavButton removeTarget:self action:@selector(goBack2) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setHidden:NO];
    [saveButton removeTarget:self action:@selector(finishResetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton addTarget:self action:@selector(saveProfile) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - profile page
- (IBAction)editPic:(id)sender {
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Facebook Picture", @"Use Camera", @"From iPhone Library", nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
    [zip resignFirstResponder];
    [name resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    [address resignFirstResponder];
    [addressLine2 resignFirstResponder];
    [recoveryEmail resignFirstResponder];
    [state resignFirstResponder];
    [city resignFirstResponder];
}
-(void)setSettingsInfoList:(NSMutableDictionary *) sInfoDic{
    name.text =[[NSString alloc]initWithFormat:@"%@ %@",[[me usr] valueForKey:@"firstName"],[[me usr] valueForKey:@"lastName"]];
    if([sInfoDic objectForKey:@"UserName"]!=[NSNull null])
    {
        self.email.text=[sInfoDic objectForKey:@"UserName"];
    }
    if([sInfoDic objectForKey:@"RecoveryMail"]!=[NSNull null])
    {
        self.recoveryEmail.text=[sInfoDic objectForKey:@"RecoveryMail"];
    }
    if([sInfoDic objectForKey:@"Address"]!=[NSNull null])
    {
        if([[me usr] objectForKey:@"Addr1"] != NULL && [[me usr] objectForKey:@"Addr2"] != NULL){
            self.address.text = [[me usr] objectForKey:@"Addr1"];
            self.addressLine2.text = [[me usr] objectForKey:@"Addr2"];
        }else
            self.address.text=[sInfoDic objectForKey:@"Address"];
    }
    if([sInfoDic objectForKey:@"City"]!=[NSNull null])
    {
        self.city.text=[sInfoDic objectForKey:@"City"];
    }
    if([sInfoDic objectForKey:@"State"]!=[NSNull null])
    {
        self.state.text=[sInfoDic objectForKey:@"State"];
    }
    if([sInfoDic objectForKey:@"TimeZoneKey"]!=[NSNull null])
    {
        tz=[sInfoDic objectForKey:@"TimeZoneKey"];
    }
    if([sInfoDic objectForKey:@"Zipcode"]!=[NSNull null])
    {
        self.zip.text=[sInfoDic objectForKey:@"Zipcode"];
    }
    if([sInfoDic objectForKey:@"ContactNumber"]!=[NSNull null] && [[sInfoDic objectForKey:@"ContactNumber"] length] == 10)
    {
        self.contactPhone.text = [NSString stringWithFormat:@"(%@) %@-%@",[[sInfoDic objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(0, 3)],[[sInfoDic objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(3, 3)],[[sInfoDic objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(6, 4)]];
    }
    if([sInfoDic objectForKey:@"Password"]!=[NSNull null])
    {
        Decryption *decry = [[Decryption alloc] init];
        decry.Delegate = self;
        decry->tag = [NSNumber numberWithInteger:2];
        [decry getDecryptedValue:@"GetDecryptedData" pwdString:[sInfoDic objectForKey:@"Password"]];
    }
    if([[[me usr] objectForKey:@"validated"] boolValue]){
        //set validated badge
        [validationBadge setHighlighted:YES];
    }else{
        [validationBadge setHighlighted:NO];
    }
    if(([contactPhone.text isEqualToString:@""] || [address.text isEqualToString:@""]) && profileScroll.frame.origin.x == 0){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Don't fret" message:@"We at Nooch are concerned with your privacy too! Any information you enter here is strictly for security and validation purposes. We will never disclose your personal information to anyone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)
    {
        [self.view addSubview:[me waitStat:@"Fetching your Facebook picture..."]];
        if(me.fbAllowed){
            
            //NSString *imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", fbUID];
            NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me/picture"];
            SLRequest *imageReq =[SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:meurl parameters:nil];
            imageReq.account = me.facebookAccount;
            __block NSData *imgData = [NSData new];
            [imageReq performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (error) {
                    NSLog(@"error -%@", [error debugDescription]);
                }else{
                    imgData = [NSData dataWithData:[responseData copy]];
                    [[me pic] setData:imgData];
                    userPic.image = [UIImage imageWithData:[me pic]];
                    useFacebookPic = YES;
                    prompt = YES;
                }
                [me endWaitStat];
            }];
        }else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Connected!" message:@"You must be connected to Facebook in order to use your Facebook picture." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }

    }
    else if(buttonIndex == 1)
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [[[UIApplication sharedApplication] keyWindow] addSubview:picker.view];
        useFacebookPic = NO;
        prompt = YES;
    }

    else if(buttonIndex == 2)
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [[[UIApplication sharedApplication] keyWindow] addSubview:picker.view];
        useFacebookPic = NO;
        prompt = YES;
    }
}
-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;

    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 75.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 115.0;
        }
        else{
            imgRatio = 75.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 75.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker1.view removeFromSuperview];
    userPic.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    userPic.image=[self imageWithImage:userPic.image scaledToSize:CGSizeMake(40.f,40.f)];
    imageData = UIImagePNGRepresentation(userPic.image);
    [[me pic] setData:imageData];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1{
	[picker1.view removeFromSuperview];
}
- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingImage:(UIImage *)image1 editingInfo:(NSDictionary *)editingInfo{
    NSData *imgData = [NSData alloc];
    imgData = UIImagePNGRepresentation(image1);
    imageData = imgData;
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerViewC numberOfRowsInComponent:(NSInteger)component{
    return 1;
}
- (IBAction)profileSettings:(id)sender {
    profileScroll.hidden = NO;
    editPicButton.hidden = NO;
    CGRect inFrame = [profileScroll frame];
    inFrame.origin.x = 320;
    [profileScroll setFrame:inFrame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    inFrame.origin.x = 0;
    [profileScroll setFrame:inFrame];
    inFrame = scrollView.frame;
    inFrame.origin.x = -320;
    [scrollView setFrame:inFrame];
    [UIView commitAnimations];
}
- (void)saveProfile {
    
    UIAlertView *av =[ [UIAlertView alloc] initWithTitle:@"I don't see you!" message:@"You haven't set your profile picture, would you like to?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [av setTag:20];
    if([[me pic] isKindOfClass:[NSNull class]]){
        [av show];
    }
    [self.view addSubview:[me waitStat:@"Saving your profile..."]];
    [self getEncryptedPassword:password.text];
    NSString *timezoneStandard;
    if([self.recoveryEmail.text length]==0)
    {
        self.recoveryEmail.text=@"";
    }
    if([self.state.text length]==0)
    {
        self.state.text=@"";
    }
    timezoneStandard = [NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone]];
    timezoneStandard = [[timezoneStandard componentsSeparatedByString:@", "] objectAtIndex:0];
    timezoneStandard = [GMTTimezonesDictionary objectForKey:timezoneStandard];
    timezoneStandard = @"";
    imageData = [me pic];
    if(imageData.length != 0){
        encodedString =  [NSString base64StringFromData:imageData length:imageData.length];
    }else{
        encodedString=@"";
    }
    NSMutableDictionary *imageDic = [[NSMutableDictionary alloc] init];
    NSString *imageLen = [NSString stringWithFormat:@"%d",imageData.length];
    imageDic = [NSMutableDictionary dictionaryWithObjectsAndKeys: encodedString, @"FileContent", imageLen, @"ContentLength", @".png", @"FileExtension", nil];
    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    if([password.text length] != 0)
    {
        if([password.text length] < 8){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain minimum of 8 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }else if([password.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain at least one numeric character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }

        else if([password.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain at least one character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }

        else {
            [self getEncryptedPassword:password.text];
        }
    }
    NSString *recoverMail = [[NSString alloc] init];
    if([self.recoveryEmail.text length] > 0){
        recoverMail = self.recoveryEmail.text;
    }else
        recoverMail = @"";

    /*if([self.address.text length] == 0 || [self.city.text length] == 0 || [self.zip.text length] == 0|| [self.state.text length] == 0 || [self.contactPhone.text length] == 0 || [self.email.text length] == 0){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Profile information is incomplete." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }*/
    if([self.addressLine2.text length] != 0){
        [[me usr] setObject:self.addressLine2.text forKey:@"Addr2"];
        [[me usr] setObject:self.address.text forKey:@"Addr1"];
    }else{
        [[me usr] removeObjectForKey:@"Addr2"];
    }
    NSMutableDictionary *transactionInput  =[[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",self.name.text,@"FirstName",self.email.text,@"UserName",nil];
    [transactionInput setObject:getEncryptedPasswordValue forKey:@"Password"];
    [transactionInput setObject:[NSString stringWithFormat:@"%@ %@",self.address.text,self.addressLine2.text] forKey:@"Address"];
    [transactionInput setObject:self.city.text forKey:@"City"];
    NSString *number = [NSString stringWithFormat:@"%@%@%@",[contactPhone.text substringWithRange:NSMakeRange(1, 3)],[contactPhone.text substringWithRange:NSMakeRange(6, 3)],[contactPhone.text substringWithRange:NSMakeRange(10, 4)]];
    [transactionInput setObject:number forKey:@"ContactNumber"];
    [transactionInput setObject:self.zip.text forKey:@"Zipcode"];
    [transactionInput setObject:@"false" forKey:@"UseFacebookPicture"];
    [transactionInput setObject:imageDic forKey:@"AttachmentFile"];
    [transactionInput setObject:recoverMail forKey:@"RecoveryMail"];
    [transactionInput setObject:self.state.text forKey:@"State"];
    [transactionInput setObject:timezoneStandard forKey:@"TimeZoneKey"];
    NSMutableDictionary *transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"mySettings", nil];
    serve *req=[[serve alloc]init];
    req.Delegate = self;
    req.tagName=@"MySettingsResult";
    //NSLog(@"transaction INput %@",transaction);
    [req setSets:transaction];
    firstTime = NO;
}

#pragma mark - password encryption
-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue{
    decryptedPassword=[sourceData objectForKey:@"Status"];
    password.text = decryptedPassword;
    [self getEncryptedPassword:password.text];
    NSLog(@"should be encrypting password");

}
-(void)setEncryptedPassword:(NSString *) encryptedPwd{
    getEncryptedPasswordValue = [[NSString alloc] initWithString:encryptedPwd];
}
-(void) getEncryptedPassword:(NSString *)newPassword{

    if([newPassword length]!=0){
        GetEncryptionValue *encryPassword = [[GetEncryptionValue alloc] init];
        [encryPassword getEncryptionData:newPassword];
        encryPassword.Delegate = self;
        encryPassword->tag = [NSNumber numberWithInteger:2];
    }
    NSLog(@"encrypting password");
}
-(void) resetPassword:(NSString *)newPassword{

    if([newPassword length]!=0){
        GetEncryptionValue *encryPassword = [[GetEncryptionValue alloc] init];
        [encryPassword getEncryptionData:newPassword];
        encryPassword.Delegate = self;
        encryPassword->tag = [NSNumber numberWithInteger:3];
    }
    NSLog(@"ecrypting password");
}
-(void)encryptionDidFinish:(NSString *) encryptedData TValue:(NSNumber *) tagValue{
    NSInteger value = [tagValue integerValue];
    [self setEncryptedPassword:encryptedData];
    if(value ==3)
    {
        getEncryptionNewPassword=encryptedData;
        [self resetNewPassword:(NSString *)getEncryptionNewPassword];
    }

}
-(void) resetNewPassword:(NSString *)encryptedNewPassword{
    [self.view addSubview:[me waitStat:@"Attempting password reset..."]];
    getEncryptionOldPassword=password.text;

    serve *respass = [[serve alloc] init];
    respass.Delegate = self;
    respass.tagName = @"resetPasswordDetails";
    [respass resetPassword:getEncryptionOldPassword new:getEncryptionNewPassword];

}
- (IBAction)finishResetPassword:(id)sender {
    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    if([firstNewPass.text isEqualToString:confirmNewPassword.text]){
        if([firstNewPass.text length] < 8){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain minimum of 8 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }else if([firstNewPass.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain atleast one numeric character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if([firstNewPass.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain atleast one character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }else{
            passwordReset = firstNewPass.text;
            [self resetPassword:firstNewPass.text];
        }
    }else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Passwords do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        passwordReset = @"";
    }
}

#pragma mark - PIN
- (IBAction)pinSettings:(id)sender {
    navBar.topItem.title = @"PIN Settings";
    if(![[[me usr] objectForKey:@"requiredImmediately"] boolValue]){
        [reqImmSwitch setOn:NO];
    }else{
        [reqImmSwitch setOn:YES];
    }
    pinSettingsView.hidden = NO;
    CGRect inFrame = [pinSettingsView frame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    inFrame.origin.x -= 320;
    [pinSettingsView setFrame:inFrame];
    inFrame = scrollView.frame;
    inFrame.origin.x -= 320;
    [scrollView setFrame:inFrame];
    [UIView commitAnimations];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [leftNavButton setFrame:CGRectMake(0, 0, 43, 43)];
    //[leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackSettings.png"] forState:UIControlStateNormal];
    //[leftNavButton setFrame:CGRectMake(0, 0, 70, 30)];
    [leftNavButton removeTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}
- (IBAction)changePIN:(id)sender {
    resetPIN = YES; reqImm = NO;
    UIViewController *pinChange = [storyboard instantiateViewControllerWithIdentifier:@"pin"];
    [self presentModalViewController:pinChange animated:YES];
    [pinChange performSelector:@selector(resetPinFlag)];
}
- (IBAction)requireImmediately:(id)sender {
    if(reqImmSwitch.on){
        [[me usr] setObject:@"YES" forKey:@"requiredImmediately"];
    }else{
        [[me usr] setObject:@"NO" forKey:@"requiredImmediately"];
    }
}

#pragma mark - notifications
- (IBAction)notificationsSettings:(id)sender {
    notificationsScroll.hidden = NO;
    CGRect inFrame = [notificationsScroll frame];
    inFrame.origin.x = 320;
    [notificationsScroll setFrame:inFrame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    inFrame.origin.x -= 320;
    [notificationsScroll setFrame:inFrame];
    inFrame = scrollView.frame;
    inFrame.origin.x -= 320;
    [scrollView setFrame:inFrame];
    [UIView commitAnimations];
    navBar.topItem.title = @"Notifications";
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [leftNavButton setFrame:CGRectMake(0, 0, 43, 43)];
    //[leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackSettings.png"] forState:UIControlStateNormal];
    //[leftNavButton setFrame:CGRectMake(0, 0, 70, 30)];
    [leftNavButton removeTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setHidden:NO];
    [saveButton addTarget:self action:@selector(saveNotificationSettings) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:[me waitStat:@"Loading notification settings..."]];
    serve * getPushNotification=[[serve alloc]init];
    getPushNotification.tagName=@"getPushnotification";
    getPushNotification.delegate=self;
    [getPushNotification getNoteSettings];

    serve * getEmailNotification=[[serve alloc]init];
    getEmailNotification.tagName=@"getEmailnotification";
    getEmailNotification.delegate=self;
    [getEmailNotification getNoteSettings];
}
-(void)numberTapped:(id)sender{
    switch(((UIGestureRecognizer *)sender).view.tag)
    {
        case 1:{
            if(receivedEmail.isHighlighted)
                [receivedEmail setHighlighted:NO];
            else
                [receivedEmail setHighlighted:YES];
            break;
        }case 2:{
            if(receivedPush.isHighlighted)
                [receivedPush setHighlighted:NO];
            else
                [receivedPush setHighlighted:YES];
            break;
        }case 3:{
            if(sentEmail.isHighlighted)
                [sentEmail setHighlighted:NO];
            else
                [sentEmail setHighlighted:YES];
            break;
        }case 4:{
            if(unclaimedEmail.isHighlighted)
                [unclaimedEmail setHighlighted:NO];
            else
                [unclaimedEmail setHighlighted:YES];
            break;
        }case 5:{
            if(lowEmail.isHighlighted)
                [lowEmail setHighlighted:NO];
            else
                [lowEmail setHighlighted:YES];
            break;
        }case 6:{
            if(lowPush.isHighlighted)
                [lowPush setHighlighted:NO];
            else
                [lowPush setHighlighted:YES];
            break;
        }case 7:{
            if(validEmail.isHighlighted)
                [validEmail setHighlighted:NO];
            else
                [validEmail setHighlighted:YES];
            break;
        }case 8:{
            if(validPush.isHighlighted)
                [validPush setHighlighted:NO];
            else
                [validPush setHighlighted:YES];
            break;
        }case 9:{
            if(updateEmail.isHighlighted)
                [updateEmail setHighlighted:NO];
            else
                [updateEmail setHighlighted:YES];
            break;
        }case 10:{
            if(updatePush.isHighlighted)
                [updatePush setHighlighted:NO];
            else
                [updatePush setHighlighted:YES];
            break;
        }case 11:{
            if(newsEmail.isHighlighted)
                [newsEmail setHighlighted:NO];
            else
                [newsEmail setHighlighted:YES];
            break;
        }case 12:{
            if(newsPush.isHighlighted)
                [newsPush setHighlighted:NO];
            else
                [newsPush setHighlighted:YES];
            break;
        }case 13:{
            if(inviteEmail.isHighlighted)
                [inviteEmail setHighlighted:NO];
            else
                [inviteEmail setHighlighted:YES];
            break;
        }case 14:{
            if(invitePush.isHighlighted)
                [invitePush setHighlighted:NO];
            else
                [invitePush setHighlighted:YES];
            break;
        }case 15:{
            if(joinedEmail.isHighlighted)
                [joinedEmail setHighlighted:NO];
            else
                [joinedEmail setHighlighted:YES];
            break;
        }case 16:{
            if(joinedPush.isHighlighted)
                [joinedPush setHighlighted:NO];
            else
                [joinedPush setHighlighted:YES];
            break;
        }case 17:{
            if(b2nRequestEmail.isHighlighted)
                [b2nRequestEmail setHighlighted:NO];
            else
                [b2nRequestEmail setHighlighted:YES];
            break;
        }case 18:{
            if(b2nEmail.isHighlighted)
                [b2nEmail setHighlighted:NO];
            else
                [b2nEmail setHighlighted:YES];
            break;
        }case 19:{
            if(b2nPush.isHighlighted)
                [b2nPush setHighlighted:NO];
            else
                [b2nPush setHighlighted:YES];
            break;
        }case 20:{
            if(n2bRequestEmail.isHighlighted)
                [n2bRequestEmail setHighlighted:NO];
            else
                [n2bRequestEmail setHighlighted:YES];
            break;
        }case 21:{
            if(n2bEmail.isHighlighted)
                [n2bEmail setHighlighted:NO];
            else
                [n2bEmail setHighlighted:YES];
            break;
        }case 22:{
            if(n2bPush.isHighlighted)
                [n2bPush setHighlighted:NO];
            else
                [n2bPush setHighlighted:YES];
            break;
        }case 23:{
            if(failEmail.isHighlighted)
                [failEmail setHighlighted:NO];
            else
                [failEmail setHighlighted:YES];
            break;
        }case 24:{
            if(failPush.isHighlighted)
                [failPush setHighlighted:NO];
            else
                [failPush setHighlighted:YES];
            break;
        }
    }

}
- (void)saveNotificationSettings {
    NSDictionary *transactionInput=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",receivedEmail.isHighlighted?@"true":@"false",@"EmailTransferReceived",sentEmail.isHighlighted?@"true":@"false",@"EmailTransferSent",unclaimedEmail.isHighlighted?@"true":@"false",@"TransferUnclaimed",b2nRequestEmail.isHighlighted?@"true":@"false",@"BankToNoochRequested",b2nEmail.isHighlighted?@"true":@"false",@"BankToNoochCompleted",n2bRequestEmail.isHighlighted?@"true":@"false",@"NoochToBankRequested",n2bEmail.isHighlighted?@"true":@"false",@"NoochToBankCompleted",failEmail.isHighlighted?@"true":@"false",@"EmailTransferAttemptFailure",joinedEmail.isHighlighted?@"true":@"false",@"EmailFriendRequest",inviteEmail.isHighlighted?@"true":@"false",@"EmailInviteRequestAccept",@"true",@"InviteReminder",lowEmail.isHighlighted?@"true":@"false",@"LowBalance",validEmail.isHighlighted?@"true":@"false",@"ValidationRemainder",updateEmail.isHighlighted?@"true":@"false",@"ProductUpdates",newsEmail.isHighlighted?@"true":@"false",@"NewAndUpdate",notificationID,@"MemberNotificationId", nil];
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"notificationSettings", nil];
    serve *notificationService=[[serve alloc]init];
    notificationService.tagName=@"emailNotification";
    notificationService.Delegate=self;
    [notificationService setEmailSets:notificationDictionary];

    NSDictionary *pushNotes=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",receivedPush.isHighlighted?@"true":@"false",@"TransferReceived",joinedPush.isHighlighted?@"true":@"false",@"FriendRequest",invitePush.isHighlighted?@"true":@"false",@"InviteRequestAccept",failPush.isHighlighted?@"true":@"false",@"TransferAttemptFailure",n2bPush.isHighlighted?@"true":@"false",@"NoochToBank",b2nPush.isHighlighted?@"true":@"false",@"BankToNooch",lowPush.isHighlighted?@"true":@"false",@"LowBalance",validPush.isHighlighted?@"true":@"false",@"ValidationReminder",updatePush.isHighlighted?@"true":@"false",@"ProductUpdates",newsPush.isHighlighted?@"true":@"false",@"NewAndUpdate",notificationID,@"NotificationId", nil];
    NSMutableDictionary *pushNotify = [[NSMutableDictionary alloc] initWithObjectsAndKeys:pushNotes, @"notificationSettings", nil];
    serve *pushUpdate=[[serve alloc]init];
    pushUpdate.tagName=@"pushNotification";
    pushUpdate.Delegate=self;
    [pushUpdate setPushSets:pushNotify];
    [self.view addSubview:[me waitStat:@"Saving your notifications settings..."]];
}

#pragma mark - facebook
- (NSString *)ToBase64:(NSData *)pBase64Data;{
	unsigned char *pInData = (unsigned char *)[pBase64Data bytes];
	int InLength = [pBase64Data length];
	int OutLength=0;
	unsigned char *pOutData = malloc(InLength*4);


	int	I=0;
	//	for(I=0;I<	((Length>>2)<<2);I	+=	3)
	for(I=0;I<	InLength-2;I	+=	3)
	{
		uint32_t	I32	=	(pInData[I]	<<	16)	+(pInData[I+1]	<<	8)	+	pInData[I+2];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	6)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	)	&	0x3f];
	}
	if(InLength-I	==	1)
	{
		uint32_t	I32	=	(pInData[I]	<<	16);
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	'=';
		pOutData[OutLength++]	=	'=';
	}	else		if(InLength-I	==	2)
	{
		uint32_t	I32	=	(pInData[I]	<<	16)	+(pInData[I+1]	<<	8);
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	6)	&	0x3f];
		pOutData[OutLength++]	=	'=';
	}
	pOutData[OutLength]	=	0;
	NSString *pRetVal = [[NSString alloc] initWithBytes:pOutData length:OutLength encoding:NSUTF8StringEncoding];
	free(pOutData);
	return pRetVal;
}
- (NSData *)FromBase64:(NSString *)pBase64String{
	unsigned char	*InData = (unsigned char	*)[pBase64String UTF8String];
	int InLength	=	[pBase64String length];
	unsigned char	*OutData	=	malloc(InLength);
	int OutDataLen=0;
	if(Base64Inverted['B']	!=	1)
	{
		for(int	I=0;I	< 64;I++)
		{
			Base64Inverted[Base64Chars[I]]	=	I;
		}
	}
	for(int	I=0;I	<	(int)InLength;I+=4)
	{
		if(InData[I+3]	!=	'=')
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12)	+
			(Base64Inverted[InData[I+2]]	<<	6)	+
			Base64Inverted[InData[I+3]];
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
			OutData[OutDataLen++]	=	(I32	>>	8)	&	0xff;
			OutData[OutDataLen++]	=	(I32	)	&	0xff;
		}	else	if(InData[I+2]	!=	'=')
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12)	+
			(Base64Inverted[InData[I+2]]	<<	6);
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
			OutData[OutDataLen++]	=	(I32	>>	8)	&	0xff;
		}	else
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12);
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
		}
	}
	NSData *pRetVal = [NSData dataWithBytes:OutData length:OutDataLen];
	free(OutData);
	return pRetVal;
}
- (NSString *)signClearText:(NSString *)base withSecret:(NSData *)secret{
    NSData *data = [base dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_SHA1_DIGEST_LENGTH+1];
    CCHmac(kCCHmacAlgSHA1,secret.bytes,secret.length,data.bytes,data.length,result);
    NSData *hash = [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    return [self ToBase64:hash];
}

#pragma mark - tutorial
- (IBAction)viewTutorial:(id)sender {
    navBar.topItem.title = @"Tutorial";
    tutorialView.hidden = NO;
    CGRect inFrame = [tutorialView frame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    inFrame.origin.x -= 320;
    [tutorialView setFrame:inFrame];
    inFrame = scrollView.frame;
    inFrame.origin.x -= 320;
    [scrollView setFrame:inFrame];
    [UIView commitAnimations];
    stepLabel.text = [stepArray objectAtIndex:0];
    info1.text = [info1Array objectAtIndex:0];
    info2.text = [info2Array objectAtIndex:0];
    tutorialImage.clipsToBounds = YES;
    tutorialImage.image = [backgroundArray objectAtIndex:0];
}
- (IBAction)nextTutorial:(id)sender {
    if(position!=6){
        position++;
        tutorialImage.image = [backgroundArray objectAtIndex:position];
        //stepLabel.text = [stepArray objectAtIndex:position];
        //info1.text = [info1Array objectAtIndex:position];
        //info2.text = [info2Array objectAtIndex:position];
    }
    tutorialPage.currentPage = position;
}
- (IBAction)previousTutorial:(id)sender {
    if(position!=0){
        position--;
        tutorialImage.image = [backgroundArray objectAtIndex:position];
        //stepLabel.text = [stepArray objectAtIndex:position];
        //info1.text = [info1Array objectAtIndex:position];
        //info2.text = [info2Array objectAtIndex:position];
    }
    tutorialPage.currentPage = position;
}

#pragma mark - nooch info and interaction
- (IBAction)viewFAQ:(id)sender {
    NSURL *webURL = [NSURL URLWithString:@"http://support.nooch.com"];
    [[UIApplication sharedApplication] openURL: webURL];
}
- (IBAction)reportBug:(id)sender {
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:[NSString stringWithFormat:@"Bug Report: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"bugs@nooch.com",nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:mailComposer animated:YES];
}
- (IBAction)emailSupport:(id)sender {
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:mailComposer animated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultSent) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Thanks for the Feedback" message:@"Our scientists will study and consider these comments or suggestions to better the app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}
- (IBAction)callSupport:(id)sender {
    if([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPad"])
    {
        NSLog(@"call action process");
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Call Nooch?" message:@"Would you like to call the Nooch scientists? They answer questions, but they're probably at lunch." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK",nil];
        [alertView setTag:3];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"This device doesn't support calling!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)startSupportCall{
    NSString *phoneNumber = [[NSString alloc] initWithFormat:@"tel:8552696662"];
    NSURL *phoneNumberURL = [[NSURL alloc] initWithString:phoneNumber];
    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}
- (IBAction)rateNooch:(id)sender {
}

#pragma mark - alert view delegation
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 3 && buttonIndex == 1){
        [self startSupportCall];
    }else if(alertView.tag == 4 && buttonIndex == 1){
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
        sendingMoney = NO;
        [navCtrl dismissModalViewControllerAnimated:NO];
        [navCtrl performSelector:@selector(disable)];
        [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"tutorial"] animated:YES];
        me = [core new];
    }else if(alertView.tag == 20){
        if(buttonIndex == 0){
            prompt = NO;
        }else{
            [self editPic:self];
        }
    }else if(alertView.tag == 21){
        if(buttonIndex == 1)
            [self saveProfile];
    }
}

#pragma mark - Sign out
- (IBAction)signOut:(id)sender {
    [me stamp];
    [[navCtrl.viewControllers objectAtIndex:0] performSelectorOnMainThread:@selector(hideMenu) withObject:nil waitUntilDone:YES];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"You Sure?" message:@"We're always sad to see you go but we understand if you have to." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Sign Out",nil];
    [alertView setTag:4];
    [alertView show];
}

#pragma mark - connection delegation
-(void) listen:(NSString *)result tagName:(NSString *)tagName{
    [me endWaitStat];
    NSDictionary *loginResult = [result JSONValue];
    if([tagName isEqualToString:@"MySettingsResult"])
    {
        
        NSDictionary *resultValue = [loginResult valueForKey:@"MySettingsResult"];
        NSLog(@"resultValue is : %@", result);
        if([[resultValue valueForKey:@"Result"] isEqualToString:@"Your details have been updated successfully."] && imageData.length != 0){
            [imageData writeToFile:[core path:@"image"] atomically:YES];
            NSString *validated = @"YES";
            [[me usr] setObject:validated forKey:@"validated"];
            validationBadge.highlighted = YES;
        }else{
            NSString *validated = @"YES"; //
            if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Profile Validation Failed! Please provide valid contact informations such as address, city, state and contact number details."]) {
                [[me usr] setObject:validated forKey:@"validated"];
                validationBadge.highlighted = NO;
            }
        }
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:9];
        
        prompt = NO;
        serve *targ = [serve new];
        targ.Delegate = self;
        targ.tagName = @"GetMemberTargusScoresForBank";
        //[targ getTargus];

    }else if([tagName isEqualToString:@"GetMemberTargusScoresForBank"]){
        if(([loginResult objectForKey:@"Address"]==[NSNull null]) || ([loginResult objectForKey:@"EmailId"]==[NSNull null]) || ([loginResult objectForKey:@"ContactNumber"]==[NSNull null]))
        {
            UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Profile Validation Failed!" message:@"Please provide valid contact information such as address, city, state and contact number details in the profile information page." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertRedirectToProfileScreen show];
        }
        else
        {
            NSString *validated = @"YES";
            [[me usr] setObject:validated forKey:@"validated"];
        }
    }else if([tagName isEqualToString:@"resetPasswordDetails"]){
        BOOL isResult = [result boolValue];
        if(isResult == 0)
        {
            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:nil message:@"Your password has been changed successfully" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
            [resetPasswordView setHidden:YES];
            navBar.topItem.title = @"Profile Info";
            [leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
            //[leftNavButton setBackgroundImage:[UIImage imageNamed:@"BackSettings.png"] forState:UIControlStateNormal];
            [leftNavButton setFrame:CGRectMake(0, 0, 43, 43)];
            [leftNavButton removeTarget:self action:@selector(goBack2) forControlEvents:UIControlEventTouchUpInside];
            [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
            [saveButton setHidden:NO];
            [saveButton removeTarget:self action:@selector(finishResetPassword:) forControlEvents:UIControlEventTouchUpInside];
            [saveButton addTarget:self action:@selector(saveProfile) forControlEvents:UIControlEventTouchUpInside];
            password.text = firstNewPass.text;
        }
        else
        {
            UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:nil message:@"Incorrect password. Please check your current password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [showAlertMessage show];
        }
    }else if([tagName isEqualToString:@"getPushnotification"]){
        NSLog(@"push notifications: %@",loginResult);
        receivedPush.highlighted = [[loginResult objectForKey:@"TransferReceived"] boolValue];
        b2nPush.highlighted = [[loginResult objectForKey:@"BankToNooch"] boolValue];
        n2bPush.highlighted = [[loginResult objectForKey:@"NoochToBank"] boolValue];
        failPush.highlighted = [[loginResult objectForKey:@"TransferAttemptFailure"] boolValue];
        joinedPush.highlighted = [[loginResult objectForKey:@"FriendRequest"] boolValue];
        invitePush.highlighted = [[loginResult objectForKey:@"InviteRequestAccept"] boolValue];
        lowPush.highlighted = [[loginResult objectForKey:@"LowBalance"] boolValue];
        validPush.highlighted = [[loginResult objectForKey:@"ValidationRemainder"] boolValue];
        updatePush.highlighted = [[loginResult objectForKey:@"ProductUpdates"] boolValue];
        newsPush.highlighted = [[loginResult objectForKey:@"NewAndUpdate"] boolValue];
    }else if([tagName isEqualToString:@"getEmailnotification"]){
        notificationID=[loginResult objectForKey:@"NotificationId"];
        receivedEmail.highlighted = [[loginResult objectForKey:@"EmailTransferReceived"] boolValue];
        sentEmail.highlighted = [[loginResult objectForKey:@"EmailTransferSent"] boolValue];
        unclaimedEmail.highlighted = [[loginResult objectForKey:@"TransferUnclaimed"] boolValue];

        b2nRequestEmail.highlighted = [[loginResult objectForKey:@"BankToNoochRequested"] boolValue];
        b2nEmail.highlighted = [[loginResult objectForKey:@"BankToNoochCompleted"] boolValue];
        n2bRequestEmail.highlighted = [[loginResult objectForKey:@"NoochToBankRequested"] boolValue];
        n2bEmail.highlighted = [[loginResult objectForKey:@"NoochToBankCompleted"] boolValue];
        failEmail.highlighted = [[loginResult objectForKey:@"EmailTransferAttemptFailure"] boolValue];

        joinedEmail.highlighted = [[loginResult objectForKey:@"EmailFriendRequest"] boolValue];
        inviteEmail.highlighted = [[loginResult objectForKey:@"EmailInviteRequestAccept"] boolValue];

        lowEmail.highlighted = [[loginResult objectForKey:@"LowBalance"] boolValue];
        validEmail.highlighted = [[loginResult objectForKey:@"ValidationRemainder"] boolValue];
        updateEmail.highlighted = [[loginResult objectForKey:@"ProductUpdates"] boolValue];
        newsEmail.highlighted = [[loginResult objectForKey:@"NewAndUpdate"] boolValue];
    }else if([tagName isEqualToString:@"pushNotification"]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your notification settings have been updated successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self goBack];
    }else if([tagName isEqualToString:@"getMemberDetails"]){

    }
}

#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];

}

#pragma mark - unloading
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setUserPic:nil];
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setBalance:nil];
    [self setScrollView:nil];
    [self setProfileScroll:nil];
    [self setName:nil];
    [self setEmail:nil];
    [self setRecoveryEmail:nil];
    [self setAddress:nil];
    [self setCity:nil];
    [self setState:nil];
    [self setZip:nil];
    [self setPassword:nil];
    [self setEditPicButton:nil];
    [self setPinSettingsView:nil];
    [self setReqImmSwitch:nil];
    [self setNotificationsScroll:nil];
    [self setReceivedPush:nil];
    [self setSentEmail:nil];
    [self setUnclaimedEmail:nil];
    [self setReceivedEmail:nil];
    [self setNewsPush:nil];
    [self setNewsEmail:nil];
    [self setUpdatePush:nil];
    [self setUpdateEmail:nil];
    [self setValidPush:nil];
    [self setValidEmail:nil];
    [self setLowEmail:nil];
    [self setLowPush:nil];
    [self setJoinedPush:nil];
    [self setJoinedEmail:nil];
    [self setInvitePush:nil];
    [self setInviteEmail:nil];
    [self setFailPush:nil];
    [self setN2bPush:nil];
    [self setFailEmail:nil];
    [self setN2bEmail:nil];
    [self setN2bRequestEmail:nil];
    [self setB2nPush:nil];
    [self setB2nEmail:nil];
    [self setB2nRequestEmail:nil];
    [self setFbSharingSwitch:nil];
    [self setFbConnectView:nil];
    [self setFbNotConnectedView:nil];
    [self setSwiper1:nil];
    [self setSwiper2:nil];
    [self setStepLabel:nil];
    [self setInfo1:nil];
    [self setInfo2:nil];
    [self setTutorialView:nil];
    [self setTutorialImage:nil];
    [self setSpinner:nil];
    [self setAccountSettingsTable:nil];
    [self setHelpTable:nil];
    [self setAboutTable:nil];
    [self setProfileTable:nil];
    [self setInputAccessory:nil];
    [self setNoochTransfersTable:nil];
    [self setNetworkTable:nil];
    [self setBankNotesTable:nil];
    [self setContactsTable:nil];
    [self setContactPhone:nil];
    [self setLogoutTable:nil];
    [self setResetPasswordTable:nil];
    [self setResetPasswordView:nil];
    [self setOldPassword:nil];
    [self setConfirmNewPassword:nil];
    [self setFirstNewPass:nil];
    [self setLogoutButton:nil];
    [self setAddressLine2:nil];
    [self setTutorialPage:nil];
    [self setValidationBadge:nil];
    profileSettingsButton = nil;
    userBar = nil;
    labelReqImm = nil;
    labelChangePIN = nil;
    navBar = nil;
    leftNavButton = nil;
    saveButton = nil;
    cPinButton = nil;
    accountSettingsTitle = nil;
    [super viewDidUnload];
}
@end
