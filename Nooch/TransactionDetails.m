//  TransactionDetails.m
//  Nooch
//
//  Created by crks on 10/4/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "TransactionDetails.h"
#import <QuartzCore/QuartzCore.h>
#import "Home.h"
#import "UIImageView+WebCache.h"
#import "ECSlidingViewController.h"
#import "HowMuch.h"
#import "TransferPIN.h"
#import "SelectRecipient.h"
#import "ProfileInfo.h"
#import "DisputeDetail.h"

@interface TransactionDetails ()
@property (nonatomic,strong) NSDictionary *trans;
@property(nonatomic,strong) NSMutableData *responseData;
@end

@implementation TransactionDetails

- (id)initWithData:(NSDictionary *)trans {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.trans = trans;
        NSLog(@"%@",self.trans);
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.trackedViewName = @"TransactionDetail Screen";
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    UIActivityIndicatorView*act=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [act setFrame:CGRectMake(14, 5, 20, 20)];
    [act startAnimating];

    [self.view setBackgroundColor:[UIColor whiteColor]];

	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Transfer Details"];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    UILabel *other_party = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 60)];  // Other user's NAME
    UIImageView *user_picture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 27, 78, 78)];  // Other user's PICTURE
//    user_picture.layer.borderWidth = 1;
//    user_picture.layer.borderColor = kNoochGrayDark.CGColor;
    user_picture.layer.cornerRadius = 39;
    user_picture.clipsToBounds = YES;

    if( [[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Invite"] ||         // Transfers to Non-Noochers
        [[self.trans valueForKey:@"TransactionType"]isEqualToString:@"InviteRequest"] ||  // Requests to Non-Noochers coming straight from PIN screen
	   ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"] &&
       !([self.trans valueForKey:@"InvitationSentTo"] == NULL || [[self.trans objectForKey:@"InvitationSentTo"] isKindOfClass:[NSNull class]])))
    {
        [other_party setStyleClass:@"details_othername_nonnooch"];
        [other_party setText:[self.trans objectForKey:@"InvitationSentTo"]];
        [user_picture setImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    else // transfers with an existing Nooch user
    {
        [other_party setText:[[self.trans objectForKey:@"Name"] capitalizedString]];
        [other_party setStyleClass:@"details_othername"];
        [user_picture setImageWithURL:[NSURL URLWithString:[self.trans objectForKey:@"Photo"]]
             placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    [self.view addSubview:other_party];
    [self.view addSubview:user_picture];

	
	// SET TEXT LABEL ABOVE OTHER USER'S NAME
    UILabel *payment = [UILabel new];
    [payment setStyleClass:@"details_intro"];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(32, 63, 63, .35);
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    NSDictionary * textAttributes =
    @{NSShadowAttributeName: shadow };
    
    if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Transfer"])
    {
	    if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]]) {
	        payment.attributedText = [[NSAttributedString alloc] initWithString:@"Paid To:"
                                                                   attributes:textAttributes];
            [payment setStyleClass:@"details_intro_red"];
        }
		else {
            payment.attributedText = [[NSAttributedString alloc] initWithString:@"Payment From:"
                                                                   attributes:textAttributes];
            [payment setStyleClass:@"details_intro_green"];
        }
	}
    else if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"])
    {
        if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"RecepientId"]]) {
            payment.attributedText = [[NSAttributedString alloc] initWithString:@"Request Sent To:"
                                                                   attributes:textAttributes];
        }
        else {
            payment.attributedText = [[NSAttributedString alloc] initWithString:@"Request From:"
                                                                   attributes:textAttributes];
        }
        [payment setStyleClass:@"details_intro_blue"];
    }
    else if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Invite"])
    {
        payment.attributedText = [[NSAttributedString alloc] initWithString:@"Invite Sent To:"
                                                               attributes:textAttributes];
        [payment setStyleClass:@"details_intro_green"];
    }
    else if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"InviteRequest"] ||
	         ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"] && [[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"RecepientId"]]))
    {
        payment.attributedText = [[NSAttributedString alloc] initWithString:@"Request Sent To:"
                                                               attributes:textAttributes];
        [payment setStyleClass:@"details_intro_blue"];
    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Disputed"])
    {
        payment.attributedText = [[NSAttributedString alloc] initWithString:@"Disputed Transfer:"
                                                               attributes:textAttributes];
        [payment setStyleClass:@"details_intro_red"];
    }
    [self.view addSubview:payment];


    amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 60)];
    [amount setStyleClass:@"details_amount"];
    [amount setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:amount];

    UILabel *memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 116, 320, 60)];
    if (![[self.trans valueForKey:@"Memo"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"Memo"]!=NULL)
    {
        if ([[self.trans valueForKey:@"Memo"] length]==0 || [[self.trans valueForKey:@"Memo"] isEqualToString:@"\"\""])
        {
            memo.text=@"No memo attached";
        } 
        else
            [memo setText:[NSString stringWithFormat:@"\"%@\"",[self.trans valueForKey:@"Memo"]]];
    }
    else  {
        memo.text=@"No memo attached";
    }

    memo.numberOfLines=2;
    [memo setStyleClass:@"details_label_memo"];
    [memo setStyleClass:@"blue_text"];
    [memo setStyleClass:@"italic_font"];
    [self.view addSubview:memo];

        
    UIButton *pay_back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pay_back setTitle:@"" forState:UIControlStateNormal];
    [pay_back setStyleCSS:@"background-image : url(pay-back-icon.png)"];
    [pay_back setStyleId:@"details_payback"];
    [pay_back addTarget:self action:@selector(pay_back) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
            [pay_back setStyleClass:@"details_buttons_4"];
        } 
    else {
        [pay_back setStyleClass:@"details_buttons"];
    }

    UILabel *pay_text = [UILabel new];
    [pay_text setFrame:pay_back.frame];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [pay_text setStyleClass:@"details_buttons_labels_4"];
    }
    else {
        [pay_text setStyleClass:@"details_buttons_labels"];
    }
    [pay_text setText:@"Pay Back"];

    UIButton *fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fb setTitle:@"" forState:UIControlStateNormal];
    [fb setStyleCSS:@"background-image : url(fb-icon-90x90.png)"];
    if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Donation"]) {
        [fb setStyleId:@"details_fb_donate"];
    }
    else {
        [fb setStyleId:@"details_fb"];
    }
    [fb addTarget:self action:@selector(post_to_fb) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [fb setStyleClass:@"details_buttons_4"];
    }
    else {
        [fb setStyleClass:@"details_buttons"];
    }

    UILabel *fb_text = [UILabel new];
    [fb_text setFrame:fb.frame];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
            [fb_text setStyleClass:@"details_buttons_labels_4"];
        } 
    else {
        [fb_text setStyleClass:@"details_buttons_labels"];
    }
    [fb_text setText:@"Share"];

    UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setTitle:@"" forState:UIControlStateNormal];
    [twit setStyleCSS:@"background-image : url(twitter-icon.png)"];
    if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Donation"]) {
        [twit setStyleId:@"details_twit_donate"];
    }
    else {
        [twit setStyleId:@"details_twit"];
    }
    [twit addTarget:self action:@selector(post_to_twitter) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [twit setStyleClass:@"details_buttons_4"];
    }
    else {
        [twit setStyleClass:@"details_buttons"];
    }

    UILabel *twit_text = [UILabel new];
    [twit_text setFrame:twit.frame];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [twit_text setStyleClass:@"details_buttons_labels_4"];
    }
    else {
        [twit_text setStyleClass:@"details_buttons_labels"];
    }
    [twit_text setText:@"Tweet"];

    UIButton *disp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [disp setTitle:@"" forState:UIControlStateNormal];
    [disp setStyleCSS:@"background-image : url(dispute-icon.png)"];
    if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Donation"]) {
        [disp setStyleId:@"details_disp_donate"];
    }
    else
        [disp setStyleId:@"details_disp"];
        
    [disp addTarget:self action:@selector(dispute) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [disp setStyleClass:@"details_buttons_4"];
    }
    else {
        [disp setStyleClass:@"details_buttons"];
    }

    UILabel *disp_text = [UILabel new];
    [disp_text setFrame:disp.frame];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [disp_text setStyleClass:@"details_buttons_labels_4"];
    }
    else {
        [disp_text setStyleClass:@"details_buttons_labels"];
    }
    [disp_text setText:@"Dispute"];
        
    if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Request"])
    {
        // Pay & Cancel Buttons
        UIButton *pay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [pay setStyleClass:@"details_button_left"];
        [pay setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.3) forState:UIControlStateNormal];
        pay.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);

        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancel setTitleShadowColor:Rgb2UIColor(36, 22, 19, 0.3) forState:UIControlStateNormal];
        cancel.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);

        UIButton *remind = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [remind setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.3) forState:UIControlStateNormal];
        remind.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);

        if ( ![[self.trans objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] &&
             ![[self.trans objectForKey:@"TransactionStatus"]isEqualToString:@"Rejected"])
        {
            if ([[self.trans objectForKey:@"RecepientId"] isEqualToString:[user objectForKey:@"MemberId"]])
            {
                [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                [cancel setStyleClass:@"details_button_right"];
                [cancel setTag:13];
                [cancel setEnabled:YES];
                [cancel addTarget:self action:@selector(cancel_request) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:cancel];
                [remind setTitle:@"Remind" forState:UIControlStateNormal];
                [remind setStyleClass:@"details_button_remind"];
                [remind setTag:14];
                [remind setEnabled:YES];
                [remind addTarget:self action:@selector(remind_friend) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:remind];
            }
            else {
                [cancel setStyleClass:@"details_button_right"];
                [pay setTitle:@"Pay" forState:UIControlStateNormal];
                [pay addTarget:self action:@selector(fulfill_request) forControlEvents:UIControlEventTouchUpInside];
                [cancel setTitle:@"Decline" forState:UIControlStateNormal];
                [cancel addTarget:self action:@selector(decline_request) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:pay]; [self.view addSubview:cancel];
            }
        }
    }

    else if ( [[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
              [[self.trans valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"] )
    {
        if ([[self.trans objectForKey:@"RecepientId"] isEqualToString:[user objectForKey:@"MemberId"]])
        {
            UIButton *cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [cancel setTitleShadowColor:Rgb2UIColor(36, 22, 19, 0.3) forState:UIControlStateNormal];
            cancel.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
            [cancel setStyleClass:@"details_button_right"];
            [cancel setTag:13];
            [cancel setEnabled:YES];
            [cancel addTarget:self action:@selector(cancel_invite) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:cancel];
                
            UIButton *remind = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [remind setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.3) forState:UIControlStateNormal];
            remind.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [remind setTitle:@"Remind" forState:UIControlStateNormal];
            [remind setStyleClass:@"details_button_remind"];
            [remind setTag:14];
            [remind setEnabled:YES];
            [remind addTarget:self action:@selector(remind_friend) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:remind];
        }
    }

    else if ([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Transfer"])
    {
            
        if ([[self.trans objectForKey:@"MemberId"] isEqualToString:[user objectForKey:@"MemberId"]]) {
            [self.view addSubview:disp];
            [self.view addSubview:disp_text];
        }
        else {
            [fb setStyleId:@"details_twit_donate"];
            [fb_text setFrame:fb.frame];
            [twit setStyleId:@"details_disp"];
            [twit_text setFrame:twit.frame];
        }
        [self.view addSubview:pay_back];
        [self.view addSubview:pay_text];
        [self.view addSubview:fb];
        [self.view addSubview:fb_text];
        [self.view addSubview:twit];
        [self.view addSubview:twit_text];
    }
    
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [scroll setDelegate:self];
        [scroll setContentSize:CGSizeMake(320, 550)];
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
            [scroll addSubview:subview];
        }
        [self.view addSubview:scroll];
    }
    
    blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
    [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    UIActivityIndicatorView*actv=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2)-5, 40, 40)];
    [actv startAnimating];
    [blankView addSubview:actv];
    [self.view addSubview:blankView];
    [self.view bringSubviewToFront:blankView];
    serve *serveOBJ=[serve new ];
    serveOBJ.tagName=@"tranDetail";
    [serveOBJ setDelegate:self];
    [serveOBJ GetTransactionDetail:[self.trans valueForKey:@"TransactionId"]];
}

-(void)remind_friend{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send Reminder" message:@"Do you want to send a reminder about this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
   
    [av setTag:1012];
    [av show];
}

-(void)Map_LightBox
{
    overlay=[[UIView alloc]init];
    overlay.frame=CGRectMake(0, 0, 320, 568);
    overlay.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [UIView transitionWithView:self.navigationController.view
                    duration:0.5
                    options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.navigationController.view addSubview:overlay];
                    }
                    completion:nil];

    mainView=[[UIView alloc]init];
    mainView.layer.cornerRadius=5;
    mapView_.layer.borderColor=[[UIColor blackColor]CGColor];
    mapView_.layer.borderWidth=1;
    
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        mainView.frame = CGRectMake(10, 30, 300, 443);
    }
    else {
        mainView.frame = CGRectMake(10, 70, 300, self.view.frame.size.height-35);
    }
    mainView.backgroundColor=[UIColor whiteColor];
    
    [overlay addSubview:mainView];
    mainView.layer.masksToBounds = NO;
    mainView.layer.cornerRadius = 5;
    mainView.layer.shadowOffset = CGSizeMake(0, 2);
    mainView.layer.shadowRadius = 5;
    mainView.layer.shadowOpacity = 0.65;
    
    UIView*head_container=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 44)];
    head_container.backgroundColor=[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;

    UILabel*title=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 300, 30)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Transfer Location"];
    [title setStyleClass:@"lightbox_title"];
    [mainView addSubview:title];

    UIView*space_container=[[UIView alloc]initWithFrame:CGRectMake(0, 34, 300, 10)];
    space_container.backgroundColor=[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];   
    
    UIView*map_container=[[UIView alloc]initWithFrame:CGRectMake(10, 50, 280, 300)];
    map_container.backgroundColor=[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:map_container];
    
    map_container.layer.cornerRadius=5;
    map_container.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    map_container.layer.borderWidth=1;
    map_container.clipsToBounds=YES;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:10];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(11, 51, 278, 298) camera:camera];
    [mapView_ setFrame:CGRectMake(11, 51, 278, 298)];
    [mainView addSubview:mapView_];
    mapView_.layer.cornerRadius=5;
    mapView_.clipsToBounds=YES;
    mapView_.myLocationEnabled = YES;
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(lat, lon);
    marker.map = mapView_;
    
    UIView*desc_container=[[UIView alloc]initWithFrame:CGRectMake(10, 356, 280, 36)];
    desc_container.backgroundColor=[UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0];
    desc_container.layer.cornerRadius = 5;
    desc_container.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    desc_container.layer.borderWidth=0.5;
    [mainView addSubview:desc_container];
    
    UILabel*desc=[[UILabel alloc]initWithFrame:CGRectMake(5, 0, 270, 36)];
    [desc setBackgroundColor:[UIColor clearColor]];
    desc.text=@"This shows the location of the user who initiated the transfer.";
    desc.font=[UIFont fontWithName:@"Roboto" size:12];
    [desc setStyleId:@"mapLightBox_paraText"];
    desc.numberOfLines=0;
    [desc_container addSubview:desc];

    UIView*line_container=[[UIView alloc]initWithFrame:CGRectMake(0, desc_container.frame.origin.y+desc_container.frame.size.height+6, 300, 1)];
    line_container.backgroundColor=[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0];
    [mainView addSubview:line_container];
    
    UIButton *btnclose=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnclose setTitle:@"Close" forState:UIControlStateNormal];
    [btnclose setTitleShadowColor:Rgb2UIColor(26, 32, 38, 0.4) forState:UIControlStateNormal];
    btnclose.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [btnclose addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [btnclose setStyleClass:@"button_blue_closeLightbox_smscrn"];
    }
    else {
        [btnclose setStyleClass:@"button_blue_closeLightbox"];
    }
    [mainView addSubview:btnclose];

}
-(void)close_lightBox{
    [overlay removeFromSuperview];
}
-(void) cancel_invite {
    serve *canc = [serve new];
    [canc setTagName:@"cancel_invite"];
    [canc setDelegate:self];
    [canc cancel_invite:self.trans[@"TransactionId"]];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result) {
        case MFMailComposeResultCancelled:    
            NSLog(@"Mail cancelled");
            break;
        
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [alert setTitle:@"Email Draft Saved"];
            [alert show];
            break;

        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"Email Sent Successfully"];
            [alert show];
            break;

        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) fulfill_request {
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Suspended" message:@"Your account has been suspended for 24 hours from now. Please email support@nooch.com if you believe this was a mistake and we will be glad to help." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
        [alert setTag:50];
        [alert show];
        return;
    }
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Email Verification Needed" message:@"Please click the link sent to your email to verify your email address." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Profile Not Complete" message:@"Please validate your profile by completing all fields. This helps us keep Nooch safe!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }
    if ( ![[[NSUserDefaults standardUserDefaults]
            objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Please Link A Bank Account" message:@"Before you can make any transfer you must attach a bank account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];

        [set show];
        return;
    }

    NSMutableDictionary *input = [self.trans mutableCopy];
    [input setValue:@"accept" forKey:@"response"];
    [[assist shared]setRequestMultiple:NO];
    TransferPIN *trans = [[TransferPIN alloc] initWithReceiver:input type:@"requestRespond" amount:[[self.trans objectForKey:@"Amount"] floatValue]];
    [nav_ctrl pushViewController:trans animated:YES];
}

- (void) decline_request {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to reject this request?" delegate:self cancelButtonTitle:@"Yes - Reject" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:1011];
    //    NSMutableDictionary *input = [self.trans mutableCopy];
    //    [input setValue:@"deny" forKey:@"response"];
    //    TransferPIN *trans = [[TransferPIN alloc] initWithReceiver:input type:@"requestRespond" amount:[[self.trans objectForKey:@"Amount"] floatValue]];
    //    [nav_ctrl pushViewController:trans animated:YES];
}

- (void) cancel_request {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to cancel this request?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:1010];
}

- (void) pay_back {
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];

    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Account Suspended" message:@"Your account has been suspended for 24 hours from now. Please email support@nooch.com if you believe this was a mistake and we will be glad to help." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
        [alert setTag:50];
        [alert show];
        return;
    }
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Email Verification Needed" message:@"Please click the link sent to your email to verify your email address." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Profile Not Complete" message:@"Please validate your profile by completing all fields. This helps us keep Nooch safe!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }
    if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Phone Not Verified" message:@"Please validate your phone number before sending money." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil , nil];
        [alert show];
        return;
    }
    if ( ![[[NSUserDefaults standardUserDefaults]
            objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Funding Source Needed" message:@"Before you can send or receive money, you must add a bank account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [set show];
        return;
    }

    NSMutableDictionary *input = [self.trans mutableCopy];
    if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]]) {
        NSString*MemberId=[input valueForKey:@"RecepientId"];
        [input setObject:MemberId forKey:@"MemberId"];
    }

    isPayBack=YES;
    [[assist shared]setRequestMultiple:NO];
    isEmailEntry=NO;
    // NSLog(@"%@",self.trans);
    HowMuch *payback = [[HowMuch alloc] initWithReceiver:input];
    [self.navigationController pushViewController:payback animated:YES];
}

- (void) post_to_fb {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        me.accountStore = [[ACAccountStore alloc] init];
        ACAccountType *facebookAccountType = [me.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        me.facebookAccount = nil;

        NSDictionary *options = @{
                ACFacebookAppIdKey: @"198279616971457",
                ACFacebookPermissionsKey: @[@"publish_stream"],
                ACFacebookAudienceKey: ACFacebookAudienceFriends
        };

        [me.accountStore requestAccessToAccountsWithType:facebookAccountType
                options:options completion:^(BOOL granted, NSError *e)
        {
             if (granted) {
                 NSArray *accounts = [me.accountStore accountsWithAccountType:facebookAccountType];
                 me.facebookAccount = [accounts lastObject];
                 [self performSelectorOnMainThread:@selector(post) withObject:nil waitUntilDone:NO];
             }
             else {
                 // Handle Failure
                 NSLog(@"fbposting not allowed");
             }
         }];
    }
}

- (void) post_to_twitter {
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [controller setInitialText:[NSString stringWithFormat:@"I just Nooch'ed %@!",[self.trans objectForKey:@"Name"]]];
    [controller addURL:[NSURL URLWithString:@"https://www.nooch.com"]];
    [self presentViewController:controller animated:YES completion:Nil];
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        NSString *output= nil;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog (@"cancelled");
                break;
            case SLComposeViewControllerResultDone:
                output= @"Post Succesfull";
                NSLog (@"success");
                break;
            default:
                break;
        }
        if ([output isEqualToString:@"Post Succesfull"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert setTag:11];
        }
        [controller dismissViewControllerAnimated:YES completion:Nil];
    };
    controller.completionHandler =myBlock;
}

-(void)post {
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"I just Nooch'ed %@!",[self.trans objectForKey:@"Name"]]];
    [controller addURL:[NSURL URLWithString:@"https://www.nooch.com"]];
    [self presentViewController:controller animated:YES completion:Nil];

    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        NSString *output= nil;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output= @"Action Cancelled";
                NSLog (@"cancelled");
                break;
            case SLComposeViewControllerResultDone:
                output= @"Post Succesfull";
                NSLog (@"success");
                break;
            default:
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [controller dismissViewControllerAnimated:YES completion:Nil];
        [self performSelectorOnMainThread:@selector(finishedPosting) withObject:nil waitUntilDone:NO];
    };
    controller.completionHandler =myBlock;
}
-(void)finishedPosting {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) dispute
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Confirm Dispute" message:@"To protect your money, if you dispute a transfer your Nooch account will be temporarily suspended while we investigate." delegate:self cancelButtonTitle:@"Yes - Dispute" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:1];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1012 && buttonIndex==0)  // REMIND
    {
        NSString * memId1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"];
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"remind";
        [serveObj SendReminderToRecepient:[self.trans valueForKey:@"TransactionId"] memberId:memId1];
    }
    
    else if (alertView.tag==147 && buttonIndex==1)  // PROFILE INCOMPLETE, GO TO PROFILE
    {
        ProfileInfo *prof = [ProfileInfo new];
        isProfileOpenFromSideBar=NO;
        [self.navigationController pushViewController:prof animated:YES];
    }
    
    else if (alertView.tag == 1 && buttonIndex == 0)  // DISPUTE
    {
        self.responseData = [NSMutableData data];
        NSMutableDictionary*dict=[[NSMutableDictionary alloc] init];
        NSString * memId = [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"];
        [dict setObject :memId forKey:@"MemberId"];
        [dict setObject:[self.trans valueForKey:@"RecepientId"] forKey:@"RecepientId"];
        [dict setObject:[self.trans valueForKey:@"TransactionId"] forKey:@"TransactionId"];
        [dict setObject:@"SENT" forKey:@"ListType"];
        //NSLog(@"%@",dict);
        serve*serveobj=[serve new];
        [serveobj setDelegate:self];
        serveobj.tagName=@"dispute";
        [serveobj RaiseDispute:dict];
    }
    
    else if(alertView.tag == 568 && buttonIndex == 1)  // USER DISPUTED A TRANSFER, SELECTED "CONTACT SUPPORT" IN ALERT
    {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have an email account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
           }
    
    else if(alertView.tag==1010 && buttonIndex==0)  // CANCEL
    {
      //  NSString * memId = [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"];
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"cancel";
//      [serveObj CancelRejectTransaction:[self.trans valueForKey:@"TransactionId"] resp:@"Cancelled"];
      //  [serveObj CancelMoneyRequestForExistingNoochUser:[self.trans valueForKey:@"TransactionId"] memberId:memId];
    }
    
    else if(alertView.tag==1011 && buttonIndex==0)  // REJECT
    {
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"reject";
        [serveObj CancelRejectTransaction:[self.trans valueForKey:@"TransactionId"] resp:@"Rejected"];
    }
  
    else if (alertView.tag == 50 && buttonIndex == 1)  // IF USER IS SUSPENDED, & TAPS "CONTACT SUPPORT" IN ALERT
    {
        if (![MFMailComposeViewController canSendMail]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't seem to have an email account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];

        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"cancel_invite"])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Invitation Cancelled" message:@"You have withdrawn this transfer successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [nav_ctrl popViewControllerAnimated:YES];
    }
    
    else if ([tagName isEqualToString:@"tranDetail"])
    {
        [blankView removeFromSuperview];
        NSError *error;

        loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if (![[self.trans objectForKey:@"Latitude"] intValue] == 0 && ![[self.trans objectForKey:@"Longitude"] intValue] == 0)
        {
            // self.trans=[loginResult mutableCopy];
            NSLog(@"%f",[[self.trans objectForKey:@"Latitude"] floatValue]);
            NSLog(@"%f",[[self.trans objectForKey:@"Longitude"] floatValue]);
            
            lat = [[self.trans objectForKey:@"Latitude"] floatValue];
            lon = [[self.trans objectForKey:@"Longitude"] floatValue];
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                                    longitude:lon
                                                                         zoom:11];
            
            UIButton*btnShowOverlay=[[UIButton alloc]init];
            
            UIImageView*imgTran;
            if (![[loginResult valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [loginResult valueForKey:@"Picture"]!=NULL)
            {
                NSArray* bytedata = [loginResult valueForKey:@"Picture"];
                unsigned c = bytedata.count;
                uint8_t *bytes = malloc(sizeof(*bytes) * c);
                
                unsigned i;
                for (i = 0; i < c; i++) {
                    NSString *str = [bytedata objectAtIndex:i];
                    int byte = [str intValue];
                    bytes[i] = (uint8_t)byte;
                }

                NSData *datos = [NSData dataWithBytes:bytes length:c];

                imgTran=[[UIImageView alloc]initWithFrame:CGRectMake(5, 240, 150, 160)];
                [imgTran setImage:[UIImage imageWithData:datos]];
              
                
                mapView_ = [GMSMapView mapWithFrame:CGRectMake(165, 240, 150, 160) camera:camera];
                if ([[UIScreen mainScreen] bounds].size.height == 480) {
                    [imgTran setFrame:CGRectMake(5, 240, 150, 80)];
                    [mapView_ setFrame:CGRectMake(165, 240, 150, 80)];
                    btnShowOverlay.frame=mainView.frame;
                }
                else{
                    [mapView_ setFrame:CGRectMake(165, 240, 150, 160)];
                    [imgTran setFrame:CGRectMake(5, 240, 150, 160)];
                    btnShowOverlay.frame=CGRectMake(165, 240, 150, 160);
                }
            }
            else {
                
                mapView_ = [GMSMapView mapWithFrame:CGRectMake(-1, 240, 322, 160) camera:camera];
                if ([[UIScreen mainScreen] bounds].size.height == 480) {
                    [mapView_ setFrame:CGRectMake(-1, 240, 322, 80)];
                    btnShowOverlay.frame=CGRectMake(-1, 240, 322, 80);
                }
                else
                {
                  [mapView_ setFrame:CGRectMake(-1, 240, 322, 160)];
                    btnShowOverlay.frame=CGRectMake(-1, 240, 322, 160);
                }
                
            }
           [self.view addSubview:mapView_];
            mapView_.myLocationEnabled = YES;
           
            if ([[assist shared]islocationAllowed]) {
                [self.view addSubview:mapView_];
                if (![[loginResult valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [loginResult valueForKey:@"Picture"]!=NULL) {
                    [self.view addSubview:imgTran];
                }
            }
            else {
                if (![[loginResult valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [loginResult valueForKey:@"Picture"]!=NULL) {
                    imgTran.frame=CGRectMake(5, 240, 310, 160);
                    if ([[UIScreen mainScreen] bounds].size.height == 480) {
                        [imgTran setFrame:CGRectMake(5, 240, 150, 80)];
                    }
                    [self.view addSubview:imgTran];
                }
            }
            // Creates a marker in the center of the map.
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(lat, lon);
            marker.map = mapView_;
            [self.view addSubview:btnShowOverlay];
            [btnShowOverlay setBackgroundColor:[UIColor clearColor]];
            [self.view bringSubviewToFront:btnShowOverlay];
            [btnShowOverlay addTarget:self action:@selector(Map_LightBox) forControlEvents:UIControlEventTouchUpInside];
            
        }

        if ([self.trans objectForKey:@"Amount"] != NULL)
        {
            [amount setText:[NSString stringWithFormat:@"$%.02f",[[loginResult valueForKey:@"Amount"] floatValue]]];
        }
        
        [amount setStyleClass:@"details_amount"];
        [amount setTextAlignment:NSTextAlignmentCenter];

        UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 60)];
        CGRect frame = location.frame;
        if (![[loginResult valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [loginResult valueForKey:@"Picture"]!=NULL) {
            frame.origin.x = 165;
            frame.size.width = 155;
            [location setFrame:frame];
        }
        location.numberOfLines=2;
        [location setStyleClass:@"details_label_location"];
        
        if ([[UIScreen mainScreen] bounds].size.height == 480) {
            [location setStyleClass:@"details_label_location_4"];
        }
        
        if ([self.trans objectForKey:@"AddressLine1"] != NULL &&
            [self.trans objectForKey:@"City"] != NULL &&
            [[assist shared]islocationAllowed] )
        {
			NSString*address=[[self.trans objectForKey:@"AddressLine1"] stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            if ([self.trans objectForKey:@"AddressLine2"] != NULL)
            {
                address=[address stringByAppendingString:[self.trans objectForKey:@"AddressLine2"]];
                [location setText:[NSString stringWithFormat:@"%@",address]];
                [self.view addSubview:location];
            }
            
            if ([[self.trans objectForKey:@"AddressLine1"]length] == 0 && [[self.trans objectForKey:@"City"]length] == 0)
            {
                [location setText:@""];
            }
        }

        //Set Status
        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 166, 320, 30)];
        [status setTag:12];
        [status setStyleClass:@"details_label"];
        [status setStyleId:@"details_status"];

        if ([loginResult objectForKey:@"TransactionDate"]!=NULL)
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [dateFormatter setAMSymbol:@"AM"];
            [dateFormatter setPMSymbol:@"PM"];
            dateFormatter.dateFormat = @"M/d/yyyy h:mm:ss a";
            NSDate *yourDate = [dateFormatter dateFromString:[loginResult valueForKey:@"TransactionDate"]];
            dateFormatter.dateFormat = @"dd-MMMM-yyyy";
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];

            NSString*statusstr;

            if ([[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Request"])
            {
                if ([[loginResult objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                    statusstr=@"Cancelled";
                    [status setStyleClass:@"red_text"];
                }
                else if ([[loginResult objectForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                    statusstr=@"Rejected";
                    [status setStyleClass:@"red_text"];
                }
                else {
                    statusstr=@"Pending";
                    [status setStyleClass:@"yellow_text"];
                }
            }
            else if ([[loginResult objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"])
            {
                statusstr=@"Cancelled";
                [status setStyleClass:@"red_text"];
            }
            else if ([[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Sent"]     ||
                    [[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Donation"]  ||
                    [[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Received"]  ||
                    [[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Transfer"])
            {
                statusstr=@"Completed";
                [status setStyleClass:@"green_text"];
            }
            else if ([[loginResult valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
                     [[loginResult valueForKey:@"TransactionStatus"]isEqualToString:@"Pending"])
            {
                statusstr=@"Invited - Pending";
                [status setStyleClass:@"yellow_text"];
            }
            else if ( ![[self.trans valueForKey:@"DisputeId"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"DisputeId"]!=NULL )
            {
                statusstr=@"Disputed:";
                [status setStyleClass:@"red_text"];

				UIButton *detailbutton = [UIButton buttonWithType:UIButtonTypeCustom];
                [detailbutton addTarget:self
                           action:@selector(DisputeDetailClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
                [detailbutton setTitle:@"See Details" forState:UIControlStateNormal];
                [detailbutton setTitle:@"See Details" forState:UIControlStateHighlighted];
                [detailbutton setTitle:@"See Details" forState:UIControlStateSelected];
                detailbutton.frame = CGRectMake(97, 195, 120, 20);
                detailbutton.titleLabel.font=[UIFont fontWithName:@"Roboto-Regular" size:15];
                detailbutton.titleLabel.textColor=kNoochBlue;
                [detailbutton setTitleColor:kNoochBlue forState:UIControlStateSelected];
                [detailbutton setTitleColor:kNoochBlue forState:UIControlStateNormal];
                [self.view addSubview:detailbutton];

				UIImageView*arrow_direction=[[UIImageView alloc]initWithFrame:CGRectMake(detailbutton.frame.origin.x+detailbutton.frame.size.width-15, 198, 12, 15)];
                arrow_direction.image=[UIImage imageNamed:@"arrow-blue.png"];
                [self.view addSubview:arrow_direction];
                UIView*line=[[UIView alloc]initWithFrame:CGRectMake(118, 213, 78, 1)];
                line.backgroundColor=kNoochBlue;
                [self.view addSubview:line];
            }

            [status setText:statusstr];
            [self.view addSubview:status];
            
            if ( [[self.trans valueForKey:@"DisputeId"] isKindOfClass:[NSNull class]] || [self.trans valueForKey:@"DisputeId"] == NULL )
            {
                NSArray *arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
                UILabel *datelbl = [[UILabel alloc] initWithFrame:CGRectMake(90, 190, 140, 30)];
                [datelbl setTextAlignment:NSTextAlignmentCenter]; 
                [datelbl setFont:[UIFont fontWithName:@"Roboto-Light" size:16]];
                [datelbl setTextColor:kNoochGrayDark];
                datelbl.text=[NSString stringWithFormat:@"%@ %@, %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]];
                [self.view addSubview:datelbl];
            }

        }

        serve *info = [serve new];
        info.Delegate = self;
        info.tagName = @"info";
        
        NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
        [info getDetails:[defaults valueForKey:@"MemberId"]];
    }

    if ([tagName isEqualToString:@"reject"])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Request Rejected" message:@"No problem, you have rejected this request successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }

    else if ([tagName isEqualToString:@"cancel"])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Request Cancelled" message:@"You got it. That request has been cancelled successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        for (UIView *subview in self.view.subviews)
        {
            if (subview.tag == 13)  // Remove 'Cancel' Button
                [subview removeFromSuperview];
            if (subview.tag == 14)  // Remove 'Remind' Button
                [subview removeFromSuperview];
        }
        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 320, 30)];
        [status setStyleClass:@"details_label"];
        [status setStyleId:@"details_status"];
        NSString *statusstr=@"Cancelled";
        [status setStyleClass:@"red_text"];
        [status setText:statusstr];
        [self.view addSubview:status];
    }
    
    else if ([tagName isEqualToString:@"dispute"])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Transfer Disputed" message:@"Thanks for letting us know. We will investigate and may contact you for more information.\n\nIf you would like to tell us more please contact Nooch Support." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support", nil];
        [alert show];
        [alert setTag:568];
        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 320, 30)];
        [status setStyleClass:@"details_label"];
        [status setStyleId:@"details_status"];
        NSString *statusstr=@"Disputed";
        [status setStyleClass:@"red_text"];
        [status setText:statusstr];
        [self.view addSubview:status];
        [[assist shared]setSusPended:YES];
    }
    
    else if([tagName isEqualToString:@"info"])
    {
        NSError *error;
        NSMutableDictionary *Result = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([Result valueForKey:@"Status"] != Nil &&
           ![[Result valueForKey:@"Status"] isKindOfClass:[NSNull class]] &&
            [Result valueForKey:@"Status"] != NULL)
        {
            [user setObject:[Result valueForKey:@"Status"] forKey:@"Status"];
            NSString*url=[Result valueForKey:@"PhotoUrl"];
            
            [user setObject:[Result valueForKey:@"DateCreated"] forKey:@"DateCreated"];
            [user setObject:url forKey:@"Photo"];
        }
    }
    
    else if ([tagName isEqualToString:@"remind"])
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Reminder Sent Successfully" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

-(void)DisputeDetailClicked:(UIButton*)sender{
    //[sender setTitle:@"See Details" forState:UIControlStateNormal];
    //[sender setSelected:NO];
    DisputeDetail*dd=[[DisputeDetail alloc]initWithData:loginResult];
    [self.navigationController pushViewController:dd animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}
@end