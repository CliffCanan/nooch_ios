//
//  knoxWeb.m
//  Nooch
//
//  Created by crks on 3/13/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "knoxWeb.h"
#import "ProfileInfo.h"
#import "Home.h"
@interface knoxWeb ()
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIWebView *web;
@end

@implementation knoxWeb

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
    
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Connect Bank"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.web = [UIWebView new];
    [self.web setFrame:CGRectMake(0, -10, 320, [[UIScreen mainScreen] bounds].size.height)];
    [self.view addSubview:self.web];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.delegate = self;
    self.hud.labelText = @"Loading online banking";
    //[self.hud show:YES];
    
    NSURL *url = [NSURL URLWithString: @"https://www.knoxpayments.com/admin/popup_paid.php"];
    NSString *body = [NSString stringWithFormat: @"d_amout=%@&api_key=%@&api_pass=%@invoice_detail=%@&recur_status=%@user_request=%@&req_url=%@", @"1",@"7068_59cd5c1f5a75c31",@"7068_da64134cc66a5f0",@"testing",@"ot",@"show_all",@"nooch://"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [self.web loadRequest: request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignView)
                                                 name:@"KnoxResponse"
                                               object:nil];
}

- (void)resignView {
    [nav_ctrl popViewControllerAnimated:NO];
    ProfileInfo *profile = [ProfileInfo new];
    [nav_ctrl pushViewController:profile animated:YES];
}

#pragma mark - webview delegation
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.hud hide:YES];
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
