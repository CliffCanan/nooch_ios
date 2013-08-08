//
//  PXButtonViewController.m
//  PXCodeOnlyDemo
//
//  Created by Paul Colton on 10/22/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXButtonViewController.h"
#import <PXEngine/PXEngine.h>

@implementation PXButtonViewController
{
    UIButton *button;
    UIButton *button2;
}

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
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];

    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(72, 50, 175, 50);
    [button setTitle:@"Via Stylesheet" forState:UIControlStateNormal];

    // Here is how you set the styleId on your button
    button.styleId = @"myButton";
    
    [self.view addSubview:button];
    
    button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(72, 110, 175, 50);
    [button2 setTitle:@"Via Inline Style" forState:UIControlStateNormal];
    
    // Here we style the button inline
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithDictionary:@{
                        @"color"            : @"white",
                        @"background-color" : @"blue",
                        @"border-radius"    : @"10px",
                        @"border-color"     : @"red",
                        @"border-width"     : @"5px",
                             }];
    
    
    button2.styleCSS = [d toCSS];
    
    [self.view addSubview:button2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
