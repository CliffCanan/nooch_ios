//
//  ResetPassword.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "ResetPassword.h"
#import "Home.h"

@interface ResetPassword ()
@property (nonatomic,strong) UITextField *old;
@property (nonatomic,strong) UITextField *pass;
@property (nonatomic,strong) UITextField *confirm;
@property (nonatomic,strong) UIButton *save;
@end

@implementation ResetPassword

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
	// Do any additional setup after loading the view.
    [self.view setStyleClass:@"background_gray"];
    
    UITableView *menu = [UITableView new];
    [menu setStyleId:@"settings"];
    [menu setDelegate:self]; [menu setDataSource:self]; [menu setScrollEnabled:NO];
    [self.view addSubview:menu];
    [menu reloadData];
    
    self.old = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
    [self.old setStyleClass:@"resetpw_right_label"];
    [self.old setDelegate:self];
    [self.old setPlaceholder:@"Enter Password"];
    [self.old setSecureTextEntry:YES];
    
    self.pass = [[UITextField alloc] initWithFrame:self.old.frame];
    [self.pass setStyleClass:@"resetpw_right_label"];
    [self.pass setDelegate:self];
    [self.pass setPlaceholder:@"New Password"];
    [self.pass setSecureTextEntry:YES];
    
    self.confirm = [[UITextField alloc] initWithFrame:self.old.frame];
    [self.confirm setStyleClass:@"resetpw_right_label"];
    [self.confirm setDelegate:self];
    [self.confirm setPlaceholder:@"Confirm Password"];
    [self.confirm setSecureTextEntry:YES];
    
    self.save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.save setFrame:CGRectMake(0, 200, 0, 0)];
    [self.save setStyleClass:@"button_green"];
    [self.save setTitle:@"Change Password" forState:UIControlStateNormal];
    [self.save setEnabled:NO];
    [self.view addSubview:self.save];
    
    [self.old becomeFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = kNoochGrayLight;
        cell.selectedBackgroundView = selectionColor;
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.indentationLevel = 1;
    [cell.textLabel setStyleClass:@"settings_resetpass_labels"];
    [cell.textLabel setStyleClass:@"resetpw_left_label"];
    if(indexPath.row == 0){
        cell.textLabel.text = @"Current Password";
        [cell.contentView addSubview:self.old];
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"New Password";
        [cell.contentView addSubview:self.pass];
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"Confirm Password" ;
        [cell.contentView addSubview:self.confirm];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.old becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        [self.pass becomeFirstResponder];
    }else if(indexPath.row == 2){
        [self.confirm becomeFirstResponder];
    }
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
