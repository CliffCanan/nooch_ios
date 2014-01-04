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
    
    serve * ser = [serve new];
    ser.tagName=@"search";
    [ser setDelegate:self];
    [ser getLocationBasedSearch:@"2"];
	// Do any additional setup after loading the view.
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName {
    if ([tagName isEqualToString:@"search"]) {
        NSError* error;
        self.users = [NSJSONSerialization
                      JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                      options:kNilOptions
                      error:&error];
        
        
        if ([self.users count]!=0) {
            [self.usersTable reloadData];
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
    cell.indentationLevel = 1; cell.indentationWidth = 60;
    [cell.textLabel setStyleClass:@"select_recipient_name"];
    
    NSDictionary * temp = [self.users objectAtIndex:indexPath.row];
    
    NSString * name = [NSString stringWithFormat:@"%@ %@",[temp objectForKey:@"FirstName"],[temp objectForKey:@"LastName"]];
    [cell.textLabel setText:name];
    
    NSString * miles;
    if ([[temp objectForKey:@"Miles"] intValue]<1) {
        miles = [NSString stringWithFormat:@"%d feet",([[temp objectForKey:@"Miles"] intValue] * 100)];
    }
    else
    {
        miles = [NSString stringWithFormat:@"%d miles",[[temp objectForKey:@"Miles"] intValue]];
        
    }
    
    
    [cell.detailTextLabel setText:miles];
    
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
