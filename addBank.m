//
//  addBank.m
//  Nooch
//
//  Created by crks on 3/13/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "addBank.h"
#import "Home.h"
#import "Welcome.h"
#import "webView.h"
#import "SelectRecipient.h"

@interface addBank ()<serveD,UIWebViewDelegate>
{
    NSString *jsonString;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) UIWebView *web;
@property(nonatomic,strong) NSMutableURLRequest*request;
@property (nonatomic,strong) UIButton *helpGlyph;
@end

@implementation addBank

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    self.screenName = @"AddBank Screen";
    self.artisanNameTag = @"AddBank Webview Screen";
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationItem setTitle:@"Connect Bank"];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self.navigationItem setHidesBackButton:YES];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToSettings)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setStyleId:@"navbar_backSm"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

    [self.navigationItem setLeftBarButtonItem:menu];

    UIButton * helpGlyph = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [helpGlyph setStyleClass:@"navbar_rightside_icon"];
    [helpGlyph addTarget:self action:@selector(moreinfo_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [helpGlyph setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"] forState:UIControlStateNormal];
    [helpGlyph setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    helpGlyph.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem * help = [[UIBarButtonItem alloc] initWithCustomView:helpGlyph];
    [self.navigationItem setRightBarButtonItem:help];

    self.web = [UIWebView new];
    [self.web setDelegate:self];
    [self.web setFrame:CGRectMake(0, -1, 320, [[UIScreen mainScreen] bounds].size.height - 63)];
    [self.view addSubview:self.web];
    [self.web.scrollView setScrollEnabled:YES];

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];

    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = @"Preparing Secure Connection";
    [self.hud show:YES];

    NSString * baseUrl = [ARPowerHookManager getValueForHookById:@"synps_baseUrl"];
    NSString * memberId = [user objectForKey:@"MemberId"];

    NSString *body = [NSString stringWithFormat: @"MemberId=%@&redUrl=nooch://banksuccess",memberId];

    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@?%@",baseUrl,body]];

    NSLog(@"SYNPASE URL IS: %@",url);
    self.request = [[NSMutableURLRequest alloc]initWithURL: url];
    [self.request setHTTPMethod: @"GET"];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    [self.request setHTTPBody: [jsonString dataUsingEncoding: NSUTF8StringEncoding]];
    [self.web loadRequest: self.request];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignAddBankWebview)
                                                 name:@"SynapseResponse"
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

#pragma mark - More Info Lightbox
-(void)moreinfo_lightBox
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];

    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        mainView.frame = CGRectMake(9, -500, 302, 440);
    }
    else {
        mainView.frame = CGRectMake(9, -540, 302, self.view.frame.size.height - 5);
    }

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
    imageShow.image = [UIImage imageNamed:@"Knox_Infobox"];
    imageShow.contentMode = UIViewContentModeScaleAspectFit;

    UIButton * btnHelp = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHelp setStyleClass:@"button_LtBoxSm_left"];
    [btnHelp setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnHelp.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnHelp.frame = CGRectMake(10, mainView.frame.size.height - 56, 280, 50);
    [btnHelp setTitle:@"Get Help!" forState:UIControlStateNormal];
    [btnHelp addTarget:self action:@selector(getHelpPressed) forControlEvents:UIControlEventTouchUpInside];

    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLink.frame = CGRectMake(10, mainView.frame.size.height - 56, 280, 50);
    [btnLink setStyleClass:@"button_LtBoxSm_right"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [btnLink setTitle:@"Got It" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(close_lightKnoxLtBox) forControlEvents:UIControlEventTouchUpInside];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_lock.frame = CGRectMake(28, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        imageShow.frame = CGRectMake(1, 43, 300, 340);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height - 51, 280, 44);
    }

    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(9, 6, 35, 35);

    UIButton * btnClose_shell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose_shell.frame = CGRectMake(mainView.frame.size.width - 35, head_container.frame.origin.y - 21, 48, 46);
    [btnClose_shell addTarget:self action:@selector(close_lightKnoxLtBox) forControlEvents:UIControlEventTouchUpInside];
    [btnClose_shell addSubview:btnClose];

    [mainView addSubview:btnClose_shell];
    [mainView addSubview:imageShow];
    [mainView addSubview:btnLink];
    [mainView addSubview:btnHelp];
    [overlay addSubview:mainView];

    [UIView animateKeyframesWithDuration:.55
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.8 animations:^{
                                      overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, 70, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 5);
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.4 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, 35, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, 45, 302, self.view.frame.size.height - 5);
                                      }
                                  }];
                              }
                              completion: nil
     ];

    [ARTrackingManager trackEvent:@"Knox_MoreInfoLtBx_Appear"];
}

-(void)close_lightKnoxLtBox
{
    [UIView animateKeyframesWithDuration:0.6
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.35 animations:^{
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, 70, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 5);
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.65 animations:^{
                                      overlay.alpha = 0;
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, -500, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, -540, 302, self.view.frame.size.height - 5);
                                      }
                                  }];
                              }
                              completion:^(BOOL finished) {
                                  [overlay removeFromSuperview];
                              }
     ];
}

-(void)getHelpPressed
{    
    //contact support
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"Support Options"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"My bank is not listed", @"View Nooch Support Center", @"Email Nooch Support", nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject setTag:1];
    [actionSheetObject showInView:self.view];

    [ARTrackingManager trackEvent:@"AddBank_GetHelpTapped"];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet tag] == 1)
    {
        if (buttonIndex != 3)
        {
            [self close_lightKnoxLtBox];
        }

        if (buttonIndex == 0)
        {
            // 'My bank is not listed'
            [ARTrackingManager trackEvent:@"AddBank_ActSheet_MyBankNotListed"];

            // Email Support
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Oh No!   \xF0\x9F\x98\xB1"
                                                          message:@"Nooch works with more than 90% of checking accounts in the US, but we haven't gotten to them all yet.\n\nWe're always adding more banks and credit unions, so please let us know what bank you use.  We prioritize banks that users request and appreciate your feedback!"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
            [av show];

            if (![MFMailComposeViewController canSendMail])
            {
                [self cantSendMail];
                return;
            }
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            mailComposer.navigationBar.tintColor=[UIColor whiteColor];
            [mailComposer setSubject:[NSString stringWithFormat:@"Add My Bank!!"]];
            [mailComposer setMessageBody:@"" isHTML:NO];
            [mailComposer setToRecipients:[NSArray arrayWithObjects:@"Support@nooch.com", nil]];
            [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        else if (buttonIndex == 1)
        {
            // Go to Nooch Support Center in web view
            webView * wb = [[webView alloc]init];
            [nav_ctrl pushViewController:wb animated:NO];
        }
        else if (buttonIndex == 2)
        {
            // Email Support
            if (![MFMailComposeViewController canSendMail])
            {
                [self cantSendMail];
                return;
            }

            NSString * memberId = [user valueForKey:@"MemberId"];
            NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
            NSString * userStatus = [user objectForKey:@"Status"];
            NSString * userEmail = [user objectForKey:@"UserName"];
            NSString * IsVerifiedPhone = [[user objectForKey:@"IsVerifiedPhone"] lowercaseString];
            NSString * iOSversion = [[UIDevice currentDevice] systemVersion];
            NSString * msgBody = [NSString stringWithFormat:@"<!doctype html> <html><body><br><br><br><br><br><br><small>• MemberID: %@<br>• Name: %@<br>• Status: %@<br>• Email: %@<br>• Is Phone Verified: %@<br>• iOS Version: %@<br></small></body></html>",memberId, fullName, userStatus, userEmail, IsVerifiedPhone, iOSversion];

            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            mailComposer.navigationBar.tintColor=[UIColor whiteColor];
            [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
            [mailComposer setMessageBody:msgBody isHTML:YES];
            [mailComposer setToRecipients:[NSArray arrayWithObjects:@"Support@nooch.com", nil]];
            [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
    }
}

-(void)cantSendMail
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                      message:@"You don't have an email account configured for this device."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
        [av show];
        return;
    }
}

-(void)backToSettings
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)resignAddBankWebview
{
    NSLog(@"addBank.m -> resignAddBankWebview fired");

    [[assist shared] setneedsReload:YES];
    [[assist shared] getAcctInfo];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Great Success"
                                                    message:@"\xF0\x9F\x98\x80\nYour bank was linked successfully."
                                                   delegate:Nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:Nil, nil];
    [alert show];

    if ([user boolForKey:@"IsSynapseBankVerified"])
    {
        isFromBankWebView = YES;
        SelectRecipient * selectRecipScrn = [SelectRecipient new];
        [nav_ctrl pushViewController:selectRecipScrn animated:YES];
    }
    else
    {
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Trouble"
                          message:@"Looks like we're having trouble finding an internet connection! Please check your connection and try again."
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

        NSLog(@"Knox dictResponse is: %@",[dictResponse valueForKey:@"SaveMemberTransIdResult"]);
        //NSLog(@"Knox dictResponse -> valueForKey@'Result' is: %@",[[dictResponse valueForKey:@"SaveMemberTransIdResult"]valueForKey:@"Result"]);

        if ([[[dictResponse valueForKey:@"SaveMemberTransIdResult"]valueForKey:@"Result"]isEqualToString:@"Success"])
        {
            [user setBool:YES forKey:@"IsKnoxBankAvailable"];

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Great Success"
                                                            message:@"\xF0\x9F\x98\x80\nYour bank was linked successfully."
                                                           delegate:Nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:Nil, nil];
            [alert show];

            Home * home = [Home new];
            [nav_ctrl pushViewController:home animated:YES];
        }
        else
        {
            [user setBool:NO forKey:@"IsKnoxBankAvailable"];

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Please Try Again"
                                                            message:@"\xF0\x9F\x98\xAE\nBank linking failed, unfortunately your info was not saved. We hate it when this happens too."
                                                           delegate:Nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:Nil, nil];
            [alert show];

            [self.navigationController popViewControllerAnimated:YES];
        }
        [user synchronize];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [alert setTitle:@"Mail saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"\xF0\x9F\x93\xA4  Email Sent Successfully"];
            [alert show];
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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
