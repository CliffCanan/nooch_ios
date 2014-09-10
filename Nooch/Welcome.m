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
    [UIView animateWithDuration:0.75
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
    
    UILabel * slogan = [[UILabel alloc] initWithFrame:CGRectMake(58, 90, 202, 19)];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [slogan setFrame:CGRectMake(0, 218, 0, 0)];
    }
    [slogan setBackgroundColor:[UIColor clearColor]];
    [slogan setText:@"Money Made Simple"];
    [slogan setFont:[UIFont fontWithName:@"VarelaRound-regular" size:15]];
    [slogan setStyleClass:@"prelogin_slogan"];
    [self.view addSubview:slogan];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 40)];
    [title setTextColor:kNoochGrayDark];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Congratulations!"];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];
    
    UILabel * success_header = [[UILabel alloc] initWithFrame:CGRectMake(20, 166, 280, 20)];
    [success_header setTextColor:kNoochBlue];
    [success_header setBackgroundColor:[UIColor clearColor]];
    [success_header setText:@"Account Created Successfully"];
    [success_header setTextAlignment:NSTextAlignmentCenter];
    [success_header setFont:[UIFont fontWithName:@"Roboto-regular" size:19]];
    [self.view addSubview:success_header];
    
    UILabel * prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 280, 122)];
    [prompt setTextColor:kNoochGrayDark];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setText:@"Next:\n\n1. Confirm your email address\n(we sent a link)\n\n2. Link a funding source \n"];
    [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setFont:[UIFont fontWithName:@"Roboto-regular" size:17]];
    prompt.numberOfLines = 0;
    [self.view addSubview:prompt];

    UIButton * enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setTitle:@"   Link Funding Source" forState:UIControlStateNormal];
    [enter setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    enter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [enter addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 385, 300, 60)];
    [enter setStyleClass:@"button_green"];
    
    UILabel * glyphBank = [UILabel new];
    [glyphBank setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    [glyphBank setFrame:CGRectMake(22, 9, 30, 30)];
    [glyphBank setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    [glyphBank setTextColor:[UIColor whiteColor]];
    
    [enter addSubview:glyphBank];
    [self.view addSubview:enter];

    UIButton * moreinfo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [moreinfo setBackgroundColor:[UIColor clearColor]];
    [moreinfo setTitle:@" Tell me more" forState:UIControlStateNormal];
    [moreinfo setFrame:CGRectMake(95, 325, 130, 20)];
    [moreinfo setStyleId:@"moreinfo_button"];
    
    UILabel * glyphinfo = [UILabel new];
    [glyphinfo setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
    [glyphinfo setFrame:CGRectMake(4, 1, 15, 18)];
    [glyphinfo setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"]];
    [glyphinfo setTextColor:kNoochPurple];
    [moreinfo addSubview:glyphinfo];
    [moreinfo addTarget:self action:@selector(moreinfo_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreinfo];
    
    UIButton * later = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [later setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [later setBackgroundColor:[UIColor clearColor]];
    [later setTitle:@"I'll link a bank later..." forState:UIControlStateNormal];
    [later addTarget:self action:@selector(later) forControlEvents:UIControlEventTouchUpInside];
    [later setFrame:CGRectMake(10, 450, 300, 60)];
    [later setStyleClass:@"label_small"];
    [self.view addSubview:later];
}

-(void)moreinfo_lightBox
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [UIView transitionWithView:self.navigationController.view
    duration:0.5
    options:UIViewAnimationOptionTransitionCrossDissolve
    animations:^{
        [self.navigationController.view addSubview:overlay];
    }
    completion:nil];
     
    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 5;
    mainView.frame = CGRectMake(6, 40, 308, self.view.frame.size.height-80);
    mainView.backgroundColor = [UIColor whiteColor];
     
    [overlay addSubview:mainView];
    mainView.layer.masksToBounds = NO;
    mainView.layer.cornerRadius = 5;
    mainView.layer.shadowOffset = CGSizeMake(0, 2);
    mainView.layer.shadowRadius = 4;
    mainView.layer.shadowOpacity = 0.6;
    
    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 308, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;
     
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 308, 30)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Connect Your Bank"];
    [title setStyleClass:@"lightbox_title"];
    [head_container addSubview:title];
    
    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 308, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];
     
    UIView * container = [[UIView alloc]initWithFrame:CGRectMake(2, 44, 304, 300)];
     
    UIImageView * imageShow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 304, self.view.frame.size.height-175)];
    imageShow.image = [UIImage imageNamed:@"KnoxInfo_Lightbox@2x.png"];
    imageShow.contentMode = UIViewContentModeScaleAspectFit;
    [container addSubview:imageShow];
    [mainView addSubview:container];
     
    UIButton * btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLink setStyleClass:@"button_green_welcome"];
    [btnLink setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.2) forState:UIControlStateNormal];
    btnLink.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    btnLink.frame = CGRectMake(10,mainView.frame.size.height-57, 280, 50);
    [btnLink setTitle:@"Link Now" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];

    UILabel * glyphLink = [UILabel new];
    [glyphLink setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [glyphLink setFrame:CGRectMake(186, 9, 30, 30)];
    [glyphLink setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-link"]];
    [glyphLink setTextColor:[UIColor whiteColor]];
    
    [btnLink addSubview:glyphLink];
    [mainView addSubview:btnLink];
     
    UIButton * btnclose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnclose.frame = CGRectMake(mainView.frame.size.width-28,head_container.frame.origin.y-15, 35, 35);
    [btnclose setImage:[UIImage imageNamed:@"close_button.png"] forState:UIControlStateNormal] ;
    [btnclose addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:btnclose];
}

-(void)close_lightBox{
    [overlay removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end