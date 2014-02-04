//
//  Welcome.m
//  Nooch
//
//  Created by crks on 10/2/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    if (isSignup) {
        [self.navigationController setNavigationBarHidden:NO];
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                         }];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController.view addGestureRecognizer:self.navigationController.slidingViewController.panGesture];
        isSignup=NO;
    }
    
    
}
- (void)validate
{
    //navigate to settings
    
    [self.navigationController setNavigationBarHidden:NO];
    ProfileInfo *profile = [ProfileInfo new];
    isSignup=YES;
    //[nav_ctrl performSelector:@selector(reenable)];
    //  [nav_ctrl performSelector:@selector(ENABLE:) withObject:<#(id)#>]
    // [self.navigationController presentModalViewController:profile animated:YES];
    [self.navigationController presentViewController:profile animated:YES completion:Nil];
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
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 280, 200)];
    [prompt setTextColor:kNoochGrayDark]; [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setNumberOfLines:0];
    [prompt setFont:[UIFont systemFontOfSize:14]];
    [prompt setText:@"Your account has been created.\n\nBe sure to check your email for a message from us to confirm your email address.\n\nBefore you can start sending money you must validate your profile. Tap the green button to validate your profile now."]; [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setStyleClass:@"instruction_text"];
    CGRect frame = prompt.frame;
    frame.size.height += 50;
    [prompt setFrame:frame];
    [self.view addSubview:prompt];
    
    UIButton *enter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enter setBackgroundColor:kNoochGreen];
    [enter setTitle:@"Validate Profile" forState:UIControlStateNormal];
    [enter addTarget:self action:@selector(validate) forControlEvents:UIControlEventTouchUpInside];
    [enter setFrame:CGRectMake(10, 390, 300, 60)];
    [enter setStyleClass:@"button_green"];
    [self.view addSubview:enter];
    
    UIButton *later = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [later setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [later setBackgroundColor:[UIColor clearColor]];
    [later setTitle:@"I'll validate my profile later..." forState:UIControlStateNormal];
    [later addTarget:self action:@selector(later) forControlEvents:UIControlEventTouchUpInside];
    [later setFrame:CGRectMake(10, 460, 300, 60)];
    [later setStyleClass:@"label_small"];
    [self.view addSubview:later];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
