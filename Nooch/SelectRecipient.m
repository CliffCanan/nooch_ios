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
@property(nonatomic,strong) UISegmentedControl *completed_pending;
@property(nonatomic,strong) UIImageView*noContact_img;
@property(nonatomic, strong) UILabel * glyph_recent;
@property(nonatomic, strong) UILabel * glyph_location;
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
  
   /* if ([user valueForKey:@"facebook_id"] && ![[user valueForKey:@"facebook_id"] length] > 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Connect with Facebook" message:@"Do you want to connect with your facebook friends?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"Lator",nil];
        [av show];
        av.tag=6;
    } */

    NSLog(@"\n\nDEFAULTS ARE: %@",user);
    self.location = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    [self.navigationItem setLeftBarButtonItem:nil];
    UIButton * back_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back_button setStyleId:@"navbar_back"];
    [back_button addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    [back_button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] forState:UIControlStateNormal];
    [back_button setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.15) forState:UIControlStateNormal];
    back_button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

    isPayBack = NO;
    isEmailEntry = NO;
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


    NSArray *seg_items = @[@"Recent",@"    Find by Location"];
    self.completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [self.completed_pending setStyleId:@"history_segcontrol"];
    [self.completed_pending addTarget:self action:@selector(recent_or_location:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.completed_pending];
    [self.completed_pending setSelectedSegmentIndex:0];

    self.glyph_recent = [UILabel new];
    [self.glyph_recent setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [self.glyph_recent setFrame:CGRectMake(32, 12, 22, 18)];
    [self.glyph_recent setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
    [self.glyph_recent setTextColor:[UIColor whiteColor]];
    [self.glyph_recent setAlpha: 1];
    [self.view addSubview:self.glyph_recent];

    self.glyph_location = [UILabel new];
    [self.glyph_location setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [self.glyph_location setFrame:CGRectMake(168, 12, 20, 17)];
    [self.glyph_location setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"]];
    [self.glyph_location setTextColor: kNoochBlue];
    [self.glyph_location setAlpha: 1];
    [self.view addSubview:self.glyph_location];

    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    search.searchBarStyle = UISearchBarStyleMinimal;
    search.placeholder=@"Search by Name or Enter an Email";
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
                [((UITextField *)subview2) setClearButtonMode:UITextFieldViewModeWhileEditing];
                 break;
            }
        }
    }

    [self.view addSubview:search];

    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, [[UIScreen mainScreen] bounds].size.height-146)];
    [self.contacts setDataSource:self];
    [self.contacts setDelegate:self];
    [self.contacts setSectionHeaderHeight:30];
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
    self.hud.labelText = @"Building Your Recent List";
    [self.hud show:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [search setHidden:NO];
    self.screenName = @"SelectRecipient Screen";

    if ([[assist shared] isRequestMultiple] && isAddRequest)
    {
        self.location = NO;
        [self.navigationItem setHidesBackButton:YES];
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.completed_pending setSelectedSegmentIndex:0];

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Recipients"
                                                     message:@"To request money from more than one person, search for friends then tap each additional person (up to 10).\n\nTap 'Done' when finished."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [self.navigationItem setTitle:@"Group Request"];
        [self.navigationItem setRightBarButtonItem:Nil];
        
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
        isRecentList = NO;
        searching = NO;
        emailEntry = NO;
        isRecentList = YES;
        isphoneBook = NO;
        [search resignFirstResponder];
        [search setText:@""];
        [search setShowsCancelButton:NO];

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
        [self.navigationItem setTitle:@"Select Recipient"];
        [self.navigationItem setHidesBackButton:NO];

        UIButton * back_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [back_button setStyleId:@"navbar_back"];
        [back_button addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
        [back_button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] forState:UIControlStateNormal];
        [back_button setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.16) forState:UIControlStateNormal];
        back_button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
        [self.navigationItem setLeftBarButtonItem:menu];

        isUserByLocation = NO;
        [self.navigationItem setRightBarButtonItem:Nil];
        [[assist shared]setRequestMultiple:NO];
        [self.completed_pending setSelectedSegmentIndex:0];
        self.location = NO;
        isRecentList = YES;
        searching = NO;
        emailEntry = NO;
        search.text = @"";
        [search setShowsCancelButton:NO];
        [search resignFirstResponder];

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];

        CGRect frame = self.contacts.frame;
        frame.origin.y = 80;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height-144;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [search setTintColor:kNoochBlue];

    //[self facebook];

    if (!isEmailEntry && !isphoneBook)
    {
        serve * recents = [serve new];
        [recents setTagName:@"recents"];
        [recents setDelegate:self];
        [recents getRecents];
    }

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        NSLog(@"Contacts permission denied");
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Access To Contacts"
                                                        message:@"Did you know you can send money to ANY email address? It's really helpful to select a contact you already have in your iPhone's Address Book.\n\nTo enable this ability, turn on access to Contacts in your iPhone's Settings:\n\nSettings --> Privacy --> Contacts"
                                                       delegate:Nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:Nil, nil];
        [alert show];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        NSLog(@"Authorized");
        [self address_book];
    }
    else
    {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted)
            {
                NSLog(@"Just denied");
                return;
            }
            [self address_book];
            NSLog(@"Just authorized");

        });
        NSLog(@"Not determined");
    }

}

-(void)backPressed:(id)sender{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)DoneEditing_RequestMultiple:(id)sender
{
    if ([[[assist shared]getArray] count] == 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"But Whooo?"
                                                     message:@"\xF0\x9F\x98\x95\nPlease select at least one recipient. Otherwise it makes it way harder to know where to send your request!"
                                                    delegate:Nil
                                           cancelButtonTitle:@"Ok"
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
    HowMuch * how_much = [[HowMuch alloc] init];
    [self.navigationController pushViewController:how_much animated:YES];
}

-(void)lowerNavBar
{
    //[nav_ctrl setNavigationBarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateKeyframesWithDuration:0.35
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [self.completed_pending setFrame:CGRectMake(7, 6, 306, 30)];
                                      [self.completed_pending setAlpha: 1];
                                      [self.view setBackgroundColor:[UIColor whiteColor]];
                                      [self.contacts setFrame:CGRectMake(0, 80, 320, [[UIScreen mainScreen] bounds].size.height-146)];
                                      [self.glyph_recent setAlpha: 1];
                                      [self.glyph_location setAlpha: 1];
                                      search.placeholder=@"Search by Name or Enter an Email";
                                      [search setFrame:CGRectMake(0, 40, 320, 40)];
                                      [search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

                                  }];
                              } completion: nil
    ];
}

/*
-(void) facebook
{
    NSDictionary * options = @{
            ACFacebookAppIdKey: @"198279616971457",
            ACFacebookPermissionsKey: @[@"friends_about_me"],
            ACFacebookAudienceKey: ACFacebookAudienceFriends
    };
    ACAccountType *facebookAccountType = [me.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [me.accountStore requestAccessToAccountsWithType:facebookAccountType
            options:options completion:^(BOOL granted, NSError *e)
     {
         
     }];
    NSString *acessToken = [NSString stringWithFormat:@"%@",me.facebookAccount.credential.oauthToken];
    NSDictionary *parameters = @{@"access_token": acessToken,@"fields":@"id,installed,username,first_name,last_name"};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodGET
                              URL:feedURL
                              parameters:parameters];
    feedRequest.account = me.facebookAccount;
    [feedRequest performRequestWithHandler:^(NSData *respData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         NSString *resp = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
         NSError* err;
        NSDictionary *d = [NSJSONSerialization
                         JSONObjectWithData:[resp dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&err];
         NSMutableArray *friends = [d objectForKey:@"data"];
         NSMutableArray *temp = [NSMutableArray new];
         for(NSMutableDictionary *dict in friends){
             if (![dict objectForKey:@"id"]) continue;
             NSMutableDictionary *new = [NSMutableDictionary new];
             [new addEntriesFromDictionary:dict];
             [new setObject:dict[@"id"] forKey:@"facebookId"];
             if([dict objectForKey:@"installed"]) [new setObject:@"wut2do" forKey:@"MemberId"];
             [temp addObject:new];
         }
         NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
         NSMutableArray *temp2 = [[NSMutableArray alloc] init];
         NSMutableArray *temp3 = [[NSMutableArray alloc] init];
         NSMutableArray *fbFriendsTemp;// = [[NSMutableArray alloc] init];
         NSMutableArray *fbNoochFriendsTemp;// = [[NSMutableArray alloc] init];
         for(int i= 0; i<[temp count];i++){
             NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
             if([[temp objectAtIndex:i] objectForKey:@"first_name"] != NULL)[dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"first_name"]] forKey:@"FirstName"];
             if([[temp objectAtIndex:i] objectForKey:@"last_name"] != NULL)[dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"last_name"]] forKey:@"LastName"];
             [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"name"]] forKey:@"name"];
             if([[temp objectAtIndex:i] objectForKey:@"username"] != NULL) [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"username"]] forKey:@"UserName"];
             [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"facebookId"]] forKey:@"facebookId"];
             NSString *photoURL;
             if([dict objectForKey:@"UserName"] != NULL) photoURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [dict objectForKey:@"UserName"]];
             else if([dict objectForKey:@"facebookId"] != NULL) photoURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [dict objectForKey:@"facebookId"]];
             [dict setObject:photoURL forKey:@"Photo"];
             if([[temp objectAtIndex:i] objectForKey:@"MemberId"] != NULL){
                 [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"MemberId"]] forKey:@"MemberId"];
                 [temp3 addObject:dict];
             } else
                 [temp2 addObject:dict];
         }
         fbFriendsTemp = [[temp2 sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
         fbNoochFriendsTemp = [[temp3 sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
         
         [[assist shared] addAssos:fbFriendsTemp];
         [[assist shared] addAssos:fbNoochFriendsTemp];
         //friends = [me cleanForSave:friends];
         //[self facebookProcess:friends];
     }];
}  */

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
            
            if (emailId != NULL)
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

                // NSLog(@"\nCheckpoint DELTA.  Contact Number: %d  -  Phone Number: %d",i,j);
                [additions addObject:curContact];
            }
            
        }
        
        if (phoneNumber) {
            CFRelease(phoneNumber);
        }

 /*       if (ABMultiValueGetCount(phoneNumber) > 0)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 0);
            phone = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (phoneValue)
                CFRelease(phoneValue);

            phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            [curContact setObject:phone forKey:@"phoneNo"];
           
            [additions addObject:curContact];

            NSLog(@"%d.) Additions count is: %d",i,[additions count]);
        }

        if (ABMultiValueGetCount(phoneNumber) > 1)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 1);
            phone2 = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (phoneValue)
                CFRelease(phoneValue);
            
            phone2 = [phone2 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone2 length])];
            [curContact setObject:phone2 forKey:@"phoneNo"];

            [additions addObject:curContact];
            NSLog(@"%d.) Additions count is: %d",i,[additions count]);
        }

        if (ABMultiValueGetCount(phoneNumber) > 2)
        {
            CFTypeRef phoneValue = ABMultiValueCopyValueAtIndex(phoneNumber, 2);
            phone3 = [[NSString stringWithFormat:@"%@", phoneValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (phoneValue)
                CFRelease(phoneValue);
            
            phone3 = [phone3 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone3 length])];
            [curContact setObject:phone3 forKey:@"phoneNo"];

            [additions addObject:curContact];
        }
*/
        if (phone != NULL)
        {
           // NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
          //  if (strippedNumber != NULL)
           //     [curContact setObject:strippedNumber forKey:@"phoneNo"];
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
        [self.glyph_recent setTextColor: [UIColor whiteColor]];
        [self.glyph_location setTextColor: kNoochBlue];

        self.location = NO;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.45];

        CGRect frame = self.contacts.frame;
        frame.origin.y = 80;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height-146;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];
        
        [search setHidden:NO];

        RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud.customView = spinner1;
        self.hud.labelText = @"Loading your recent list";
        [self.hud show:YES];

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

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];

        CGRect frame = self.contacts.frame;
        frame.origin.y = 40;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height-104;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];

        [search setHidden:YES];

        RTSpinKitView * spinner2 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWordPress];
        spinner2.color = [UIColor whiteColor];
        self.hud.customView = spinner2;
        self.hud.labelText = @"Finding Nooch users near you";
        [self.hud show:YES];

        serve * ser = [serve new];
        ser.tagName = @"searchByLocation";
        [ser setDelegate:self];
        [ser getLocationBasedSearch:@"15"];
    }
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
                                                            message:@"No email address has been specified. Please try again."
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
    if ([actionSheet tag] == 1111)  // Not sure that this is every actually called or necessary
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

        if ([emailphoneBook isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Very Sneaky"
                                                         message:@"\xF0\x9F\x98\xB1\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try someone ELSE's email address!"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av setTag:4];
            [av show];
        }
        else if (![selectedEmail isEqualToString:@"Cancel"])
        {
            [search resignFirstResponder];

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

        [search setTintColor:[UIColor whiteColor]]; // For the 'Cancel' text

        [UIView animateKeyframesWithDuration:0.38
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.2 animations:^{
                                          [self.contacts setFrame:CGRectMake(0, 70, 320, [[UIScreen mainScreen] bounds].size.height-56)];
                                      }];
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                          [self.view setBackgroundColor:kNoochBlue];
                                          [self.completed_pending setAlpha:0];
                                          [self.glyph_recent setAlpha: 0];
                                          [self.glyph_location setAlpha: 0];
                                          [search setImage:[UIImage imageNamed:@"search_white"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
                                      }];
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                          [self.completed_pending setFrame:CGRectMake(7, -8, 306, 30)];
                                          [searchBar setFrame:CGRectMake(0, 24, 320, 40)];
                                          searchBar.placeholder = @"";
                                      }];
                                  } completion: nil
         ];
    }

    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar setKeyboardType:UIKeyboardTypeEmailAddress];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
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

        return;
    }

    else if ([searchText length] > 0)
    {
        if ([self.view.subviews containsObject:self.noContact_img]) {
             [self.noContact_img removeFromSuperview];
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

            if (isRange.location < searchText.length - 1) {
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
            if ([s rangeOfCharacterFromSet:notDigits].location == NSNotFound)
            {
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
            }
            else
            {
                phoneNumEntry = NO;
                shouldAnimate = NO;
                searching = YES;
                searchString = searchText;
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

- (void) searchTableView
{
    arrSearchedRecords = [[NSMutableArray alloc]init];

    for (NSString * key in [[assist shared] assos].allKeys)
    {
        //NSLog(@"Key is: %@",key);
        NSMutableDictionary * dict = [[assist shared] assos][key];

        NSComparisonResult result;
        NSComparisonResult result2;
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

        if ((result == NSOrderedSame || result2 == NSOrderedSame) &&
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
    [search resignFirstResponder];

    if ([emailphoneBook isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Try That Again"
                                                     message:@"\xE2\x98\x9D\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try someone ELSE's email address!"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else
    {
        serve *emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:emailphoneBook];
    }
}

#pragma mark - Manually Entered Email Handling
-(void)getMemberIdByUsingUserName
{
    [search resignFirstResponder];
    if ([[search.text lowercaseString] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Hold On There..."
                                                     message:@"\xF0\x9F\x98\xB1\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try someone ELSE's email address!"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else
    {
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

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Error"
                          message:@"Looks like there was some trouble connecting to the right place.  Please try again!"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    [self.contacts setNeedsDisplay];
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];

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

    /* else if ([tagName isEqualToString:@"fb"])
    {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"fb storing %@",temp);
        if ([[temp valueForKey:@"Result"]isEqualToString:@"Success"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"whoo!" message:@"You account has been connected to facebook successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"whoo!" message:[temp valueForKey:@"Result"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    } */

    else if ([tagName isEqualToString:@"recents"])
    {
        [spinner setHidden:YES];

        NSError * error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        
        NSMutableArray * temp = [NSMutableArray new];
        for (NSDictionary * dict in self.recents) {
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
            return;
        }

        if ([self.recents count] > 0)
        {
            [self.contacts setHidden:NO];
            [self.contacts setStyleId:@"select_recipient"];
            [self.contacts reloadData];
        }
        else
        {
            [self.contacts setHidden:YES];
            self.noContact_img = [[UIImageView alloc] init];
            
            if (IS_IPHONE_5) {
                self.noContact_img.frame = CGRectMake(0, 82, 320, 405);
                self.noContact_img.contentMode = UIViewContentModeScaleAspectFit;
                self.noContact_img.image = [UIImage imageNamed:@"selectRecipientIntro.png"];
            }
            else {
                self.noContact_img.frame = CGRectMake(3, 79, 314, 340);
                self.noContact_img.contentMode = UIViewContentModeScaleAspectFit;
                self.noContact_img.image = [UIImage imageNamed:@"selectRecipientIntro_smallScreen.png"];
            }
            [self.view addSubview:self.noContact_img];
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
        
        for (int i = 0; i < [ self.recents count]; i++)
        {
            for (int j = i+1; j < [ self.recents count]; j++)
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
        [self.contacts setHidden:NO];
        [self.contacts reloadData];
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
            if (navIsUp == YES) {
                navIsUp = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self lowerNavBar];
                });
            }

            [self.navigationItem setLeftBarButtonItem:nil];

            if ([[assist shared]isRequestMultiple])
            {
                [spinner setHidden:YES];
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

            HowMuch * how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];

            [spinner setHidden:YES];

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
            if ([[dictResult objectForKey:@"Result"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
            {
                [search becomeFirstResponder];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Hold On There..."
                                                             message:@"\xF0\x9F\x98\xB1\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try someone ELSE's phone number!"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av setTag:4];
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
            if (navIsUp == YES) {
                navIsUp = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self lowerNavBar];
                });
            }

            [self.navigationItem setLeftBarButtonItem:nil];

            if ([[assist shared]isRequestMultiple])
            {
                [spinner setHidden:YES];
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
            
            HowMuch * how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];

            [spinner setHidden:YES];

            return;
        }
    }

    else if ([tagName isEqualToString:@"getMemberDetails"])
    {
        NSError * error;
        [spinner setHidden:YES];

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

            isEmailEntry = NO;
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

            isFromHome = NO;
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /* if (alertView.tag == 6) {
        if (buttonIndex==0) {
            [self connect_to_facebook];
        }
    }

    if (alertView.tag == 4 && buttonIndex == 0)
    {
     // If the user attempts to select himself by entering his own email address or selecting himself from the search results for Address Book
    } */
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.location) {
            return @"Nearby Users";
        } 
        else if (searching) {
            return @"Search Results";
        }
        else {
            return @"Recent";
        }
        return @"Recent";
    }
    else {
        return @"";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake (10, 0, 200, 30)];
    title.textColor = kNoochGrayDark;

    if (section == 0)
    {
        if (self.location)
            title.text = @"Nearby Users";
        else if (searching)
            title.text = @"Search Results";
        else if (isRecentList)
            title.text = @"Recent Contacts";
        else
            title.text = @"Send To Email Address";
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

        if ([[temp objectForKey:@"Miles"] intValue] < 1) {
            miles = [NSString stringWithFormat:@"    %.0f feet",([[temp objectForKey:@"Miles"] floatValue] * 5280)];
        }
        else {
            miles = [NSString stringWithFormat:@"    %.0f miles",[[temp objectForKey:@"Miles"] floatValue]];
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

            NSLog(@"Inside Cell For Row... info object is: %@",info);

            if (info[@"emailAdday0"])
            {
                [cell.textLabel setStyleClass:@"select_recipient_nameWithPhoneInCell"];
                [phoneOrEmailLabel setText:info[@"emailAdday0"]];
            }

            else if (info[@"phoneAdday0"])
            {
                NSLog(@"CheckPOINT YO!");
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
        [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
        [pic setFrame:CGRectMake(130, 62, 60, 60)];
        pic.layer.cornerRadius = 30;
        if (shouldAnimate) {
            [pic setStyleClass:@"animate_bubble"];
        }
        cell.indentationWidth = 10;
        [cell.contentView sizeToFit];

        UILabel * send_to_label = [UILabel new];
        [send_to_label setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
        [send_to_label setFrame:CGRectMake(60, 2, 200, 25)];
        [send_to_label setText:@"Send To:"];
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
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Too Many Recipients"
                                                               message:@"\xE2\x98\x9D\nYou can't request more than 10 Users!"
                                                              delegate:Nil
                                                     cancelButtonTitle:@"Ok"
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
            [self getMemberIdByUsingEnteredPhoneNumber];
        }
        else
        {
            [search becomeFirstResponder];
            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Phone Number Trouble"
                                             message:@"Please double check that you entered a valid 10-digit phone number."
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
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Phone Number Trouble"
                                                                message:@"Please double check that you entered a valid 10-digit phone number."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
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
            [self getMemberIdByUsingUserName];
        }
        else
        {
            if ([UIAlertController class]) // for iOS 8
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Please Check That Email"
                                             message:@"\xF0\x9F\x93\xA7\nThat doesn't look like a valid email address.  Please check it and try again."
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
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Please Check That Email"
                                                              message:@"\xF0\x9F\x93\xA7\nThat doesn't look like a valid email address. Please check it and try again."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
                [av show];
            }
        }
        return;
    }

    if (searching)
    {
        NSDictionary * receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];

        NSLog(@"Receiver is: %@",receiver);
        if ([[assist shared] assos][receiver[@"UserName"]][@"addressbook"] ||
            [[assist shared] assos][receiver[@"phoneNo"]][@"addressbook"] )
        {
            isphoneBook = YES;

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

        //[self.navigationItem setLeftBarButtonItem:nil];

        isFromHome = NO;
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
        NSDictionary * receiver = [self.recents objectAtIndex:indexPath.row];

        HowMuch * how_much = [[HowMuch alloc] initWithReceiver:receiver];
        [self.navigationController pushViewController:how_much animated:YES];
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