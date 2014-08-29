//
//  terms.m
//  Nooch
//
//  Created by administrator on 6/05/14.
//  Copyright 2014 Nooch Inc. All rights reserved.
//

#import "terms.h"
#import "NSData+AESCrypt.h"
#import "NSString+AESCrypt.h"

@implementation terms

@synthesize termsView,spinner;

# pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil value:(NSString *)sendValue
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.trackedViewName = @"Terms Screen";
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"User Agreement";

    NSURL *webURL = [NSURL URLWithString:@"https://www.nooch.com/tos"];
    termsView=[[UIWebView alloc]initWithFrame:CGRectMake(0, -2, 320, [[UIScreen mainScreen] bounds].size.height - 62)];
    termsView.delegate = self;
    
    [termsView loadRequest:[NSURLRequest requestWithURL:webURL]];
    termsView.scalesPageToFit = YES;
   
    termsView.scrollView.hidden = NO;
    [termsView setMultipleTouchEnabled:YES];
    [self.view addSubview:termsView];
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

-(void)navCustomization
{
}

-(void)goBack
{
    //[navCtrl dismissModalViewControllerAnimated:YES];
}

- (IBAction) acceptButtonAction
{
    //[navCtrl dismissModalViewControllerAnimated:YES];
}

-(void)listen:(NSString *)result tagName:(NSString*)tagName
{
    NSError *error;
    NSDictionary *template = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    [termsView loadHTMLString:[template objectForKey:@"Result"] baseURL:nil];
    [spinner stopAnimating];
    
    for (id subView in [termsView subviews]) {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)]) {
            [subView flashScrollIndicators];
        }
    }
}

@end
