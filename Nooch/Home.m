//
//  Home.m
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "Home.h"
#import "Register.h"
#import "InitSliding.h"
#import "ECSlidingViewController.h"
#import "TransferPIN.h"
#import "ReEnterPin.h"
#import "ProfileInfo.h"
#import "serve.h"
#import "iCarousel.h"
#import "UIImageView+WebCache.h"
#import "HowMuch.h"
#import <QuartzCore/QuartzCore.h>
#import "knoxWeb.h"
#import <AddressBook/AddressBook.h>

#define kButtonType     @"transaction_type"
#define kButtonTitle    @"button_title"
#define kButtonColor    @"button_background_color"

NSMutableURLRequest *request;
@interface Home ()
@property(nonatomic,strong) NSMutableArray*arrRecords;
@property(nonatomic,strong) NSArray *transaction_types;
@property(nonatomic,strong) UIButton *balance;
@property(nonatomic,strong) UITableView *news_feed;
@property(nonatomic,strong) FAImageView *close;
@property(nonatomic,strong) UIView *popup;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIView *suspended;
@property(nonatomic,strong) UIView *profile_incomplete;
@property(nonatomic,strong) UIView *phone_incomplete;
@property(nonatomic,strong) UIView *phone_unverified;
@property(nonatomic,strong) iCarousel *carousel;

@end

@implementation Home
@synthesize arrRecords;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge void *)(self));
     [self address_book];
	// Do any additional setup after loading the view.
    
    nav_ctrl = self.navigationController;
    [ self.navigationItem setLeftBarButtonItem:Nil];
    
   // self.favorites = [NSMutableArray new];
    
    user = [NSUserDefaults standardUserDefaults];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[assist shared]isPOP];
    self.transaction_types = @[
                               @{kButtonType: @"send_request",
                                 kButtonTitle: @"Send or Request",
                                 kButtonColor: [UIColor clearColor]},
                               
                               @{kButtonType: @"pay_in_person",
                                 kButtonTitle: @"Pay in Person",
                                 kButtonColor: [UIColor clearColor]},
                               
                               @{kButtonType: @"donate",
                                 kButtonTitle: @"Donate to a Cause",
                                 kButtonColor: [UIColor clearColor]}
                               ];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

//    self.popup = [UIView new];
//    [self.popup setStyleId:@"news_popup"];
    
//    self.news_feed = [UITableView new];
//    [self.news_feed setDelegate:self];
//    [self.news_feed setDataSource:self];
//    [self.news_feed setStyleId:@"news_feed"];
//    self.news_feed.clipsToBounds = YES;
//    self.news_feed.layer.masksToBounds = YES;
//    [self.popup addSubview:self.news_feed];
    
//    self.close = [[FAImageView alloc] initWithFrame:CGRectMake(262.f, 35.f, 30.f, 40.f)];
//    self.close.image = nil;
    //[self.close setBackgroundColor:[UIColor whiteColor]];
 //   [self.close setDefaultIconIdentifier:@"fa-caret-up"];
    
//    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
//    [tap addTarget:self action:@selector(hide_news)];
//    [self.view addGestureRecognizer:tap];
    
    UIButton *top_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [top_button setStyleClass:@"button_blue"];
    
    UIButton *mid_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *bot_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    float height = [[UIScreen mainScreen] bounds].size.height;
    height -= 150; height /= 3;
    CGRect button_frame = CGRectMake(20.00, 270.00, 280, height);
    [top_button setFrame:button_frame];
    button_frame.origin.y += height+20; [mid_button setFrame:button_frame];
    button_frame.origin.y = 350; [bot_button setFrame:button_frame];
    
    [top_button addTarget:self action:@selector(send_request) forControlEvents:UIControlEventTouchUpInside];
//  [mid_button addTarget:self action:@selector(pay_in_person) forControlEvents:UIControlEventTouchUpInside];
//  [bot_button addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    
    [top_button setTitle:[[self.transaction_types objectAtIndex:0] objectForKey:kButtonTitle] forState:UIControlStateNormal];
//  [mid_button setTitle:[[self.transaction_types objectAtIndex:1] objectForKey:kButtonTitle] forState:UIControlStateNormal];
//  [bot_button setTitle:[[self.transaction_types objectAtIndex:2] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    
    [self.view addSubview:top_button];
    
    NSMutableDictionary *loadInfo;
    //if user has autologin set bring up their data, otherwise redirect to the tutorial/login/signup flow
    if ([core isAlive:[self autoLogin]]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationPush"]intValue]==1) {
            ProfileInfo *prof = [ProfileInfo new];
            [nav_ctrl pushViewController:prof animated:YES];
            [self.slidingViewController resetTopView];
        }
        me = [core new];
        [user removeObjectForKey:@"Balance"];
        loadInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:[self autoLogin]];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"MemberId"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"UserName"] forKey:@"UserName"];
        [me birth];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [user removeObjectForKey:@"Balance"];
        Register*reg=[Register new];
        [nav_ctrl pushViewController:reg animated:NO];
        return;
    }
    
    //if they have required immediately turned on or haven't selected the option yet, redirect them to PIN screen
    if (![user objectForKey:@"requiredImmediately"])
    {
        ReEnterPin*pin=[ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
    }
    else if([[user objectForKey:@"requiredImmediately"] boolValue])
    {
        ReEnterPin*pin=[ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
    }
   
    serve *fb = [serve new];
    [fb setDelegate:self];
    [fb setTagName:@"fb"];
    if ([user objectForKey:@"facebook_id"]) {
        [fb storeFB:[user objectForKey:@"facebook_id"]];
    }
    
}
void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
   
    NSMutableArray*additions = [[NSMutableArray alloc]init];
   // ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for(int i=0; i<nPeople; i++)
    {
        NSMutableDictionary *curContact=[[NSMutableDictionary alloc] init];
        ABRecordRef person=CFArrayGetValueAtIndex(people, i);
        NSString *contacName = [[NSMutableString alloc] init];
        contacName =(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *firstName = [[NSString alloc] init];
        NSString *lastName = [[NSString alloc] init];
        firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if((__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)) {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)]];
            lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        }
        NSData *contactImage;
        if(ABPersonHasImageData(person) > 0 ) {
            contactImage = (__bridge NSData *)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail));
        }
        else {
            contactImage = UIImageJPEGRepresentation([UIImage imageNamed:@"profile_picture.png"], 1);
        }
        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSString *emailId = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailInfo, 0);
        if(emailId != NULL) {
            [curContact setObject:emailId forKey:@"UserName"]; [curContact setObject:emailId forKey:@"emailAddy"];
        }
        if(contacName != NULL)  [curContact setObject:contacName forKey:@"Name"];
        if(firstName != NULL) [curContact setObject:firstName forKey:@"FirstName"];
        if(lastName != NULL)  [curContact setObject:lastName forKey:@"LastName"];
        NSLog(@"%@",contactImage);
        [curContact setObject:contactImage forKey:@"image"];
        [curContact setObject:@"YES" forKey:@"addressbook"];
        NSLog(@"%@",curContact);
        NSString *phone,*phone2,*phone3;
        if(ABMultiValueGetCount(phoneNumber)> 0)
            phone =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 0));
        
        if(ABMultiValueGetCount(phoneNumber)> 1) {
            phone2=  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 1));
            phone2 = [phone2 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone2 length])];
            [curContact setObject:phone2 forKey:@"phoneNo2"];
        }
        if(ABMultiValueGetCount(phoneNumber)> 2) {
            phone3 =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,2));
            phone3 = [phone3 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone3 length])];
            [curContact setObject:phone3 forKey:@"phoneNo3"];
        }
        if(phone == NULL && (emailId == NULL || [emailId rangeOfString:@"facebook"].location != NSNotFound)) {
            [additions addObject:curContact];
        }else if( contacName == NULL) {
        }
        else {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            if([strippedNumber length] == 11){
                strippedNumber = [strippedNumber substringFromIndex:1];
            }
            if(strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
            [additions addObject:curContact];
        }
    }
    [[assist shared] SaveAssos:additions.mutableCopy];
    NSLog(@"ginto%d",[additions count]);
    NSMutableArray *get_ids_input = [NSMutableArray new];
    for (NSDictionary *person in additions) {
        NSMutableDictionary *person_input = [NSMutableDictionary new];
        [person_input setObject:@"" forKey:@"memberId"];
        if (person[@"phoneNo"]) [person_input setObject:person[@"phoneNo"] forKey:@"phoneNo"];
        if (person[@"emailAddy"]) [person_input setObject:person[@"emailAddy"] forKey:@"emailAddy"];
        else [person_input setObject:@"" forKey:@"emailAddy"];
        if (person[@"phoneNo2"]) [person_input setObject:person[@"phoneNo2"] forKey:@"phoneNo2"];
        if (person[@"phoneNo3"]) [person_input setObject:person[@"phoneNo3"] forKey:@"phoneNo3"];
        [get_ids_input addObject:person_input];
    }
    
    
    CFRelease(people);
    CFRelease(addressBook);    NSLog(@"Recevied notification");
    
}
-(void)dismiss_suspended_alert {
    [self.suspended removeFromSuperview];
    CGRect rect= self.profile_incomplete.frame;
    rect.origin.y-=70;
    self.profile_incomplete.frame=rect;
    
    CGRect rect2= self.phone_incomplete.frame;
    rect2.origin.y-=70;
    self.phone_incomplete.frame=rect2;
}
-(void)address_book  {
    [additions removeAllObjects];
     additions = [[NSMutableArray alloc]init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for(int i=0; i<nPeople; i++)
    {
        NSMutableDictionary *curContact=[[NSMutableDictionary alloc] init];
        ABRecordRef person=CFArrayGetValueAtIndex(people, i);
        NSString *contacName = [[NSMutableString alloc] init];
        contacName =(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *firstName = [[NSString alloc] init];
        NSString *lastName = [[NSString alloc] init];
        firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if((__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)) {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)]];
            lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        }
        NSData *contactImage;
        if(ABPersonHasImageData(person) > 0 ) {
            contactImage = (__bridge NSData *)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail));
        }
        else {
            contactImage = UIImageJPEGRepresentation([UIImage imageNamed:@"profile_picture.png"], 1);
        }
        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSString *emailId = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailInfo, 0);
        if(emailId != NULL) {
            [curContact setObject:emailId forKey:@"UserName"]; [curContact setObject:emailId forKey:@"emailAddy"];
        }
        if(contacName != NULL)  [curContact setObject:contacName forKey:@"Name"];
        if(firstName != NULL) [curContact setObject:firstName forKey:@"FirstName"];
        if(lastName != NULL)  [curContact setObject:lastName forKey:@"LastName"];
        NSLog(@"%@",contactImage);
        [curContact setObject:contactImage forKey:@"image"];
        [curContact setObject:@"YES" forKey:@"addressbook"];
          NSLog(@"%@",curContact);
        NSString *phone,*phone2,*phone3;
        if(ABMultiValueGetCount(phoneNumber)> 0)
            phone =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 0));
        
        if(ABMultiValueGetCount(phoneNumber)> 1) {
            phone2=  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 1));
            phone2 = [phone2 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone2 length])];
            [curContact setObject:phone2 forKey:@"phoneNo2"];
        }
        if(ABMultiValueGetCount(phoneNumber)> 2) {
            phone3 =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,2));
            phone3 = [phone3 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone3 length])];
            [curContact setObject:phone3 forKey:@"phoneNo3"];
        }
        if(phone == NULL && (emailId == NULL || [emailId rangeOfString:@"facebook"].location != NSNotFound)) {
            [additions addObject:curContact];
        }else if( contacName == NULL) {
        }
        else {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            if([strippedNumber length] == 11){
                strippedNumber = [strippedNumber substringFromIndex:1];
            }
            if(strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
            [additions addObject:curContact];
        }
    }
    [[assist shared] SaveAssos:additions.mutableCopy];
    NSMutableArray *get_ids_input = [NSMutableArray new];
    for (NSDictionary *person in additions) {
        NSMutableDictionary *person_input = [NSMutableDictionary new];
        [person_input setObject:@"" forKey:@"memberId"];
        if (person[@"phoneNo"]) [person_input setObject:person[@"phoneNo"] forKey:@"phoneNo"];
        if (person[@"emailAddy"]) [person_input setObject:person[@"emailAddy"] forKey:@"emailAddy"];
        else [person_input setObject:@"" forKey:@"emailAddy"];
        if (person[@"phoneNo2"]) [person_input setObject:person[@"phoneNo2"] forKey:@"phoneNo2"];
        if (person[@"phoneNo3"]) [person_input setObject:person[@"phoneNo3"] forKey:@"phoneNo3"];
        [get_ids_input addObject:person_input];
    }
   
    
    CFRelease(people);
    CFRelease(addressBook);
}

-(void)getAddressBookContacts{
    
        CFErrorRef err;
    
    ABAddressBookRef addressBook =  ABAddressBookCreateWithOptions(NULL, &err);

    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    
    if (accessGranted) {
        
        NSArray *thePeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        // Do whatever you need with thePeople...
        NSLog(@"%@",thePeople);
       arrRecords=[[NSMutableArray alloc]init];
        NSMutableArray*arremailRecords=[[NSMutableArray alloc]init];
        for (int i=0; i<[thePeople count]; i++) {
            ABMutableMultiValueRef Emailref = ABRecordCopyValue((__bridge ABRecordRef)([thePeople objectAtIndex:i]), kABPersonEmailProperty);
          
            
            CFIndex Count = ABMultiValueGetCount(Emailref);
            NSLog(@"%ld",Count);
            for(int k = 0; k < Count; k++)
            {
                
                
                CFStringRef EmailValue = ABMultiValueCopyValueAtIndex( Emailref, k );
                
                CFStringRef EmailValueLabel = ABMultiValueCopyLabelAtIndex(Emailref, k);
                CFStringRef EmailValueLocalizedLabel = ABAddressBookCopyLocalizedLabel( EmailValueLabel );
              
                
                [arremailRecords addObject:(NSString *)CFBridgingRelease(EmailValue)];
                NSLog(@"%@",EmailValue);
                NSLog(@"%@",EmailValueLocalizedLabel);
            
                CFRelease(EmailValueLocalizedLabel);
                CFRelease(EmailValue);
            }
            UIImage*imgData=nil;
            
            imgData =[self imageForContact:(__bridge ABRecordRef)([thePeople objectAtIndex:i])];
            NSLog(@"%@",imgData);
            imgData=nil;
            NSLog(@"%@",arremailRecords);
            
        }
       
        
    }
}
- (UIImage*)imageForContact: (ABRecordRef)contactRef {
    UIImage *img = nil;
    
    // can't get image from a ABRecordRef copy
    ABRecordID contactID = ABRecordGetRecordID(contactRef);
    CFErrorRef err;
    
    ABAddressBookRef addressBook =  ABAddressBookCreateWithOptions(NULL, &err);
    
    ABRecordRef origContactRef = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
    
    if (ABPersonHasImageData(origContactRef)) {
        NSData *imgData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(origContactRef, kABPersonImageFormatOriginalSize);
        img = [UIImage imageWithData: imgData];
        
        [imgData release];
    }
    
    CFRelease(addressBook);
    
    return img;
}
-(void)contact_support
{
    if (![MFMailComposeViewController canSendMail]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have an email account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor=[UIColor whiteColor];
    
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

-(void)dismiss_profile_unvalidated {
    [self.profile_incomplete removeFromSuperview];
   
    
    CGRect rect2= self.phone_incomplete.frame;
    rect2.origin.y-=70;
    self.phone_incomplete.frame=rect2;
}
-(void)dismiss_phone_unvalidated {
    [self.phone_unverified removeFromSuperview];
}
-(void)go_profile
{
    ProfileInfo *info = [ProfileInfo new];
    [self.navigationController pushViewController:info animated:YES];
}

- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    int bannerAlert=0;
    if ([[user objectForKey:@"Status"] isEqualToString:@"Suspended"]) {
        bannerAlert++;
        [self.suspended removeFromSuperview];
        self.suspended = [UIView new];
        [self.suspended setStyleId:@"suspended_home"];

        UILabel *sus_header = [UILabel new];
        [sus_header setStyleClass:@"banner_header"];
        [sus_header setText:@"Account Suspended"];
        [self.suspended addSubview:sus_header];

        UILabel *sus_info = [UILabel new];
        [sus_info setStyleClass:@"banner_info"];
        [sus_info setNumberOfLines:0];
        [sus_info setText:@"Your account will have limited functionality while you are suspended."];
        [self.suspended addSubview:sus_info];

        UILabel *sus_exclaim = [UILabel new];
        [sus_exclaim setStyleClass:@"banner_alert_glyph"];
        [sus_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
        [self.suspended addSubview:sus_exclaim];
        
        UIButton *contact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [contact setStyleClass:@"go_now_text"];
        [contact setTitle:@"TAP TO CONTACT NOOCH" forState:UIControlStateNormal];
        [contact addTarget:self action:@selector(contact_support) forControlEvents:UIControlEventTouchUpInside];
        [self.suspended addSubview:contact];
        
        UIButton *dis = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [dis setStyleClass:@"dismiss_banner"];
        [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
        [dis addTarget:self action:@selector(dismiss_suspended_alert) forControlEvents:UIControlEventTouchUpInside];
        [self.suspended addSubview:dis];
        
        [self.view addSubview:self.suspended];
    }
    else if(![[user objectForKey:@"Status"] isEqualToString:@"Suspended"] && ![[user objectForKey:@"Status"] isEqualToString:@"Registered"]&& [[user valueForKey:@"Status"]isEqualToString:@"Active"]){
         [self.suspended removeFromSuperview];
        bannerAlert--;
    }
   else if (![[user valueForKey:@"Status"]isEqualToString:@"Active"]|| [[user objectForKey:@"Status"] isEqualToString:@"Registered"]) {
      
       [self.profile_incomplete removeFromSuperview];
        self.profile_incomplete = [UIView new];
       [self.profile_incomplete setStyleId:@"email_unverified"];
       if (bannerAlert>0) {
           CGRect rect= self.profile_incomplete.frame;
           rect.origin.y+=60;
           self.profile_incomplete.frame=rect;
       }
        bannerAlert++;
      
        UILabel *em = [UILabel new];
        [em setStyleClass:@"banner_header"];
        [em setText:@"Profile Not Validated"];
        [self.profile_incomplete addSubview:em];
        
        UILabel *em_exclaim = [UILabel new];
        [em_exclaim setStyleClass:@"banner_alert_glyph"];
        [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
        [self.profile_incomplete addSubview:em_exclaim];
        
        UILabel *em_info = [UILabel new];
        [em_info setStyleClass:@"banner_info"];
        [em_info setNumberOfLines:0];
        [em_info setText:@"Please complete your profile to unlock all features."];
        [self.profile_incomplete addSubview:em_info];
        
        UIButton *go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [go setStyleClass:@"go_now_text"];
        [go setTitle:@"TAP TO GO NOW" forState:UIControlStateNormal];
        [go addTarget:self action:@selector(go_profile) forControlEvents:UIControlEventTouchUpInside];
        [self.profile_incomplete addSubview:go];
        
        UIButton *dis = [UIButton buttonWithType:UIButtonTypeCustom];
        [dis setStyleClass:@"dismiss_banner"];
        [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
        [dis addTarget:self action:@selector(dismiss_profile_unvalidated) forControlEvents:UIControlEventTouchUpInside];
      
        [self.profile_incomplete addSubview:dis];
        
        [self.view addSubview:self.profile_incomplete];
    }
     else if ([[user valueForKey:@"Status"]isEqualToString:@"Active"]) {
         bannerAlert--;
         [self.profile_incomplete removeFromSuperview];
         [self.suspended removeFromSuperview];

     }
      if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
          [self.phone_incomplete removeFromSuperview];
          self.phone_incomplete = [UIView new];
          [self.phone_incomplete setStyleId:@"phone_unverified"];
          
          if (bannerAlert>0) {
              CGRect rect= self.phone_incomplete.frame;
              rect.origin.y+=60;
              self.phone_incomplete.frame=rect;
          }
           bannerAlert++;
          UILabel *em = [UILabel new];
          [em setStyleClass:@"banner_header"];
          [em setText:@"Phone Not Verified"];
          [self.phone_incomplete addSubview:em];
          
          UILabel *em_exclaim = [UILabel new];
          [em_exclaim setStyleClass:@"banner_alert_glyph"];
          [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
          [self.phone_incomplete addSubview:em_exclaim];
          
          UILabel *em_info = [UILabel new];
          [em_info setStyleClass:@"banner_info"];
          [em_info setNumberOfLines:0];
          [em_info setText:@"Please verify your phone to unlock all features."];
          [self.phone_incomplete addSubview:em_info];
          
          UIButton *go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
          [go setStyleClass:@"go_now_text"];
          [go setTitle:@"TAP TO GO NOW" forState:UIControlStateNormal];
          [go addTarget:self action:@selector(go_profile) forControlEvents:UIControlEventTouchUpInside];
          [self.phone_incomplete addSubview:go];
          
          UIButton *dis = [UIButton buttonWithType:UIButtonTypeCustom];
          [dis setStyleClass:@"dismiss_banner"];
          [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
          [dis addTarget:self action:@selector(dismiss_phone_unvalidated) forControlEvents:UIControlEventTouchUpInside];
          
          [self.phone_incomplete addSubview:dis];
          
          [self.view addSubview:self.phone_incomplete];
      }
      else{
          [self.phone_incomplete removeFromSuperview];
      }
    [_carousel removeFromSuperview];
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 50, 320, 175)];
    _carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _carousel.type = iCarouselTypeCylinder;
    
    [_carousel setNeedsLayout];
    _carousel.delegate = self;
    _carousel.dataSource = self;
    [self.view addSubview:_carousel];
    
    
    if (![[assist shared]isPOP]) {
        self.slidingViewController.panGesture.enabled=YES;
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
        
        //location
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
        
    }
    [[assist shared] setRequestMultiple:NO];
 
    [[assist shared]setArray:nil];
    
  
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Nooch"];

      if (![[assist shared]isPOP]) {
          if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
              [self.navigationItem setRightBarButtonItem:Nil];
              UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:self.balance];
              [self.navigationItem setRightBarButtonItem:funds];
          }
          else
          {
              UIActivityIndicatorView*act=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
              [act setFrame:CGRectMake(14, 5, 20, 20)];
              [act startAnimating];
              
              UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:act];
              [self.navigationItem setRightBarButtonItem:funds];
          }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
//        if (timerHome==nil) {
//             timerHome=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLoader) userInfo:nil repeats:YES];
//        }
    
    if ([[user objectForKey:@"logged_in"] isKindOfClass:[NSNull class]]) {
        //push login
        return;
    }
    if ([[assist shared]needsReload]) {
       
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        
        self.hud.delegate = self;
        self.hud.labelText = @"Loading Your Nooch Account";
        [self.hud showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
            serve *serveOBJ=[serve new ];
            [serveOBJ setTagName:@"sets"];
            [serveOBJ getSettings];
        }
        if ([[assist shared]needsReload]) {
            [[assist shared]setneedsReload:NO];
            serve *banks = [serve new];
            banks.Delegate = self;
            banks.tagName = @"banks";
            [banks getBanks];
        }
    }
    else
    {
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    
   // if ([[user valueForKey:@"Status"]isEqualToString:@"Active"]) {
        //do carousel
        [self.view addSubview:_carousel];
        [_carousel reloadData];
        // [favorites removeAllObjects];
        serve *favoritesOBJ = [serve new];
        [favoritesOBJ setTagName:@"favorites"];
        [favoritesOBJ setDelegate:self];
        [favoritesOBJ get_favorites];
        //launch favorites call
//        
//    }
//    {
//        [favorites removeAllObjects];
//         [_carousel reloadData];
//    }
}

#pragma mark - iCarousel methods

-(void)scrollCarouselToIndex:(NSNumber *)index
{
    [_carousel scrollToItemAtIndex:index.intValue animated:YES];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [favorites count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = nil;
    UILabel*name=nil;;
    NSDictionary *favorite = [favorites objectAtIndex:index];
    //create new view if no view is available for recycling
    if (view == nil)
    {
		view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200, 175)];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 25, 100, 100)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.borderColor = kNoochBlue.CGColor;
        imageView.layer.borderWidth = 1;
        imageView.layer.cornerRadius = 50;
        if (favorite[@"MemberId"]) {
            [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://192.203.102.254/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                      placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        }
        else if (favorite[@"image"]){
            [imageView setImage:[UIImage imageWithData:favorite[@"image"]]];
            
        }
       
        [imageView setClipsToBounds:YES];
        name=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 125.0f, 200, 20)];
        name.textColor=[UIColor blackColor];
        name.textAlignment=NSTextAlignmentCenter;
        [name setFont:[UIFont fontWithName:@"Roboto-Bold" size:15]];
        name.text= [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]];
        name.backgroundColor=[UIColor whiteColor];
        [view addSubview:imageView];
        [view addSubview:name];

    }
    else
    {
        imageView = (UIImageView *)[view viewWithTag:1];
    }
    
    //set image
    
    return view;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
    if(carousel.scrolling == NO)
    {
        NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
        
        
        if ([[assist shared]getSuspended]) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"For security your account has been suspended for 24 hours.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com for more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
            [alert setTag:50];
            [alert show];
            return;
        }
        
        if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please Verify Your Email" message:@"Terribly sorry, but before you send money, please just confirm your email address by clicking the link we sent to the email address you used to sign up." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
            return;
        }
        
        if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Help Us Keep Nooch Safe" message:@"Please take 1 minute to validate your identity by completing your Nooch profile (just 4 fields)." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
            [alert setTag:147];
            [alert show];
            return;
        }
        
        if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Blame Our Lawyers" message:@"To keep Nooch safe, we ask all users to verify your phone number before before sending money.\n \nIf you've already added your phone number, just respond 'Go' to the text message we sent." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Add Phone", nil];
            [alert setTag:148];
            [alert show];
            return;
        }
        
        if ( ![[[NSUserDefaults standardUserDefaults]
                objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
            UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Connect Your Bank" message:@"Adding a bank account to fund Nooch payments is lightening quick. (You don't have to type a routing or account number!)  Would you like to take care of this now?." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
            [set setTag:201];
            [set show];
            return;
        }
        
        NSMutableDictionary *favorite = [NSMutableDictionary new];
        [favorite addEntriesFromDictionary:[favorites objectAtIndex:index]];
        if (favorite[@"MemberId"]) {
            [favorite setObject:[NSString stringWithFormat:@"https://192.203.102.254/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]] forKey:@"Photo"];
            NSLog(@"%@",favorite);
            isFromHome=YES;
            HowMuch *trans = [[HowMuch alloc] initWithReceiver:favorite];
            [self.navigationController pushViewController:trans animated:YES];
            
        }
        else if (favorite[@"UserName"]){
            emailID=favorite[@"UserName"];
            
            serve *emailCheck = [serve new];
            emailCheck.Delegate = self;
            emailCheck.tagName = @"emailCheck";
            [emailCheck getMemIdFromuUsername:[favorite[@"UserName"] lowercaseString]];
        }
       
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
      }
//        case iCarouselOptionArc:
//        {
//            return 180;
//        }
     case iCarouselOptionRadius:
       {
           return 160;
       }
        case iCarouselOptionSpacing:
        {
            return value * 1.3;
        }
        default:
        {
            return value;
        }
    }    
}

- (void)myTask {
	// This just increases the progress indicator in a loop
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		self.hud.progress = progress;
		usleep(50000);
	}
}

#pragma mark - news feed
//-(void)show_news
//{
//    [self.balance removeTarget:self action:@selector(show_news) forControlEvents:UIControlEventTouchUpInside];
//    [self.balance addTarget:self action:@selector(hide_news) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.navigationController.view addSubview:self.popup];
//    [self.navigationController.view addSubview:self.close];
    
//    [self.news_feed reloadData];
//}

//-(void)hide_news
//{
//    [self.balance removeTarget:self action:@selector(hide_news) forControlEvents:UIControlEventTouchUpInside];
//    [self.balance addTarget:self action:@selector(show_news) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.popup removeFromSuperview];
//    [self.close removeFromSuperview];
//}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    // Configure the cell...
    
    UILabel *test = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 150, 30)];
    [test setFont:[UIFont fontWithName:@"Roboto-Regular" size:12]];
    [test setBackgroundColor:[UIColor clearColor]];
    [test setNumberOfLines:0];
    [test setText:@"Paid you $1bil with the force, Yoda did"];
    [cell.contentView addSubview:test];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(70, 45, 150, 20)];
    [time setFont:[UIFont fontWithName:@"Roboto-Light" size:10]];
    [time setText:@"2 days ago"];
    [time setTextColor:kNoochGrayLight];
    [cell.contentView addSubview:time];
    
    return cell;
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showMenu
{
    [[assist shared]setneedsReload:NO];
    [self.slidingViewController anchorTopViewTo:ECRight];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag==147 || alertView.tag==148) && buttonIndex==1) {
        ProfileInfo *prof = [ProfileInfo new];
        [nav_ctrl pushViewController:prof animated:YES];
        [self.slidingViewController resetTopView];
    }
    
    else if (alertView.tag == 201){
        if (buttonIndex == 1) {
            knoxWeb *knox = [knoxWeb new];
            [nav_ctrl pushViewController:knox animated:YES];
            [self.slidingViewController resetTopView];
            // SHOULD GO TO THE KNOX UIWEBVIEW WITHIN THE 'SettingsOptions.m' 
        }
    }
    else if (alertView.tag == 50 && buttonIndex == 1)
    {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)send_request
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
   

    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"For security your account has been suspended for 24 hours.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com if you would like more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
        [alert setTag:50];
        [alert show];
        return;
    }
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please Verify Your Email" message:@"Terribly sorry, but before you can send money, please confirm your email address by clicking the link we sent to the email address you used to sign up." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
  
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Help Us Keep Nooch Safe" message:@"Please take 1 minute to verify your identity by completing your Nooch profile (just 4 fields)." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }
    
    if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Blame The Lawyers" message:@"To keep Nooch safe, we ask all users to verify a phone number before before sending money.\n \n If you've already added your phone number, just respond 'Go' to the text message we sent." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Add Phone", nil];
        [alert setTag:148];
        [alert show];
        return;
    }
  
    if ( ![[[NSUserDefaults standardUserDefaults]
        objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Connect Your Bank" message:@"Adding a bank account to fund Nooch payments is lightening quick. (You don't have to type a routing or account number!)\n \n Would you like to take care of this now?" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
        [set setTag:201];
        [set show];
        return;
    }
    
  
    if (NSClassFromString(@"SelectRecipient")) {
        
        Class aClass = NSClassFromString(@"SelectRecipient");
        id instance = [[aClass alloc] init];
        
        if ([instance isKindOfClass:[UIViewController class]]) {
            
            //[(UIViewController *)instance setTitle:@"Select Recipient"];
            [self.navigationController pushViewController:(UIViewController *)instance
                                                 animated:YES];
            //[self.navigationItem setTitle:@""];
        }
    }
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    [[assist shared]setlocationAllowed:NO];
    
    NSLog(@"Error : %@",error);
    if ([error code] == kCLErrorDenied){
        NSLog(@"Error : %@",error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [manager stopUpdatingLocation];
    
    CLLocationCoordinate2D loc = [newLocation coordinate];
    lat = [[[NSString alloc] initWithFormat:@"%f",loc.latitude] floatValue];
    lon = [[[NSString alloc] initWithFormat:@"%f",loc.longitude] floatValue];
    [[assist shared]setlocationAllowed:YES];
    serve*serveOBJ=[serve new];
    [serveOBJ UpDateLatLongOfUser:[[NSString alloc] initWithFormat:@"%f",loc.latitude] lng:[[NSString alloc] initWithFormat:@"%f",loc.longitude]];
    [locationManager stopUpdatingLocation];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"favorites"]) {
        NSError *error;
        favorites = [[NSMutableArray alloc]init];
        favorites = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"favorites %@",favorites);
        favorites=[favorites mutableCopy];
        if ([favorites count]==0) {
            [self FavoriteContactsProcessing];
            [_carousel reloadData];
        
            
        }else{
            favorites=[favorites mutableCopy];
            
            if ([favorites count]<5) {
               [self FavoriteContactsProcessing];
            }
            [_carousel reloadData];
        }
    
    }
    else if([tagName isEqualToString:@"emailCheck"]) {
        NSError* error;
        NSMutableDictionary *dictResult = [NSJSONSerialization
                                           JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                           options:kNilOptions
                                           error:&error];
        
        if([dictResult objectForKey:@"Result"] != [NSNull null]) {
            serve *getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberDetails";
            [getDetails getDetails:[dictResult objectForKey:@"Result"]];
        }
        else {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:emailID forKey:@"email"];
            [dict setObject:@"nonuser" forKey:@"nonuser"];
              isFromHome=YES;
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
            return;
        }
    }
    else if([tagName isEqualToString:@"getMemberDetails"]) {
        NSError* error;
        //[spinner stopAnimating];
       // [spinner setHidden:YES];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict=[NSJSONSerialization
         JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
         options:kNilOptions
         error:&error];
         isFromHome=YES;
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
        
    }

    else if ([tagName isEqualToString:@"getMemberIds"]) {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSMutableArray *temp2 = [[temp objectForKey:@"GetMemberIdsResult"] objectForKey:@"phoneEmailList"];
        NSMutableArray *AddressBookAdditions = [NSMutableArray new];
        for (NSDictionary *dict in temp2) {
            NSMutableDictionary *new = [NSMutableDictionary new];
            for (NSString *key in dict.allKeys) {
                if ([key isEqualToString:@"memberId"] && [dict[key] length] > 0)
                    [new setObject:dict[key] forKey:@"MemberId"];
                else if ([key isEqualToString:@"emailAddy"])
                    [new setObject:dict[key] forKey:@"UserName"];
                else
                    [new setObject:dict[key] forKey:key];
            }
            if (new[@"MemberId"])
                [AddressBookAdditions addObject:new];
        }
        NSLog(@"%@",AddressBookAdditions);
    }

    else if ([tagName isEqualToString:@"fb"]) {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"fb storing %@",temp);
    }
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"New Device Detected" message:@"It looks like you have logged in from a new device.  To protect your account, we will just log you out of all other devices." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [Alert show];
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        [timer invalidate];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        
        [nav_ctrl performSelector:@selector(reset)];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    if ([tagName isEqualToString:@"bDelete"]) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Bank Deleted" message:@"Your Bank Account was not verified for 21 days.\n \n Nooch has deleted your bank Account." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
    }

     else if ([tagName isEqualToString:@"banks"]) {
         
         NSError *error = nil;
         //bank Data
         NSMutableArray *bankResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
         [blankView removeFromSuperview];
         
         //Get Server Date info
          NSString *urlString = [NSString stringWithFormat:@"%@"@"/%@", @"https://192.203.102.254/NoochService/NoochService.svc", @"GetServerCurrentTime"];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@",urlString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                  NSHTTPURLResponse* urlResponse = nil;
        
         NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
       
        if (nil == urlResponse ) {
            if (error)
            {
                ServerDate=[NSDate date];
            }
        }else{
            
                    
               NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
                 NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                   ServerDate=[self dateFromString:[jsonObject valueForKey:@"Result"] ];
            
        }
     
     if ([bankResult count]>0) {
    
     if ([[[bankResult objectAtIndex:0] valueForKey:@"IsPrimary"] intValue]&& [[[bankResult objectAtIndex:0] valueForKey:@"IsVerified"] intValue]) {
     
     
     }
     else
     {
         if ([bankResult count]==2) {
             [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"AddBank"];
         }
         else
         {
             [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"AddBank"];
         }
         for (int i=0; i<[bankResult count]; i++) {
             NSString*datestr=[[bankResult objectAtIndex:i] valueForKey:@"ExpirationDate"];
             NSLog(@"%@",datestr);
             
             NSDate *addeddate = [self dateFromString:datestr];
             
             NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
             NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                 fromDate:addeddate
                                                                   toDate:ServerDate
                                                                  options:0];
             
             NSLog(@"%ld", (long)[components day]);
             if ([components day]>21) {
                 
                 
                 serve *bank = [serve new];
                 bank.tagName = @"bDelete";
                 bank.Delegate = self;
                 [bank deleteBank:[[bankResult objectAtIndex:i] valueForKey:@"BankAccountId"]];
             }
         }
     }}
     
     }
 
}
-(void)FavoriteContactsProcessing{
    [additions removeAllObjects];
    additions=nil;
    additions=[[NSMutableArray alloc]init];
    
    additions=[[[assist shared]assosAll] mutableCopy];
   // favorites = [[NSMutableArray alloc]init];
    for (int i = 0; i<[additions count] ;i++)
    {
        if ([favorites count]==5) {
            break;
        }
        else if(i>=[additions count]-1){
            i=0;
        }
        NSUInteger randomIndex = arc4random() % [additions  count];
        if ([favorites containsObject:[additions objectAtIndex:randomIndex]])
        {
            continue;
        }
        if ([[additions objectAtIndex:randomIndex] valueForKey:@"UserName"]) {
            [favorites  addObject:[additions objectAtIndex:randomIndex]];
        }

    }

}
#pragma mark- Date From String
- (NSDate*) dateFromString:(NSString*)aStr
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
   
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    
    NSLog(@"%@", aStr);
    NSDate   *aDate = [dateFormatter dateFromString:aStr];
    NSLog(@"%@", aDate);
    return aDate;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end