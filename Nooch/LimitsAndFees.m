//  LimitsAndFees.m
//  Nooch
//
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "LimitsAndFees.h"
#import "Home.h"
#import "ECSlidingViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "NSString+FontAwesome.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

@interface LimitsAndFees ()<MBProgressHUDDelegate>
@property(nonatomic,strong) MBProgressHUD *hud;
@end
@implementation LimitsAndFees
@synthesize LimitsAndFeesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Limits & Fees Screen";
    self.artisanNameTag = @"Limist and Fees Screen";
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setTitle:NSLocalizedString(@"LimitsFees_ScrnTitle", @"LimitsFees 'Limits & Fees' Screen Title")];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    LimitsAndFeesView.backgroundColor = [UIColor clearColor];
    LimitsAndFeesView.opaque = 0;

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = NSLocalizedString(@"LimitsFees_HUDlbl", @"LimitsFees 'Loading & Other Computer Activities' HUD Label");
    [self.hud show:YES];

    NSURL * webURL = [NSURL URLWithString:@"https://www.nooch.com/2248-112188/"];
    LimitsAndFeesView = [[UIWebView alloc]initWithFrame:self.view.frame];
    LimitsAndFeesView.delegate = self;
    
    [LimitsAndFeesView loadRequest:[NSURLRequest requestWithURL:webURL]];
    LimitsAndFeesView.scalesPageToFit = YES;
    
    [LimitsAndFeesView.scrollView setScrollEnabled:NO];

    [LimitsAndFeesView setDelegate:self];
    [LimitsAndFeesView setMultipleTouchEnabled:YES];
    [self.view addSubview:LimitsAndFeesView];

    [ARTrackingManager trackEvent:@"LimitsFees_viewDidLoad"];
}

-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.hud hide:YES];
    return ;
}

-(void)webViewDidFinishLoad:(UIWebView *) portal
{
    [self.hud hide:YES];
    [self.navigationItem setRightBarButtonItem:nil];
}

- (void)viewDidUnload
{
    [self.hud hide:YES];
    self.hud = nil;
    [super viewDidUnload];
}
-(void)Error:(NSError *)Error{
    [self.hud hide:YES];
    
    /*UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];*/
    
}
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end