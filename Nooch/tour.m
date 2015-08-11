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

    page1.title = NSLocalizedString(@"Tour_Page1Title", @"Tour 'Welcome To Nooch' page Title");
    page1.titlePositionY = 430;

    page1.desc = NSLocalizedString(@"Tour_Page1Desc", @"Tour page 1 Description");
    page1.descWidth = 302;
    page1.descPositionY = 126;

    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-circled"]];
    [page1.titleIconView setStyleClass:@"animate_bubble_slow"];
    page1.titleIconPositionY = 118;

    // PAGE 2
    EAIntroPage * page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"1_connectBank_bg.png"];

    page2.title = NSLocalizedString(@"Tour_Page2Title", @"Tour 'Link A Funding Source' page Title");
    page2.titlePositionY = 120;

    page2.desc = NSLocalizedString(@"Tour_Page2Desc", @"Tour page 2 Description");
    page2.descWidth = 302;
    page2.descPositionY = page2.titlePositionY - 26;

    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connectBank-circled"]];
    [page2.titleIconView setStyleClass:@"animate_bubble_tour"];
    page2.titleIconPositionY = 125;
    
    // PAGE 3
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"2_selectRecipient_bg"];

    page3.titlePositionY = 116;

    page3.desc = NSLocalizedString(@"Tour_Page3Desc", @"Tour page 3 Description");
    page3.descWidth = 304;
    page3.descPositionY = page3.titlePositionY - 21;

    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectRec-circled"]];
    page3.titleIconPositionY = 155;

    // PAGE 4
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:@"3_howMuch_bg"];

    page4.title = NSLocalizedString(@"Tour_Page4Title", @"Tour 'Send or Request?' page Title");
    page4.titlePositionY = 120;

    page4.desc = NSLocalizedString(@"Tour_Page4Desc", @"Tour page 4 Description");
    page4.descWidth = 300;
    page4.descPositionY = page4.titlePositionY - 26;
    
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HowMuch_tour"]];
    page4.titleIconPositionY = 120;

    // PAGE 5
    EAIntroPage *page5 = [EAIntroPage page];
    page5.bgImage = [UIImage imageNamed:@"4_history_bg"];

    page5.title = NSLocalizedString(@"Tour_Page5Title", @"Tour 'Transaction History' page Title");
    page5.titlePositionY = 120;
    
    page5.desc = NSLocalizedString(@"Tour_Page5Desc", @"Tour page 5 Description");
    page5.descWidth = 300;
    page5.descPositionY = page5.titlePositionY - 26;
    
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HistoryPending"]];
    page5.titleIconPositionY = 120;

    EAIntroPage *page6 = [EAIntroPage page];
    page6.bgImage = [UIImage imageNamed:@"Tour_stats_bg"];

    page6.title = NSLocalizedString(@"Tour_Page6Title", @"Tour 'Stats & Analytics' page Title");
    page6.titlePositionY = 120;

    page6.desc = NSLocalizedString(@"Tour_Page6Desc", @"Tour page 6 Description");
    page6.descWidth = 300;
    page6.descPositionY = page6.titlePositionY - 26;

    page6.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StatsCircled"]];
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

    intro = [[EAIntroView alloc] initWithFrame:CGRectMake(0, 0, 320, 504) andPages:@[page1,page2,page3,page4,page5,page6]];
    [intro setDelegate:self];
    [intro.skipButton setStyleClass:@"reallyLight_gray"];
    [intro setBgViewContentMode:UIViewContentModeScaleAspectFill];

    intro.showSkipButtonOnlyOnLastPage = false;
    [intro.skipButton setTitle:NSLocalizedString(@"Tour_SkipBtn", @"Tour 'Skip' Button Text") forState:UIControlStateNormal];
    //[intro setSkipButtonY:340.0f];

    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        intro.swipeToExit = true;
    }

    [intro showInView:self.view animateDuration:0.3];
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex
{
    if (pageIndex == 5)
    {
        [intro.skipButton setTitle:NSLocalizedString(@"Tour_DoneBtn", @"Tour 'Done' Button Text") forState:UIControlStateNormal];
    }
    else
    {
        [intro.skipButton setTitle:NSLocalizedString(@"Tour_SkipBtn2", @"Tour 'Skip' Button Text (2nd)") forState:UIControlStateNormal];
    }
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex{
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex{
}

- (void)introDidFinish:(EAIntroView *)introView
{
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