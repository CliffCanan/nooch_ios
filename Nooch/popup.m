//
//  popup.m
//  Nooch
//
//  Created by Preston Hults on 7/26/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "popup.h"

@interface popup ()

@end

@implementation popup

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

    UIImageView *background = [UIImageView new];
    [pup setFrame:CGRectMake(0, 0, 200, 300)];
    [background setFrame:pup.frame];
    [background setImage:[UIImage imageNamed:@"BackgroundMain.png"]];
    [pup addSubview:background];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 50)];
    [title setText:@"title"];
    [pup addSubview:title];

    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(25, 100, 150, 100)];
    [message setLineBreakMode:NSLineBreakByWordWrapping];
    [message setText:@"message"];
    [pup addSubview:message];

    UIButton *details = [[UIButton alloc] initWithFrame:CGRectMake(25, 250, 150, 50)];
    [details setTitle:@"View details" forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)slideIn:(id)obj{
    if ([obj class] == [UIView class]) {
        UIView *view = obj;
        CGRect frame = view.frame;
        frame.origin.x -= 320;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [view setFrame:frame];
        [UIView commitAnimations];
    }
}

-(void)slideOut:(id)obj{
    if ([obj class] == [UIView class]) {
        UIView *view = obj;
        CGRect frame = view.frame;
        frame.origin.x += 320;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [view setFrame:frame];
        [UIView commitAnimations];
    }
}

-(void)fadeIn:(id)obj{
    if ([obj class] == [UIView class]) {
        UIView *view = obj;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [view setAlpha:1.0];
        [UIView commitAnimations];
    }
}

-(void)fadeOut:(id)obj{
    if ([obj class] == [UIView class]) {
        UIView *view = obj;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [view setAlpha:0.0];
        [UIView commitAnimations];
    }
}


@end
