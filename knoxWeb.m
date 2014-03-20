//
//  knoxWeb.m
//  Nooch
//
//  Created by crks on 3/13/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "knoxWeb.h"

@interface knoxWeb ()
@property(nonatomic,strong) MBProgressHUD *hud;
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
    
    web = [UIWebView new];
    [web setDelegate:self];
    [web setFrame:CGRectMake(0, -42, 320, [[UIScreen mainScreen] bounds].size.height)];
    [self.view addSubview:web];
    
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.nooch.com/staging/web-app/bank-add.php"]]];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.delegate = self;
    self.hud.labelText = @"Loading online banking";
    [self.hud show:YES];
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
