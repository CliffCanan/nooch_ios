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
#import "Welcome.h"
@interface knoxWeb ()<serveD,UIWebViewDelegate>
{
    NSString *jsonString;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIWebView *web;
@property(nonatomic,strong) NSMutableURLRequest*request;
@property (nonatomic,strong) UIButton *helpGlyph;
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.trackedViewName = @"KnoxWeb Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.topItem.title = @"";
    NSDictionary *navbarTtlAts = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIColor whiteColor], UITextAttributeTextColor,
                                  Rgb2UIColor(19, 32, 38, .25), UITextAttributeTextShadowColor,
                                  [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)], UITextAttributeTextShadowOffset,
                                  nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTtlAts];

    [self.navigationItem setTitle:@"Connect Bank"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeCustom];
    [hamburger setStyleId:@"navbar_back"];
    [hamburger setImage:[UIImage imageNamed:@"whiteBack.png"] forState:UIControlStateNormal];
    [hamburger setImage:[UIImage imageNamed:@"whiteBack.png"] forState:UIControlStateHighlighted];
    [hamburger addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    UIButton *helpGlyph = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [helpGlyph setStyleClass:@"navbar_rightside_icon"];
    [helpGlyph addTarget:self action:@selector(moreinfo_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [helpGlyph setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"] forState:UIControlStateNormal];
    UIBarButtonItem *help = [[UIBarButtonItem alloc] initWithCustomView:helpGlyph];
    [self.navigationItem setRightBarButtonItem:help];
    
    self.web = [UIWebView new];
    [self.web setDelegate:self];
    [self.web setFrame:CGRectMake(0, -2, 320, [[UIScreen mainScreen] bounds].size.height - 61)];
    [self.view addSubview:self.web];
    [self.web.scrollView setScrollEnabled:YES];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.delegate = self;
    self.hud.labelText = @"Preparing Secure Connection";
    [self.hud show:YES];

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
-(void)moreinfo_lightBox
{
    overlay = [[UIView alloc]init];
    overlay.frame=CGRectMake(0, 0, 320, 568);
    overlay.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [UIView transitionWithView:self.navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.navigationController.view addSubview:overlay];
                    }
                    completion:nil];
    
    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    mainView.frame = CGRectMake(10, 45, 300, self.view.frame.size.height-45);
    mainView.backgroundColor = [UIColor whiteColor];
    
    [overlay addSubview:mainView];
    mainView.layer.masksToBounds = NO;
    mainView.layer.cornerRadius = 5;
    mainView.layer.shadowOffset = CGSizeMake(0, 2);
    mainView.layer.shadowRadius = 4;
    mainView.layer.shadowOpacity = 0.6;
    
    UIView*head_container=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 44)];
    head_container.backgroundColor=[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;
    
    UILabel*title=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 300, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Connecting Your Bank"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];
    
    UIView *space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 300, 10)];
    space_container.backgroundColor=[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];
    
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(2, 48, 296, 300)];
    
    UIImageView *imageShow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 296, self.view.frame.size.height-175)];
    imageShow.image = [UIImage imageNamed:@"KnoxInfo_Lightbox@2x.png"];
    imageShow.contentMode = UIViewContentModeScaleAspectFit;
    [container addSubview:imageShow];
    [mainView addSubview:container];
    
    UIButton *btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.3) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    btnLink.frame = CGRectMake(10,mainView.frame.size.height-60, 280, 50);
    [btnLink setTitle:@"Continue" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:btnLink];
    
    UIButton *btnclose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnclose.frame=CGRectMake(mainView.frame.size.width-28,head_container.frame.origin.y-15, 35, 35);
    [btnclose setImage:[UIImage imageNamed:@"close_button.png"] forState:UIControlStateNormal] ;
    [btnclose addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:btnclose];
}

-(void)close_lightBox
{
    [overlay removeFromSuperview];
    [UIView transitionWithView:self.navigationController.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [overlay removeFromSuperview];
                    }
                    completion:nil];
}

-(void)backToHome {
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)resignView
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.delegate = self;
    self.hud.labelText = @"Finishing up...";
    [self.hud show:YES];

    serve*obj=[serve new];
    obj.tagName=@"saveMemberTransId";
    [obj setDelegate:self];
    
    NSDictionary*dict=@{@"TransId":[[NSUserDefaults standardUserDefaults] objectForKey:@"paymentID"],@"BankName":[[NSUserDefaults standardUserDefaults] objectForKey:@"BankName"],@"BankImageURL":[[NSUserDefaults standardUserDefaults] objectForKey:@"BankImageURL"],@"AccountName":[[NSUserDefaults standardUserDefaults] objectForKey:@"AccountName"],@"MemberId":[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]};
    NSLog(@"%@",dict);
    
    [obj saveMemberTransId:[dict mutableCopy]];
    
    [nav_ctrl popViewControllerAnimated:NO];
    ProfileInfo *profile = [ProfileInfo new];
    isProfileOpenFromSideBar = NO;
    [nav_ctrl pushViewController:profile animated:YES];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError *error;
    
    if ([tagName isEqualToString:@"saveMemberTransId"])
    {
        [self.hud hide:YES];
        
        NSDictionary*dictResponse=[NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([[[dictResponse valueForKey:@"SaveMemberTransIdResult"]valueForKey:@"Result"]isEqualToString:@"Success"])
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Whooo" message:@"Bank Successfully Linked" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Please Try Again" message:@"Bank Linking Failure" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
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

@end
