//
//  Home.m
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
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
#import <AddressBook/ABAddressBook.h>
#define kButtonType     @"transaction_type"
#define kButtonTitle    @"button_title"
#define kButtonColor    @"button_background_color"

NSMutableURLRequest *request;
@interface Home ()
@property(nonatomic,strong) NSMutableArray*arrRecords;
@property(nonatomic,strong) NSArray *transaction_types;
@property(nonatomic,strong) UIButton *balance;
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

    nav_ctrl = self.navigationController;
    [ self.navigationItem setLeftBarButtonItem:Nil];
    
    user = [NSUserDefaults standardUserDefaults];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[assist shared]isPOP];
    self.transaction_types = @[
                               @{kButtonType: @"send_request",
                                 kButtonTitle: @"   Search For More Friends",
                                 kButtonColor: [UIColor clearColor]},
                               
                               @{kButtonType: @"pay_in_person",
                                 kButtonTitle: @"Pay in Person",
                                 kButtonColor: [UIColor clearColor]},
                               
                               @{kButtonType: @"donate",
                                 kButtonTitle: @"Donate to a Cause",
                                 kButtonColor: [UIColor clearColor]}
                               ];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .25;
    [self.view addSubview:backgroundImage];
    
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    
    NSMutableDictionary *loadInfo;
    if ([core isAlive:[self autoLogin]])
    {
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
    }
    else
    {
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

void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    NSMutableArray*additions = [[NSMutableArray alloc]init];
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for(int i = 0; i < nPeople; i++)
    {
        NSMutableDictionary *curContact=[[NSMutableDictionary alloc] init];
        ABRecordRef person=CFArrayGetValueAtIndex(people, i);
        
        NSString *contacName;
        
        CFTypeRef contacNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        contacName = [[NSString stringWithFormat:@"%@", contacNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (contacNameValue)
        CFRelease(contacNameValue);

        NSString *firstName ;
        NSString *lastName;
        
        //Get FirstName Ref
        CFTypeRef firstNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        firstName = [[NSString stringWithFormat:@"%@", firstNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
         if (firstNameValue)
        CFRelease(firstNameValue);
        
        //Get LastName Ref
        CFTypeRef LastNameValue = ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        if (LastNameValue)
        {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", LastNameValue]];
            
            lastName = [[NSString stringWithFormat:@"%@", LastNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (LastNameValue)
            CFRelease(LastNameValue);
        }
        NSData *contactImage;
        //Get Contact Image Ref
        if (ABPersonHasImageData(person) > 0 )
        {
            CFTypeRef contactImageValue = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
            contactImage = (__bridge NSData *)(contactImageValue);
            [curContact setObject:contactImage forKey:@"image"];
            if (contactImageValue)
            CFRelease(contactImageValue);
        }
        else
        {
            contactImage = UIImageJPEGRepresentation([UIImage imageNamed:@"profile_picture.png"], 1);
            [curContact setObject:contactImage forKey:@"image"];
        }
        
        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);
        //Get emailInfo Ref
        CFTypeRef emailIdValue = ABMultiValueCopyValueAtIndex(emailInfo, 0);
        NSString *emailId = [[NSString stringWithFormat:@"%@", emailIdValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (emailIdValue) {
            CFRelease(emailIdValue);
        }
        if (emailInfo) {
            CFRelease(emailInfo);
        }
        
        if(emailId != NULL) {
            [curContact setObject:emailId forKey:@"UserName"];
            [curContact setObject:emailId forKey:@"emailAddy"];
        }
        if(contacName != NULL)  [curContact setObject:contacName forKey:@"Name"];
        if(firstName != NULL) [curContact setObject:firstName forKey:@"FirstName"];
        if(lastName != NULL)  [curContact setObject:lastName forKey:@"LastName"];
        
        [curContact setObject:@"YES" forKey:@"addressbook"];
        
        NSString *phone,*phone2,*phone3;
        if (ABMultiValueGetCount(phoneNumber) > 0)
        {
            //Get phoneValue Ref
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 0);
            phone = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
             if (phoneValue)
            CFRelease(phoneValue);
        }
        
        if (ABMultiValueGetCount(phoneNumber) > 1)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 1);
            phone2 = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (phoneValue)
            CFRelease(phoneValue);
            
            phone2 = [phone2 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone2 length])];
            [curContact setObject:phone2 forKey:@"phoneNo2"];
        }
        
        if (ABMultiValueGetCount(phoneNumber) > 2)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 2);
            phone3 = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
             if (phoneValue)
            CFRelease(phoneValue);
            
            phone3 = [phone3 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone3 length])];
            [curContact setObject:phone3 forKey:@"phoneNo3"];
        }
        
        if (phone == NULL && (emailId == NULL || [emailId rangeOfString:@"facebook"].location != NSNotFound)) {
            [additions addObject:curContact];
        }
        else if( contacName == NULL) {
        }
        else {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            if([strippedNumber length] == 11) {
                strippedNumber = [strippedNumber substringFromIndex:1];
            }
            if(strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
            [additions addObject:curContact];
        }
        if (phoneNumber)
            CFRelease(phoneNumber);
    }
   
    [[assist shared] SaveAssos:additions.mutableCopy];
    
    NSLog(@"ginto%d",[additions count]);
    NSMutableArray * get_ids_input = [NSMutableArray new];
    for (NSDictionary * person in additions)
    {
        NSMutableDictionary * person_input = [NSMutableDictionary new];
        [person_input setObject:@"" forKey:@"memberId"];
        if (person[@"phoneNo"]) [person_input setObject:person[@"phoneNo"] forKey:@"phoneNo"];
        if (person[@"emailAddy"]) [person_input setObject:person[@"emailAddy"] forKey:@"emailAddy"];
        else [person_input setObject:@"" forKey:@"emailAddy"];
        if (person[@"phoneNo2"]) [person_input setObject:person[@"phoneNo2"] forKey:@"phoneNo2"];
        if (person[@"phoneNo3"]) [person_input setObject:person[@"phoneNo3"] forKey:@"phoneNo3"];
        [get_ids_input addObject:person_input];
    }
      if (people)
    CFRelease(people);
      if (addressBook)
    CFRelease(addressBook);
    NSLog(@"Recevied notification");
}

-(void)dismiss_suspended_alert
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.45];
    
    CGRect frame = self.suspended.frame;
    frame.origin.y = -58;
    [self.suspended setFrame:frame];
    
//    [self.suspended removeFromSuperview];
    CGRect rect= self.profile_incomplete.frame;
    rect.origin.y-=54;
    self.profile_incomplete.frame=rect;
    
    CGRect rect2 = self.phone_incomplete.frame;
    rect2.origin.y-=54;
    self.phone_incomplete.frame=rect2;
    [UIView commitAnimations];
}

-(void)dismiss_profile_unvalidated
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.45];
    
    CGRect frame = self.profile_incomplete.frame;
    frame.origin.y = -58;
    [self.profile_incomplete setFrame:frame];
    
    CGRect rect2 = self.phone_incomplete.frame;
    rect2.origin.y-=54;
    self.phone_incomplete.frame=rect2;

    [UIView commitAnimations];
    //[self.profile_incomplete removeFromSuperview];
}

-(void)dismiss_phone_unvalidated
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.45];
    
    CGRect frame = self.phone_incomplete.frame;
    frame.origin.y = -58;
    [self.phone_incomplete setFrame:frame];
    
    [UIView commitAnimations];
  // [self.phone_incomplete removeFromSuperview];
}

-(void)address_book
{
    [additions removeAllObjects];
    additions = [[NSMutableArray alloc]init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i = 0; i < nPeople; i++)
    {
        NSMutableDictionary *curContact=[[NSMutableDictionary alloc] init];
        ABRecordRef person=CFArrayGetValueAtIndex(people, i);
        
        NSString *contacName;
        
        CFTypeRef contacNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        contacName = [[NSString stringWithFormat:@"%@", contacNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (contacNameValue)
        CFRelease(contacNameValue);
        
        
        NSString *firstName ;
        NSString *lastName;
        
        //Get FirstName Ref
        CFTypeRef firstNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        firstName = [[NSString stringWithFormat:@"%@", firstNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (firstNameValue)
        CFRelease(firstNameValue);
        
        //Get LastName Ref
        CFTypeRef LastNameValue = ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        if(LastNameValue)
        {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", LastNameValue]];
        
            lastName = [[NSString stringWithFormat:@"%@", LastNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (LastNameValue)
            CFRelease(LastNameValue);
        }
        NSData *contactImage;
         //Get Contact Image Ref
        if (ABPersonHasImageData(person) > 0 )
        {
            CFTypeRef contactImageValue = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
            contactImage = (__bridge NSData *)(contactImageValue);
            [curContact setObject:contactImage forKey:@"image"];
             if (contactImageValue)
            CFRelease(contactImageValue);
            
        }
        else {
            contactImage = UIImageJPEGRepresentation([UIImage imageNamed:@"profile_picture.png"], 1);
            [curContact setObject:contactImage forKey:@"image"];
        }
        
        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);

        //Get emailInfo Ref
        CFTypeRef emailIdValue = ABMultiValueCopyValueAtIndex(emailInfo, 0);
        NSString *emailId = [[NSString stringWithFormat:@"%@", emailIdValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (emailIdValue) {
            CFRelease(emailIdValue);
        }
        if (emailInfo) {
             CFRelease(emailInfo);
        }
       
        if(emailId != NULL) {
            [curContact setObject:emailId forKey:@"UserName"]; [curContact setObject:emailId forKey:@"emailAddy"];
        }
        if(contacName != NULL)  [curContact setObject:contacName forKey:@"Name"];
        if(firstName != NULL) [curContact setObject:firstName forKey:@"FirstName"];
        if(lastName != NULL)  [curContact setObject:lastName forKey:@"LastName"];
        
        
        [curContact setObject:@"YES" forKey:@"addressbook"];
       
        NSString *phone,*phone2,*phone3;
        if (ABMultiValueGetCount(phoneNumber) > 0)
        {
             //Get phoneValue Ref
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 0);
            phone = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (phoneValue)
            CFRelease(phoneValue);
        }
        
        if (ABMultiValueGetCount(phoneNumber) > 1)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 1);
            phone2 = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (phoneValue)
            CFRelease(phoneValue);
           
            phone2 = [phone2 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone2 length])];
            [curContact setObject:phone2 forKey:@"phoneNo2"];
        }

        if (ABMultiValueGetCount(phoneNumber) > 2)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 2);
            phone3 = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
             if (phoneValue)
            CFRelease(phoneValue);
            
            phone3 = [phone3 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone3 length])];
            [curContact setObject:phone3 forKey:@"phoneNo3"];
        }

        if(phone == NULL && (emailId == NULL || [emailId rangeOfString:@"facebook"].location != NSNotFound)) {
            [additions addObject:curContact];
        }
        else if( contacName == NULL) {
        }
        else {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            if([strippedNumber length] == 11) {
                strippedNumber = [strippedNumber substringFromIndex:1];
            }
            if(strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
            [additions addObject:curContact];
        }
        if (phoneNumber)
       CFRelease(phoneNumber);
    }
    [[assist shared] SaveAssos:additions.mutableCopy];
    NSMutableArray *get_ids_input = [NSMutableArray new];
    for (NSDictionary *person in additions)
    {
        NSMutableDictionary *person_input = [NSMutableDictionary new];
        [person_input setObject:@"" forKey:@"memberId"];
        if (person[@"phoneNo"]) [person_input setObject:person[@"phoneNo"] forKey:@"phoneNo"];
        if (person[@"emailAddy"]) [person_input setObject:person[@"emailAddy"] forKey:@"emailAddy"];
        else [person_input setObject:@"" forKey:@"emailAddy"];
        if (person[@"phoneNo2"]) [person_input setObject:person[@"phoneNo2"] forKey:@"phoneNo2"];
        if (person[@"phoneNo3"]) [person_input setObject:person[@"phoneNo3"] forKey:@"phoneNo3"];
        [get_ids_input addObject:person_input];
    }
    if (people)
    CFRelease(people);
     if (addressBook)
    CFRelease(addressBook);
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

-(void)go_profile
{
    ProfileInfo *info = [ProfileInfo new];
    [self.navigationController pushViewController:info animated:YES];
}

- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDictionary *navbarTtlAts = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIColor whiteColor], UITextAttributeTextColor,
                                  Rgb2UIColor(19, 32, 38, .26), UITextAttributeTextShadowColor,
                                  [NSValue valueWithUIOffset:UIOffsetMake(0.0, -1.0)], UITextAttributeTextShadowOffset, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTtlAts];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(71, 8, 7, .4);
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes =
            @{NSShadowAttributeName: shadow };
    
    int bannerAlert = 0;

    if ([[user objectForKey:@"Status"] isEqualToString:@"Suspended"])
    {
        bannerAlert++;
        [self.suspended removeFromSuperview];
        self.suspended = [UIView new];
        [self.suspended setStyleId:@"suspended_home"];

        UILabel *sus_header = [UILabel new];
        [sus_header setStyleClass:@"banner_header"];
        sus_header.attributedText = [[NSAttributedString alloc] initWithString:@"Account Suspended"
                                                               attributes:textAttributes];
        [self.suspended addSubview:sus_header];

        UILabel *sus_info = [UILabel new];
        [sus_info setStyleClass:@"banner_info"];
        [sus_info setNumberOfLines:0];
        sus_info.attributedText = [[NSAttributedString alloc] initWithString:@"Your account will be limited while you are suspended."
                                                                    attributes:textAttributes];
        [self.suspended addSubview:sus_info];

        UILabel *sus_exclaim = [UILabel new];
        [sus_exclaim setStyleClass:@"banner_alert_glyph"];
        [sus_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
        [self.suspended addSubview:sus_exclaim];
        
        UIButton *contact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [contact setStyleClass:@"go_now_text"];
        [contact setTitle:@"TAP TO CONTACT NOOCH" forState:UIControlStateNormal];
        [contact setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
        contact.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [contact addTarget:self action:@selector(contact_support) forControlEvents:UIControlEventTouchUpInside];
        [self.suspended addSubview:contact];
        
        UIButton *dis = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [dis setStyleClass:@"dismiss_banner"];
        [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
        [dis addTarget:self action:@selector(dismiss_suspended_alert) forControlEvents:UIControlEventTouchUpInside];
        [self.suspended addSubview:dis];
        
        [self.view addSubview:self.suspended];
    }
    
    else if(![[user objectForKey:@"Status"] isEqualToString:@"Suspended"] && ![[user objectForKey:@"Status"] isEqualToString:@"Registered"] && [[user valueForKey:@"Status"]isEqualToString:@"Active"])
    {
        [self.suspended removeFromSuperview];
        bannerAlert--;
    }
    
    else if ([[user objectForKey:@"Status"] isEqualToString:@"Registered"])
    {
        [self.profile_incomplete removeFromSuperview];
        self.profile_incomplete = [UIView new];
        [self.profile_incomplete setStyleId:@"email_unverified"];
       
        if (bannerAlert > 0)
        {
           CGRect rect= self.profile_incomplete.frame;
           rect.origin.y+=54;
           self.profile_incomplete.frame=rect;
        }
        bannerAlert++;
      
        UILabel *em = [UILabel new];
        [em setStyleClass:@"banner_header"];
        em.attributedText = [[NSAttributedString alloc] initWithString:@"Profile Not Validated"
                                                                   attributes:textAttributes];
        [self.profile_incomplete addSubview:em];
        
        UILabel *em_exclaim = [UILabel new];
        [em_exclaim setStyleClass:@"banner_alert_glyph"];
        [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
        [self.profile_incomplete addSubview:em_exclaim];
        
        UILabel *em_info = [UILabel new];
        [em_info setStyleClass:@"banner_info"];
        [em_info setNumberOfLines:0];
        em_info.attributedText = [[NSAttributedString alloc] initWithString:@"Complete your profile to unlock all features."
                                                         attributes:textAttributes];
       
        [self.profile_incomplete addSubview:em_info];
        
        UIButton *go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [go setStyleClass:@"go_now_text"];
        [go setTitle:@"TAP TO FIX NOW" forState:UIControlStateNormal];
        [go setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
        go.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [go addTarget:self action:@selector(go_profile) forControlEvents:UIControlEventTouchUpInside];
        [self.profile_incomplete addSubview:go];
        
        UIButton *dis = [UIButton buttonWithType:UIButtonTypeCustom];
        [dis setStyleClass:@"dismiss_banner"];
        [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
        [dis addTarget:self action:@selector(dismiss_profile_unvalidated) forControlEvents:UIControlEventTouchUpInside];
      
        [self.profile_incomplete addSubview:dis];
        
        [self.view addSubview:self.profile_incomplete];
    }
    
    else if ([[user valueForKey:@"Status"]isEqualToString:@"Active"])
    {
        bannerAlert--;
        [self.profile_incomplete removeFromSuperview];
        [self.suspended removeFromSuperview];
    }
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] )
    {
          [self.phone_incomplete removeFromSuperview];
          self.phone_incomplete = [UIView new];
          [self.phone_incomplete setStyleId:@"phone_unverified"];
          
          if (bannerAlert > 0) {
              CGRect rect= self.phone_incomplete.frame;
              rect.origin.y+=54;
              self.phone_incomplete.frame=rect;
          }
          bannerAlert++;
        
          UILabel *em = [UILabel new];
          [em setStyleClass:@"banner_header"];
          em.attributedText = [[NSAttributedString alloc] initWithString:@"Phone Number Not Verified"
                                                              attributes:textAttributes];
          [self.phone_incomplete addSubview:em];
          
          UILabel *em_exclaim = [UILabel new];
          [em_exclaim setStyleClass:@"banner_alert_glyph"];
          [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-phone"]];
          [self.phone_incomplete addSubview:em_exclaim];
        
        UILabel *glyph_phone = [UILabel new];
        [glyph_phone setStyleClass:@"banner_alert_glyph_sm"];
        [glyph_phone setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation"]];
        [self.phone_incomplete addSubview:glyph_phone];
        
          UILabel *em_info = [UILabel new];
          [em_info setStyleClass:@"banner_info"];
          [em_info setNumberOfLines:0];
          em_info.attributedText = [[NSAttributedString alloc] initWithString:@"Please verify your phone - respond 'Go' to the SMS."
                                                            attributes:textAttributes];
          [self.phone_incomplete addSubview:em_info];
          
          UIButton *go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
          [go setStyleClass:@"go_now_text"];
          [go setTitle:@"TAP TO ADD NUMBER" forState:UIControlStateNormal];
          [go setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
          go.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
          [go addTarget:self action:@selector(go_profile) forControlEvents:UIControlEventTouchUpInside];
          [self.phone_incomplete addSubview:go];
          
          UIButton *dis = [UIButton buttonWithType:UIButtonTypeCustom];
          [dis setStyleClass:@"dismiss_banner"];
          [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
          [dis addTarget:self action:@selector(dismiss_phone_unvalidated) forControlEvents:UIControlEventTouchUpInside];
          
          [self.phone_incomplete addSubview:dis];
          
          [self.view addSubview:self.phone_incomplete];
      }
    else {
        [self.phone_incomplete removeFromSuperview];
    }
    
    [top_button removeFromSuperview];
     top_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [top_button setStyleId:@"button_green_home"];
    [top_button setTitleShadowColor:Rgb2UIColor(26, 38, 32, 0.2) forState:UIControlStateNormal];
    top_button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    CGRect button_frame = CGRectMake(20, 250, 280, 60);
    [top_button setFrame:button_frame];
    
    [top_button addTarget:self action:@selector(send_request) forControlEvents:UIControlEventTouchUpInside];
    //  [mid_button addTarget:self action:@selector(pay_in_person) forControlEvents:UIControlEventTouchUpInside];
    //  [bot_button addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    
    [top_button setTitle:[[self.transaction_types objectAtIndex:0] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    //  [mid_button setTitle:[[self.transaction_types objectAtIndex:1] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    //  [bot_button setTitle:[[self.transaction_types objectAtIndex:2] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    
    UILabel * glyph_search = [UILabel new];
    [glyph_search setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [glyph_search setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-search"]];
    [glyph_search setFrame:CGRectMake(14, 0, 15, 53)];
    [glyph_search setTextColor:[UIColor whiteColor]];
    [top_button addSubview:glyph_search];

    [self.view addSubview:top_button];

    int carouselTop;
    if (bannerAlert == 1)
    {
        carouselTop = 90;
        CGRect button_frame = CGRectMake(20, 270, 280, 60);
        [top_button setFrame:button_frame];
    }
    else if (bannerAlert == 2)
    {
        carouselTop = 120;
        CGRect button_frame = CGRectMake(20, 306, 280, 60);
        [top_button setFrame:button_frame];
    }
    else {
        carouselTop = 50;
    }
    
    // Address Book Authorization grant
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        
        NSLog(@"Denied");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        
        NSLog(@"Authorized");
        if ([[[assist shared]assosAll] count]==0) {
            [self address_book];
            
        }
         [self GetFavorite];
    }
    else
    {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error)
                                                 {
                                                     if (!granted){
                                                         
                                                         NSLog(@"Just denied");
                                                         return;
                                                     }
                                                     
                                                     if ([[[assist shared]assosAll] count]==0) {
                                                         [self address_book];
                                                         
                                                     }
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self GetFavorite];
                                                     });
                                                     
                                                     NSLog(@"Just authorized");
                                                 });
        
        NSLog(@"Not determined");
    }
    
    
    [_carousel removeFromSuperview];
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, carouselTop, 320, 175)];
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

    [[assist shared] setArray:nil];
 
}

-(void)GetFavorite
{
    serve *favoritesOBJ = [serve new];
    [favoritesOBJ setTagName:@"favorites"];
    [favoritesOBJ setDelegate:self];
    [favoritesOBJ get_favorites];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.trackedViewName = @"Home Screen";
    [self.navigationItem setTitle:@"Nooch"];

    if (![[assist shared]isPOP])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
        if ([[user objectForKey:@"logged_in"] isKindOfClass:[NSNull class]])
        {
            //push login
            return;
        }
        if ([[assist shared]needsReload])
        {
            
            self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:self.hud];
            
            self.hud.delegate = self;
            self.hud.labelText = @"Loading your Nooch account";
            [self.hud show:YES];

        }

        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] )
        {
            serve *serveOBJ = [serve new ];
            [serveOBJ setTagName:@"sets"];
            [serveOBJ getSettings];
        }
    }
    else
    {
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }

    // for the red notification bubble if a user has a pending RECEIVED Request
    serve *serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"histPending";
    [serveOBJ histMore:@"ALL" sPos:1 len:20 subType:@"Pending"];

    //do carousel
    [self.view addSubview:_carousel];
    [_carousel reloadData];
    // [favorites removeAllObjects];
}

#pragma mark - iCarousel methods

-(void)scrollCarouselToIndex:(NSNumber *)index
{
    [_carousel scrollToItemAtIndex:index.intValue animated:YES];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [favorites count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = nil;
    UILabel *name=nil;;
    NSDictionary *favorite = [favorites objectAtIndex:index];
    //create new view if no view is available for recycling
    
    if (view == nil)
    {
		view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 175)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 25, 100, 100)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        view.layer.borderColor = kNoochBlue.CGColor;
//        view.layer.borderWidth = 1;
        imageView.layer.cornerRadius = 50;

        if (favorite[@"MemberId"])
        {
            [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://192.203.102.254/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                      placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
            
            UILabel * glyph_fav = [UILabel new];
            [glyph_fav setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
            [glyph_fav setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-star-o"]];
            glyph_fav.textAlignment = NSTextAlignmentCenter;
            [glyph_fav setFrame:CGRectMake(68, 148, 14, 16)];
            [glyph_fav setTextColor:kNoochGrayLight];
            [view addSubview:glyph_fav];
        }
        else if (favorite[@"image"])
        {
            [imageView setImage:[UIImage imageWithData:favorite[@"image"]]];

            UIImageView *glyph_adressBook = [UIImageView new];
            [glyph_adressBook setStyleClass:@"addressbook-icons"];
            glyph_adressBook.layer.borderWidth = 1;
            glyph_adressBook.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
            glyph_adressBook.layer.cornerRadius = 3;
            [glyph_adressBook setFrame:CGRectMake(68, 149, 14, 16)];
            [view addSubview:glyph_adressBook];
        }
        [imageView setClipsToBounds:YES];
        
        name = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 130.0f, 150, 20)];
        name.textColor = [UIColor blackColor];
        name.textAlignment = NSTextAlignmentCenter;
        [name setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];
        if (favorite[@"LastName"])
        {
            name.text = [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]];
        }
        else {
            name.text = [NSString stringWithFormat:@"%@",favorite[@"FirstName"]];
        }
        [view addSubview:imageView];
        [view addSubview:name];

    }
    else
    {
        imageView = (UIImageView *)[view viewWithTag:1];
    }
    
    return view;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
    if(carousel.scrolling == NO)
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        if ([[assist shared]getSuspended])
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"For security your account has been suspended for 24 hours.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com for more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
            [alert setTag:50];
            [alert show];
            return;
        }
        
        if ([[user valueForKey:@"Status"]isEqualToString:@"Registered"] )
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please Verify Your Email" message:@"Terribly sorry, but before you send money, please just confirm your email address by clicking the link we sent to the email address you used to sign up." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
            return;
        }
        
        if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] )
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Help Us Keep Nooch Safe" message:@"Please take 1 minute to validate your identity by completing your Nooch profile (just 4 fields)." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
            [alert setTag:147];
            [alert show];
            return;
        }
        
        if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] )
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Blame Our Lawyers" message:@"To keep Nooch safe, we ask all users to verify your phone number before before sending money.\n \nIf you've already added your phone number, just respond 'Go' to the text message we sent." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Add Phone", nil];
            [alert setTag:148];
            [alert show];
            return;
        }
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"IsBankAvailable"]isEqualToString:@"1"])
        {
            UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Connect Your Bank" message:@"Adding a bank account to fund Nooch payments is lightening quick. (You don't have to type a routing or account number!)  Would you like to take care of this now?." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
            [set setTag:201];
            [set show];
            return;
        }
        
        NSMutableDictionary *favorite = [NSMutableDictionary new];
        [favorite addEntriesFromDictionary:[favorites objectAtIndex:index]];
        
        if (favorite[@"MemberId"])
        {
            [favorite setObject:[NSString stringWithFormat:@"https://192.203.102.254/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]] forKey:@"Photo"];
            NSLog(@"%@",favorite);
            isFromHome = YES;
            HowMuch * trans = [[HowMuch alloc] initWithReceiver:favorite];
            [self.navigationController pushViewController:trans animated:YES];
            return;
        }
        else if (favorite[@"UserName"])
        {
            emailID = favorite[@"UserName"];
            serve * emailCheck = [serve new];
            emailCheck.Delegate = self;
            emailCheck.tagName = @"emailCheck";
            [emailCheck getMemIdFromuUsername:[favorite[@"UserName"] lowercaseString]];
            return;
        }
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionWrap: {
            return YES;
        }
        case iCarouselOptionRadius: {
           return 300;
        }
        case iCarouselOptionSpacing: {
            return value * 1.9;
        }
        case iCarouselOptionArc:
        {
            return 2.2;
        }
        default: {
            return value;
        }
    }    
}

- (void)myTask {
    [blankView removeFromSuperview];
}

-(void)showMenu
{
    [[assist shared]setneedsReload:NO];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ((alertView.tag == 147 || alertView.tag == 148) && buttonIndex==1)
    {
        ProfileInfo *prof = [ProfileInfo new];
        [nav_ctrl pushViewController:prof animated:YES];
        [self.slidingViewController resetTopView];
    }
    else if (alertView.tag == 201)
    {
        if (buttonIndex == 1) {
            knoxWeb *knox = [knoxWeb new];
            [nav_ctrl pushViewController:knox animated:YES];
            [self.slidingViewController resetTopView];
            // GOES TO THE KNOX WEBVIEW WITHIN
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
   
    if ([[assist shared]getSuspended])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Temporarily Suspended" message:@"For security your account has been suspended for 24 hours.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n \nPlease contact us at support@nooch.com if you would like more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
        [alert setTag:50];
        [alert show];
        return;
    }
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please Verify Your Email" message:@"Terribly sorry, but before you can send money, please confirm your email address by clicking the link we sent to the email address you used to sign up." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
  
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Help Us Keep Nooch Safe" message:@"Please take 1 minute to verify your identity by completing your Nooch profile (just 4 fields)." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }

    if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] )
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Blame The Lawyers" message:@"To keep Nooch safe, we ask all users to verify a phone number before before sending money.\n \n If you've already added your phone number, just respond 'Go' to the text message we sent." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Add Phone", nil];
        [alert setTag:148];
        [alert show];
        return;
    }

    if ( ![[[NSUserDefaults standardUserDefaults] objectForKey:@"IsBankAvailable"]isEqualToString:@"1"])
    {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Connect Your Bank" message:@"Adding a bank account to fund Nooch payments is lightening quick. (You don't have to type a routing or account number!)\n \n Would you like to take care of this now?" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
        [set setTag:201];
        [set show];
        return;
    }
  
    if (NSClassFromString(@"SelectRecipient"))
    {
        
        Class aClass = NSClassFromString(@"SelectRecipient");
        id instance = [[aClass alloc] init];
        
        if ([instance isKindOfClass:[UIViewController class]]) {
            [self.navigationController pushViewController:(UIViewController *)instance
                                                 animated:YES];
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
    if ([tagName isEqualToString:@"favorites"])
    {
        [self.hud hide:YES];
        NSError * error;
        favorites = [[NSMutableArray alloc]init];
        favorites = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"favorites %@",favorites);
        favorites=[favorites mutableCopy];
        if ([favorites count] == 0) {
            [self FavoriteContactsProcessing];
        }
        else
        {
            favorites=[favorites mutableCopy];
            
            if ([favorites count] < 5) {
               [self FavoriteContactsProcessing];
            }
           [_carousel reloadData];
        }
    }
    
    else if ([tagName isEqualToString:@"histPending"])
    {
        NSError *error;
        [self.hud hide:YES];
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count] > 0)
        {
            int counter = 0;
            for (NSDictionary * dict in histArray)
            {
                if ( ( [[dict valueForKey:@"TransactionType"]isEqualToString:@"Request"] &&
                      [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"] ) &&
                     ![[dict valueForKey:@"RecepientId"]isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
                {
                    counter++;
                }
            }
            NSLog(@"The counter is: ==  %d  == ",counter);
            [self.navigationItem setLeftBarButtonItem:nil];
            
            if (counter > 0)
            {
                UILabel * pending_notif = [UILabel new];
                [pending_notif setText:[NSString stringWithFormat:@"%d",counter]];
                CGRect button_frame = CGRectMake(16, -2, 20, 20);
                [pending_notif setFrame:button_frame];
                [pending_notif setStyleId:@"pending_notif"];
            
                UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [hamburger setStyleId:@"navbar_hamburger"];
                [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
                [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
                [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
                hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
                [hamburger addSubview:pending_notif];
            
                UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
                [self.navigationItem setLeftBarButtonItem:menu];
            }
            else
            {
                UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [hamburger setStyleId:@"navbar_hamburger"];
                [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
                [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
                [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
                hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
                UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
                [self.navigationItem setLeftBarButtonItem:menu];
            }
        }
    }

    else if([tagName isEqualToString:@"emailCheck"])
    {
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
            isFromHome = YES;
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
            return;
        }
    }
    
    else if([tagName isEqualToString:@"getMemberDetails"])
    {
        NSError * error;
        
        NSMutableDictionary * dict = [NSJSONSerialization
        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
        options:kNilOptions
        error:&error];
        isFromHome = YES;
        
        HowMuch * how_much = [[HowMuch alloc] initWithReceiver:dict];
        [self.navigationController pushViewController:how_much animated:YES];
    }

    else if ([tagName isEqualToString:@"getMemberIds"])
    {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSMutableArray *temp2 = [[temp objectForKey:@"GetMemberIdsResult"] objectForKey:@"phoneEmailList"];
        NSMutableArray *AddressBookAdditions = [NSMutableArray new];
        
        for (NSDictionary *dict in temp2)
        {
            NSMutableDictionary *new = [NSMutableDictionary new];
            
            for (NSString *key in dict.allKeys)
            {
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

    else if ([tagName isEqualToString:@"fb"])
    {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"fb storing %@",temp);
    }
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [self.hud hide:YES];
        UIAlertView * Alert=[[UIAlertView alloc]initWithTitle:@"New Device Detected" message:@"It looks like you have logged in from a new device.  To protect your account, we will just log you out of all other devices." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
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

}

-(void)FavoriteContactsProcessing
{
    [additions removeAllObjects];
    additions = nil;
    additions = [[NSMutableArray alloc]init];
    
    additions = [[[assist shared]assosAll] mutableCopy];
   // favorites = [[NSMutableArray alloc]init];

    for (int i = 0; i < [additions count] ;i++)
    {
        if ([favorites count] == 6) {
            break;
        }
        else if (i >= [additions count]-1) {
            i = 0;
        }
        NSUInteger randomIndex = arc4random() % [additions  count];
        if ([favorites containsObject:[additions objectAtIndex:randomIndex]])
        {
            continue;
        }
        if (  [[additions objectAtIndex:randomIndex] valueForKey:@"UserName"] &&
            ![[[additions objectAtIndex:randomIndex] valueForKey:@"UserName"]isEqualToString:@"(null)"] &&
            ![[[additions objectAtIndex:randomIndex] valueForKey:@"UserName"]isKindOfClass:[NSNull class]])
        {
            [favorites addObject:[additions objectAtIndex:randomIndex]];
        }
    }

    [_carousel reloadData];
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