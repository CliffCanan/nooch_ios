//
//  socialNetworks.m
//  Nooch
//
//  Created by Preston Hults on 5/27/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "socialNetworks.h"

@interface socialNetworks ()

@end

@implementation socialNetworks

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
    [leftNavButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [connectFb addTarget:self action:@selector(connectToFB) forControlEvents:UIControlEventTouchUpInside];
    [dcFb addTarget:self action:@selector(disconnectFb) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];

    if([[[me usr] objectForKey:@"fbUID"] length] != 0){
        [fbConnectedView setAlpha:1.0f];
        [notConnectedView setAlpha:0.0f];
        if([[[me usr] objectForKey:@"fbSharing"] isEqualToString:@"false"]){
            [allowSharingSwitch setOn:NO];
        }else{
            [allowSharingSwitch setOn:YES];
        }
    }else{
        [fbConnectedView setAlpha:0.0f];
        [notConnectedView setAlpha:1.0f];
    }
    [fbConnectedView setAlpha:0.0f];
    [notConnectedView setAlpha:1.0f];
}

-(void)close{
    [navCtrl dismissViewControllerAnimated:YES completion:nil];
   // [navCtrl dismissModalViewControllerAnimated:YES];
    
}

- (void)disconnectFb {
    [[me usr] removeObjectForKey:@"fbUID"];
    fbUID = @"";
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    [notConnectedView setAlpha:1.0f];
    [fbConnectedView setAlpha:0.0f];
    [UIView commitAnimations];
}
- (void)fbSharing:(id)sender {
    UISwitch *onoff = (UISwitch *)sender;
    if(onoff.on){
        [[me usr] setObject:@"true" forKey:@"fbSharing"];
        serve *allowSharingConstantService=[serve new];
        allowSharingConstantService.tagName=@"Allow Sharing";
        allowSharingConstantService.Delegate=self;
        //[allowSharingConstantService ];
    }else{
        [[me usr] setObject:@"false" forKey:@"fbSharing"];
        serve *allowSharingConstantService=[serve new];
        allowSharingConstantService.tagName=@"Allow Sharing";
        allowSharingConstantService.Delegate=self;
        //[allowSharingConstantService methodNameAllowSharing:@"false"];
    }
    [[me usr] writeToFile:[core path:@"core"] atomically:YES];
}
- (void)connectToFB {
    if([fbUID length] != 0){
        [[me usr] setObject:fbUID forKey:@"fbUID"];
    }
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    navBar = nil;
    leftNavButton = nil;
    notConnectedView = nil;
    connectFb = nil;
    fbConnectedView = nil;
    dcFb = nil;
    allowSharingSwitch = nil;
    [super viewDidUnload];
}
@end
