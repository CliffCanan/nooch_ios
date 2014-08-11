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
@interface knoxWeb ()<serveD>
{
    NSString *jsonString;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIWebView *web;
@property(nonatomic,strong) NSMutableURLRequest*request;
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
    [self.web setFrame:CGRectMake(0, -2, 320, [[UIScreen mainScreen] bounds].size.height - 60)];
    [self.view addSubview:self.web];
    [self.web.scrollView setScrollEnabled:YES];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.delegate = self;
    self.hud.labelText = @"Preparing Secure Connection";
    //[self.hud show:YES];
    NSString *body = [NSString stringWithFormat: @"amount=%@&api_key=%@&api_password=%@&invoice_detail=%@&recurring=%@&information_request=%@&redirect_url=%@", @".01",@"7068_59cd5c1f5a75c31",@"7068_da64134cc66a5f0",@"Onboard",@"ot",@"show_all",@"nooch://"];
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@?%@",@"https://knoxpayments.com/nooch/index.php",body]];

    
    self.request = [[NSMutableURLRequest alloc]initWithURL: url];
    [self.request setHTTPMethod: @"GET"];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    [self.request setHTTPBody: [jsonString dataUsingEncoding: NSUTF8StringEncoding]];
    [self.web loadRequest: self.request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignView)
                                                 name:@"KnoxResponse"
                                               object:nil];
}

- (void)resignView {
    serve*obj=[serve new];
    obj.tagName=@"saveMemberTransId";
    [obj setDelegate:self];
    
    NSDictionary*dict=@{@"TransId":[[NSUserDefaults standardUserDefaults] objectForKey:@"paymentID"],@"BankName":[[NSUserDefaults standardUserDefaults] objectForKey:@"BankName"],@"BankImageURL":[[NSUserDefaults standardUserDefaults] objectForKey:@"BankImageURL"],@"AccountName":[[NSUserDefaults standardUserDefaults] objectForKey:@"AccountName"],@"MemberId":[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]};
    NSLog(@"%@",dict);
    
    [obj saveMemberTransId:[dict mutableCopy]];
    
    [nav_ctrl popViewControllerAnimated:NO];
    ProfileInfo *profile = [ProfileInfo new];
    isProfileOpenFromSideBar=NO;
    [nav_ctrl pushViewController:profile animated:YES];
}
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
        NSError *error;
    
    if ([tagName isEqualToString:@"saveMemberTransId"]) {
        NSDictionary*dictResponse=[NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([[[dictResponse valueForKey:@"SaveMemberTransIdResult"]valueForKey:@"Result"]isEqualToString:@"Success"]) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Whooo" message:@"Bank Successfully Linked" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Try Lator" message:@"Bank Linking failure" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
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
