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
    
//    if (![self.view.subviews containsObject:loader]) {
//        loader=[me waitStat:@"Loading Recent List..."];
//        [self.view addSubview:loader];
//    }
    
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
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [spinner startAnimating];
    serve *recents = [serve new];
    [recents setTagName:@"recents"];
    [recents setDelegate:self];
    [recents getRecents];
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
              searchString = searchBar.text;
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
    if ([search.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]){
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
        [emailCheck getMemIdFromuUsername:search.text];
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
        [self.contacts reloadData];
        
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
            UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Unknown" message:@"We at Nooch have no knowledge of this email address. Are You sure?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
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
   // [cell.textLabel setStyleClass:@"select_recipient_name"];
    
    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 60, 60)];
    pic.clipsToBounds = YES;
    [pic setTag:indexPath.row];
    [cell addSubview:pic];
    
    UIImageView *npic = [UIImageView new];
    npic.clipsToBounds = YES;
    [npic setTag:indexPath.row];
    [cell addSubview:npic];

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
        // [pic setStyleClass:@"list_userprofilepic"];
        //[pic setStyleCSS:@"background-image : url(Preston.png)"];
        
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = kNoochBlue.CGColor; pic.layer.borderWidth = 1;
        pic.clipsToBounds = YES;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",info[@"FirstName"],info[@"LastName"]];
    }
    else{
    
        //Nooch User
        npic.hidden=NO;
        [npic setFrame:CGRectMake(250,15, 34, 40)];
        [npic setImage:[UIImage imageNamed:@"n_Icon.png"]];
        

        NSDictionary *info = [self.recents objectAtIndex:indexPath.row];
        NSLog(@"%@",info);
        
        [pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
        placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        pic.hidden=NO;
        cell.indentationWidth = 70;
        // [pic setStyleClass:@"list_userprofilepic"];
        //[pic setStyleCSS:@"background-image : url(Preston.png)"];
        
        [pic setFrame:CGRectMake(20, 5, 60, 60)];
        pic.layer.cornerRadius = 30; pic.layer.borderColor = kNoochBlue.CGColor; pic.layer.borderWidth = 1;
        pic.clipsToBounds = YES;
        [cell setIndentationLevel:1];
        cell.textLabel.text = [NSString stringWithFormat:@"   %@ %@",info[@"FirstName"],info[@"LastName"]];
        
        
    }
    if(emailEntry){
        for (UIView*subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        cell.indentationWidth = 10;
         npic.hidden=YES;
                pic.hidden=YES;
        // [pic setFrame:CGRectMake(0, 0, 0, 0)];
        //  [npic setFrame:CGRectMake(0, 0, 0, 0)];
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
