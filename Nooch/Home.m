//
//  Home.m
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import "Home.h"
#import "Register.h"
#import "InitSliding.h"
#import "ECSlidingViewController.h"
#import "TransferPIN.h"
#import "ReEnterPin.h"
#import "ProfileInfo.h"
#import "HistoryFlat.h"
#import "SendInvite.h"
#import "iCarousel.h"
#import "SIAlertView.h"
#import "UIImageView+WebCache.h"
#import "HowMuch.h"
#import <QuartzCore/QuartzCore.h>
#import "knoxWeb.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import "SpinKit/RTSpinKitView.h"

NSMutableURLRequest *request;
@interface Home ()
@property(nonatomic,strong) NSMutableArray *arrRecords;
@property(nonatomic,strong) NSArray *transaction_types;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIView *suspended;
@property(nonatomic,strong) UIView *profile_incomplete;
@property(nonatomic,strong) UIView *phone_incomplete;
@property(nonatomic,strong) UIView *phone_unverified;
@property(nonatomic,strong) UIView *pending_requests;
@property(nonatomic,strong) iCarousel *carousel;
@property(nonatomic,strong) UILabel * selectedFavName;

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterFG_Home:) name:UIApplicationWillEnterForegroundNotification object:nil];

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge void *)(self));

    nav_ctrl = self.navigationController;
    [self.navigationItem setLeftBarButtonItem:Nil];

    user = [NSUserDefaults standardUserDefaults];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[assist shared] isPOP];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .4;
    [self.view addSubview:backgroundImage];

    UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    NSMutableDictionary * loadInfo;
    if ([core isAlive:[self autoLogin]])
    {
        [[assist shared] setisloggedout:NO];

        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationPush"]intValue] == 1)
        {
            ProfileInfo *prof = [ProfileInfo new];
            [nav_ctrl pushViewController:prof animated:YES];
            [self.slidingViewController resetTopView];

            isFromSettingsOptions = NO;
            isProfileOpenFromSideBar = NO;
            isFromTransDetails = NO;
            sentFromHomeScrn = YES;
        }

        me = [core new];
        [user removeObjectForKey:@"Balance"];
        loadInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:[self autoLogin]];
        [user setValue:[loadInfo valueForKey:@"MemberId"] forKey:@"MemberId"];
        [user setValue:[loadInfo valueForKey:@"UserName"] forKey:@"UserName"];
        [user synchronize];

        [me birth];
    }
    else
    {
        [user removeObjectForKey:@"MemberId"];
        [user removeObjectForKey:@"UserName"];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [user removeObjectForKey:@"Balance"];

        Register * reg = [Register new];
        [nav_ctrl pushViewController:reg animated:NO];

        [ARProfileManager clearProfile];
        [[assist shared] setisloggedout:YES];
        return;
    }

    // If they have required immediately turned on or haven't selected the option yet, redirect them to PIN screen
    if (![user objectForKey:@"requiredImmediately"])
    {
        ReEnterPin * pin = [ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
    }
    else if ([[user objectForKey:@"requiredImmediately"] boolValue])
    {
        ReEnterPin * pin = [ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
    }

    if ([user objectForKey:@"facebook_id"])
    {
        serve * fb = [serve new];
        [fb setDelegate:self];
        [fb setTagName:@"fb"];
        [fb storeFB:[user objectForKey:@"facebook_id"] isConnect:@"YES"];
    }

    firstNameAB = @"";
    lastNameAB = @"";

    noRecentContacts = false;
    
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    [NSTimeZone setDefaultTimeZone:timeZone];

    [ARProfileManager setSharedUserId:[user valueForKey:@"MemberId"]];
    [ARProfileManager registerLocation:@"lastKnownLocation"];
}

void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    NSMutableArray*additions = [[NSMutableArray alloc] init];
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);

    for (int i = 0; i < nPeople; i++)
    {
        NSMutableDictionary * curContact = [[NSMutableDictionary alloc] init];

        [curContact setObject:@"YES" forKey:@"addressbook"];

        ABRecordRef person = CFArrayGetValueAtIndex(people, i);

        NSString * contacName, * firstName, * lastName;
        NSData * contactImage;
        NSString * phone, * phone2, * phone3;

        CFTypeRef contacNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        contacName = [[NSString stringWithFormat:@"%@", contacNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (contacNameValue)
            CFRelease(contacNameValue);

        // Get FirstName Ref
        CFTypeRef firstNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        firstName = [[NSString stringWithFormat:@"%@", firstNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (firstNameValue)
            CFRelease(firstNameValue);

        // Get LastName Ref
        CFTypeRef LastNameValue = ABRecordCopyValue(person, kABPersonLastNameProperty);
        if (LastNameValue)
        {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", LastNameValue]];
            lastName = [[NSString stringWithFormat:@"%@", LastNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (LastNameValue)
                CFRelease(LastNameValue);
        }

        // Get Contact Image Ref
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

        if (contacName != NULL) [curContact setObject: contacName forKey:@"Name"];
        if (firstName != NULL) [curContact setObject: firstName forKey:@"FirstName"];
        if (lastName != NULL) [curContact setObject: lastName forKey:@"LastName"];


        if (ABMultiValueGetCount(phoneNumber) > 0)
        {
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

        //Get emailInfo Ref
        for (int j = 0; j < ABMultiValueGetCount(emailInfo); j++)
        {
            CFTypeRef emailIdValue = ABMultiValueCopyValueAtIndex(emailInfo, j);
            NSString * emailId = [[NSString stringWithFormat:@"%@", emailIdValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ( emailId != NULL &&
                [emailId rangeOfString:@"@facebook.com"].location == NSNotFound &&
                [emailId rangeOfString:@"hushmail.com"].location == NSNotFound &&
                [emailId rangeOfString:@"mailinator."].location == NSNotFound &&
                [emailId rangeOfString:@"mailinater."].location == NSNotFound &&
                [emailId rangeOfString:@"hmamail.com"].location == NSNotFound &&
                [emailId rangeOfString:@"guerrillamail"].location == NSNotFound &&
                [emailId rangeOfString:@"sharklasers"].location == NSNotFound &&
                [emailId rangeOfString:@"anonymousemail"].location == NSNotFound)
            {
                [curContact setObject:emailId forKey:@"UserName"];
                [curContact setObject:emailId forKey:[NSString stringWithFormat:@"emailAdday%d",j]];
                [curContact setObject:[NSString stringWithFormat:@"%d", j+1] forKey:@"emailCount"];
            }
            if (emailIdValue) {
                CFRelease(emailIdValue);
            }
        }        

        if (emailInfo) {
            CFRelease(emailInfo);
        }

        if (contacName != NULL)
        {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            if ([strippedNumber length] == 11) {
                strippedNumber = [strippedNumber substringFromIndex:1];
            }
            if (strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
        }
        [additions addObject:curContact];
        if (phoneNumber)
            CFRelease(phoneNumber);
    }

    [[assist shared] SaveAssos:additions.mutableCopy];

    NSMutableArray * get_ids_input = [NSMutableArray new];
    for (NSDictionary * person in additions)
    {
        NSMutableDictionary *person_input = [NSMutableDictionary new];
        [person_input setObject:@"" forKey:@"memberId"];
        if (person[@"emailAddy"]) [person_input setObject:person[@"emailAddy"] forKey:@"emailAddy"];
        else [person_input setObject:@"" forKey:@"emailAddy"];
        if (person[@"phoneNo"]) [person_input setObject:person[@"phoneNo"] forKey:@"phoneNo"];
        if (person[@"phoneNo2"]) [person_input setObject:person[@"phoneNo2"] forKey:@"phoneNo2"];
        if (person[@"phoneNo3"]) [person_input setObject:person[@"phoneNo3"] forKey:@"phoneNo3"];
        [get_ids_input addObject:person_input];
    }

    if (people)
        CFRelease(people);
    if (addressBook)
        CFRelease(addressBook);
}

-(void)dismiss_suspended_alert
{
    [UIView animateKeyframesWithDuration:.34
                                   delay:0
                                 options:2 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      CGRect frame = self.suspended.frame;
                                      frame.origin.y = -56;
                                      [self.suspended setFrame:frame];
                                      
                                      CGRect rect= self.profile_incomplete.frame;
                                      rect.origin.y -= 56;
                                      self.profile_incomplete.frame = rect;
                                      
                                      CGRect rect2 = self.phone_incomplete.frame;
                                      rect2.origin.y -= 56;
                                      self.phone_incomplete.frame = rect2;

                                      CGRect carouselFrame = _carousel.frame;
                                      carouselFrame.origin.y -= 40;
                                      [_carousel setFrame:carouselFrame];

                                      CGRect topBtnFrame = top_button.frame;
                                      topBtnFrame.origin.y -= 30;
                                      [top_button setFrame:topBtnFrame];
                                  }];
                              } completion: ^(BOOL finished){
                                  [self.suspended removeFromSuperview];
                              }
     ];
}

-(void)dismiss_profile_unvalidated
{
    [UIView animateKeyframesWithDuration:.34
                                   delay:0
                                 options:2 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      CGRect frame = self.profile_incomplete.frame;
                                      frame.origin.y = -57;
                                      [self.profile_incomplete setFrame:frame];
                                      
                                      CGRect rect2 = self.phone_incomplete.frame;
                                      rect2.origin.y -= 56;
                                      self.phone_incomplete.frame = rect2;

                                      CGRect carouselFrame = _carousel.frame;
                                      carouselFrame.origin.y -= 40;
                                      [_carousel setFrame:carouselFrame];

                                      CGRect topBtnFrame = top_button.frame;
                                      topBtnFrame.origin.y -= 30;
                                      [top_button setFrame:topBtnFrame];
                                  }];
                              } completion: ^(BOOL finished){
                                  [self.profile_incomplete removeFromSuperview];
                              }
     ];
}

-(void)dismiss_phone_unvalidated
{
    if ([self.view.subviews containsObject:self.profile_incomplete])
    {
        [self.view bringSubviewToFront:self.profile_incomplete];
    }

    [UIView animateKeyframesWithDuration:.34
                                   delay:0
                                 options:2 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      CGRect frame = self.phone_incomplete.frame;
                                      frame.origin.y = -57;
                                      [self.phone_incomplete setFrame:frame];

                                      CGRect carouselFrame = _carousel.frame;
                                      carouselFrame.origin.y -= 40;
                                      [_carousel setFrame:carouselFrame];

                                      CGRect topBtnFrame = top_button.frame;
                                      topBtnFrame.origin.y -= 30;
                                      [top_button setFrame:topBtnFrame];
                                  }];
                              } completion: ^(BOOL finished){
                                  [self.phone_incomplete removeFromSuperview];
                              }
     ];
}

-(void)dismiss_requestsPendingBanner
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    [UIView animateKeyframesWithDuration:.38
                                   delay:0
                                 options:2 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      CGRect frame = self.pending_requests.frame;
                                      frame.origin.y = -57;
                                      [self.pending_requests setFrame:frame];

                                      CGRect carouselFrame = _carousel.frame;
                                      carouselFrame.origin.y -= 30;
                                      [_carousel setFrame:carouselFrame];

                                      CGRect topBtnFrame = top_button.frame;
                                      topBtnFrame.origin.y -= 25;
                                      [top_button setFrame:topBtnFrame];
                                  }];
                              } completion: ^(BOOL finished){
                                  [self.pending_requests removeFromSuperview];
                              }
     ];
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
        NSMutableDictionary * curContact = [[NSMutableDictionary alloc] init];

        [curContact setObject:@"YES" forKey:@"addressbook"];

        ABRecordRef person = CFArrayGetValueAtIndex(people, i);

        NSString * contacName, * firstName, * lastName;
        NSData * contactImage;
        NSString * phone, * phone2, * phone3;

        CFTypeRef contacNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        contacName = [[NSString stringWithFormat:@"%@", contacNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (contacNameValue)
            CFRelease(contacNameValue);
        
        // Get FirstName Ref
        CFTypeRef firstNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        firstName = [[NSString stringWithFormat:@"%@", firstNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (firstNameValue)
            CFRelease(firstNameValue);
        
        // Get LastName Ref
        CFTypeRef LastNameValue = ABRecordCopyValue(person, kABPersonLastNameProperty);
        if (LastNameValue)
        {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", LastNameValue]];
            lastName = [[NSString stringWithFormat:@"%@", LastNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (LastNameValue)
                CFRelease(LastNameValue);
        }
        
        // Get Contact Image Ref
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

        if (contacName != NULL) [curContact setObject: contacName forKey:@"Name"];
        if (firstName != NULL) [curContact setObject: firstName forKey:@"FirstName"];
        if (lastName != NULL) [curContact setObject: lastName forKey:@"LastName"];
        
       
        if (ABMultiValueGetCount(phoneNumber) > 0)
        {
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

        //Get emailInfo Ref
        for (int j = 0; j < ABMultiValueGetCount(emailInfo); j++)
        {
            CFTypeRef emailIdValue = ABMultiValueCopyValueAtIndex(emailInfo, j);
            NSString * emailId = [[NSString stringWithFormat:@"%@", emailIdValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            if ( emailId != NULL &&
                [emailId rangeOfString:@"facebook.com"].location == NSNotFound &&
                [emailId rangeOfString:@"hushmail.com"].location == NSNotFound &&
                [emailId rangeOfString:@"mailinator."].location == NSNotFound &&
                [emailId rangeOfString:@"mailinater."].location == NSNotFound &&
                [emailId rangeOfString:@"hmamail.com"].location == NSNotFound &&
                [emailId rangeOfString:@"guerrillamail"].location == NSNotFound &&
                [emailId rangeOfString:@"sharklasers"].location == NSNotFound &&
                [emailId rangeOfString:@"anonymousemail"].location == NSNotFound)
            {
                [curContact setObject:emailId forKey:@"UserName"];
                [curContact setObject:emailId forKey:[NSString stringWithFormat:@"emailAdday%d",j]];
                [curContact setObject:[NSString stringWithFormat:@"%d", j+1] forKey:@"emailCount"];
            }
            if (emailIdValue) {
                CFRelease(emailIdValue);
            }
        }

        if (emailInfo) {
            CFRelease(emailInfo);
        }

        if (contacName != NULL)
        {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            if ([strippedNumber length] == 11) {
                strippedNumber = [strippedNumber substringFromIndex:1];
            }
            if (strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
        }
        //NSLog(@"Address_Book --> curContact is: %@",curContact[@"Name"]);
        [additions addObject:curContact];
        if (phoneNumber)
            CFRelease(phoneNumber);
    }

    [[assist shared] SaveAssos:additions.mutableCopy];

    NSMutableArray * get_ids_input = [NSMutableArray new];
    for (NSDictionary * person in additions)
    {
        NSMutableDictionary *person_input = [NSMutableDictionary new];

        [person_input setObject:@"" forKey:@"memberId"];

        if (person[@"emailAddy"])
        {
            [person_input setObject:person[@"emailAddy"] forKey:@"emailAddy"];
        }
        else
        {
            [person_input setObject:@"" forKey:@"emailAddy"];
        }
        if (person[@"phoneNo"])
        {
            [person_input setObject:person[@"phoneNo"] forKey:@"phoneNo"];
        }
        if (person[@"phoneNo2"])
        {
            [person_input setObject:person[@"phoneNo2"] forKey:@"phoneNo2"];
        }
        if (person[@"phoneNo3"])
        {
            [person_input setObject:person[@"phoneNo3"] forKey:@"phoneNo3"];
        }
        [get_ids_input addObject:person_input];
    }

    if (people)
    CFRelease(people);
    if (addressBook)
    CFRelease(addressBook);
}

-(void)contact_support
{
    if (![MFMailComposeViewController canSendMail])
    {
      /*if ([UIAlertController class]) // for iOS 8
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No Email Detected"
                                         message:@"You don't have an email account configured for this device."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * ok = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                  }];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else
        {
          */UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                          message:@"You don't have an email account configured for this device."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [av show];
            return;
      //}
    }

    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor=[UIColor whiteColor];
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

-(void)go_profileFromHome
{
    sentFromHomeScrn = YES;
    isFromSettingsOptions = NO;
    isProfileOpenFromSideBar = NO;
    isFromTransDetails = NO;

    ProfileInfo *info = [ProfileInfo new];
    [self.navigationController pushViewController:info animated:YES];
}

-(void)go_history
{
    [self dismiss_requestsPendingBanner];
    HistoryFlat *goToHistory = [HistoryFlat new];
    [self.navigationController pushViewController:goToHistory animated:NO];
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
    [self.navigationItem setTitle:@"Nooch"];

    if (![[assist shared] isPOP])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

        self.slidingViewController.panGesture.enabled = YES;
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];

        if ([[user objectForKey:@"logged_in"] isKindOfClass:[NSNull class]])
        {
            //push login
            return;
        }

        if ([[assist shared] needsReload] &&
            [[user valueForKey:@"ProfileComplete"]isEqualToString:@"YES"])
        {
            NSDictionary * dictionary = @{@"MemberId": [user valueForKey:@"MemberId"]};

            RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleCircleFlip];
            spinner1.color = [UIColor clearColor];
            self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:self.hud];

            self.hud.color = Rgb2UIColor(238, 239, 240, .92);
            self.hud.mode = MBProgressHUDModeCustomView;
            self.hud.customView = spinner1;
            self.hud.delegate = self;
            self.hud.labelText = NSLocalizedString(@"Home_HUDlbl1", @"Home Screen 'Loading Your Nooch Account' HUD");
            self.hud.labelColor = kNoochGrayDark;
            [self.hud show:YES];

            //location
            [self checkIfLocAllowed];

            [ARTrackingManager trackEvent:@"Home_ViewDidAppear_ReloadInitiated" parameters:dictionary];
            NSLog(@"Home: Reload Initiated");
        }

        serve * serveOBJ = [serve new];
        [serveOBJ setTagName:@"sets"];
        [serveOBJ getSettings];

        [[assist shared] setisloggedout:NO];

        NSString * KnoxOnOff = [[ARPowerHookManager getValueForHookById:@"knox_OnOff"] lowercaseString];
        NSString * SynapseOnOff = [[ARPowerHookManager getValueForHookById:@"synps_OnOff"] lowercaseString];

        if ([KnoxOnOff isEqualToString:@"on"]) {
            isKnoxOn = YES;
        }
        else {
            isKnoxOn = NO;
        }
        if ([SynapseOnOff isEqualToString:@"on"]) {
            isSynapseOn = YES;
        }
        else {
            isSynapseOn = NO;
        }
        //NSLog(@"isKnoxOn is: %d",isKnoxOn);
        //NSLog(@"isSynapseOn is: %d",isSynapseOn);
    }
    else
    {
        [[assist shared] setisloggedout:YES];

        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];

        me = [core new];

        [ARProfileManager clearProfile];
        return;
    }

    // Address Book Authorization grant
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        NSLog(@"AB Denied");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        NSLog(@"AB Authorized");
        if ([[[assist shared]assosAll] count] == 0) {
            [self address_book];
        }
    }
    else
    {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error)
                                                 {
                                                     if (!granted) {
                                                         NSLog(@"AB Just denied");
                                                         return;
                                                     }
                                                     if ([[[assist shared]assosAll] count] == 0) {
                                                         [self address_book];
                                                     }
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self GetFavorite];
                                                     });
                                                     NSLog(@"AB Just authorized");
                                                 });
        NSLog(@"AB Not determined");
    }

    [self GetFavorite];

    [self checkAllBannerStatuses];

    [[assist shared] setRequestMultiple:NO];
    [[assist shared] setArray:nil];

    BOOL shouldDisplayVersionUpdateAlert = [[ARPowerHookManager getValueForHookById:@"NV_YorN"] boolValue];

    if (shouldDisplayVersionUpdateAlert)
    {
        NSString * versionNumFromArtisan = [ARPowerHookManager getValueForHookById:@"versionNum"];
        versionNumFromArtisan = [versionNumFromArtisan stringByReplacingOccurrencesOfString:@"1." withString:@""];

        NSString * versionNumFromBundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        versionNumFromBundle = [versionNumFromBundle stringByReplacingOccurrencesOfString:@"1." withString:@""];

        float versionNumFromArtisanDouble = [versionNumFromArtisan floatValue];
        float bundleVersionNumDouble = [versionNumFromBundle floatValue];

        if (bundleVersionNumDouble < versionNumFromArtisanDouble &&
            [user boolForKey:@"VersionUpdateNoticeDisplayed"] == false )
        {
            [self displayVersionUpdateNotice];
        }
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ARProfileManager registerString:@"IsKnoxBankAttached" withValue:@"unknown"];
        [ARProfileManager registerString:@"IsSynapseBankAttached" withValue:@"unknown"];
        [ARProfileManager registerString:@"IPaddress" withValue:@"unknown"];

        if (isSynapseOn && [user boolForKey:@"IsSynapseBankAvailable"])
        {
            [ARProfileManager setStringValue:@"YES" forVariable:@"IsSynapseBankAttached"];
        }
        else if (isSynapseOn)
        {
            [ARProfileManager setStringValue:@"NO" forVariable:@"IsSynapseBankAttached"];
        }
        else if (isKnoxOn && [user boolForKey:@"IsKnoxBankAvailable"])
        {
            [ARProfileManager setStringValue:@"YES" forVariable:@"IsKnoxBankAttached"];
        }
        else if (isKnoxOn)
        {
            [ARProfileManager setStringValue:@"NO" forVariable:@"IsKnoxBankAttached"];
        }
    });

    NSURL * theURL = [[NSURL alloc] initWithString:@"http://ip-api.com/line/?fields=query"];
    NSString * myIP = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:theURL] encoding:NSUTF8StringEncoding];
    
    if ([myIP length] < 16)
    {
        [self saveIpAddress:myIP];
    }
}

-(void)saveIpAddress:(NSString*)Ip
{
    if ([Ip rangeOfString:@"\n"].location != NSNotFound)
    {
        Ip = [Ip substringWithRange: NSMakeRange(0, [Ip rangeOfString: @"\n"].location)];
    }
    //NSLog(@"IP: %@", Ip);

    serve * saveIP = [serve new];
    [saveIP setTagName:@"saveIpAddress"];
    [saveIP setDelegate:self];
    [saveIP saveUserIpAddress:Ip];

    [ARProfileManager setStringValue:Ip forVariable:@"IPaddress"];
}

- (void)applicationWillEnterFG_Home:(NSNotification *)notification
{
    //NSLog(@"Home -> ApplicationWillEnterFG fired");

    if ([[assist shared] isloggedout] == false)
    {
        serve * serveOBJ = [serve new];
        [serveOBJ setTagName:@"sets"];
        [serveOBJ getSettings];

        [self performSelector:@selector(checkAllBannerStatuses) withObject:nil afterDelay:1];
    }
}

-(void)checkAllBannerStatuses
{
    //NSLog(@"checkAllBannerStatuses Checkpoint # 1");
    bannerAlert = 0;
    carouselTopValue = 48;
    topBtnTopValue = 260;

    // for the red notification bubble if a user has a pending RECEIVED Request
    serve * getPendingCount = [serve new];
    [getPendingCount setDelegate:self];
    [getPendingCount setTagName:@"getPendingTransfersCount"];
    [getPendingCount getPendingTransfersCount];

    NSShadow * shadowRed = [[NSShadow alloc] init];
    shadowRed.shadowColor = Rgb2UIColor(71, 8, 7, .4);
    shadowRed.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadowRed };

    if ([[assist shared] getSuspended])
    {
        if ([self.view.subviews containsObject:self.pending_requests]) {
            [self dismiss_requestsPendingBanner];
        }
        if ([self.view.subviews containsObject:self.phone_incomplete]) {
            [self dismiss_phone_unvalidated];
        }
        if ([self.view.subviews containsObject:self.profile_incomplete]) {
            [self dismiss_profile_unvalidated];
        }

        bannerAlert++;
        if (![self.view.subviews containsObject:self.suspended])
        {
            [self.suspended removeFromSuperview];
            self.suspended = [UIView new];
            [self.suspended setStyleId:@"suspended_home"];
            [self.suspended addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contact_support)]];

            UILabel * sus_header = [UILabel new];
            [sus_header setStyleClass:@"banner_header"];
            sus_header.attributedText = [[NSAttributedString alloc] initWithString:[NSString  stringWithFormat:NSLocalizedString(@"SuspBannerTitle", @"Home Screen Suspended Banner Title")]
                                                                        attributes:textAttributes];
            [self.suspended addSubview:sus_header];

            UILabel * sus_info = [UILabel new];
            [sus_info setStyleClass:@"banner_info"];
            [sus_info setNumberOfLines:0];
            sus_info.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"SuspBannerBodyTxt", @"Home Screen Suspended Banner Body Text")]
                                                                      attributes:textAttributes];
            [self.suspended addSubview:sus_info];

            UILabel * sus_exclaim = [UILabel new];
            [sus_exclaim setStyleClass:@"banner_alert_glyph"];
            [sus_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
            [self.suspended addSubview:sus_exclaim];

            UIButton * contact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [contact setStyleClass:@"go_now_text"];
            [contact setTitle:[NSString stringWithFormat:NSLocalizedString(@"SuspBannerAction", @"Home Screen Suspended Banner Action Text")] forState:UIControlStateNormal];
            [contact setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
            contact.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [contact addTarget:self action:@selector(contact_support) forControlEvents:UIControlEventTouchUpInside];
            [self.suspended addSubview:contact];

            UIButton * dis = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [dis setStyleClass:@"dismiss_banner"];
            [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
            [dis setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
            dis.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [dis setTitleColor:[Helpers hexColor:@"F49593"] forState:UIControlStateHighlighted];
            [dis addTarget:self action:@selector(dismiss_suspended_alert) forControlEvents:UIControlEventTouchUpInside];
            [self.suspended addSubview:dis];

            [self.view addSubview:self.suspended];
        }
    }
    else
    {
        if ([self.view.subviews containsObject:self.suspended])
        {
            [self dismiss_suspended_alert];
        }
        if (bannerAlert > 0) {
            bannerAlert--;
        }
    }

    if ([[user objectForKey:@"Status"] isEqualToString:@"Registered"])
    {
        if (![self.view.subviews containsObject:self.profile_incomplete])
        {
            [self.profile_incomplete removeFromSuperview];
            self.profile_incomplete = [UIView new];
            [self.profile_incomplete setStyleId:@"email_unverified"];
            [self.profile_incomplete addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(go_profileFromHome)]];

            UILabel * em = [UILabel new];
            [em setStyleClass:@"banner_header"];
            em.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"EmailUnverifiedTitle", @"Home Screen Email Unregistered Title")]
                                                                attributes:textAttributes];
            [self.profile_incomplete addSubview:em];

            UILabel * em_exclaim = [UILabel new];
            [em_exclaim setStyleClass:@"banner_alert_glyph"];
            [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
            [self.profile_incomplete addSubview:em_exclaim];

            UILabel * em_info = [UILabel new];
            [em_info setStyleClass:@"banner_info"];
            [em_info setNumberOfLines:0];
            em_info.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EmailUnverifiedBodyTxt", @"Home Screen Email Unregistered Body Text") attributes:textAttributes];
            [self.profile_incomplete addSubview:em_info];

            UIButton * go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [go setStyleClass:@"go_now_text"];
            [go setTitle:NSLocalizedString(@"EmailUnverifiedActinoTxt", @"Home Screen Email Unregistered Action Text") forState:UIControlStateNormal];
            [go setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
            go.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [go addTarget:self action:@selector(go_profileFromHome) forControlEvents:UIControlEventTouchUpInside];
            [self.profile_incomplete addSubview:go];

            UIButton * dis = [UIButton buttonWithType:UIButtonTypeCustom];
            [dis setStyleClass:@"dismiss_banner"];
            [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
            [dis setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
            [dis setTitleColor:[Helpers hexColor:@"F49593"] forState:UIControlStateHighlighted];
            dis.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [dis addTarget:self action:@selector(dismiss_profile_unvalidated) forControlEvents:UIControlEventTouchUpInside];
            
            [self.profile_incomplete addSubview:dis];
            [self.view addSubview:self.profile_incomplete];
            
            [UIView animateKeyframesWithDuration:.4
                                           delay:0
                                         options:2 << 16
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:.25 relativeDuration:.75 animations:^{
                                              CGRect frame = self.profile_incomplete.frame;
                                              if (bannerAlert == 0)
                                              {
                                                  frame.origin.y = 0;
                                              }
                                              else if (bannerAlert > 0)
                                              {
                                                  frame.origin.y = 56;
                                              }
                                              [self.profile_incomplete setFrame:frame];
                                          }];
                                      } completion: ^(BOOL finished) {
                                          [self.view bringSubviewToFront:self.profile_incomplete];
                                      }
             ];
        }
        bannerAlert++;
    }
    else if ([[user valueForKey:@"Status"]isEqualToString:@"Active"])
    {
        if ([self.view.subviews containsObject:self.profile_incomplete])
        {
            [self dismiss_profile_unvalidated];
        }
        if ([self.view.subviews containsObject:self.suspended])
        {
            [self dismiss_suspended_alert];
        }
    }

    if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] &&
        ![[user objectForKey:@"Status"] isEqualToString:@"Suspended"])
    {
        if (![self.view.subviews containsObject:self.phone_incomplete])
        {
            [self.phone_incomplete removeFromSuperview];
            
            self.phone_incomplete = [UIView new];
            [self.phone_incomplete setStyleId:@"phone_unverified"];
            [self.phone_incomplete addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(go_profileFromHome)]];
            
            UILabel * em = [UILabel new];
            [em setStyleClass:@"banner_header"];
            em.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PhoneUnverifiedTitle", @"Home Screen Phone Unverified Title") attributes:textAttributes];
            [self.phone_incomplete addSubview:em];

            UILabel * em_exclaim = [UILabel new];
            [em_exclaim setStyleClass:@"banner_alert_glyph"];
            [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-phone"]];
            [self.phone_incomplete addSubview:em_exclaim];

            UILabel * glyph_phone = [UILabel new];
            [glyph_phone setStyleClass:@"banner_alert_glyph_sm"];
            [glyph_phone setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation"]];
            [self.phone_incomplete addSubview:glyph_phone];

            UILabel * em_info = [UILabel new];
            [em_info setStyleClass:@"banner_info"];
            [em_info setNumberOfLines:0];
            em_info.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PhoneUnverifiedBodyTxt", @"Home Screen Phone Unregistered Body Text")
                                                                     attributes:textAttributes];
            [self.phone_incomplete addSubview:em_info];

            UIButton * go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [go setStyleClass:@"go_now_text"];
            [go setTitle:NSLocalizedString(@"PhoneUnverifiedActionTxt", @"Home Screen Phone Unverified Action Text") forState:UIControlStateNormal];
            [go setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
            go.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [go addTarget:self action:@selector(go_profileFromHome) forControlEvents:UIControlEventTouchUpInside];
            [self.phone_incomplete addSubview:go];

            UIButton * dis = [UIButton buttonWithType:UIButtonTypeCustom];
            [dis setStyleClass:@"dismiss_banner"];
            [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
            [dis setTitleShadowColor:Rgb2UIColor(71, 8, 7, 0.4) forState:UIControlStateNormal];
            [dis setTitleColor:[Helpers hexColor:@"F49593"] forState:UIControlStateHighlighted];
            dis.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [dis addTarget:self action:@selector(dismiss_phone_unvalidated) forControlEvents:UIControlEventTouchUpInside];

            [self.phone_incomplete addSubview:dis];

            [self.view addSubview:self.phone_incomplete];

            [UIView animateKeyframesWithDuration:.4
                                           delay:0
                                         options:2 << 16
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:.15 relativeDuration:.85 animations:^{
                                              CGRect frame = self.phone_incomplete.frame;
                                              if (bannerAlert == 0)
                                              {
                                                  frame.origin.y = 0;
                                              }
                                              else if (bannerAlert > 0)
                                              {
                                                  frame.origin.y = 56;
                                              }
                                              [self.phone_incomplete setFrame:frame];
                                          }];
                                      } completion: ^(BOOL finished) {
                                          [self.view bringSubviewToFront:self.phone_incomplete];
                                      }
             ];
        }
        else
        {
            [UIView animateKeyframesWithDuration:.4
                                           delay:0
                                         options:2 << 16
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                              CGRect frame = self.phone_incomplete.frame;
                                              if (bannerAlert == 0)
                                              {
                                                  frame.origin.y = 0;
                                              }
                                              else if (bannerAlert > 0)
                                              {
                                                  frame.origin.y = 56;
                                              }
                                              [self.phone_incomplete setFrame:frame];
                                          }];
                                      } completion: ^(BOOL finished) {
                                          [self.view bringSubviewToFront:self.phone_incomplete];
                                      }
             ];
        }

        bannerAlert++;
    }
    else
    {
        if (bannerAlert > 0 && ![self.view.subviews containsObject:self.suspended])
        {
            bannerAlert--;
        }
        if ([self.view.subviews containsObject:self.phone_incomplete])
        {
            [self dismiss_phone_unvalidated];
        }
    }

    //NSLog(@"Banner count is: %d",bannerAlert);

    //Update Pending Status
    if ([[user objectForKey:@"Pending_count"] intValue] > 0)
    {
        [self addPendingBanner];
    }
    else
    {
        if ([self.view.subviews containsObject:self.pending_requests])
        {
            if (bannerAlert > 0 && ![self.view.subviews containsObject:self.suspended]) {
                bannerAlert--;
            }
            [self dismiss_requestsPendingBanner];
        }
    }

    NSString * homeBtnColorFromArtisan = [ARPowerHookManager getValueForHookById:@"homeBtnClr"];

    if (![self.view.subviews containsObject:top_button])
    {
        top_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [top_button setFrame:CGRectMake(20, topBtnTopValue, 280, 54)];
        [top_button setTitle:[NSString stringWithFormat:NSLocalizedString(@"HomeBtnTitle", @"Home Screen Btn Title")] forState:UIControlStateNormal];
        [top_button setTitleShadowColor:Rgb2UIColor(26, 38, 32, 0.2) forState:UIControlStateNormal];
        top_button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [top_button addTarget:self action:@selector(send_request) forControlEvents:UIControlEventTouchUpInside];
        if ([homeBtnColorFromArtisan isEqualToString:@"blue"])
        {
            [top_button setStyleId:@"button_blue_home"];
        }
        else if ([homeBtnColorFromArtisan isEqualToString:@"green"])
        {
            [top_button setStyleId:@"button_green_home"];
        }
        else
        {
            [top_button setStyleId:@"button_green_home"];
        }
    }
    top_button.alpha = .01;

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(26, 38, 32, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

    UILabel * glyph_search = [UILabel new];
    [glyph_search setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    glyph_search.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-search"] attributes:textAttributes1];
    [glyph_search setFrame:CGRectMake(17, 0, 15, 52)];
    [glyph_search setTextColor:[UIColor whiteColor]];
    [top_button addSubview:glyph_search];

    [self.view addSubview:top_button];

    if ([self.navigationController.view.subviews containsObject:self.hud])
    {
        [self.hud hide:YES];
    }

    [self drawCarousel];
}

-(void)addPendingBanner
{
    //Update Pending Status

    [self.navigationItem setLeftBarButtonItem:nil];
    UILabel * pending_notif = [UILabel new];
    [pending_notif setText:[user objectForKey:@"Pending_count"]];
    [pending_notif setFrame:CGRectMake(16, -2, 20, 20)];
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

    if ([[user objectForKey:@"Status"] isEqualToString:@"Active"] &&
        [[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"])
    {
        bannerAlert++;

        if (![self.view.subviews containsObject:self.pending_requests])
        {
            [self.pending_requests removeFromSuperview];

            self.pending_requests = [UIView new];
            [self.pending_requests setStyleId:@"pendingRequestBanner"];
            [self.pending_requests addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(go_history)]];

            NSShadow * shadowBlue = [[NSShadow alloc] init];
            shadowBlue.shadowColor = Rgb2UIColor(19, 32, 38, .25);
            shadowBlue.shadowOffset = CGSizeMake(0, 1);
            NSDictionary * textShadowBlue = @{NSShadowAttributeName:shadowBlue};

            UILabel * em = [UILabel new];
            [em setStyleClass:@"banner_header"];

            UILabel * em_exclaim = [UILabel new];
            [em_exclaim setStyleClass:@"banner_alert_glyph"];
            [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-inbox"]];
            CGRect frameOfGlyph = em_exclaim.frame;
            frameOfGlyph.origin.x += 6;
            [em_exclaim setFrame:frameOfGlyph];
            [self.pending_requests addSubview:em_exclaim];

            UILabel * em_info = [UILabel new];
            [em_info setStyleClass:@"banner_info"];
            [em_info setNumberOfLines:0];
            if ([[user objectForKey:@"Pending_count"] intValue] == 1)
            {
                em.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PendingBannerTitleSingular", @"Home Screen Pending Title Singular") attributes:textShadowBlue];
                em_info.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PendingBannerBodyTxtSingular", @"Home Screen Pending Body Text Singular") attributes:textShadowBlue];
            }
            else if ([[user objectForKey:@"Pending_count"] intValue] > 1)
            {
                em.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PendingBannerTitlePlural", @"Home Screen Pending Title Plural") attributes:textShadowBlue];
                em_info.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"PendingBannerBodyTxtPlural", @"Home Screen Pending Body Text Plural"), [[user objectForKey:@"Pending_count"] intValue]] attributes:textShadowBlue];
            }
            [self.pending_requests addSubview:em];
            [self.pending_requests addSubview:em_info];

            UIButton * goHistory = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [goHistory setStyleClass:@"go_now_text"];
            [goHistory setTitle:NSLocalizedString(@"PendingBannerActionTxt", @"Home Screen Pending Banner Action Text") forState:UIControlStateNormal];
            [goHistory setTitleShadowColor:Rgb2UIColor(19, 32, 38, .25) forState:UIControlStateNormal];
            goHistory.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [goHistory addTarget:self action:@selector(go_history) forControlEvents:UIControlEventTouchUpInside];
            [self.pending_requests addSubview:goHistory];

            UIButton * dis = [UIButton buttonWithType:UIButtonTypeCustom];
            [dis setStyleClass:@"dismiss_banner"];
            [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
            [dis setTitleShadowColor:Rgb2UIColor(19, 32, 38, .25) forState:UIControlStateNormal];
            [dis setTitleColor:[Helpers hexColor:@"a5d8f1"] forState:UIControlStateHighlighted];
            dis.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [dis addTarget:self action:@selector(dismiss_requestsPendingBanner) forControlEvents:UIControlEventTouchUpInside];

            [self.pending_requests addSubview:dis];

            [self.view addSubview:self.pending_requests];

            [UIView animateKeyframesWithDuration:.6
                                           delay:0
                                         options:2 << 16
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:.28 relativeDuration:.72 animations:^{
                                              CGRect frame = self.pending_requests.frame;
                                              frame.origin.y = 0;
                                              [self.pending_requests setFrame:frame];
                                          }];
                                      } completion: ^(BOOL finished) {
                                          [self.view bringSubviewToFront:self.pending_requests];
                                      }
             ];
        }
    }
    else if ([self.view.subviews containsObject:self.pending_requests])
    {
        if (bannerAlert > 0 && ![self.view.subviews containsObject:self.suspended]) {
            bannerAlert--;
        }
        [self dismiss_requestsPendingBanner];
    }

    [self drawCarousel];
}

-(void)GetFavorite
{
    serve *favoritesOBJ = [serve new];
    [favoritesOBJ setTagName:@"favorites"];
    [favoritesOBJ setDelegate:self];
    [favoritesOBJ get_favorites];
}

-(void)checkIfLocAllowed
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized  ||
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            NSLog(@"Home --> Location Services Allowed");
            
            locationManager = [[CLLocationManager alloc] init];
            
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
            
            [locationManager startUpdatingLocation];
        }
        else
        {
            NSLog(@"Home --> Location Services NOT Allowed");
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [top_button removeFromSuperview];

    if ([self.view.subviews containsObject:self.pending_requests])
    {
        [self dismiss_requestsPendingBanner];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Home Screen";
    self.artisanNameTag = @"Home Screen";

    NSMutableDictionary * automatic = [[NSMutableDictionary alloc] init];
    if ([user valueForKey:@"MemberId"] &&
        [user valueForKey:@"UserName"])
    {
        [automatic setObject:[user valueForKey:@"MemberId"] forKey:@"MemberId"];
        [automatic setObject:[user valueForKey:@"UserName"] forKey:@"UserName"];
        [automatic writeToFile:[self autoLogin] atomically:YES];
    }

    isFromArtisanDonationAlert = NO;

    //do carousel
    [self.view addSubview:_carousel];
    [_carousel reloadData];
}

-(void)displayVersionUpdateNotice
{
    [ARTrackingManager trackEvent:@"VersionUpdateNotice_Displayed"];

    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];

    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(9, -500, 302, 440);
    }
    else
    {
        mainView.frame = CGRectMake(9, -540, 302, 445);
    }
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;

    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }];

    [UIView animateWithDuration:0.38
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500)
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 440);
                         }
                         else
                         {
                             mainView.frame = CGRectMake(9, 80, 302, 445);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.23
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500)
                                              {
                                                  mainView.frame = CGRectMake(9, 45, 302, 440);
                                              }
                                              else
                                              {
                                                  mainView.frame = CGRectMake(9, 55, 302, 445);
                                              }
                                          }];
                     }];

    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;

    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];

    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"New Version Available"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];

    UILabel * glyph_download = [UILabel new];
    [glyph_download setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyph_download setFrame:CGRectMake(18, 10, 22, 26)];
    [glyph_download setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-download"]];
    [glyph_download setTextColor:kNoochBlue];
    [head_container addSubview:glyph_download];

    NSString * pictureURL = [ARPowerHookManager getValueForHookById:@"NV_IMG"];
    NSString * pictureWidth = [ARPowerHookManager getValueForHookById:@"NV_IMG_W"];
    NSUInteger picwidthInt = [pictureWidth integerValue];
    NSString * pictureHeight = [ARPowerHookManager getValueForHookById:@"NV_IMG_H"];
    NSUInteger picHeightInt = [pictureHeight integerValue];
    NSString * bodyHeaderTxt = [ARPowerHookManager getValueForHookById:@"NV_HDR"];
    NSString * bodyTextTxt = [ARPowerHookManager getValueForHookById:@"NV_BODY"];

    UILabel * bodyHeader = [[UILabel alloc]initWithFrame:CGRectMake(10, head_container.bounds.size.height + 180, mainView.bounds.size.width - 20, 30)];
    [bodyHeader setBackgroundColor:[UIColor clearColor]];
    [bodyHeader setText:bodyHeaderTxt];
    [bodyHeader setFont:[UIFont fontWithName:@"Roboto-regular" size:23]];
    bodyHeader.textColor = [Helpers hexColor:@"313233"];
    bodyHeader.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:bodyHeader];

    UILabel * bodyText = [[UILabel alloc]initWithFrame:CGRectMake(8, 234, mainView.bounds.size.width - 16, 162)];
    [bodyText setBackgroundColor:[UIColor clearColor]];
    [bodyText setText:bodyTextTxt];
    [bodyText setFont:[UIFont fontWithName:@"Roboto-light" size:14]];
    [bodyText setNumberOfLines: 0];
    bodyText.textColor = [Helpers hexColor:@"313233"];
    bodyText.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:bodyText];
    
    //NSLog(@"picWidth is: %d  and picHeight is: %d",picwidthInt,picHeightInt);
    
    UIImageView * mainImage = [UIImageView new];
    [mainImage setFrame:CGRectMake((mainView.bounds.size.width - picwidthInt) / 2, head_container.bounds.size.height + 10, picwidthInt, picHeightInt)];
    mainImage.clipsToBounds = YES;
    mainImage.layer.cornerRadius = 10;
    [mainImage sd_setImageWithURL:[NSURL URLWithString:pictureURL]
                 placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];

    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnLink.frame = CGRectMake(10, mainView.frame.size.height - 60, 280, 46);
    [btnLink setTitle:@"    Get Newest Version" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(OpenAppInAppStore) forControlEvents:UIControlEventTouchUpInside];

    UILabel * glyph_download2 = [UILabel new];
    [glyph_download2 setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    [glyph_download2 setFrame:CGRectMake(21, 10, 22, 24)];
    [glyph_download2 setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-download"]];
    [glyph_download2 setTextColor:[UIColor whiteColor]];
    [btnLink addSubview:glyph_download2];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(8, 40, 302, 440);
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_download.frame = CGRectMake(18, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height-51, 280, 44);
    }

    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(5, 5, 38, 39);

    UIView * btnClose_shell = [[UIView alloc] initWithFrame:CGRectMake(mainView.frame.size.width - 38, head_container.frame.origin.y - 21, 48, 46)];
    [btnClose_shell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close_lightBox)]];
    [btnClose_shell addSubview:btnClose];

    [mainView addSubview:btnClose_shell];
    [mainView addSubview:mainImage];
    [mainView addSubview:btnLink];
    [overlay addSubview:mainView];

    [user setBool:true forKey:@"VersionUpdateNoticeDisplayed"];
    [user synchronize];
}

-(void)close_lightBox
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500) {
                             mainView.frame = CGRectMake(9, 70, 302, 449);
                         } else {
                             mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 34);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.38
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                                  mainView.frame = CGRectMake(9, -500, 302, 443);
                                              }
                                              else {
                                                  mainView.frame = CGRectMake(9, -540, 302, self.view.frame.size.height - 34);
                                              }
                                              overlay.alpha = 0.1;
                                          } completion:^(BOOL finished) {
                                              [overlay removeFromSuperview];
                                          }
                          ];
                     }
     ];
}

-(void)OpenAppInAppStore
{
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/nooch/id917955306?mt=8&uo=4";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

-(void)goToReferFriend
{
    sentFromStatsScrn = false;

    SendInvite *inv = [SendInvite new];
    [self.navigationController pushViewController:inv animated:YES];
}

#pragma mark - iCarousel methods
-(void)drawCarousel
{
    if (bannerAlert == 1 && carouselTopValue != 75 )
    {
        carouselTopValue = 75;
        topBtnTopValue = 284;
    }
    else if (bannerAlert >= 2 && carouselTopValue != 114)
    {
        carouselTopValue = 114;
        topBtnTopValue = 320;
    }
    else if (bannerAlert == 0 && carouselTopValue != 48)
    {
        carouselTopValue = 48;
        topBtnTopValue = 260;
    }
    
    [UIView animateKeyframesWithDuration:0.5
                                   delay:0
                                 options:2 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                                      [top_button setFrame:CGRectMake(20, topBtnTopValue, 280, 54)];
                                  }];
                              } completion: nil
     ];
    
    if (top_button.alpha != 1)
    {
        [UIView animateKeyframesWithDuration:0.5
                                       delay:0
                                     options:2 << 16
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:.8 animations:^{
                                          top_button.alpha = 1;
                                      }];
                                  } completion: nil
         ];
    }
    
    if ([self.view.subviews containsObject:_carousel])
    {
        float duration = .35;
        short randNum = 0;
        
        if (favorites && [favorites count] > 1)
        {
            randNum = arc4random() % [favorites count];
            
            if (abs(([_carousel currentItemIndex] - randNum) == 2))
            {
                duration = .6;
            }
            else if (abs(([_carousel currentItemIndex] - randNum) > 2))
            {
                duration = .7;
            }
        }
        
        [UIView animateKeyframesWithDuration:duration
                                       delay:0
                                     options:2 << 16
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                          [_carousel setFrame:CGRectMake(0, carouselTopValue, 320, 175)];
                                      }];
                                  } completion: ^(BOOL finished) {
                                      [_carousel scrollToItemAtIndex:randNum duration:.7];
                                  }
         ];
    }
    else
    {
        //NSLog(@"drawCarousel --> Banner count is: %d  and carouselTopValue is: %d  and topBtnTopValue is: %d",bannerAlert, carouselTopValue, topBtnTopValue);
        
        _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, carouselTopValue, 320, 175)];
        _carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _carousel.type = iCarouselTypeCylinder;
        
        [_carousel setNeedsLayout];
        _carousel.delegate = self;
        _carousel.dataSource = self;
        [self.view addSubview:_carousel];
    }
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 100, 100)];
        UIView * imageShadow = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 100, 100)];
        UILabel * firstName = [[UILabel alloc] initWithFrame:CGRectMake(0, 117, 140, 20)];
        UILabel * lastName = [[UILabel alloc] initWithFrame:CGRectMake(0, 137, 140, 20)];

		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 160)];

        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;

        [imageShadow setStyleClass:@"raised_view_carousel"];
        [imageShadow setBackgroundColor:[UIColor whiteColor]];

        firstName.textColor = [Helpers hexColor:@"313233"];
        firstName.textAlignment = NSTextAlignmentCenter;
        [firstName setFont:[UIFont fontWithName:@"Roboto-regular" size:19]];

        lastName.textColor = [UIColor blackColor];
        lastName.textAlignment = NSTextAlignmentCenter;
        [lastName setFont:[UIFont fontWithName:@"Roboto-light" size:16]];

        if (index < [favorites count])
        {
            NSDictionary * favorite = [favorites objectAtIndex:index];

            if (favorite[@"MemberId"])
            {
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]]]
                          placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];

                firstName.text = [NSString stringWithFormat:@"%@",favorite[@"FirstName"]];

                UILabel * glyph_fav = [UILabel new];
                [glyph_fav setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
                [glyph_fav setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-star"]];
                [glyph_fav setTextAlignment:NSTextAlignmentCenter];
                [glyph_fav setFrame:CGRectMake(62, 140, 16, 17)];
                [glyph_fav setTextColor:kNoochBlue];
                [view addSubview:glyph_fav];
            }
            else if (favorite[@"image"])
            {
                [imageView setImage:[UIImage imageWithData:favorite[@"image"]]];

                UIImageView * glyph_adressBook = [UIImageView new];
                [glyph_adressBook setStyleClass:@"addressbook-icons"];
                glyph_adressBook.layer.borderWidth = 1;
                glyph_adressBook.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
                glyph_adressBook.layer.cornerRadius = 3;

                if (!favorite[@"LastName"])
                {
                    firstName.text = [NSString stringWithFormat:@"%@",favorite[@"FirstName"]];
                    [glyph_adressBook setFrame:CGRectMake(63, 141, 14, 16)];
                }
                else
                {
                    firstName.text = [NSString stringWithFormat:@"%@",favorite[@"FirstName"]];
                    lastName.text = [NSString stringWithFormat:@"%@",favorite[@"LastName"]];
                    [glyph_adressBook setFrame:CGRectMake(63, 158, 14, 16)];
                }
                [view addSubview:lastName];
                [view addSubview:glyph_adressBook];
            }
        }
        else
        {
            [imageView setFrame:CGRectMake((view.bounds.size.width / 2) - (70 / 2), 31, 70, 70)];
            [imageView setImage:[UIImage imageNamed:@"silhouette"]];
            //[imageView setImage:[UIImage imageNamed:@"RoundLoading"]];

            [imageShadow setFrame:imageView.frame];

            firstName.text = [NSString stringWithFormat:@"Future"];
            firstName.textColor = kNoochGrayLight;
            lastName.text = [NSString stringWithFormat:@"Friend"];
            lastName.textColor = kNoochGrayLight;
            [view addSubview:lastName];
        }

        imageView.layer.cornerRadius = imageView.bounds.size.width / 2;
        imageShadow.layer.cornerRadius = imageView.bounds.size.width / 2;

        [view addSubview:imageShadow];
        [view addSubview:imageView];
        [view addSubview:firstName];
    }

    return view;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [_carousel scrollToItemAtIndex:index duration:.5];

    if (index < [favorites count])
    {
        if ([self checkIfUserSuspendedOrBlocked])
        {
            NSMutableDictionary * favorite = [NSMutableDictionary new];
            [favorite addEntriesFromDictionary:[favorites objectAtIndex:index]];

            //NSLog(@"Selected Favorite is: %@  %@  %@  %@", favorite[@"FirstName"], favorite[@"LastName"],favorite[@"UserName"],favorite[@"addressbook"]);

            if ( favorite[@"MemberId"] ||
                (favorite[@"UserName"] && [favorite[@"emailCount"]intValue] == 1))
            {
                if ([self.view.subviews containsObject:self.pending_requests])
                {
                    if (bannerAlert > 0) {
                        bannerAlert--;
                    }
                    [self dismiss_requestsPendingBanner];
                }
                
                self.selectedFavName = [[UILabel alloc] initWithFrame:CGRectMake(20, carousel.bounds.origin.y + 12, 280, 30)];
                [self.selectedFavName setFont:[UIFont fontWithName:@"Roboto-regular" size: 22]];

                if (favorite[@"FirstName"] && favorite[@"LastName"])
                {
                    [self.selectedFavName setText: [NSString stringWithFormat:@"%@ %@",favorite[@"FirstName"],favorite[@"LastName"]]];
                    firstNameAB = favorite[@"FirstName"];
                    lastNameAB = favorite[@"LastName"];
                }
                else if (favorite[@"FirstName"])
                {
                    [self.selectedFavName setText: [NSString stringWithFormat:@"%@",favorite[@"FirstName"]]];
                    firstNameAB = favorite[@"FirstName"];
                }
                else
                {
                    firstNameAB = @"";
                }
                [self.selectedFavName setTextColor:kNoochGrayDark];
                [self.selectedFavName setTextAlignment:NSTextAlignmentCenter];
                [self.selectedFavName setAlpha:0];
                [self.view addSubview: self.selectedFavName];


                [UIView animateKeyframesWithDuration:0.7
                                               delay:0.01
                                             options:2 << 16
                                          animations:^{
                                              [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.98 animations:^{
                                                  [carousel itemViewAtIndex:index].transform = CGAffineTransformMakeScale(1.18, 1.18);
                                              }];
                                              [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.98 animations:^{
                                                  self.selectedFavName.transform = CGAffineTransformMakeScale(1.35, 1.35);
                                                  self.selectedFavName.alpha = 1;

                                                  for (int i = 0; i < 6; i++)
                                                  {
                                                      if (i != index)
                                                      {
                                                          [[carousel itemViewAtIndex:i] setAlpha:0];
                                                          [carousel itemViewAtIndex:i].transform = CGAffineTransformMakeScale(.3, .3);
                                                      }
                                                  }
                                              }];
                                              [UIView addKeyframeWithRelativeStartTime:.1 relativeDuration:.7 animations:^{
                                                  top_button.alpha = 0;
                                                  top_button.transform = CGAffineTransformMakeScale(.1, .1);
                                              }];
                                          } completion:^(BOOL finished) {
                                              if (favorite[@"MemberId"])
                                              {
                                                  [favorite setObject:[NSString stringWithFormat:@"https://www.noochme.com/noochservice/UploadedPhotos/Photos/%@.png",favorite[@"MemberId"]] forKey:@"Photo"];
                                                  
                                                  isFromHome = YES;
                                                  isFromMyApt = NO;
                                                  isFromArtisanDonationAlert = NO;

                                                  HowMuch * trans = [[HowMuch alloc] initWithReceiver:favorite];
                                                  [self.navigationController pushViewController:trans animated:YES];
                                                  
                                                  [self.selectedFavName removeFromSuperview];
                                              }
                                              else if (favorite[@"UserName"])
                                              {
                                                  emailID = favorite[@"UserName"];
                                                  serve * emailCheck = [serve new];
                                                  emailCheck.Delegate = self;
                                                  emailCheck.tagName = @"emailCheck";
                                                  [emailCheck getMemIdFromuUsername:[emailID lowercaseString]];
                                              }
                                              return;
                                          }];
            }

            else if (favorite[@"UserName"])
            {
                if ([favorite[@"emailCount"]intValue] > 1)
                {
                    UIActionSheet * actionSheetObject = [[UIActionSheet alloc] init];
                    for (int j = 0; j < [favorite[@"emailCount"]intValue]; j++)
                    {
                        [actionSheetObject addButtonWithTitle:[favorite[[NSString stringWithFormat:@"emailAdday%d",j]] lowercaseString]];
                    }
                    actionSheetObject.title = [NSString stringWithFormat:@"Select which email to use for %@", favorite[@"FirstName"]];
                    actionSheetObject.cancelButtonIndex = [actionSheetObject addButtonWithTitle:@"Cancel"];
                    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
                    [actionSheetObject setTag:1];
                    actionSheetObject.delegate = self;
                    [actionSheetObject showInView:self.view];
                }

                return;
            }
        }
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
             ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Access To Contacts"
                                                        message:@"You can send money to ANY contact in your address book, even if they don't have Nooch.\n\nTO ENABLE, turn on access to Contacts in your iPhone's Settings:\n\nSettings  -->  Privacy  -->  Contacts"
                                                       delegate:Nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:Nil, nil];
        [alert show];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    emailID = title;

    if (![title isEqualToString:@"Cancel"])
    {
        serve * emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:[title lowercaseString]];
    }
}

-(void)showMenu
{
    [[assist shared]setneedsReload:NO];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 201 && buttonIndex == 1)// GO TO THE ADD BANK WEBVIEW
    {
        knoxWeb *knox = [knoxWeb new];
        [nav_ctrl pushViewController:knox animated:YES];
        [self.slidingViewController resetTopView];
    }
    else if ((alertView.tag == 50 || alertView.tag == 54) && buttonIndex == 1)
    {
        [self contact_support];
    }
}

- (void)send_request
{
    CGRect existing = top_button.frame;
    existing.origin.y -= 2;
    [top_button setFrame:existing];

    if ([self checkIfUserSuspendedOrBlocked])
    {
        if (NSClassFromString(@"SelectRecipient"))
        {
            [UIView animateKeyframesWithDuration:0.2
                                           delay:0
                                         options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                                              top_button.alpha = 0;
                                          }];
                                      } completion: ^(BOOL finished) {
                                          [top_button removeFromSuperview];
                                      }
             ];

            Class aClass = NSClassFromString(@"SelectRecipient");
            id instance = [[aClass alloc] init];
            
            if ([instance isKindOfClass:[UIViewController class]]) {
                [self.navigationController pushViewController:(UIViewController *)instance
                                                     animated:YES];
            }
        }
    }
}

-(BOOL)checkIfUserSuspendedOrBlocked
{
    if ([[assist shared] getSuspended])
    {
        SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"Account Suspended" andMessage:@"\xF0\x9F\x98\xA7\nFor security your account has been suspended pending a review.\n\nWe really apologize for the inconvenience and ask for your patience. Our top priority is keeping Nooch safe and secure.\n\nPlease contact us at support@nooch.com if this is a mistake or for more information."];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:@"Contact Nooch" type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [self contact_support];
                              }];
        [[SIAlertView appearance] setButtonColor:kNoochBlue];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
        [alertView show];
        return NO;
    }

    else if ([[user valueForKey:@"Status"]isEqualToString:@"Registered"])
    {
        SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"Please Verify Your Email" andMessage:@"Terribly sorry, but before you send money, please confirm your email address by clicking the link we sent to the email address you used to sign up.\n\xF0\x9F\x99\x8F"];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
        [[SIAlertView appearance] setButtonColor:kNoochBlue];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
        [alertView show];
        return NO;
    }

    /* if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"])
     {
     SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"Help Us Keep Nooch Safe" andMessage:@"Please take 1 minute to verify your identity by completing your Nooch profile (just 4 fields)."];
     [alertView addButtonWithTitle:@"Later" type:SIAlertViewButtonTypeCancel handler:nil];
     [alertView addButtonWithTitle:@"Validate Now" type:SIAlertViewButtonTypeDefault
     handler:^(SIAlertView *alert) {
     ProfileInfo *prof = [ProfileInfo new];
     [nav_ctrl pushViewController:prof animated:YES];
     [self.slidingViewController resetTopView];
     }];
     [[SIAlertView appearance] setButtonColor:kNoochBlue];
     
     alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
     alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
     [alertView show];
     return NO;
     }*/

    else if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] )
    {
        SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"Blame The Lawyers" andMessage:@"To keep Nooch safe, we ask all users to verify a phone number before sending money.\n\nIf you've already added your phone number, just respond 'Go' to the text message we sent."];
        [alertView addButtonWithTitle:@"Later" type:SIAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:@"Add Phone" type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [self go_profileFromHome];
                              }];
        [[SIAlertView appearance] setButtonColor:kNoochBlue];

        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
        [alertView show];
        return NO;
    }

    else if ((isKnoxOn && ![user boolForKey:@"IsKnoxBankAvailable"]) ||
             (isSynapseOn && ![user boolForKey:@"IsSynapseBankAvailable"]))
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Connect A Funding Source \xF0\x9F\x92\xB0" andMessage:@"\xE2\x9A\xA1\nAdding a bank account to fund Nooch payments is lightning quick.\n\n• No routing or account number needed\n• Bank-grade encryption keeps your info safe\n\nWould you like to take care of this now?"];
        [alertView addButtonWithTitle:@"Later" type:SIAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:@"Go Now" type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  knoxWeb *knox = [knoxWeb new];
                                  [nav_ctrl pushViewController:knox animated:YES];
                                  [self.slidingViewController resetTopView];
                              }];
        [[SIAlertView appearance] setButtonColor:kNoochBlue];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
        [alertView show];
        return NO;
    }

    else if (!isKnoxOn && isSynapseOn && [user boolForKey:@"IsSynapseBankAvailable"] && ![user boolForKey:@"IsSynapseBankVerified"])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Bank Account Un-Verified"
                                                     message:@"Looks like your bank account remains un-verified.  This usually happens when the contact info listed on the bank account does not match your Nooch profile information. Please contact Nooch support for more information."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:@"Contact Support", nil];
        [av setTag:54];
        [av show];
        return NO;
    }


    return YES;
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];

    CLLocationCoordinate2D loc = manager.location.coordinate;
    lat = [[[NSString alloc] initWithFormat:@"%f",loc.latitude] floatValue];
    lon = [[[NSString alloc] initWithFormat:@"%f",loc.longitude] floatValue];

    [[assist shared]setlocationAllowed:YES];

    serve * serveOBJ = [serve new];
    [serveOBJ UpDateLatLongOfUser:[[NSString alloc] initWithFormat:@"%f",loc.latitude]
                              lng:[[NSString alloc] initWithFormat:@"%f",loc.longitude]];

    [ARProfileManager setLocationValue:loc forVariable:@"lastKnownLocation"];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [[assist shared] setlocationAllowed:NO];

    if ([error code] == kCLErrorDenied) {
        NSLog(@"Home --> Location Mgr Error: %@", error);
    }
    else {
        NSLog(@"Home --> Location Mgr Error: %@",error);
    }
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Trouble Connecting"
                          message:@"We aren't able to connect to the server right now, the internet must be unusually congested.  Sorry about that, please try again!"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud hide:YES];
    });

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound ||
        result == NULL)
    {
        [self.hud hide:YES];
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];
        
        [timer invalidate];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        
        [nav_ctrl performSelector:@selector(reset)];
        
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        [ARProfileManager clearProfile];
        return;
    }

    if ([tagName isEqualToString:@"favorites"])
    {
        NSError * error;
        favorites = [[NSMutableArray alloc] init];
        favorites = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        //NSLog(@"1a. favorites Count is: %lu \n...and Fav Json is: %@", (unsigned long)[favorites count], favorites);

        if ([favorites count] > 0)
        {
            noRecentContacts = false;
            [ARProfileManager registerNumber:@"Fav_Nooch_Friends"];
            [ARProfileManager setNumberValue:[NSNumber numberWithDouble:[favorites count]] forVariable:@"Fav_Nooch_Friends"];
        }
        else if ([favorites count] == 0)
        {
            noRecentContacts = true;
        }

        if (favorites != NULL)
        {
            favorites = [favorites mutableCopy];

            if ([favorites count] < 5)
            {
                [self FavoriteContactsProcessing];
            }
            else
            {
                [_carousel reloadData];
            }
        }

        if ([self.view.subviews containsObject:self.hud])
        {
            [self.hud hide:YES];
        }
    }

    else if ([tagName isEqualToString:@"getPendingTransfersCount"])
    {
        NSError *error;
        [self.hud hide:YES];

        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        //NSLog(@"Home --> Listen --> getPendingTransfersCount Result: %@",dict);
        int pendingRequestsReceived = [[dict valueForKey:@"pendingRequestsReceived"] intValue];
        NSString * count;

        [self.navigationItem setLeftBarButtonItem:nil];

        if (pendingRequestsReceived > 0)
        {
            UILabel * pending_notif = [UILabel new];
            [pending_notif setText:[NSString stringWithFormat:@"%d", pendingRequestsReceived]];
            [pending_notif setFrame:CGRectMake(16, -2, 20, 20)];
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

            [user setBool:true forKey:@"hasPendingItems"];
            count = [dict valueForKey:@"pendingRequestsReceived"];

            [user setValue: count forKey:@"Pending_count"];

            if (![self.view.subviews containsObject:self.pending_requests])
            {
                [self addPendingBanner];
            }
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

            [user setBool:false forKey:@"hasPendingItems"];

            count = @"0";

            if ([self.view.subviews containsObject:self.pending_requests])
            {
                [self dismiss_requestsPendingBanner];
            }

            [user setValue:count forKey:@"Pending_count"];
        }
        [user synchronize];

        if ([self.view.subviews containsObject:self.hud])
        {
            [self.hud hide:YES];
        }
    }

    else if ([tagName isEqualToString:@"emailCheck"])
    {
        NSError * error;
        NSMutableDictionary * dictResult = [NSJSONSerialization
                                           JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                           options:kNilOptions
                                           error:&error];
        
        if ([dictResult objectForKey:@"Result"] != [NSNull null])
        {
            serve * getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberDetails";
            [getDetails getDetails:[dictResult objectForKey:@"Result"]];
        }
        else
        {
            [UIView animateKeyframesWithDuration:.2
                                           delay:0
                                         options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.9 animations:^{
                                              top_button.alpha = 0;
                                              top_button.transform = CGAffineTransformMakeScale(.1, .1);
                                          }];
                                          
                                      } completion:^(BOOL finished){
                                          [top_button removeFromSuperview];
                                          [self.selectedFavName removeFromSuperview];
                                      }];

            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:emailID forKey:@"email"];
            [dict setObject:@"nonuser" forKey:@"nonuser"];

            if (![firstNameAB isEqualToString:@""] )
            {
                [dict setObject:firstNameAB forKey:@"firstName"];
            }
            if (![lastNameAB isEqualToString:@""])
            {
                [dict setObject:lastNameAB forKey:@"lastName"];
            }

            isFromHome = YES;
            isFromMyApt = NO;
            isFromArtisanDonationAlert = NO;

            HowMuch * how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
            return;
        }
    }

    else if ([tagName isEqualToString:@"getMemberDetails"])
    {
        NSError * error;

        NSMutableDictionary * dict = [NSJSONSerialization
        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
        options:kNilOptions
        error:&error];
        isFromHome = YES;
        isFromMyApt = NO;
        isFromArtisanDonationAlert = NO;

        HowMuch * how_much = [[HowMuch alloc] initWithReceiver:dict];
        [self.navigationController pushViewController:how_much animated:YES];

        [top_button removeFromSuperview];
        [self.selectedFavName removeFromSuperview];
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
    }

    else if ([tagName isEqualToString:@"fb"])
    {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        if ([error isKindOfClass:[NSNull class]])
        {
            NSLog(@"Home -> Server response error for StoreFB: %@  & Error: %@", temp, error);
        }
    }

    else if ([tagName isEqualToString:@"saveIpAddress"])
    {
        NSError *error;
        NSMutableDictionary *dict = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        //NSLog(@"Home -> SERVER RESPONSE for saveIpAddress: %@", dict);
        if ([error isKindOfClass:[NSNull class]])
        {
            NSLog(@"Home -> Server response error for saveIpAddress: %@  & Error: %@", dict, error);
        }
        BOOL shouldDisplayRefCampaign= [[ARPowerHookManager getValueForHookById:@"RefCmpgn_YorN"] boolValue];
        
        if (shouldDisplayRefCampaign)
        {
            NSLog(@"ShouldDisplayRefCampaign block fired");
            [ARPowerHookManager executeBlockWithId:@"goToReferScrn"
                                              data:@{ @"shouldDisplayAlert" : @"YES",
                                                      @"alertText" : @"Here you can see your unique Referral Code. Send it out to anyone as often as you'd like and you'll get $5 when the first 5 people sign up with your code and makes a payment."
                                                      }
                                           context:self];
        }
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

-(void)hide
{
    [self.hud hide:YES];
}

-(void)FavoriteContactsProcessing
{
    //NSLog(@"FavoriteContactsProcessing fired. [[[assist shared] assosAll] count] is: %lu",(unsigned long)[[[assist shared] assosAll] count]);

    shouldBreakLoop = false;
    loopIteration = 0;

    NSMutableArray * AbContactsWithAnEmail = [[NSMutableArray alloc] init];

    // This loop creates an Array of ONLY AB contacts that have an Email Address (as opposed to just a phone number)
    for (int x = 0; x < [[[assist shared] assosAll] count]; x++)
    {
        if (  [[[[assist shared] assosAll] objectAtIndex:x] valueForKey:@"UserName"] &&
            ![[[[[assist shared] assosAll] objectAtIndex:x] valueForKey:@"UserName"] isKindOfClass:[NSNull class]])
        {
            [AbContactsWithAnEmail addObject:[[[assist shared] assosAll] objectAtIndex:x]];
        }
        else
        {
            continue;
        }
    }

    for (int i = 0; i < [AbContactsWithAnEmail count]; i++)
    {
        loopIteration += 1;

        if ([AbContactsWithAnEmail count] < 5)
        {
             [favorites addObject:[AbContactsWithAnEmail objectAtIndex:i]];
        }
        else if ([favorites count] == 5)
        {
                //NSLog(@"FavContactsProcessing --> BREAK (fav count == 5)");
                break;
        }
        else
        {
            if (loopIteration > 200 || i > 200)
            {
                NSLog(@"Home -> FavContProc -> loopIteration > 200");
                [ARTrackingManager trackEvent:@"Home_FavContProc_Over200_1"];
                break;
            }
            else if ( i >= [AbContactsWithAnEmail count] - 1 &&
                     [AbContactsWithAnEmail count] > 5 )
            {
                NSLog(@"FavContactsProcessing --> 'else if' that shouldn't ever be called");
                i = 0;
            }

            NSUInteger randomIndex = arc4random() % [AbContactsWithAnEmail count];

            // CHECKING IF THE ADDRESS BOOK CONTACT IS ALREADY A NOOCHER'S FAV FROM SERVER
            for (int j = 0; j < [favorites count]; j++)
            {
                // In case of Server Record
                if (  [[favorites objectAtIndex:j] valueForKey:@"eMailId"] &&
                    ![[[favorites objectAtIndex:j] valueForKey:@"eMailId"]isKindOfClass:[NSNull class]])
                {
                    if ([[[favorites objectAtIndex:j] valueForKey:@"eMailId"] isEqualToString:[[AbContactsWithAnEmail objectAtIndex:randomIndex]valueForKey:@"UserName"]])
                    {
                        //NSLog(@"***RandomAB Contact ('%@') matches Favorite Already on List From Server (%@)", [[favorites objectAtIndex:j] valueForKey:@"eMailId"], [[AbContactsWithAnEmail objectAtIndex:randomIndex]valueForKey:@"UserName"]);
                        shouldBreakLoop = true;
                    }
                }
                // In case of Address book
                else if (  [[favorites objectAtIndex:j] valueForKey:@"UserName"] &&
                         ![[[favorites objectAtIndex:j] valueForKey:@"UserName"]isKindOfClass:[NSNull class]])
                {
                    if ([[[favorites objectAtIndex:j] valueForKey:@"UserName"] isEqualToString:[[AbContactsWithAnEmail objectAtIndex:randomIndex] valueForKey:@"UserName"]])
                    {
                        //NSLog(@"***RandomAB Contact ('%@') matches Favorite Already on List From AB (%@)", [[favorites objectAtIndex:j] valueForKey:@"UserName"], [[AbContactsWithAnEmail objectAtIndex:randomIndex]valueForKey:@"UserName"]);
                        shouldBreakLoop = true;
                    }
                }

                if (j > 6)
                {
                    [ARTrackingManager trackEvent:@"Home_FavContProc_jOver6"];
                    break;
                }
            }

            // Continue outer loop (i.e. end this loop & DON'T add this iteration into Favorites below)
            if (shouldBreakLoop)
            {
                shouldBreakLoop = false;
                continue;
            }

            // FINALLY, IF IT MAKES IT TO HERE, THEN ADD THE CONTACT TO THE FAVORITES ARRAY
            else if ( [[AbContactsWithAnEmail objectAtIndex:randomIndex] valueForKey:@"UserName"] &&
                    ![[[AbContactsWithAnEmail objectAtIndex:randomIndex] valueForKey:@"UserName"] isKindOfClass:[NSNull class]])
            {
                [favorites addObject:[AbContactsWithAnEmail objectAtIndex:randomIndex]];
            }
        }
    }

    shouldBreakLoop = false;

    [_carousel reloadData];
}

#pragma mark- Date From String
-(NSDate*)dateFromString:(NSString*)aStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];

    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";

    NSDate * aDate = [dateFormatter dateFromString:aStr];

    return aDate;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end