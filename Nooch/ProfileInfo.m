//

//  ProfileInfo.m

//  Nooch

//

//  Created by crks on 10/7/13.

//  Copyright (c) 2013 Nooch. All rights reserved.

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

@property(nonatomic,strong) UIButton *save;

@property(nonatomic,strong) NSString *ServiceType;

@property (nonatomic , retain) NSString * SavePhoneNumber;

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

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"Profile Info"];
    if ([[user objectForKey:@"Photo"] length]>0 && [user objectForKey:@"Photo"]!=nil && !isPhotoUpdate) {
        
        [picture setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
         
                placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
        
    }
    
}

-(void)showMenu

{
    
    [self.slidingViewController anchorTopViewTo:ECRight];
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    
    if (isProfileOpenFromSideBar) {
        
        [self.navigationItem setHidesBackButton:YES];
        
        UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [hamburger setFrame:CGRectMake(0, 0, 40, 40)];
        
        [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [hamburger setStyleId:@"navbar_hamburger"];
        
        UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
        
        [self.navigationItem setLeftBarButtonItem:menu];
        
    }
    
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tap];
    
    if (!isSignup) {
        
        [self.slidingViewController.panGesture setEnabled:YES];
        
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
        
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    isPhotoUpdate=NO;
    
    
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self.view addSubview:spinner];
    
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    [spinner startAnimating];
    
    
    [self.navigationItem setTitle:@"Profile Info"];
    serve *serveOBJ=[serve new ];
    
    serveOBJ.tagName=@"myset";
    
    [serveOBJ setDelegate:self];
    
    [serveOBJ getSettings];
    
    // Do any additional setup after loading the view.
    
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    down=0;
    
    if (isSignup) {
        down=64;
        navBar=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
        [navBar setBackgroundColor:[UIColor colorWithRed:82.0f/255.0f green:176.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
        [self.view addSubview:navBar];
        lbl=[[UILabel alloc]initWithFrame:CGRectMake(120, 20,150, 30)];
        [lbl setText:@"Profile Info"];
        [lbl setFont:[UIFont systemFontOfSize:22]];
        [lbl setTextColor:[UIColor whiteColor]];
        [self.view addSubview:lbl];
        crossbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        crossbtn.frame=CGRectMake(10,20, 70,30);
        [crossbtn setStyleClass:@"smscrossbuttn-icon"];
        [crossbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [crossbtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [crossbtn addTarget:self action:@selector(crossClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:crossbtn];
        
    }
    else
    {
        [crossbtn removeFromSuperview];
        [navBar removeFromSuperview];
        [lbl removeFromSuperview];
    }
    UIView *member_since_back = [UIView new];
    [member_since_back setFrame:CGRectMake(0, 0+down, 320, 70)];
    [member_since_back setBackgroundColor:[Helpers hexColor:@"3fabe1"]];
    [member_since_back setAlpha:0.3];
    [self.view addSubview:member_since_back];
    
    picture = [UIImageView new];
    
    [picture setFrame:CGRectMake(20, 5+down, 60, 60)];
    
    picture.layer.cornerRadius = 30; picture.layer.borderColor = [UIColor whiteColor].CGColor; picture.layer.borderWidth = 2;
    
    picture.clipsToBounds = YES;
    
    [picture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change_pic)]];
    
    [picture setUserInteractionEnabled:YES];
    
    [self.view addSubview:picture];
    
    
    
    start = [[user valueForKey:@"DateCreated"] rangeOfString:@"("];
    
    end = [[user valueForKey:@"DateCreated"] rangeOfString:@")"];
    
    if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location)
        
    {
        
        betweenBraces = [[user valueForKey:@"DateCreated"] substringWithRange:NSMakeRange(start.location+1, end.location-(start.location+1))];
        
    }
    
    newString = [betweenBraces substringToIndex:[betweenBraces length]-8];
    
    
    
    NSTimeInterval _interval=[newString doubleValue];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    
    [_formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *_date=[_formatter stringFromDate:date];
    memSincelbl = [[UITextView alloc] initWithFrame:CGRectMake(20, 20+down, 200, 30)];
    [memSincelbl setText:[NSString stringWithFormat:@"Member Since %@",_date]];
    memSincelbl.userInteractionEnabled=NO;
    memSincelbl.selectable=NO;
    [memSincelbl setUserInteractionEnabled:NO];
    [memSincelbl setBackgroundColor:[UIColor clearColor]];
    if (isSignup) {
        [memSincelbl setStyleClass:@"memtable_view_cell_textlabel_1_64"];
    }
    else
        [memSincelbl setStyleClass:@"memtable_view_cell_textlabel_1"];
    
    
    [self.view addSubview:memSincelbl];
    
    self.name = [[UITextField alloc] initWithFrame:CGRectMake(20, 70+down, 280, 30)];
    
    [self.name setTextAlignment:NSTextAlignmentRight]; [self.name setBackgroundColor:[UIColor clearColor]];
    
    [self.name setPlaceholder:@"First & Last Name"]; [self.name setDelegate:self];
    
    [self.name setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.name setText:[NSString stringWithFormat:@"%@ %@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"] capitalizedString],[[[NSUserDefaults standardUserDefaults] objectForKey:@"LastName"] capitalizedString]]];
    
    [self.name setUserInteractionEnabled:NO];
    
    [self.view addSubview:self.name];
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, 70+down, 280, 30)];
    
    [name setBackgroundColor:[UIColor clearColor]]; [name setText:@"Name:"];
    
    [name setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:name];
    
    
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 105+down, 0, 0)];
    
    [div setStyleId:@"divider"];
    
    [self.view addSubview:div];
    
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"]) {
        UIView *email_not_validated = [[UIView alloc] initWithFrame:CGRectMake(0, 110+down, 320, 30)];
        [email_not_validated setBackgroundColor:[UIColor redColor]];
        [email_not_validated setAlpha:0.3];
        [self.view addSubview:email_not_validated];
    }
    
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(20, 110+down, 280, 30)];
    
    [self.email setTextAlignment:NSTextAlignmentRight]; [self.email setBackgroundColor:[UIColor clearColor]];
    
    [self.email setPlaceholder:@"email@email.com"]; [self.email setDelegate:self];
    
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    
    [self.email setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.name setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]];
    
    [self.email setUserInteractionEnabled:NO];
    
    [self.view addSubview:self.email];
    
    UILabel *mail = [[UILabel alloc] initWithFrame:CGRectMake(20, 110+down, 280, 30)];
    
    [mail setBackgroundColor:[UIColor clearColor]]; [mail setText:@"Email:"];
    
    [mail setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:mail];
    
    
    UIView *div2 = [[UIView alloc] initWithFrame:CGRectMake(0, 145+down, 0, 0)];
    
    [div2 setStyleId:@"divider"];
    
    [self.view addSubview:div2];
    
    
    //Recovery Mail
    self.recovery_email = [[UITextField alloc] initWithFrame:CGRectMake(20, 150+down, 280, 30)];
    
    [self.recovery_email setTextAlignment:NSTextAlignmentRight]; [self.recovery_email setBackgroundColor:[UIColor clearColor]];
    
    [self.recovery_email setPlaceholder:@"(Optional)"]; [self.recovery_email setDelegate:self];
    
    [self.recovery_email setKeyboardType:UIKeyboardTypeEmailAddress];
    
    [self.recovery_email setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.view addSubview:self.recovery_email];
    
    UILabel *recover = [[UILabel alloc] initWithFrame:CGRectMake(20, 150+down, 280, 30)];
    
    [recover setBackgroundColor:[UIColor clearColor]]; [recover setText:@"Recovery Email:"];
    
    [recover setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:recover];
    
    
    // Row Seperator
    UIView *div3= [[UIView alloc] initWithFrame:CGRectMake(0, 185+down, 0, 0)];
    
    [div3 setStyleId:@"divider"];
    
    [self.view addSubview:div3];
    
    // Row Seperator
    UIView *div4 = [[UIView alloc] initWithFrame:CGRectMake(0, 225+down, 0, 0)];
    
    [div4 setStyleId:@"divider"];
    
    [self.view addSubview:div4];
    
    
    if (![[user objectForKey:@"IsVerifiedPhone"] isEqualToString:@"YES"]) {
        UIView *unverified_phone = [[UIView alloc] initWithFrame:CGRectMake(0,190+down,320,30)];
        [unverified_phone setAlpha:0.3]; [unverified_phone setBackgroundColor:[UIColor redColor]];
        [self.view addSubview:unverified_phone];
    }
    self.phone = [[UITextField alloc] initWithFrame:CGRectMake(20,190+down,280,30)];
    
    [self.phone setTextAlignment:NSTextAlignmentRight]; [self.phone setBackgroundColor:[UIColor clearColor]];
    
    [self.phone setPlaceholder:@"555-555-5555"]; [self.phone setDelegate:self];
    
    [self.phone setKeyboardType:UIKeyboardTypePhonePad];
    
    [self.phone setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.view addSubview:self.phone];
    
    UILabel *num = [[UILabel alloc] initWithFrame:CGRectMake(20, 190+down, 280, 30)];
    
    [num setBackgroundColor:[UIColor clearColor]]; [num setText:@"Phone:"];
    
    [num setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:num];
    
    
    // Row Seperator
    UIView *div5 = [[UIView alloc] initWithFrame:CGRectMake(0, 265+down, 0, 0)];
    
    [div5 setStyleId:@"divider"];
    
    [self.view addSubview:div5];
    
    
    // Address
    self.address_one = [[UITextField alloc] initWithFrame:CGRectMake(20, 230+down, 280, 30)];
    
    [self.address_one setTextAlignment:NSTextAlignmentRight]; [self.address_one setBackgroundColor:[UIColor clearColor]];
    
    [self.address_one setPlaceholder:@"123 Nooch Lane"]; [self.address_one setDelegate:self];
    
    [self.address_one setKeyboardType:UIKeyboardTypeDefault];
    
    [self.address_one setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.view addSubview:self.address_one];
    
    // Address label
    UILabel *addr1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 230+down, 280, 30)];
    
    [addr1 setBackgroundColor:[UIColor clearColor]]; [addr1 setText:@"Address One:"];
    
    [addr1 setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:addr1];
    
    
    // Row Seperator
    UIView *div6 = [[UIView alloc] initWithFrame:CGRectMake(0, 305+down, 0, 0)];
    
    [div6 setStyleId:@"divider"];
    
    [self.view addSubview:div6];
    
    
    // Address
    self.address_two = [[UITextField alloc] initWithFrame:CGRectMake(20, 270+down, 280, 30)];
    
    [self.address_two setTextAlignment:NSTextAlignmentRight]; [self.address_two setBackgroundColor:[UIColor clearColor]];
    
    [self.address_two setPlaceholder:@"(Optional)"]; [self.address_two setDelegate:self];
    
    [self.address_two setKeyboardType:UIKeyboardTypeDefault];
    
    [self.address_two setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.view addSubview:self.address_two];
    
    
    // Address label
    UILabel *addr2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 270+down, 280, 30)];
    
    [addr2 setBackgroundColor:[UIColor clearColor]]; [addr2 setText:@"Address Two:"];
    
    [addr2 setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:addr2];
    
    
    // Row Seperator
    UIView *div7 = [[UIView alloc] initWithFrame:CGRectMake(0, 345+down, 0, 0)];
    
    [div7 setStyleId:@"divider"];
    
    [self.view addSubview:div7];
    
    
    // City
    self.city = [[UITextField alloc] initWithFrame:CGRectMake(20, 310+down, 280, 30)];
    
    [self.city setTextAlignment:NSTextAlignmentRight]; [self.city setBackgroundColor:[UIColor clearColor]];
    
    [self.city setPlaceholder:@"City"]; [self.city setDelegate:self];
    
    [self.city setKeyboardType:UIKeyboardTypeDefault];
    
    [self.city setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.view addSubview:self.city];
    
    
    // City label
    UILabel *cit = [[UILabel alloc] initWithFrame:CGRectMake(20, 310+down, 280, 30)];
    
    [cit setBackgroundColor:[UIColor clearColor]]; [cit setText:@"City:"];
    
    [cit setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:cit];
    
    
    // Row Seperator
    UIView *div8 = [[UIView alloc] initWithFrame:CGRectMake(0, 385+down, 0, 0)];
    
    [div8 setStyleId:@"divider"];
    
    [self.view addSubview:div8];
    
    
    // Zip label
    self.zip = [[UITextField alloc] initWithFrame:CGRectMake(20, 350+down, 280, 30)];
    
    [self.zip setTextAlignment:NSTextAlignmentRight]; [self.zip setBackgroundColor:[UIColor clearColor]];
    
    [self.zip setPlaceholder:@"12345"]; [self.zip setDelegate:self];
    
    [self.zip setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.zip setStyleClass:@"table_view_cell_detailtext_1"];
    
    [self.view addSubview:self.zip];
    
    UILabel *z = [[UILabel alloc] initWithFrame:CGRectMake(20, 350+down, 280, 30)];
    
    [z setBackgroundColor:[UIColor clearColor]]; [z setText:@"ZIP:"];
    
    [z setStyleClass:@"table_view_cell_textlabel_1"];
    
    [self.view addSubview:z];
    
    
    
    self.save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [self.save addTarget:self action:@selector(save_changes) forControlEvents:UIControlEventTouchUpInside];
    
    [self.save setTitle:@"Save Profile" forState:UIControlStateNormal];
    
    [self.save setFrame:CGRectMake(0, 400+down, 0, 0)];
    
    [self.save setStyleClass:@"button_green"];
    
    [self.save setEnabled:YES];
    
    [self.view addSubview:self.save];
    
    
    
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
                              
                              @"Tasmania Standard Time",@"GMT+10:00",
                              
                              @"West Pacific Standard Time",@"GMT+10:00",
                              
                              nil];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                             [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [scroll setDelegate:self];
        [scroll setContentSize:CGSizeMake(320, 530)];
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
            [scroll addSubview:subview];
        }
         [self.view addSubview:scroll];
    }
}
-(void)crossClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    [self.name resignFirstResponder];
    
    [self.email  resignFirstResponder];
    
    [self.recovery_email resignFirstResponder];
    
    [self.phone resignFirstResponder];
    
    [self.address_one resignFirstResponder];
    
    [self.address_two resignFirstResponder];
    
    [self.city resignFirstResponder];
    
    [self.zip resignFirstResponder];
    
    
    
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
    
    if ([self.name.text length]==0) {
        
        UIAlertView *av =[ [UIAlertView alloc] initWithTitle:@"Nooch Money!" message:@"Please Enter Name" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        
        [av show];
        
        return;
        
    }
    
    
    
    if (![self validateEmail:[self.email text]]) {
        
        self.email.text = @"";
        
        [self.email becomeFirstResponder];
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Valid Email ID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        
        
        return;
        
    }
    
    if ([self.address_one.text length]==0) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        [self.address_one becomeFirstResponder];
        
        
        
        return;
        
    }
    
    if ([self.city.text length]==0) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Your City" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        [self.city becomeFirstResponder];
        
        return;
        
    }
    
    UIAlertView *av =[ [UIAlertView alloc] initWithTitle:@"I don't see you!" message:@"You haven't set your profile picture, would you like to?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
    [av setTag:20];
    
    if([[me pic] isKindOfClass:[NSNull class]]){
        
        [av show];
        
    }
    
    [self.save setEnabled:NO];
    [self.save setUserInteractionEnabled:NO];
    
    //NSLog(@"%@",self.SavePhoneNumber);
    
    // NSLog(@"%@",self.phone.text);
    
    strPhoneNumber=self.phone.text;
    
    strPhoneNumber=[strPhoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    strPhoneNumber=[strPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    strPhoneNumber=[strPhoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    strPhoneNumber=[strPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    
    if (![self.SavePhoneNumber isEqualToString:strPhoneNumber] || [self.SavePhoneNumber length]==0) {
        
        NSLog(@"Not Same");
        
        serve *req = [serve new];
        
        [req SendSMSApi:strPhoneNumber msg:@"PLEASE RESPOND \"GO\" TO THE TEXT"];
        
        
    }
    
    
    
    if([self.recovery_email.text length]==0)
        
    {
        
        self.recovery_email.text=@"";
        
    }
    
    
    
    timezoneStandard = [NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone]];
    
    timezoneStandard = [[timezoneStandard componentsSeparatedByString:@", "] objectAtIndex:0];
    
    timezoneStandard = [GMTTimezonesDictionary objectForKey:timezoneStandard];
    
    timezoneStandard = @"";
    
    
    
    
    
    //    if ([self.phone.text length]!=10)
    
    //    {
    
    //
    
    //        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"NoochMoney" message:@"Enter valid 10 digit Cell Number" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil, nil];
    
    //        [alert show];
    
    //        return;
    
    //    }
    
    recoverMail = [[NSString alloc] init];
    
    if([self.recovery_email.text length] > 0)
        
    {
        
        if (![self validateEmail:[self.recovery_email text]]) {
            
            // [me endWaitStat];
            
            self.recovery_email.text = @"";
            
            [self.recovery_email becomeFirstResponder];
            
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Valid Recovery Email ID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            
            
            
            return;
            
        }
        
    }
    
    if([self.recovery_email.text length] > 0){
        
        recoverMail = self.recovery_email.text;
        
    }else
        
        recoverMail = @"";
    
    if([self.address_two.text length] != 0){
        
        [[me usr] setObject:self.address_two.text forKey:@"Addr2"];
        
        [[me usr] setObject:self.address_two.text forKey:@"Addr1"];
        
    }else{
        
        [[me usr] removeObjectForKey:@"Addr2"];
        
    }
    self.name.text=[self.name.text lowercaseString];
    
    NSArray*arrdivide=[self.name.text componentsSeparatedByString:@" "];
    
    if ([arrdivide count]==2) {
        
        transactionInput  =[[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",[arrdivide objectAtIndex:0],@"FirstName",[arrdivide objectAtIndex:1],@"LastName",self.email.text,@"UserName",nil];
        
    }
    
    else
        
    {
        
        transactionInput  =[[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",self.name.text,@"FirstName",@" ",@"LastName",self.email.text,@"UserName",nil];
        
    }
    
    
    [transactionInput setObject:[NSString stringWithFormat:@"%@/%@",self.address_one.text,self.address_two.text] forKey:@"Address"];
    
    
    [transactionInput setObject:self.city.text forKey:@"City"];
    
    NSLog(@"%d",[self.phone.text length]);
    
    //    if ([self.phone.text length]!=10)
    
    //    {
    
    //        //[me endWaitStat];
    
    //        UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"NoochMoney" message:@"Enter valid 10 digit Cell Number" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil, nil];
    
    //        [alert show];
    
    //        return;
    
    //    }
    
    //    else
    
    //    {
    
    //NSString *number = [NSString stringWithFormat:@"%@%@%@",[self.phone.text substringWithRange:NSMakeRange(1, 3)],[self.phone.text substringWithRange:NSMakeRange(6, 3)],[self.phone.text substringWithRange:NSMakeRange(10, 4)]];
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
       
        NSData *data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
        
        NSUInteger len = data.length;
        
        uint8_t *bytes = (uint8_t *)[data bytes];
        
        NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];
        for (NSUInteger i = 0; i < len; i++) {
            
            if (i) {
                
                [result1 appendString:@","];
                
            }
            
            [result1 appendFormat:@"%d", bytes[i]];
            
        }
        NSArray*arr=[result1 componentsSeparatedByString:@","];
        
        
        [transactionInput setObject:arr forKey:@"Picture"];
        
    }
    NSLog(@"%@",transactionInput);
    
    [spinner startAnimating];
    
    [spinner setHidden:NO];
    
    transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"mySettings", nil];
    
    serve *req=[serve new];
    
    req.Delegate = self;
    
    req.tagName=@"MySettingsResult";
    
    
    [req setSets:transaction];
    
    NSArray*arr=[self.name.text componentsSeparatedByString:@" "];
    
    if ([arr count]==2) {
        
        self.name.text=[NSString stringWithFormat:@"%@ %@",[[arr objectAtIndex:0] capitalizedString],[[arr objectAtIndex:1] capitalizedString]];
    }

}

- (void)change_pic
{
    
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Facebook Picture", @"Use Camera", @"From iPhone Library", nil];
    
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    
    [actionSheetObject showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)
        
    {
        
        //self.pic.layer.borderColor = kNoochBlue.CGColor;
        
        //[self.pic setImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];
        
    }
    
    else if(buttonIndex == 1)
    {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                        
                                                                  message:@"Device has no camera"
                                        
                                                                 delegate:nil
                                        
                                                        cancelButtonTitle:@"OK"
                                        
                                                        otherButtonTitles: nil];
            
            
            [myAlertView show];
            
            return;
            
        }
        
        self.picker=[UIImagePickerController new];
        
        self.picker.delegate = self;
        
        self.picker.allowsEditing = YES;
        
        self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:self.picker animated:YES completion:Nil];
        
        
    }
    else if(buttonIndex == 2)
        {
        self.picker=[UIImagePickerController new];
        
        self.picker.delegate = self;
        
        self.picker.allowsEditing = YES;
        
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.picker animated:YES completion:Nil];
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

#pragma mark-ImagePicker

- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(120,120) interpolationQuality:kCGInterpolationMedium];
    isPhotoUpdate=YES;
    
    [picture setImage:image];
    
    [[assist shared]setTranferImage:image];
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
    return 10;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:kNoochGrayLight];
        
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
   
    return 70.0;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UITextField delegation

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    
    [self.save setEnabled:YES];
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField

{
    
    [textField resignFirstResponder];
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField

{
    
    if (textField==self.phone) {
        
        if ([self.phone.text length]==10) {
            
            self.phone.text = [NSString stringWithFormat:@"(%@) %@-%@",[self.phone.text substringWithRange:NSMakeRange(0, 3)],[self.phone.text substringWithRange:NSMakeRange(3, 3)],[self.phone.text substringWithRange:NSMakeRange(6, 4)]];
            
        }
        
    }
    [self animateTextField:textField up:NO];
    
}

#pragma mark - adjusting for textfield view

- (void) animateTextField: (UITextField*) textField up: (BOOL) up

{
    
    const int movementDistance = textField.frame.origin.y/2; // tweak as needed
    
    const float movementDuration = 0.3f; // tweak as needed
    
    
    
    int movement = (up ? -movementDistance : movementDistance);
    
    
    
    [UIView beginAnimations: @"anim" context: nil];
    
    [UIView setAnimationBeginsFromCurrentState: YES];
    
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
    
}


#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    
}

#pragma mark - server delegation

- (void) listen:(NSString *)result tagName:(NSString *)tagName

{      NSError* error;
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [Alert show];
        
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        // NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
        [timer invalidate];
        // timer=nil;
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        NSLog(@"%@",nav_ctrl.viewControllers);
        NSMutableArray*arrNav=[nav_ctrl.viewControllers mutableCopy];
        for (int i=[arrNav count]; i>1; i--) {
            [arrNav removeLastObject];
        }
        
        [nav_ctrl setViewControllers:arrNav animated:NO];
        
        NSLog(@"%@",nav_ctrl.viewControllers);

        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    
    if([tagName isEqualToString:@"MySettingsResult"])
        
    {
        dictProfileinfo=[NSJSONSerialization
                         
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         
                         options:kNilOptions
                         
                         error:&error];
        
        
        
        NSDictionary *resultValue = [dictProfileinfo valueForKey:@"MySettingsResult"];
        
        //NSLog(@"resultValue is : %@", result);
        
        getEncryptionOldPassword= [dictProfileinfo objectForKey:@"Password"];
        
        if([[resultValue valueForKey:@"Result"] isEqualToString:@"Your details have been updated successfully."]){
            
            NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
            
            [defaults setObject:@"YES" forKey:@"ProfileComplete"];
            
            [defaults synchronize];
            [self.save setEnabled:YES];
            [self.save setUserInteractionEnabled:YES];
            
            
            if ([[user objectForKey:@"Photo"] length]>0 && [user objectForKey:@"Photo"]!=nil && !isPhotoUpdate) {
                
                [picture setImageWithURL:[NSURL URLWithString:[user objectForKey:@"Photo"]]
                 
                        placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
                
            }
            
            
            
        }else{
            
            NSString *validated = @"YES"; //
            
            if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Profile Validation Failed! Please provide valid contact informations such as address, city, state and contact number details."]) {
                
                [[me usr] setObject:validated forKey:@"validated"];
                
                
                
            }
            
        }
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
        
        [av setTag:9];
        
        [spinner stopAnimating];
        
        [spinner setHidden:YES];
        
        if (isSignup || [[[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationPush"]intValue]==1) {
            
            [self dismissViewControllerAnimated:NO completion:nil];
            
            
            
        }
        
    }
    
    else if ([tagName isEqualToString:@"myset"]) {
        
        
        
        dictProfileinfo=[NSJSONSerialization
                         
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         
                         options:kNilOptions
                         
                         error:&error];
        if (![[dictProfileinfo valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]]) {
            
            
            
            if ([dictProfileinfo valueForKey:@"ContactNumber"]!=NULL && ![[dictProfileinfo valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]]) {
                
                self.SavePhoneNumber=[dictProfileinfo valueForKey:@"ContactNumber"];
                
            }
        else
            {
            self.SavePhoneNumber=@"";
                
            }
            
            if ([[dictProfileinfo valueForKey:@"ContactNumber"] length]==10) {
                
                self.phone.text = [NSString stringWithFormat:@"(%@) %@-%@",[[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(0, 3)],[[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(3, 3)],[[dictProfileinfo objectForKey:@"ContactNumber"] substringWithRange:NSMakeRange(6, 4)]];
                
            }
            
            else
                
                self.phone.text=[dictProfileinfo valueForKey:@"ContactNumber"];
            
        }
        
        else
            self.SavePhoneNumber=@"";
            
        
        if (![[dictProfileinfo valueForKey:@"Address"] isKindOfClass:[NSNull class]]) {
            
            self.ServiceType=@"Address";
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Address"]];
           
        }
        
        else if(![[dictProfileinfo valueForKey:@"City"] isKindOfClass:[NSNull class]])
            
        {
            self.ServiceType=@"City";
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"City"]];
            
            
            
        }
        
        else if(![[dictProfileinfo valueForKey:@"State"] isKindOfClass:[NSNull class]])
            
        {
            
            self.ServiceType=@"State";
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"State"]];
            
        }
        
        else if(![[dictProfileinfo valueForKey:@"Zipcode"] isKindOfClass:[NSNull class]])
            
        {
         self.ServiceType=@"zip";
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
            
        
        }
        
        else if (![[dictProfileinfo valueForKey:@"FirstName"] isKindOfClass:[NSNull class]])
            
        {
            
            self.ServiceType=@"name";
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
            
            
        }
        
        else if (![[dictProfileinfo valueForKey:@"LastName"] isKindOfClass:[NSNull class]])
            
        {
            
            self.ServiceType=@"lastname";
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"LastName"]];
            
        }
        
        else if (![[dictProfileinfo valueForKey:@"UserName"] isKindOfClass:[NSNull class]])
            
        {
            self.ServiceType=@"email";
            
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
        [spinner stopAnimating];
        
    }
    
}

#pragma mark - password encryption

-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue{
    if([self.ServiceType isEqualToString:@"Address"])
        
    {
        
        self.ServiceType=@"City";
        NSArray*arr=[[sourceData objectForKey:@"Status"] componentsSeparatedByString:@"/"];
        
        if ([arr count]==2) {
            
            self.address_one.text=[arr objectAtIndex:0];
            
            self.address_two.text=[arr objectAtIndex:1];
            
        }
        
        else
        self.address_one.text=[arr objectAtIndex:0];
        
        if (![[dictProfileinfo objectForKey:@"City"] isKindOfClass:[NSNull class]]) {
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"City"]];
            
        }
        }
    
    else if([self.ServiceType isEqualToString:@"City"])
        
    {
        
        self.ServiceType=@"State";
        
        self.city.text=[sourceData objectForKey:@"Status"];
        if (![[dictProfileinfo objectForKey:@"State"] isKindOfClass:[NSNull class]]) {
           
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"State"]];
           
        }
        
        else if (![[dictProfileinfo objectForKey:@"Zipcode"] isKindOfClass:[NSNull class]]) {
            self.ServiceType=@"zip";
           
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
            
        }
    }
    
    else if([self.ServiceType isEqualToString:@"State"])
        
    {
        
        self.ServiceType=@"zip";
        
        if (![[dictProfileinfo objectForKey:@"Zipcode"] isKindOfClass:[NSNull class]]) {
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptedValue:@"GetDecryptedData" pwdString:[dictProfileinfo objectForKey:@"Zipcode"]];
            
        }
        
        else
        {
            self.ServiceType=@"name";
            
            if (![[dictProfileinfo objectForKey:@"FirstName"] isKindOfClass:[NSNull class]]) {
                
                Decryption *decry = [[Decryption alloc] init];
                
                decry.Delegate = self;
                
                decry->tag = [NSNumber numberWithInteger:2];
                
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
                
            }
            
        }
       
    }
    
    else  if ([self.ServiceType isEqualToString:@"zip"])
        
    {
        self.ServiceType=@"name";
        self.zip.text=[sourceData objectForKey:@"Status"];
        if (![[dictProfileinfo objectForKey:@"FirstName"] isKindOfClass:[NSNull class]]) {
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
            
        }
        
    }
    
    else  if ([self.ServiceType isEqualToString:@"name"])
        
    {
        self.ServiceType=@"lastname";
        
        if ([[sourceData objectForKey:@"Status"] length]>0) {
            
            NSString* letterA=[[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];
           
            self.name.text=[NSString stringWithFormat:@"%@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]];
            
            if (![[dictProfileinfo objectForKey:@"LastName"] isKindOfClass:[NSNull class]])
                
            {
                
                self.ServiceType=@"lastname";
                
                Decryption *decry = [[Decryption alloc] init];
                
                decry.Delegate = self;
                
                decry->tag = [NSNumber numberWithInteger:2];
                
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"LastName"]];
                
            }
            
            else if (![[dictProfileinfo objectForKey:@"UserName"] isKindOfClass:[NSNull class]]) {
                
                self.ServiceType=@"email";
                
                Decryption *decry = [[Decryption alloc] init];
                
                decry.Delegate = self;
                
                decry->tag = [NSNumber numberWithInteger:2];
                
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
                
            }
            
        }
        
    }
    
    else  if ([self.ServiceType isEqualToString:@"lastname"])
        
    {
        self.ServiceType=@"email";
        
        if ([[sourceData objectForKey:@"Status"] length]>0) {
            
            NSString* letterA=[[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];
            self.name.text=[self.name.text stringByAppendingString:[NSString stringWithFormat:@" %@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]]];
        }
        
        if (![[dictProfileinfo objectForKey:@"UserName"] isKindOfClass:[NSNull class]]) {
            
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
            
        }
        
    }
    
    else  if ([self.ServiceType isEqualToString:@"email"])
        
    {
        
        self.email.text=[sourceData objectForKey:@"Status"];
        
        if (![[dictProfileinfo objectForKey:@"RecoveryMail"] isKindOfClass:[NSNull class]]&& [dictProfileinfo objectForKey:@"RecoveryMail"]!=NULL && ![[dictProfileinfo objectForKey:@"RecoveryMail"] isEqualToString:@""]) {
            
            self.ServiceType=@"recovery";
            Decryption *decry = [[Decryption alloc] init];
            
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"RecoveryMail"]];
            
        }
        
        else
            
        {
            self.recovery_email.text=@"";
            
            self.ServiceType=@"pwd";
            if (![[dictProfileinfo objectForKey:@"Password"] isKindOfClass:[NSNull class]]) {
                
                Decryption *decry = [[Decryption alloc] init];
                
                decry.Delegate = self;
                
                self.ServiceType=@"pwd";
                
                decry->tag = [NSNumber numberWithInteger:2];
                
                [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Password"]];
                
            }
            
        }
        
    }
    
    //RecoveryMail
    
    else if ([self.ServiceType isEqualToString:@"recovery"])
        
    {
        
        self.ServiceType=@"pwd";
        
        self.recovery_email.text=[NSString stringWithFormat:@"%@",[sourceData objectForKey:@"Status"]];
        
        if ([self.recovery_email.text isKindOfClass:[NSNull class]]) {
            
            self.recovery_email.text=@"";
            
        }
    }
    
}

- (void)didReceiveMemoryWarning

{
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}



@end
