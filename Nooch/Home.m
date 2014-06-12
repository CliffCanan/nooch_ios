//
//  Home.m
//  Nooch
//
//  Created by crks on 9/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "Home.h"
#import "Register.h"
#import "InitSliding.h"
#import "ECSlidingViewController.h"
#import "TransferPIN.h"
#import "ReEnterPin.h"
#import "ProfileInfo.h"
#import "serve.h"
#import "iCarousel.h"
#import <QuartzCore/QuartzCore.h>
#define kButtonType     @"transaction_type"
#define kButtonTitle    @"button_title"
#define kButtonColor    @"button_background_color"

NSMutableURLRequest *request;
@interface Home ()
@property(nonatomic,strong) NSArray *transaction_types;
@property(nonatomic,strong) UIButton *balance;
@property(nonatomic,strong) UITableView *news_feed;
@property(nonatomic,strong) FAImageView *close;
@property(nonatomic,strong) UIView *popup;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIView *suspended;
@property(nonatomic,strong) UIView *profile_incomplete;
@property(nonatomic,strong) UIView *phone_unverified;
@property(nonatomic,strong) iCarousel *carousel;
@property(nonatomic,strong) NSMutableDictionary *favorites;
@end

@implementation Home

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
    
    nav_ctrl = self.navigationController;
    [ self.navigationItem setLeftBarButtonItem:Nil];
    
    user = [NSUserDefaults standardUserDefaults];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[assist shared]isPOP];
    self.transaction_types = @[
                               @{kButtonType: @"send_request",
                                 kButtonTitle: @"Send or Request",
                                 kButtonColor: [UIColor clearColor]},
                               
                               @{kButtonType: @"pay_in_person",
                                 kButtonTitle: @"Pay in Person",
                                 kButtonColor: [UIColor clearColor]},
                               
                               @{kButtonType: @"donate",
                                 kButtonTitle: @"Donate to a Cause",
                                 kButtonColor: [UIColor clearColor]}
                               ];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    self.popup = [UIView new];
    [self.popup setStyleId:@"news_popup"];
    
    self.news_feed = [UITableView new];
    [self.news_feed setDelegate:self];
    [self.news_feed setDataSource:self];
    [self.news_feed setStyleId:@"news_feed"];
    self.news_feed.clipsToBounds = YES;
    self.news_feed.layer.masksToBounds = YES;
    [self.popup addSubview:self.news_feed];
    
    self.close = [[FAImageView alloc] initWithFrame:CGRectMake(262.f, 35.f, 30.f, 40.f)];
    self.close.image = nil;
    //[self.close setBackgroundColor:[UIColor whiteColor]];
    [self.close setDefaultIconIdentifier:@"fa-caret-up"];
    
    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(hide_news)];
    [self.view addGestureRecognizer:tap];
    
    UIButton *top_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [top_button setStyleClass:@"button_blue"];
    
    UIButton *mid_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *bot_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bot_button setStyleClass:@"button_green"];
    
    float height = [[UIScreen mainScreen] bounds].size.height;
    height -= 150; height /= 3;
    CGRect button_frame = CGRectMake(20.00, 270.00, 280, height);
    [top_button setFrame:button_frame];
    button_frame.origin.y += height+20; [mid_button setFrame:button_frame];
    button_frame.origin.y = 350; [bot_button setFrame:button_frame];
    
    [top_button addTarget:self action:@selector(send_request) forControlEvents:UIControlEventTouchUpInside];
    [mid_button addTarget:self action:@selector(pay_in_person) forControlEvents:UIControlEventTouchUpInside];
    //[bot_button addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    
    [top_button setTitle:[[self.transaction_types objectAtIndex:0] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    [mid_button setTitle:[[self.transaction_types objectAtIndex:1] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    [bot_button setTitle:[[self.transaction_types objectAtIndex:2] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    
    [self.view addSubview:top_button];
    
    //29/12
    NSMutableDictionary *loadInfo;
    //if user has autologin set bring up their data, otherwise redirect to the tutorial/login/signup flow
    if ([core isAlive:[self autoLogin]]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationPush"]intValue]==1) {
            ProfileInfo *prof = [ProfileInfo new];
            [nav_ctrl pushViewController:prof animated:YES];
            [self.slidingViewController resetTopView];
        }
        me = [core new];
        [user removeObjectForKey:@"Balance"];
        loadInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:[self autoLogin]];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"MemberId"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"UserName"] forKey:@"UserName"];
        [me birth];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [user removeObjectForKey:@"Balance"];
        Register*reg=[Register new];
        [nav_ctrl pushViewController:reg animated:NO];
        return;
    }
    
    //if they have required immediately turned on or haven't selected the option yet, redirect them to PIN screen
    if (![user objectForKey:@"requiredImmediately"])
    {
        ReEnterPin*pin=[ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
    }
    else if([[user objectForKey:@"requiredImmediately"] boolValue])
    {
        ReEnterPin*pin=[ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
    }
    
    if ([[user objectForKey:@"Status"] isEqualToString:@"Suspended"]) {
        self.suspended = [UIView new];
        [self.suspended setStyleId:@"suspended_home"];
        UILabel *sus_header = [UILabel new];
        [sus_header setStyleClass:@"banner_header"];
        [sus_header setText:@"Account Suspended"];
        [self.suspended addSubview:sus_header];
        UILabel *sus_info = [UILabel new];
        [sus_info setStyleClass:@"banner_info"];
        [sus_info setNumberOfLines:0];
        [sus_info setText:@"Your account will have limited functionality until you are unsuspended. Contact support for further inquiries."];
        [self.suspended addSubview:sus_info];
        UILabel *sus_exclaim = [UILabel new];
        [sus_exclaim setStyleClass:@"banner_alert_glyph"];
        [sus_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
        [self.suspended addSubview:sus_exclaim];
        
        UIButton *contact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [contact setStyleClass:@"go_now"];
        [contact setTitle:@"Contact" forState:UIControlStateNormal];
        [contact addTarget:self action:@selector(contact_support) forControlEvents:UIControlEventTouchUpInside];
        [self.suspended addSubview:contact];
        
        UIButton *dis = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [dis setStyleClass:@"dismiss_banner"];
        [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
        [dis addTarget:self action:@selector(dismiss_suspended_alert) forControlEvents:UIControlEventTouchUpInside];
        [self.suspended addSubview:dis];
        
        [self.view addSubview:self.suspended];
    }
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"]) {
        self.profile_incomplete = [UIView new];
        [self.profile_incomplete setStyleId:@"email_unverified"];
        
        UILabel *em = [UILabel new];
        [em setStyleClass:@"banner_header"];
        [em setText:@"Profile Not Validated"];
        [self.profile_incomplete addSubview:em];
        
        UILabel *em_exclaim = [UILabel new];
        [em_exclaim setStyleClass:@"banner_alert_glyph"];
        [em_exclaim setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-exclamation-triangle"]];
        [self.profile_incomplete addSubview:em_exclaim];
        
        UILabel *em_info = [UILabel new];
        [em_info setStyleClass:@"banner_info"];
        [em_info setNumberOfLines:0];
        [em_info setText:@"Please complete your profile to unlock all features."];
        [self.profile_incomplete addSubview:em_info];
        
        UIButton *go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [go setStyleClass:@"go_now"];
        [go setTitle:@"Go Now" forState:UIControlStateNormal];
        [go addTarget:self action:@selector(go_profile) forControlEvents:UIControlEventTouchUpInside];
        [self.profile_incomplete addSubview:go];
        
        UIButton *dis = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [dis setStyleClass:@"dismiss_banner"];
        [dis setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
        [dis addTarget:self action:@selector(dismiss_profile_unvalidated) forControlEvents:UIControlEventTouchUpInside];
        [self.profile_incomplete addSubview:dis];
        
        [self.view addSubview:self.profile_incomplete];
    }
    
    [top_button setStyleId:@"test"];
    
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 45, 320, 30)];
    _carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _carousel.type = iCarouselTypeCoverFlow2;
    [_carousel setNeedsLayout];
    _carousel.delegate = self;
    _carousel.dataSource = self;
    
    serve *fb = [serve new];
    [fb setDelegate:self];
    [fb setTagName:@"fb"];
    if ([user objectForKey:@"facebook_id"]) {
        [fb storeFB:[user objectForKey:@"facebook_id"]];
    }
}

-(void)dismiss_suspended_alert {
    [self.suspended removeFromSuperview];
}

-(void)contact_support
{
    if (![MFMailComposeViewController canSendMail]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor=[UIColor whiteColor];
    
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

-(void)dismiss_profile_unvalidated {
    [self.profile_incomplete removeFromSuperview];
}

-(void)go_profile
{
    ProfileInfo *info = [ProfileInfo new];
    [self.navigationController pushViewController:info animated:YES];
}

-(void)updateLoader{
    self.balance = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.balance.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:24]];
    [self.balance setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-flag"] forState:UIControlStateNormal];
    [self.balance addTarget:self action:@selector(show_news) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:self.balance];
    [self.navigationItem setRightBarButtonItem:funds];
}
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![[assist shared]isPOP]) {
        self.slidingViewController.panGesture.enabled=YES;
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
        
        //location
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
        
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Nooch"];

      if (![[assist shared]isPOP]) {
          if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
              [self.navigationItem setRightBarButtonItem:Nil];
              UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:self.balance];
              [self.navigationItem setRightBarButtonItem:funds];
          }
          else
          {
              UIActivityIndicatorView*act=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
              [act setFrame:CGRectMake(14, 5, 20, 20)];
              [act startAnimating];
              
              UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:act];
              [self.navigationItem setRightBarButtonItem:funds];
          }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        if (timerHome==nil) {
             timerHome=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLoader) userInfo:nil repeats:YES];
        }
    
    if ([[user objectForKey:@"logged_in"] isKindOfClass:[NSNull class]]) {
        //push login
        return;
    }
    if (![self.view.subviews containsObject:blankView] && [[assist shared]needsReload]) {
        blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
        [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        
        self.hud.delegate = self;
        self.hud.labelText = @"Loading your Nooch account";
        [self.hud showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
            serve *serveOBJ=[serve new ];
            [serveOBJ setTagName:@"sets"];
            [serveOBJ getSettings];
        }
        if ([[assist shared]needsReload]) {
            [[assist shared]setneedsReload:NO];
            serve *banks = [serve new];
            banks.Delegate = self;
            banks.tagName = @"banks";
            [banks getBanks];
        }
    }
    else
    {
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    
    if ([[user valueForKey:@"Status"]isEqualToString:@"Active"] && [[user objectForKey:@"Status"] isEqualToString:@"Suspended"]) {
        //do carousel
        
        
        
        //launch favorites call
    }
    
    [self.view addSubview:_carousel];
    [_carousel reloadData];
    
}

#pragma mark - iCarousel methods

-(void)scrollCarouselToIndex:(NSNumber *)index
{
    [_carousel scrollToItemAtIndex:index.intValue animated:YES];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    //return [self.favorites count];
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
		view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 100)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 70, 70)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.borderColor = kNoochBlue.CGColor;
        imageView.layer.borderWidth = 1;
        imageView.layer.cornerRadius = 35;
        [imageView setImage:[UIImage imageNamed:@"Preston.png"]];
        [imageView setClipsToBounds:YES];
        [view addSubview:imageView];
        
    }
    else
    {
        imageView = (UIImageView *)[view viewWithTag:1];
    }
    
    //set image
    
    return view;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if(carousel.scrolling == NO)
    {
        [self carouselDidEndScrollingAnimation:carousel];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return NO;
        }
        case iCarouselOptionArc:
        {
            return 360; //arc
        }
        case iCarouselOptionRadius:
        {
            return 160;
        }
        case iCarouselOptionSpacing:
        {
            return value * 1;
        }
        default:
        {
            return value;
        }
    }
}

- (void)myTask {
	// This just increases the progress indicator in a loop
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		self.hud.progress = progress;
		usleep(50000);
	}
}

#pragma mark - news feed
-(void)show_news
{
    [self.balance removeTarget:self action:@selector(show_news) forControlEvents:UIControlEventTouchUpInside];
    [self.balance addTarget:self action:@selector(hide_news) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.view addSubview:self.popup];
    [self.navigationController.view addSubview:self.close];
    
    [self.news_feed reloadData];
}

-(void)hide_news
{
    [self.balance removeTarget:self action:@selector(hide_news) forControlEvents:UIControlEventTouchUpInside];
    [self.balance addTarget:self action:@selector(show_news) forControlEvents:UIControlEventTouchUpInside];
    
    [self.popup removeFromSuperview];
    [self.close removeFromSuperview];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    // Configure the cell...
    
    UILabel *test = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 150, 30)];
    [test setFont:[UIFont fontWithName:@"Roboto-Regular" size:12]];
    [test setBackgroundColor:[UIColor clearColor]];
    [test setNumberOfLines:0];
    [test setText:@"Paid you $1bil with the force, Yoda did"];
    [cell.contentView addSubview:test];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(70, 45, 150, 20)];
    [time setFont:[UIFont fontWithName:@"Roboto-Light" size:10]];
    [time setText:@"2 days ago"];
    [time setTextColor:kNoochGrayLight];
    [cell.contentView addSubview:time];
    
    
    return cell;
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showMenu
{
    [[assist shared]setneedsReload:NO];
    [self.slidingViewController anchorTopViewTo:ECRight];
}
-(void)showFunds
{
    
    [self.slidingViewController anchorTopViewTo:ECLeft];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag==147 || alertView.tag==148) && buttonIndex==1) {
        ProfileInfo *prof = [ProfileInfo new];
        [nav_ctrl pushViewController:prof animated:YES];
        [self.slidingViewController resetTopView];
    }
    
    else if (alertView.tag == 201){
        if (buttonIndex == 1) {
            
        }
    }
    else if (alertView.tag == 50 && buttonIndex == 1)
    {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)send_request
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"bank verified? %d",[[assist shared]isBankVerified]);
#pragma mark-9jan
    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
        [alert setTag:50];
        [alert show];
        return;
        
    }
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You are not a active user.Please click the link sent to your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Profile before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }
    
    if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Phone Number before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:148];
        [alert show];
        return;
    }
    
    
    if ( ![[[NSUserDefaults standardUserDefaults]
            objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can make any transfer you must attach a bank account." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
        [set setTag:201];
        [set show];
        return;
    }
    
    
    if (NSClassFromString(@"SelectRecipient")) {
        
        Class aClass = NSClassFromString(@"SelectRecipient");
        id instance = [[aClass alloc] init];
        
        if ([instance isKindOfClass:[UIViewController class]]) {
            
            //[(UIViewController *)instance setTitle:@"Select Recipient"];
            [self.navigationController pushViewController:(UIViewController *)instance
                                                 animated:YES];
            //[self.navigationItem setTitle:@""];
        }
    }
}
- (void)pay_in_person
{
    
}
# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    [[assist shared]setlocationAllowed:NO];
    
    NSLog(@"Error : %@",error);
    if ([error code] == kCLErrorDenied){
        NSLog(@"Error : %@",error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [manager stopUpdatingLocation];
    
    CLLocationCoordinate2D loc = [newLocation coordinate];
    lat = [[[NSString alloc] initWithFormat:@"%f",loc.latitude] floatValue];
    lon = [[[NSString alloc] initWithFormat:@"%f",loc.longitude] floatValue];
    [[assist shared]setlocationAllowed:YES];
    serve*serveOBJ=[serve new];
    [serveOBJ UpDateLatLongOfUser:[[NSString alloc] initWithFormat:@"%f",loc.latitude] lng:[[NSString alloc] initWithFormat:@"%f",loc.longitude]];
    [locationManager stopUpdatingLocation];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"fb"]) {
        NSError *error;
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"fb storing %@",temp);
    }
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [Alert show];
        
        
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        [timer invalidate];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        
        [nav_ctrl performSelector:@selector(reset)];
        //[self.navigationController popViewControllerAnimated:YES];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    if ([tagName isEqualToString:@"bDelete"]) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your Bank Account was not verified for 21 days.\nNooch has deleted your bank Account." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
    }

     else if ([tagName isEqualToString:@"banks"]) {
         
         NSError *error = nil;
         //bank Data
         NSMutableArray *bankResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
         [blankView removeFromSuperview];
         
         //Get Server Date info
          NSString *urlString = [NSString stringWithFormat:@"%@"@"/%@", @"https://192.203.102.254/NoochService/NoochService.svc", @"GetServerCurrentTime"];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@",urlString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                  NSHTTPURLResponse* urlResponse = nil;
        
         NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
       
        if (nil == urlResponse ) {
            if (error)
            {
                ServerDate=[NSDate date];
                
            }
        }else{
            
                    
               NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
                 NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                   ServerDate=[self dateFromString:[jsonObject valueForKey:@"Result"] ];
            
        }
     
     if ([bankResult count]>0) {
    
     if ([[[bankResult objectAtIndex:0] valueForKey:@"IsPrimary"] intValue]&& [[[bankResult objectAtIndex:0] valueForKey:@"IsVerified"] intValue]) {
     
     
     }
     else
     {
         if ([bankResult count]==2) {
             [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"AddBank"];
         }
         else
         {
             [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"AddBank"];
         }
         for (int i=0; i<[bankResult count]; i++) {
             NSString*datestr=[[bankResult objectAtIndex:i] valueForKey:@"ExpirationDate"];
             NSLog(@"%@",datestr);
             
             NSDate *addeddate = [self dateFromString:datestr];
             
             NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
             NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                 fromDate:addeddate
                                                                   toDate:ServerDate
                                                                  options:0];
             
             NSLog(@"%ld", (long)[components day]);
             if ([components day]>21) {
                 
                 
                 serve *bank = [serve new];
                 bank.tagName = @"bDelete";
                 bank.Delegate = self;
                 [bank deleteBank:[[bankResult objectAtIndex:i] valueForKey:@"BankAccountId"]];
             }
         }
   
     }}
     
     }
 
}

#pragma mark- Date From String
- (NSDate*) dateFromString:(NSString*)aStr
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
   
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    
    
    NSLog(@"%@", aStr);
    NSDate   *aDate = [dateFormatter dateFromString:aStr];
    NSLog(@"%@", aDate);
    return aDate;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
