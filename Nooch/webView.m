//
//  webView.m
//  Nooch
//
//  Created by Vicky Mathneja on 04/07/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "webView.h"
#import "Home.h"

@interface webView ()<UIWebViewDelegate>

@end

@implementation webView
@synthesize mywebview;

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
    self.screenName = @"Support Center WebView Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //@"Support Center"
    [self.navigationItem setTitle:NSLocalizedString(@"webView_ScrnTitle", @"Support Center webview screen title")];

    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    NSURL *webURL = [NSURL URLWithString:@"http://support.nooch.com"];
    mywebview=[[UIWebView alloc]initWithFrame:self.view.frame];
    [mywebview setFrame:CGRectMake(0, -40, 320, [[UIScreen mainScreen] bounds].size.height - 22)];
    [mywebview loadRequest:[NSURLRequest requestWithURL:webURL]];
    mywebview.scalesPageToFit = YES;
    mywebview.delegate=self;
    mywebview.scrollView.hidden = NO;
    [mywebview setMultipleTouchEnabled:YES];
    [self.view addSubview:mywebview];
    // Do any additional setup after loading the view.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

-(void)showMenu
{
    [[assist shared]setneedsReload:NO];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    return ;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
