//
//  privacy.m
//  Nooch
//
//  Created by administrator on 6/05/14.
//  Copyright 2014 Nooch Inc. All rights reserved.
//

#import "privacy.h"
#import "terms.h"

@implementation privacy

@synthesize privacyView,spinner;

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
    //[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    privacyView.backgroundColor = [UIColor clearColor];
    privacyView.opaque = 0;
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    self.navigationItem.title = @"Privacy Policy";
    
    NSURL *webURL = [NSURL URLWithString:@"https://www.nooch.com/privacy/"];
    privacyView=[[UIWebView alloc]initWithFrame:CGRectMake(0, -2, 320, [[UIScreen mainScreen] bounds].size.height - 62)];
    privacyView.delegate = self;
    [privacyView loadRequest:[NSURLRequest requestWithURL:webURL]];
    privacyView.scalesPageToFit = YES;
    privacyView.scrollView.hidden = NO;
    [privacyView setMultipleTouchEnabled:YES];
    [self.view addSubview:privacyView];
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
    self.navigationItem.title = @"Privacy Policy";
}

-(void)goBack
{
    //[navCtrl dismissModalViewControllerAnimated:YES];
}

# pragma mark - serve delegation

-(void)listen:(NSString *)result tagName:(NSString*)tagName
{
    NSError *error;
    NSDictionary *template = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if([template objectForKey:@"Result"])
    {
        [privacyView loadHTMLString:[template objectForKey:@"Result"] baseURL:nil];
    }
    [spinner stopAnimating];
    for (id subView in [privacyView subviews]) {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)]) {
            [subView flashScrollIndicators];
        }
    }
}

- (IBAction)continueButtonAction
{
   //[navCtrl dismissModalViewControllerAnimated:YES];
}

@end
