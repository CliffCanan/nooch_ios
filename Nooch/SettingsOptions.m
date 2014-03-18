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
#import "ECSlidingViewController.h"
#import "knoxWeb.h"
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
-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Settings"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [WTGlyphFontSet setDefaultFontSetName: @"fontawesome"];
    UIImageView *ttt = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    [ttt setImage:[UIImage imageGlyphNamed:@"reorder" height:40 color:[UIColor whiteColor]]];
    
    
    [self.navigationItem setHidesBackButton:YES];
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setFrame:CGRectMake(0, 0, 30, 30)];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger setBackgroundImage:ttt.image forState:UIControlStateNormal];
    UIBarButtonItem *menu1 = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu1];
    
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Settings"];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [ttt setImage:[UIImage imageGlyphNamed:@"cogs" height:40 color:[UIColor whiteColor]]];
    
    [self.view setStyleClass:@"background_gray"];
    
    UIView *linked_background = [UIView new];
    [linked_background setStyleId:@"account_background"];
    [self.view addSubview:linked_background];
    
    UILabel *bank_name = [UILabel new];
    [bank_name setStyleId:@"linked_account_name"];
    [bank_name setText:@"Bank of America"];
    [linked_background addSubview:bank_name];
    
    UILabel *bank_num = [UILabel new];
    [bank_num setStyleId:@"linked_account_number"];
    [bank_num setText:@"XXXX XXXX XXXX 1234"];
    [linked_background addSubview:bank_num];
    
    UIButton *unlink_account = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [unlink_account setStyleId:@"remove_account"];
    [unlink_account setTitle:@"Remove" forState:UIControlStateNormal];
    [unlink_account addTarget:self action:@selector(remove_attached_bank) forControlEvents:UIControlEventTouchUpInside];
    [linked_background addSubview:unlink_account];
    
    UIButton *link_bank = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [link_bank setFrame:CGRectMake(0, 125, 0, 0)];
    [link_bank setTitle:@" Link a new bank" forState:UIControlStateNormal];
    [link_bank addTarget:self action:@selector(attach_bank) forControlEvents:UIControlEventTouchUpInside];
    //[link_bank setGlyphNamed:@"plus-sign"];
    [link_bank setStyleClass:@"button_blue"];
    [link_bank setStyleId:@"link_new_account"];
    [ttt setFrame:CGRectMake(30, 15, 25, 25)];
    [ttt setImage:[UIImage imageGlyphNamed:@"plus-sign" height:40 color:[UIColor whiteColor]]];
    [link_bank addSubview:ttt];
    [link_bank setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:link_bank];
    
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

-(void)attach_bank
{
    // SelectBank *add = [SelectBank new];
    // [self.navigationController pushViewController:add animated:YES];
    
    knoxWeb *knox = [knoxWeb new];
    [self.navigationController pushViewController:knox animated:YES];
}

-(void)remove_attached_bank {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Remove Account" message:@"Are you sure you wish to unlink this bank account from Nooch?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av setTag:2];
    [av show];
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
    [WTGlyphFontSet setDefaultFontSetName: @"fontawesome"];
    UIImageView *ttt = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    [ttt setImage:[UIImage imageGlyphNamed:@"chevron-right" height:40 color:kNoochGrayLight]];
    
    UILabel *title = [UILabel new];
    [title setStyleClass:@"settings_table_label"];
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, 17, 12, 18)];
    arrow.image = ttt.image;
    [cell.contentView addSubview:arrow];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 26, 30)];
    [iv setImage:[UIImage imageGlyphNamed:@"user" height:30 color:kNoochBlue]];
    if(indexPath.row == 0){
        title.text = @"Profile Info";
    }else if(indexPath.row == 1){
        title.text = @"Security Settings";
        [iv setImage:[UIImage imageGlyphNamed:@"lock" height:30 color:kNoochBlue]];
        [iv setFrame:CGRectMake(10, 10, 26, 28)];
    }else if(indexPath.row == 2){
        title.text = @"Notification Settings" ;
        [iv setImage:[UIImage imageGlyphNamed:@"bell" height:30 color:kNoochBlue]];
        [iv setFrame:CGRectMake(10, 10, 26, 26)];
    }
    [cell.contentView addSubview:title];
    [cell.contentView addSubview:iv];
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
    isProfileOpenFromSideBar=NO;
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
    NSLog(@"%@",nav_ctrl.viewControllers);
    
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
                
                [blankView removeFromSuperview];
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
    if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            //proceed to unlink
        } else if (buttonIndex == 1) {
            //cancel
        }
        return;
    }
    
    if (buttonIndex == 1) {
        blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
        [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        UIActivityIndicatorView*actv=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2)-5, 40, 40)];
        [actv startAnimating];
        [blankView addSubview:actv];
        [self .view addSubview:blankView];
        [self.view bringSubviewToFront:blankView];
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
