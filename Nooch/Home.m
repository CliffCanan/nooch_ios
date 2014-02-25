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
#import "NewBank.h"
#import "serve.h"
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
    
    self.balance = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.balance setFrame:CGRectMake(0, 0, 80, 30)];
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
    
    [top_button addTarget:self action:@selector(send_request) forControlEvents:UIControlEventTouchUpInside];
    [mid_button addTarget:self action:@selector(pay_in_person) forControlEvents:UIControlEventTouchUpInside];
    [bot_button addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    
    [top_button setTitle:[[self.transaction_types objectAtIndex:0] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    [mid_button setTitle:[[self.transaction_types objectAtIndex:1] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    [bot_button setTitle:[[self.transaction_types objectAtIndex:2] objectForKey:kButtonTitle] forState:UIControlStateNormal];
    
    [self.view addSubview:top_button]; [self.view addSubview:bot_button];
    
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
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"MemberId"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"UserName"] forKey:@"UserName"];
        [me birth];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        //[nav_ctrl performSelector:@selector(disable)];
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
        UIActivityIndicatorView*actv=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2)-5, 40, 40)];
        [actv startAnimating];
        [blankView addSubview:actv];
        [self .view addSubview:blankView];
        [self.view bringSubviewToFront:blankView];
        
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
            
            NewBank *add_bank = [NewBank new];
            [nav_ctrl pushViewController:add_bank animated:NO];
            [self.slidingViewController resetTopView];
        }
    }
}
- (void)send_request
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"bank verified? %d",[[assist shared]isBankVerified]);
#pragma mark-9jan
    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
        
    }

    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
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
     
    
    if ( ![[[NSUserDefaults standardUserDefaults]
            objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can make any transfer you must attach a bank account." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
        [set setTag:201];
        [set show];
        return;
    }
    
    
    if (![[assist shared]isBankVerified]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Bank Account before Proceeding." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        
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
- (void)donate
{
    isOpenLeftSideBar=NO;
    SelectCause *donate = [SelectCause new];
    [self.navigationController pushViewController:donate animated:YES];
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
    

     if ([tagName isEqualToString:@"banks"]) {
         
         NSError *error = nil;
         //bank Data
         NSMutableArray *bankResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
         [blankView removeFromSuperview];
         
         //Get Server Date info
          NSString *urlString = [NSString stringWithFormat:@"%@"@"/%@", @"https://192.203.102.254/NoochService/NoochService.svc", @"GetServerCurrentTime"];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
         NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@",urlString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                  NSHTTPURLResponse* urlResponse = nil;
        
         NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
       
        if (nil == urlResponse ) {
            if (error)
            {
                ServerDate=[NSDate date];
                
            }
        }else{
                if([newData length] && error == nil ){
                    
               NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
                 NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    NSLog(@"%@",[jsonObject valueForKey:@"Result"]);
                   ServerDate=[self dateFromString:[jsonObject valueForKey:@"Result"] ];
                    NSLog(@"%@",ServerDate);
                }
        }
     // NSLog(@"%@",[[[[bankResult objectAtIndex:0] valueForKey:@"ExpirationDate"] componentsSeparatedByString:@" "] objectAtIndex:0]);
     if ([bankResult count]>0) {
     if ([[[bankResult objectAtIndex:0] valueForKey:@"IsPrimary"] intValue]&& [[[bankResult objectAtIndex:0] valueForKey:@"IsVerified"] intValue]) {
     
     
     }
     else
     {
     NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
     NSMutableDictionary* dictUsers2=[[NSMutableDictionary alloc]init];
     if (![[defaults objectForKey:@"NotifPlaced2"]isKindOfClass:[NSNull class]]&& [defaults objectForKey:@"NotifPlaced2"]!=NULL) {
     dictUsers2=[[defaults objectForKey:@"NotifPlaced2"] mutableCopy];
     
     }
     NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
     NSString*strNotifPlaced;
     for (id key in dictUsers2) {
     if ([key isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]]) {
     strNotifPlaced=[dictUsers2 valueForKey:key];
     break;
     }
     }
     NSLog(@"%@",strNotifPlaced);
     if ([strNotifPlaced isEqualToString:@"1"]) {
     NSLog(@"%@",bankResult);
    // NSLog(@"%@",[[[[bankResult objectAtIndex:0] valueForKey:@"ExpirationDate"] componentsSeparatedByString:@" "] objectAtIndex:0]);
    NSString*datestr=[[bankResult objectAtIndex:0] valueForKey:@"ExpirationDate"];
     
     
     NSDate *addeddate = [self dateFromString:datestr];
     
     NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
     NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
     fromDate:addeddate
     toDate:ServerDate
     options:0];
     
     NSLog(@"%ld", (long)[components day]);
     if ([components day]>21) {
     
//     for (UILocalNotification *localnoti in [[UIApplication sharedApplication] scheduledLocalNotifications] ) {
//     if ([[localnoti.userInfo valueForKey:@"notificationId"]isEqualToString:@"Bank1"]) {
//     [[UIApplication sharedApplication]cancelLocalNotification:localnoti];
//     }
//     if ([[localnoti.userInfo valueForKey:@"notificationId"]isEqualToString:@"Bank2"]) {
//     [[UIApplication sharedApplication]cancelLocalNotification:localnoti];
//     }
//     if ([[localnoti.userInfo valueForKey:@"notificationId"]isEqualToString:@"Bank3"]) {
//     [[UIApplication sharedApplication]cancelLocalNotification:localnoti];
//     }
//     
//     }
//     NSMutableDictionary* dictUsers2=[[NSMutableDictionary alloc]init];
//     if (![[defaults objectForKey:@"NotifPlaced2"]isKindOfClass:[NSNull class]]&& [defaults objectForKey:@"NotifPlaced2"]!=NULL) {
//     dictUsers2=[[defaults objectForKey:@"NotifPlaced2"] mutableCopy];
//     
//     }
//     NSLog(@"%@",dictUsers2);
//     for (id key in dictUsers2) {
//     if ([key isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]]) {
//     [dictUsers2 setValue:@"0" forKey:key];
//     
//     break;
//     }
//     }
//     [defaults setValue:dictUsers2 forKey:@"NotifPlaced2"];
//     [defaults synchronize];
//     
     
     serve *bank = [serve new];
     bank.tagName = @"bDelete";
     bank.Delegate = self;
     [bank deleteBank:[[bankResult objectAtIndex:0] valueForKey:@"BankAccountId"]];
     }
     
     
     
     }
     }
     }

     }
     
    
   }
#pragma mark- Date From String
- (NSDate*) dateFromString:(NSString*)aStr
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    //[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss a"];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"M/dd/yyyy hh:mm:ss a";
    //[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    // [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-5]];
    
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
