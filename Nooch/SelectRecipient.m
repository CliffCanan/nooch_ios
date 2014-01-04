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

@interface SelectRecipient ()
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) NSMutableArray *recents;
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

    // Do any additional setup after loading the view from its nib.
    
    UIButton *location = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [location setStyleId:@"icon_location"];
    [location addTarget:self action:@selector(locationSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *loc = [[UIBarButtonItem alloc] initWithCustomView:location];
    [self.navigationItem setRightBarButtonItem:loc];
    
    serve *recents = [serve new];
    [recents setTagName:@"recents"];
    [recents setDelegate:self];
    [recents getRecents];
    if (![self.view.subviews containsObject:loader]) {
        loader=[me waitStat:@"Loading Recent List..."];
        [self.view addSubview:loader];
    }
    
    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, [[UIScreen mainScreen] bounds].size.height-90)];
    [self.contacts setDataSource:self]; [self.contacts setDelegate:self];
    [self.contacts setSectionHeaderHeight:30];
    [self.contacts setStyleId:@"select_recipient"];
    [self.view addSubview:self.contacts]; [self.contacts reloadData];
    
    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [search setBackgroundColor:kNoochGrayDark];
    [search setDelegate:self];
    [search setTintColor:kNoochGrayDark];
    [self.view addSubview:search];
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
        [self.contacts reloadData];
        return;
    }
    if ([searchText length]>0) {
        searching = YES;
        NSRange isRange = [searchBar.text  rangeOfString:[NSString stringWithFormat:@"@"] options:NSCaseInsensitiveSearch];
        if(isRange.location != NSNotFound){
            emailEntry = YES;
            searching = NO;
        }
        else{
            emailEntry = NO;
            searching = YES;
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
    if ([search.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Denied" message:@"You are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else
    {
        //            if (![self.view.subviews containsObject:loader]) {
        //                loader=[me waitStat:@"Checking email address."];
        //                [self.view addSubview:loader];
        //            }
        
        serve *emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:search.text];
    }
}


#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName{
    NSError* error;
    if ([tagName isEqualToString:@"recents"]) {
        
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        [self.contacts reloadData];
        //        if ([self.view.subviews containsObject:loader]) {
        //            [loader removeFromSuperview];
        //            [me endWaitStat];
        //        }
        
    }
    else if([tagName isEqualToString:@"emailCheck"])
    {
        NSMutableDictionary *dictResult = [NSJSONSerialization
                                           JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                           options:kNilOptions
                                           error:&error];
        if([dictResult objectForKey:@"Result"] != [NSNull null])
        {
            NSLog(@"%@",[dictResult objectForKey:@"Result"]);
            //emailSend = YES;
            serve *getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberDetails";
            [getDetails getDetails:[dictResult objectForKey:@"Result"]];
        }
        else
        {
            
            //[me endWaitStat];
            UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Unknown" message:@"We at Nooch have no knowledge of this email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertRedirectToProfileScreen setTag:20220];
            [alertRedirectToProfileScreen show];
            //            if ([self.view.subviews containsObject:loader])
            //            {
            //                [loader removeFromSuperview];
            //                [me endWaitStat];
            //
            //            }
            
            
        }
    }
    else if([tagName isEqualToString:@"getMemberDetails"])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setDictionary:[NSJSONSerialization
                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                             options:kNilOptions
                             error:&error]];
        NSLog(@"%@",dict);
        // NSDictionary *receiver =  [self.recents objectAtIndex:indexPath.row];;
        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
        
        [self.navigationController pushViewController:how_much animated:YES];
        
        
        //            receiverFirst = [dict objectForKey:@"FirstName"];
        //            receiverLast = [dict objectForKey:@"LastName"];
        //            receiverId = [dict objectForKey:@"MemberId"];
        //            [dictGroup removeAllObjects];
        //            [dictGroup setValue:dict forKey:@"1"];
        //            transfer*transferOBJ=[storyboard instantiateViewControllerWithIdentifier:@"transfer"];
        //            transferOBJ.dictResp=dictGroup;
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
    
    //3
    if (searching) {
        return [arrSearchedRecords count];
    }
    else if (emailEntry)
    {
        return 1;
    }
    return [self.recents count];
    //29/12
    
//    if ([self.recents count] == 0) {
//        return 1;
//    }
    //return [self.recents count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kNoochGrayLight];
         cell.indentationLevel = 1; cell.indentationWidth = 60;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*cell.textLabel.textColor = [UIColor colorWithRed:51./255.
                                                   green:153./255.
                                                    blue:204./255.
                                                   alpha:1.0];*/
    }
    for (UIView*subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [cell.textLabel setStyleClass:@"select_recipient_name"];
    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 50, 50)];
    pic.clipsToBounds = YES;
    // remove comment if photo url is valid
    //[pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
    //  placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
    
    
    [cell addSubview:pic];
    
    if(emailEntry){
        cell.indentationWidth = 10;
        
        pic.hidden=YES;
        NSLog(@"%@",search.text);
        cell.textLabel.text = [NSString stringWithFormat:@"Send to %@",search.text];
        return cell;
    }
    pic.hidden=NO;
    //[pic setStyleClass:@"list_userprofilepic"];
    //[pic setStyleCSS:@"background-image : url(Preston.png)"];
    if (searching) {
        
        NSDictionary *info = [arrSearchedRecords objectAtIndex:indexPath.row];
        
        
        [cell setIndentationLevel:1]; [cell setIndentationWidth:40];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",info[@"FirstName"],info[@"LastName"]];
    }
    else{
        
        NSDictionary *info = [self.recents objectAtIndex:indexPath.row];
        //kaNSLog(@"%@",info);
        
        [cell setIndentationLevel:1]; [cell setIndentationWidth:40];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",info[@"FirstName"],info[@"LastName"]];
        
        
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
