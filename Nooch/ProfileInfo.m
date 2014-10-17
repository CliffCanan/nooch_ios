//  ProfileInfo.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import "ProfileInfo.h"
#import "Home.h"
#import <QuartzCore/QuartzCore.h>
#import "ResetPassword.h"
#import "Decryption.h"
#import "NSString+AESCrypt.h"
#import "ResetPassword.h"
#import "UIImageView+WebCache.h"
#import "Welcome.h"
#import "Register.h"
#import "ECSlidingViewController.h"
#import "UIImage+Resize.h"
#import "UAPush.h"
UIImageView *picture;
@interface ProfileInfo ()
@property(nonatomic) UIImagePickerController *picker;
@property(nonatomic,strong) UITextField *name;
@property(nonatomic,strong) UITextField *email;
@property(nonatomic,strong) UITextField *recovery_email;
@property(nonatomic,strong) UITextField *phone;
@property(nonatomic,strong) UITextField *address_one;
@property(nonatomic,strong) UITextField *address_two;
@property(nonatomic,strong) UITextField *city;
@property(nonatomic,strong) UITextField *zip;
@property(nonatomic,strong) UITableView *list;
@property(nonatomic,strong) UILabel *glyph_arrow_email;
@property(nonatomic,strong) UILabel *glyph_arrow_phone;
@property(nonatomic,strong) UIButton *save;
@property(nonatomic,strong) NSString *ServiceType;
@property(nonatomic, retain) NSString * SavePhoneNumber;
@property(nonatomic) BOOL disclose;
@property(nonatomic) NSIndexPath *expand_path;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIView *member_since_back;
@end
@implementation ProfileInfo

@synthesize SavePhoneNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    self.screenName = @"Profile Screen";

    [self.navigationItem setTitle:@"Profile Info"];

    if ([[user objectForKey:@"Photo"] length] > 0 && [user objectForKey:@"Photo"] != nil && !isPhotoUpdate)
    {
        [picture sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
    }
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"])
    {
        [self.member_since_back setStyleId:@"profileTopSectionBg_susp"];
    }
    [UAPush shared].userPushNotificationsEnabled = YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)showMenu
{
    [self savePrompt];
}

-(void)GoBackOnce
{
    if (isSignup) {
        [self.navigationController setNavigationBarHidden:NO];
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                         }];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
        isSignup=NO;
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)SaveAlert1
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Save Changes" message:@"Do you want to save the changes in your profile?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [alert setTag:5021];
    [alert show];
    
    return;
}

-(void)savePrompt2
{
    if ([self.recovery_email.text length] == 0)
    {
        if ( [[dictSavedInfo valueForKey:@"ImageChanged"]isEqualToString:@"YES"] ||
             (self.address_one.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address1"]isEqualToString:self.address_one.text]) ||
             (self.address_two.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address2"]isEqualToString:self.address_two.text]) ||
             (self.zip.text.length > 2 && ![[dictSavedInfo valueForKey:@"zip"]isEqualToString:self.zip.text]) ||
             (self.city.text.length > 2 && ![[dictSavedInfo valueForKey:@"City"]isEqualToString:self.city.text]) ||
             (self.phone.text.length > 3 && ![[dictSavedInfo valueForKey:@"phoneno"]isEqualToString:self.phone.text]) )
        {
            [self SaveAlert1];
        }
        else
        {
            [self.navigationItem setLeftBarButtonItem:nil];
            [self performSelector:@selector(GoBackOnce) withObject:nil];
        }
    }
    else
    {
        if ( [[dictSavedInfo valueForKey:@"ImageChanged"]isEqualToString:@"YES"] ||
             (self.address_one.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address1"]isEqualToString:self.address_one.text]) ||
             (self.address_two.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address2"]isEqualToString:self.address_two.text]) ||
             (self.zip.text.length > 2 && ![[dictSavedInfo valueForKey:@"zip"]isEqualToString:self.zip.text]) ||
             (self.city.text.length > 2 && ![[dictSavedInfo valueForKey:@"City"]isEqualToString:self.city.text]) ||
             (self.phone.text.length > 3 && ![[dictSavedInfo valueForKey:@"phoneno"]isEqualToString:self.phone.text]) ||
             (self.recovery_email.text.length > 3 && ![[dictSavedInfo valueForKey:@"recovery_email"]isEqualToString:self.recovery_email.text]) )
        {
            [self SaveAlert1];
        }
        else
        {
            [self.navigationItem setLeftBarButtonItem:nil];
            [self performSelector:@selector(GoBackOnce) withObject:nil];
        }
    }
}

-(void)savePrompt
{
    if ([self.recovery_email.text length] == 0)
    {
        if ( [[dictSavedInfo valueForKey:@"ImageChanged"]isEqualToString:@"YES"] ||
             (self.address_one.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address1"]isEqualToString:self.address_one.text]) ||
             (self.address_two.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address2"]isEqualToString:self.address_two.text]) ||
             (self.zip.text.length > 2 && ![[dictSavedInfo valueForKey:@"zip"]isEqualToString:self.zip.text]) ||
             (self.city.text.length > 2 && ![[dictSavedInfo valueForKey:@"City"]isEqualToString:self.city.text]) ||
             (self.phone.text.length > 3 && ![[dictSavedInfo valueForKey:@"phoneno"]isEqualToString:self.phone.text]) )
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Nooch" message:@"Do you want to save the changes in your profile?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
            [alert setTag:5020];
            [alert show];

            return;
        }
        else
        {
            [self.slidingViewController anchorTopViewTo:ECRight];
        }
    }
    else
    {
        if ( [[dictSavedInfo valueForKey:@"ImageChanged"]isEqualToString:@"YES"] ||
             (self.address_one.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address1"]isEqualToString:self.address_one.text]) ||
             (self.address_two.text.length > 3 && ![[dictSavedInfo valueForKey:@"Address2"]isEqualToString:self.address_two.text]) ||
             (self.zip.text.length > 2 && ![[dictSavedInfo valueForKey:@"zip"]isEqualToString:self.zip.text]) ||
             (self.city.text.length > 2 && ![[dictSavedInfo valueForKey:@"City"]isEqualToString:self.city.text]) ||
             (self.phone.text.length > 3 && ![[dictSavedInfo valueForKey:@"phoneno"]isEqualToString:self.phone.text]) ||
             (self.recovery_email.text.length > 3 && ![[dictSavedInfo valueForKey:@"recovery_email"]isEqualToString:self.recovery_email.text]) )
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Nooch" message:@"Do you want to save the changes in your profile?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
            [alert setTag:5020];
            [alert show];

            return;
        }
        else
        {
            [self.slidingViewController anchorTopViewTo:ECRight];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag == 5020 || alertView.tag == 5021) && buttonIndex == 0) {
        [self save_changes];
    }
    else if (alertView.tag == 5020 && buttonIndex == 1){
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
    else if (alertView.tag == 5021 && buttonIndex == 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 1001 && buttonIndex == 0) {
        [self.name setUserInteractionEnabled:YES];
        [self.name becomeFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dictSavedInfo = [[NSMutableDictionary alloc]init];
    [dictSavedInfo setObject:@"NO" forKey:@"ImageChanged"];
    self.navigationController.navigationBar.topItem.title = @"";
    self.disclose = NO;
    [self.navigationItem setHidesBackButton:YES];
    
    if (isProfileOpenFromSideBar)
    {
        UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [hamburger setStyleId:@"navbar_hamburger"];
        [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
        [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
        [self.navigationItem setLeftBarButtonItem:menu];
    }
    else
    {
        UIButton * back_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [back_button setStyleId:@"navbar_back"];
        [back_button addTarget:self action:@selector(savePrompt2) forControlEvents:UIControlEventTouchUpInside];
        [back_button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] forState:UIControlStateNormal];
        [back_button setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.16) forState:UIControlStateNormal];
        back_button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

        UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
        [self.navigationItem setLeftBarButtonItem:menu];
    }

    if (!isSignup) {
        [self.slidingViewController.panGesture setEnabled:YES];
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    isPhotoUpdate = NO;

    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Loading your profile...";
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    [self.hud show:YES];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .26);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    
    NSDictionary * titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSShadowAttributeName: shadowNavText};
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    [self.navigationItem setTitle:@"Profile Info"];
    
    serve *serveOBJ = [serve new ];
    serveOBJ.tagName = @"myset";
    [serveOBJ setDelegate:self];
    [serveOBJ getSettings];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.member_since_back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    [self.member_since_back setFrame:CGRectMake(0, 0, 320, 70)];
    [self.member_since_back setStyleId:@"profileTopSectionBg"];
    [self.view addSubview:self.member_since_back];

    UIView * shadowUnder = [[UIView alloc] initWithFrame:CGRectMake(20, 5, 60, 61)];
    shadowUnder.backgroundColor = Rgb2UIColor(63, 171, 225, .4);
    shadowUnder.layer.cornerRadius = 30;
    shadowUnder.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowUnder.layer.shadowOffset = CGSizeMake(0, 2.5);
    shadowUnder.layer.shadowOpacity = 0.4;
    shadowUnder.layer.shadowRadius = 3.5;
    [shadowUnder setStyleClass:@"animate_bubble"];
    [self.view addSubview:shadowUnder];

    picture = [UIImageView new];
    [picture setFrame:CGRectMake(20, 5, 60, 60)];
    picture.layer.cornerRadius = 30;
    picture.layer.borderColor = [UIColor whiteColor].CGColor;
    picture.layer.borderWidth = 2;
    picture.clipsToBounds = YES;
    [picture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change_pic)]];
    [picture setUserInteractionEnabled:YES];
    [self.view addSubview:picture];
    [picture setStyleClass:@"animate_bubble"];
    
    NSShadow * shadow_edit = [[NSShadow alloc] init];
    shadow_edit.shadowColor = Rgb2UIColor(33, 34, 35, .35);
    shadow_edit.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow_edit };

    UILabel *edit_label = [UILabel new];
    [edit_label setBackgroundColor:[UIColor clearColor]];
    edit_label.attributedText = [[NSAttributedString alloc] initWithString:@"edit"
                                                                 attributes:textAttributes];
    [edit_label setFont:[UIFont fontWithName:@"Roboto-regular" size:11]];
    [edit_label setFrame:CGRectMake(8, 42, 44, 12)];
    [edit_label setTextAlignment:NSTextAlignmentCenter];
    [edit_label setTextColor:[UIColor whiteColor]];
    [picture addSubview:edit_label];

    start = [[user valueForKey:@"DateCreated"] rangeOfString:@"("];
    end = [[user valueForKey:@"DateCreated"] rangeOfString:@")"];

    if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location)
    {
        betweenBraces = [[user valueForKey:@"DateCreated"] substringWithRange:NSMakeRange(start.location+1, end.location-(start.location+1))];
    }

    newString = [betweenBraces substringToIndex:[betweenBraces length]-8];

    NSTimeInterval _interval = [newString doubleValue];

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"M/d/yyyy"];
    NSString *_date=[_formatter stringFromDate:date];
    
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(229, 242, 248, .3);
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    NSDictionary * textAttributes_memberSince = @{NSShadowAttributeName: shadow };

    memSincelbl = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 200, 30)];
    memSincelbl.attributedText = [[NSAttributedString alloc] initWithString:@"Member Since"
                                                                 attributes:textAttributes_memberSince];
    memSincelbl.userInteractionEnabled = NO;
    memSincelbl.selectable = NO;
    [memSincelbl setBackgroundColor:[UIColor clearColor]];
    [memSincelbl setStyleClass:@"memtable_view_cell_textlabel_1"];
    [self.view addSubview:memSincelbl];
    
    dateText = [[UITextView alloc] initWithFrame:CGRectMake(20, 34, 200, 24)];
    dateText.userInteractionEnabled = NO;
    dateText.selectable = NO;
    [dateText setBackgroundColor:[UIColor clearColor]];
    [dateText setText:[NSString stringWithFormat:@"%@",_date]];
    [dateText setStyleId:@"profile_DateText"];
    [self.view addSubview:dateText];
    
    NSLog(@"%@",transactionInput);

    self.name = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.name setTextAlignment:NSTextAlignmentRight];
    [self.name setPlaceholder:@"First & Last Name"];
    [self.name setDelegate:self];
    [self.name setStyleClass:@"table_view_cell_detailtext_1"];
    [self.name setText:[NSString stringWithFormat:@"%@ %@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"] capitalizedString],[[[NSUserDefaults standardUserDefaults] objectForKey:@"LastName"] capitalizedString]]];
    [self.name setUserInteractionEnabled:NO];
    [self.name setTag:0];
    [self.view addSubview:self.name];

    self.email = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.email setTextAlignment:NSTextAlignmentRight];
    [self.email setPlaceholder:@"email@email.com"];
    [self.email setDelegate:self];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    self.email.returnKeyType = UIReturnKeyNext;
    [self.email setStyleClass:@"table_view_cell_detailtext_1"];
    [self.name setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]];
    [self.email setUserInteractionEnabled:NO];
    [self.email setTag:0];
    [self.view addSubview:self.email];

    //Recovery Mail
    self.recovery_email = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.recovery_email setTextAlignment:NSTextAlignmentRight];
    [self.recovery_email setBackgroundColor:[UIColor clearColor]];
    [self.recovery_email setPlaceholder:@"(Optional)"];
    [self.recovery_email setDelegate:self];
    [self.recovery_email setKeyboardType:UIKeyboardTypeEmailAddress];
    self.recovery_email.returnKeyType = UIReturnKeyNext;
    [self.recovery_email setStyleClass:@"table_view_cell_detailtext_1"];
    [self.recovery_email setTag:1];
    [self.view addSubview:self.recovery_email];

    self.phone = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.phone setTextAlignment:NSTextAlignmentRight];
    [self.phone setBackgroundColor:[UIColor clearColor]];
    [self.phone setPlaceholder:@"(215) 555-1234"];
    [self.phone setDelegate:self];
    [self.phone setKeyboardType:UIKeyboardTypeNumberPad];
    self.phone.returnKeyType = UIReturnKeyNext;
    [self.phone setStyleClass:@"table_view_cell_detailtext_1"];
    [self.phone setTag:2];
    [self.view addSubview:self.phone];

    // Address
    self.address_one = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.address_one setTextAlignment:NSTextAlignmentRight];
    [self.address_one setBackgroundColor:[UIColor clearColor]];
    [self.address_one setPlaceholder:@"123 Nooch St"];
    [self.address_one setDelegate:self];
    [self.address_one setKeyboardType:UIKeyboardTypeDefault];
    self.address_one.returnKeyType = UIReturnKeyNext;
    [self.address_one setStyleClass:@"table_view_cell_detailtext_1"];
    [self.address_one setTag:3];
    [self.view addSubview:self.address_one];

    self.address_two = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.address_two setTextAlignment:NSTextAlignmentRight];
    [self.address_two setBackgroundColor:[UIColor clearColor]];
    [self.address_two setPlaceholder:@"(Optional)"];
    [self.address_two setDelegate:self];
    [self.address_two setKeyboardType:UIKeyboardTypeDefault];
    self.address_two.returnKeyType = UIReturnKeyNext;
    [self.address_two setStyleClass:@"table_view_cell_detailtext_1"];
    [self.address_two setTag:4];
    [self.view addSubview:self.address_two];

    // City
    self.city = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.city setTextAlignment:NSTextAlignmentRight];
    [self.city setBackgroundColor:[UIColor clearColor]];
    [self.city setPlaceholder:@"City"];
    [self.city setDelegate:self];
    [self.city setTag:5];
    [self.city setKeyboardType:UIKeyboardTypeDefault];
    self.city.returnKeyType = UIReturnKeyNext;
    [self.city setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.view addSubview:self.city];

    // ZIP
    self.zip = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.zip setTextAlignment:NSTextAlignmentRight];
    [self.zip setBackgroundColor:[UIColor clearColor]];
    [self.zip setPlaceholder:@"12345"];
    [self.zip setDelegate:self];
    [self.zip setKeyboardType:UIKeyboardTypeNumberPad];
    [self.zip setStyleClass:@"table_view_cell_detailtext_1"];
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        [self.zip setTag:6];
    }
    else {
        [self.zip setTag:5];
    }
    [self.view addSubview:self.zip];

    self.save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.save setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    self.save.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.save addTarget:self action:@selector(save_changes) forControlEvents:UIControlEventTouchUpInside];
    [self.save setTitle:@"Save" forState:UIControlStateNormal];
    [self.save setStyleClass:@"nav_top_right"];
    [self.save setStyleClass:@"disabled_gray"];
    [self.save setEnabled:NO];
    [self.save setUserInteractionEnabled:NO];
    //[self.view addSubview:self.save];
    UIBarButtonItem *nav_save = [[UIBarButtonItem alloc] initWithCustomView:self.save];
    [self.navigationItem setRightBarButtonItem:nav_save animated:YES];
    
    self.name.text=@"";
    self.email.text=@"";
    self.recovery_email.text=@"";
    self.phone.text=@"";
    self.address_one.text=@"";
    self.address_two.text=@"";
    self.city.text=@"";
    self.zip.text=@"";

    GMTTimezonesDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Samoa Standard Time",@"GMT-11:00",
                              @"Hawaiian Standard Time",@"GMT-10:00",
                              @"Alaskan Standard Time",@"GMT-09:00",
                              @"Pacific Standard Time",@"GMT-08:00",
                              @"Mountain Standard Time",@"GMT-07:00",
                              @"Central Standard Time",@"GMT-06:00",
                              @"Eastern Standard Time",@"GMT-05:00",
                              @"Atlantic Standard Time",@"GMT-04:00",
                              nil];
    rowHeight = 51;
    self.list = [UITableView new];
    [self.list setFrame:CGRectMake(0, 70, 320, (rowHeight * 8) + 10)];
    [self.list setDelegate:self];
    [self.list setDataSource:self];
    [self.list setRowHeight:rowHeight];
    [self.list setScrollEnabled:YES];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        rowHeight = 45;
    }
    [self.view addSubview:self.list];
}

-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.name resignFirstResponder];
    [self.email resignFirstResponder];
    [self.recovery_email resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.address_one resignFirstResponder];
    [self.address_two resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zip resignFirstResponder];
}

-(void)resend_email
{
    serve *email_verify = [serve new];
    [email_verify setDelegate:self];
    [email_verify setTagName:@"email_verify"];
    [email_verify resendEmail];
}

-(void)resend_SMS
{
    serve *sms_verify = [serve new];
    [sms_verify setDelegate:self];
    [sms_verify setTagName:@"sms_verify"];
    [sms_verify resendSMS];
}

-(BOOL)validateEmail:(NSString*)emailStr;
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,3}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailCheck];
    return [emailTest evaluateWithObject:emailStr];
}

- (void) save_changes
{
    [self.name resignFirstResponder];
    [self.email resignFirstResponder];
    [self.recovery_email resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.address_one resignFirstResponder];
    [self.address_two resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zip resignFirstResponder ];

    [UIView beginAnimations:@"bucketsOff" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:CGRectMake(0,64, 320, 600)];
    [UIView commitAnimations];
    
    if ([self.name.text length] == 0)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Need A Name" message:@"We can call you 'Blank' if you want, but it's probably better if you entered a name..." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [av show];
        return;
    }
    
    if (![self validateEmail:[self.email text]])
    {
        self.email.text = @"";
        [self.email becomeFirstResponder];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Invalid Email Address" message:@"Hmm... please double check that you have entered a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    if ([self.address_one.text length] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Missing An Address" message:@"Please enter your address to validate your profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.address_one becomeFirstResponder];
        return;
    }

    if ([self.city.text length] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"How Bout A City" message:@"It would be fantastic if you entered a city! ;-)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.city becomeFirstResponder];
        return;
    }
    
    if ([[me pic] isKindOfClass:[NSNull class]]) {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"I don't see you!" message:@"You haven't set your profile picture, would you like to?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Yes I do", nil];
        [av setTag:20];
        [av show];
    }

    [self.save setEnabled:NO];
    [self.save setUserInteractionEnabled:NO];
    [self.save setStyleClass:@"disabled_gray"];
    
    strPhoneNumber = self.phone.text;
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    strPhoneNumber = [strPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![self.SavePhoneNumber isEqualToString:strPhoneNumber] || [self.SavePhoneNumber length] == 0)
    {
        if ([strPhoneNumber length] != 10)
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Phone Number Trouble" message:@"Please double check that you entered a valid 10-digit phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }

    if ([self.recovery_email.text length] == 0) {
        self.recovery_email.text = @"";
    }

    timezoneStandard = [NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone]];
    timezoneStandard = [[timezoneStandard componentsSeparatedByString:@", "] objectAtIndex:0];
    timezoneStandard = [GMTTimezonesDictionary objectForKey:timezoneStandard];
    timezoneStandard = @"";

    recoverMail = [[NSString alloc] init];
    
    if ([self.recovery_email.text length] > 0) {
        recoverMail = self.recovery_email.text;
    }
    else
        recoverMail = @"";
    
    if ([self.address_two.text length] != 0) {
        [[me usr] setObject:self.address_two.text forKey:@"Addr2"];
        [[me usr] setObject:self.address_two.text forKey:@"Addr1"];
    }
    else {
        [[me usr] removeObjectForKey:@"Addr2"];
    }
    self.name.text = [self.name.text lowercaseString];
    
    NSArray *arrdivide = [self.name.text componentsSeparatedByString:@" "];
    
    if ([arrdivide count] == 2)
    {
        transactionInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[arrdivide objectAtIndex:0],@"FirstName",[arrdivide objectAtIndex:1],@"LastName",self.email.text,@"UserName",nil];
    }
    else
    {
        transactionInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",self.name.text,@"FirstName",@" ",@"LastName",self.email.text,@"UserName",nil];
    }

    [transactionInput setObject:[NSString stringWithFormat:@"%@/%@",self.address_one.text,self.address_two.text] forKey:@"Address"];
    [transactionInput setObject:self.city.text forKey:@"City"];
    
    
    if ( [[assist shared]islocationAllowed]) {
        [transactionInput setObject:[[assist shared]islocationAllowed]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"ShowInSearch"];
    }
    else
        [transactionInput setObject:[[assist shared]islocationAllowed]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"ShowInSearch"];
    [transactionInput setObject:strPhoneNumber forKey:@"ContactNumber"];
    [transactionInput setObject:self.zip.text forKey:@"Zipcode"];
    [transactionInput setObject:@"false" forKey:@"UseFacebookPicture"];
    [transactionInput setObject:@".png" forKey:@"fileExtension"];
    [transactionInput setObject:recoverMail forKey:@"RecoveryMail"];
    [transactionInput setObject:timezoneStandard forKey:@"TimeZoneKey"];
    
    if ([[assist shared] getTranferImage]) {
        NSData *data;
       
       data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
        NSUInteger len = data.length;
        uint8_t *bytes = (uint8_t *)[data bytes];
        NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];
        for (NSUInteger i = 0; i < len; i++) {
            if (i) {
                [result1 appendString:@","];
            }
            [result1 appendFormat:@"%d", bytes[i]];
        }
        NSArray * arr = [result1 componentsSeparatedByString:@","];
        [transactionInput setObject:arr forKey:@"Picture"];
    }

    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.delegate = self;
    self.hud.labelText = @"Saving Your Profile";
    [self.hud show:YES];
    
    transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"mySettings", nil];
    serve * req = [serve new];
    req.Delegate = self;
    req.tagName = @"MySettingsResult";
    [req setSets:transaction];
    
    NSArray * arr = [self.name.text componentsSeparatedByString:@" "];
    if ([arr count] == 2) {
        self.name.text = [NSString stringWithFormat:@"%@ %@",[[arr objectAtIndex:0] capitalizedString],[[arr objectAtIndex:1] capitalizedString]];
    }
}

- (void)change_pic
{
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Facebook Picture", @"Use Camera", @"From iPhone Library", nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (![user objectForKey:@"facebook_id"]) {
            return;
        }

        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",[user objectForKey:@"facebook_id"]];
   
        [picture sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"RoundLoading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [picture setImage:image];
                [[assist shared]setTranferImage:nil];
                [[assist shared]setTranferImage:image];
            }

        }];
        
//        [picture sd_setImageWithURL:[NSURL URLWithString:url]
//             placeholderImage:[UIImage imageNamed:@"profile_picture"]
//                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                        
//                        if (image) {
//                            [picture setImage:image];
//                            [[assist shared]setTranferImage:nil];
//                            [[assist shared]setTranferImage:image];
//                        }
//        }];
    
        [self.save setEnabled:YES];
        [self.save setUserInteractionEnabled:YES];
        [self.save setStyleClass:@"nav_top_right"];
        [self.save setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
        self.save.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        
        [dictSavedInfo setObject:@"YES" forKey:@"ImageChanged"];
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
      
    }
    else if (buttonIndex == 1)
    {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            [myAlertView show];
            return;
        }
        
        self.picker = [UIImagePickerController new];
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.picker animated:YES completion:Nil];
    }
    else if (buttonIndex == 2)
    {
        self.picker = [UIImagePickerController new];
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.picker animated:YES completion:Nil];
    }
}

-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;

    if (imgRatio != maxRatio)
    {
        
        if (imgRatio < maxRatio)
        {
            imgRatio = 115.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 115.0;
        }
        else
        {
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

#pragma mark-ImagePicker

- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    option = 1;
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(120,120) interpolationQuality:kCGInterpolationMedium];
    [picture setImage:image];
    [[assist shared]setTranferImage:image];

    isPhotoUpdate = YES;

    [self.save setEnabled:YES];
    [self.save setUserInteractionEnabled:YES];
    [self.save setStyleClass:@"nav_top_right"];
    [dictSavedInfo setObject:@"YES" forKey:@"ImageChanged"];

    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        cell.clipsToBounds = YES;
    }

    NSShadow * shadow_white = [[NSShadow alloc] init];
    shadow_white.shadowColor = Rgb2UIColor(255, 252, 252, .4);
    shadow_white.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes_white = @{NSShadowAttributeName: shadow_white };
    
    if (indexPath.row == 0)
    {
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setText:@"Name"];
        [name setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:name];
        [cell.contentView addSubview:self.name];
        [cell setUserInteractionEnabled:NO];
    }
    else if (indexPath.row == 1)
    {
        UILabel * mail = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
        [mail setBackgroundColor:[UIColor clearColor]];
        [mail setStyleClass:@"table_view_cell_textlabel_1"];
        mail.attributedText = [[NSAttributedString alloc] initWithString:@"Email"
                                                              attributes:textAttributes_white];
        
        if ([[user valueForKey:@"Status"] isEqualToString:@"Registered"])
        {
            UIView * email_not_validated = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
            [email_not_validated setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];
            [cell.contentView addSubview:email_not_validated];
            
            [mail setStyleClass:@"table_txtlbl_indented"];

            UILabel * glyph_excl = [UILabel new];
            [glyph_excl setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
            [glyph_excl setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
            [glyph_excl setStyleClass:@"animate_bubble_slow"];
            [glyph_excl setFrame:CGRectMake(12, 6, 20, 38)];
            [glyph_excl setTextColor:kNoochRed];
            [cell.contentView addSubview:glyph_excl];
            
            self.glyph_arrow_email = [UILabel new];
            [self.glyph_arrow_email setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
            [self.glyph_arrow_email setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-caret-down"]];
            [self.glyph_arrow_email setFrame:CGRectMake(82, 6, 20, 38)];
            [self.glyph_arrow_email setTextColor:kNoochGrayDark];
            [cell.contentView addSubview:self.glyph_arrow_email];
        
            UILabel * emailVerifiedStatus = [[UILabel alloc] initWithFrame:CGRectMake(32, 50, 130, 30)];
            [emailVerifiedStatus setBackgroundColor:[UIColor clearColor]];
            [emailVerifiedStatus setStyleClass:@"notVerifiedLabel"];
            [cell.contentView addSubview:emailVerifiedStatus];

            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowColor = Rgb2UIColor(255, 252, 249, .25);
            shadow.shadowOffset = CGSizeMake(0, 1);
            NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
            emailVerifiedStatus.attributedText = [[NSAttributedString alloc] initWithString:@"Not Verified"
                                                                       attributes:textAttributes];

            UIButton * resend_mail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [resend_mail setFrame:CGRectMake(200, 50, 105, 30)];
            [resend_mail setStyleClass:@"button_green_sm"];
            [resend_mail addTarget:self action:@selector(resend_email) forControlEvents:UIControlEventTouchUpInside];
            [resend_mail setTitle:@"Resend Email" forState:UIControlStateNormal];
            [resend_mail setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.22) forState:UIControlStateNormal];
            resend_mail.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
            [cell.contentView addSubview:resend_mail];
        }

        [cell.contentView addSubview:mail];
        [cell.contentView addSubview:self.email];
    }
    else if (indexPath.row == 2)
    {
        UILabel * recover = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
        [recover setBackgroundColor:[UIColor clearColor]];
        [recover setText:@"Recovery Email"];

        [recover setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:recover];
        [cell.contentView addSubview:self.recovery_email];
    }
    else if (indexPath.row == 3)
    {
        UILabel * num = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
        [num setBackgroundColor:[UIColor clearColor]];
        [num setStyleClass:@"table_view_cell_textlabel_1"];
        num.attributedText = [[NSAttributedString alloc] initWithString:@"Phone"
                                                             attributes:textAttributes_white];
        
        // NSLog(@"PhoneNo value is: %@",[dictSavedInfo valueForKey:@"phoneno"]);
        
        if (![[user objectForKey:@"IsVerifiedPhone"] isEqualToString:@"YES"])
        {
            UIView * unverified_phone = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,88)];
            [unverified_phone setBackgroundColor:Rgb2UIColor(250, 228, 3, .25)];
            [cell.contentView addSubview:unverified_phone];
            
            [num setStyleClass:@"table_txtlbl_indented"];

            UILabel * glyph_excl = [UILabel new];
            [glyph_excl setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
            [glyph_excl setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-circle"]];
            [glyph_excl setStyleClass:@"animate_bubble_slow"];
            [glyph_excl setFrame:CGRectMake(12, 6, 20, 38)];
            [glyph_excl setTextColor:kNoochRed];
            [cell.contentView addSubview:glyph_excl];
            
            if ([[dictSavedInfo valueForKey:@"phoneno"]length] > 0)
            {
                self.glyph_arrow_phone = [UILabel new];
                [self.glyph_arrow_phone setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
                [self.glyph_arrow_phone setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-caret-down"]];
                [self.glyph_arrow_phone setFrame:CGRectMake(89, 6, 20, 38)];
                [self.glyph_arrow_phone setTextColor:kNoochGrayDark];
                [cell.contentView addSubview:self.glyph_arrow_phone];
            }

            UILabel * phoneVerifiedStatus = [[UILabel alloc] initWithFrame:CGRectMake(32, 50, 130, 30)];
            [phoneVerifiedStatus setBackgroundColor:[UIColor clearColor]];
            [phoneVerifiedStatus setStyleClass:@"notVerifiedLabel"];
            [cell.contentView addSubview:phoneVerifiedStatus];
            
            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowColor = Rgb2UIColor(255, 252, 249, .3);
            shadow.shadowOffset = CGSizeMake(0, 1);
            NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
            phoneVerifiedStatus.attributedText = [[NSAttributedString alloc] initWithString:@"Not Verified"
                                                                                 attributes:textAttributes];
            
            UIButton *resend_phone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [resend_phone setTitle:@"Resend SMS" forState:UIControlStateNormal];
            [resend_phone addTarget:self action:@selector(resend_SMS) forControlEvents:UIControlEventTouchUpInside];
            [resend_phone setFrame:CGRectMake(200, 50, 105, 30)];
            [resend_phone setStyleClass:@"button_green_sm"];
            [resend_phone setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.25) forState:UIControlStateNormal];
            resend_phone.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
            [cell.contentView addSubview:resend_phone];
            
        }
        
        [cell.contentView addSubview:num];
        [cell.contentView addSubview:self.phone];
    }
    else if (indexPath.row == 4)
    {
        UILabel * addr1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
        [addr1 setBackgroundColor:[UIColor clearColor]];
        [addr1 setText:@"Address"];
        [addr1 setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:addr1];
        [cell.contentView addSubview:self.address_one];
    }
    else if (indexPath.row == 5)
    {
        UILabel * addr2 = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
        [addr2 setBackgroundColor:[UIColor clearColor]];
        [addr2 setText:@"Address 2"];
        [addr2 setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:addr2];
        [cell.contentView addSubview:self.address_two];
    }
    else if (indexPath.row == 6)
    {
        UILabel * city_lbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, rowHeight)];
        [city_lbl setBackgroundColor:[UIColor clearColor]];
        [city_lbl setText:@"City"];
        [city_lbl setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:city_lbl];
        [cell.contentView addSubview:self.city];
    }
    else if (indexPath.row == 7)
    {
        UILabel * zip_lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 140, rowHeight)];
        [zip_lbl setBackgroundColor:[UIColor clearColor]];
        [zip_lbl setText:@"ZIP"];
        [zip_lbl setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:zip_lbl];
        [cell.contentView addSubview:self.zip];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.name resignFirstResponder];
    [self.email resignFirstResponder];
    [self.recovery_email resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.address_one resignFirstResponder];
    [self.address_two resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zip resignFirstResponder];

    if (indexPath.row == 1 && [[user valueForKey:@"Status"]isEqualToString:@"Registered"])
    {
        if (self.disclose == YES) {
            self.disclose = NO;
        }
        else if (self.disclose == NO) {
            self.disclose = YES;
            self.expand_path = indexPath;
        }
        [self.list beginUpdates];
        [self.list endUpdates];
    } 
    else if (indexPath.row == 3 && ![[user objectForKey:@"IsVerifiedPhone"] isEqualToString:@"YES"] && [[dictSavedInfo valueForKey:@"phoneno"]length] > 0)
    {
        if (self.disclose == YES) {
            self.disclose = NO;
        }
        else if (self.disclose == NO) {
            self.disclose = YES;
            self.expand_path = indexPath;
        }
        [self.list beginUpdates];
        [self.list endUpdates];
        [self.phone setUserInteractionEnabled:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.expand_path.row && self.disclose) {
        return 88;
    }
    return rowHeight;
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.save setEnabled:YES];
    [self.save setUserInteractionEnabled:YES];
    [self.save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (textField == self.phone)
    {
        if ([self.phone.text length] == 9 &&
            [self.phone.text rangeOfString:@"-"].location == NSNotFound &&
            [self.phone.text rangeOfString:@"("].location == NSNotFound)
        {
            self.phone.text = [NSString stringWithFormat:@"(%@) %@-%@",
                               [self.phone.text substringWithRange:NSMakeRange(0, 3)],
                               [self.phone.text substringWithRange:NSMakeRange(3, 3)],
                               [self.phone.text substringWithRange:NSMakeRange(6, 3)]];
        }
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _email)
    {
        [_recovery_email becomeFirstResponder];
    }
    else if (textField == _recovery_email)
    {
        [_phone becomeFirstResponder];
    }
    else if (textField == _phone)
    {
        [_address_one becomeFirstResponder];
    }
    else if (textField == _address_one)
    {
        [_address_two becomeFirstResponder];
    }
    else if (textField == _address_two)
    {
        [_city becomeFirstResponder];
    }
    else if (textField == _city )
    {
        [_zip becomeFirstResponder];
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)Error:(NSError *)Error{
    [self.hud hide:YES];
   
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    NSError* error;
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [timer invalidate];
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        NSMutableArray*arrNav=[nav_ctrl.viewControllers mutableCopy];
        for (int i=[arrNav count]; i>1; i--) {
            [arrNav removeLastObject];
        }

        [nav_ctrl setViewControllers:arrNav animated:NO];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    
    if ([tagName isEqualToString:@"email_verify"])
    {
        NSString *response = [[NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error] objectForKey:@"Result"];
        if ([response isEqualToString:@"Already Activated."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"Your email has already been verified." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            self.disclose = NO;
            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Not a nooch member."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"An error occurred when attempting to fulfill this request, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Success"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"A verifiction link has been sent to your email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            self.disclose = NO;
            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Failure"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"An error occurred when attempting to fulfill this request, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    else if ([tagName isEqualToString:@"sms_verify"])
    {
        NSString *response = [[NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error] objectForKey:@"Result"];
        
        if ([response isEqualToString:@"Already Verified."]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"Your phone number has already been verified." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            self.disclose = NO;
            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Not a nooch member."]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"An error occurred when attempting to fulfill this request, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Success"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Check Your Texts" message:@"A verifiction SMS has been sent to your phone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            self.disclose = YES;
            [self.list beginUpdates];
            [self.list endUpdates];
        }
        else if ([response isEqualToString:@"Failure"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"An error occurred when attempting to fulfill this request, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Temporarily_Blocked"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Account Is Suspended" message:@"Your account is currently suspended, please attempt to verify your phone number when you are no longer suspended." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Suspended"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Account Is Suspended" message:@"Your account is currently suspended, please attempt to verify your phone number when you are no longer suspended." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    else if ([tagName isEqualToString:@"MySettingsResult"])
    {
        dictProfileinfo = [NSJSONSerialization
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];
        [dictSavedInfo setObject:@"NO" forKey:@"ImageChanged"];
        NSDictionary *resultValue = [dictProfileinfo valueForKey:@"MySettingsResult"];
        getEncryptionOldPassword = [dictProfileinfo objectForKey:@"Password"];
        NSLog(@"My Settings Result:  %@",[resultValue valueForKey:@"Result"]);
        [[assist shared]setTranferImage:nil];

        if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Your details have been updated successfully."])
        {
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:@"ProfileComplete"];
            [defaults synchronize];
            [self.save setEnabled:NO];
            [self.save setUserInteractionEnabled:NO];
            [self.save setStyleClass:@"disabled_gray"];
            
            serve * serveOBJ = [serve new];
            serveOBJ.tagName = @"myset";
            [serveOBJ setDelegate:self];
            [serveOBJ getSettings];
            
            if ([[user objectForKey:@"Photo"] length] > 0 && [user objectForKey:@"Photo"] != nil && !isPhotoUpdate)
            {
                [picture sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
            }

            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Profile Saved" message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else
        {
            NSString *validated = @"YES";
            if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Profile Validation Failed! Please provide valid contact informations such as address, city, state and contact number details."])
            {
                [[me usr] setObject:validated forKey:@"validated"];
            }
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Something Went Wrong" message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        
        if (isSignup)
        {
            [self.navigationController setNavigationBarHidden:NO];
            [UIView animateWithDuration:0.75
                             animations:^{
                                 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                             }];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
            isSignup = NO;
        }
    }

    else if ([tagName isEqualToString:@"myset"])
    {
        dictProfileinfo = [NSJSONSerialization
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];
        
        NSLog(@"dictProfileinfo is: %@",dictProfileinfo);

        if (![[dictProfileinfo valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]])
        {
            
            if (  [dictProfileinfo valueForKey:@"ContactNumber"] != NULL &&
                ![[dictProfileinfo valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]])
            {
                self.SavePhoneNumber = [dictProfileinfo valueForKey:@"ContactNumber"];
            }
            else {
                self.SavePhoneNumber = @"";
            }

            if ([[dictProfileinfo valueForKey:@"ContactNumber"] length] == 10)
            {
                self.phone.text = [NSString stringWithFormat:@"(%@) %@-%@",
                                   [[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(0, 3)],
                                   [[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(3, 3)],
                                   [[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(6, 4)]];
                NSString * phone = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                self.phone.text = phone;
                
                [dictSavedInfo setObject:self.phone.text forKey:@"phoneno"];
            }
            else
            {
                self.phone.text = [dictProfileinfo valueForKey:@"ContactNumber"];
                NSString * phone = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                self.address_one.text = phone;
                [dictSavedInfo setObject:self.phone.text forKey:@"phoneno"];
            }
         //   [self.list reloadData];
        }
        
        else
            self.SavePhoneNumber = @"";
            
        if (![[dictProfileinfo valueForKey:@"Address"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"Address";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Address"]];
        }
        else if (![[dictProfileinfo valueForKey:@"City"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"City";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"City"]];
        }
        else if (![[dictProfileinfo valueForKey:@"State"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"State";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"State"]];
        }
        else if (![[dictProfileinfo valueForKey:@"Zipcode"] isKindOfClass:[NSNull class]])
        {
         self.ServiceType = @"zip";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
        }
        else if (![[dictProfileinfo valueForKey:@"FirstName"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"name";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
        }
        else if (![[dictProfileinfo valueForKey:@"LastName"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"lastname";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"LastName"]];
        }
        else if (![[dictProfileinfo valueForKey:@"UserName"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType = @"email";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
        }
        else if (![[dictProfileinfo valueForKey:@"RecoveryMail"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType=@"recovery";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"RecoveryMail"]];
        }
        else if (![[dictProfileinfo valueForKey:@"Password"] isKindOfClass:[NSNull class]])
        {
            self.ServiceType=@"pwd";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Password"]];
        }
    }
}

#pragma mark - password encryption

-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue
{
    
    if ([self.ServiceType isEqualToString:@"Address"])
    {
        self.ServiceType = @"City";
        NSArray * arr = [[sourceData objectForKey:@"Status"] componentsSeparatedByString:@"/"];
        
        if ([arr count] == 2)
        {
            self.address_one.text = [arr objectAtIndex:0];
            self.address_two.text = [arr objectAtIndex:1];
        }
        
        else
        {
            self.address_one.text = [arr objectAtIndex:0];
            self.address_two.text = @"";
        }
        NSString * address1 = [self.address_one.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.address_one.text = [address1 capitalizedString];
        NSString* address2 = [self.address_two.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.address_two.text = [address2 capitalizedString];
        
        [dictSavedInfo setObject:self.address_one.text forKey:@"Address1"];
        [dictSavedInfo setObject:self.address_two.text forKey:@"Address2"];
        
        if (![[dictProfileinfo objectForKey:@"City"] isKindOfClass:[NSNull class]])
        {
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"City"]];
        }
    }
    
    else if ([self.ServiceType isEqualToString:@"City"])
    {
        self.ServiceType = @"State";
        self.city.text = [sourceData objectForKey:@"Status"];
        NSString * city = [self.city.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.city.text = [city capitalizedString];

        [dictSavedInfo setObject:self.city.text forKey:@"City"];
       
        if (![[dictProfileinfo objectForKey:@"State"] isKindOfClass:[NSNull class]])
        {
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"State"]];
        }
        
        else if (![[dictProfileinfo objectForKey:@"Zipcode"] isKindOfClass:[NSNull class]]) {
            self.ServiceType = @"zip";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
        }
    }
    
    else if ([self.ServiceType isEqualToString:@"State"])
    {
        self.ServiceType = @"zip";
        
        if (![[dictProfileinfo objectForKey:@"Zipcode"] isKindOfClass:[NSNull class]])
        {
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
        }
        
        else
        {
            self.ServiceType = @"name";
            if (![[dictProfileinfo objectForKey:@"FirstName"] isKindOfClass:[NSNull class]])
            {
                Decryption *decry = [[Decryption alloc] init];
                decry.Delegate = self;
                decry->tag = [NSNumber numberWithInteger:2];
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
            }
        }
    }
    
    else  if ([self.ServiceType isEqualToString:@"zip"])
    {
        self.ServiceType = @"name";
        self.zip.text = [sourceData objectForKey:@"Status"];
        NSString * zip = [self.zip.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.zip.text = zip;
        
        [dictSavedInfo setObject:self.zip.text forKey:@"zip"];
        
        if (![[dictProfileinfo objectForKey:@"FirstName"] isKindOfClass:[NSNull class]])
        {
            Decryption * decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
        }
    }
    
    else  if ([self.ServiceType isEqualToString:@"name"]) // first name
    {
        self.ServiceType = @"lastname";
        
        if ([[sourceData objectForKey:@"Status"] length] > 0)
        {
            NSString * letterA = [[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];

            self.name.text = [NSString stringWithFormat:@"%@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]];
            
            NSString * name = [self.name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.name.text = [name capitalizedString];

            [dictSavedInfo setObject:self.name.text forKey:@"name"];

            if (![[dictProfileinfo objectForKey:@"LastName"] isKindOfClass:[NSNull class]])
            {
                self.ServiceType = @"lastname";
                Decryption * decry = [[Decryption alloc] init];
                decry.Delegate = self;
                decry->tag = [NSNumber numberWithInteger:2];
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"LastName"]];
            }
            else if (![[dictProfileinfo objectForKey:@"UserName"] isKindOfClass:[NSNull class]])
            {
                Decryption * decry = [[Decryption alloc] init];
                decry.Delegate = self;
                decry->tag = [NSNumber numberWithInteger:2];
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
            }
        }
        else {
            UIAlertView * newUserNoName = [[UIAlertView alloc] initWithTitle:@"Nice To Meet You" message:@"Thanks for joining Nooch! Please complete your profile to get started." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [newUserNoName show];
            [newUserNoName setTag:1001];
        }
    }

    else  if ([self.ServiceType isEqualToString:@"lastname"]) //last name
    {
        self.ServiceType = @"email";
        
        if ([[sourceData objectForKey:@"Status"] length] > 0)
        {
            NSString * letterA = [[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];
            self.name.text = [self.name.text stringByAppendingString:[NSString stringWithFormat:@" %@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]]];
            
            NSString * name = [self.name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.name.text = [name capitalizedString];
            
            [dictSavedInfo setObject:self.name.text forKey:@"name"];
        }
        
        if (![[dictProfileinfo objectForKey:@"UserName"] isKindOfClass:[NSNull class]])
        {
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
        }
    }
    
    else  if ([self.ServiceType isEqualToString:@"email"])
    {
        self.email.text = [sourceData objectForKey:@"Status"];
        //  NSString* email = [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (![[dictProfileinfo objectForKey:@"RecoveryMail"] isKindOfClass:[NSNull class]] &&
              [dictProfileinfo objectForKey:@"RecoveryMail"] != NULL &&
            ![[dictProfileinfo objectForKey:@"RecoveryMail"] isEqualToString:@""])
        {
            self.ServiceType = @"recovery";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"RecoveryMail"]];
        }
        
        else
        {
            self.recovery_email.text = @"";
            self.ServiceType = @"pwd";

            if (![[dictProfileinfo objectForKey:@"Password"] isKindOfClass:[NSNull class]])
            {
                Decryption *decry = [[Decryption alloc] init];
                decry.Delegate = self;
                self.ServiceType = @"pwd";
                decry->tag = [NSNumber numberWithInteger:2];
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Password"]];
            }
        }
    }
    else if ([self.ServiceType isEqualToString:@"recovery"])
    {
        self.ServiceType = @"pwd";
        self.recovery_email.text = [[NSString stringWithFormat:@"%@",[sourceData objectForKey:@"Status"]] lowercaseString];
        
        NSString * recovery_email = [self.recovery_email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.recovery_email.text = [recovery_email lowercaseString];
        
        [dictSavedInfo setObject:self.recovery_email.text forKey:@"recovery_email"];

        if ([self.recovery_email.text isKindOfClass:[NSNull class]] ||
            [self.recovery_email.text isEqualToString:@"declined"]) {
            self.recovery_email.text = @"";
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    // Dispose of any resources that can be recreated.
}
@end