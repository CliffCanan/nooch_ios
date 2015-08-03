//  SelectRecipient.m
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "SelectRecipient.h"
#import "UIImageView+WebCache.h"
#import "Helpers.h"
#import "ECSlidingViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MBProgressHUD.h"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@interface SelectRecipient ()
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) NSMutableArray *recents;
@property(nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property(nonatomic) BOOL location;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UISegmentedControl * recent_location;
@property(nonatomic,strong) UIImageView*noContact_img;
@property(nonatomic, strong) UILabel * glyph_recent;
@property(nonatomic, strong) UILabel * glyph_location;
@property(nonatomic, strong) UILabel * glyph_emptyLoc;
@property(nonatomic, strong) UILabel * glyphEmail;
@property(nonatomic, strong) UILabel * emptyLocBody;
@property(nonatomic, strong) UILabel * emptyLocHdr;
@property(nonatomic, strong) UIImageView * backgroundImage;
@end

@implementation SelectRecipient

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

    self.location = NO;
    self.navigationController.navigationBar.topItem.title = @"";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    [self.navigationItem setLeftBarButtonItem:nil];
    UIButton * back_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

    isPayBack = NO;
    isAddRequest = NO;
    if ([[assist shared] isRequestMultiple]) {
        isAddRequest=YES;
    }
    else {
        [arrRecipientsForRequest removeAllObjects];
        [[assist shared]setArray:[arrRecipientsForRequest copy]];
    }
    isUserByLocation = NO;
    isphoneBook = NO;

    arrRequestPersons = [[NSMutableArray alloc]init];

    NSArray *seg_items = @[NSLocalizedString(@"SelectRecip_RecentToggle", @"Select Recipient Recent Segmented Toggle"),NSLocalizedString(@"SelectRecip_LocationToggle", @"Select Recipient Find By Location Segemented Toggle")];
    self.recent_location = [[UISegmentedControl alloc] initWithItems:seg_items];
    [self.recent_location setStyleId:@"history_segcontrol"];
    [self.recent_location addTarget:self action:@selector(recent_or_location:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.recent_location];
    [self.recent_location setSelectedSegmentIndex:0];
    [self.recent_location setTintColor:kNoochBlue];

    self.glyph_recent = [UILabel new];
    [self.glyph_recent setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [self.glyph_recent setFrame:CGRectMake(32, 12, 22, 19)];
    [self.glyph_recent setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
    [self.glyph_recent setTextColor:[UIColor whiteColor]];
    [self.glyph_recent setAlpha: 1];
    [self.view addSubview:self.glyph_recent];

    self.glyph_location = [UILabel new];
    [self.glyph_location setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [self.glyph_location setFrame:CGRectMake(168, 12, 20, 18)];
    [self.glyph_location setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"]];
    [self.glyph_location setTextColor: kNoochBlue];
    [self.glyph_location setAlpha: 1];
    [self.view addSubview:self.glyph_location];

    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    search.searchBarStyle = UISearchBarStyleMinimal;
    search.placeholder = NSLocalizedString(@"SelectRecip_SearchPlaceholder", @"Select Recipient Search Bar Placeholder");
    [search setDelegate:self];
    [search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [search setImage:[UIImage imageNamed:@"clear_white"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];

    for (UIView *subView1 in search.subviews)
    {
        for (id subview2 in subView1.subviews)
        {
            if ([subview2 isKindOfClass:[UITextField class]])
            {
                ((UITextField *)subview2).textColor = [UIColor whiteColor];
                ((UITextField *)subview2).font = [UIFont fontWithName:@"Roboto-medium" size:16];
                [((UITextField *)subview2) setClearButtonMode:UITextFieldViewModeWhileEditing];
                 break;
            }
        }
    }

    [self.view addSubview:search];

    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 82, 320, [[UIScreen mainScreen] bounds].size.height - 147)];
    [self.contacts setDataSource:self];
    [self.contacts setDelegate:self];
    [self.contacts setSectionHeaderHeight:28];
    [self.contacts setStyleId:@"select_recipientwithoutSeperator"];
    [self.contacts setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.contacts];
    [self.contacts reloadData];

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];

    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    self.noContact_img = [[UIImageView alloc] init];
    self.noContact_img.contentMode = UIViewContentModeScaleAspectFit;

    self.glyphEmail = [[UILabel alloc] initWithFrame:CGRectMake(115, 125, 30, 30)];
    [self.glyphEmail setTextColor:kNoochPurple];
    [self.glyphEmail setAlpha:.2];
    [self.view addSubview:self.glyphEmail];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [search setHidden:NO];
    self.screenName = @"SelectRecipient Screen";
    self.artisanNameTag = @"Select Recipient Screen";

    if ([[assist shared] isRequestMultiple] && isAddRequest)
    {
        self.location = NO;
        [self.navigationItem setHidesBackButton:YES];
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setTitle:@"Group Request"];
        [self.navigationItem setRightBarButtonItem:Nil];

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Recipients"
                                                     message:@"To request money from more than one person, search for friends then tap each additional person (up to 10).\n\nTap 'Done' when finished."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];

        UIButton * Done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        Done.frame = CGRectMake(307, 25, 16, 35);
        [Done setStyleId:@"icon_RequestMultiple"];
        [Done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Done setTitle:@"     Done" forState:UIControlStateNormal];
        [Done setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.15) forState:UIControlStateNormal];
        Done.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [Done addTarget:self action:@selector(DoneEditing_RequestMultiple:) forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem * DoneItem = [[UIBarButtonItem alloc] initWithCustomView:Done];
        [self.navigationItem setRightBarButtonItem:DoneItem];

        if ([arrRequestPersons count] == 0)
        {
            arrRequestPersons = [self.recents mutableCopy];
        }
        else
        {
            int loc =-1;
            for (int i = 0; i < [self.recents count] ; i++)
            {
                NSDictionary * dict = [self.recents objectAtIndex:i];
                for (int j = 0; j < [arrRequestPersons count]; j++)
                {
                   NSDictionary * dictSub = [arrRequestPersons objectAtIndex:j];
                     if ([[dict valueForKey:@"MemberId"]caseInsensitiveCompare:[dictSub valueForKey:@"MemberId"] ] == NSOrderedSame)
                        loc=1;
                }
                if (loc == -1)
                    [arrRequestPersons addObject:dict];
                else
                    loc =-1;
            }
        }
        //NSLog(@"%@",arrRequestPersons);
        [self.contacts reloadData];
    }
    else
    {
        [self.navigationItem setTitle:NSLocalizedString(@"SelectRecipientScrnTitle", @"Select Recipient Screen Title")];
        [self.navigationItem setHidesBackButton:YES];

        NSShadow * shadowNavText = [[NSShadow alloc] init];
        shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
        shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
        NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

        if (!isFromBankWebView)
        {
            UILabel * back_button = [UILabel new];
            [back_button setUserInteractionEnabled:YES];
            UITapGestureRecognizer * backTap;
            [back_button setStyleId:@"navbar_back"];
            back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];
            backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backPressed_SelectRecip)];
            [back_button addGestureRecognizer: backTap];

            UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
            [self.navigationItem setLeftBarButtonItem:menu];
        }
        else
        {
            UIButton * Done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            Done.frame = CGRectMake(307, 25, 16, 35);
            [Done setStyleId:@"icon_RequestMultiple"];
            [Done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [Done setTitle:@"Home" forState:UIControlStateNormal];
            [Done setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.16) forState:UIControlStateNormal];
            Done.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
            [Done addTarget:self action:@selector(backPressed_FrmBnkWbView) forControlEvents:UIControlEventTouchUpInside];

            UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithCustomView:Done];
            [self.navigationItem setLeftBarButtonItem:backItem];
        }

        [self.navigationItem setRightBarButtonItem:Nil];

        [[assist shared]setRequestMultiple:NO];
        self.location = NO;

        if (emailEntry || phoneNumEntry)
        {
            [self searchBarTextDidBeginEditing:search];
        }
    }

    [self.recent_location setSelectedSegmentIndex:0];

    if (!emailEntry && !phoneNumEntry)
    {
        [ARTrackingManager trackEvent:@"SelectRecip_viewWillAppear1"];

        if ([self.recents count] == 0)
        {
            //[self.contacts setHidden:YES];
            [self.view addSubview: self.noContact_img];
        }

        [self.glyphEmail setAlpha: 0];

        [self.recent_location setTintColor:kNoochBlue];
        [search setTintColor:kNoochBlue];

        isphoneBook = NO;
        isUserByLocation = NO;
        isRecentList = YES;
        searching = NO;

        search.text = @"";
        [search resignFirstResponder];
        search.searchBarStyle = UISearchBarStyleMinimal;
        [search setShowsCancelButton:NO animated:YES];
        [self.contacts setStyleId:@"select_recipient"];

        if (navIsUp == YES) {
            navIsUp = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self lowerNavBar];
            });
        }

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.12];
        [self.contacts setAlpha:0];
        [UIView commitAnimations];

        //NSLog(@"noRecentContacts is: %d",noRecentContacts);

        if (noRecentContacts == true)
        {
            [self displayFirstTimeUserImg];
        }
        else
        {
            RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
            spinner1.color = [UIColor whiteColor];
            self.hud.customView = spinner1;
            self.hud.labelText = NSLocalizedString(@"SelectRecip_RecentLoading", @"Select Recipient Recent List Loading Text");
            self.hud.detailsLabelText = nil;
            [self.hud show:YES];

            serve * recents = [serve new];
            [recents setTagName:@"recents"];
            [recents setDelegate:self];
            [recents getRecents];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //[self facebook];

    if ((ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted) &&
        !isAddRequest && !emailEntry && !phoneNumEntry)
    {
        NSLog(@"Contacts permission denied");
        NSLog(@"screenLoadedTimes is: %d  and  shouldNotDisplayContactsAlert is: %d",screenLoadedTimes,[user boolForKey:@"shouldNotDisplayContactsAlert"]);

        if (screenLoadedTimes % 2 == 0 &&
            ![user boolForKey:@"shouldNotDisplayContactsAlert"])
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Access To Contacts"
                                                            message:@"Did you know you can send money to ANY email address OR phone number? It's really helpful to select a contact you already have in your iPhone's Address Book.\n\nTO ENABLE, turn on access to Contacts in your iPhone's Settings:\n\nSettings --> 'Privacy' --> 'Contacts'"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Don't Show Again", nil];
            [alert setTag:2];
            [alert show];
        }
        screenLoadedTimes += 1;
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        NSLog(@"AB Authorized");
        [self address_book];
    }
    else
    {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted)
            {
                NSLog(@"AB Just denied");
                return;
            }
            [self address_book];
            NSLog(@"AD Just authorized");

        });
        NSLog(@"AB Not determined");
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (!emailEntry && !phoneNumEntry)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.12];
        [self.contacts setAlpha:0];
        [UIView commitAnimations];
    }
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

-(void)backPressed_SelectRecip
{
    [[assist shared]setneedsReload:NO]; //Going right back to Home, so don't really need to reload

    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backPressed_FrmBnkWbView
{
    [[assist shared] setneedsReload:NO]; //Going right back to Home, so don't really need to reload

    [self.navigationItem setLeftBarButtonItem:nil];

    Home * goHome = [Home new];
    [self.navigationController pushViewController:goHome animated:YES];
}

-(void)DoneEditing_RequestMultiple:(id)sender
{
    if ([[[assist shared]getArray] count] == 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"But Whooo?"
                                                     message:@"\xF0\x9F\x98\x95\nPlease select at least one recipient. Otherwise it makes it way harder to know where to send your request!"
                                                    delegate:Nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    [search resignFirstResponder];

    if (navIsUp == YES) {
        navIsUp = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self lowerNavBar];
        });
    }
    isAddRequest = NO;
    isFromHome = NO;
    isFromMyApt = NO;

    HowMuch * how_much = [[HowMuch alloc] init];
    [self.navigationController pushViewController:how_much animated:YES];
}

-(void)lowerNavBar
{
    NSLog(@"LOWER NAV BAR FIRED!");
    //[nav_ctrl setNavigationBarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateKeyframesWithDuration:0.3
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [self.recent_location setFrame:CGRectMake(7, 6, 306, 30)];
                                      [self.recent_location setAlpha: 1];
                                      [self.view setBackgroundColor:[UIColor whiteColor]];
                                      [self.contacts setFrame:CGRectMake(0, 82, 320, [[UIScreen mainScreen] bounds].size.height - 147)];
                                      [self.glyph_recent setAlpha: 1];
                                      [self.glyph_location setAlpha: 1];
                                      search.placeholder = @"Search by Name or Enter an Email";
                                      [search setFrame:CGRectMake(0, 40, 320, 40)];
                                      [search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

                                  }];
                              } completion: nil
    ];
}

-(void)address_book
{
    NSMutableArray * additions = [NSMutableArray new];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);

    for (int i = 0; i < nPeople; i++)
    {
        NSMutableDictionary * curContact = [[NSMutableDictionary alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSString * contacName;
        
        CFTypeRef contacNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        contacName = [[NSString stringWithFormat:@"%@", contacNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (contacNameValue)
            CFRelease(contacNameValue);

        NSString * firstName;
        NSString * lastName;
        NSData * contactImage;

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

        if (contacName != NULL) [curContact setObject:contacName forKey:@"Name"];
        if (firstName != NULL) [curContact setObject:firstName forKey:@"FirstName"];
        if (lastName != NULL) [curContact setObject:lastName forKey:@"LastName"];
        [curContact setObject:@"YES" forKey:@"addressbook"];

        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);

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
                [curContact setObject:[NSString stringWithFormat:@"%d",j+1] forKey:@"emailCount"];
            }
            if (emailIdValue) {
                CFRelease(emailIdValue);
            }
        }

        if (emailInfo) {
            CFRelease(emailInfo);
        }


        // Get phoneValue Ref
        NSString *phone;//, *phone2, *phone3;

        for (int j = 0; j < ABMultiValueGetCount(phoneNumber); j++)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, j);
            phone = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            if (phoneValue)
                CFRelease(phoneValue);

            if (phone != NULL)
            {
                phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];

                if ([phone length] == 11) // In case the number begins with '1'
                {
                    phone = [phone substringFromIndex:1];
                }

                [curContact setObject:phone forKey:@"phoneNo"];
                [curContact setObject:phone forKey:[NSString stringWithFormat:@"phoneAdday%d",j]];
                [curContact setObject:[NSString stringWithFormat:@"%d",j+1] forKey:@"phoneCount"];

                [additions addObject:curContact];
            }
            
        }
        
        if (phoneNumber) {
            CFRelease(phoneNumber);
        }

        else
        {
            [additions addObject:curContact];
        }
    }

    [[assist shared] addAssos:additions.mutableCopy];
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

    serve *get_ids = [serve new];
    [get_ids setDelegate:self];
    [get_ids setTagName:@"getMemberIds"];
    [get_ids getMemberIds:get_ids_input];

     if (people)
    CFRelease(people);
     if (addressBook)
    CFRelease(addressBook);
}

-(void)recent_or_location:(UISegmentedControl *)sender
{
    [search resignFirstResponder];
    [search setText:@""];
    searching = NO;
    
    if (sender.selectedSegmentIndex == 0)
    {
        self.location = NO;

        if (![self.view.subviews containsObject:self.hud])
        {
            RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
            spinner1.color = [UIColor whiteColor];
            self.hud.customView = spinner1;
            self.hud.labelText = NSLocalizedString(@"SelectRecip_RecentLoading2", @"Select Recipient Recent List Loading Text 2");
            self.hud.detailsLabelText = nil;
            [self.hud show:YES];
        }
        [self.glyph_recent setTextColor: [UIColor whiteColor]];
        [self.glyph_location setTextColor: kNoochBlue];

        serve *recents = [serve new];
        [recents setTagName:@"recents"];
        [recents setDelegate:self];
        [recents getRecents];
    }
    else
    {
        [self.glyph_recent setTextColor:kNoochBlue];
        [self.glyph_location setTextColor: [UIColor whiteColor]];
        
        self.location = YES;
        [search setHidden:YES];

        if ([self.view.subviews containsObject:self.noContact_img])
        {
            [UIView animateKeyframesWithDuration:.3
                                           delay:0
                                         options:1 << 16
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                              [self.noContact_img setAlpha:0];
                                          }];
                                      } completion: ^(BOOL finished){
                                          [self.noContact_img removeFromSuperview];
                                      }
             ];
        }

        [UIView animateKeyframesWithDuration:.3
                                       delay:0
                                     options:1 << 16
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                          CGRect frame = self.contacts.frame;
                                          frame.origin.y = 44;
                                          frame.size.height = [[UIScreen mainScreen] bounds].size.height - 108;
                                          [self.contacts setFrame:frame];
                                      }];
                                  } completion: ^(BOOL finished){
                                      
                                  }
         ];
        

        //location
        locationManager = [[CLLocationManager alloc] init];

        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            locationUpdateDelay = 0.6; // Setting the time for a delay so the server can receive the location and update the DB before trying to caluculate nearby users (otherwise it will not have time and may just use "0,0")
            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
                // Sending a message to avoid compile time error
                
                [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                           to:locationManager
                                                         from:self
                                                     forEvent:nil];
            }
            [locationManager startUpdatingLocation];
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SelectRecip_NoLocAlertTitle", @"Select Recipient No Location Alert Title")
                                                            message:NSLocalizedString(@"SelectRecip_NoLocAlertBody", @"Select Recipient No Locaiton Alert Body Text")
                                                           delegate:Nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:Nil, nil];
            [alert show];
            
            [self displayEmpty_SearchByLocation];
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized  ||
                 [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            locationUpdateDelay = 0;

            [self.recents removeAllObjects];
            [self.contacts reloadData];

            RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWordPress];
            spinner2.color = [UIColor whiteColor];
            self.hud.customView = spinner2;
            self.hud.labelText = NSLocalizedString(@"SelectRecip_LoadingLocation", @"Select Recipient Find By Location Loading Text");
            self.hud.detailsLabelText = nil;
            [self.hud show:YES];

            [locationManager startUpdatingLocation];
        }
    }
}

-(void)displayEmpty_SearchByLocation
{
    [self.hud hide:YES];

    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    [self.backgroundImage setAlpha:0];
    [self.view addSubview:self.backgroundImage];
    [self.view sendSubviewToBack:self.backgroundImage];

    NSShadow * shadow_white = [[NSShadow alloc] init];
    shadow_white.shadowColor = [UIColor whiteColor];
    shadow_white.shadowOffset = CGSizeMake(0, 1.0);
    NSDictionary * shadowWhite = @{NSShadowAttributeName: shadow_white};

    NSShadow * shadow_Dark = [[NSShadow alloc] init];
    shadow_Dark.shadowColor = Rgb2UIColor(88, 90, 92, .85);
    shadow_Dark.shadowOffset = CGSizeMake(0, -2.5);
    NSDictionary * shadowDark = @{NSShadowAttributeName: shadow_Dark};

    self.glyph_emptyLoc = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 280, 74)];
    [self.glyph_emptyLoc setFont:[UIFont fontWithName:@"FontAwesome" size:72]];
    self.glyph_emptyLoc.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"] attributes:shadowDark];
    [self.glyph_emptyLoc setTextAlignment:NSTextAlignmentCenter];
    [self.glyph_emptyLoc setTextColor: kNoochGrayLight];
    [self.glyph_emptyLoc setAlpha:0];
    [self.view addSubview:self.glyph_emptyLoc];

    self.emptyLocHdr = [[UILabel alloc] initWithFrame:CGRectMake(20, 146, 280, 40)];
    [self.emptyLocHdr setFont:[UIFont fontWithName:@"Roboto-regular" size: 23]];
    self.emptyLocHdr.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SelectRecip_NoNearbyUsers", @"Select Recipient No Nearby Users Title") attributes:shadowWhite];
    [self.emptyLocHdr setTextColor:kNoochGrayLight];
    [self.emptyLocHdr setTextAlignment:NSTextAlignmentCenter];
    [self.emptyLocHdr setAlpha:0];
    [self.view addSubview: self.emptyLocHdr];
    
    self.emptyLocBody = [[UILabel alloc] initWithFrame:CGRectMake(16, 185, 288, 95)];
    [self.emptyLocBody setFont:[UIFont fontWithName:@"Roboto-light" size: 18]];
    self.emptyLocBody.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SelectRecip_NoNearbyUsersBody", @"Select Recipient No Nearby Users Body Text") attributes:shadowWhite];
    [self.emptyLocBody setTextColor:kNoochGrayLight];
    [self.emptyLocBody setTextAlignment:NSTextAlignmentCenter];
    [self.emptyLocBody setNumberOfLines:0];
    [self.emptyLocBody setAlpha:0];
    [self.view addSubview: self.emptyLocBody];

    [UIView animateKeyframesWithDuration:0.45
                                   delay:0
                                 options:2 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.7 animations:^{
                                      self.contacts.alpha = 0;
                                      [self.backgroundImage setAlpha: .5];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:.25 relativeDuration:.75 animations:^{
                                      [self.emptyLocHdr setAlpha:1];
                                      [self.emptyLocBody setAlpha:1];
                                      [self.glyph_emptyLoc setStyleClass:@"animate_bubble_noAlpha"];
                                      [self.glyph_emptyLoc setAlpha:1];
                                  }];
                              } completion: ^(BOOL finished){
                                  [search setHidden:YES];
                              }
     ];
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];

    CLLocationCoordinate2D loc = manager.location.coordinate;

    [[assist shared] setlocationAllowed:YES];

    serve * serveOBJ = [serve new];
    [serveOBJ UpDateLatLongOfUser:[[NSString alloc] initWithFormat:@"%f",loc.latitude]
                              lng:[[NSString alloc] initWithFormat:@"%f",loc.longitude]];


    NSString * searchRadiusString = [ARPowerHookManager getValueForHookById:@"srchRds"];
    short searchRadiusInt = [searchRadiusString integerValue];

    if (searchRadiusInt < 2) // Just in case value from Artisan is unavailable for some reason, we'll use a default of 12M
    {
        searchRadiusString = @"12";
    }

    serve * ser = [serve new];
    ser.tagName = @"searchByLocation";
    [ser setDelegate:self];
    [ser performSelector:@selector(getLocationBasedSearch:) withObject:searchRadiusString afterDelay:locationUpdateDelay];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [[assist shared] setlocationAllowed:NO];
    
    NSLog(@"Select Recipient - Location Tab: Location Mgr Error : %@",error);

    [self.hud hide:YES];
    if ([error code] == kCLErrorDenied)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SelectRecip_NeedLocAccessTitle", @"Select Recipient Need Location Alert Title")
                                                        message:NSLocalizedString(@"SelectRecip_NeedLocAccessBody", @"Select Recipient Need Location Alert Body Text")
                                                       delegate:Nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:Nil, nil];
        [alert show];
    }
    else
    {
        [self performSelector:@selector(simulateSegControlChanged) withObject:Nil afterDelay:1.5];

        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Location Error"
                                                        message:@"Sorry to say, but we're having trouble getting your location to find nearby users. Please try again or contact Nooch support so we can exterminate any bugs!"
                                                       delegate:Nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:Nil, nil];
        [alert show];
    }
}

- (void)simulateSegControlChanged
{
    self.recent_location.selectedSegmentIndex = 0;
    [self.recent_location sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)phonebook:(id)sender
{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self.view removeConstraints:self.view.constraints];
    NSArray * displayedItems = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:kABPersonEmailProperty],
                               nil];
    _addressBookController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _addressBookController.view.translatesAutoresizingMaskIntoConstraints=YES;
	[_addressBookController.view removeConstraints:_addressBookController.view.constraints];
    _addressBookController.displayedProperties = displayedItems;
    [self presentViewController:_addressBookController animated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue) ;

    NSLog(@"Email Address: %@",emailAddresses);

    if (emailMultiValue)
    CFRelease(emailMultiValue);
    [_addressBookController dismissViewControllerAnimated:YES completion:^{
        if ([emailAddresses count] == 0)
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Uh Oh"
                                                            message:NSLocalizedString(@"SelectRecip_NoEmailSelected", @"Select Recipient No Email Address Selected Alert Body")
                                                           delegate:Nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:Nil, nil];
            [alert show];
        }
        else if ([emailAddresses count] == 1)
        {
            emailphoneBook = [emailAddresses objectAtIndex:0];
            isphoneBook = YES;
            [self getMemberIdByUsingUserNameFromPhoneBook];
        }
        /*else
        {
            UIActionSheet * actionSheet = [[UIActionSheet alloc]init];
            [actionSheet setDelegate:self];

            for (int i = 0 ; i < [emailAddresses count]; i++)
            {
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@",[emailAddresses objectAtIndex:i]]];
            }
            actionSheet.tag = 1111;
            [actionSheet addButtonWithTitle:@"Cancel"];
            [actionSheet showInView:self.view];
        }*/
    }];
    return NO;
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *_currentView in actionSheet.subviews)
    {
        if ([_currentView isKindOfClass:[UILabel class]])
        {
            [((UILabel *)_currentView) setFont:[UIFont boldSystemFontOfSize:15.f]];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet tag] == 1111)  // Not sure that this is ever actually called or necessary
    {
        if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
        {
            emailphoneBook = [actionSheet buttonTitleAtIndex:buttonIndex];
            isphoneBook = YES;
            [self getMemberIdByUsingUserNameFromPhoneBook];
        }
    }
    else if ([actionSheet tag] == 1122)
    {
        NSString * selectedEmail = [actionSheet buttonTitleAtIndex:buttonIndex];
        emailphoneBook = selectedEmail;
        isphoneBook = YES;

        if ([emailphoneBook isEqualToString:[user objectForKey:@"UserName"]])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SelectRecip_VerySneaky", @"Select Recipient Very Sneaky Alert Title")
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB1\n%@", NSLocalizedString(@"SelectRecip_VerySneakyBody", @"Select Recipient Very Sneak Body Text")]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if (![selectedEmail isEqualToString:@"Cancel"])
        {
            [search resignFirstResponder];

            RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleCircleFlip];
            spinner2.color = [UIColor whiteColor];
            self.hud.customView = spinner2;
            self.hud.labelText = NSLocalizedString(@"SelectRecip_HUDchecking", @"Select Recipient HUD Checking Text");
            self.hud.detailsLabelText = [NSString stringWithFormat:@"'%@'",[selectedEmail lowercaseString]];
            self.hud.detailsLabelColor = [UIColor whiteColor];
            [self.hud show:YES];

            serve * emailCheck = [serve new];
            emailCheck.Delegate = self;
            emailCheck.tagName = @"emailCheck";
            [emailCheck getMemIdFromuUsername:[selectedEmail lowercaseString]];
        }
    }
    else if ([actionSheet tag] == 223)
    {
        NSString * selectedPhone = [actionSheet buttonTitleAtIndex:buttonIndex];
        phoneBookPhoneNum = selectedPhone;
        isphoneBook = YES;
        
        if (![selectedPhone isEqualToString:@"Cancel"])
        {
            [search resignFirstResponder];

            RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave];
            spinner2.color = [UIColor whiteColor];
            self.hud.customView = spinner2;
            self.hud.labelText = NSLocalizedString(@"SelectRecip_HUDchecking2", @"Select Recipient HUD Checking Text");
            self.hud.detailsLabelText = [NSString stringWithFormat:@"'%@'", selectedPhone];
            [self.hud show:YES];

            NSString * s = selectedPhone;
            s = [s stringByReplacingOccurrencesOfString:@"("
                                             withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@")"
                                             withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@"-"
                                             withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@" "
                                             withString:@""];

            serve * phoneCheck = [serve new];
            phoneCheck.Delegate = self;
            phoneCheck.tagName = @"phoneCheck";
            [phoneCheck getMemIdFromPhoneNumber:s];
        }
    }
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    isphoneBook = NO;
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self lowerNavBar];

    if ([self.recents count] == 0)
    {
        [self.contacts setHidden:YES];
        [self.view addSubview: self.noContact_img];
    }

    searching = NO;
    emailEntry = NO;
    phoneNumEntry = NO;
    isphoneBook = NO;
    isRecentList = YES;

    [self.glyphEmail setAlpha: 0];

    [self.recent_location setTintColor:kNoochBlue];

    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.contacts setStyleId:@"select_recipient"];
    [self.contacts reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];

    [self.contacts reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (!isAddRequest)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        navIsUp = YES;
    }

    [search setTintColor:[UIColor whiteColor]]; // For the 'Cancel' text

    [UIView animateKeyframesWithDuration:0.38
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.2 animations:^{
                                      if (!isAddRequest)
                                      {
                                          [self.contacts setFrame:CGRectMake(0, 70, 320, [[UIScreen mainScreen] bounds].size.height - 56)];
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                      if ([self.view.subviews containsObject:self.noContact_img])
                                      {
                                          [self.noContact_img setAlpha:0];
                                      }
                                      [self.view setBackgroundColor:kNoochBlue];
                                      [self.contacts setAlpha:1];
                                      if (!isAddRequest)
                                      {
                                          [self.recent_location setTintColor:kNoochBlue];
                                          [self.recent_location setAlpha:0];
                                          [self.glyph_recent setAlpha: 0];
                                          [self.glyph_location setAlpha: 0];
                                      }
                                      else
                                      {
                                          [self.recent_location setTintColor:[UIColor whiteColor]];
                                      }
                                      [search setImage:[UIImage imageNamed:@"search_white"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      if (!isAddRequest)
                                      {
                                          [self.recent_location setFrame:CGRectMake(7, -8, 306, 30)];
                                          [searchBar setFrame:CGRectMake(0, 24, 320, 40)];
                                      }
                                      searchBar.placeholder = @"";
                                  }];
                              } completion: ^(BOOL finished){
                                  if ([self.view.subviews containsObject:self.noContact_img])
                                  {
                                      [self.noContact_img removeFromSuperview];
                                  }
                              }
     ];

    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar setKeyboardType:UIKeyboardTypeEmailAddress];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length] == 0)
    {
        searching = NO;
        emailEntry = NO;
        phoneNumEntry = NO;
        isRecentList = YES;

        [self.glyphEmail setAlpha:0];

        return;
    }

    else if ([searchText length] > 0)
    {
        if ([self.view.subviews containsObject:self.noContact_img])
        {
            [UIView animateKeyframesWithDuration:.3
                                           delay:0
                                         options:1 << 16
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                              [self.noContact_img setAlpha:0];
                                          }];
                                      } completion: ^(BOOL finished){
                                          [self.noContact_img removeFromSuperview];
                                      }
             ];
        }
        [self.contacts setHidden:NO];

        searching = YES;

        NSRange isRange = [searchText rangeOfString:[NSString stringWithFormat:@"@"] options:NSCaseInsensitiveSearch];

        if (isRange.location != NSNotFound)
        {
            emailEntry = YES;
            phoneNumEntry = NO;
            shouldAnimate = YES;
            isphoneBook = NO;
            searching = NO;
            isRecentList = NO;
            searchString = searchText;

            [self.glyphEmail setFont:[UIFont fontWithName:@"FontAwesome" size:22]];
            [self.glyphEmail setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"]];
            int leftValue = ([[UIScreen mainScreen] bounds].size.width / 2) - 49 - (4.9 * [searchString length]);
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.2];
            if (leftValue < 2)
            {
                [self.glyphEmail setAlpha:0];
            }
            else
            {
                [self.glyphEmail setAlpha: 1];
                [self.glyphEmail setFrame:CGRectMake(leftValue, 125, 30, 30)];
            }
            [UIView commitAnimations];

            if (isRange.location < searchText.length - 1)
            {
                shouldAnimate = NO;
            }

            if ([[assist shared] isRequestMultiple]) {
                return;
            }
        }
        else
        {
            emailEntry = NO;
            isphoneBook = NO;
            isRecentList = NO;

            NSString * s = searchText;
            s = [s stringByReplacingOccurrencesOfString:@"("
                                             withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@")"
                                             withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@"-"
                                             withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@" "
                                             withString:@""];

            NSCharacterSet * notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            if ([s rangeOfCharacterFromSet:notDigits].location == NSNotFound &&
                [searchText length] > 3)
            {
                if (s.length > 3)
                {
                    phoneNumEntry = YES;
                    searching = NO;
                    searchString = searchBar.text;
                }

                if (s.length > 4)
                {
                    shouldAnimate = NO;
                }

                if (s.length == 4)
                {
                    NSMutableString * mu = [NSMutableString stringWithString:s];
                    [mu insertString:@"(" atIndex:0];
                    [mu insertString:@")" atIndex:4];
                    [mu insertString:@" " atIndex:5];
                    
                    NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                    searchBar.text = phoneWithSymbolsAddedBack;
                    
                    shouldAnimate = YES;
                }

                if (s.length == 7)
                {
                    NSMutableString * mu = [NSMutableString stringWithString:s];
                    [mu insertString:@"(" atIndex:0];
                    [mu insertString:@")" atIndex:4];
                    [mu insertString:@" " atIndex:5];
                    [mu insertString:@"-" atIndex:9];
                    
                    NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                    searchBar.text = phoneWithSymbolsAddedBack;
                }

                if (phoneNumEntry && [s length] > 3)
                {
                    [self.glyphEmail setFont:[UIFont fontWithName:@"FontAwesome" size:27]];
                    [self.glyphEmail setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"]];
                    int leftValue = ([[UIScreen mainScreen] bounds].size.width / 2) - 38 - (4.5 * [searchString length]);
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:.2];
                    if (leftValue < 3)
                    {
                        [self.glyphEmail setAlpha:0];
                    }
                    else
                    {
                        [self.glyphEmail setFrame:CGRectMake(leftValue, 125, 30, 30)];
                        [self.glyphEmail setAlpha: 1];
                    }
                    [UIView commitAnimations];
                }
                else
                {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:.15];
                    [self.glyphEmail setAlpha: 0];
                    [UIView commitAnimations];
                }
            }
            else
            {
                phoneNumEntry = NO;
                shouldAnimate = NO;
                searching = YES;
                searchString = searchText;
                [self.glyphEmail setAlpha:0];
                [self searchTableView];
            }
        }
        [self.contacts reloadData];
    }

    else
    {
        isphoneBook = NO;
        searchString = [searchBar.text substringToIndex:[searchBar.text length] - 1];
        [self.contacts reloadData];
    }
}

-(void)searchTableView
{
    arrSearchedRecords = [[NSMutableArray alloc]init];

    for (NSString * key in [[assist shared] assos].allKeys)
    {
        NSMutableDictionary * dict = [[assist shared] assos][key];

        NSComparisonResult result;
        NSComparisonResult result2;
        NSComparisonResult result3;

        if ([dict valueForKey:@"FirstName"])
        {
            result = [[dict valueForKey:@"FirstName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        }
        else {
            result = true;
        }

        if ([dict valueForKey:@"LastName"])
        {
            result2 = [[dict valueForKey:@"LastName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        }
        else {
            result2 = true;
        }

        if ([dict valueForKey:@"LastName"] &&
            [dict valueForKey:@"FirstName"])
        {
            NSString * fullName = [NSString stringWithFormat:@"%@ %@", [dict valueForKey:@"FirstName"], [dict valueForKey:@"LastName"]];
            result3 = [fullName compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        }
        else {
            result3 = true;
        }

        if ((result == NSOrderedSame || result2 == NSOrderedSame || result3 == NSOrderedSame) &&
            (dict[@"FirstName"] || dict[@"LastName"]))
        {
            [arrSearchedRecords addObject:dict];
        }
    }

    if (![arrSearchedRecords isKindOfClass:[NSNull class]])
    {
        NSSortDescriptor * sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"FirstName" ascending:YES];
        NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray * temp = [arrSearchedRecords copy];
        [arrSearchedRecords setArray:[temp sortedArrayUsingDescriptors:sortDescriptors]];
    }
}

#pragma mark - Email From Address Book handling
-(void)getMemberIdByUsingUserNameFromPhoneBook
{
    if ([emailphoneBook isEqualToString:[user objectForKey:@"UserName"]])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SelectRecip_TryAgainAlertTitle", @"Select Recipient Try That Again Alert Title")
                                                     message:[NSString stringWithFormat:@"\xE2\x98\x9D\n%@", NSLocalizedString(@"SelectRecip_TryAgainAlertBody", @"Select Recipient Try That Again Alert Body Text")]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
    else
    {
        [search resignFirstResponder];

        serve *emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:emailphoneBook];
    }
}

#pragma mark - Manually Entered Email Handling
-(void)getMemberIdByUsingUserName
{
    if ([[search.text lowercaseString] isEqualToString:[user objectForKey:@"UserName"]])
    {
        [self.hud hide:YES];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SelectRecip_HoldOnThere", @"Select Recipient Hold On There Alert Title")
                                                     message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB1\n%@", NSLocalizedString(@"SelectRecip_HoldOnThereBody", @"Select Recipient Hold On There Alert Body Text")]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
    else
    {
        [search resignFirstResponder];

        serve *emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:[search.text lowercaseString]];
    }
}

#pragma Mark - Manually Entered Phone Number Handling
-(void)getMemberIdByUsingEnteredPhoneNumber
{
    [search resignFirstResponder];

    NSString * s = search.text;
    s = [s stringByReplacingOccurrencesOfString:@"("
                                     withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@")"
                                     withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"-"
                                     withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@" "
                                     withString:@""];

    serve * phoneCheck = [serve new];
    phoneCheck.Delegate = self;
    phoneCheck.tagName = @"phoneCheck";
    [phoneCheck getMemIdFromPhoneNumber:s];
}

#pragma Mark - Phone Number From Address Book Handling
-(void)getMemberIdByUsingPhoneNumberFromAB
{
    [search resignFirstResponder];

    serve * phoneCheck = [serve new];
    phoneCheck.Delegate = self;
    phoneCheck.tagName = @"phoneCheck";
    [phoneCheck getMemIdFromPhoneNumber:phoneBookPhoneNum];
}

#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)loadDelay
{
    NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];
    [arrNav removeLastObject];
    [nav_ctrl setViewControllers:arrNav animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

  /*UIAlertView * alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"SelectRecip_ConnectionErrorAlertTitle", @"Select Recipient Connection Error Alert Title")
                          message:NSLocalizedString(@"SelectRecip_ConnectionErrorAlertBody", @"Select Recipient Connection Error Alert Body Text")
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];*/
}

#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.contacts setNeedsDisplay];
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];

        [timer invalidate];

        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];

        [[assist shared]setPOP:YES];
        [self performSelector:@selector(loadDelay) withObject:Nil afterDelay:1.0];
    }

    else if ([tagName isEqualToString:@"getMemberIds"])
    {
        NSError *error;
        NSMutableDictionary * getMemberIdsResult = [NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error];
        NSMutableArray * phoneEmailListFromServer = [[getMemberIdsResult objectForKey:@"GetMemberIdsResult"] objectForKey:@"phoneEmailList"];
        NSMutableArray * additions = [NSMutableArray new];

        for (NSDictionary * dict in phoneEmailListFromServer)
        {
            NSMutableDictionary * new = [NSMutableDictionary new];

            for (NSString * key in dict.allKeys)
            {
                if ([key isEqualToString:@"memberId"] && [dict[key] length] > 0)
                {
                    [new setObject:dict[key] forKey:@"MemberId"];
                }
                else if ([key isEqualToString:@"emailAddy"])
                {
                    [new setObject:dict[key] forKey:@"UserName"];
                }
                else
                {
                    [new setObject:dict[key] forKey:key];
                }
            }
            if (new[@"MemberId"])
            {
                [additions addObject:new];
            }
        }
        [[assist shared] addAssos:additions];
    }

    else if ([tagName isEqualToString:@"recents"])
    {
        if ([self.view.subviews containsObject:self.hud])
        {
            [self.hud hide:YES];
        }

        NSError * error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        
        NSMutableArray * temp = [NSMutableArray new];
 
        for (NSDictionary * dict in self.recents)
        {
            NSMutableDictionary * prep = dict.mutableCopy;
            [prep setObject:@"YES" forKey:@"recent"];
            [temp addObject:prep];
        }

        self.recents = temp.mutableCopy;
        [[assist shared] addAssos:[self.recents mutableCopy]];

        if ([[assist shared] isRequestMultiple])
        {
            searching = NO;
            emailEntry = NO;
            isRecentList = YES;
            isphoneBook = NO;

            [self.contacts setStyleId:@"select_recipient"];

            [search resignFirstResponder];
            [search setText:@""];
            [search setShowsCancelButton:NO];

            arrRequestPersons = [self.recents mutableCopy];
            //NSLog(@"%@",arrRequestPersons);

            if ([arrRequestPersons count] == 0) {
                arrRequestPersons = [self.recents mutableCopy];
            }
            else
            {
                int loc=-1;
                for (int i = 0; i < [self.recents count]; i++) {
                    NSDictionary * dict = [self.recents objectAtIndex:i];
                    
                    for (int j = 0; j < [arrRequestPersons count]; j++)
                    {
                        NSDictionary * dictSub = [arrRequestPersons objectAtIndex:j];
                        if ([[dict valueForKey:@"MemberId"]caseInsensitiveCompare:[dictSub valueForKey:@"MemberId"]] == NSOrderedSame)
                            loc = 1;
                    }
                    if (loc == -1) {
                        [arrRequestPersons addObject:dict];
                    }
                    else
                        loc=-1;
                }
            }
            //NSLog(@"%@",arrRequestPersons);

            [self.contacts reloadData];
            //return;
        }

        [self.hud hide:YES];
        if ([self.recents count] > 0)
        {
            if ([self.view.subviews containsObject:self.noContact_img])
            {
                [UIView animateKeyframesWithDuration:.3
                                               delay:0
                                             options:1 << 16
                                          animations:^{
                                              [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                                  [self.noContact_img setAlpha:0];
                                              }];
                                          } completion: ^(BOOL finished){
                                              [self.noContact_img removeFromSuperview];
                                          }
                 ];
            }

            if ([self.contacts isHidden]) {
                [self.contacts setHidden:NO];
            }

            [self.contacts setStyleId:@"select_recipient"];
            [self.contacts reloadData];

            [UIView animateKeyframesWithDuration:0.4
                                           delay:0
                                         options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                              [self.backgroundImage setAlpha: 0];
                                              [self.glyph_emptyLoc setAlpha:0];
                                              [self.emptyLocHdr setAlpha:0];
                                              [self.emptyLocBody setAlpha:0];
                                              [search setHidden:NO];
                                          }];
                                          [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.8 animations:^{
                                              CGRect frame = self.contacts.frame;
                                              frame.origin.y = 82;
                                              frame.size.height = [[UIScreen mainScreen] bounds].size.height - 147;
                                              [self.contacts setFrame:frame];
                                          }];
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                              [self.contacts setAlpha: 1];
                                          }];
                                      } completion: ^(BOOL finished){
                                          nil;
                                      }
             ];
        }
        else
        {
            [self displayFirstTimeUserImg];
        }
    }

    else if ([tagName isEqualToString:@"searchByLocation"])
    {
        NSError * error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
    
        self.recents = [self.recents mutableCopy];

        if ([self.recents count] > 0)
        {
            for (int i = 0; i < [ self.recents count]; i++)
            {
                for (int j = i + 1; j < [ self.recents count]; j++)
                {
                    NSDictionary * recordOne = [ self.recents objectAtIndex:i];
                    NSDictionary * recordTwo = [ self.recents objectAtIndex:j];
                    
                    if ([[recordOne valueForKey:@"Miles"] floatValue] > [[recordTwo valueForKey:@"Miles"] floatValue])
                    {
                        [ self.recents exchangeObjectAtIndex:i withObjectAtIndex:j];
                    }
                }   
            }

            [self.noContact_img removeFromSuperview];
            [self.contacts setStyleId:@"select_recipient"];
            if ([self.contacts isHidden]) {
                [self.contacts setHidden:NO];
            }
            [self.contacts setAlpha:1];
            [self.contacts reloadData];
        }
        else
        {
            [self displayEmpty_SearchByLocation];
        }
        [self.hud hide:YES];
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
            [self.hud hide:YES];

            if (!emailEntry && !phoneNumEntry && navIsUp == YES) {
                navIsUp = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self lowerNavBar];
                });
            }

            [self.navigationItem setLeftBarButtonItem:nil];

            if ([[assist shared]isRequestMultiple])
            {
                searching = NO;
                emailEntry = NO;
                isRecentList = NO;
                isphoneBook = NO;
                [search resignFirstResponder];
                [search setText:@""];
                [search setShowsCancelButton:NO];
                [self.contacts reloadData];
                return;
            }

            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            if (isphoneBook)
            {
                [dict setObject:emailphoneBook forKey:@"email"];
                [dict setObject:firstNamePhoneBook forKey:@"firstName"];
                [dict setObject:lastNamePhoneBook forKey:@"lastName"];
            }
            else
                [dict setObject:searchString forKey:@"email"];
            
            [dict setObject:@"nonuser" forKey:@"nonuser"];
            isFromHome = NO;
            isFromMyApt = NO;
            isFromArtisanDonationAlert = NO;

            HowMuch * how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];

            return;
        }
    }

    else if ([tagName isEqualToString:@"phoneCheck"])
    {
        NSError * error;
        NSMutableDictionary * dictResult = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];

        if ([dictResult objectForKey:@"Result"] != [NSNull null])
        {
            if ([[dictResult objectForKey:@"Result"] isEqualToString:[user objectForKey:@"MemberId"]])
            {
                [self.hud hide:YES];
                [search becomeFirstResponder];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Hold On There..."
                                                             message:@"\xF0\x9F\x98\xB1\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try someone ELSE's phone number!"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
            else
            {
                serve * getDetails = [serve new];
                getDetails.Delegate = self;
                getDetails.tagName = @"getMemberDetails";
                [getDetails getDetails:[dictResult objectForKey:@"Result"]];
            }
        }
        else
        {
            [self.hud hide:YES];

            if (!emailEntry && !phoneNumEntry && navIsUp == YES) {
                navIsUp = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self lowerNavBar];
                });
            }

            [self.navigationItem setLeftBarButtonItem:nil];

            if ([[assist shared]isRequestMultiple])
            {
                searching = NO;
                emailEntry = NO;
                isRecentList = NO;
                isphoneBook = NO;
                [search resignFirstResponder];
                [search setText:@""];
                [search setShowsCancelButton:NO];
                [self.contacts reloadData];
                return;
            }

            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            if (isphoneBook)
            {
                [dict setObject:phoneBookPhoneNum forKey:@"phone"];
                [dict setObject:firstNamePhoneBook forKey:@"firstName"];
                [dict setObject:lastNamePhoneBook forKey:@"lastName"];
            }
            else
                [dict setObject:searchString forKey:@"phone"];
            
            [dict setObject:@"nonuser" forKey:@"nonuser"];
            isFromHome = NO;
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

        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setDictionary:[NSJSONSerialization
                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                             options:kNilOptions
                             error:&error]];
        
        if ([[assist shared]isRequestMultiple])
        {
            emailEntry = YES;
            int loc = 0;

            for (int i = 0; i < [arrRequestPersons count]; i++)
            {
                if ([[[arrRequestPersons objectAtIndex:i]valueForKey:@"MemberId"]isEqualToString:[dict valueForKey:@"MemberId"]])
                {
                    loc = 1;
                }
            }

            if (loc == 0) {
                NSString * PhotoUrl = [dict valueForKey:@"PhotoUrl"];
                [dict setObject:PhotoUrl forKey:@"Photo"];
                [arrRequestPersons addObject:dict];
            }
            [self.contacts reloadData];
            [self.hud hide:YES];
            return;
        }
        else
        {
            if (navIsUp == YES) {
                navIsUp = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self lowerNavBar];
                });
            }
            [self.navigationItem setLeftBarButtonItem:nil];

            int loc = 0;

            for (int i = 0; i < [arrRequestPersons count]; i++)
            {
                if ([[[arrRequestPersons objectAtIndex:i]valueForKey:@"MemberId"]isEqualToString:[dict valueForKey:@"MemberId"]]) {
                    loc=1;  
                }
            }

            if (loc == 0)
            {
                NSString * PhotoUrl = [dict valueForKey:@"PhotoUrl"];
                [dict setObject:PhotoUrl forKey:@"Photo"];
                [arrRequestPersons addObject:dict];
            }

            [self.hud hide:YES];

            isFromHome = NO;
            isFromMyApt = NO;
            isFromArtisanDonationAlert = NO;

            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
        }
    }
}

-(void)displayFirstTimeUserImg
{
    if (IS_IPHONE_5)
    {
        self.noContact_img.frame = CGRectMake(0, 82, 320, 405);
        self.noContact_img.image = [UIImage imageNamed:@"SelectRecipIntro"];
    }
    else
    {
        self.noContact_img.frame = CGRectMake(3, 79, 314, 340);
        self.noContact_img.image = [UIImage imageNamed:@"selectRecipIntro_4"];
    }
    [self.noContact_img setAlpha:0];
    [self.view addSubview:self.noContact_img];
    
    [UIView animateKeyframesWithDuration:.4
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                      [self.backgroundImage setAlpha: 0];
                                      [self.glyph_emptyLoc setAlpha:0];
                                      [self.emptyLocHdr setAlpha:0];
                                      [self.emptyLocBody setAlpha:0];
                                      [search setHidden:NO];
                                      [self.contacts setAlpha: 0];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.8 animations:^{
                                      CGRect frame = self.contacts.frame;
                                      frame.origin.y = 82;
                                      frame.size.height = [[UIScreen mainScreen] bounds].size.height - 147;
                                      [self.contacts setFrame:frame];
                                      
                                      [self.noContact_img setAlpha:1];
                                  }];
                              } completion: ^(BOOL finished){
                                  //[self.contacts setHidden:YES];
                              }
     ];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2 && buttonIndex == 1)
    {
        [user setBool:YES forKey:@"shouldNotDisplayContactsAlert"];
        [user synchronize];
        NSLog(@"shouldNotDisplayContactsAlert is: %d",[user boolForKey:@"shouldNotDisplayContactsAlert"]);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 28)];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake (10, 0, 200, 28)];
    [title setTextColor: kNoochGrayDark];
    [title setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];

    if (section == 0)
    {
        if (self.location) {
            title.text = NSLocalizedString(@"SelectRecip_NearbyUsers", @"Select Recipient Nearby Users");
        }
        else if (searching) {
            title.text = NSLocalizedString(@"SelectRecip_SearchResults", @"Select Recipient Search Results");
        }
        else if (isRecentList) {
            title.text = NSLocalizedString(@"SelectRecip_RecentContacts", @"Select Recipient Recent Contacts");
        }
        else if (emailEntry) {
            title.text = NSLocalizedString(@"SelectRecip_Emai", @"Select Recipient Email Address Entry");
        }
        else if (phoneNumEntry) {
            title.text = NSLocalizedString(@"SelectRecip_Phone", @"Select Recipient Phone Number Entry");
        }
    }
    else {
        title.text = @"";
    }
    [headerView addSubview:title];
    [headerView setBackgroundColor:[Helpers hexColor:@"e3e4e5"]];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching)
    {
        return [arrSearchedRecords count];
    }
    else if ([[assist shared] isRequestMultiple])
    {
        return [arrRequestPersons count];
    }
    else if (emailEntry)
    {
        return 1;
    }
    else if (phoneNumEntry)
    {
        return 1;
    }
    else
    {
        return [self.recents count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        cell.indentationLevel = 1;
    }

    for (UIView *subview in cell.contentView.subviews)
    {
        [subview removeFromSuperview];
    }

    [cell.detailTextLabel setText:@""];

    UIImageView * pic = [[UIImageView alloc] initWithFrame:CGRectMake(16, 6, 50, 50)];
    pic.clipsToBounds = YES;

    UIImageView * npic = [UIImageView new];
    npic.clipsToBounds = YES;

    [cell.contentView addSubview:pic];
    [cell.contentView addSubview:npic];

    if (self.location)
    {
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.indentationLevel = 1;
        cell.indentationWidth = 46;
        [cell.textLabel setStyleClass:@"select_recipient_pending_name"];

        NSDictionary * temp;

        if ([[assist shared] isRequestMultiple])
        {
            temp = [arrRequestPersons objectAtIndex:indexPath.row];
            arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];

            int loc = -1;
            
            for (int i = 0; i < [arrRecipientsForRequest count]; i++)
            {
                NSDictionary * dictionary = [arrRecipientsForRequest objectAtIndex:i];
                if ([[dictionary valueForKey:@"MemberId"]isEqualToString:temp[@"MemberId"]]) {
                    loc = 1;
                }
            }
            if (loc == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }
        else
        {
            temp = [self.recents objectAtIndex:indexPath.row];
        }
        
        UIImageView * pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;
        pic.clipsToBounds = YES;
        [pic sd_setImageWithURL:[NSURL URLWithString:temp[@"Photo"]] placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        [cell.contentView addSubview:pic];

        NSString * name = [NSString stringWithFormat:@"   %@ %@",[[temp objectForKey:@"FirstName"] capitalizedString],[[temp objectForKey:@"LastName"] capitalizedString]];
        [cell.textLabel setText:name];

        NSString * miles;
        
        if ([[temp objectForKey:@"Miles"] shortValue] < 1)
        {
            float threshold = 150;
            threshold /= 5280;

            if ([[temp objectForKey:@"Miles"] floatValue] > threshold)
            {
                miles = [NSString stringWithFormat:@"     %.0f feet",([[temp objectForKey:@"Miles"] floatValue] * 5280)];
            }
            else
            {
                miles = @"     < 150 feet";
            }
        }
        else
        {
            miles = [NSString stringWithFormat:@"     %.0f miles",[[temp objectForKey:@"Miles"] floatValue]];
        }
        [cell.detailTextLabel setText:miles];
        
        for (NSString * key in [assist shared].assos.allKeys)
        {
            NSDictionary * person = [assist shared].assos[key];
            if ([person[@"MemberId"] isEqualToString:temp[@"MemberId"]])
            {
                UIImageView * ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                ab.layer.cornerRadius = 4;
                [ab setStyleClass:@"animate_bubble"];
                [cell.contentView addSubview:ab];
                break;
            }
        }
        if (![[assist shared] isRequestMultiple])
        {
            [pic setStyleClass:@"animate_bubble"];
        }
        return cell;
    }

    else if (searching)
    {
        // Nooch User
        npic.hidden = NO;
        [npic setFrame:CGRectMake(278, 19, 23, 27)];
        [npic setImage:[UIImage imageNamed:@"n_icon_46x54.png"]];
        [npic removeFromSuperview];

        NSDictionary *info = [arrSearchedRecords objectAtIndex:indexPath.row];

        [pic sd_setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        [cell setIndentationLevel:1];
        cell.indentationWidth = 61;

        pic.hidden = NO;
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;

        if (info[@"FirstName"] != NULL && info[@"LastName"] != NULL) // If address book record has a First & Last Name
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",info[@"FirstName"],info[@"LastName"]];
        }
        else if (info[@"FirstName"] != NULL && info[@"LastName"] == NULL) // If address book record has only a First Name
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",info[@"FirstName"]];
        }
        else if (info[@"FirstName"] == NULL && info[@"LastName"] != NULL) // If address book record has only a Last Name
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",info[@"LastName"]];
        }
        
        [cell.textLabel setStyleClass:@"select_recipient_name"];

        /*if (info[@"facebookId"])
        {
            UILabel * fb = [UILabel new];
            [fb setStyleClass:@"facebook_glyph"];
            [fb setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook"]];
            [cell.contentView addSubview:fb];
        }*/

        if (info[@"MemberId"]) {
            [cell.contentView addSubview:npic];
        }

        if (( [[[assist shared] assos] objectForKey:info[@"UserName"]] && [[assist shared] assos][info[@"UserName"]][@"addressbook"]) ||
            ( [[[assist shared] assos] objectForKey:info[@"phoneNo"]] && [[assist shared] assos][info[@"phoneNo"]][@"addressbook"]))
        {
            UIImageView * ab = [UIImageView new];
            [ab setStyleClass:@"addressbook-icons"];

            if (shouldAnimate) {
                [ab setStyleClass:@"animate_bubble"];
            }
            [cell.contentView addSubview:ab];

            UILabel * phoneOrEmailLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 200, 20)];
            [phoneOrEmailLabel setFont:[UIFont fontWithName:@"Roboto-light" size:15]];
            [phoneOrEmailLabel setFrame:CGRectMake(76, 37, 200, 18)];
            [phoneOrEmailLabel setTextColor:kNoochGrayDark];
            [phoneOrEmailLabel setTextAlignment:NSTextAlignmentLeft];

            //NSLog(@"Inside Cell For Row... info object is: %@",info);

            if (info[@"emailAdday0"])
            {
                [cell.textLabel setStyleClass:@"select_recipient_nameWithPhoneInCell"];
                [phoneOrEmailLabel setText:info[@"emailAdday0"]];
            }

            else if (info[@"phoneAdday0"])
            {
                [cell.textLabel setStyleClass:@"select_recipient_nameWithPhoneInCell"];

                if (info[@"phoneAdday3"])
                {
                    NSMutableString * mu = [NSMutableString stringWithString:info[@"phoneAdday0"]];
                    [mu insertString:@"(" atIndex:0];
                    [mu insertString:@")" atIndex:4];
                    [mu insertString:@" " atIndex:5];
                    [mu insertString:@"-" atIndex:9];

                    NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                    [phoneOrEmailLabel setText:phoneWithSymbolsAddedBack];
                }
                else if (info[@"phoneAdday2"])
                {
                    NSMutableString * mu = [NSMutableString stringWithString:info[@"phoneAdday0"]];
                    [mu insertString:@"(" atIndex:0];
                    [mu insertString:@")" atIndex:4];
                    [mu insertString:@" " atIndex:5];
                    [mu insertString:@"-" atIndex:9];

                    NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                    [phoneOrEmailLabel setText:phoneWithSymbolsAddedBack];
                }
                else
                {
                    if ([info[@"phoneAdday0"] length] == 10)
                    {
                        NSMutableString * mu = [NSMutableString stringWithString:info[@"phoneAdday0"]];
                        [mu insertString:@"(" atIndex:0];
                        [mu insertString:@")" atIndex:4];
                        [mu insertString:@" " atIndex:5];
                        [mu insertString:@"-" atIndex:9];

                        NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];
                        [phoneOrEmailLabel setText:phoneWithSymbolsAddedBack];
                    }
                }
            }

            [cell.contentView addSubview:phoneOrEmailLabel];
        }

        if ([[assist shared] isRequestMultiple])
        {
            [npic removeFromSuperview];
            arrRecipientsForRequest = [[[assist shared] getArray] mutableCopy];
            if ([arrRecipientsForRequest containsObject:info]) {
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType=UITableViewCellAccessoryNone;
        }
        else
            cell.accessoryType=UITableViewCellAccessoryNone;

    }

    else if ([[assist shared] isRequestMultiple])
    {
        [npic setFrame:CGRectMake(278, 19, 23, 27)];
        [npic setImage:[UIImage imageNamed:@"n_icon_46x54.png"]];

        NSDictionary *info = [arrRequestPersons objectAtIndex:indexPath.row];
        [pic sd_setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        pic.hidden=NO;
        cell.indentationWidth = 50;
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",[info[@"FirstName"] capitalizedString],[info[@"LastName"] capitalizedString]];
        [cell.textLabel setStyleClass:@"select_recipient_name"];

        [npic removeFromSuperview];
        arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        //NSLog(@"arrRecipientsForRequest: %@",arrRecipientsForRequest);

        int loc =- 1;

        for (int i = 0; i < [arrRecipientsForRequest count]; i++)
        {
            NSDictionary * dictionary = [arrRecipientsForRequest objectAtIndex:i];
            if ([[dictionary valueForKey:@"MemberId"]caseInsensitiveCompare:info[@"MemberId"]] == NSOrderedSame) {
                loc = 1;
            }
        }

        if (loc == 1)
        {
             cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        else
        {
            //loc=-1;
            cell.accessoryType=UITableViewCellAccessoryNone;
        }

        if ([[[assist shared] assos] objectForKey:info[@"UserName"]])
        {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"])
            {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                [cell.contentView addSubview:ab];
            }
        }
    }

    else if (isRecentList)
    {
        [npic setFrame:CGRectMake(278, 19, 23, 27)];
        [npic setImage:[UIImage imageNamed:@"n_icon_46x54.png"]];

        NSDictionary * info = [self.recents objectAtIndex:indexPath.row];
        [pic sd_setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.hidden = NO;
        pic.layer.cornerRadius = 25;

        [cell setIndentationLevel:1];
        cell.indentationWidth = 42;
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        cell.textLabel.text = [NSString stringWithFormat:@"    %@ %@",info[@"FirstName"],info[@"LastName"]];

        cell.accessoryType = UITableViewCellAccessoryNone;

        if ([[[assist shared] assos] objectForKey:info[@"UserName"]])
        {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"])
            {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                [ab setStyleClass:@"animate_bubble"];
                [cell.contentView addSubview:ab];
            }
        }
        if (![[assist shared] isRequestMultiple])
        {
            [pic setStyleClass:@"animate_bubble"];
        }
    }
    
    else if (emailEntry || phoneNumEntry)
    {
        [self.contacts setStyleId:@"select_recipientwithoutSeperator"];
        [npic removeFromSuperview];

        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationWidth = 10;
        [cell.contentView sizeToFit];

        [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
        [pic setFrame:CGRectMake(130, 62, 60, 60)];
        pic.layer.cornerRadius = 30;

        if (shouldAnimate)
        {
            [pic setStyleClass:@"animate_bubble"];
        }
        //[cell.contentView addSubview:self.glyphEmail];

        UILabel * send_to_label = [UILabel new];
        [send_to_label setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
        [send_to_label setFrame:CGRectMake(60, 2, 200, 25)];
        [send_to_label setText:NSLocalizedString(@"SelectRecip_SendToTxt", @"Select Recipient Send To Text")];
        [send_to_label setTextColor:kNoochBlue];
        [send_to_label setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:send_to_label];

        UILabel * send_to_email = [UILabel new];
        [send_to_email setFont:[UIFont fontWithName:@"Roboto-light" size:22]];
        [send_to_email setFrame:CGRectMake(10, 28, 300, 30)];
        [send_to_email setText:[NSString stringWithFormat:@"%@",searchString]];
        [send_to_email setTextColor:kNoochGrayDark];
        [send_to_email setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:send_to_email];

        cell.textLabel.text = @"";
        return cell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([[assist shared] isRequestMultiple])
    {
        NSDictionary * receiver = [arrRequestPersons objectAtIndex:indexPath.row];

        if (searching) {
            receiver = [arrSearchedRecords objectAtIndex:indexPath.row];
        }

        arrRecipientsForRequest = [[[assist shared] getArray] mutableCopy];
        int loc = -1;
        for (int i = 0; i < [arrRecipientsForRequest count]; i++)
        {
            NSDictionary * dictionary = [arrRecipientsForRequest objectAtIndex:i];
            if ([[dictionary valueForKey:@"UserName"]isEqualToString:receiver[@"UserName"]]) {
                loc = 1;
            }
            else
                loc = -1;
        }
        if (loc == 1)
        {
            [arrRecipientsForRequest removeObject:receiver];
            [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
        }
        else
        {
            if ([[[assist shared]getArray] count] == 10)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SelectRecip_TooManyRecipAlertTitle", @"Select Recipient Too Many Recipients Alert Title")
                                                               message:[NSString stringWithFormat:@"\xE2\x98\x9D\n%@", NSLocalizedString(@"SelectRecip_TooManyRecipAlertBody", @"Select Recipient Too Many Recipients Alert Body Text")]
                                                              delegate:Nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:Nil, nil];
                [alert show];
                return;
            }
            [arrRecipientsForRequest addObject:receiver];
            [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
        }
        [tableView reloadData];
        return;
    }

    if (phoneNumEntry)
    {
        if ([search.text length] == 14)
        {
            RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
            spinner2.color = [UIColor whiteColor];
            self.hud.customView = spinner2;
            self.hud.labelText = NSLocalizedString(@"SelectRecip_HUD_CheckingPhoneNum", @"Select Recipient HUD Checking That Phone Text");
            self.hud.detailsLabelText = nil;
            [self.hud show:YES];

            [self getMemberIdByUsingEnteredPhoneNumber];
        }
        else
        {
            [search becomeFirstResponder];

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SelectRecip_PhoneNumTroubleAlertTitle2", @"Select Recipient Phone Number Trouble Alert Title")
                                                            message:NSLocalizedString(@"SelectRecip_PhoneNumTroubleAlertBody", @"Select Recipient Phone Number Trouble Body Text")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        return;
    }

    if (emailEntry)
    {
        if ([search.text length] > 3 &&
            [search.text rangeOfString:@"@"].location != NSNotFound &&
            [search.text rangeOfString:@"@"].location > 1 &&
            [search.text rangeOfString:@"."].location < search.text.length - 2 &&
            [search.text rangeOfString:@"."].location != NSNotFound)
        {
            if ([self checkEmailForShadyDomainSelectRecip] == true)
            {
                RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
                spinner2.color = [UIColor whiteColor];
                self.hud.customView = spinner2;
                self.hud.labelText = @"Checking that email address...";
                self.hud.detailsLabelText = nil;
                [self.hud show:YES];

                [self getMemberIdByUsingUserName];
            }
        }
        else
        {
            /*if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:NSLocalizedString(@"SelectRecip_PlsCheckEmailAlertTitle", @"Select Recipient Please Check That Email Alert Title")
                                             message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA7\n%@", NSLocalizedString(@"SelectRecip_PlsCheckEmailAlertBody", @"Select Recipient Please Check That Email Alert Body Text")]
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
                [alert addAction:ok];
                
                [self presentViewController:alert animated:NO completion:nil];
            }
            else  // for iOS 7 and prior
            {
              */UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SelectRecip_PlsCheckEmailAlertTitle2", @"Select Recipient Please Check That Email Alert Title")
                                                              message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA7\n%@", NSLocalizedString(@"SelectRecip_PlsCheckEmailAlertBody2", @"Select Recipient Please Check That Email Alert Body Text")]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
                [av show];
            //}
        }
        return;
    }

    if (searching)
    {
        NSDictionary * receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];

        //NSLog(@"Receiver is: %@",receiver);
        if ([[assist shared] assos][receiver[@"UserName"]][@"addressbook"] ||
            [[assist shared] assos][receiver[@"phoneNo"]][@"addressbook"] )
        {
            isphoneBook = YES;
            emailEntry = NO;
            phoneNumEntry = NO;

            if (receiver[@"UserName"]) {
                emailphoneBook = receiver[@"UserName"];
            }
            else {
                emailphoneBook = @"";
            }
    
            if (receiver[@"phoneNo"]) {
                phoneBookPhoneNum = receiver[@"phoneNo"];
            }
            else {
                phoneBookPhoneNum = @"";
            }

            if (receiver[@"FirstName"]) {
                firstNamePhoneBook = receiver[@"FirstName"];
            }
            else {
                firstNamePhoneBook = @"";
            }

            if (receiver[@"LastName"]) {
                lastNamePhoneBook = receiver[@"LastName"];
            }
            else {
                lastNamePhoneBook = @"";
            }

            if (receiver[@"UserName"])
            {
                if ([receiver[@"emailCount"]intValue] > 1)
                {
                    UIActionSheet * actionSheetObject = [[UIActionSheet alloc] init];

                    for (int j = 0; j < [receiver[@"emailCount"]intValue]; j++)
                    {
                        [actionSheetObject addButtonWithTitle:[receiver[[NSString stringWithFormat:@"emailAdday%d",j]] lowercaseString]];
                    }

                    actionSheetObject.title = [NSString stringWithFormat:@"Select which email to use for %@",receiver[@"FirstName"]];
                    actionSheetObject.cancelButtonIndex = [actionSheetObject addButtonWithTitle:@"Cancel"];
                    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
                    [actionSheetObject setTag:1122];
                    actionSheetObject.delegate = self;
                    [actionSheetObject showInView:self.view];
                }
                else
                {
                    RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
                    spinner2.color = [UIColor whiteColor];
                    self.hud.customView = spinner2;
                    self.hud.labelText = NSLocalizedString(@"SelectRecip_HUD_GeneratingTrnsfr", @"Select Recipient HUD Generating Transfer Text");
                    self.hud.detailsLabelText = nil;
                    [self.hud show:YES];

                    [self getMemberIdByUsingUserNameFromPhoneBook];
                }
            }
            else if (receiver[@"phoneNo"])
            {
                if ([receiver[@"phoneCount"] intValue] > 1) // More than 1 phone number
                {
                    UIActionSheet * actionSheetForPhoneNos = [[UIActionSheet alloc] init];

                    for (int k = 0; k < [receiver[@"phoneCount"] intValue]; k++)
                    {
                        if ([receiver[[NSString stringWithFormat:@"phoneAdday%d",k]] length] == 10)
                        {
                            NSMutableString * mu = [NSMutableString stringWithString:receiver[[NSString stringWithFormat:@"phoneAdday%d",k]]];
                            [mu insertString:@"(" atIndex:0];
                            [mu insertString:@")" atIndex:4];
                            [mu insertString:@" " atIndex:5];
                            [mu insertString:@"-" atIndex:9];

                            NSString * phoneWithSymbolsAddedBack = [NSString stringWithString:mu];

                            [actionSheetForPhoneNos addButtonWithTitle:[phoneWithSymbolsAddedBack lowercaseString]];
                        }
                    }

                    actionSheetForPhoneNos.title = [NSString stringWithFormat:@"Select which phone number to use for %@",receiver[@"FirstName"]];
                    actionSheetForPhoneNos.cancelButtonIndex = [actionSheetForPhoneNos addButtonWithTitle:@"Cancel"];
                    actionSheetForPhoneNos.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                    [actionSheetForPhoneNos setTag:223];
                    actionSheetForPhoneNos.delegate = self;
                    [actionSheetForPhoneNos showInView:self.view];
                }
                else // only 1 Phone Number
                {
                    RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleFadingCircleAlt];
                    spinner2.color = [UIColor whiteColor];
                    self.hud.customView = spinner2;
                    self.hud.labelText = NSLocalizedString(@"SelectRecip_HUD_GeneratingTrnsfr2", @"Select Recipient HUD Generating Transfer Text");
                    self.hud.detailsLabelText = nil;
                    [self.hud show:YES];

                    [self getMemberIdByUsingPhoneNumberFromAB];
                }
            }

            [tableView deselectRowAtIndexPath:indexPath animated:YES];

            return;
        }


        // BELOW THIS WOULD BE FOR WHEN THE SELECTED ROW CONTAINS A RESULT FROM
        // THE USER'S 'RECENT LIST' AS OPPOSED TO A PHONE BOOK ENTRY (Email OR Phone)
        searching = NO;
        emailEntry = NO;
        isRecentList = YES;
        [search resignFirstResponder];
        [search setText:@""];
        [search setShowsCancelButton:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (navIsUp == YES)
        {
            navIsUp = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self lowerNavBar];
            });
        }

        isFromHome = NO;
        isFromMyApt = NO;
        isFromArtisanDonationAlert = NO;

        HowMuch * how_much = [[HowMuch alloc] initWithReceiver:receiver];
        [self.navigationController pushViewController:how_much animated:YES];
    }
    else
    {
        if (navIsUp == YES)
        {
            navIsUp = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self lowerNavBar];
            });
        }
        [self.navigationItem setLeftBarButtonItem:nil];
        isFromHome = NO;
        isFromMyApt = NO;
        isFromArtisanDonationAlert = NO;

        NSDictionary * receiver = [self.recents objectAtIndex:indexPath.row];

        HowMuch * how_much = [[HowMuch alloc] initWithReceiver:receiver];
        [self.navigationController pushViewController:how_much animated:YES];
    }
}

-(bool)checkEmailForShadyDomainSelectRecip
{
    NSString * emailToCheck = search.text;
    
    if ([emailToCheck rangeOfString:@"sharklasers"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"grr.la"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"guerrillamail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"spam4"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"anonymousemail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"anonemail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"hmamail.com"].location != NSNotFound || // "hideMyAss.com"
        [emailToCheck rangeOfString:@"mailinator"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mailinater"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"sendspamhere"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"sogetthis"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mt2014.com"].location != NSNotFound ||  // "myTrashMail.com"
        [emailToCheck rangeOfString:@"hushmail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mailnesia"].location != NSNotFound)
    {
        [search becomeFirstResponder];
        
        /*if ([UIAlertController class]) // for iOS 8
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Try A Different Email"
                                         message:@"\xF0\x9F\x93\xA7\nTo protect all Nooch accounts, we ask that you please only make payments to a regular (not anonymous) email address."
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
        }
        else  // for iOS 7 and prior
        {
          */UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Try A Different Email"
                                                         message:@"\xF0\x9F\x93\xA7\nTo protect all Nooch accounts, we ask that you please only make payments to a regular (not anonymous) email address."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        //}
        return false;
    }
    else
    {
        return true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}
@end