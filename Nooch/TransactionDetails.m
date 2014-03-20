//
//  TransactionDetails.m
//  Nooch
//
//  Created by crks on 10/4/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "TransactionDetails.h"
#import <QuartzCore/QuartzCore.h>
#import "Home.h"
#import "UIImageView+WebCache.h"
#import "ECSlidingViewController.h"
#import "HowMuch.h"
#import "TransferPIN.h"
#import "SelectRecipient.h"
@interface TransactionDetails ()
@property (nonatomic,strong) NSDictionary *trans;
@property(nonatomic,strong) NSMutableData *responseData;
@end

@implementation TransactionDetails

- (id)initWithData:(NSDictionary *)trans
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.trans = trans;
        //  NSLog(@"%@",self.trans);
    }
    return self;
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
    
    /*UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:act];
    [self.navigationItem setRightBarButtonItem:funds];*/
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Transfer Details"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //UIImageView *user_picture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 76, 76)];
    UIImageView *user_picture = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 76, 76)];
    user_picture.layer.borderWidth = 1; user_picture.layer.borderColor = kNoochGrayDark.CGColor;
    //user_picture.layer.cornerRadius = 38;
    user_picture.layer.cornerRadius = 4;
    user_picture.clipsToBounds = YES;

     if(([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"]&& [self.trans valueForKey:@"BankPicture"] !=NULL&& ![[self.trans valueForKey:@"BankPicture"]isKindOfClass:[NSNull class]]))

    {
        NSArray* bytedata = [self.trans valueForKey:@"BankPicture"];
        unsigned c = bytedata.count;
        uint8_t *bytes = malloc(sizeof(*bytes) * c);
        
        unsigned i;
        for (i = 0; i < c; i++)
        {
            NSString *str = [bytedata objectAtIndex:i];
            int byte = [str intValue];
            bytes[i] = (uint8_t)byte;
        }
        
        NSData *datos = [NSData dataWithBytes:bytes length:c];
        
        
        [user_picture setImage:[UIImage imageWithData:datos]];
        
        
        
    }
    else if ([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Deposit"]){
        [user_picture setImage:[UIImage imageNamed:@"Icon.png"]];
    }
   else if([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Invite"])
         {
             [user_picture setImage:[UIImage imageNamed:@"RoundLoading"]];
         }
    
    else    {
        [user_picture setImageWithURL:[NSURL URLWithString:[self.trans objectForKey:@"Photo"]]
                     placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
    }
    
    
    [self.view addSubview:user_picture];
    
    UILabel *payment = [UILabel new];
    [payment setStyleClass:@"details_intro"];

    
    if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]]) {
        if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
            //send&&

            [payment setText:@"Paid to:"];
            [payment setStyleClass:@"details_intro_red"];
        }

        
    }
    else
    {
        if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Transfer"]) {
            [payment setText:@"Payment From:"];
            [payment setStyleClass:@"details_intro_green"];
        }
    }
    
    if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
        if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"RecepientId"]]) {
            [payment setText:@"Request Sent to:"];
            [payment setStyleClass:@"details_intro_blue"];
        }
        else{
            [payment setText:@"Request From:"];
            [payment setStyleClass:@"details_intro_blue"];

        }
        
    }
    else if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Invite"]) {
        
        [payment setText:@"Invited to:"];
        [payment setStyleClass:@"details_intro_green"];
    }
    
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"])
    {
        [payment setText:@"Withdrawal to:"];

        [payment setStyleClass:@"details_intro_green"];

    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Deposit"])
    {
        [payment setText:@"Deposit Into:"];
        [payment setStyleClass:@"details_intro_green"];
    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Donation"])
    {
        [payment setText:@"Donation To:"];
        [payment setStyleClass:@"details_intro_green"];
    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Disputed"])
    {
        [payment setText:@"Disputed:"];
        
        [payment setStyleClass:@"details_intro_purple"];

    }
    [self.view addSubview:payment];
    
    
    UILabel *other_party = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 60)];
    if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Invite"]) {
        //details_othername_nonnooch
        [other_party setStyleClass:@"details_othername_nonnooch"];
        [other_party setText:[self.trans objectForKey:@"InvitationSentTo"]];
        
    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"]&& [self.trans objectForKey:@"BankName"]!=NULL&& ![[self.trans valueForKey:@"BankName"]isKindOfClass:[NSNull class]])
    {
        [other_party setText:[[self.trans objectForKey:@"BankName"] capitalizedString]];
        [other_party setStyleClass:@"details_othername"];
    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Deposit"])
    {
        [other_party setText:@"Nooch"];
        [other_party setStyleClass:@"details_othername"];
    }
     else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"]&& [self.trans objectForKey:@"BankName"]!=NULL&& ![[self.trans valueForKey:@"BankName"]isKindOfClass:[NSNull class]])
     {
         [other_party setText:[[self.trans objectForKey:@"BankName"] capitalizedString]];
         [other_party setStyleClass:@"details_othername"];
     }
     else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Deposit"])
     {
         [other_party setText:@"Nooch"];
         [other_party setStyleClass:@"details_othername"];
     }
     else{
        [other_party setText:[[self.trans objectForKey:@"Name"] capitalizedString]];
    [other_party setStyleClass:@"details_othername"];
     }
    [self.view addSubview:other_party];
    
    
    amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 60)];
//    if ([self.trans objectForKey:@"Amount"]!=NULL) {
//        [amount setText:[NSString stringWithFormat:@"$%.02f",[[self.trans valueForKey:@"Amount"] floatValue]]];
//    }
    
    [amount setStyleClass:@"details_amount"];
    [amount setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:amount];
    
    UILabel *memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 320, 60)];
    if (![[self.trans valueForKey:@"Memo"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"Memo"]!=NULL) {
        if ([[self.trans valueForKey:@"Memo"] length]==0 || [[self.trans valueForKey:@"Memo"] isEqualToString:@"\"\""]) {
            memo.text=@"No memo attached";
        } else
            [memo setText:[NSString stringWithFormat:@"\"%@\"",[self.trans valueForKey:@"Memo"]]];
    }
    else
    {
        memo.text=@"No memo attached";
    }
    
    memo.numberOfLines=2;
    [memo setStyleClass:@"details_label_memo"];
    [memo setStyleClass:@"blue_text"];
    [memo setStyleClass:@"italic_font"];
    [self.view addSubview:memo];
    
    
    if(![[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"] && ![[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Deposit"])
    {
        if (false) {
            UIButton *pay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [pay setFrame:CGRectMake(0, 440, 0, 0)];
            [pay setTitle:@"Pay" forState:UIControlStateNormal];
            [pay setStyleId:@"button_pay"];
            [self.view addSubview:pay];
            
            UIButton *dec = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [dec setFrame:pay.frame];
            [dec setTitle:@"Decline" forState:UIControlStateNormal];
            [dec setStyleId:@"button_decline"];
            [self.view addSubview:dec];
        }
        
        
        UIButton *pay_back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [pay_back setTitle:@"" forState:UIControlStateNormal];
        [pay_back setStyleClass:@"details_buttons"];
        [pay_back setStyleCSS:@"background-image : url(pay-back-icon.png)"];
        [pay_back setStyleId:@"details_payback"];
        [pay_back addTarget:self action:@selector(pay_back) forControlEvents:UIControlEventTouchUpInside];
        [pay_back setFrame:CGRectMake(15, 410, 60, 60)];
        
        UILabel *pay_text = [UILabel new];
        [pay_text setFrame:pay_back.frame];
        [pay_text setStyleClass:@"details_buttons_labels"];
        [pay_text setText:@"Pay Back"];
        
        UIButton *fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [fb setTitle:@"" forState:UIControlStateNormal];
        [fb setStyleClass:@"details_buttons"];
        [fb setStyleCSS:@"background-image : url(fb-icon-90x90.png)"];
        if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Donation"]) {
            [fb setStyleId:@"details_fb_donate"];
        }
        else
            [fb setStyleId:@"details_fb"];
        
        [fb addTarget:self action:@selector(post_to_fb) forControlEvents:UIControlEventTouchUpInside];
        [fb setFrame:CGRectMake(95, 410, 60, 60)];
        
        UILabel *fb_text = [UILabel new];
        [fb_text setFrame:fb.frame];
        [fb_text setStyleClass:@"details_buttons_labels"];
        [fb_text setText:@"Facebook"];
        
        UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [twit setTitle:@"" forState:UIControlStateNormal];
        [twit setStyleClass:@"details_buttons"];
        [twit setStyleCSS:@"background-image : url(twitter-icon.png)"];
        if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Donation"]) {
            [twit setStyleId:@"details_twit_donate"];
        }
        else
            [twit setStyleId:@"details_twit"];
        [twit addTarget:self action:@selector(post_to_twitter) forControlEvents:UIControlEventTouchUpInside];
        [twit setFrame:CGRectMake(175, 410, 60, 60)];
        
        UILabel *twit_text = [UILabel new];
        [twit_text setFrame:twit.frame];
        [twit_text setStyleClass:@"details_buttons_labels"];
        [twit_text setText:@"Twitter"];
        
        
        UIButton *disp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [disp setTitle:@"" forState:UIControlStateNormal];
        [disp setStyleClass:@"details_buttons"];
        [disp setStyleCSS:@"background-image : url(dispute-icon.png)"];
        if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Donation"]) {
            [disp setStyleId:@"details_disp_donate"];
        }
        else
            [disp setStyleId:@"details_disp"];
        
        
        [disp addTarget:self action:@selector(dispute) forControlEvents:UIControlEventTouchUpInside];
        [disp setFrame:CGRectMake(255, 410, 60, 60)];
        
        
        UILabel *disp_text = [UILabel new];
        [disp_text setFrame:disp.frame];
        [disp_text setStyleClass:@"details_buttons_labels"];
        [disp_text setText:@"Dispute"];
        
        
        if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Request"]) {
            //pay/cancel buttons
            UIButton *pay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [pay setStyleClass:@"details_button_left"];
            
            UIButton *cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            
            if ([[self.trans objectForKey:@"RecepientId"] isEqualToString:[user objectForKey:@"MemberId"]]) {
                if (![[self.trans objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"] && ![[self.trans objectForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                    [cancel setStyleClass:@"details_button_center"];
                    [cancel setEnabled:YES];
                    [cancel addTarget:self action:@selector(cancel_request) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:cancel];
                }
                
            } else {
                if (![[self.trans objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]&& ![[self.trans objectForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                    [cancel setStyleClass:@"details_button_right"];
                    [pay setTitle:@"Pay" forState:UIControlStateNormal];
                    [pay addTarget:self action:@selector(fulfill_request) forControlEvents:UIControlEventTouchUpInside];
                    [cancel setTitle:@"Decline" forState:UIControlStateNormal];
                    [cancel addTarget:self action:@selector(decline_request) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:pay]; [self.view addSubview:cancel];                }
                
                
            }
        }
        else
        {
            
            if([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Donation"]){
                [self.view addSubview:disp];
                [self.view addSubview:disp_text];
                [self.view addSubview:fb];
                [self.view addSubview:fb_text];
                [self.view addSubview:twit];
                [self.view addSubview:twit_text];
            }
            else
            {
                if ([[self.trans objectForKey:@"TransactionType"] isEqualToString:@"Transfer"]) {
                    if([[self.trans objectForKey:@"MemberId"] isEqualToString:[user objectForKey:@"MemberId"]])
                    {
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
            }
        }
    }
    
    blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
    [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    UIActivityIndicatorView*actv=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2)-5, 40, 40)];
    [actv startAnimating];
    [blankView addSubview:actv];
    [self .view addSubview:blankView];
    [self.view bringSubviewToFront:blankView];
    serve *serveOBJ=[serve new ];
    
    serveOBJ.tagName=@"tranDetail";
    
    [serveOBJ setDelegate:self];
    
    [serveOBJ GetTransactionDetail:[self.trans valueForKey:@"TransactionId"]];
}


- (void) fulfill_request
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
        
    }
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your are not a active user.Please click the link sent to your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
        
        
    }
    
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Profile before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }
    
    
    
    if ( ![[[NSUserDefaults standardUserDefaults]
            objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can make any transfer you must attach a bank account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        
        [set show];
        return;
    }
    
    
    if ( ![[assist shared]isBankVerified]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Bank Account before Proceeding." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        
        return;
    }
    
    NSMutableDictionary *input = [self.trans mutableCopy];
    [input setValue:@"accept" forKey:@"response"];
    //NSLog(@"%@",input);
    // isMutipleRequest=NO;
    [[assist shared]setRequestMultiple:NO];
    TransferPIN *trans = [[TransferPIN alloc] initWithReceiver:input type:@"requestRespond" amount:[[self.trans objectForKey:@"Amount"] floatValue]];
    [nav_ctrl pushViewController:trans animated:YES];
}

- (void) decline_request
{
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to Reject this Request? " delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:1011];
    //    NSMutableDictionary *input = [self.trans mutableCopy];
    //    [input setValue:@"deny" forKey:@"response"];
    //    TransferPIN *trans = [[TransferPIN alloc] initWithReceiver:input type:@"requestRespond" amount:[[self.trans objectForKey:@"Amount"] floatValue]];
    //    [nav_ctrl pushViewController:trans animated:YES];
}

- (void) cancel_request
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to cancel this Request? " delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:1010];
}

- (void) pay_back
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    if ([[assist shared]getSuspended]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
        
    }
    
    if (![[user valueForKey:@"Status"]isEqualToString:@"Active"] ) {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Your are not a active user.Please click the link sent to your email." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
        
        
    }
    
    if (![[defaults valueForKey:@"ProfileComplete"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Profile before Proceeding." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Validate Now", nil];
        [alert setTag:147];
        [alert show];
        return;
    }
    if (![[defaults valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] ) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Phone Number before Proceeding." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil , nil];
        
        [alert show];
        return;
    }
    
    
    if ( ![[[NSUserDefaults standardUserDefaults]
            objectForKey:@"IsBankAvailable"]isEqualToString:@"1"]) {
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can make any transfer you must attach a bank account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        
        [set show];
        return;
    }
    
    
    if ( ![[assist shared]isBankVerified]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Bank Account before Proceeding." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        
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

- (void) post_to_fb
{
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
             
             if (granted)
             {
                 NSArray *accounts = [me.accountStore accountsWithAccountType:facebookAccountType];
                 
                 me.facebookAccount = [accounts lastObject];
                 [self performSelectorOnMainThread:@selector(post) withObject:nil waitUntilDone:NO];
             }
             else
             {
                 // Handle Failure
                 NSLog(@"fbposting not allowed");
                 
             }
             
         }];
    }
}

- (void) post_to_twitter
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [controller setInitialText:[NSString stringWithFormat:@"I just Nooch'ed %@!",[self.trans objectForKey:@"Name"]]];
    [controller addURL:[NSURL URLWithString:@"http://www.nooch.com"]];
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

-(void)post
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"I just Nooch'ed %@!",[self.trans objectForKey:@"Name"]]];
    [controller addURL:[NSURL URLWithString:@"http://www.nooch.com"]];
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

-(void)finishedPosting
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) dispute
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to dispute this transfer? Your account will be suspended while we investigate." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:1];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            self.responseData = [NSMutableData data];
            NSMutableDictionary*dict=[[NSMutableDictionary alloc] init];
            
            NSString * memId = [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"];
            [dict setObject :memId forKey:@"MemberId"];
            [ dict setObject:[self.trans valueForKey:@"RecepientId"] forKey:@"RecepientId"];
            [ dict setObject:[self.trans valueForKey:@"TransactionId"] forKey:@"TransactionId"];
            [ dict setObject:@"SENT" forKey:@"ListType"];
            //NSLog(@"%@",dict);
            serve*serveobj=[serve new];
            [serveobj setDelegate:self];
            serveobj.tagName=@"dispute";
            [serveobj RaiseDispute:dict];
            //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&%@=%@&%@=%@", MyUrl, raiseDispute, idvalue, MemID, recepientId, recepientIdValue, txnId, txnIdValue, listType, listTypeValue]]];
            //[NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
    else if(alertView.tag==1010 && buttonIndex==0)
    {
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"cancel";
        [serveObj CancelRejectTransaction:[self.trans valueForKey:@"TransactionId"] resp:@"Cancelled"];
        
    }
    else if(alertView.tag==1011 && buttonIndex==0)
    {
        serve*serveObj=[serve new];
        [serveObj setDelegate:self];
        serveObj.tagName=@"reject";
        [serveObj CancelRejectTransaction:[self.trans valueForKey:@"TransactionId"] resp:@"Rejected"];
        
    }
    
    //1011
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    

    if ([tagName isEqualToString:@"tranDetail"]) {
        [blankView removeFromSuperview];
        NSError *error;
        
        NSMutableDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if (![[self.trans objectForKey:@"Latitude"] intValue]==0&& ![[self.trans objectForKey:@"Longitude"] intValue]==0) {
            // self.trans=[loginResult mutableCopy];
            double lat = [[self.trans objectForKey:@"Latitude"] floatValue];
            double lon = [[self.trans objectForKey:@"Longitude"] floatValue];
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                                    longitude:lon
                                                                         zoom:11];
            UIImageView*imgTran;
            if (![[loginResult valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [loginResult valueForKey:@"Picture"]!=NULL) {
                NSArray* bytedata = [loginResult valueForKey:@"Picture"];
                unsigned c = bytedata.count;
                uint8_t *bytes = malloc(sizeof(*bytes) * c);
                
                unsigned i;
                for (i = 0; i < c; i++)
                {
                    NSString *str = [bytedata objectAtIndex:i];
                    int byte = [str intValue];
                    bytes[i] = (uint8_t)byte;
                }
                
                NSData *datos = [NSData dataWithBytes:bytes length:c];
                
                imgTran=[[UIImageView alloc]initWithFrame:CGRectMake(5, 240, 150, 160)];
                [imgTran setImage:[UIImage imageWithData:datos]];
                
                mapView_ = [GMSMapView mapWithFrame:CGRectMake(165, 240, 150, 160) camera:camera];
            }
            else
                mapView_ = [GMSMapView mapWithFrame:CGRectMake(-1, 240, 322, 160) camera:camera];
            
            mapView_.myLocationEnabled = YES;
            //mapView_.layer.borderWidth = 1;
            if ([[assist shared]islocationAllowed]) {
                
                [self.view addSubview:mapView_];
                if (![[loginResult valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [loginResult valueForKey:@"Picture"]!=NULL) {

                    [self.view addSubview:imgTran];
                }
            }
            else
            {
                if (![[loginResult valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [loginResult valueForKey:@"Picture"]!=NULL) {
                    imgTran.frame=CGRectMake(5, 240, 310, 160);
                    
                    [self.view addSubview:imgTran];
                }
            }
            // Creates a marker in the center of the map.
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(lat, lon);
            
            marker.map = mapView_;
            
            
        }
        if ([self.trans objectForKey:@"Amount"]!=NULL) {
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
        [location setAlpha:0.7];
        if ([self.trans objectForKey:@"AddressLine1"]!=NULL && [self.trans objectForKey:@"City"]!=NULL && [[assist shared]islocationAllowed] ) {
            if ([self.trans objectForKey:@"AddressLine1"]!=NULL && [self.trans objectForKey:@"City"]!=NULL && [[assist shared]islocationAllowed] ) {
                NSString*address=[[self.trans objectForKey:@"AddressLine1"] stringByReplacingOccurrencesOfString:@"," withString:@""];
                
                if ([self.trans objectForKey:@"AddressLine2"]!=NULL) {
                    address=[address stringByAppendingString:[self.trans objectForKey:@"AddressLine2"]];
                }
                
                NSString*city=[[self.trans objectForKey:@"City"] stringByReplacingOccurrencesOfString:@"," withString:@""];
               
                [location setText:[NSString stringWithFormat:@"%@,%@",address,city]];
               
                if ([[self.trans objectForKey:@"AddressLine1"]length]==0 && [[self.trans objectForKey:@"City"]length]==0) {
                    [location setText:@""];
                }
            [self.view addSubview:location];
        }
        }
        //Set Status
        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 320, 30)];
        [status setStyleClass:@"details_label"];
        [status setStyleId:@"details_status"];
        if ([loginResult objectForKey:@"TransactionDate"]!=NULL) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];

            [dateFormatter setAMSymbol:@"AM"];
            [dateFormatter setPMSymbol:@"PM"];
            dateFormatter.dateFormat = @"M/d/yyyy h:mm:ss a";
            NSDate *yourDate = [dateFormatter dateFromString:[loginResult valueForKey:@"TransactionDate"]];
            dateFormatter.dateFormat = @"dd-MMMM-yyyy";
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            
            NSString*statusstr;
            if ([[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Request"]) {
                if ([[loginResult objectForKey:@"RecepientId"] isEqualToString:[user objectForKey:@"MemberId"]]) {
                    if ([[loginResult objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                        statusstr=@"Cancelled";
                        [status setStyleClass:@"red_text"];
                        
                    }
                    else if ([[self.trans objectForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                        statusstr=@"Rejected";
                        [status setStyleClass:@"red_text"];
                        
                    }
                    else
                    {
                        statusstr=@"Pending";
                        [status setStyleClass:@"green_text"];
                    }
                    
                }
                else{
                    if ([[loginResult objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                        statusstr=@"Cancelled";
                        [status setStyleClass:@"red_text"];
                    }
                    else if ([[loginResult objectForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                        statusstr=@"Rejected";
                        [status setStyleClass:@"red_text"];
                    }
                    else
                    {
                        statusstr=@"Pending";
                        [status setStyleClass:@"green_text"];
                    }
                }
                
            }
            else if([[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Donation"]||[[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Received"]||[[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Transfer"])
            {
                statusstr=@"Completed";
                [status setStyleClass:@"green_text"];
            }
            else if([[loginResult valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"] || [[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Deposit"])
            {
                statusstr=@"Submitted";
                [status setStyleClass:@"green_text"];
            }
            else if ([[loginResult valueForKey:@"TransactionType"]isEqualToString:@"Invite"]) {
                
                statusstr=@"Invited";
                [status setStyleClass:@"green_text"];
            }

            else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Disputed"])
            {
                statusstr=@"Disputed on:";
               [status setStyleClass:@"red_text"];
            }

            [status setText:statusstr];
            [self.view addSubview:status];
            
            NSArray*arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
            UILabel *datelbl = [[UILabel alloc] initWithFrame:CGRectMake(90, 190, 140, 30)];
            [datelbl setTextAlignment:NSTextAlignmentCenter]; [datelbl setFont:[UIFont fontWithName:@"Roboto-Light" size:16]];
            [datelbl setTextColor:kNoochGrayDark];
            [self.view addSubview:datelbl];
            datelbl.text=[NSString stringWithFormat:@"%@ %@, %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]];
        }
        
        serve *info = [serve new];
        info.Delegate = self;
        info.tagName = @"info";
        
        NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
        [info getDetails:[defaults valueForKey:@"MemberId"]];
        
    }
    if ([tagName isEqualToString:@"reject"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've rejected the Request Successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
    else if ([tagName isEqualToString:@"cancel"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've cancelled the Request Successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
    else if ([tagName isEqualToString:@"dispute"]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've diputed your Transaction Successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [[assist shared]setSusPended:YES];
        [nav_ctrl popToRootViewControllerAnimated:YES];
    }
    else if([tagName isEqualToString:@"info"]){
        NSError *error;
        
        NSMutableDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ([loginResult valueForKey:@"Status"]!=Nil  && ![[loginResult valueForKey:@"Status"] isKindOfClass:[NSNull class]]&& [loginResult valueForKey:@"Status"] !=NULL) {
            [user setObject:[loginResult valueForKey:@"Status"] forKey:@"Status"];
            NSString*url=[loginResult valueForKey:@"PhotoUrl"];
            
            [user setObject:[loginResult valueForKey:@"DateCreated"] forKey:@"DateCreated"];
            [user setObject:url forKey:@"Photo"];
            
        }
        
        if(![[loginResult objectForKey:@"BalanceAmount"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"BalanceAmount"] != NULL)
        {
            
            [user setObject:[loginResult objectForKey:@"BalanceAmount"] forKey:@"Balance"];
            UIButton*balance = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            [balance setFrame:CGRectMake(0, 0, 60, 30)];
            if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
                
                [balance setTitle:[NSString stringWithFormat:@"$%@",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
                
            }
            
            [balance.titleLabel setFont:kNoochFontMed];
            
            [balance setStyleId:@"navbar_balance"];
            
            [self.navigationItem setRightBarButtonItem:Nil];
            
            //UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:balance];
            //[self.navigationItem setRightBarButtonItem:funds];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}

@end
