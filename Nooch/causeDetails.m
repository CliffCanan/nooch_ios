//
//  causeDetails.m
//  Nooch
//
//  Created by Preston Hults on 6/27/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "causeDetails.h"

@interface causeDetails ()

@end

@implementation causeDetails

@synthesize site,fbpage,twitpage;

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
    [webview setAlpha:0.0];

    [charityWebsite addTarget:self action:@selector(website) forControlEvents:UIControlEventTouchUpInside];
    [charityFB addTarget:self action:@selector(facebook) forControlEvents:UIControlEventTouchUpInside];
    [charityTwitter addTarget:self action:@selector(twitter) forControlEvents:UIControlEventTouchUpInside];


    [header1 setFont:[core nFont:@"Bold" size:18]];
    [header2 setFont:[core nFont:@"Bold" size:18]];
    [header1 setTextColor:[core hexColor:@"5a538d"]];
    [header2 setTextColor:[core hexColor:@"5a538d"]];
    [charityInfo setTextColor:[core hexColor:@"40494c"]];

    [scroller setContentSize:CGSizeMake(320, 490)];
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    [leftNavButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [donateToCharity addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    [charityName setFont:[core nFont:@"Bold" size:24]];
    [charityInfo setFont:[core nFont:@"Medium" size:12]];
    [charityName setText:[NSString stringWithFormat:@"%@ %@",receiverFirst,receiverLast]];
    if ([receiverFirst isEqualToString:@"4K for"]){
        [charityPicture setImage:[UIImage imageNamed:@"4k_image.png"]];
        [charityInfo setText:@"The 4K for Cancer is a program of the Ulman Cancer Fund for Young Adults. We are a non-profit organization dedicated to enhancing lives by supporting, educating and connecting young adults, and their loved ones, affected by cancer.  Since 2001, groups of college students have undertaken journeys across America with the goal of offering hope, inspiration and support to cancer communities along the way."];
        site = @"http://www.4kforcancer.org";
        fbpage = @"https://www.facebook.com/4kforcancer";
        twitpage = @"https://twitter.com/4KforCancer";
    }
    else if ([receiverFirst isEqualToString:@"Grassroot"]){
        [charityPicture setImage:[UIImage imageNamed:@"GRS_image.png"]];
        [charityInfo setText:@"Mission: Grassroot Soccer uses the power of soccer to educate, inspire, and mobilize communities to stop the spread of HIV \n \nVision: A world mobilized through soccer to create an AIDS free generation. \n \nStrategy: To achieve our mission, we continuously improve our innovative HIV prevention and life-skills curriculum, share our program and concept effectively, and utilize the popularity of soccer to increase our impact."];

        site = @"http://www.grassrootsoccer.org";
        fbpage = @"https://www.facebook.com/GrassrootSoccer";
        twitpage = @"https://twitter.com/GrassrootSoccer";
    }else if ([receiverFirst isEqualToString:@"Boy Scouts"]){
        [charityPicture setImage:[UIImage imageNamed:@"BoyScouts_Banner.png"]];
        [charityInfo setText:@"For almost 100 years, Scouting has helped youth reach their full potential by instilling the values found in the Scout Oath & Scout Law. Scouting helps youth develop academic skills, self-confidence, ethics, leadership skills, & citizenship skills that influence their adult lives. Scouting also goes beyond that & encourages scouts to achieve a deeper appreciation for service to others in their community. The Cradle of Liberty council administers all Cub Scout Packs, Boy Scout Troops & Venture Crews in Southeastern PA."];

        site = @"http://www.scouting.org/";
        fbpage = @"https://www.facebook.com/pages/Boy-Scouts-of-America/113441755297";
        twitpage = @"https://twitter.com/boyscouts";
    }else if ([receiverFirst isEqualToString:@"Philadelphia Children's"]){
        [charityPicture setImage:[UIImage imageNamed:@"PCL_Banner.png"]];
        [charityInfo setText:@"All young people deserve bright dreams for the future. The Philadelphia Children's Foundation offers connections, programs & resources designed to help Philadelphia's youth face & conquer their challenges and inspire them to imagine all of life's possibilities."];

        site = @"http://www.philadelphiachildrensfoundation.org/";
        fbpage = @"https://www.facebook.com/pages/The-Philadelphia-Childrens-Foundation/114455791928182";
        twitpage = @"";
    }
    else if ([receiverFirst isEqualToString:@"Ulman Cancer"]){
        [charityPicture setImage:[UIImage imageNamed:@"Ulman_image.png"]];
        [charityInfo setText:@"A leading voice in the young adult cancer movement, we are working at a grassroots level to support, educate, connect and empower young adult cancer survivors.  Since inception in 1997, we have been working tirelessly at both the community level and with our national partners to raise awareness of the young adult cancer issue and ensure all young adults and families impacted by cancer have a voice and the resources necessary to thrive."];
        site = @"http://ulmanfund.org";
        fbpage = @"https://www.facebook.com/ulmancancerfund";
        twitpage = @"https://twitter.com/ulmancancerfnd";
    }else if ([receiverFirst isEqualToString:@"Rebecca Davis"]){
        [charityPicture setImage:[UIImage imageNamed:@"RDDC_Banner.jpg"]];
        [charityInfo setText:@"Working in post-conflict and developing countries, RDDC is a not-for-profit organization running dance and educational programs to improve the lives of street children and underserved youth.  Your tax-deductible donation will help a child receive basic IT training in Rwanda, a rice meal in Guinea, or a chance to participate in a peace-building dialogue in Bosnia-Herzegovina."];
        site = @"http://rebeccadavisdance.com";
        fbpage = @"https://www.facebook.com/RebeccaDavisDance";
        twitpage = @"https://twitter.com/RDDanceCo";
    }else if([receiverFirst isEqualToString:@"Boston One"]){
        [charityPicture setImage:[UIImage imageNamed:@"BostonFund_Banner.png"]];
        [charityInfo setText:@"n/a"];
        site = @"https://secure.onefundboston.org";
        fbpage = @"https://www.facebook.com/OneFundBoston";
        twitpage = @"https://twitter.com/OneFundBoston";
    }
}

-(void)donate{
    [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES];
}

-(void)cancel{
    [navCtrl popViewControllerAnimated:YES];
}

-(void)website{
    [leftNavButton removeTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(closeWeb) forControlEvents:UIControlEventTouchUpInside];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:site]]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3];
    [webview setAlpha:1.0];
    [UIView commitAnimations];
}

-(void)facebook{
    [leftNavButton removeTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(closeWeb) forControlEvents:UIControlEventTouchUpInside];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fbpage]]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3];
    [webview setAlpha:1.0];
    [UIView commitAnimations];
}

-(void)twitter{
    [leftNavButton removeTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(closeWeb) forControlEvents:UIControlEventTouchUpInside];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:twitpage]]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3];
    [webview setAlpha:1.0];
    [UIView commitAnimations];
}

-(void)closeWeb{
    [leftNavButton removeTarget:self action:@selector(closeWeb) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [webview setAlpha:0.0];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    charityPicture = nil;
    charityName = nil;
    charityInfo = nil;
    charityWebsite = nil;
    charityFB = nil;
    charityTwitter = nil;
    donateToCharity = nil;
    leftNavButton = nil;
    navBar = nil;
    scroller = nil;
    webview = nil;
    header2 = nil;
    header1 = nil;
    [super viewDidUnload];
}
@end
