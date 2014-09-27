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
    page1.desc = @"Pay back a friend or send a payment request to anyone. The people you Nooch most frequently will appear on the Home Screen. Send to anyone - even if they don't have Nooch.";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];

    // PAGE 2
    EAIntroPage * page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"1_connectBank_bg.png"];

    page2.title = @"Link A Funding Source";
    page2.titlePositionY = 116;

    page2.desc = @"No long forms or waiting periods.  Just select your bank and sign in using your existing online banking credentials.";
    page2.descWidth = 300;
    page2.descPositionY = page2.titlePositionY - 23;

/*    UILabel * glyphLock = [UILabel new];
    [glyphLock setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
    [glyphLock setFrame:CGRectMake(147, 9, 14, 10)];
    [glyphLock setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-lock"]];
    [glyphLock setTextColor:[UIColor whiteColor]];
    [page2.desc addSubview:glyphLock];  */

    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connectBank_img"]];
    [page2.titleIconView setStyleClass:@"animate_bubble_tour"];
    page2.titleIconPositionY = 125;
    
    // PAGE 3
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"2_selectRecipient_bg"];

    // page3.title = @"Choose A Recipient";
    page3.titlePositionY = 116;
    
    page3.desc = @"To send or request money, select from a recent contact, find nearby Nooch users, or enter ANY email address.";
    page3.descWidth = 304;
    page3.descPositionY = page3.titlePositionY - 21;

    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectRecipient_img"]];
    page3.titleIconPositionY = 155;

    // PAGE 4
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:@"3_howMuch_bg"];

    page4.title = @"Send or Request?";
    page4.titlePositionY = 115;

    page4.desc = @"Enter an amount, add a memo, or picture to any transfer.  Then tap 'Send' or 'Request'.";
    page4.descWidth = 300;
    page4.descPositionY = page4.titlePositionY - 24;
    
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"howMuch_img"]];
    page4.titleIconPositionY = 120;

    // PAGE 5
    EAIntroPage *page5 = [EAIntroPage page];
    page5.bgImage = [UIImage imageNamed:@"4_history_bg"];

    page5.title = @"Detailed History";
    page5.titlePositionY = 115;
    
    page5.desc = @"See all your Nooch transfers and filter by type.  To see a map of your payments, swipe left or tap the map icon in the navigation bar.";
    page5.descWidth = 300;
    page5.descPositionY = page4.titlePositionY - 24;
    
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_img"]];
    page5.titleIconPositionY = 120;

    EAIntroPage *page6 = [EAIntroPage page];
    page6.bgImage = [UIImage imageNamed:@"bg1"];

    page6.title = @"Transfer History";

    page6.desc = @"";

    page6.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];
    page5.titleIconPositionY = 120;

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:CGRectMake(0, 0, 320, 504) andPages:@[page1,page2,page3,page4, page5]];
    [intro setDelegate:self];
    [intro.pageControl setStyleClass:@"reallyLight_gray"];
    [intro.skipButton setStyleClass:@"reallyLight_gray"];
    [intro setBgViewContentMode:UIViewContentModeScaleAspectFill];
    
    [intro showInView:self.view animateDuration:0.4];
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
