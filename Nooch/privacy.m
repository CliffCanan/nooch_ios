//  privacy.m
//  Nooch
//
//  Copyright 2014 Nooch Inc. All rights reserved.

#import "privacy.h"
#import "Home.h"
#import "ECSlidingViewController.h"
#import "SpinKit/RTSpinKitView.h"

@interface privacy ()<MBProgressHUDDelegate>
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation privacy

@synthesize privacyView;

# pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil value:(NSString *)sendValue
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidDisappear:(BOOL)animated{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.trackedViewName = @"Privacy Screen";
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Privacy Policy";
    privacyView.backgroundColor = [UIColor whiteColor];

    UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];

    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = @"Loading Privacy Policy...";
    [self.hud show:YES];
    [spinner1 startAnimating];

    NSURL * webURL = [NSURL URLWithString:@"https://www.nooch.com/privacy/"];
    privacyView = [[UIWebView alloc]initWithFrame:CGRectMake(0, -2, 320, [[UIScreen mainScreen] bounds].size.height - 62)];
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
    [self.hud hide:YES];
    return ;
}

-(void)webViewDidFinishLoad:(UIWebView *) portal
{
    [self.hud hide:YES];
    [self.navigationItem setRightBarButtonItem:nil];
}

-(void)showMenu
{
    [[assist shared]setneedsReload:NO];
    [self.slidingViewController anchorTopViewTo:ECRight];
}
-(void)Error:(NSError *)Error{
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
    
}
# pragma mark - serve delegation
-(void)listen:(NSString *)result tagName:(NSString*)tagName
{
    NSError *error;
    NSDictionary *template = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if ([template objectForKey:@"Result"]) {
        [privacyView loadHTMLString:[template objectForKey:@"Result"] baseURL:nil];
    }
    
    [self.hud hide:YES];

    for (id subView in [privacyView subviews]) {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)]) {
            [subView flashScrollIndicators];
        }
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

@end
