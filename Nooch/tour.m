//
//  tour.m
//  Nooch
//
//  Created by Cliff Canan on 9/17/14.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
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
    
    self.screenName = @"How Nooch Works Tour";
    
    [self showIntroWithCrossDissolve];
}

- (void)showIntroWithCrossDissolve
{
    // PAGE 1
    EAIntroPage * page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:@"0_home-bg"];

    page1.title = @"Welcome To Nooch";
    page1.titlePositionY = 428;

    page1.desc = @"Pay back a friend or send a payment request to anyone. The people you Nooch most will appear on the Home Screen. Send to anyone - even if they don't have Nooch.";
    page1.descWidth = 302;
    page1.descPositionY = 126;

    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-circled"]];
    [page1.titleIconView setStyleClass:@"animate_bubble_slow"];
    page1.titleIconPositionY = 118;

    // PAGE 2
    EAIntroPage * page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"1_connectBank_bg.png"];

    page2.title = @"Link A Funding Source";
    page2.titlePositionY = 116;

    page2.desc = @"No long forms or waiting periods.  Just select your bank and sign in using your existing online banking credentials.";
    page2.descWidth = 302;
    page2.descPositionY = page2.titlePositionY - 23;

    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connectBank-circled"]];
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

    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectRecipient-Circled"]];
    page3.titleIconPositionY = 155;

    // PAGE 4
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:@"3_howMuch_bg"];

    page4.title = @"Send or Request?";
    page4.titlePositionY = 118;

    page4.desc = @"Enter an amount, add a memo, or picture to any transfer.  Then tap 'Send' or 'Request'.";
    page4.descWidth = 300;
    page4.descPositionY = page4.titlePositionY - 24;
    
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"howMuch_img"]];
    page4.titleIconPositionY = 120;

    // PAGE 5
    EAIntroPage *page5 = [EAIntroPage page];
    page5.bgImage = [UIImage imageNamed:@"4_history_bg"];

    page5.title = @"Transfer History";
    page5.titlePositionY = 118;
    
    page5.desc = @"See all your Nooch transfers and filter by type.  To see a map of your payments, swipe left or tap the map icon in the navigation bar.";
    page5.descWidth = 300;
    page5.descPositionY = page5.titlePositionY - 24;
    
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_img"]];
    page5.titleIconPositionY = 120;

    EAIntroPage *page6 = [EAIntroPage page];
    page6.bgImage = [UIImage imageNamed:@"bg1"];

    page6.title = @"Detailed History";
    page6.titlePositionY = 118;

    page6.desc = @"";
    page6.descWidth = 300;
    page6.descPositionY = page6.titlePositionY - 24;

    page6.titleIconView = [[UIImageView alloc] initWithImage:nil];
    page6.titleIconPositionY = 120;

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        page1.descPositionY = 136;
        page2.titlePositionY = 426;
        page2.descPositionY = 120;
        page3.descPositionY = 103;

        page4.titlePositionY = 428;
        page4.descPositionY = 118;
        page4.titleIconPositionY = 125;

        page5.titlePositionY = 418;
        page5.descPositionY = 124;
        page5.titleIconPositionY = 130;
    }

    EAIntroView * intro = [[EAIntroView alloc] initWithFrame:CGRectMake(0, 0, 320, 504) andPages:@[page1,page2,page3,page4,page5]];
    [intro setDelegate:self];
    [intro.skipButton setStyleClass:@"reallyLight_gray"];
    [intro setBgViewContentMode:UIViewContentModeScaleAspectFill];
    intro.showSkipButtonOnlyOnLastPage = false;

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        intro.swipeToExit = true;
    }

    [intro showInView:self.view animateDuration:0.4];
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{
}

- (void)introDidFinish:(EAIntroView *)introView
{
    NSLog(@"introDidFinish callback");
    self.navigationController.navigationBar.hidden = NO;
    
    [nav_ctrl popViewControllerAnimated:YES];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
