//
//  webView.m
//  Nooch
//
//  Created by Vicky Mathneja on 04/07/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "webView.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *webURL = [NSURL URLWithString:@"http://support.nooch.com"];
    mywebview=[[UIWebView alloc]initWithFrame:self.view.frame];
    mywebview.delegate = self;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end