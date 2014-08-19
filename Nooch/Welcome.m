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
//    if (isSignup) {
//        [self.navigationController setNavigationBarHidden:NO];
//        [UIView animateWithDuration:0.75
//                         animations:^{
//                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
//                         }];
//        [self.navigationController popToRootViewControllerAnimated:NO];
//        [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
//        isSignup=NO;
//    }
    [self.navigationController setNavigationBarHidden:YES];
    
}
- (void)validate
{
    //navigate to settings
    [overlay removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO];
    
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
    
    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    [title setTextColor:kNoochGrayDark]; [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Congratulations!"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:24]];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 280, 160)];
    [prompt setTextColor:kNoochGrayDark]; [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setText:@"Your account has been created.\n\nCheck your email for a message from us to confirm your email address.\n\nBefore you can send money you'll need a funding source. Tap the green button to link your bank now."];
    [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setFont:[UIFont systemFontOfSize:15]];
    prompt.numberOfLines=0;
    [prompt sizeToFit];
//  CGRect frame = prompt.frame;
//  frame.size.height += 150;
//  [prompt setFrame:frame];
    [self.view addSubview:prompt];

    UIButton *enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setTitle:@"Link Funding Source" forState:UIControlStateNormal];
    [enter addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 375, 300, 60)];
    [enter setStyleClass:@"button_green"];
    [self.view addSubview:enter];

    UIButton *moreinfo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [moreinfo setBackgroundColor:[UIColor clearColor]];
    [moreinfo setTitle:@"   Tell me more" forState:UIControlStateNormal];
    [moreinfo setFrame:CGRectMake(30, 335, 260, 22)];
    [moreinfo setStyleClass:@"moreinfo_button"];
    
    UILabel *glyph = [UILabel new];
    [glyph setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
    [glyph setFrame:CGRectMake(1, 2, 15, 18)];
    [glyph setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-question-circle"]];
    [glyph setTextColor:kNoochGrayLight];
    [moreinfo addSubview:glyph];
    [moreinfo addTarget:self action:@selector(moreinfo_lightBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreinfo];
    
    UIButton *later = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [later setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [later setBackgroundColor:[UIColor clearColor]];
    [later setTitle:@"I'll link a bank later..." forState:UIControlStateNormal];
    [later addTarget:self action:@selector(later) forControlEvents:UIControlEventTouchUpInside];
    [later setFrame:CGRectMake(10, 460, 300, 60)];
    [later setStyleClass:@"label_small"];
    [self.view addSubview:later];
}
-(void)moreinfo_lightBox{
     overlay=[[UIView alloc]init];
     overlay.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
     overlay.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
     
     [UIView transitionWithView:self.navigationController.view
     duration:0.4
     options:UIViewAnimationOptionTransitionCrossDissolve
     animations:^{
     [self.navigationController.view addSubview:overlay];
     }
     completion:nil];
     
     mainView=[[UIView alloc]init];
     mainView.layer.cornerRadius=5;
     
     mainView.frame=CGRectMake(10, 70, 300, self.view.frame.size.height-75);
     mainView.backgroundColor=[UIColor whiteColor];
     
     [overlay addSubview:mainView];
     mainView.layer.masksToBounds = NO;
     mainView.layer.cornerRadius = 5;
     mainView.layer.shadowOffset = CGSizeMake(0, 2);
     mainView.layer.shadowRadius = 4;
     mainView.layer.shadowOpacity = 0.5;
     
    
     UIView*head_container=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 44)];
     head_container.backgroundColor=[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
     [mainView addSubview:head_container];
     head_container.layer.cornerRadius = 10;
     
     UILabel*title=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 300, 30)];
     [title setBackgroundColor:[UIColor clearColor]];
     title.textAlignment=NSTextAlignmentCenter;
     [title setText:@"Connect Your Bank"];
     title.font=[UIFont fontWithName:@"Arial" size:20];
     [title setTextColor:kNoochBlue];
     [head_container addSubview:title];
    
     UIView*space_container=[[UIView alloc]initWithFrame:CGRectMake(0, 34, 300, 10)];
     space_container.backgroundColor=[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
     [mainView addSubview:space_container];
     
     UIView*container=[[UIView alloc]initWithFrame:CGRectMake(10, 50, 280, 300)];
     
     UIImageView*imageShow=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 280, self.view.frame.size.height-175)];
     imageShow.image=[UIImage imageNamed:@"KnoxInfo_Lightbox.png"];
     imageShow.contentMode=UIViewContentModeScaleAspectFit;
     [container addSubview:imageShow];
     [mainView addSubview:container];
     
     
     UIButton *btnLink=[UIButton buttonWithType:UIButtonTypeCustom];
     [btnLink setStyleClass:@"button_green_welcome"];
     btnLink.frame=CGRectMake(10,mainView.frame.size.height-55, 280, 50);
     [btnLink setTitle:@"Link Now" forState:UIControlStateNormal];
     [btnLink addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];
     [mainView addSubview:btnLink];
     
     UIButton *btnclose=[UIButton buttonWithType:UIButtonTypeCustom];
     btnclose.frame=CGRectMake(mainView.frame.size.width-27,head_container.frame.origin.y-13, 35, 35);
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