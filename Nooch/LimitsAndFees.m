//  LimitsAndFees.m
//  Nooch
//
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "LimitsAndFees.h"
#import "ECSlidingViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "NSString+FontAwesome.h"
@interface LimitsAndFees ()

@end
@implementation LimitsAndFees
@synthesize LimitsAndFeesView,spinner;
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
    [self.navigationItem setTitle:@"Limits and Fees"];   
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    LimitsAndFeesView.backgroundColor = [UIColor clearColor];
    LimitsAndFeesView.opaque = 0;
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    self.navigationItem.title = @"Privacy Policy";
    NSURL *webURL = [NSURL URLWithString:@"https://www.nooch.com/2248-112188/"];
    LimitsAndFeesView=[[UIWebView alloc]initWithFrame:self.view.frame];
    LimitsAndFeesView.delegate = self;
    
    [LimitsAndFeesView loadRequest:[NSURLRequest requestWithURL:webURL]];
    LimitsAndFeesView.scalesPageToFit = YES;
    
    LimitsAndFeesView.scrollView.hidden = NO;
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
    return ;
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}
-(void)webViewDidStartLoad:(UIWebView *) portal {
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}
-(void)webViewDidFinishLoad:(UIWebView *) portal{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    [self.navigationItem setRightBarButtonItem:nil];
}



- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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