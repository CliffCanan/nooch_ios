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

@interface TransactionDetails ()
@property (nonatomic,strong) NSDictionary *trans;
@end

@implementation TransactionDetails

- (id)initWithData:(NSDictionary *)trans
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.trans = trans;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Transfer Details"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *user_picture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 76, 76)];
    user_picture.layer.borderWidth = 1; user_picture.layer.borderColor = kNoochGrayDark.CGColor;
    user_picture.layer.cornerRadius = 38;
    user_picture.clipsToBounds = YES;
    [self.view addSubview:user_picture];
    
    UILabel *payment = [UILabel new];
    [payment setStyleClass:@"details_intro"];
    [payment setStyleClass:@"details_intro_green"];
    [payment setText:@"Payment From:"];
    [self.view addSubview:payment];
    
    UILabel *other_party = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 60)];
    [other_party setStyleClass:@"details_othername"];
    [other_party setText:@"Preston Hults"];
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
    
    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 60)];
    [amount setText:@"$ 50.\u00B0\u00B0"];
    [amount setStyleClass:@"details_amount"];
    //[amount setFont:kNoochFontBold];
    [amount setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:amount];
    
    UILabel *memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 320, 60)];
    [memo setText:@"\"for lunch and a soda\""];
    [memo setStyleClass:@"details_label"];
    [memo setStyleClass:@"blue_text"];
    [memo setStyleClass:@"italic_font"];
    [self.view addSubview:memo];
    
    UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 60)];
    [location setText:@"Philadelphia, PA"];
    [location setStyleClass:@"details_label"];
    [self.view addSubview:location];
    
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, 320, 30)];
    [status setStyleClass:@"details_label"];
    [status setText:@"Completed on 11/12/13"];
    [status setStyleClass:@"green_text"];
    [self.view addSubview:status];
    
    double lat = 10.000;
    double lon = 10.000;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:11];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(-1, 240, 322, 160) camera:camera];
    mapView_.myLocationEnabled = YES;
    //mapView_.layer.borderWidth = 1;
    [self.view addSubview:mapView_];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(lat, lon);
    //marker.title = @"Sydney";
    //marker.snippet = @"Australia";
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
    [fb setFrame:CGRectMake(95, 410, 60, 60)];
    [self.view addSubview:fb];
    
    UILabel *fb_text = [UILabel new];
    [fb_text setFrame:fb.frame];
    [fb_text setStyleClass:@"details_buttons_labels"];
    [fb_text setText:@"Facebok"];
    [self.view addSubview:fb_text];
    
    UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setTitle:@"" forState:UIControlStateNormal];
    [twit setStyleClass:@"details_buttons"];
    [twit setStyleCSS:@"background-image : url(twitter-icon.png)"];
    [twit setStyleId:@"details_twit"];
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
    [disp setFrame:CGRectMake(255, 410, 60, 60)];
    [self.view addSubview:disp];
    
    UILabel *disp_text = [UILabel new];
    [disp_text setFrame:disp.frame];
    [disp_text setStyleClass:@"details_buttons_labels"];
    [disp_text setText:@"Dispute"];
    [self.view addSubview:disp_text];
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
