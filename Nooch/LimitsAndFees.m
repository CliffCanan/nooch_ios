//  LimitsAndFees.m
//  Nooch
//
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "LimitsAndFees.h"
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
    self.trackedViewName = @"Limit & Fees Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setTitle:@"Limits and Fees"];
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
    self.hud.labelText = @"Loading & Other Computer Activities";
    [self.hud show:YES];
    [spinner1 startAnimating];

    NSURL * webURL = [NSURL URLWithString:@"https://www.nooch.com/2248-112188/"];
    LimitsAndFeesView = [[UIWebView alloc]initWithFrame:self.view.frame];
    LimitsAndFeesView.delegate = self;
    
    [LimitsAndFeesView loadRequest:[NSURLRequest requestWithURL:webURL]];
    LimitsAndFeesView.scalesPageToFit = YES;
    
    LimitsAndFeesView.scrollView.hidden = NO;
    [LimitsAndFeesView setDelegate:self];
    [LimitsAndFeesView setMultipleTouchEnabled:YES];
    [self.view addSubview:LimitsAndFeesView];
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