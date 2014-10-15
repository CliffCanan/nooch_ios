//  Welcome.m
//  Nooch
//
//  Created by crks on 10/2/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "Welcome.h"
#import "Home.h"
#import "ProfileInfo.h"
#import "knoxWeb.h"
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];

    self.trackedViewName = @"Welcome Screen";

    [self.navigationController setNavigationBarHidden:YES];
    
}
- (void)validate
{
    //navigate to settings
    [overlay removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO];
    isSignup=YES;
    knoxWeb *knox = [knoxWeb new];
    [self.navigationController pushViewController:knox animated:YES];
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
    [title setText:@"Congratulations!"];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];
    
    UILabel * success_header = [[UILabel alloc] initWithFrame:CGRectMake(20, 156, 280, 20)];
    [success_header setTextColor:kNoochBlue];
    [success_header setBackgroundColor:[UIColor clearColor]];
    [success_header setText:@"Account Created Successfully"];
    [success_header setTextAlignment:NSTextAlignmentCenter];
    [success_header setFont:[UIFont fontWithName:@"Roboto-regular" size:19]];
    [success_header setStyleClass:@"animate_bubble_slow"];
    [self.view addSubview:success_header];
    
    UILabel * next_lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 194, 300, 32)];
    [next_lbl setTextColor:kNoochGrayDark];
    [next_lbl setBackgroundColor:[UIColor clearColor]];
    [next_lbl setText:@"What Next?"];
    [next_lbl setTextAlignment:NSTextAlignmentCenter];
    [next_lbl setFont:[UIFont fontWithName:@"Roboto-regular" size:24]];
    [self.view addSubview:next_lbl];

    UILabel * prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 228, 300, 110)];
    [prompt setTextColor:kNoochGrayDark];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setText:@"1. Confirm your email address\n(we sent a link)\n\n2. Link a funding source"];
    [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setFont:[UIFont fontWithName:@"Roboto-regular" size:19]];
    prompt.numberOfLines = 0;
    [self.view addSubview:prompt];

    UIButton * moreinfo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [moreinfo setBackgroundColor:[UIColor clearColor]];
    [moreinfo setTitle:@" Tell me more" forState:UIControlStateNormal];
    [moreinfo setFrame:CGRectMake(93, 338, 134, 20)];
    [moreinfo setStyleId:@"moreinfo_button"];
    
    UILabel * glyphinfo = [UILabel new];
    [glyphinfo setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
    [glyphinfo setFrame:CGRectMake(5, 1, 15, 18)];
    [glyphinfo setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"]];
    [glyphinfo setTextColor:kNoochPurple];
    [moreinfo addSubview:glyphinfo];
    [moreinfo addTarget:self action:@selector(moreinfo_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreinfo];

    UIButton * enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setTitle:@"   Link Funding Source" forState:UIControlStateNormal];
    [enter setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    enter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [enter addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 388, 300, 60)];
    [enter setStyleClass:@"button_green"];
    
    NSShadow * shadow1 = [[NSShadow alloc] init];
    shadow1.shadowColor = Rgb2UIColor(26, 38, 19, .22);
    shadow1.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes0 = @{NSShadowAttributeName: shadow1 };

    UILabel * glyphBank = [UILabel new];
    [glyphBank setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [glyphBank setFrame:CGRectMake(23, 9, 30, 30)];
    glyphBank.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]
                                                               attributes:textAttributes0];
    [glyphBank setTextColor:[UIColor whiteColor]];
    
    [enter addSubview:glyphBank];
    [self.view addSubview:enter];
    
    UIButton * later = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [later setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [later setBackgroundColor:[UIColor clearColor]];
    [later setTitle:@"I'll link a bank later..." forState:UIControlStateNormal];
    [later addTarget:self action:@selector(later) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [later setFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 44, 300, 44)];
    }
    else {
        [later setFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 90, 300, 65)];
    }
    [later setStyleClass:@"label_small"];
    [self.view addSubview:later];
}

-(void)moreinfo_lightBox
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.navigationController.view addSubview:overlay];
    
    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    mainView.frame = CGRectMake(8, -540, 302, 504);
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.layer.masksToBounds = NO;
    
    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;
    
    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 304, 30)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Connect Your Bank"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];

    UILabel * glyph_lock = [UILabel new];
    [glyph_lock setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyph_lock setFrame:CGRectMake(32, 11, 22, 29)];
    [glyph_lock setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    [glyph_lock setTextColor:kNoochBlue];
    [head_container addSubview:glyph_lock];

    UIImageView * imageShow = [[UIImageView alloc]initWithFrame:CGRectMake(2, 50, 300, 380)];
    imageShow.image = [UIImage imageNamed:@"Knox_lightbox.png"];
    imageShow.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.22) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnLink.frame = CGRectMake(10,mainView.frame.size.height-56, 280, 50);
    [btnLink setTitle:@" Link Now" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(26, 38, 32, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

    UILabel * glyphLink = [UILabel new];
    [glyphLink setFont:[UIFont fontWithName:@"FontAwesome" size:18]];
    [glyphLink setFrame:CGRectMake(70, 9, 24, 28)];
    glyphLink.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-link"]
                                                             attributes:textAttributes1];
    [glyphLink setTextColor:[UIColor whiteColor]];
    [btnLink addSubview:glyphLink];
    [mainView addSubview:btnLink];

    UIImageView * btnClose = [[UIImageView alloc] initWithFrame:self.view.frame];
    btnClose.image = [UIImage imageNamed:@"close_button"];
    btnClose.frame = CGRectMake(9, 6, 35, 35);
    
    UIButton * btnClose_shell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose_shell.frame = CGRectMake(mainView.frame.size.width - 35, head_container.frame.origin.y - 21, 48, 46);
    [btnClose_shell addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [btnClose_shell addSubview:btnClose];
    
    [mainView addSubview:btnClose_shell];
    [mainView addSubview:imageShow];
    [overlay addSubview:mainView];

    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
                     }];
    
    [UIView animateWithDuration:0.35
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 52);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.24
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              mainView.frame = CGRectMake(9, 45, 302, self.view.frame.size.height - 52);
                                          }
                          ];
                     }
     ];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        mainView.frame = CGRectMake(9, 40, 302, 430);
        head_container.frame = CGRectMake(0, 0, 302, 38);
        space_container.frame = CGRectMake(0, 28, 302, 10);
        glyph_lock.frame = CGRectMake(29, 5, 22, 29);
        title.frame = CGRectMake(0, 5, 302, 28);
        imageShow.frame = CGRectMake(2, 42, 298, 338);
        btnLink.frame = CGRectMake(10,mainView.frame.size.height-51, 280, 44);
    }

}

-(void)close_lightBox
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 52);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.38
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              mainView.frame = CGRectMake(9, -540, 302, self.view.frame.size.height - 52);
                                              overlay.alpha = 0;
                                          } completion:^(BOOL finished) {
                                              [overlay removeFromSuperview];
                                          }
                          ];
                     }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end