//  Welcome.m
//  Nooch
//
//  Created by crks on 10/2/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "Welcome.h"
#import "Home.h"
#import "ProfileInfo.h"
#import "ECSlidingViewController.h"

@interface Welcome ()
@end
@implementation Welcome

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

    [self.view setBackgroundColor:[UIColor whiteColor]];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 300, 40)];
    [title setTextColor:kNoochGrayDark];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:NSLocalizedString(@"Welcom_HdrTxt", @"'Congratulations!' Header Text")];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];

    UILabel * success_header = [[UILabel alloc] initWithFrame:CGRectMake(20, 152, 280, 21)];
    [success_header setTextColor:kNoochBlue];
    [success_header setBackgroundColor:[UIColor clearColor]];
    [success_header setText:NSLocalizedString(@"Welcom_AcntCrtdSccssTxt", @"'Account Created Successfully' Header Text")];
    [success_header setTextAlignment:NSTextAlignmentCenter];
    [success_header setFont:[UIFont fontWithName:@"Roboto-regular" size:19]];
    [success_header setStyleClass:@"animate_bubble_slow"];
    [self.view addSubview:success_header];

    UIView * boxOutline = [[UIView alloc] initWithFrame:CGRectMake(10, 186, 300, 183)];
    boxOutline.backgroundColor = [UIColor whiteColor];
    boxOutline.layer.cornerRadius = 8;
    [boxOutline setStyleClass:@"welcomeBoxShadow"];
    [self.view addSubview:boxOutline];

    UILabel * next_lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 194, 300, 32)];
    [next_lbl setTextColor:kNoochGrayDark];
    [next_lbl setBackgroundColor:[UIColor clearColor]];
    [next_lbl setText:NSLocalizedString(@"Welcome_WhtNxtTxt", @"'What Next?' Text")];
    [next_lbl setTextAlignment:NSTextAlignmentCenter];
    [next_lbl setFont:[UIFont fontWithName:@"Roboto-regular" size:24]];
    [self.view addSubview:next_lbl];

    UILabel * prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 234, 300, 28)];
    [prompt setTextColor:kNoochGrayDark];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setText:NSLocalizedString(@"Welcome_Instruct1a", @"'1. Confirm your email address' instruction Text")];
    [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setFont:[UIFont fontWithName:@"Roboto-regular" size:19]];
    prompt.numberOfLines = 0;
    [self.view addSubview:prompt];

    UILabel * subPromptTxt = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 280, 23)];
    [subPromptTxt setTextColor:[Helpers hexColor:@"585a5c"]];
    [subPromptTxt setBackgroundColor:[UIColor clearColor]];
    [subPromptTxt setText:NSLocalizedString(@"Welcome_Instruct1b", @"'(we sent a link - check your email)' instruction Text")];
    [subPromptTxt setTextAlignment:NSTextAlignmentCenter];
    [subPromptTxt setFont:[UIFont fontWithName:@"Roboto-light" size:16]];
    subPromptTxt.numberOfLines = 0;
    [self.view addSubview:subPromptTxt];

    UILabel * prompt2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 306, 300, 28)];
    [prompt2 setTextColor:kNoochGrayDark];
    [prompt2 setBackgroundColor:[UIColor clearColor]];
    [prompt2 setText:NSLocalizedString(@"Welcome_Instruct2", @"'2. Verify your phone number' instruction Text")];
    [prompt2 setTextAlignment:NSTextAlignmentCenter];
    [prompt2 setFont:[UIFont fontWithName:@"Roboto-regular" size:19]];
    prompt2.numberOfLines = 0;
    [self.view addSubview:prompt2];

    UIButton * moreInfo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [moreInfo setBackgroundColor:[UIColor clearColor]];
    [moreInfo setTitle:NSLocalizedString(@"Welcome_TellMoreTxt", @"'  Tell me more' Text") forState:UIControlStateNormal];
    [moreInfo setFrame:CGRectMake(90, 336, 140, 23)];
    [moreInfo setStyleId:@"moreinfo_button"];
    [moreInfo addTarget:self action:@selector(moreinfo_lightBox) forControlEvents:UIControlEventTouchUpInside];

    UILabel * glyphInfo = [UILabel new];
    [glyphInfo setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
    [glyphInfo setFrame:CGRectMake(5, 0, 15, 23)];
    [glyphInfo setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"]];
    [glyphInfo setTextColor:kNoochPurple];
    [moreInfo addSubview:glyphInfo];
    [self.view addSubview:moreInfo];

    UIButton * goToProfile = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [goToProfile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goToProfile setTitle:NSLocalizedString(@"Welcome_LnkBtn", @"'   Complete Profile Now' Button Text") forState:UIControlStateNormal];
    [goToProfile setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    goToProfile.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [goToProfile addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];
    [goToProfile setStyleClass:@"button_green"];

    NSShadow * shadow1 = [[NSShadow alloc] init];
    shadow1.shadowColor = Rgb2UIColor(26, 38, 19, .22);
    shadow1.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes0 = @{NSShadowAttributeName: shadow1 };

    UILabel * glyphBank = [UILabel new];
    [glyphBank setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [glyphBank setFrame:CGRectMake(23, 9, 30, 30)];
    [glyphBank setTextColor:[UIColor whiteColor]];
    glyphBank.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]
                                                               attributes:textAttributes0];
    [goToProfile addSubview:glyphBank];

    UIButton * later = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [later setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [later setBackgroundColor:[UIColor clearColor]];
    [later setTitle:NSLocalizedString(@"Welcome_later", @"'I'll do this later...' Button Text") forState:UIControlStateNormal];
    [later setStyleClass:@"label_small"];
    [later addTarget:self action:@selector(later) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [goToProfile setFrame:CGRectMake(10, 384, 300, 50)];
        [later setFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 42, 300, 42)];
    }
    else
    {
        [goToProfile setFrame:CGRectMake(10, 402, 300, 50)];
        [later setFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 90, 300, 65)];
    }
    [self.view addSubview:goToProfile];
    [self.view addSubview:later];

    NSString * displayArtisanPopup = [[ARPowerHookManager getValueForHookById:@"wlcm_ArtPop"] lowercaseString];
    if ([displayArtisanPopup isEqualToString:@"yes"]) {
        shouldDisplayArtisanPopup = YES;
    }
    else
    {
        shouldDisplayArtisanPopup = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.screenName = @"Welcome Screen";
    self.artisanNameTag = @"Welcome Screen";
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)validate
{
    //Go to Profile
    [overlay removeFromSuperview];

    [self.navigationController setNavigationBarHidden:NO];

    isSignup = YES;

    ProfileInfo * profileScrn = [ProfileInfo new];
    [self.navigationController pushViewController:profileScrn animated:YES];
    [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
}

- (void)later
{
    [self.navigationController setNavigationBarHidden:NO];
    [UIView animateWithDuration:0.7
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
}

-(void)moreinfo_lightBox
{
    if (shouldDisplayArtisanPopup)
    {
        [ARTrackingManager trackEvent:@"Welcome_MoreInfo_NeedPopup"];
    }
    else
    {
        overlay = [[UIView alloc]init];
        overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
        overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self.navigationController.view addSubview:overlay];

        mainView = [[UIView alloc]init];
        mainView.layer.cornerRadius = 5;
        mainView.backgroundColor = [UIColor whiteColor];
        mainView.layer.masksToBounds = NO;
        if ([[UIScreen mainScreen] bounds].size.height < 500) {
            mainView.frame = CGRectMake(9, -500, 302, 440);
        }
        else {
            mainView.frame = CGRectMake(9, -540, 302, 499);
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
        [title setText:NSLocalizedString(@"Welcome_LtBxTtl", @"'Connect Your Bank' Lightbox Title")];
        [title setStyleClass:@"lightbox_title"];
        [head_container addSubview:title];

        UILabel * glyph_lock = [UILabel new];
        [glyph_lock setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
        [glyph_lock setFrame:CGRectMake(29, 11, 22, 29)];
        [glyph_lock setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
        [glyph_lock setTextColor:kNoochBlue];
        [head_container addSubview:glyph_lock];

        UIImageView * imageShow = [[UIImageView alloc]initWithFrame:CGRectMake(1, 50, 300, 380)];
        imageShow.image = [UIImage imageNamed:@"Knox_Infobox"];
        imageShow.contentMode = UIViewContentModeScaleAspectFit;

        UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnLink setStyleClass:@"button_green_welcome"];
        [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.22) forState:UIControlStateNormal];
        btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        btnLink.frame = CGRectMake(10, mainView.frame.size.height - 56, 280, 50);
        [btnLink setTitle:NSLocalizedString(@"Welcome_LtBxBtn", @"'  Complete Now' Lightbox Button Text") forState:UIControlStateNormal];
        [btnLink addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];

        NSShadow * shadow = [[NSShadow alloc] init];
        shadow.shadowColor = Rgb2UIColor(26, 38, 32, .22);
        shadow.shadowOffset = CGSizeMake(0, -1);
        NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

        UILabel * glyphLink = [UILabel new];
        [glyphLink setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
        [glyphLink setFrame:CGRectMake(42, 9, 22, 27)];
        glyphLink.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-link"]
                                                                   attributes:textAttributes1];
        [glyphLink setTextColor:[UIColor whiteColor]];
        [btnLink addSubview:glyphLink];

        if ([[UIScreen mainScreen] bounds].size.height < 500)
        {
            head_container.frame = CGRectMake(0, 0, 302, 38);
            space_container.frame = CGRectMake(0, 28, 302, 10);
            glyph_lock.frame = CGRectMake(28, 5, 22, 28);
            title.frame = CGRectMake(0, 5, 302, 28);
            imageShow.frame = CGRectMake(2, 42, 298, 338);
            btnLink.frame = CGRectMake(10, mainView.frame.size.height - 51, 280, 44);
        }

        UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
        btnClose.image = [UIImage imageNamed:@"close_button"];
        btnClose.frame = CGRectMake(9, 6, 35, 35);

        UIButton * btnClose_shell = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClose_shell.frame = CGRectMake(mainView.frame.size.width - 35, head_container.frame.origin.y - 21, 48, 46);
        [btnClose_shell addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
        [btnClose_shell addSubview:btnClose];

        [mainView addSubview:btnClose_shell];
        [mainView addSubview:imageShow];
        [mainView addSubview:btnLink];
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
                                              mainView.frame = CGRectMake(9, 74, 302, 440);
                                          }
                                          else {
                                              mainView.frame = CGRectMake(9, 74, 302, 499);
                                          }
                                      }];
                                      [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.4 animations:^{
                                          if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                              mainView.frame = CGRectMake(9, 35, 302, 440);
                                          }
                                          else {
                                              mainView.frame = CGRectMake(9, 45, 302, 499);
                                          }
                                      }];
                                  }
                                  completion:^(BOOL finished) {
                                      [ARTrackingManager trackEvent:@"Welcome_MoreInfo_FinishedAppear"];
                                  }
         ];
    }
}

-(void)close_lightBox
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
                                          mainView.frame = CGRectMake(9, 70, 302, 499);
                                      }
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.65 animations:^{
                                      overlay.alpha = 0;
                                      if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                          mainView.frame = CGRectMake(9, -500, 302, 440);
                                      }
                                      else {
                                          mainView.frame = CGRectMake(9, -540, 302, 499);
                                      }
                                  }];
                              }
                              completion:^(BOOL finished) {
                                  [overlay removeFromSuperview];
                              }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end