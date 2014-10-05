//  SelectRecipient.m
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

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
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property(nonatomic) BOOL location;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UISegmentedControl *completed_pending;
@property(nonatomic,strong) UIImageView*noContact_img;
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
  
    if ([user valueForKey:@"facebook_id"] && ![[user valueForKey:@"facebook_id"] length] > 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Connect with Facebook" message:@"Do you want to connect with your facebook friends?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"Lator",nil];
        [av show];
        av.tag=6;
    }

    self.location = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
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

    UILabel *glyph_recent = [UILabel new];
    [glyph_recent setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [glyph_recent setFrame:CGRectMake(32, 12, 22, 18)];
    [glyph_recent setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
    [glyph_recent setTextColor:[UIColor whiteColor]];
    [self.view addSubview:glyph_recent];
    
    UILabel *glyph_location = [UILabel new];
    [glyph_location setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [glyph_location setFrame:CGRectMake(168, 12, 20, 17)];
    [glyph_location setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"]];
    [glyph_location setTextColor: kNoochBlue];
    [self.view addSubview:glyph_location];
    
    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    [search setBackgroundColor:kNoochGrayDark];
    search.placeholder=@"Search by Name or Enter an Email";
    [search setDelegate:self];
    [search setTintColor:kNoochGrayDark];
    [self.view addSubview:search];

    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 82, 320, [[UIScreen mainScreen] bounds].size.height-146)];
    [self.contacts setDataSource:self];
    [self.contacts setDelegate:self];
    [self.contacts setSectionHeaderHeight:30];
    [self.contacts setStyleId:@"select_recipientwithoutSeperator"];
    [self.contacts setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.contacts];
    [self.contacts reloadData];

    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = @"Building Your Recent List";
    [self.hud show:YES];
    [spinner1 startAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [search setHidden:NO];
    self.trackedViewName = @"SelectRecipient Screen";

    if ([[assist shared] isRequestMultiple] && isAddRequest)
    {
        self.location = NO;
        [self.navigationItem setHidesBackButton:YES];

        [self.completed_pending setSelectedSegmentIndex:0];

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Recipients" message:@"To request money from more than one person, search for friends then tap each additional person (up to 10).\n\nTap 'Done' when finished." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.navigationItem setTitle:@"Group Request"];
        [self.navigationItem setRightBarButtonItem:Nil];
        
        UIButton * Done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        Done.frame = CGRectMake(307, 25, 16, 35);
        [Done setStyleId:@"icon_RequestMultiple"];
        [Done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Done setTitle:@"    Done" forState:UIControlStateNormal];
        [Done setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.26) forState:UIControlStateNormal];
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
        NSLog(@"%@",arrRequestPersons);
        [self.contacts reloadData];
    }
    else
    {
        [self.navigationItem setTitle:@"Select Recipient"];
        [self.navigationItem setHidesBackButton:NO];
        isUserByLocation=NO;
        [self.navigationItem setRightBarButtonItem:Nil];
        [[assist shared]setRequestMultiple:NO];
        [self.completed_pending setSelectedSegmentIndex:0];
        self.location = NO;
        isRecentList=YES;
        searching=NO;
        emailEntry=NO;
        search.text=@"";
        [search setShowsCancelButton:NO];
        [search resignFirstResponder];
//        [self.contacts reloadData];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        CGRect frame = self.contacts.frame;
        frame.origin.y = 80;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height-144;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];
    }
}

-(void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        NSLog(@"Denied");
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

    [self facebook];
    serve *recents = [serve new];
    [recents setTagName:@"recents"];
    [recents setDelegate:self];
    [recents getRecents];
    
}

-(void)DoneEditing_RequestMultiple:(id)sender
{
    if ([[[assist shared]getArray] count]==0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"But Whooo?" message:@"Please select at least one recipient.  Otherwise it makes it way harder to know where to send your request!" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    isAddRequest = NO;
    isFromHome = NO;
    HowMuch * how_much = [[HowMuch alloc] init];
    [self.navigationController pushViewController:how_much animated:YES];
}

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
}

-(void)address_book
{
    NSMutableArray *additions = [NSMutableArray new];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);

    for(int i = 0; i < nPeople; i++)
    {
        NSMutableDictionary *curContact = [[NSMutableDictionary alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSString *contacName;
        
        CFTypeRef contacNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        contacName = [[NSString stringWithFormat:@"%@", contacNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (contacNameValue)
            CFRelease(contacNameValue);
        
        NSString * firstName;
        NSString * lastName;
        NSData *contactImage;

        // Get FirstName Ref
        CFTypeRef firstNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        firstName = [[NSString stringWithFormat:@"%@", firstNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (firstNameValue)
            CFRelease(firstNameValue);
        
        // Get LastName Ref
        CFTypeRef LastNameValue = ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        if(LastNameValue)
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
        else {
            contactImage = UIImageJPEGRepresentation([UIImage imageNamed:@"profile_picture.png"], 1);
            [curContact setObject:contactImage forKey:@"image"];
        }
        
        if (contacName != NULL) [curContact setObject:contacName forKey:@"Name"];
        if (firstName != NULL) [curContact setObject:firstName forKey:@"FirstName"];
        if (lastName != NULL) [curContact setObject:lastName forKey:@"LastName"];
        [curContact setObject:@"YES" forKey:@"addressbook"];

        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        // Get phoneValue Ref
        NSString *phone,*phone2,*phone3;
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
            NSString *emailId = [[NSString stringWithFormat:@"%@", emailIdValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

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
        [additions addObject:curContact];
        
        if (contacName != NULL)
        {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];

            if ([strippedNumber length] == 11) {
                strippedNumber = [strippedNumber substringFromIndex:1];
            }

            if (strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
            [additions addObject:curContact];
        }
        
        if (phoneNumber)
            CFRelease(phoneNumber);
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
        UILabel *glyph_recent = [UILabel new];
        [glyph_recent setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
        [glyph_recent setFrame:CGRectMake(32, 12, 22, 18)];
        [glyph_recent setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
        [glyph_recent setTextColor: [UIColor whiteColor]];
        [self.view addSubview:glyph_recent];
        [self.view bringSubviewToFront:glyph_recent];

        UILabel *glyph_location = [UILabel new];
        [glyph_location setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
        [glyph_location setFrame:CGRectMake(168, 12, 20, 17)];
        [glyph_location setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"]];
        [glyph_location setTextColor: kNoochBlue];
        [self.view addSubview:glyph_location];
        [self.view bringSubviewToFront:glyph_location];
        
        self.location = NO;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.7];
        
        CGRect frame = self.contacts.frame;
        frame.origin.y = 82;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height-146;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];
        
        [search setHidden:NO];

        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        self.hud.labelText = @"Loading your recent list";
        [self.hud show:YES];
        [spinner1 startAnimating];

        serve *recents = [serve new];
        [recents setTagName:@"recents"];
        [recents setDelegate:self];
        [recents getRecents];
    } 
    else
    {
        UILabel *glyph_recent = [UILabel new];
        [glyph_recent setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
        [glyph_recent setFrame:CGRectMake(32, 12, 22, 18)];
        [glyph_recent setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
        [glyph_recent setTextColor:kNoochBlue];
        [self.view addSubview:glyph_recent];
        [self.view bringSubviewToFront:glyph_recent];
        
        UILabel *glyph_location = [UILabel new];
        [glyph_location setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
        [glyph_location setFrame:CGRectMake(168, 12, 20, 17)];
        [glyph_location setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"]];
        [glyph_location setTextColor: [UIColor whiteColor]];
        [self.view addSubview:glyph_location];
        [self.view bringSubviewToFront:glyph_location];
        
        self.location = YES;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        
        CGRect frame = self.contacts.frame;
        frame.origin.y = 40;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height-104;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];
        
        [search setHidden:YES];

        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        self.hud.labelText = @"Finding Nooch users near you";
        [self.hud show:YES];
        [spinner1 startAnimating];

        serve * ser = [serve new];
        ser.tagName = @"searchByLocation";
        [ser setDelegate:self];
        [ser getLocationBasedSearch:@"15"];
    }
}

-(void)phonebook:(id)sender {
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self.view removeConstraints:self.view.constraints];
    NSArray *displayedItems = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:kABPersonEmailProperty],
                               nil];
    _addressBookController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _addressBookController.view.translatesAutoresizingMaskIntoConstraints=YES;
	[_addressBookController.view removeConstraints:_addressBookController.view.constraints];
    _addressBookController.displayedProperties=displayedItems;
    [self presentViewController:_addressBookController animated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue) ;
    NSLog(@"%@",emailAddresses);
    if (emailMultiValue)
    CFRelease(emailMultiValue);
    [_addressBookController dismissViewControllerAnimated:YES completion:^{
        if ([emailAddresses count]==0) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Uh Oh" message:@"No email address has been specified. Please try again." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
        else if ([emailAddresses count]==1)
        {
            //  search.text=[emailAddresses objectAtIndex:0];
            // [search setShowsCancelButton:YES];
            // [search becomeFirstResponder];
            emailphoneBook= [emailAddresses objectAtIndex:0];
            isphoneBook=YES;
            [self getMemberIdByUsingUserNameFromPhoneBook];
        }
        else
        {
            UIActionSheet *actionSheet=[[UIActionSheet alloc]init];
            [actionSheet setDelegate:self];
            for (int i=0 ; i<[emailAddresses count];i++) {
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@",[emailAddresses objectAtIndex:i]]];
            }
            actionSheet.tag=1111;
            [actionSheet addButtonWithTitle:@"Cancel"];
            [actionSheet showInView:self.view];
        }
    }];
    return NO;
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *_currentView in actionSheet.subviews) {
        if ([_currentView isKindOfClass:[UILabel class]]) {
            [((UILabel *)_currentView) setFont:[UIFont boldSystemFontOfSize:15.f]];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet tag] == 1111)
    {
        if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
        {
            emailphoneBook= [actionSheet buttonTitleAtIndex:buttonIndex];
            isphoneBook=YES;
            [self getMemberIdByUsingUserNameFromPhoneBook];
        }
    }
    else if ([actionSheet tag] == 1122)
    {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        emailphoneBook = title;
        isphoneBook = YES;

        if (![title isEqualToString:@"Cancel"])
        {
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.view addSubview:spinner];
            [spinner setHidden:NO];
            spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
            [spinner startAnimating];
            
            serve * emailCheck = [serve new];
            emailCheck.Delegate = self;
            emailCheck.tagName = @"emailCheck";
            [emailCheck getMemIdFromuUsername:[title lowercaseString]];
        }
    }
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return YES;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    isphoneBook=NO;
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - email handling
-(void)getMemberIdByUsingUserNameFromPhoneBook
{
    if ([emailphoneBook isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Denied" message:@"You are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n \n Please try someone ELSE's email address!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else
    {
        if ([self.view.subviews containsObject:spinner]) {
            [spinner removeFromSuperview];
        }
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:spinner];
        [spinner setHidden:NO];
        spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [spinner startAnimating];
        
        serve *emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:emailphoneBook];
    }
}

#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([self.recents count]==0)
    {
        [self.contacts setHidden:YES];
        [self.view addSubview: self.noContact_img];
    }
    searching = NO;
    emailEntry = NO;
    isRecentList = YES;
    isphoneBook = NO;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO];
    [self.contacts reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
    [self.contacts reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length] == 0)
    {
        searching=NO;
        emailEntry=NO;
        isRecentList=YES;
        
        [self.contacts reloadData];
        return;
    }
    if ([searchText length] > 0)
    {
        if ([self.view.subviews containsObject:self.noContact_img]) {
             [self.noContact_img removeFromSuperview];
        }
       
        searching = YES;
        NSRange isRange = [searchBar.text  rangeOfString:[NSString stringWithFormat:@"@"] options:NSCaseInsensitiveSearch];
        NSRange isRange2 = [searchBar.text  rangeOfString:[NSString stringWithFormat:@"."] options:NSCaseInsensitiveSearch];
        
        if(isRange.location != NSNotFound && isRange2.location != NSNotFound)
        {
            emailEntry = YES;
            isphoneBook=NO;
            searching = NO;
            isRecentList=NO;
            searchString = searchBar.text;
            [self.contacts setHidden:NO];
            if ([[assist shared]isRequestMultiple]) {
                return;
            }
        }
        else
        {
            emailEntry = NO;
            isphoneBook=NO;
            searching = YES;
            isRecentList=NO;
            searchString = searchBar.text;
            [self searchTableView];
        }
        [self.contacts reloadData];
    }
    else {
        isphoneBook=NO;
        searchString = [searchBar.text substringToIndex:[searchBar.text length] - 1];
        [self.contacts reloadData];
    }
}

- (void) searchTableView
{
    arrSearchedRecords =[[NSMutableArray alloc]init];
    for (NSString *key in [[assist shared] assos].allKeys)
    {
        NSMutableDictionary *dict = [[assist shared] assos][key];
        NSComparisonResult result = [[dict valueForKey:@"FirstName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        NSComparisonResult result2 = [[dict valueForKey:@"LastName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if ((result == NSOrderedSame || result2 == NSOrderedSame) && dict[@"FirstName"] && dict[@"LastName"]) {
            [arrSearchedRecords addObject:dict];
        }
    }
    if (![arrSearchedRecords isKindOfClass:[NSNull class]]) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"FirstName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *temp = [arrSearchedRecords copy];
        [arrSearchedRecords setArray:[temp sortedArrayUsingDescriptors:sortDescriptors]];
    }
}

#pragma mark - email handling
-(void)getMemberIdByUsingUserName
{
    [search resignFirstResponder];
    if ([[search.text lowercaseString] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Denied" message:@"You are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n \n Please try someone ELSE's email address!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else {
        if ([self.view.subviews containsObject:spinner]) {
            [spinner removeFromSuperview];
        }
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:spinner];
        [spinner setHidden:NO];
        spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [spinner startAnimating];
        
        serve *emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:[search.text lowercaseString]];
    }
}

#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)loadDelay
{
    NSMutableArray*arrNav=[nav_ctrl.viewControllers mutableCopy];
    [arrNav removeLastObject];
    [nav_ctrl setViewControllers:arrNav animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Error:(NSError *)Error {
    [self.hud hide:YES];

    /* UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show]; */
}

#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    [self.contacts setNeedsDisplay];
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
//        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [Alert show];
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        [timer invalidate];
        
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        
        [[assist shared]setPOP:YES];
        [self performSelector:@selector(loadDelay) withObject:Nil afterDelay:2.0];
        
    }

    else if ([tagName isEqualToString:@"getMemberIds"])
    {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error];
        NSMutableArray *temp2 = [[temp objectForKey:@"GetMemberIdsResult"] objectForKey:@"phoneEmailList"];
        NSMutableArray *additions = [NSMutableArray new];
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
                [additions addObject:new];
        }
        [[assist shared] addAssos:additions];
    }

    else if ([tagName isEqualToString:@"fb"])
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
    }

    else if ([tagName isEqualToString:@"recents"])
    {
        [spinner stopAnimating];
        [spinner setHidden:YES];
        NSError* error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *dict in self.recents) {
            NSMutableDictionary *prep = dict.mutableCopy;
            [prep setObject:@"YES" forKey:@"recent"];
            [temp addObject:prep];
        }
        self.recents = temp.mutableCopy;
        [[assist shared] addAssos:[self.recents mutableCopy]];
        
        if ([[assist shared] isRequestMultiple])
        {
            isRecentList=NO;
            searching = NO;
            emailEntry=NO;
            isRecentList=YES;
            isphoneBook=NO;
            [search resignFirstResponder];
            [search setText:@""];
            
            [search setShowsCancelButton:NO];
            arrRequestPersons=[self.recents mutableCopy];
            NSLog(@"%@",arrRequestPersons);
            
            if ([arrRequestPersons count]==0) {
                arrRequestPersons=[self.recents mutableCopy];
            }
            else {
                int loc=-1;
                for (int i=0;i<[self.recents count];i++) {
                    NSDictionary*dict=[self.recents objectAtIndex:i];
                    
                    for (int j=0;j<[arrRequestPersons count];j++) {
                        
                        NSDictionary*dictSub=[arrRequestPersons objectAtIndex:j];
                        if ([[dict valueForKey:@"MemberId"]caseInsensitiveCompare:[dictSub valueForKey:@"MemberId"] ] ==NSOrderedSame)
                            loc=1;
                    }
                    if (loc==-1) {
                        [arrRequestPersons addObject:dict];
                    }
                    else
                        loc=-1;
                }
            }
            NSLog(@"%@",arrRequestPersons);
            
            [self.contacts reloadData];
            return;
        }
        
        if ([self.recents count] > 0) {
            [self.contacts setHidden:NO];
            [self.contacts setStyleId:@"select_recipient"];
            [self.contacts reloadData];
        }
        else {
            [self.contacts setHidden:YES];
            self.noContact_img=[[UIImageView alloc] init];
            
            if (IS_IPHONE_5) {
                self.noContact_img.frame=CGRectMake(0, 93, 320, 405);
                self.noContact_img.contentMode=UIViewContentModeScaleToFill;
                self.noContact_img.image=[UIImage imageNamed:@"selectRecipientIntro.png"];
            }
            else {
                self.noContact_img.frame=CGRectMake(0, 93, 320, 320);
                self.noContact_img.contentMode=UIViewContentModeScaleToFill;
                self.noContact_img.image=[UIImage imageNamed:@"selectRecipientIntro_smallScreen.png"];
            }
            [self.view addSubview:self.noContact_img];

        }
    }
    
    else if ([tagName isEqualToString:@"searchByLocation"])
    {
        NSError* error;
        self.recents = [NSJSONSerialization
                      JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                      options:kNilOptions
                      error:&error];
         self.recents=[ self.recents mutableCopy];
        for(int i = 0; i < [ self.recents count]; i++)
        {
            for(int j = i+1; j < [ self.recents count]; j++)
            {
                NSDictionary *recordOne = [ self.recents objectAtIndex:i];
                NSDictionary *recordTwo = [ self.recents objectAtIndex:j];
                
                if([[recordOne valueForKey:@"Miles"] floatValue] > [[recordTwo valueForKey:@"Miles"] floatValue])
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
        NSError* error;
        NSMutableDictionary *dictResult = [NSJSONSerialization
                                           JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                           options:kNilOptions
                                           error:&error];

        if ([dictResult objectForKey:@"Result"] != [NSNull null])
        {
            if ([self.view.subviews containsObject:spinner]) {
                [spinner removeFromSuperview];
            }
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.view addSubview:spinner];
            [spinner setHidden:NO];
            spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
            [spinner startAnimating];
            serve *getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberDetails";
            [getDetails getDetails:[dictResult objectForKey:@"Result"]];
        }
        else
        {
            if ([[assist shared]isRequestMultiple])
            {
                [spinner stopAnimating];
                [spinner setHidden:YES];
                searching = NO;
                emailEntry=NO;
                isRecentList=NO;
                isphoneBook=NO;
                [search resignFirstResponder];
                [search setText:@""];
                [search setShowsCancelButton:NO];
                [self.contacts reloadData];
                return;
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if (isphoneBook) {
                [dict setObject:emailphoneBook forKey:@"email"];
            }
            else
                [dict setObject:searchString forKey:@"email"];
            
            [dict setObject:@"nonuser" forKey:@"nonuser"];
            isFromHome = NO;
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
            
            [spinner stopAnimating];
            [spinner setHidden:YES];
    
            return;
        }
    }
    
    else if ([tagName isEqualToString:@"getMemberDetails"])
    {
        NSError* error;
        [spinner stopAnimating];
        [spinner setHidden:YES];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setDictionary:[NSJSONSerialization
                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                             options:kNilOptions
                             error:&error]];
        
        if ([[assist shared]isRequestMultiple])
        {
            emailEntry=YES;
            int loc=0;
            
            for (int i=0;i<[arrRequestPersons count]; i++) {
                if ([[[arrRequestPersons objectAtIndex:i]valueForKey:@"MemberId"]isEqualToString:[dict valueForKey:@"MemberId"]]) {
                    loc=1;
                }
            }
            
            if (loc==0) {
                NSString*PhotoUrl=[dict valueForKey:@"PhotoUrl"];
                [dict setObject:PhotoUrl forKey:@"Photo"];
                [arrRequestPersons addObject:dict];
            }
            [self.contacts reloadData];
            return;
        }
        else
        {
            isEmailEntry=NO;
            int loc=0;
            
            for (int i=0;i<[arrRequestPersons count]; i++)
            {
                if ([[[arrRequestPersons objectAtIndex:i]valueForKey:@"MemberId"]isEqualToString:[dict valueForKey:@"MemberId"]]) {
                    loc=1;  
                }
            }
            
            if (loc==0)
            {
                NSString*PhotoUrl=[dict valueForKey:@"PhotoUrl"];
                [dict setObject:PhotoUrl forKey:@"Photo"];
                [arrRequestPersons addObject:dict];
            }
            isFromHome=NO;
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 6)
    {
        if (buttonIndex==0) {
            [self connect_to_facebook];
        }
        else{
            
        }
    }
    
    if (alertView.tag == 20220)
    {
        if (buttonIndex==1)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if (isphoneBook) {
                [dict setObject:emailphoneBook forKey:@"email"];
            }
            else
                [dict setObject:searchString forKey:@"email"];
            
            [dict setObject:@"nonuser" forKey:@"nonuser"];
             isFromHome=NO;
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
        }
    }
    else if (alertView.tag==4 && buttonIndex==0)
    {
        isEmailEntry=NO;
        emailEntry=NO;
        isphoneBook=NO;
        isRecentList=YES;
        searching=NO;
        search.text=@"";
        [search setShowsCancelButton:NO];
        [search resignFirstResponder];
        [self.contacts reloadData];
    }
}

#pragma mark - facebook integration
- (void)connect_to_facebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        accountStore = [[ACAccountStore alloc] init];
        facebookAccount = nil;
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"198279616971457",
                                  ACFacebookPermissionsKey: @[@"email",@"user_about_me"],
                                  ACFacebookAudienceKey: ACFacebookAudienceOnlyMe
                                  };
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [accountStore requestAccessToAccountsWithType:facebookAccountType
                                                   options:options completion:^(BOOL granted, NSError *e)
         {
             if (!granted) {
                 NSLog(@"didnt grant because: %@",e.description);
             }
             else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                     [self.navigationController.view addSubview:self.hud];
                     self.hud.delegate = self;
                     self.hud.labelText = @"Loading Facebook Info...";
                     [self.hud show:YES];
                 });
                 NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                 facebookAccount = [accounts lastObject];
              
                 [self finishFb];
             }
         }];
    }
    else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"You do not have a Facebook account attached to this phone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

-(void)renewFb
{
    [accountStore renewCredentialsForAccount:(ACAccount *)facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error){
        if(!error)
        {
            switch (renewResult) {
                case ACAccountCredentialRenewResultRenewed:
                    break;
                case ACAccountCredentialRenewResultRejected:
                    NSLog(@"User declined permission");
                    break;
                case ACAccountCredentialRenewResultFailed:
                    NSLog(@"non-user-initiated cancel, you may attempt to retry");
                    break;
                default:
                    break;
            }
            [self finishFb];
        }
        else{
            NSLog(@"error from renew credentials%@",error);
        }
    }];
}

-(void)finishFb
{
    NSString *acessToken = [NSString stringWithFormat:@"%@",facebookAccount.credential.oauthToken];
    NSDictionary *parameters = @{@"access_token": acessToken,@"fields":@"id,username,first_name,last_name,email"};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodGET
                              URL:feedURL
                              parameters:parameters];
    feedRequest.account = facebookAccount;
    facebook_info = [NSMutableDictionary new];
    [feedRequest performRequestWithHandler:^(NSData *respData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         facebook_info = [NSJSONSerialization
                               JSONObjectWithData:respData //1
                               options:kNilOptions
                               error:&error];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.hud hide:YES];

             [[NSUserDefaults standardUserDefaults] setObject:[facebook_info objectForKey:@"id"] forKey:@"facebook_id"];
             serve *fb = [serve new];
             [fb setDelegate:self];
             [fb setTagName:@"fb"];
             if ([facebook_info objectForKey:@"id"]) {
                 [fb storeFB:[facebook_info objectForKey:@"id"]];
             }
         });
         
     }];
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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,200,30)];
    title.textColor = kNoochGrayDark;
    
    if (section == 0)
    {
        if (self.location)
            title.text = @"Nearby Users";
        else if (searching)
            title.text = @"Search Results";
        else
            title.text = @"Recent Contacts";
    } else{
        title.text = @"";
    }
    [headerView addSubview:title];
    [headerView setBackgroundColor:[Helpers hexColor:@"f8f8f8"]];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching) {
        return [arrSearchedRecords count];
    }
    else if ([[assist shared] isRequestMultiple]) {
        return [arrRequestPersons count];
    }
    else if (emailEntry) {
        return 1;
    }
    else {
        return [self.recents count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        cell.indentationLevel = 1;
    }

    for (UIView *subview in cell.contentView.subviews) {
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
        cell.indentationWidth = 56;
        [cell.textLabel setStyleClass:@"select_recipient_pending_name"];

        NSDictionary * temp;

        if ([[assist shared] isRequestMultiple])
        {
            temp = [arrRequestPersons objectAtIndex:indexPath.row];
            arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
            int loc = -1;
            
            for (int i = 0; i<[arrRecipientsForRequest count]; i++)
            {
                NSDictionary *dictionary = [arrRecipientsForRequest objectAtIndex:i];
                if ([[dictionary valueForKey:@"MemberId"]isEqualToString:temp[@"MemberId"]]) {
                    loc = 1;
                }
                
            }
            if (loc == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
 //               loc =- 1;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }
        else {
            temp = [self.recents objectAtIndex:indexPath.row];
            NSLog(@"%@",temp);
        }
        
        UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        pic.clipsToBounds = YES;
        [cell.contentView addSubview:pic];
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;
        pic.clipsToBounds = YES;
        [pic sd_setImageWithURL:[NSURL URLWithString:temp[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        
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
        
        for (NSString *key in [assist shared].assos.allKeys)
        {
            NSDictionary *person = [assist shared].assos[key];
            if ([person[@"MemberId"] isEqualToString:temp[@"MemberId"]])
            {
                UIImageView *ab = [UIImageView new];
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
        //Nooch User
        npic.hidden = NO;
        [npic setFrame:CGRectMake(278, 19, 23, 27)];
        [npic setImage:[UIImage imageNamed:@"n_icon_46x54.png"]];
        [npic removeFromSuperview];
        
        NSDictionary *info = [arrSearchedRecords objectAtIndex:indexPath.row];
        [pic sd_setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        [cell setIndentationLevel:1];
        pic.hidden = NO;
        cell.indentationWidth = 56;
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",info[@"FirstName"],info[@"LastName"]];
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        
        if (info[@"facebookId"])
        {
            //add fb image
            UILabel *fb = [UILabel new];
            [fb setStyleClass:@"facebook_glyph"];
            [fb setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook"]];
            [cell.contentView addSubview:fb];
        }
        if (info[@"MemberId"])
        {
            [cell.contentView addSubview:npic];
        }
        if ([[[assist shared] assos] objectForKey:info[@"UserName"]])
        {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"]) {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                [ab setStyleClass:@"animate_bubble"];
                [cell.contentView addSubview:ab];
            }
        }
        if ([[assist shared] isRequestMultiple]) {
            [npic removeFromSuperview];
            arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
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
        cell.indentationWidth = 56;
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",[info[@"FirstName"] capitalizedString],[info[@"LastName"] capitalizedString]];
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        
        [npic removeFromSuperview];
        arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        NSLog(@"%@",arrRecipientsForRequest);
        
        int loc =- 1;
        
        for (int i = 0; i < [arrRecipientsForRequest count]; i++)
        {
            NSDictionary *dictionary=[arrRecipientsForRequest objectAtIndex:i];
            if ([[dictionary valueForKey:@"MemberId"]caseInsensitiveCompare:info[@"MemberId"]]==NSOrderedSame) {
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

    else if (isRecentList){
        //Recent List
        
        [npic setFrame:CGRectMake(278, 19, 23, 27)];
        [npic setImage:[UIImage imageNamed:@"n_icon_46x54.png"]];
        
        NSDictionary * info = [self.recents objectAtIndex:indexPath.row];
        [pic sd_setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        pic.hidden = NO;
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;

        cell.indentationWidth = 56;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"    %@ %@",info[@"FirstName"],info[@"LastName"]];
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([[[assist shared] assos] objectForKey:info[@"UserName"]])
        {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"]) {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                [ab setStyleClass:@"animate_bubble"];
                [cell.contentView addSubview:ab];
            }
        }
        if (![[assist shared] isRequestMultiple]) {
            [pic setStyleClass:@"animate_bubble"];
        }
    }
    
    else if (emailEntry)
    {
        //Email
        [self.contacts setStyleId:@"select_recipientwithoutSeperator"];
        cell.accessoryType = UITableViewCellAccessoryNone;
   //     [pic removeFromSuperview];
        [pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
        [pic setFrame:CGRectMake(130, 62, 60, 60)];
        pic.layer.cornerRadius = 29;
        [npic removeFromSuperview];
        
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
        [send_to_email setText:[NSString stringWithFormat:@"%@",search.text]];
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
    
    if ([[assist shared] isRequestMultiple])
    {
        NSDictionary *receiver =  [arrRequestPersons objectAtIndex:indexPath.row];
        
        if (searching) {
            receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];
        }
        
        arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        NSLog(@"%@",arrRecipientsForRequest);
        int loc = -1;
        for (int i = 0; i<[arrRecipientsForRequest count]; i++) {
            NSDictionary *dictionary=[arrRecipientsForRequest objectAtIndex:i];
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
            if ([[[assist shared]getArray] count] == 10) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You can't request more than 10 Users!" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alert show];
                return;
            }
            [arrRecipientsForRequest addObject:receiver];
            [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView reloadData];
        return;
    }
    
    if (emailEntry)
    {
        [self getMemberIdByUsingUserName];
        return;
    }
    
    if (searching)
    {
        searching = NO;
        emailEntry = NO;
        isRecentList = YES;
        [search resignFirstResponder];
        [search setText:@""];
        [search setShowsCancelButton:NO];

        NSDictionary *receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];
        
        if ([[assist shared] assos][receiver[@"UserName"]][@"addressbook"])
        {
            if ([self.view.subviews containsObject:spinner]) {
                [spinner removeFromSuperview];
            }
            emailphoneBook = receiver[@"UserName"];
            isphoneBook = YES;

            if ([receiver[@"emailCount"]intValue] > 1)
            {
                UIActionSheet *actionSheetObject = [[UIActionSheet alloc] init];
                for (int j=0; j<[receiver[@"emailCount"]intValue]; j++) {
                    [actionSheetObject addButtonWithTitle:[receiver[[NSString stringWithFormat:@"emailAdday%d",j]] lowercaseString]];
                }
                
                actionSheetObject.cancelButtonIndex = [actionSheetObject addButtonWithTitle:@"Cancel"];
                actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheetObject setTag:1122];
                actionSheetObject.delegate = self;
                [actionSheetObject showInView:self.view];
            }
            else
            {
                spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [self.view addSubview:spinner];
                [spinner setHidden:NO];
                spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
                [spinner startAnimating];
               
                serve *emailCheck = [serve new];
                emailCheck.Delegate = self;
                emailCheck.tagName = @"emailCheck";
                [emailCheck getMemIdFromuUsername:[receiver[@"UserName"] lowercaseString]];
            }
            
            return;
         }

        isFromHome = NO;
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:receiver];
        [self.navigationController pushViewController:how_much animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.contacts reloadData];
    }
    else
    {
        isFromHome = NO;
        NSDictionary *receiver =  [self.recents objectAtIndex:indexPath.row];
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:receiver];
        [self.navigationController pushViewController:how_much animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning  {
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}
@end