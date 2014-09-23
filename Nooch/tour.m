//
//  tour.m
//  Nooch
//
//  Created by Cliff Canan on 9/17/14.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import "tour.h"
#import <QuartzCore/QuartzCore.h>
@interface tour () {
    UIView *rootView;
}
@end
@implementation tour

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
    rootView = self.navigationController.view;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    [super viewWillAppear:animated];
    
    self.trackedViewName = @"How Nooch Works Tour";
    
    [self showIntroWithCrossDissolve];
}

- (void)showIntroWithCrossDissolve
{
    // PAGE 1
    EAIntroPage * page1 = [EAIntroPage page];
    page1.title = @"Welcome To Nooch";
    page1.desc = @"Pay back a friend or send a payment request to anyone. Nooch makes money simple. The people you Nooch most frequently will appear on the Home Screen. Send to anyone - even if they don't have Nooch.";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];

    // PAGE 2
    EAIntroPage * page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"1connect-bank-bg.png"];

    page2.title = @"Link A Funding Source";
    page2.titlePositionY = 118;

    page2.desc = @"No more long forms or waiting periods.  Just select your bank and sign in using your existing online banking credentials.";
    page2.descWidth = 300;
    page2.descPositionY = page2.titlePositionY - 23;

    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connect-bank-img2"]];
    [page2.titleIconView setStyleClass:@"animate_bubble_tour"];
    page2.titleIconPositionY = 116;
    
    // PAGE 3
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"2select-recipient-bg.png"];

//    page3.title = @"Choose A Recipient";
    page3.titlePositionY = 118;
    
    page3.desc = @"To send or request money, select from a recent contact, find nearby Nooch users, or enter ANY email address.";
    page3.descWidth = 304;
    page3.descPositionY = page3.titlePositionY - 21;

    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select-recipient-img"]];
    [page3.titleIconView setStyleClass:@"animate_bubble_tour"];
    page3.titleIconPositionY = 155;

    // PAGE 4
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:@"3how-much-bg"];

    page4.title = @"Send or Request?";
    page4.titlePositionY = 112;

    page4.desc = @"Enter an amount, add a memo, or picture to any transfer.  Then tap 'Send' or 'Request'.";
    page4.descWidth = 300;
    page4.descPositionY = page4.titlePositionY - 24;
    
    [page4.titleIconView setStyleClass:@"animate_bubble_tour"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"how-much-img"]];
    page4.titleIconPositionY = 126;

    // PAGE 5
    EAIntroPage *page5 = [EAIntroPage page];
    page5.bgImage = [UIImage imageNamed:@"bg1"];

    page5.title = @"Transfer Details";
    
    page5.desc = @"";
    
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];

    EAIntroPage *page6 = [EAIntroPage page];
    page6.bgImage = [UIImage imageNamed:@"bg1"];

    page6.title = @"Transfer History";

    page6.desc = @"See all your Nooch transfers and filter by type.  To see your transfers on a map, swipe <-- or tap the map icon in the navigation bar.";

    page6.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:CGRectMake(0, 0, 320, 504) andPages:@[page1,page2,page3,page4, page5,page6]];
    [intro setDelegate:self];
    [intro.pageControl setStyleClass:@"reallyLight_gray"];
    [intro.skipButton setStyleClass:@"reallyLight_gray"];
    [intro setBgViewContentMode:UIViewContentModeScaleAspectFill];
    
    [intro showInView:self.view animateDuration:0.3];
}

- (void)introDidFinish:(EAIntroView *)introView
{
    NSLog(@"introDidFinish callback");
    self.navigationController.navigationBar.hidden = NO;
    
    [nav_ctrl popToRootViewControllerAnimated:YES];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
