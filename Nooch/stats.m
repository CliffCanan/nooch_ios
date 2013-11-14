//
//  stats.m
//  Nooch
//
//  Created by Preston Hults on 6/27/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "stats.h"

@interface stats ()

@end

@implementation stats

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
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    navBar.topItem.title = @"Account Statistics";
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
}

-(void)goBack{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    navBar = nil;
    leftNavButton = nil;
    [super viewDidUnload];
}
@end
