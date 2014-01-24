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
#import "SelectCause.h"
#import "TransferPIN.h"
#import "ReEnterPin.h"
#import "ProfileInfo.h"
#define kButtonType     @"transaction_type"
#define kButtonTitle    @"button_title"
#define kButtonColor    @"button_background_color"


@interface Home ()
@property(nonatomic,strong) NSArray *transaction_types;
@property(nonatomic,strong) UIButton *balance;
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
    
     NSLog(@"%@",nav_ctrl.view);
    [ self.navigationItem setLeftBarButtonItem:Nil];
    nav_ctrl = self.navigationController;
     NSLog(@"%d",[nav_ctrl.viewControllers count]);
    user = [NSUserDefaults standardUserDefaults];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
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
    
    self.balance = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.balance setFrame:CGRectMake(0, 0, 60, 30)];
    // [self.balance setTitle:[NSString stringWithFormat:@"$%@",@"00.00"] forState:UIControlStateNormal];
    if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
        [self.balance setTitle:[NSString stringWithFormat:@"$%@",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
    }
    else
    {
        [self.balance setTitle:[NSString stringWithFormat:@"$%@",@"00.00"] forState:UIControlStateNormal];
    }
    [self.balance.titleLabel setFont:kNoochFontMed];
    [self.balance addTarget:self action:@selector(showFunds) forControlEvents:UIControlEventTouchUpInside];
    [self.balance setStyleId:@"navbar_balance"];
    [self.navigationItem setLeftBarButtonItem:nil];
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setFrame:CGRectMake(0, 0, 40, 40)];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setStyleId:@"navbar_hamburger"];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    UIButton *top_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [top_button setStyleClass:@"button_blue"];
    
    UIButton *mid_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *bot_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bot_button setStyleClass:@"button_green"];
    
    float height = [[UIScreen mainScreen] bounds].size.height;
    height -= 150; height /= 3;
    CGRect button_frame = CGRectMake(20.00, 20.00, 280, height);
    [top_button setFrame:button_frame];
    button_frame.origin.y += height+20; [mid_button setFrame:button_frame];
    button_frame.origin.y += height+20; [bot_button setFrame:button_frame];
    
    [top_button.titleLabel setFont:[UIFont fontWithName:@"BrandonGrotesque-Medium" size:18]];
    [mid_button.titleLabel setFont:[UIFont fontWithName:@"BrandonGrotesque-Medium" size:18]];
    [bot_button.titleLabel setFont:[UIFont fontWithName:@"BrandonGrotesque-Medium" size:18]];
    
    [top_button addTarget:self action:@selector(send_request) forControlEvents:UIControlEventTouchUpInside];
    [mid_button addTarget:self action:@selector(pay_in_person) forControlEvents:UIControlEventTouchUpInside];
    [bot_button addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    
    [top_button setTitle:[[self.transaction_types objectAtIndex:0] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    [mid_button setTitle:[[self.transaction_types objectAtIndex:1] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    [bot_button setTitle:[[self.transaction_types objectAtIndex:2] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    
    [self.view addSubview:top_button]; [self.view addSubview:mid_button]; [self.view addSubview:bot_button];
    /*if (![user objectForKey:@"member_id"]) {
        Register *reg = [Register new];
        [self.navigationController pushViewController:reg animated:NO];
        [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
    }*/
    
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
        NSLog(@"%@",loadInfo);
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"MemberId"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"UserName"] forKey:@"UserName"];
        [me birth];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [nav_ctrl performSelector:@selector(disable)];
        [user removeObjectForKey:@"Balance"];
        Register*reg=[Register new];
        [nav_ctrl pushViewController:reg animated:NO];
        return;
    }
    
      //if they have required immediately turned on or haven't selected the option yet, redirect them to PIN screen
    if (![[user objectForKey:@"requiredImmediately"] isEqualToString:@"YES"]) {
        
        ReEnterPin*pin=[ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
       
    }else if([[user objectForKey:@"requiredImmediately"] isEqualToString:@"YES"]){
        ReEnterPin*pin=[ReEnterPin new];
        [self presentViewController:pin animated:YES completion:nil];
      
    }
      }
-(void)updateLoader{
       if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
           [self.navigationItem setRightBarButtonItem:Nil];
           if ([[user objectForKey:@"Balance"] rangeOfString:@"."].location!=NSNotFound) {
               [self.balance setTitle:[NSString stringWithFormat:@"$%@",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
           }
           else
               [self.balance setTitle:[NSString stringWithFormat:@"$%@.00",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
           UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:self.balance];
           [self.navigationItem setRightBarButtonItem:funds];
             }
    else
    {
        [self.balance setTitle:[NSString stringWithFormat:@"$%@",@"00.00"] forState:UIControlStateNormal];    }
    
  
}
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"Nooch"];
    
    UIActivityIndicatorView*act=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [act setFrame:CGRectMake(14, 5, 20, 20)];
    [act startAnimating];
    
    UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:act];
    [self.navigationItem setRightBarButtonItem:funds];
 
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateLoader) userInfo:nil repeats:YES];
    

    if ([[user objectForKey:@"logged_in"] isKindOfClass:[NSNull class]]) {
        //push login
        return;
    }
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        serve *serveOBJ=[serve new ];
        
        [serveOBJ setTagName:@"sets"];
        [serveOBJ getSettings];
    }

    
}

-(void)showMenu
{
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
}
- (void)send_request
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[defaults valueForKey:@"IsPrimaryBankVerified"]);
#pragma mark-9jan
 /*  if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
       
       UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your are not a active user.Please click the link sent to your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
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
   
    //IsVerifiedPhone
    //[user setObject:[loginResult valueForKey:@"Status"] forKey:@"Status"]
   if ( ![[defaults valueForKey:@"IsPrimaryBankVerified"]isEqualToString:@"YES"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Bank Account before Proceeding." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        
        return;
    }
    */
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
- (void)donate
{
    isOpenLeftSideBar=NO;
    SelectCause *donate = [SelectCause new];
    [self.navigationController pushViewController:donate animated:YES];
}
# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
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
    [locationManager stopUpdatingLocation];
}
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"details"]) {
        NSLog(@"deets: %@",result);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
