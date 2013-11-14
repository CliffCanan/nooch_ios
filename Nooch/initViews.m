//
//  initViews.m
//  Nooch
//
//  Created by Preston Hults on 5/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "initViews.h"

@interface initViews ()

@end

@implementation initViews

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"appSkel"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
