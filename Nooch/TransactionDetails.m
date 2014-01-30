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
        NSLog(@"%@",self.trans);
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
//    serve *serveOBJ=[serve new ];
//    
//    serveOBJ.tagName=@"tranDetail";
//    
//    [serveOBJ setDelegate:self];
//    
//    [serveOBJ GetTransactionDetail:[self.trans valueForKey:@"transactionId"]];

    NSLog(@"trans details: %@",self.trans);
    
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Transfer Details"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *user_picture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 76, 76)];
    user_picture.layer.borderWidth = 1; user_picture.layer.borderColor = kNoochGrayDark.CGColor;
    user_picture.layer.cornerRadius = 38;
    user_picture.clipsToBounds = YES;
    [user_picture setImageWithURL:[NSURL URLWithString:[self.trans objectForKey:@"Photo"]]
             placeholderImage:[UIImage imageNamed:@"RoundLoading"]];
    [self.view addSubview:user_picture];
    
    UILabel *payment = [UILabel new];
    [payment setStyleClass:@"details_intro"];
    [payment setStyleClass:@"details_intro_green"];
    NSLog(@"%@",self.trans);
    if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Sent"]) {
       
             [payment setText:@"Paid to:"];
          }
   else if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Received"]) {
        
            [payment setText:@"Received From:"];
    
    }
    else if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"]) {
       
            [payment setText:@"Requested From:"];
            
        
        
    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"])
    {
       [payment setText:@"Withdraw From:"];
    }
    else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Donation"])
    {
        [payment setText:@"Donation To:"];
    }
   
    [self.view addSubview:payment];
    
    UILabel *other_party = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 60)];
    [other_party setStyleClass:@"details_othername"];
    [other_party setText:[self.trans objectForKey:@"Name"]];
    [self.view addSubview:other_party];
    /*
    if ([other_party respondsToSelector:@selector(setAttributedText:)]) {
        //const CGFloat fontSize = 18;
        UIFont *boldFont = kNoochFontBold;
        UIFont *regularFont = kNoochFontMed;
        UIColor *foregroundColor = [UIColor whiteColor];
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName, nil];
        const NSRange range = NSMakeRange(1,6); // range of " 2012/10/14 ". Ideally this should not be hardcoded
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:@"Preston Hults"
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        
        // Set it in our UILabel and we are done!
        [other_party setAttributedText:attributedText];
        [self.view addSubview:other_party];
    }
     */
    // City = "";
    
    
   
    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 60)];
    if ([self.trans objectForKey:@"Amount"]!=NULL) {
    [amount setText:[NSString stringWithFormat:@"$%.02f",[[self.trans valueForKey:@"Amount"] floatValue]]];
    }
  
    [amount setStyleClass:@"details_amount"];
    //[amount setFont:kNoochFontBold];
    [amount setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:amount];
  
    UILabel *memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 320, 60)];
    if (![[self.trans valueForKey:@"Memo"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"Memo"]!=NULL) {
        [memo setText:[NSString stringWithFormat:@"\"%@\"",[self.trans valueForKey:@"Memo"]]];
            }
    else
    {
        memo.text=@"";
    }
    
    [memo setStyleClass:@"details_label"];
    [memo setStyleClass:@"blue_text"];
    [memo setStyleClass:@"italic_font"];
    [self.view addSubview:memo];

    
    UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 60)];
    location.numberOfLines=2;
     [location setStyleClass:@"details_label"];
    if ([self.trans objectForKey:@"AddressLine1"]!=NULL && [self.trans objectForKey:@"City"]!=NULL && [[assist shared]islocationAllowed] ) {
        [location setText:[NSString stringWithFormat:@"%@ %@ %@ %@",[self.trans objectForKey:@"AddressLine1"],[self.trans objectForKey:@"AddressLine2"],[self.trans objectForKey:@"City"],[self.trans objectForKey:@"Country"]]];
        if ([[self.trans objectForKey:@"AddressLine1"]length]==0 && [[self.trans objectForKey:@"City"]length]==0) {
            [location setText:@""];
        }
         [self.view addSubview:location];
    }

    else
    {
        [location setText:@""];
        [self.view addSubview:location];

    }
   
    
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, 320, 30)];
    [status setStyleClass:@"details_label"];
    if ([self.trans objectForKey:@"TransactionDate"]!=NULL) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        NSDate *yourDate = [dateFormatter dateFromString:[self.trans valueForKey:@"TransactionDate"]];
        dateFormatter.dateFormat = @"dd-MMMM-yyyy";
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSLog(@"%@",[dateFormatter stringFromDate:yourDate]);
        NSString*statusstr;
        if ([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Request"]) {
            [status setStyleClass:@"details_label1"];
           statusstr=@"Pending...:";
        }
        else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Donation"]||[[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Sent"]||[[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Received"])
        {
            statusstr=@"Completed on :";
        }
        else if([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Withdraw"])
        {
            statusstr=@"Submitted on :";
        }
          NSArray*arrdate=[[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
        if ([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Request"]) {
            [status setText:[NSString stringWithFormat:@"%@ (Sent on %@ %@,%@)",statusstr,[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]]];
        }
      else
      {
        [status setText:[NSString stringWithFormat:@"%@ %@ %@,%@",statusstr,[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]]];
      }
    }
    //[status setText:[NSString stringWithFormat:@"%@ on %@",[self.trans objectForKey:@"TransactionType"],[self.trans objectForKey:@"TransactionDate"]]];
    [status setStyleClass:@"green_text"];
    [self.view addSubview:status];
    double lat = [[self.trans objectForKey:@"Latitude"] floatValue];
    double lon = [[self.trans objectForKey:@"Longitude"] floatValue];
    

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:11];
    UIImageView*imgTran;
    if (![[self.trans valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"Picture"]!=NULL) {
        NSArray* bytedata = [self.trans valueForKey:@"Picture"];
        //XXXXXXXX2222
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
        if (![[self.trans valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"Picture"]!=NULL) {
            
            [self.view addSubview:imgTran];
        }
    }
    else
    {
        if (![[self.trans valueForKey:@"Picture"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"Picture"]!=NULL) {
            imgTran.frame=CGRectMake(5, 240, 310, 160);

            [self.view addSubview:imgTran];
        }
    }
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(lat, lon);
   
    marker.map = mapView_;
    
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
    [self.view addSubview:pay_back];
    
    UILabel *pay_text = [UILabel new];
    [pay_text setFrame:pay_back.frame];
    [pay_text setStyleClass:@"details_buttons_labels"];
    [pay_text setText:@"Pay Back"];
    [self.view addSubview:pay_text];
    
    UIButton *fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fb setTitle:@"" forState:UIControlStateNormal];
    [fb setStyleClass:@"details_buttons"];
    [fb setStyleCSS:@"background-image : url(fb-icon-90x90.png)"];
    [fb setStyleId:@"details_fb"];
    [fb addTarget:self action:@selector(post_to_fb) forControlEvents:UIControlEventTouchUpInside];
    [fb setFrame:CGRectMake(95, 410, 60, 60)];
    [self.view addSubview:fb];
    
    UILabel *fb_text = [UILabel new];
    [fb_text setFrame:fb.frame];
    [fb_text setStyleClass:@"details_buttons_labels"];
    [fb_text setText:@"Facebook"];
    [self.view addSubview:fb_text];
    
    UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setTitle:@"" forState:UIControlStateNormal];
    [twit setStyleClass:@"details_buttons"];
    [twit setStyleCSS:@"background-image : url(twitter-icon.png)"];
    [twit setStyleId:@"details_twit"];
    [twit addTarget:self action:@selector(post_to_twitter) forControlEvents:UIControlEventTouchUpInside];
    [twit setFrame:CGRectMake(175, 410, 60, 60)];
    [self.view addSubview:twit];
    
    UILabel *twit_text = [UILabel new];
    [twit_text setFrame:twit.frame];
    [twit_text setStyleClass:@"details_buttons_labels"];
    [twit_text setText:@"Twitter"];
    [self.view addSubview:twit_text];
    
    UIButton *disp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [disp setTitle:@"" forState:UIControlStateNormal];
    [disp setStyleClass:@"details_buttons"];
    [disp setStyleCSS:@"background-image : url(dispute-icon.png)"];
    [disp setStyleId:@"details_disp"];
    [disp addTarget:self action:@selector(dispute) forControlEvents:UIControlEventTouchUpInside];
    [disp setFrame:CGRectMake(255, 410, 60, 60)];
    [self.view addSubview:disp];
    
    UILabel *disp_text = [UILabel new];
    [disp_text setFrame:disp.frame];
    [disp_text setStyleClass:@"details_buttons_labels"];
    [disp_text setText:@"Dispute"];
    [self.view addSubview:disp_text];
}

- (void) pay_back
{
    HowMuch *payback = [[HowMuch alloc] initWithReceiver:self.trans];
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
        if (buttonIndex == 1) {
            self.responseData = [NSMutableData data];
            //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&%@=%@&%@=%@", MyUrl, raiseDispute, idvalue, MemID, recepientId, recepientIdValue, txnId, txnIdValue, listType, listTypeValue]]];
            //[NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
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
