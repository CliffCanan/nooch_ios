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

    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setStyleId:@"navbar_back"];
    [backBtn setImage:[UIImage imageNamed:@"whiteBack.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"whiteBack.png"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
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
    
    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = @"Preparing Secure Connection";
    [self.hud show:YES];
    [spinner1 startAnimating];

    NSString *body = [NSString stringWithFormat: @"amount=%@&api_key=%@&api_password=%@&invoice_detail=%@&recurring=%@&information_request=%@&redirect_url=%@&partner=%@&label=%@", @"0.00",@"7068_59cd5c1f5a75c31",@"7068_da64134cc66a5f0",@"Onboard",@"ot",@"show_all",@"nooch://",@"nooch",@"wl"];
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@?%@",@"https://knoxpayments.com/pay/index.php",body]];
    
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
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];

    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    mainView.frame = CGRectMake(9, -540, 302, self.view.frame.size.height - 5);
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;
    
    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
                     }];
    
    [UIView animateWithDuration:0.33
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 5);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.22
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              mainView.frame = CGRectMake(9, 45, 302, self.view.frame.size.height - 5);
                                          }];
                     }];
 
    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;

    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];

    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 28)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Connect An Account"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];

    UILabel * glyph_lock = [UILabel new];
    [glyph_lock setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph_lock setFrame:CGRectMake(29, 10, 22, 29)];
    [glyph_lock setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    [glyph_lock setTextColor:kNoochBlue];
    [head_container addSubview:glyph_lock];

    UIImageView * imageShow = [[UIImageView alloc]initWithFrame:CGRectMake(1, 50, 300, 380)];
    imageShow.image = [UIImage imageNamed:@"Knox_lightbox.png"];
    imageShow.contentMode = UIViewContentModeScaleAspectFit;

    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnLink.frame = CGRectMake(10,mainView.frame.size.height-56, 280, 50);
    [btnLink setTitle:@"Continue" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(8, 40, 302, 430);
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_lock.frame = CGRectMake(29, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        imageShow.frame = CGRectMake(1, 43, 300, 340);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height-51, 280, 44);
    }
    
    UIButton *btnclose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnclose.frame = CGRectMake(mainView.frame.size.width - 28, head_container.frame.origin.y - 15, 35, 35);
    [btnclose setImage:[UIImage imageNamed:@"close_button.png"] forState:UIControlStateNormal] ;
    [btnclose addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];

    [mainView addSubview:btnclose];
    [mainView addSubview:imageShow];
    [mainView addSubview:btnLink];
    [overlay addSubview:mainView];
}

-(void)close_lightBox
{
    //[overlay removeFromSuperview];
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

    serve * obj = [serve new];
    obj.tagName = @"saveMemberTransId";
    [obj setDelegate:self];
    
    NSDictionary * dict = @{@"TransId":[[NSUserDefaults standardUserDefaults] objectForKey:@"paymentID"],
                            @"BankName":[[NSUserDefaults standardUserDefaults] objectForKey:@"BankName"],
                            @"BankImageURL":[[NSUserDefaults standardUserDefaults] objectForKey:@"BankImageURL"],
                            @"AccountName":[[NSUserDefaults standardUserDefaults] objectForKey:@"AccountName"],
                            @"MemberId":[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]};
    
    [obj saveMemberTransId:[dict mutableCopy]];
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
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError *error;
    
    if ([tagName isEqualToString:@"saveMemberTransId"])
    {
        [self.hud hide:YES];
        
        NSDictionary * dictResponse = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([[[dictResponse valueForKey:@"SaveMemberTransIdResult"]valueForKey:@"Result"]isEqualToString:@"Success"])
        {
            [nav_ctrl popViewControllerAnimated:NO];
            ProfileInfo * profile = [ProfileInfo new];
            isProfileOpenFromSideBar = NO;
            [nav_ctrl pushViewController:profile animated:YES];

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Great Success" message:@"Your bank was successfully linked." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Please Try Again" message:@"Bank linking failed and your info was not saved." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
            
            [self.navigationController popViewControllerAnimated:YES];
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
