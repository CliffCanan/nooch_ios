//
//  AppSkel.m
//  Nooch
//
//  Created by Preston Hults on 9/14/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "AppSkel.h"
#import "Tutorial1.h"
#import "AppDelegate.h"

@interface AppSkel ()

@end

@implementation AppSkel

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIImageView *leftShade = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 10, 600)];
    leftShade.image = [UIImage imageNamed:@"Shadow_LeftSidebar.png"];
    UIImageView *rightShade = [[UIImageView alloc] initWithFrame:CGRectMake(320, 0, 10, 600)];
    rightShade.image = [UIImage imageNamed:@"Shadow_RightSidebar.png"];
    [self.view addSubview:leftShade];
    [self.view addSubview:rightShade];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[sideMenu class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"sideMenu"];
    }
    [self.slidingViewController setAnchorRightRevealAmount:270.0f];

    if (![self.slidingViewController.underRightViewController isKindOfClass:[rightMenu class]]) {
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"rightMenu"];
    }
    [self.slidingViewController setAnchorLeftRevealAmount:270.0f];
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

-(void)disable{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
}

-(void)reenable{
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
