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
#import "userlocation.h"
#import "ECSlidingViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
@interface SelectRecipient ()
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) NSMutableArray *recents;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[assist shared] isRequestMultiple] && isAddRequest) {
        [self.navigationItem setRightBarButtonItem:Nil];
        UIButton *Done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        Done.frame=CGRectMake(277, 25, 80, 35);
        [Done setStyleId:@"icon_RequestMultiple"];
        [Done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Done setTitle:@"Done" forState:UIControlStateNormal];
        [Done addTarget:self action:@selector(DoneEditing_RequestMultiple:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *DoneItem = [[UIBarButtonItem alloc] initWithCustomView:Done];
        [self.navigationItem setRightBarButtonItem:DoneItem];
        isRecentList=NO;
        if ([arrRequestPersons count]==0) {
            arrRequestPersons=[self.recents mutableCopy];
        }
        
        [self.contacts reloadData];
        
        
    }
    else {
        isUserByLocation=NO;
        [self.navigationItem setRightBarButtonItem:Nil];
        UIButton *location = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [location setStyleId:@"icon_location"];
        [location addTarget:self action:@selector(locationSearch:) forControlEvents:UIControlEventTouchUpInside];
        isRecentList=YES;
        [[assist shared]setRequestMultiple:NO];
        // isMutipleRequest=NO;
        UIBarButtonItem *loc = [[UIBarButtonItem alloc] initWithCustomView:location];
        [self.navigationItem setRightBarButtonItem:loc];
        isRecentList=YES;
        searching=NO;
        emailEntry=NO;
        //isphoneBook=NO;
        search.text=@"";
        [search setShowsCancelButton:NO];
        [search resignFirstResponder];
        
        serve *recents = [serve new];
        [recents setTagName:@"recents"];
        [recents setDelegate:self];
        [recents getRecents];
        
        //[self.contacts reloadData];
    }
    
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Select Recipient"];
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
    
    //    //clear Image cache
    //    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    //    [imageCache clearMemory];
    //    [imageCache clearDisk];
    //    [imageCache cleanDisk];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *location = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [location setStyleId:@"icon_location"];
    [location addTarget:self action:@selector(locationSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *loc = [[UIBarButtonItem alloc] initWithCustomView:location];
    [self.navigationItem setRightBarButtonItem:loc];
    
    
    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, [[UIScreen mainScreen] bounds].size.height-90)];
    [self.contacts setDataSource:self]; [self.contacts setDelegate:self];
    [self.contacts setSectionHeaderHeight:30];
    [self.contacts setStyleId:@"select_recipient"];
    [self.view addSubview:self.contacts]; [self.contacts reloadData];
    
    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
    [search setBackgroundColor:kNoochGrayDark];
    search.placeholder=@"Search by Name or Email";
    [search setDelegate:self];
    [search setTintColor:kNoochGrayDark];
    [self.view addSubview:search];
    
    UIButton *phonebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [phonebook setStyleId:@"icon_phonebook"];
    [phonebook addTarget:self action:@selector(phonebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phonebook];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [spinner startAnimating];
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


#pragma mark-Location Search
-(void)locationSearch:(id)sender{
    isUserByLocation=YES;
    userlocation*loc=[userlocation new];
    [self.navigationController pushViewController:loc animated:YES];
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
    for (NSMutableDictionary *dict in self.recents)
    {
        
        NSComparisonResult result = [[dict valueForKey:@"FirstName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame)
        {
            [arrSearchedRecords addObject:dict];
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
    
    NSLog(@"%@",nav_ctrl.viewControllers);
    NSMutableArray*arrNav=[nav_ctrl.viewControllers mutableCopy];
    [arrNav removeLastObject];
    [nav_ctrl setViewControllers:arrNav animated:NO];
    NSLog(@"%@",nav_ctrl.viewControllers);
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName{
    
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [Alert show];
        
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
        
        [timer invalidate];
        
        
        NSLog(@"%@",nav_ctrl.viewControllers);
        
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        
        [[assist shared]setPOP:YES];
        [self performSelector:@selector(loadDelay) withObject:Nil afterDelay:2.0];
        
    }
    
    
    else if ([tagName isEqualToString:@"recents"]) {
        [spinner stopAnimating];
        [spinner setHidden:YES];
        NSError* error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        NSLog(@"%@",self.recents);
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
            em.numberOfLines=10;             [em setText:@"Hey There!\nUse this handy dandy search bar to easily find contacts to send or request money with.\n\n\nThe next time you come here, your most recent contacts will automatically appear "];
            [self.view addSubview:em];
            
        }
        
    }
    else if([tagName isEqualToString:@"emailCheck"])
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
                UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Unknown" message:@"We at Nooch have no knowledge of this email address. You can't make request to this mail address?" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil,nil];
                
                [alertRedirectToProfileScreen show];
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
        NSLog(@"%@",dict);
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
        isEmailEntry=YES;
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
        
        [self.navigationController pushViewController:how_much animated:YES];
        
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
        title.text = @"Recent";
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
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.indentationLevel = 1;
        
    }
    for (UIView*subview in cell.contentView.subviews) {
        
        [subview removeFromSuperview];
    }
    
    UIImageView*pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 60, 60)];
    pic.clipsToBounds = YES;
    UIImageView* npic = [UIImageView new];
    npic.clipsToBounds = YES;
    
    [cell.contentView addSubview:pic];
    [cell.contentView addSubview:npic];
    
    if (searching) {
        //Nooch User
        
        npic.hidden=NO;
        [npic setFrame:CGRectMake(260,25, 20, 20)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        
        
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
        //Recent List
        
        [npic setFrame:CGRectMake(260,25, 20, 20)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        NSDictionary *info = [arrRequestPersons objectAtIndex:indexPath.row];
        NSLog(@"%@",info);
        [pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        pic.hidden=NO;
        cell.indentationWidth = 70;
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = [Helpers hexColor:@"6D6E71"].CGColor; pic.layer.borderWidth = 1;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",info[@"FirstName"],info[@"LastName"]];
        
        
        [npic removeFromSuperview];
        arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        if ([arrRecipientsForRequest containsObject:info])
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType=UITableViewCellAccessoryNone;
        
    }
    
    
    else if(isRecentList){
        
        //Recent List
        
        [npic setFrame:CGRectMake(260,25, 20, 20)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        NSDictionary *info = [self.recents objectAtIndex:indexPath.row];
        NSLog(@"%@",info);
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 70.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[assist shared] isRequestMultiple]) {
        
        NSDictionary *receiver =  [arrRequestPersons objectAtIndex:indexPath.row];
        if (searching) {
            receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];
        }
        arrRecipientsForRequest=[[[assist shared] getArray] mutableCopy];
        NSLog(@"%@",arrRecipientsForRequest);
        if ([arrRecipientsForRequest containsObject:receiver]) {
            [arrRecipientsForRequest removeObject:receiver];
            [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
        }
        else{
            NSLog(@"%d",[[[assist shared]getArray] count]);
            if ([[[assist shared]getArray] count]==10) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You can't request more than 10 Users!" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alert show];
                return;
            }
            [arrRecipientsForRequest addObject:receiver];
            [[assist shared]setArray:[arrRecipientsForRequest copy]];
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
