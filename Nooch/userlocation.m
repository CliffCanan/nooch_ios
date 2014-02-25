//
//  userlocation.m
//  Nooch
//
//  Created by Vicky Mathneja on 04/01/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "userlocation.h"
#import <Pixate/Pixate.h>
#import "serve.h"
#import "UIImageView+WebCache.h"
#import "HowMuch.h"
@interface userlocation ()<serveD>
@property(nonatomic,strong) UITableView *usersTable;
@property(nonatomic,strong) NSMutableArray *users;
@end

@implementation userlocation

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
    [self.navigationItem setTitle:@"Location Based Search"];
    self.usersTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    [self.usersTable setDataSource:self]; [self.usersTable setDelegate:self];
    [self.usersTable setSectionHeaderHeight:30];
    [self.usersTable setStyleId:@"select_recipient"];
    [self.view addSubview:self.usersTable]; [self.usersTable reloadData];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [spinner startAnimating];
    [spinner setHidden:NO];
    serve * ser = [serve new];
    ser.tagName=@"search";
    [ser setDelegate:self];
    [ser getLocationBasedSearch:@"2"];
	// Do any additional setup after loading the view.
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName {
    [spinner stopAnimating];
    [spinner setHidden:YES];
    
    if ([tagName isEqualToString:@"search"]) {
        NSError* error;
        self.users = [NSJSONSerialization
                      JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                      options:kNilOptions
                      error:&error];
        
        NSLog(@"%@", self.users);   
        if ([self.users count]!=0) {
            [self.usersTable reloadData];
        }
        else{
            if (![[assist shared]islocationAllowed]) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Please enable location services from iPhone settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [av show];
            }
           

        }
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    tableView.rowHeight = 80;
    return self.users.count;
}
////- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
////
////
////    return view;
////
////}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return 60;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setTextColor:kNoochGrayLight];
    cell.indentationLevel = 1; cell.indentationWidth = 70;
    [cell.textLabel setStyleClass:@"select_recipient_name"];
    
    NSDictionary * temp = [self.users objectAtIndex:indexPath.row];
    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 60, 60)];
    pic.clipsToBounds = YES;
    [cell.contentView addSubview:pic];
    [pic setFrame:CGRectMake(20, 10, 60, 60)];
    pic.layer.cornerRadius = 30; pic.layer.borderColor = kNoochBlue.CGColor; pic.layer.borderWidth = 1;
    pic.clipsToBounds = YES;
    [pic setImageWithURL:[NSURL URLWithString:temp[@"Photo"]]
        placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
    NSString * name = [NSString stringWithFormat:@"   %@ %@",[[temp objectForKey:@"FirstName"] capitalizedString],[[temp objectForKey:@"LastName"] capitalizedString]];
    [cell.textLabel setText:name];
    
    NSString * miles;
    if ([[temp objectForKey:@"Miles"] intValue]<1) {
        miles = [NSString stringWithFormat:@"    %f feet",([[temp objectForKey:@"Miles"] floatValue] * 5280)];
    }
    else
    {
        miles = [NSString stringWithFormat:@"    %d miles",[[temp objectForKey:@"Miles"] intValue]];
        
    }
    
    
    [cell.detailTextLabel setText:miles];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *receiver =  [self.users objectAtIndex:indexPath.row];
            HowMuch *how_much = [[HowMuch alloc] initWithReceiver:receiver];
        
        [self.navigationController pushViewController:how_much animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
