//
//  SettingsOptions.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "SettingsOptions.h"
#import "Home.h"
#import "Register.h"
#import "ProfileInfo.h"
#import "PINSettings.h"
#import "NotificationSettings.h"

@interface SettingsOptions ()
@property(atomic,weak)UIButton *logout;
@end

@implementation SettingsOptions

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
    [self.navigationItem setTitle:@"Settings"];
    
    [self.view setStyleClass:@"background_gray"];
    
    UITableView *menu = [UITableView new];
    [menu setStyleId:@"settings"];
    [menu setDelegate:self]; [menu setDataSource:self]; [menu setScrollEnabled:NO];
    [self.view addSubview:menu];
    [menu reloadData];
    
    self.logout = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logout setTitle:@"Sign Out" forState:UIControlStateNormal];
    [ self.logout addTarget:self action:@selector(sign_out) forControlEvents:UIControlEventTouchUpInside];
    [self.logout setStyleClass:@"button_gray"];
    [self.logout setStyleId:@"button_signout"];
    [self.view addSubview: self.logout];
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
    UILabel *title = [UILabel new];
    [title setStyleClass:@"settings_table_label"];
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, 17, 12, 18)];
    arrow.image = [UIImage imageNamed:@"Arrow.png"];
    [cell.contentView addSubview:arrow];
    if(indexPath.row == 0){
        title.text = @"Profile Info";
    }else if(indexPath.row == 1){
        title.text = @"PIN Settings";
    }else if(indexPath.row == 2){
        title.text = @"Notification Settings" ;
    }
    [cell.contentView addSubview:title];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self profile];
    }
    else if (indexPath.row == 1) {
        [self pin];
    }else if(indexPath.row == 2){
        [self notifications];
    }
}

- (void)profile
{
    ProfileInfo *info = [ProfileInfo new];
    [self performSelector:@selector(navigate_to:) withObject:info afterDelay:0.1];
}
- (void)pin
{
    PINSettings *pin = [PINSettings new];
    [self performSelector:@selector(navigate_to:) withObject:pin afterDelay:0.1];
}
- (void)notifications
{
    NotificationSettings *notes = [NotificationSettings new];
    [self performSelector:@selector(navigate_to:) withObject:notes afterDelay:0.1];
}
- (void) navigate_to:(id)view
{
    [self.navigationController pushViewController:view animated:YES];
}

- (void)sign_out
{
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sign Out" message:@"Are you sure you want to sign out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"I'm Sure", nil];
    [av show];
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    
    NSError* error;
    NSMutableDictionary*dictResponse = [NSJSONSerialization
                                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                        options:kNilOptions
                                        error:&error];
     if([tagName isEqualToString:@"logout"])
    {
        if([dictResponse valueForKey:@"Result"])
        {
            if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Success."]) {
                
                
                [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
                NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
                [nav_ctrl performSelector:@selector(disable)];
                Register *reg = [Register new];
                [self.navigationController pushViewController:reg animated:YES];
            
                me = [core new];
                
            }
            else
            {
                
            }
        }
    }
  
}
#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[assist shared]setisloggedout:YES];
        [timer invalidate];
        timer=nil;
        serve*  serveOBJ=[serve new];
        serveOBJ.Delegate=self;
        
        serveOBJ.tagName=@"logout";
        [serveOBJ LogOutRequest:[[NSUserDefaults standardUserDefaults ]valueForKey:@"MemberId"]];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
