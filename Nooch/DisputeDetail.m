//
//  DisputeDetail.m
//  Nooch
//
//  Created by Vicky Mathneja on 01/08/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "DisputeDetail.h"
#import "Home.h"
#import "Register.h"
@interface DisputeDetail ()
@property(nonatomic,strong) UITextField *txtStatus;
@property(nonatomic,strong) UITextField *txtDate;
@property(nonatomic,strong) UITextField *txtID;
@property(nonatomic,strong) UITextField *txtReviewDate;
@property(nonatomic,strong) UITextField *txtResolvedD;
@property(nonatomic,strong) UILabel *lblNotes;
@property(nonatomic,strong) UITableView *list;
@end

@implementation DisputeDetail

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
    self.title=@"Dispute Details";
    
    self.txtStatus = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtStatus setTextAlignment:NSTextAlignmentRight];
    [self.txtStatus setBackgroundColor:[UIColor clearColor]];
    [self.txtStatus setPlaceholder:@"First & Last Name"];
    [self.txtStatus setDelegate:self];
    [self.txtStatus setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtStatus setText:[NSString stringWithFormat:@"%@ %@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"] capitalizedString],[[[NSUserDefaults standardUserDefaults] objectForKey:@"LastName"] capitalizedString]]];
    [self.txtStatus setUserInteractionEnabled:NO];
    [self.txtStatus setTag:0];
    [self.view addSubview:self.txtStatus];
    
    self.txtID = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtID setTextAlignment:NSTextAlignmentRight];
    [self.txtID setBackgroundColor:[UIColor clearColor]];
    [self.txtID setPlaceholder:@"email@email.com"];
    [self.txtID setDelegate:self];
    [self.txtID setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.txtID setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtStatus setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]];
    [self.txtID setUserInteractionEnabled:NO];
    [self.txtID setTag:0];
    [self.view addSubview:self.txtID];
    
    //Recovery Mail
    self.txtDate = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtDate setTextAlignment:NSTextAlignmentRight];
    [self.txtDate setBackgroundColor:[UIColor clearColor]];
    [self.txtDate setPlaceholder:@"(Optional)"];
    [self.txtDate setDelegate:self];
    [self.txtDate setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.txtDate setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtDate setTag:1];
    [self.view addSubview:self.txtDate];
    
    self.txtReviewDate = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtReviewDate setTextAlignment:NSTextAlignmentRight];
    [self.txtReviewDate setBackgroundColor:[UIColor clearColor]];
    [self.txtReviewDate setPlaceholder:@"555-555-5555"];
    [self.txtReviewDate setDelegate:self];
    [self.txtReviewDate setKeyboardType:UIKeyboardTypePhonePad];
    [self.txtReviewDate setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtReviewDate setTag:2];
    [self.view addSubview:self.txtReviewDate];
    
    // Address
    self.txtResolvedD = [[UITextField alloc] initWithFrame:CGRectMake(95, 5, 210, 44)];
    [self.txtResolvedD setTextAlignment:NSTextAlignmentRight];
    [self.txtResolvedD setBackgroundColor:[UIColor clearColor]];
    [self.txtResolvedD setPlaceholder:@"123 Nooch Lane"];
    [self.txtResolvedD setDelegate:self];
    [self.txtResolvedD setKeyboardType:UIKeyboardTypeDefault];
    [self.txtResolvedD setStyleClass:@"table_view_cell_detailtext_1"];
    [self.txtResolvedD setTag:3];
    [self.view addSubview:self.txtResolvedD];
    self.list = [UITableView new];
    [self.list setFrame:CGRectMake(0, 100, 320, 350)];
    [self.list setDelegate:self];
    [self.list setDataSource:self];
    [self.list setRowHeight:50];
    [self.list setScrollEnabled:NO];
    [self.view addSubview:self.list];
        
    // Do any additional setup after loading the view.
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:kNoochGrayLight];
        cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        cell.clipsToBounds = YES;
    }
    if (indexPath.row == 0) {
        UILabel *Status = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [Status setBackgroundColor:[UIColor clearColor]];
        [Status setText:@"Status"];
        [Status setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:Status];
        [cell.contentView addSubview:self.txtStatus];
        [cell setUserInteractionEnabled:NO];
    }
    else if (indexPath.row == 1) {
        
        UILabel *ID = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [ID setBackgroundColor:[UIColor clearColor]];
        [ID setText:@"Dispute ID"];
        [ID setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:ID];
        [cell.contentView addSubview:self.txtID];
    }
    else if (indexPath.row == 2) {
        UILabel *Date = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [Date setBackgroundColor:[UIColor clearColor]];
        [Date setText:@"Dispute Date"];
        [Date setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:Date];
        [cell.contentView addSubview:self.txtDate];
    }
    else if (indexPath.row == 3) {
       
        UILabel *ReviewDate = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [ReviewDate setBackgroundColor:[UIColor clearColor]];
        [ReviewDate setText:@"Review Date"];
        [ReviewDate setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:ReviewDate];
        [cell.contentView addSubview:self.txtReviewDate];
    }
    else if (indexPath.row == 4) {
        UILabel *ResolvedD = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 140, 50)];
        [ResolvedD setBackgroundColor:[UIColor clearColor]];
        [ResolvedD setText:@"Resolved Date"];
        [ResolvedD setStyleClass:@"table_view_cell_textlabel_1"];
        [cell.contentView addSubview:ResolvedD];
        [cell.contentView addSubview:self.txtResolvedD];
    }
        return cell;
}

#pragma mark - server delegation

- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    //[self.hud hide:YES];
    NSError* error;
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [Alert show];
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [timer invalidate];
        // timer=nil;
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        NSMutableArray*arrNav=[nav_ctrl.viewControllers mutableCopy];
        for (int i=[arrNav count]; i>1; i--) {
            [arrNav removeLastObject];
        }
        
        [nav_ctrl setViewControllers:arrNav animated:NO];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    if ([tagName isEqualToString:@"email_verify"]) {
        NSString *response = [[NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error] objectForKey:@"Result"];
            }
}
#pragma mark - file paths
- (NSString *)autoLogin{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    }
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
