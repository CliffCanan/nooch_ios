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
    [[NSUserDefaults standardUserDefaults] setObject:@"100.00" forKey:@"balance"];
    [self.balance setTitle:[NSString stringWithFormat:@"$%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"balance"]] forState:UIControlStateNormal];
    [self.balance.titleLabel setFont:kNoochFontMed];
    [self.balance addTarget:self action:@selector(showFunds) forControlEvents:UIControlEventTouchUpInside];
    [self.balance setStyleId:@"navbar_balance"];
    UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:self.balance];
    [self.navigationItem setRightBarButtonItem:funds];
    
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
    //if user has autologin set bring up their data, otherwise redirect to the tutorial/login/signup flow
    if ([core isAlive:[self autoLogin]]) {
        me = [core new];
        NSMutableDictionary *loadInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:[self autoLogin]];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"MemberId"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"UserName"] forKey:@"UserName"];
        [me birth];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        //[nav_ctrl performSelector:@selector(disable)];
        Register*reg=[Register new];
        [nav_ctrl pushViewController:reg animated:NO];
        return;
    }
    
    serve *details = [serve new];
    [details setTagName:@"details"];
    [details setDelegate:self];
    [details getDetails:[[me usr] objectForKey:@"MemberId"]];
    
    //if they have required immediately turned on or haven't selected the option yet, redirect them to PIN screen
    if (![[me usr] objectForKey:@"requiredImmediately"]) {
        // reqImm = YES;
        //Commented by Charanjit as the method has been depricated
        //        [self presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"pin"] animated:NO];
        
        //new addition by Charanjit
        
        //[self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"pin"] animated:YES completion:nil];
        
    }else if([[[me usr] objectForKey:@"requiredImmediately"] boolValue]){
        //reqImm = YES;
        //commented by Charanjit
        //        [self presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"pin"] animated:NO];
        //new addition which does the same work
        //[self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"pin"] animated:YES completion:nil];
    }
    
    //
}
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  //  [nav_ctrl performSelector:@selector(reenable)];

    //Register *reg = [[Register alloc] init];
    //[self.navigationController pushViewController:reg animated:YES];
    //return;
    me=[core new];
    NSLog(@"%@",me);

    if ([[user objectForKey:@"logged_in"] isKindOfClass:[NSNull class]]) {
        //push login
        return;
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

- (void)send_request
{
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
    SelectCause *donate = [SelectCause new];
    [self.navigationController pushViewController:donate animated:YES];
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
