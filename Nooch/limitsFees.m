//
//  limitsFees.m
//  Nooch
//
//  Created by Preston Hults on 6/24/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "limitsFees.h"

@interface limitsFees ()

@end

@implementation limitsFees

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
    navBar.topItem.title = @"Limits & Fees";
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    scroller.contentSize = CGSizeMake(320,615);
}

-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    navBar = nil;
    leftNavButton = nil;
    scroller = nil;
    [super viewDidUnload];
}
@end
