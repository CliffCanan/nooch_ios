//
//  NavControl.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    //[[UINavigationBar appearance] setBackgroundColor:kNoochBlue];
    [[UINavigationBar appearance] setBarTintColor:kNoochBlue];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    
    NSDictionary * titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSShadowAttributeName: shadowNavText};
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];

    UIView *hax = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
    [hax setBackgroundColor:kNoochBlue];
    [self.navigationBar addSubview:hax];

    LeftMenu *left_menu = [LeftMenu new];

    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LeftMenu class]])
    {
        self.slidingViewController.underLeftViewController = left_menu;
    }

    [self.slidingViewController setAnchorRightRevealAmount:270.0f];
    //[self.slidingViewController setAnchorLeftRevealAmount:270.0f];

    self.view.layer.shadowOpacity = 0.9f;
    self.view.layer.shadowRadius = 4.5f;
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
