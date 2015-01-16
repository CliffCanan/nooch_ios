//
//  SelectApt.m
//  Nooch
//
//  Created by Cliff Canan on 1/13/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "SelectApt.h"
#import "MyApartment.h"
#import "UIImageView+WebCache.h"
#import "Helpers.h"
#import "ECSlidingViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MBProgressHUD.h"

@interface SelectApt ()
@property(nonatomic,strong) UITableView * propertiesTable;
@property(nonatomic,strong) NSMutableArray * properties;
@property(nonatomic) BOOL location;
@property(nonatomic,strong) MBProgressHUD * hud;
@property(nonatomic,strong) UITextField * suggestApt;
@property(nonatomic,strong) UIImageView * noAptsImg;
@end

@implementation SelectApt

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

    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Select Property"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    [self.navigationItem setRightBarButtonItem:Nil];

    UIButton * helpGlyph = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [helpGlyph setStyleClass:@"navbar_rightside_icon"];
    [helpGlyph addTarget:self action:@selector(suggestPropertyPrompt) forControlEvents:UIControlEventTouchUpInside];
    [helpGlyph setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"] forState:UIControlStateNormal];
    [helpGlyph setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.24) forState:UIControlStateNormal];
    helpGlyph.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    UIBarButtonItem * help = [[UIBarButtonItem alloc] initWithCustomView:helpGlyph];
    [self.navigationItem setRightBarButtonItem:help];

    hasAptSet = 1;
    searching = false;

    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    search.searchBarStyle = UISearchBarStyleMinimal;
    search.placeholder=@"Search by Name or Location";
    [search setDelegate:self];
    [search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [search setImage:[UIImage imageNamed:@"clear_white"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    for (UIView *subView1 in search.subviews)
    {
        for (id subview2 in subView1.subviews)
        {
            if ([subview2 isKindOfClass:[UITextField class]])
            {
                //((UITextField *)subview2).textColor = [UIColor whiteColor];
                //[((UITextField *)subview2) setClearButtonMode:UITextFieldViewModeWhileEditing];
                break;
            }
        }
    }
    
    [self.view addSubview:search];
    
    self.propertiesTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, [[UIScreen mainScreen] bounds].size.height - 105)];
    [self.propertiesTable setDataSource:self];
    [self.propertiesTable setDelegate:self];
    [self.propertiesTable setSectionHeaderHeight:27];
    [self.propertiesTable setStyleId:@"select_apt"];
    //[self.propertiesTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.propertiesTable];
    [self.propertiesTable reloadData];
    
    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStylePlane];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = @"Finding Apartments";
    //[self.hud show:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [search setTintColor:kNoochBlue];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

-(void)backPressed:(id)sender
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];

    if (isFromMyApt == YES)
    {
        isFromMyApt = NO;
    }
}

-(void)cancelBtnPressed
{
    Home * home = [[Home alloc] init];
    [self.navigationController pushViewController:home animated:YES];
}

#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [self.propertiesTable reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [search setTintColor:kNoochBlue]; // For the 'Cancel' text

    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar setKeyboardType:UIKeyboardTypeAlphabet];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length] == 0)
    {
        searching = NO;
        return;
    }
    else if ([searchText length] > 0)
    {
        searching = YES;

        if ([self.view.subviews containsObject:self.noAptsImg])
        {
            [self.noAptsImg removeFromSuperview];
        }

        [self.propertiesTable setHidden:NO];

        searchString = searchText;
        [self searchTableView];

        [self.propertiesTable reloadData];
    }
    else
    {
        searchString = [searchBar.text substringToIndex:[searchBar.text length] - 1];
        [self.propertiesTable reloadData];
    }
}

- (void) searchTableView
{
    
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)loadDelay
{
    NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];
    [arrNav removeLastObject];
    [nav_ctrl setViewControllers:arrNav animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    [self.propertiesTable setNeedsDisplay];

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];

        [timer invalidate];

        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];

        [[assist shared] setPOP:YES];
        [self performSelector:@selector(loadDelay) withObject:Nil afterDelay:1.0];
    }
    else if ([tagName isEqualToString:@"saveSuggestedProp"])
    {
        NSError * error;
        NSMutableDictionary * dictResponse = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];
        
        if ([[dictResponse valueForKey:@"Result"] isEqualToString:@"Property suggestion saved successfully."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Thank You!"
                                                         message:@"We will reach out to the owners of that property and add them to the platform ASAP."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Nooch"
                                                         message:[dictResponse valueForKey:@"Result"]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{


}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"hasAptSet is: %d",hasAptSet);
    if (hasAptSet)
    {
        return 2;
    }

    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 27)];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake (10, 0, 200, 27)];
    title.textColor = kNoochGrayDark;
    title.font = [UIFont fontWithName:@"Roboto-regular" size:14];
    
    if (section == 0)
    {
        if (searching)
            title.text = @"Search Results";
        else if (hasAptSet)
            title.text = @"My Apartment";
        else
            title.text = @"Properties On Nooch";
    }
    else if (section == 1 && hasAptSet)
    {
        title.text = @"Properties On Nooch";
    }

    [headerView addSubview:title];
    [headerView setBackgroundColor:[Helpers hexColor:@"e3e4e5"]];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching)
    {
        return [arrSearchedRecords count];
    }
    else if (hasAptSet)
    {
        if (section == 0)
        {
            return 1;
        }
        else
        {
            return [self.properties count];
        }
    }
    else
    {
        return [self.properties count];
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setStyleClass:@"select_apt_name"];
        cell.indentationLevel = 1;
    }
    
    for (UIView *subview in cell.contentView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    cell.indentationWidth = 68;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UIImageView * pic = [[UIImageView alloc] initWithFrame:CGRectMake(14, 8, 58, 58)];
    pic.clipsToBounds = YES;
    pic.hidden = NO;
    pic.layer.cornerRadius = 14;
    [pic sd_setImageWithURL:[NSURL URLWithString:@"https://www.nooch.com/staging/web-app/images/apt1.jpg"]
           placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
    [pic setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:pic];

    [cell.textLabel setStyleClass:@"select_apt_name"];
    [cell.textLabel setText:@"Bellvue Heights Apts"];

    [cell.detailTextLabel setText:@"17 E. Roosevelt Blvd., Philadelphia, PA 19123"];
    [cell.detailTextLabel setNumberOfLines:0];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (hasAptSet && indexPath.row == 0)
    {
        isFromPropertySearch = YES;
        MyApartment * myApt = [MyApartment new];
        [self.navigationController pushViewController:myApt animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)suggestPropertyPrompt
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];
    
    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    mainView.frame = CGRectMake(9, -500, 302, 292);
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;
    
    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }];
    
    [UIView animateWithDuration:0.38
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         mainView.frame = CGRectMake(9, 75, 302, 292);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.23
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500)
                                              {
                                                  mainView.frame = CGRectMake(9, 45, 302, 292);
                                              }
                                              else
                                              {
                                                  mainView.frame = CGRectMake(9, 46, 302, 292);
                                              }
                                          }];
                     }];
    
    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;
    
    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview: space_container];
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Request A New Property"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];
    
    UILabel * glyph_add = [UILabel new];
    [glyph_add setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyph_add setFrame:CGRectMake(14, 10, 22, 26)];
    [glyph_add setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"]];
    [glyph_add setTextColor:kNoochBlue];
    [head_container addSubview:glyph_add];
    
    UILabel * bodyHeader = [[UILabel alloc]initWithFrame:CGRectMake(11, head_container.bounds.size.height + 8, mainView.bounds.size.width - 22, 60)];
    [bodyHeader setBackgroundColor:[UIColor clearColor]];
    [bodyHeader setText:@"If your property is not listed, we can let the owners know you would like to use Nooch to pay your rent."];
    [bodyHeader setFont:[UIFont fontWithName:@"Roboto-light" size:16]];
    [bodyHeader setNumberOfLines:0];
    bodyHeader.textColor = [Helpers hexColor:@"313233"];
    bodyHeader.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:bodyHeader];
    
    UILabel * bodyText = [[UILabel alloc]initWithFrame:CGRectMake(12, head_container.bounds.size.height + 76, mainView.bounds.size.width - 24, 46)];
    [bodyText setBackgroundColor:[UIColor clearColor]];
    [bodyText setText:@"What is the name of your building, complex, or property?"];
    [bodyText setFont:[UIFont fontWithName:@"Roboto-regular" size:16]];
    [bodyText setNumberOfLines: 0];
    bodyText.textColor = [Helpers hexColor:@"313233"];
    bodyText.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:bodyText];

    self.suggestApt = [[UITextField alloc] initWithFrame:CGRectMake(20, 176, 262, 40)];
    [self.suggestApt setBackgroundColor:[UIColor clearColor]];
    [self.suggestApt setPlaceholder:@"Ex: Riverside Apartments, West Philly"];
    self.suggestApt.inputAccessoryView = [[UIView alloc] init];
    [self.suggestApt setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [self.suggestApt setAutocorrectionType:UITextAutocorrectionTypeDefault];
    [self.suggestApt setKeyboardType:UIKeyboardTypeAlphabet];
    [self.suggestApt setReturnKeyType:UIReturnKeySend];
    [self.suggestApt setTextAlignment:NSTextAlignmentCenter];
    [self.suggestApt becomeFirstResponder];
    [self.suggestApt setDelegate:self];
    [self.suggestApt setStyleId:@"suggestApt_textField"];
    [mainView addSubview:self.suggestApt];

    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnLink.frame = CGRectMake(20, 236, 260, 45);
    [btnLink setTitle:@"Send" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_add.frame = CGRectMake(18, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height - 54, 280, 44);
    }

    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(5, 5, 38, 39);
    
    UIView * btnClose_shell = [[UIView alloc] initWithFrame:CGRectMake(mainView.frame.size.width - 38, head_container.frame.origin.y - 21, 48, 46)];
    [btnClose_shell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close_lightBox)]];
    [btnClose_shell addSubview:btnClose];
    
    [mainView addSubview:btnClose_shell];
    [mainView addSubview:btnLink];
    [overlay addSubview:mainView];
    
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"VersionUpdateNoticeDisplayed"];
}

-(void)saveSuggestedProperty
{
    serve *  serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"saveSuggestedProp";
    //[serveOBJ saveSuggestedProp:[[NSUserDefaults standardUserDefaults ]valueForKey:@"MemberId"]];
}

-(void)close_lightBox
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500) {
                             mainView.frame = CGRectMake(9, 70, 302, 292);
                         }
                         else {
                             mainView.frame = CGRectMake(9, 70, 302, 292);
                         }
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.38
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              mainView.frame = CGRectMake(9, -500, 302, 292);
                                              overlay.alpha = 0.1;
                                          }
                                          completion:^(BOOL finished) {
                                              [overlay removeFromSuperview];

                                              [self saveSuggestedProperty];
                                          }
                          ];
                     }
     ];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Error"
                          message:@"Looks like there was some trouble connecting to the right place.  Please try again!"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}


@end