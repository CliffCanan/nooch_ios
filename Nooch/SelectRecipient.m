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
    // Do any additional setup after loading the view from its nib.
    
    UIButton *location = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [location setStyleId:@"icon_location"];
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
    
    UISearchBar *search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [search setBackgroundColor:kNoochGrayDark];
    [search setTintColor:kNoochGrayDark];
    [self.view addSubview:search];
}

#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName{
    if ([tagName isEqualToString:@"recents"]) {
        NSError* error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        [self.contacts reloadData];
        if ([self.view.subviews containsObject:loader]) {
            [loader removeFromSuperview];
            [me endWaitStat];
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
    //29/12
    
//    if ([self.recents count] == 0) {
//        return 1;
//    }
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
         cell.indentationLevel = 1; cell.indentationWidth = 60;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*cell.textLabel.textColor = [UIColor colorWithRed:51./255.
                                                   green:153./255.
                                                    blue:204./255.
                                                   alpha:1.0];*/
    }
    [cell.textLabel setStyleClass:@"select_recipient_name"];
    if ([self.recents count] == 0) {
        UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 50, 50)];
        pic.layer.borderColor = kNoochGrayDark.CGColor;
        pic.layer.borderWidth = 1;
        pic.layer.cornerRadius = 25;
        pic.clipsToBounds = YES;
        [cell addSubview:pic];
        
        cell.textLabel.text = @"Preston Hults";
        
        return cell;
    }
    
    NSDictionary *info = [self.recents objectAtIndex:indexPath.row];

    UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 50, 50)];
    pic.layer.borderColor = kNoochGrayDark.CGColor;
    pic.layer.borderWidth = 1;
    pic.layer.cornerRadius = 25;
    pic.clipsToBounds = YES;
    // remove comment if photo url is valid
    //[pic setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
    //  placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
    [cell addSubview:pic];

    [cell setIndentationLevel:1]; [cell setIndentationWidth:40];
    cell.textLabel.text = [NSString stringWithFormat:@"    %@ %@",info[@"FirstName"],info[@"LastName"]];;
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 70.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *receiver = [self.recents objectAtIndex:indexPath.row];//[self.recents objectAtIndex:indexPath.row];
    NSLog(@"%@",[self.recents objectAtIndex:indexPath.row]);
    
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
