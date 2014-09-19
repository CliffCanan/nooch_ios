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
    page1.desc = @"Pay back a friend or send a payment request to anyone. Nooch makes money simple.";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];

    // PAGE 2
    EAIntroPage * page2 = [EAIntroPage page];
    page2.title = @"Link A Funding Source";
    page2.titleColor = Rgb2UIColor(31, 32, 33, 1);
    page2.titlePositionY = 114;

    page2.desc = @"No more long forms or waiting periods.  Just select your bank and sign in using your existing online banking credentials.";
    page2.descColor = Rgb2UIColor(31, 32, 33, 1);
    page2.descWidth = 300;
    page2.descPositionY = 93;

    page2.bgImage = [UIImage imageNamed:@"1_connect-bank-bg.png"];

    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connect-bank-img2"]];
    [page2.titleIconView setStyleClass:@"animate_bubble_tour"];
    page2.titleIconPositionY = 120;
    
    // PAGE 3
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Choose A Recipient";
    page3.titleColor = Rgb2UIColor(31, 32, 33, 1);
    page3.titlePositionY = 114;
    
    page3.desc = @"The people you Nooch most frequently will appear on the Home Screen. Send to anyone - even if they don't have Nooch.";
    page3.descColor = Rgb2UIColor(31, 32, 33, 1);
    page3.descWidth = 300;
    page3.descPositionY = 93;

    page3.bgImage = [UIImage imageNamed:@"2_select-recipient-bg.png"];

    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select-recipient-img"]];
    [page3.titleIconView setStyleClass:@"animate_bubble_tour"];
    page3.titleIconPositionY = 126;

    // PAGE 4
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"Search For Contacts";
    page4.titleColor = Rgb2UIColor(31, 32, 33, 1);

    page4.desc = @"Here you'll see recent contacts.  Or select this tab to see nearby Nooch users.";
    page4.descColor = Rgb2UIColor(31, 32, 33, 1);

    page4.bgImage = [UIImage imageNamed:@"bg1"];
    
    [page4.titleIconView setStyleClass:@"animate_bubble_tour"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];

    // PAGE 5
    EAIntroPage *page5 = [EAIntroPage page];
    page5.title = @"Send or Request";
    page5.titleColor = Rgb2UIColor(31, 32, 33, 1);
    page5.desc = @"Enter an amount.  You can also add a memo or picture to any transfer.  Then select 'Send' or 'Receive'.";
    page5.descColor = Rgb2UIColor(31, 32, 33, 1);
    page5.bgImage = [UIImage imageNamed:@"bg1"];
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
    

    EAIntroPage *page6 = [EAIntroPage page];
    page6.title = @"Transfer History";
    page6.titleColor = Rgb2UIColor(31, 32, 33, 1);
    page6.desc = @"See all your Nooch transfers and filter by type.  To see your transfers on a map, swipe <-- or tap the map icon in the navigation bar.";
    page6.descColor = Rgb2UIColor(31, 32, 33, 1);
    page6.bgImage = [UIImage imageNamed:@"bg1"];
    page6.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];

    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:CGRectMake(0, 0, 320, 500) andPages:@[page1,page2,page3,page4, page5,page6]];
    [intro setDelegate:self];
    [intro.pageControl setStyleClass:@"blue_text"];
    [intro.skipButton setStyleClass:@"blue_text"];
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
