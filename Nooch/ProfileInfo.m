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
#import "ECSlidingViewController.h"
@interface ProfileInfo ()
@property(nonatomic) UIImagePickerController *picker;
@property(nonatomic,strong) UITextField *name;
@property(nonatomic,strong) UITextField *email;
@property(nonatomic,strong) UITextField *recovery_email;
@property(nonatomic,strong) UITextField *password;
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
    if ([newchangedPass length]>0 && isPasswordChanged) {
        self.password.text=newchangedPass;
    }
    
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
    
    picture = [UIImageView new];
    [picture setFrame:CGRectMake(20, 10, 60, 60)];
    picture.layer.cornerRadius = 30; picture.layer.borderColor = kNoochBlue.CGColor; picture.layer.borderWidth = 1;
    picture.clipsToBounds = YES;
    [picture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change_pic)]];
    [picture setUserInteractionEnabled:YES];
    [self.view addSubview:picture];
    
    memSincelbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 110, 30)];
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
    [_formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *_date=[_formatter stringFromDate:date];
    
    
    
    [memSincelbl setBackgroundColor:[UIColor clearColor]]; [memSincelbl setText:[NSString stringWithFormat:@"Member Since :%@",_date]];
    [memSincelbl setStyleClass:@"memtable_view_cell_textlabel_1"];
    [self.view addSubview:memSincelbl];
    
    self.name = [[UITextField alloc] initWithFrame:CGRectMake(20, 70, 280, 30)];
    [self.name setTextAlignment:NSTextAlignmentRight]; [self.name setBackgroundColor:[UIColor clearColor]];
    [self.name setPlaceholder:@"First & Last Name"]; [self.name setDelegate:self];
    [self.name setStyleClass:@"table_view_cell_detailtext_1"];
    [self.name setText:[NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"LastName"]]];
    [self.name setUserInteractionEnabled:NO];
    [self.view addSubview:self.name];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 280, 30)];
    [name setBackgroundColor:[UIColor clearColor]]; [name setText:@"Name:"];
    [name setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:name];
    
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 105, 0, 0)];
    [div setStyleId:@"divider"];
    [self.view addSubview:div];
    
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(20, 110, 280, 30)];
    [self.email setTextAlignment:NSTextAlignmentRight]; [self.email setBackgroundColor:[UIColor clearColor]];
    [self.email setPlaceholder:@"email@email.com"]; [self.email setDelegate:self];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.email setStyleClass:@"table_view_cell_detailtext_1"];
    [self.name setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]];
    [self.email setUserInteractionEnabled:NO];
    [self.view addSubview:self.email];
    UILabel *mail = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 280, 30)];
    [mail setBackgroundColor:[UIColor clearColor]]; [mail setText:@"Email:"];
    [mail setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:mail];
    
    UIView *div2 = [[UIView alloc] initWithFrame:CGRectMake(0, 145, 0, 0)];
    [div2 setStyleId:@"divider"];
    [self.view addSubview:div2];
    
    self.recovery_email = [[UITextField alloc] initWithFrame:CGRectMake(20, 150, 280, 30)];
    [self.recovery_email setTextAlignment:NSTextAlignmentRight]; [self.recovery_email setBackgroundColor:[UIColor clearColor]];
    [self.recovery_email setPlaceholder:@"(Optional)"]; [self.recovery_email setDelegate:self];
    [self.recovery_email setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.recovery_email setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.recovery_email];
    UILabel *recover = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 30)];
    [recover setBackgroundColor:[UIColor clearColor]]; [recover setText:@"Recovery Email:"];
    [recover setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:recover];
    
    UIView *div3= [[UIView alloc] initWithFrame:CGRectMake(0, 185, 0, 0)];
    [div3 setStyleId:@"divider"];
    [self.view addSubview:div3];
    
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(20, 190, 280, 30)];
    [self.password setTextAlignment:NSTextAlignmentRight]; [self.password setBackgroundColor:[UIColor clearColor]];
    [self.password setPlaceholder:@"password"]; [self.password setDelegate:self];
    [self.password setStyleClass:@"table_view_cell_detailtext_1"];
    [self.password setSecureTextEntry:YES];
    [self.view addSubview:self.password];
    UILabel *pass = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, 280, 30)];
    [pass setBackgroundColor:[UIColor clearColor]]; [pass setText:@"Password:"];
    [pass setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:pass];
    
    UIView *div4 = [[UIView alloc] initWithFrame:CGRectMake(0, 225, 0, 0)];
    [div4 setStyleId:@"divider"];
    [self.view addSubview:div4];
    
    self.phone = [[UITextField alloc] initWithFrame:CGRectMake(20,230,280,30)];
    [self.phone setTextAlignment:NSTextAlignmentRight]; [self.phone setBackgroundColor:[UIColor clearColor]];
    [self.phone setPlaceholder:@"555-555-5555"]; [self.phone setDelegate:self];
    [self.phone setKeyboardType:UIKeyboardTypePhonePad];
    [self.phone setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.phone];
    UILabel *num = [[UILabel alloc] initWithFrame:CGRectMake(20, 230, 280, 30)];
    [num setBackgroundColor:[UIColor clearColor]]; [num setText:@"Phone:"];
    [num setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:num];
    
    UIView *div5 = [[UIView alloc] initWithFrame:CGRectMake(0, 265, 0, 0)];
    [div5 setStyleId:@"divider"];
    [self.view addSubview:div5];
    
    self.address_one = [[UITextField alloc] initWithFrame:CGRectMake(20, 270, 280, 30)];
    [self.address_one setTextAlignment:NSTextAlignmentRight]; [self.address_one setBackgroundColor:[UIColor clearColor]];
    [self.address_one setPlaceholder:@"123 Nooch Lane"]; [self.address_one setDelegate:self];
    [self.address_one setKeyboardType:UIKeyboardTypeDefault];
    [self.address_one setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.address_one];
    UILabel *addr1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 270, 280, 30)];
    [addr1 setBackgroundColor:[UIColor clearColor]]; [addr1 setText:@"Address One:"];
    [addr1 setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:addr1];
    
    UIView *div6 = [[UIView alloc] initWithFrame:CGRectMake(0, 305, 0, 0)];
    [div6 setStyleId:@"divider"];
    [self.view addSubview:div6];
    
    self.address_two = [[UITextField alloc] initWithFrame:CGRectMake(20, 310, 280, 30)];
    [self.address_two setTextAlignment:NSTextAlignmentRight]; [self.address_two setBackgroundColor:[UIColor clearColor]];
    [self.address_two setPlaceholder:@"(Optional)"]; [self.address_two setDelegate:self];
    [self.address_two setKeyboardType:UIKeyboardTypeDefault];
    [self.address_two setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.address_two];
    UILabel *addr2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 310, 280, 30)];
    [addr2 setBackgroundColor:[UIColor clearColor]]; [addr2 setText:@"Address Two:"];
    [addr2 setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:addr2];
    
    UIView *div7 = [[UIView alloc] initWithFrame:CGRectMake(0, 345, 0, 0)];
    [div7 setStyleId:@"divider"];
    [self.view addSubview:div7];
    
    self.city = [[UITextField alloc] initWithFrame:CGRectMake(20, 350, 280, 30)];
    [self.city setTextAlignment:NSTextAlignmentRight]; [self.city setBackgroundColor:[UIColor clearColor]];
    [self.city setPlaceholder:@"City"]; [self.city setDelegate:self];
    [self.city setKeyboardType:UIKeyboardTypeDefault];
    [self.city setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.city];
    UILabel *cit = [[UILabel alloc] initWithFrame:CGRectMake(20, 350, 280, 30)];
    [cit setBackgroundColor:[UIColor clearColor]]; [cit setText:@"City:"];
    [cit setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:cit];
    
    UIView *div8 = [[UIView alloc] initWithFrame:CGRectMake(0, 385, 0, 0)];
    [div8 setStyleId:@"divider"];
    [self.view addSubview:div8];
    
    self.zip = [[UITextField alloc] initWithFrame:CGRectMake(20, 390, 280, 30)];
    [self.zip setTextAlignment:NSTextAlignmentRight]; [self.zip setBackgroundColor:[UIColor clearColor]];
    [self.zip setPlaceholder:@"12345"]; [self.zip setDelegate:self];
    [self.zip setKeyboardType:UIKeyboardTypeNumberPad];
    [self.zip setStyleClass:@"table_view_cell_detailtext_1"];
    [self.view addSubview:self.zip];
    UILabel *z = [[UILabel alloc] initWithFrame:CGRectMake(20, 390, 280, 30)];
    [z setBackgroundColor:[UIColor clearColor]]; [z setText:@"ZIP:"];
    [z setStyleClass:@"table_view_cell_textlabel_1"];
    [self.view addSubview:z];
    
    self.save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.save addTarget:self action:@selector(save_changes) forControlEvents:UIControlEventTouchUpInside];
    [self.save setTitle:@"Save Profile" forState:UIControlStateNormal];
    [self.save setFrame:CGRectMake(0, 440, 0, 0)];
    [self.save setStyleClass:@"button_green"];
    [self.save setEnabled:YES];
    [self.view addSubview:self.save];
    
    self.name.text=@"";
     self.email.text=@"";
     self.recovery_email.text=@"";
     self.password.text=@"";
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
}
-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer{
    [self.name resignFirstResponder];
    [self.email  resignFirstResponder];
    [self.recovery_email resignFirstResponder];
    [self.password resignFirstResponder];
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
//    if ([self.st.text length]==0) {
//        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter State" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        [self.state becomeFirstResponder];
//        return;
//        
//    }
    


    UIAlertView *av =[ [UIAlertView alloc] initWithTitle:@"I don't see you!" message:@"You haven't set your profile picture, would you like to?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [av setTag:20];
    if([[me pic] isKindOfClass:[NSNull class]]){
        [av show];
    }
    NSLog(@"%@",self.SavePhoneNumber);
    NSLog(@"%@",self.phone.text);
    //if (![self.SavePhoneNumber isEqualToString:self.phone.text]) {
        NSLog(@"Not Same");
        
        //do Phone Validation
        
        
        serve *req = [serve new];
        [req SendSMSApi:self.phone.text msg:@"PLEASE RESPOND \"GO\" TO THE TEXT"];
        
        // self.contactPhone.text
        
        
        
        
    //}
    
    //[self.view addSubview:[me waitStat:@"Saving your profile..."]];
   //  [self getEncryptedPassword:self.password.text];
   
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
            [me endWaitStat];
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

    NSCharacterSet* digitsCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* lettercaseCharSet = [NSCharacterSet letterCharacterSet];
    if([self.password.text length] != 0)
    {
        if([self.password.text length] < 8){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain minimum of 8 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }else if([self.password.text rangeOfCharacterFromSet:digitsCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain at least one numeric character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        
        else if([self.password.text rangeOfCharacterFromSet:lettercaseCharSet].location == NSNotFound){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Password should contain at least one character." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        
        else {
            [self getEncryptedPassword:self.password.text];
        }
    }
   
    
}

-(void)setEncryptedPassword:(NSString *) encryptedPwd{
    NSLog(@"%@",encryptedPwd);
    getEncryptedPasswordValue = [[NSString alloc] initWithString:encryptedPwd];
    self.name.text=[self.name.text lowercaseString];
    transactionInput  =[[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"MemberId",self.name.text,@"FirstName",self.email.text,@"UserName",nil];
    [transactionInput setObject:getEncryptedPasswordValue forKey:@"Password"];
    [transactionInput setObject:[NSString stringWithFormat:@"%@/%@",self.address_one.text,self.address_two.text] forKey:@"Address"];
    //[transactionInput setObject:[NSString stringWithFormat:@"%@ %@",self.address.text,self.addressLine2.text] forKey:@"Address"];
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
        [transactionInput setObject:self.phone.text forKey:@"ContactNumber"];
        
        
    //}
    
    [transactionInput setObject:self.zip.text forKey:@"Zipcode"];
    [transactionInput setObject:@"false" forKey:@"UseFacebookPicture"];
    
    [transactionInput setObject:@".png" forKey:@"fileExtension"];

    [transactionInput setObject:recoverMail forKey:@"RecoveryMail"];
    // [transactionInput setObject:self.state.text forKey:@"State"];
    [transactionInput setObject:timezoneStandard forKey:@"TimeZoneKey"];
    [transactionInput setObject:getEncryptedPasswordValue forKey:@"Password"];
    if ([[assist shared] getTranferImage]) {
        
        NSData *data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
        NSUInteger len = data.length;
        uint8_t *bytes = (uint8_t *)[data bytes];
        NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];
        //  [result1 appendString:@"["];
        for (NSUInteger i = 0; i < len; i++) {
            if (i) {
                [result1 appendString:@","];
            }
            [result1 appendFormat:@"%d", bytes[i]];
        }
        //[result1 appendString:@"]"];
        NSArray*arr=[result1 componentsSeparatedByString:@","];
        // NSLog(@"%@image",image64);
        //[transactionInputTransfer setValue:arr forKey:@"Picture"];
        [transactionInput setObject:arr forKey:@"Picture"];

        
    }
    NSLog(@"%@",transactionInput);
    [spinner startAnimating];
    [spinner setHidden:NO];
    transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"mySettings", nil];
    serve *req=[serve new];
    req.Delegate = self;
    req.tagName=@"MySettingsResult";
    //NSLog(@"transaction INput %@",transaction);
    [req setSets:transaction];
    // firstTime = NO;
    
    //first letter uppercase
   // self.name.text=@"";
    NSArray*arr=[self.name.text componentsSeparatedByString:@" "];
    if ([arr count]==2) {
        self.name.text=[NSString stringWithFormat:@"%@ %@",[[arr objectAtIndex:0] capitalizedString],[[arr objectAtIndex:1] capitalizedString]];
    }
    
    

}
-(void) getEncryptedPassword:(NSString *)newPassword{
    
    if([newPassword length]!=0){
        GetEncryptionValue *encryPassword = [[GetEncryptionValue alloc] init];
        encryPassword.Delegate = self;
        encryPassword->tag = [NSNumber numberWithInteger:2];
        [encryPassword getEncryptionData:newPassword];
       
    }
    NSLog(@"encrypting password");
}
-(void)encryptionDidFinish:(NSString *) encryptedData TValue:(NSNumber *) tagValue{
   // NSInteger value = [tagValue integerValue];
    [self setEncryptedPassword:encryptedData];
    
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
        

       
                // [self presentModalViewController:self.picker animated:YES];
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
    isPhotoUpdate=YES;
    [picture setImage:[self imageWithImage:image scaledToSize:CGSizeMake(40, 40)]];
    [[assist shared]setTranferImage:[self imageWithImage:image scaledToSize:CGSizeMake(40, 40)]];
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1{
    [self dismissViewControllerAnimated:YES completion:Nil];
    // 29/12
	//[self dismissModalViewControllerAnimated:YES];
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
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*cell.textLabel.textColor = [UIColor colorWithRed:51./255.
         green:153./255.
         blue:204./255.
         alpha:1.0];*/
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
    if (textField == self.password) {
        
        [self.view endEditing:YES];
        userPass=self.password.text;
        NSLog(@"%@",userPass);
        ResetPassword *pass_res = [ResetPassword new];
        [self.navigationController pushViewController:pass_res animated:YES];
    }
    [self animateTextField:textField up:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
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

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{      NSError* error;
    
    if([tagName isEqualToString:@"MySettingsResult"])
    {
        dictProfileinfo=[NSJSONSerialization
                         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];

        NSDictionary *resultValue = [dictProfileinfo valueForKey:@"MySettingsResult"];
        NSLog(@"resultValue is : %@", result);
       getEncryptionOldPassword= [dictProfileinfo objectForKey:@"Password"];
        if([[resultValue valueForKey:@"Result"] isEqualToString:@"Your details have been updated successfully."]){ //&& imageData.length != 0
           
            
            NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:@"ProfileComplete"];
            [defaults synchronize];
        }else{
            NSString *validated = @"YES"; //
            if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Profile Validation Failed! Please provide valid contact informations such as address, city, state and contact number details."]) {
                [[me usr] setObject:validated forKey:@"validated"];
              //  validationBadge.highlighted = NO;
            }
        }
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av setTag:9];
        
        //prompt = NO;
       // serve *targ = [serve new];
        //targ.Delegate = self;
        //targ.tagName = @"GetMemberTargusScoresForBank";
        //[targ getTargus];
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
       
        NSLog(@"%@",dictProfileinfo);
        if (![[dictProfileinfo valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]]) {
            self.SavePhoneNumber=[dictProfileinfo valueForKey:@"ContactNumber"];
            self.phone.text=[dictProfileinfo valueForKey:@"ContactNumber"];
        }
        //NSLog(@"%@",dictProfileinfo);
        
        if (![[dictProfileinfo valueForKey:@"Address"] isKindOfClass:[NSNull class]]) {
            self.ServiceType=@"Address";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Address"]];
            
            
        }
        else if(![[dictProfileinfo valueForKey:@"City"] isKindOfClass:[NSNull class]])
        {
            //NSLog(@"address%@",[sourceData objectForKey:@"Status"]);
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
            
            NSLog(@"should be encrypting password");
        }
        else if (![[dictProfileinfo valueForKey:@"FirstName"] isKindOfClass:[NSNull class]])
        {
            
            
            self.ServiceType=@"name";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
            //   zip.text=[dictProfileinfo objectForKey:@"UserName"];
            
        }
        else if (![[dictProfileinfo valueForKey:@"LastName"] isKindOfClass:[NSNull class]])
        {
            
            
            self.ServiceType=@"lastname";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"LastName"]];
            //   zip.text=[dictProfileinfo objectForKey:@"UserName"];
            
        }
        else if (![[dictProfileinfo valueForKey:@"UserName"] isKindOfClass:[NSNull class]])
        {
            
            self.ServiceType=@"email";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
            //   zip.text=[dictProfileinfo objectForKey:@"UserName"];
            
        }
        else if (![[dictProfileinfo valueForKey:@"RecoveryMail"] isKindOfClass:[NSNull class]])
        {
            
            
            self.ServiceType=@"recovery";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"RecoveryMail"]];
            //   zip.text=[dictProfileinfo objectForKey:@"UserName"];
            
        }
        //RecoveryMail
        else if (![[dictProfileinfo valueForKey:@"Password"] isKindOfClass:[NSNull class]])
        {
            
            self.ServiceType=@"pwd";
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Password"]];
            //   zip.text=[dictProfileinfo objectForKey:@"UserName"];
            
        }
       
       


    }
}
#pragma mark - password encryption
-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue{
    
    //20nov
    if([self.ServiceType isEqualToString:@"Address"])
    {
        self.ServiceType=@"City";
        NSLog(@"address%@",[sourceData objectForKey:@"Status"]);
        
        NSArray*arr=[[sourceData objectForKey:@"Status"] componentsSeparatedByString:@"/"];
        if ([arr count]==2) {
            self.address_one.text=[arr objectAtIndex:0];
            self.address_two.text=[arr objectAtIndex:1];
        }
        else
        {
            self.address_one.text=[arr objectAtIndex:0];
        }
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

        
        
        //        password.text = decryptedPassword;
        //        [self getEncryptedPassword:password.text];
        //        NSLog(@"should be encrypting password");
    }
    else if([self.ServiceType isEqualToString:@"State"])
    {
        self.ServiceType=@"zip";
              //  self.state.text=[sourceData objectForKey:@"Status"];
        
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
        //        password.text = decryptedPassword;
        //        [self getEncryptedPassword:password.text];
        //        NSLog(@"should be encrypting password");
    }
    else  if ([self.ServiceType isEqualToString:@"zip"])
    {
        self.ServiceType=@"name";
        
        self.zip.text=[sourceData objectForKey:@"Status"];
       // NSLog(@"%@",self.zip.text);
        //NSLog(@"zipcode %@",[sourceData objectForKey:@"Status"]);
        
        if (![[dictProfileinfo objectForKey:@"FirstName"] isKindOfClass:[NSNull class]]) {
            
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"FirstName"]];
        }
        
        //   zip.text=[sInfoDic objectForKey:@"UserName"];
        
    }
    else  if ([self.ServiceType isEqualToString:@"name"])
    {
        self.ServiceType=@"lastname";
        if ([[sourceData objectForKey:@"Status"] length]>0) {
            NSString* letterA=[[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];
            
            self.name.text=[NSString stringWithFormat:@"%@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]];
            NSLog(@"zipcode %@",[sourceData objectForKey:@"Status"]);
           
       
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
        
        
        //   zip.text=[sInfoDic objectForKey:@"UserName"];
        
    }
    }
    else  if ([self.ServiceType isEqualToString:@"lastname"])
    {
        self.ServiceType=@"email";
        if ([[sourceData objectForKey:@"Status"] length]>0) {
            NSString* letterA=[[[sourceData objectForKey:@"Status"] substringToIndex:1] uppercaseString];
            
            
            self.name.text=[self.name.text stringByAppendingString:[NSString stringWithFormat:@" %@%@",letterA,[[sourceData objectForKey:@"Status"] substringFromIndex:1]]];
            // self.zip.text=[sourceData objectForKey:@"Status"];
            NSLog(@"zipcode %@",[sourceData objectForKey:@"Status"]);

        }
        if (![[dictProfileinfo objectForKey:@"UserName"] isKindOfClass:[NSNull class]]) {
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"UserName"]];
            
        }
        
        //   zip.text=[sInfoDic objectForKey:@"UserName"];
        
    }
    else  if ([self.ServiceType isEqualToString:@"email"])
    {
       
        self.email.text=[sourceData objectForKey:@"Status"];
        NSLog(@"zipcode %@",[sourceData objectForKey:@"Status"]);
        
        
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
        
        //   zip.text=[sInfoDic objectForKey:@"UserName"];
        
    }
    //RecoveryMail
    else if ([self.ServiceType isEqualToString:@"recovery"])
    {
        self.ServiceType=@"pwd";
        self.recovery_email.text=[NSString stringWithFormat:@"%@",[sourceData objectForKey:@"Status"]];
        if ([self.recovery_email.text isKindOfClass:[NSNull class]]) {
            self.recovery_email.text=@"";
        }
        // self.zip.text=[sourceData objectForKey:@"Status"];
        NSLog(@"zipcode %@",[sourceData objectForKey:@"Status"]);
        
        
        if (![[dictProfileinfo objectForKey:@"Password"] isKindOfClass:[NSNull class]]) {
            
            
            Decryption *decry = [[Decryption alloc] init];
            decry.Delegate = self;
            decry->tag = [NSNumber numberWithInteger:2];
            [decry getDecryptionL:@"GetDecryptedData" textString:[dictProfileinfo objectForKey:@"Password"]];
        }
        
        
        //   zip.text=[sInfoDic objectForKey:@"UserName"];
        
    }
    
    //name.text =[[NSString alloc]initWithFormat:@"%@ %@",[[me usr] valueForKey:@"firstName"],[[me usr] valueForKey:@"lastName"]];
    else if([self.ServiceType isEqualToString:@"pwd"])
    {
        NSLog(@"%@",[sourceData objectForKey:@"Status"]);
        self.password.text=[sourceData objectForKey:@"Status"];
    
        [spinner stopAnimating];
        [spinner setHidden:YES];
    }
    
    
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
