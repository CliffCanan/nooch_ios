//
//  SelectRecipient.m
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "SelectRecipient.h"
#import "UIImageView+WebCache.h"
#import "Helpers.h"
#import "ECSlidingViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MBProgressHUD.h"
@interface SelectRecipient ()
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) NSMutableArray *recents;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property(nonatomic) BOOL location;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UISegmentedControl *completed_pending;
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
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [[assist shared]setRequestMultiple:NO];
    isPayBack=NO;
    isEmailEntry=NO;
    isAddRequest=NO;
    isUserByLocation=NO;
    isphoneBook=NO;
    [arrRecipientsForRequest removeAllObjects];
    [[assist shared]setArray:[arrRecipientsForRequest copy]];
    arrRequestPersons=[[NSMutableArray alloc]init];
    
    UIButton *location = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [location setStyleId:@"icon_location"];
    
    //UIBarButtonItem *loc = [[UIBarButtonItem alloc] initWithCustomView:location];
    //[self.navigationItem setRightBarButtonItem:loc];
    
    NSArray *seg_items = @[@"Recent",@"Find by Location"];
    self.completed_pending = [[UISegmentedControl alloc] initWithItems:seg_items];
    [self.completed_pending setStyleId:@"history_segcontrol"];
    [self.completed_pending addTarget:self action:@selector(recent_or_location:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.completed_pending];
    [self.completed_pending setSelectedSegmentIndex:0];
    
    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
    [search setBackgroundColor:kNoochGrayDark];
    search.placeholder=@"Search by Name or Email";
    [search setDelegate:self];
    [search setTintColor:kNoochGrayDark];
    [self.view addSubview:search];
    
    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 82, 320, [[UIScreen mainScreen] bounds].size.height-146)];
    [self.contacts setDataSource:self]; [self.contacts setDelegate:self];
    [self.contacts setSectionHeaderHeight:30];
    [self.contacts setStyleId:@"select_recipient"];
    [self.view addSubview:self.contacts]; [self.contacts reloadData];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.delegate = self;
    self.hud.labelText = @"Loading your Recent list";
    [self.hud show:YES];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[assist shared] isRequestMultiple] && isAddRequest) {
        self.location = NO;
        [self.completed_pending setSelectedSegmentIndex:0];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Recipients" message:@"To send a request to more than one person, search for them and tap each additional person (up to 10). Tap Done when finished." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.navigationItem setTitle:@"Group Request"];
        [self.navigationItem setRightBarButtonItem:Nil];
        UIButton *Done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        Done.frame=CGRectMake(277, 25, 80, 35);
        [Done setStyleId:@"icon_RequestMultiple"];
        [Done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Done setTitle:@"Done" forState:UIControlStateNormal];
        [Done addTarget:self action:@selector(DoneEditing_RequestMultiple:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.navigationItem setHidesBackButton:YES];
        UIBarButtonItem *DoneItem = [[UIBarButtonItem alloc] initWithCustomView:Done];
        [self.navigationItem setRightBarButtonItem:DoneItem];
        isRecentList=NO;
        searching = NO;
        emailEntry=NO;
        isRecentList=YES;
        isphoneBook=NO;
        [search resignFirstResponder];
        [search setText:@""];
        
        [search setShowsCancelButton:NO];
        if ([arrRequestPersons count]==0) {
            arrRequestPersons=[self.recents mutableCopy];
        }
        else
        {
            int loc=-1;
            for (int i=0;i<[self.recents count];i++) {
                NSDictionary*dict=[self.recents objectAtIndex:i];
                
                for (int j=0;j<[arrRequestPersons count];j++) {
                   
                   NSDictionary*dictSub=[arrRequestPersons objectAtIndex:j];
                    if ([[dict valueForKey:@"MemberId"]isEqualToString:[dictSub valueForKey:@"MemberId"]])
                        loc=1;
                    
                }
                if (loc==-1) {
                    [arrRequestPersons addObject:dict];
                }
                else
                    loc=-1;
            }
        }
        [self.contacts reloadData];
    }
    else {
        [self.navigationItem setTitle:@"Select Recipient"];
        [self.navigationItem setHidesBackButton:NO];
        isUserByLocation=NO;
        [self.navigationItem setRightBarButtonItem:Nil];
        UIButton *location = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [location setStyleId:@"icon_location"];
        isRecentList=YES;
        [[assist shared]setRequestMultiple:NO];
        //UIBarButtonItem *loc = [[UIBarButtonItem alloc] initWithCustomView:location];
        //[self.navigationItem setRightBarButtonItem:loc];
        isRecentList=YES;
        searching=NO;
        emailEntry=NO;
        search.text=@"";
        [search setShowsCancelButton:NO];
        [search resignFirstResponder];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [self address_book];
    [self facebook];
    serve *recents = [serve new];
    [recents setTagName:@"recents"];
    [recents setDelegate:self];
    [recents getRecents];
}
-(void)DoneEditing_RequestMultiple:(id)sender{
    if ([[[assist shared]getArray] count]==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Select a Recipient to Request!" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    isAddRequest=NO;
    HowMuch *how_much = [[HowMuch alloc] init];
    [self.navigationController pushViewController:how_much animated:YES];
}

-(void) facebook
{
    NSDictionary *options = @{
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
         NSMutableArray *fbFriendsTemp = [[NSMutableArray alloc] init];
         NSMutableArray *fbNoochFriendsTemp = [[NSMutableArray alloc] init];
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
             }else
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
    for(int i=0; i<nPeople; i++)
    {
        NSMutableDictionary *curContact=[[NSMutableDictionary alloc] init];
        ABRecordRef person=CFArrayGetValueAtIndex(people, i);
        NSString *contacName = [[NSMutableString alloc] init];
        contacName =(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *firstName = [[NSString alloc] init];
        NSString *lastName = [[NSString alloc] init];
        firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if((__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty))
        {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)]];
            lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        }
        NSData *contactImage;
        if(ABPersonHasImageData(person) > 0 )
        {
            contactImage = (__bridge NSData *)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail));
        }
        else
        {
            contactImage = UIImageJPEGRepresentation([UIImage imageNamed:@"profile_picture.png"], 1);
        }
        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSString *emailId = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailInfo, 0);
        if(emailId != NULL)
        {
            [curContact setObject:emailId forKey:@"UserName"]; [curContact setObject:emailId forKey:@"emailAddy"];
        }
        if(contacName != NULL)  [curContact setObject:contacName forKey:@"Name"];
        if(firstName != NULL) [curContact setObject:firstName forKey:@"FirstName"];
        if(lastName != NULL)  [curContact setObject:lastName forKey:@"LastName"];
        //[curContact setObject:contactImage forKey:@"image"];
        [curContact setObject:@"YES" forKey:@"addressbook"];
        NSString *phone,*phone2,*phone3;
        if(ABMultiValueGetCount(phoneNumber)> 0)
            phone =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 0));
        
        if(ABMultiValueGetCount(phoneNumber)> 1)
        {
            phone2=  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 1));
            phone2 = [phone2 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone2 length])];
            [curContact setObject:phone2 forKey:@"phoneNo2"];
        }
        
        if(ABMultiValueGetCount(phoneNumber)> 2)
        {
            phone3 =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,2));
            phone3 = [phone3 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone3 length])];
            [curContact setObject:phone3 forKey:@"phoneNo3"];
        }
        if(phone == NULL && (emailId == NULL || [emailId rangeOfString:@"facebook"].location != NSNotFound))
        {
            [additions addObject:curContact];
        }else if( contacName == NULL)
        {
        }
        else
        {
            NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
            if([strippedNumber length] == 11){
                strippedNumber = [strippedNumber substringFromIndex:1];
            }
            if(strippedNumber != NULL)
                [curContact setObject:strippedNumber forKey:@"phoneNo"];
            
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
    CFRelease(people);
    CFRelease(addressBook);
}

-(void)recent_or_location:(UISegmentedControl *)sender
{
    [search resignFirstResponder];
    [search setText:@""];
    searching = NO;
    if (sender.selectedSegmentIndex == 0) {
        self.location = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        //[search setHidden:NO];
        CGRect frame = self.contacts.frame;
        frame.origin.y =82; frame.size.height = [[UIScreen mainScreen] bounds].size.height-146;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];
        serve *recents = [serve new];
        [recents setTagName:@"recents"];
        [recents setDelegate:self];
        [recents getRecents];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.delegate = self;
        self.hud.labelText = @"Loading your Recent list";
        [self.hud show:YES];
    } else {
        self.location = YES;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        //[search setHidden:YES];
        CGRect frame = self.contacts.frame;
        frame.origin.y =40;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height-104;
        [self.contacts setFrame:frame];
        [UIView commitAnimations];
        serve * ser = [serve new];
        ser.tagName=@"search";
        [ser setDelegate:self];
        [ser getLocationBasedSearch:@"10"];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.delegate = self;
        self.hud.labelText = @"Finding users close to you";
        [self.hud show:YES];
    }
}
-(void)phonebook:(id)sender
{
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

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue) ;
    NSLog(@"%@",emailAddresses);
    CFRelease(emailMultiValue);
    [_addressBookController dismissViewControllerAnimated:YES completion:^{
        if ([emailAddresses count]==0) {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"No email attached with the user!" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
        else if ([emailAddresses count]==1){
            //  search.text=[emailAddresses objectAtIndex:0];
            //[search setShowsCancelButton:YES];
            // [search becomeFirstResponder];
            emailphoneBook= [emailAddresses objectAtIndex:0];
            isphoneBook=YES;
            [self getMemberIdByUsingUserNameFromPhoneBook];
        }
        else{
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet tag]==1111)
    {
        if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
            
            emailphoneBook= [actionSheet buttonTitleAtIndex:buttonIndex];
            isphoneBook=YES;
            [self getMemberIdByUsingUserNameFromPhoneBook];
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
-(void)getMemberIdByUsingUserNameFromPhoneBook{
    //[search resignFirstResponder];
    if ([emailphoneBook isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Denied" message:@"You are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else
    {
        
        if ([self.view.subviews containsObject:spinner]) {
            [spinner removeFromSuperview];
        }
        // NSLog(@"%@",[dictResult objectForKey:@"Result"]);
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
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    if ([self.recents count]==0) {
        [arrow setHidden:NO];
        [em setHidden:NO];
        [self.contacts setHidden:YES];
    }
    // histSearch = NO;
    searching = NO;
    emailEntry=NO;
    isRecentList=YES;
    isphoneBook=NO;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    
    [searchBar setShowsCancelButton:NO];
    
    [self.contacts reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
    if ([[assist shared]isRequestMultiple]) {
        [self getMemberIdByUsingUserName];
        return;
    }
    //newTransfersDecrement = newTransfers;
    [self.contacts reloadData];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //histSearch = YES;
    [searchBar becomeFirstResponder];
    // [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    //  NSLog(@"%@",searchText);
    if ([searchBar.text length]==0) {
        searching=NO;
        emailEntry=NO;
        isRecentList=YES;
        
        [self.contacts reloadData];
        return;
    }
    if ([searchText length]>0) {
        searching = YES;
        NSRange isRange = [searchBar.text  rangeOfString:[NSString stringWithFormat:@"@"] options:NSCaseInsensitiveSearch];
        if(isRange.location != NSNotFound){
            emailEntry = YES;
            isphoneBook=NO;
            searching = NO;
            isRecentList=NO;
            searchString = searchBar.text;
            [arrow setHidden:YES];
            [em setHidden:YES];
            [self.contacts setHidden:NO];
            if ([[assist shared]isRequestMultiple]) {
                return;
            }
        }
        else{
            isphoneBook=NO;
            emailEntry = NO;
            searching = YES;
            isRecentList=NO;
            searchString = searchBar.text;
            [self searchTableView];
        }
        [self.contacts reloadData];
    }
    else{
        isphoneBook=NO;
        searchString = [searchBar.text substringToIndex:[searchBar.text length] - 1];
        [self.contacts reloadData];
    }
    
}
- (void) searchTableView
{
    arrSearchedRecords =[[NSMutableArray alloc]init];
    if ([[assist shared]isRequestMultiple]) {
        for (NSMutableDictionary *dict in arrRequestPersons)
        {
            
            NSComparisonResult result = [[dict valueForKey:@"FirstName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
            if (result == NSOrderedSame)
            {
                [arrSearchedRecords addObject:dict];
            }
        }
    }
    else{
        for (NSString *key in [[assist shared] assos].allKeys)
        {
            NSMutableDictionary *dict = [[assist shared] assos][key];
            NSComparisonResult result = [[dict valueForKey:@"FirstName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
            if (result == NSOrderedSame && dict[@"FirstName"] && dict[@"LastName"])
            {
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
}
#pragma mark - email handling
-(void)getMemberIdByUsingUserName{
    [search resignFirstResponder];
    if ([[search.text lowercaseString] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Denied" message:@"You are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else
    {
        if ([self.view.subviews containsObject:spinner])
        {
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

-(void)loadDelay{
    NSMutableArray*arrNav=[nav_ctrl.viewControllers mutableCopy];
    [arrNav removeLastObject];
    [nav_ctrl setViewControllers:arrNav animated:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName{
    [self.hud hide:YES];
    [self.contacts setNeedsDisplay];
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [Alert show];
        
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
        
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
                [additions addObject:new];
        }
        [[assist shared] addAssos:additions];
    }
    
    else if ([tagName isEqualToString:@"recents"]) {
        [spinner stopAnimating];
        [spinner setHidden:YES];
        NSError* error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *dict in self.recents)
        {
            NSMutableDictionary *prep = dict.mutableCopy;
            [prep setObject:@"YES" forKey:@"recent"];
            [temp addObject:prep];
        }
        self.recents = temp.mutableCopy;
        [[assist shared] addAssos:[self.recents mutableCopy]];
        if ([[assist shared] isRequestMultiple]) {
            isRecentList=NO;
            searching = NO;
            emailEntry=NO;
            isRecentList=YES;
            isphoneBook=NO;
            [search resignFirstResponder];
            [search setText:@""];
            
            [search setShowsCancelButton:NO];
            arrRequestPersons=[self.recents mutableCopy];
            if ([arrRequestPersons count]==0) {
                arrRequestPersons=[self.recents mutableCopy];
            }
            else
            {
                int loc=-1;
                for (int i=0;i<[self.recents count];i++) {
                    NSDictionary*dict=[self.recents objectAtIndex:i];
                    
                    for (int j=0;j<[arrRequestPersons count];j++) {
                        
                        NSDictionary*dictSub=[arrRequestPersons objectAtIndex:j];
                        if ([[dict valueForKey:@"MemberId"]isEqualToString:[dictSub valueForKey:@"MemberId"]])
                            loc=1;
                        
                    }
                    if (loc==-1) {
                        [arrRequestPersons addObject:dict];
                    }
                    else
                        loc=-1;
                }
            }
            [self.contacts reloadData];
            return;
        }
        
        if ([self.recents count]>0) {
            [self.contacts setHidden:NO];
            [self.contacts reloadData];
        }
        else
        {
            [self.contacts setHidden:YES];
            
            arrow = [UIImageView new];
            [arrow setStyleId:@"empltyRecentList"];
            [self.view addSubview:arrow];
            
            em = [UILabel new]; [em setStyleClass:@"recentEmptytable_view_cell_detailtext_1"];
            
            [em setTextAlignment:NSTextAlignmentCenter];
            [em setBackgroundColor:[UIColor clearColor]];
            em.numberOfLines=10;
            [em setText:@"Hey There!\nUse this handy dandy search bar to easily find contacts to send or request money with.\n\n\nThe next time you come here, your most recent contacts will automatically appear "];
            [self.view addSubview:em];
            
        }
        
    }else if ([tagName isEqualToString:@"search"]) {
        NSError* error;
        self.recents = [NSJSONSerialization
                      JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                      options:kNilOptions
                      error:&error];
        [[assist shared] addAssos:[self.recents mutableCopy]];
        if ([self.recents count]!=0) {
            if ([[assist shared]isRequestMultiple]) {
                arrRequestPersons = [self.recents mutableCopy];
            }
            [self.contacts reloadData];
        }
    }else if([tagName isEqualToString:@"emailCheck"])
    {
        NSError* error;
        NSMutableDictionary *dictResult = [NSJSONSerialization
                                           JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                           options:kNilOptions
                                           error:&error];
        
        
        if([dictResult objectForKey:@"Result"] != [NSNull null])
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
            if ([[assist shared]isRequestMultiple]) {
                //ftgUIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Unknown" message:@"We at Nooch have no knowledge of this email address. You can't make request to this mail address?" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil,nil];
                
                //[alertRedirectToProfileScreen show];
                [spinner stopAnimating];
                [spinner setHidden:YES];
                // histSearch = NO;
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
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
            return;
            
            UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Unknown" message:@"We at Nooch have no knowledge of this email address. Do you still want to Transfer to this mail address?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
            [alertRedirectToProfileScreen setTag:20220];
            [alertRedirectToProfileScreen show];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            
        }
    }
    else if([tagName isEqualToString:@"getMemberDetails"])
    {
        NSError* error;
        [spinner stopAnimating];
        [spinner setHidden:YES];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setDictionary:[NSJSONSerialization
                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                             options:kNilOptions
                             error:&error]];
        if ([[assist shared]isRequestMultiple]) {
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
        else{
            
            isEmailEntry=NO;
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
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
        }
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==20220) {
        if (buttonIndex==1) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if (isphoneBook) {
                [dict setObject:emailphoneBook forKey:@"email"];
            }
            else
                [dict setObject:searchString forKey:@"email"];
            
            [dict setObject:@"nonuser" forKey:@"nonuser"];
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
            [self.navigationController pushViewController:how_much animated:YES];
        }
    }
    else if (alertView.tag==4 && buttonIndex==0){
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.location) {
            return @"Nearby Users";
        } else if (searching)
        {
            return @"Search Results";
        }
        else
        {
            return @"Recent";
        }
        return @"Recent";
    }else{
        return @"";
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake (10,0,200,30)];
    title.textColor = kNoochGrayDark;
    if (section == 0) {
        if (self.location)
            title.text = @"Nearby Users";
        else if (searching)
            title.text = @"Search Results";
        else
            title.text = @"Recent Contacts";
    }else{
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
    else if ([[assist shared] isRequestMultiple])
    {
        return [arrRequestPersons count];
    }
    
    else if (emailEntry)
    {
        return 1;
    }
    else{
        
        return [self.recents count];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.indentationLevel = 1;
    }
    for (UIView*subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [cell.detailTextLabel setText:@""];
    
    UIImageView*pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 60, 60)];
    pic.clipsToBounds = YES;
    [pic setStyleClass:@"animate_bubble"];
    UIImageView* npic = [UIImageView new];
    npic.clipsToBounds = YES;
    
    [cell.contentView addSubview:pic];
    [cell.contentView addSubview:npic];
    
    [WTGlyphFontSet setDefaultFontSetName: @"fontawesome"];
    UIImageView *ttt = [[UIImageView alloc] initWithFrame:CGRectMake(20, 48, 12, 16)];
    [ttt setImage:[UIImage imageGlyphNamed:@"facebook" height:40 color:kNoochBlue]];
    
    if (self.location) {
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.indentationLevel = 1; cell.indentationWidth = 70;
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        
        NSDictionary * temp;
        
        if ([[assist shared] isRequestMultiple]) {
            temp = [arrRequestPersons objectAtIndex:indexPath.row];
            arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
            int loc =-1;
            for (int i=0; i<[arrRecipientsForRequest count]; i++)
            {
                NSDictionary*dictionary=[arrRecipientsForRequest objectAtIndex:i];
                if ([[dictionary valueForKey:@"MemberId"]isEqualToString:temp[@"MemberId"]])
                {
                    loc=1;
                }
                
            }
            if (loc==1) {
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
            else{
                loc=-1;
                cell.accessoryType=UITableViewCellAccessoryNone;
            }
            
        }
        else
        {
             temp = [self.recents objectAtIndex:indexPath.row];
        }
        UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 60, 60)];
        pic.clipsToBounds = YES;
        [cell.contentView addSubview:pic];
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = kNoochBlue.CGColor; pic.layer.borderWidth = 1;
        pic.clipsToBounds = YES;
        [pic setImageWithURL:[NSURL URLWithString:temp[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        NSString * name = [NSString stringWithFormat:@"   %@ %@",[[temp objectForKey:@"FirstName"] capitalizedString],[[temp objectForKey:@"LastName"] capitalizedString]];
        [cell.textLabel setText:name];
        
        NSString * miles;
        if ([[temp objectForKey:@"Miles"] intValue]<1)
        {
            miles = [NSString stringWithFormat:@"    %.0f feet",([[temp objectForKey:@"Miles"] floatValue] * 5280)];
        }
        else
        {
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
                [cell.contentView addSubview:ab];
                break;
            }
        }
        
        [pic setStyleClass:@"animate_bubble"];
        return cell;
    }
    else if (searching)
    {
        //Nooch User
        npic.hidden=NO;
        [npic setFrame:CGRectMake(265,25, 17, 20)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        [npic removeFromSuperview];
        
        NSDictionary *info = [arrSearchedRecords objectAtIndex:indexPath.row];
        [pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        [cell setIndentationLevel:1];
        pic.hidden=NO;
        cell.indentationWidth = 70;
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderWidth = 1;
        pic.layer.borderColor = [Helpers hexColor:@"6D6E71"].CGColor;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",info[@"FirstName"],info[@"LastName"]];
        
        if (info[@"facebookId"]) {
            //add fb image
            [cell.contentView addSubview:ttt];
        }
        if (info[@"MemberId"]) {
            [cell.contentView addSubview:npic];
        }
        if ([[[assist shared] assos] objectForKey:info[@"UserName"]]) {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"]) {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
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
    else if ([[assist shared] isRequestMultiple]) {
        
        [npic setFrame:CGRectMake(260,25, 20, 20)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        NSDictionary *info = [arrRequestPersons objectAtIndex:indexPath.row];
        [pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        pic.hidden=NO;
        cell.indentationWidth = 70;
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = [Helpers hexColor:@"6D6E71"].CGColor; pic.layer.borderWidth = 1;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",[info[@"FirstName"] capitalizedString],[info[@"LastName"] capitalizedString]];
        
        
        [npic removeFromSuperview];
        arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        int loc =-1;
        for (int i=0; i<[arrRecipientsForRequest count]; i++) {
            NSDictionary*dictionary=[arrRecipientsForRequest objectAtIndex:i];
            if ([[dictionary valueForKey:@"MemberId"]isEqualToString:info[@"MemberId"]])
            {
                loc=1;
            }
            
        }
        if (loc==1) {
             cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        else{
            loc=-1;
              cell.accessoryType=UITableViewCellAccessoryNone;
        }
        
        if ([[[assist shared] assos] objectForKey:info[@"UserName"]]) {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"]) {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                [cell.contentView addSubview:ab];
            }
        }
        
    }
    
    
    else if(isRecentList){
        
        //Recent List
        
        [npic setFrame:CGRectMake(260,25, 20, 20)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        NSDictionary *info = [self.recents objectAtIndex:indexPath.row];
        [pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        pic.hidden=NO;
        cell.indentationWidth = 70;
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = [Helpers hexColor:@"6D6E71"].CGColor; pic.layer.borderWidth = 1;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",info[@"FirstName"],info[@"LastName"]];
        
        //        if ([[assist shared] isRequestMultiple]) {
        //            [npic removeFromSuperview];
        //            arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        //            if ([arrRecipientsForRequest containsObject:info]) {
        //                cell.accessoryType=UITableViewCellAccessoryCheckmark;
        //            }
        //            else
        //                cell.accessoryType=UITableViewCellAccessoryNone;
        //
        //
        //        }
        //        else
        cell.accessoryType=UITableViewCellAccessoryNone;
        
        if ([[[assist shared] assos] objectForKey:info[@"UserName"]]) {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"]) {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                [cell.contentView addSubview:ab];
            }
        }
    }
    else if(emailEntry){
        //Email
        cell.accessoryType=UITableViewCellAccessoryNone;
        [pic removeFromSuperview];
        [npic removeFromSuperview];
        cell.indentationWidth = 10;
        cell.textLabel.text = [NSString stringWithFormat:@"Send to %@",search.text];
        
        return cell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (self.location) {
        NSDictionary *receiver =  [self.recents objectAtIndex:indexPath.row];
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:receiver];
        [self.navigationController pushViewController:how_much animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }*/
    
    if ([[assist shared] isRequestMultiple]) {
        
        NSDictionary *receiver =  [arrRequestPersons objectAtIndex:indexPath.row];
        if (searching) {
            receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];
        }
        arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        NSLog(@"%@",arrRecipientsForRequest);
        int loc =-1;
        for (int i=0; i<[arrRecipientsForRequest count]; i++) {
            NSDictionary*dictionary=[arrRecipientsForRequest objectAtIndex:i];
            if ([[dictionary valueForKey:@"MemberId"]isEqualToString:receiver[@"MemberId"]]) {
                loc=1;
            }
            else
                loc=-1;
        }
        if (loc==1) {
            [arrRecipientsForRequest removeObject:receiver];
            [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
        }
       
//        if ([arrRecipientsForRequest containsObject:receiver]) {
//            [arrRecipientsForRequest removeObject:receiver];
//            [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
//        }
        else{
            if ([[[assist shared]getArray] count]==10) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You can't request more than 10 Users!" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
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
    
    if (emailEntry){
        [self getMemberIdByUsingUserName];
        return;
    }
    if (searching) {
        // histSearch = NO;
        searching = NO;
        emailEntry=NO;
        isRecentList=YES;
        [search resignFirstResponder];
        [search setText:@""];
        
        [search setShowsCancelButton:NO];
        
        
        NSDictionary *receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:receiver];
        
        [self.navigationController pushViewController:how_much animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.contacts reloadData];
    }
    else{
        NSDictionary *receiver =  [self.recents objectAtIndex:indexPath.row];
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:receiver];
        
        [self.navigationController pushViewController:how_much animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
