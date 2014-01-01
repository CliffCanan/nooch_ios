//
//  CharityDetails.m
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "CharityDetails.h"
#import "Home.h"
#import "DonationAmount.h"

@interface CharityDetails ()
@property (nonatomic,strong) NSDictionary *charity;
@end

@implementation CharityDetails

- (id)initWithReceiver:(NSDictionary *)charity
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.charity = charity;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    [image setImage:[UIImage imageNamed:@"4k_image.png"]];
    [image setStyleClass:@"featured_nonprofit_banner_details"];
    [image setStyleCSS:@"background-image : url(4k_image.png)"];
    [self.view addSubview:image];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, 0, 0)];
    [info setNumberOfLines:0];
    [info setText:@"The 4K for Cancer is a program of the Ulman Cancer Fund for Young Adults. We are a non-profit organization dedicated to enhancing lives by supporting, educating and connecting young adults, and their loved ones, affected by cancer.  Since 2001, groups of college students have undertaken journeys across America with the goal of offering hope, inspiration and support to cancer communities along the way."];
    [info setStyleClass:@"nonprofit_details_desc"];
    [self.view addSubview:info];
    
    UIButton *web = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [web setTitle:@"" forState:UIControlStateNormal];
    [web setStyleClass:@"nonprofit_details_buttons"];
    [web setStyleClass:@"nonprofit_details_button_website"];
    [self.view addSubview:web];
    
    UIButton *fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fb setTitle:@"" forState:UIControlStateNormal];
    [fb setStyleClass:@"nonprofit_details_buttons"];
    [fb setStyleClass:@"nonprofit_details_button_fb"];
    [self.view addSubview:fb];
    
    UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setBackgroundImage:[UIImage imageNamed:@"twitter-icon.png"] forState:UIControlStateNormal];
    [twit setTitle:@"" forState:UIControlStateNormal];
    [twit setStyleClass:@"nonprofit_details_buttons"];
    [twit setStyleClass:@"nonprofit_details_button_twitter"];
    [self.view addSubview:twit];
    
    UIButton *youtube = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [youtube setBackgroundImage:[UIImage imageNamed:@"YouTube.png"] forState:UIControlStateNormal];
    [youtube setTitle:@"" forState:UIControlStateNormal];
    [youtube setStyleClass:@"nonprofit_details_buttons"];
    [youtube setStyleClass:@"nonprofit_details_button_youtube"];
    [self.view addSubview:youtube];
    
    UILabel *website = [UILabel new];
    [website setText:@"Website"];
    [website setStyleClass:@"nonprofit_details_buttons_labels"];
    [website setStyleClass:@"nonprofit_details_buttons_label_website"];
    [self.view addSubview:website];
    
    UILabel *facebook = [UILabel new];
    [facebook setText:@"Facebook"];
    [facebook setStyleClass:@"nonprofit_details_buttons_labels"];
    [facebook setStyleClass:@"nonprofit_details_buttons_label_fb"];
    [self.view addSubview:facebook];
    
    UILabel *twitter = [UILabel new];
    [twitter setText:@"Twitter"];
    [twitter setStyleClass:@"nonprofit_details_buttons_labels"];
    [twitter setStyleClass:@"nonprofit_details_buttons_label_twitter"];
    [self.view addSubview:twitter];
    
    UILabel *yt = [UILabel new];
    [yt setText:@"Youtube"];
    [yt setStyleClass:@"nonprofit_details_buttons_labels"];
    [yt setStyleClass:@"nonprofit_details_buttons_label_youtube"];
    [self.view addSubview:yt];
    
    UIButton *donate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [donate setTitle:@"Donate" forState:UIControlStateNormal];
    [donate setStyleClass:@"button_green"];
    [donate setStyleClass:@"nonprofit_details_donatebutton"];
    [donate addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:donate];
    dict=[[NSMutableDictionary alloc]init];
    dictToSend=[[NSMutableDictionary alloc]init];
    serve*serveOBJ=[serve new];
    serveOBJ.Delegate=self;
    serveOBJ.tagName=@"npDetail";
    [serveOBJ GetNonProfiltDetail:[dictnonprofitid valueForKey:@"id"]];
}

- (void)donate
{
    DonationAmount *da = [[DonationAmount alloc] initWithReceiver:self.charity];
    [self.navigationController pushViewController:da animated:YES];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
