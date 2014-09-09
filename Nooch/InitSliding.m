//
//  InitSliding.m
//  Nooch
//
//  Created by crks on 10/2/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import "InitSliding.h"
#import "Home.h"

@interface InitSliding ()

@end

@implementation InitSliding

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:kNoochGrayDark];
    
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"flat_storyboard" bundle:nil];
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"nav_ctrl"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
