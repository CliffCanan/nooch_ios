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
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Select Recipient"];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    

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
    isRecentList=YES;
    searching=NO;
    serve *recents = [serve new];
    [recents setTagName:@"recents"];
    [recents setDelegate:self];
    [recents getRecents];
}
-(void)phonebook:(id)sender
{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}
#pragma mark - ABPeoplePickerNavigationController Delegate method implementation

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    // Initialize a mutable dictionary and give it initial values.
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                                            forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];
   
    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    // Get the phone numbers as a multi-value property.
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    CFRelease(phonesRef);
    
    
    // Get the e-mail addresses as a multi-value property.
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
     NSString *emailAddress = CFBridgingRelease(emailsRef);
    
     //if ([emailAddress rangeOfString:@"@"].location!=NSNotFound && [emailAddress rangeOfString:@"."].location!=NSNotFound) {
    NSLog(@"%@",emailAddress);
        // NSArray*arr=[emailAddress componentsSeparatedByString:@" "];
         //NSLog(@"%@",arr);
    // }
    
    
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
       
        NSString *emailAddresslbl = CFBridgingRelease(currentEmailLabel);
        
        //if ([emailAddress rangeOfString:@"@"].location!=NSNotFound && [emailAddress rangeOfString:@"."].location!=NSNotFound) {
        NSLog(@"%@",emailAddresslbl);
//        if ([emailAddresslbl isKindOfClass:[NSNull class]] || emailAddresslbl==NULL || [emailAddresslbl isEqualToString:@"(null)"]|| emailAddresslbl==nil
//) {
//            
//            NSLog(@"%@",emailAddresslbl);
//            emailAddresslbl=[self stringBetweenString:@"- " andString:@" " fullText:emailAddress];
//             NSLog(@"%@",emailAddresslbl);
//        }
//      
        // }

        if (CFStringCompare(currentEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"homeEmail"];
        }
        
        if (CFStringCompare(currentEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"workEmail"];
        }
        
        CFRelease(currentEmailLabel);
        CFRelease(currentEmailValue);
    }
    CFRelease(emailsRef);
    
    
    // Get the first street address among all addresses of the selected contact.
    ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
    if (ABMultiValueGetCount(addressRef) > 0) {
        NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
        
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressStreetKey] forKey:@"address"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressZIPKey] forKey:@"zipCode"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressCityKey] forKey:@"city"];
    }
    CFRelease(addressRef);
    
    
    // If the contact has an image then get it too.
    if (ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        [contactInfoDict setObject:contactImageData forKey:@"image"];
    }
    
    // Initialize the array if it's not yet initialized.
    
    // Add the dictionary to the array.
    // [_arrContactsData addObject:contactInfoDict];
    isphoneBook=YES;
    if (![[contactInfoDict valueForKey:@"homeEmail"] isEqualToString:@""]) {
        emailphoneBook= [contactInfoDict  valueForKey:@"homeEmail"];
        [self getMemberIdByUsingUserNameFromPhoneBook];
    }
    else if(![[contactInfoDict valueForKey:@"homeEmail"] isEqualToString:@""])
    {
        emailphoneBook= [contactInfoDict valueForKey:@"workEmail"];
    [self getMemberIdByUsingUserNameFromPhoneBook];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Email ID is not available." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        
    }
    NSLog(@"%@",contactInfoDict );
    // Reload the table view data.
    // [self.tableView reloadData];
    
    // Dismiss the address book view controller.
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end fullText:(NSString*)text {
    NSScanner* scanner = [NSScanner scannerWithString:text];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
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
    userlocation*loc=[userlocation new];
    [self.navigationController pushViewController:loc animated:YES];
}
#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    // histSearch = NO;
    searching = NO;
    emailEntry=NO;
    isRecentList=YES;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    
    [searchBar setShowsCancelButton:NO];
    
    [self.contacts reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
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
            searching = NO;
            isRecentList=NO;
              searchString = searchBar.text;
        }
        else{
            emailEntry = NO;
            searching = YES;
            isRecentList=NO;
            searchString = searchBar.text;
            [self searchTableView];
        }
        [self.contacts reloadData];
    }
    else{
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


#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName{
    NSError* error;
   
    if ([tagName isEqualToString:@"recents"]) {
        [spinner stopAnimating];
        [spinner setHidden:YES];
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
            
            UIImageView *logo = [UIImageView new];
            [logo setStyleId:@"empltyRecentList"];
            [self.view addSubview:logo];
            UILabel *em = [UILabel new]; [em setStyleClass:@"table_view_cell_textlabel_1"];
            CGRect frame = em.frame; frame.origin.y = 160; //frame = CGRectMake(10, 100, 300, 30);
            [em setBackgroundColor:[UIColor clearColor]];
            [em setFrame:frame];
            [em setText:@"Email"];
            [self.view addSubview:em];

        }
    
    }
    else if([tagName isEqualToString:@"emailCheck"])
    {
        NSMutableDictionary *dictResult = [NSJSONSerialization
                                           JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                           options:kNilOptions
                                           error:&error];
        if([dictResult objectForKey:@"Result"] != [NSNull null])
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
            serve *getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberDetails";
            [getDetails getDetails:[dictResult objectForKey:@"Result"]];
        }
        else
        {
            
            //[me endWaitStat];
            UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Unknown" message:@"We at Nooch have no knowledge of this email address. Do you still want to Transfer to this mail address?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
            [alertRedirectToProfileScreen setTag:20220];
            [alertRedirectToProfileScreen show];
            [spinner stopAnimating];
            [spinner setHidden:YES];
            
        }
    }
    else if([tagName isEqualToString:@"getMemberDetails"])
    {
        [spinner stopAnimating];
        [spinner setHidden:YES];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setDictionary:[NSJSONSerialization
                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                             options:kNilOptions
                             error:&error]];
       
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

//            serve*serveOBJ=[serve new];
//            [serveOBJ setDelegate:self];
//            serveOBJ.tagName=@"sendNonNooch";
//            serveOBJ TransferMoneyToNonNoochUser:<#(NSDictionary *)#> email:<#(NSString *)#>
        }
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
    else if (emailEntry)
    {
        return 1;
    }
    return [self.recents count];
   
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
        [npic setFrame:CGRectMake(250,15, 34, 40)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        
        
        NSDictionary *info = [arrSearchedRecords objectAtIndex:indexPath.row];
        [pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
                [cell setIndentationLevel:1];
        pic.hidden=NO;
        cell.indentationWidth = 70;
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = kNoochBlue.CGColor; pic.layer.borderWidth = 1;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",info[@"FirstName"],info[@"LastName"]];
    }
    else if(isRecentList){
        
       //Recent List
       
        [npic setFrame:CGRectMake(250,15, 34, 40)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        NSDictionary *info = [self.recents objectAtIndex:indexPath.row];
        NSLog(@"%@",info);
        [pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
        placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        pic.hidden=NO;
        cell.indentationWidth = 70;
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = kNoochBlue.CGColor; pic.layer.borderWidth = 1;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",info[@"FirstName"],info[@"LastName"]];
        
        
    }
   else if(emailEntry){
       //Email
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
    if (emailEntry){
        [self getMemberIdByUsingUserName];
        return;
    }
    if (searching) {
        NSDictionary *receiver =  [self.recents objectAtIndex:indexPath.row];;
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:receiver];
        
        [self.navigationController pushViewController:how_much animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
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
    // Dispose of any resources that can be recreated.
}

@end
