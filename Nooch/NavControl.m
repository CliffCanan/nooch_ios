//
//  NavControl.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "NavControl.h"
#import "LeftMenu.h"

@interface NavControl ()
@property(nonatomic,strong) UIButton *balance;
@end

@implementation NavControl

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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [[UINavigationBar appearance] setBackgroundColor:kNoochBlue];
    [[UINavigationBar appearance] setBarTintColor:kNoochBlue];
    
    UIView *hax = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 2)];
    [hax setBackgroundColor:kNoochBlue];
    [self.navigationBar addSubview:hax];
    
    LeftMenu *left_menu = [LeftMenu new];
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LeftMenu class]]) {
        self.slidingViewController.underLeftViewController  = left_menu;
    }
    [self.slidingViewController setAnchorRightRevealAmount:270.0f];
    
    [self.slidingViewController setAnchorLeftRevealAmount:270.0f];
    self.view.layer.shadowOpacity = 1.0f;
    self.view.layer.shadowRadius = 2.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
}

-(void)disable{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
}

-(void)reenable{
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}
-(void)reset
{
     [self.slidingViewController resetTopView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
