//  TransferPIN.m
//  Nooch
//
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "TransferPIN.h"
#import <QuartzCore/QuartzCore.h>
#import "GetLocation.h"
#import "TransactionDetails.h"
#import "UIImageView+WebCache.h"
#import "SelectRecipient.h"
#import <AudioToolbox/AudioToolbox.h>

@interface TransferPIN ()<GetLocationDelegate>
{
    GetLocation *getlocation;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong)NSMutableData*respData;
@property(nonatomic,strong) NSString *memo;
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSString *phone;
@property(nonatomic,strong) NSDictionary *receiver;
@property(nonatomic) float amnt;
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@property(nonatomic,strong) NSDictionary *trans;
@end

@implementation TransferPIN

- (id)initWithReceiver:(NSMutableDictionary *)receiver
                  type:(NSString *)type
                amount:(float)amount
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        NSLog(@"PIN: self.receiver is: %@", receiver);
        // Custom initialization
        if ([receiver valueForKey:@"FirstName"])
        {
            receiverFirst = [receiver valueForKey:@"FirstName"];
        }
        if ([receiver valueForKey:@"phone"])
        {
            self.phone = [[receiver valueForKey:@"phone"] stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [[receiver valueForKey:@"phone"] length])];
            
            NSLog(@"self.phone is: %@",self.phone);
        }
        if ([receiver valueForKey:@"memo"])
        {
            self.memo = [receiver valueForKey:@"memo"];
        }
        else if ([receiver valueForKey:@"Memo"])
        {
            self.memo = [receiver valueForKey:@"Memo"];
        }

        self.type = type;
        self.receiver = receiver;
        self.amnt = amount;

        NSLog(@"\nself.type is: %@\nself.amnt is: %f", self.type, self.amnt);
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"TransferPin Screen";
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    getlocation = [[GetLocation alloc] init];
	getlocation.delegate = self;

    if ([getlocation.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
        // Sending a message to avoid compile time error
        [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                   to:getlocation.locationManager
                                                 from:self
                                             forEvent:nil];
    }
    //[getlocation.locationManager requestWhenInUseAuthorization];
	[getlocation.locationManager startUpdatingLocation];

    // Do any additional setup after loading the view from its nib.
    self.pin = [UITextField new];
    [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    self.pin.inputAccessoryView = [[UIView alloc] init];
    [self.pin setDelegate:self];
    [self.pin setFrame:CGRectMake(800, -100, 10, 10)];
    [self.pin setTextColor:[UIColor clearColor]];
    [self.view addSubview:self.pin];
    [self.pin becomeFirstResponder];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self.navigationItem setTitle:@"Enter PIN"];
    [self.navigationItem setHidesBackButton:YES];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 60)];
    [title setText:@"Enter Your PIN to confirm your"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"pin_instructiontext"];
    [self.view addSubview:title];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backPressed:)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 300, 18)];
    }
    else
    {
        self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 42, 300, 18)];
    }
    if ([self.type isEqualToString:@"send"] || [self.type isEqualToString:@"requestRespond"])
    {
        [self.prompt setText:@"transfer"];
        [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
    }
    else if ([self.type isEqualToString:@"request"]) {    
        [self.prompt setText:@"request"];
        [self.prompt setStyleId:@"pin_instructiontext_request"];
    }
    else {
        [self.prompt setText:@"contribution"];
        [self.prompt setStyleId:@"pin_instructiontext_donate"];
    }
    [self.prompt setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.prompt];

    UILabel * total = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 290, 30)];
    [total setBackgroundColor:[UIColor clearColor]];
    [total setTextColor:[UIColor whiteColor]]; [total setTextAlignment:NSTextAlignmentRight];
    [total setText:[NSString stringWithFormat:@"$ %.02f",self.amnt]];

    UIView * back = [UIView new];
    [back setStyleClass:@"raised_view"];
    [back setStyleClass:@"pin_recipientbox"];
    [self.view addSubview:back];

    UIView * bar = [UIView new];
    [bar setStyleClass:@"pin_recipientname_bar"];

    if ([self.type isEqualToString:@"send"] || [self.type isEqualToString:@"requestRespond"])
    {
        [bar setStyleId:@"pin_recipientname_send"];
    }
    else if ([self.type isEqualToString:@"request"])
    {
        [bar setStyleId:@"pin_recipientname_request"];
    }

    [self.view addSubview:bar];
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(31, 32, 33, .25);
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    UILabel * to_label = [UILabel new];

    if ([self.receiver objectForKey:@"nonuser"])
    {
        UILabel * glyph_nonuserType = [UILabel new];
        [glyph_nonuserType setTextColor:[UIColor whiteColor]];

        if ([self.receiver objectForKey:@"email"])
        {
            [glyph_nonuserType setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
            glyph_nonuserType.attributedText = [[NSAttributedString alloc]initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"] attributes:textAttributes];
        }
        else if ([self.receiver objectForKey:@"phone"])
        {
            [glyph_nonuserType setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
            glyph_nonuserType.attributedText = [[NSAttributedString alloc]initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"] attributes:textAttributes];
        }

        if ([self.receiver objectForKey:@"firstName"] && [self.receiver objectForKey:@"lastName"])
        {
            int numOfChars = [[self.receiver objectForKey:@"firstName"] length] + [[self.receiver objectForKey:@"lastName"] length];
            if (numOfChars > 23) {numOfChars = 23;}

            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",[self.receiver objectForKey:@"firstName"],[self.receiver objectForKey:@"lastName"]] attributes:textAttributes];

            [glyph_nonuserType setFrame:CGRectMake(198 + ((numOfChars * 10) / 2), 198, 20, 38)];
            [self.view addSubview:glyph_nonuserType];
        }
        else if ([self.receiver objectForKey:@"firstName"])
        {
            int numOfChars = [[self.receiver objectForKey:@"firstName"] length];

            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[self.receiver objectForKey:@"firstName"]] attributes:textAttributes];

            [glyph_nonuserType setFrame:CGRectMake(200 + ((numOfChars * 10) / 2), 198, 20, 38)];
            [self.view addSubview:glyph_nonuserType];
        }
        else if ([self.receiver objectForKey:@"email"])
        {
            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[self.receiver objectForKey:@"email"]] attributes:textAttributes];
        }
        else if ([self.receiver objectForKey:@"phone"])
        {
            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[self.receiver objectForKey:@"phone"]] attributes:textAttributes];
        }
    }
    else
    {
        if ([[assist shared] isRequestMultiple])
        {
            NSString * strMultiple = @"";
            for (NSDictionary *dictRecord in [[assist shared]getArray])
            {
                strMultiple = [strMultiple stringByAppendingString:[NSString stringWithFormat:@", %@",[dictRecord[@"FirstName"] capitalizedString]]];
            }
            strMultiple = [strMultiple substringFromIndex:1];
            [to_label setText:strMultiple];
        }
        else
        {
            if (isFromMyApt && [self.receiver objectForKey:@"AptName"])
            {
                to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self.receiver objectForKey:@"AptName"]] attributes:textAttributes];
            }
            else if ([self.receiver objectForKey:@"FirstName"])
            {
                to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [[self.receiver objectForKey:@"FirstName"] capitalizedString], [[self.receiver objectForKey:@"LastName"] capitalizedString]] attributes:textAttributes];
            }
        }
    }

    [to_label setStyleClass:@"pin_recipientname_text"];

    UIImageView * user_pic = [UIImageView new];

    UILabel * memo_label = [UILabel new];
    [memo_label setStyleClass:@"pin_memotext"];
    if ([[self.receiver objectForKey:@"memo"] length] > 0)
    {
        [memo_label setText:[self.receiver objectForKey:@"memo"]];
    }
    else if ([[self.receiver objectForKey:@"Memo"] length] > 0)
    {
        [memo_label setText:[self.receiver objectForKey:@"Memo"]];
    }
    else
    {
        [memo_label setText:@"No memo attached"];
    }

    if (memo_label.text.length > 34)
    {
        [memo_label setStyleClass:@"memo_long"];
    }
    if (memo_label.text.length > 40)
    {
        [memo_label setStyleClass:@"memo_superLong"];
    }

    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        [title setStyleClass:@"pin_instructiontext_4"];
        [to_label setStyleClass:@"pin_recipientname_text_4"];
        [memo_label setStyleClass:@"pin_memotext_4"];
        back.layer.cornerRadius = 4;
        [back setStyleClass:@"raised_view"];
        [back setStyleClass:@"pin_recipientbox_4"];
        [bar setStyleClass:@"pin_recipientname_bar_4"];
        [user_pic setFrame:CGRectMake(11, 137, 58, 58)];

        [total setStyleClass:@"pin_amountfield_4"];

        self.first_num = [[UIView alloc] initWithFrame:CGRectMake(46,50,28,28)];
        self.second_num = [[UIView alloc] initWithFrame:CGRectMake(110,50,28,28)];
        self.third_num = [[UIView alloc] initWithFrame:CGRectMake(175,50,28,28)];
        self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(239,50,28,28)];
        self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 14;
    }
    else
    {
        [user_pic setFrame:CGRectMake(11, 205, 58, 58)];

        [total setStyleClass:@"pin_amountfield"];

        self.first_num = [[UIView alloc] initWithFrame:CGRectMake(44,70,32,32)];
        self.second_num = [[UIView alloc] initWithFrame:CGRectMake(107,70,32,32)];
        self.third_num = [[UIView alloc] initWithFrame:CGRectMake(170,70,32,32)];
        self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(233,70,32,32)];
        self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 16;
    }

    [self.view addSubview:to_label];
    [self.view addSubview:memo_label];
    
    if ([self.receiver valueForKey:@"nonuser"])
    {
        [user_pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    else
    {
        [user_pic setHidden:NO];
        if (self.receiver[@"Photo"])
        {
            [user_pic sd_setImageWithURL:[NSURL URLWithString:self.receiver[@"Photo"]]
                     placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        }
        else
        {
            [user_pic sd_setImageWithURL:[NSURL URLWithString:self.receiver[@"PhotoUrl"]]
                     placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        }
    }
    user_pic.layer.borderColor = [UIColor whiteColor].CGColor;
    user_pic.layer.borderWidth = 2;
    user_pic.clipsToBounds = YES;
    user_pic.layer.cornerRadius = 29;
    [self.view addSubview:user_pic];

    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;

    if ([self.type isEqualToString:@"send"]) {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;        
    }
    else {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;    
    }

    [self.view addSubview:total];
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
    
    if ([[assist shared] getTranferImage])
    {
        UIImageView * trans_image = [[UIImageView alloc] initWithFrame:CGRectMake(252, 205, 56, 56)];
        [memo_label setStyleClass:@"pin_memotext_wPic"];
        [to_label setStyleClass:@"pin_recipientname_text_wPic"];

        if ([[UIScreen mainScreen] bounds].size.height < 500)
        {
            [memo_label setStyleClass:@"pin_memotext_wPic_4"];
            [to_label setStyleClass:@"pin_recipientname_text_wPic_4"];
            [trans_image setFrame:CGRectMake(264, 143, 44, 44)];
        }

        trans_image.layer.cornerRadius = 5;
        trans_image.layer.borderWidth = 1;
        trans_image.clipsToBounds = YES;
        trans_image.layer.borderColor = [UIColor whiteColor].CGColor;
        [trans_image setImage:[[assist shared] getTranferImage]];
        [self.view addSubview:trans_image];
    }
}

-(void)backPressed:(id)sender
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Email cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [alert setTitle:@"Email saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"Email sent"];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark-Location Tracker Delegates
- (void)transferPinLocationUpdateManager:(CLLocationManager *)manager
                      didUpdateLocations:(NSArray *)locationsArray
{
    CLLocationCoordinate2D loc = manager.location.coordinate;
    lat = [[[NSString alloc] initWithFormat:@"%f",loc.latitude] floatValue];
    lon = [[[NSString alloc] initWithFormat:@"%f",loc.longitude] floatValue];

    latitude = [NSString stringWithFormat:@"%f",lat];
    longitude = [NSString stringWithFormat:@"%f",lon];

    [self updateLocation:[NSString stringWithFormat:@"%f",lat]
          longitudeField:[NSString stringWithFormat:@"%f",lon]];
}

-(void) updateLocation:(NSString*)latitudeField longitudeField:(NSString*)longitudeField{

    NSLog(@"TransferPIN --> updateLocation: lat is: %@  & long is: %@",latitudeField,longitudeField);

    NSString * fetchURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", latitudeField, longitudeField];
    NSURL * url = [NSURL URLWithString:fetchURL];

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response, NSData *data, NSError *err) {
        NSError * error;
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
        [self setLocation];
    }];
}

- (void)locationError:(NSError *)error
{
    NSLog(@"LocationManager didFailWithError %@", error);
}

-(void)setLocation
{
    NSArray * placemark = [jsonDictionary objectForKey:@"results"];
    //NSLog(@"Placemark COUNT is: %d\nPlacemark is: %@", [placemark count], placemark);

    if ([placemark count] > 0)
    {
        // if Google returned a Street Address
        if ([[placemark objectAtIndex:0] objectForKey:@"address_components"] &&
            [[[[placemark objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0] isEqualToString: @"street_address"])
        {
            NSArray * addressComponents = [[placemark objectAtIndex:0] objectForKey:@"address_components"];

            // Get Street Address
            if ([[[[addressComponents objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"street_number"])
            {
                addressLine1 = [NSString stringWithFormat:@"%@ %@", [[addressComponents objectAtIndex:0] objectForKey:@"long_name"],[[addressComponents objectAtIndex:1] objectForKey:@"long_name"]];
            }

            // Get City
            if ( [[[[addressComponents objectAtIndex:2] objectForKey:@"types"] objectAtIndex:0]isEqualToString:@"administrative_area_level_3"] ||
                 [[[[addressComponents objectAtIndex:2] objectForKey:@"types"] objectAtIndex:1]isEqualToString:@"administrative_area_level_3"] )
            {
                city = [[addressComponents objectAtIndex:2] objectForKey:@"long_name"];
            }
            else if ([[[[addressComponents objectAtIndex:3] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_3"] ||
                     [[[[addressComponents objectAtIndex:3] objectForKey:@"types"] objectAtIndex:1] isEqualToString:@"administrative_area_level_3"] )
            {
                city = [[addressComponents objectAtIndex:3] objectForKey:@"long_name"];
            }

            // Get State
            if ( [[[[addressComponents objectAtIndex:4] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_1"] ||
                 [[[[addressComponents objectAtIndex:4] objectForKey:@"types"] objectAtIndex:1] isEqualToString:@"administrative_area_level_1"] )
            {
                state = [[addressComponents objectAtIndex:4] objectForKey:@"short_name"];
            }
            else if ([[[[addressComponents objectAtIndex:5] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_1"] ||
                     [[[[addressComponents objectAtIndex:5] objectForKey:@"types"] objectAtIndex:1] isEqualToString:@"administrative_area_level_1"] )
            {
                state = [[addressComponents objectAtIndex:5] objectForKey:@"short_name"];
            }

            // Get ZIP
            if ([[[[addressComponents objectAtIndex:4] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"postal_code"])
            {
                zipcode = [[addressComponents objectAtIndex:4] objectForKey:@"short_name"];
            }
            else if ([[[[addressComponents objectAtIndex:5] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"postal_code"])
            {
                zipcode = [[addressComponents objectAtIndex:5] objectForKey:@"short_name"];
            }
            else if ([[[[addressComponents objectAtIndex:6] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"postal_code"])
            {
                zipcode = [[addressComponents objectAtIndex:6] objectForKey:@"short_name"];
            }
            else if ([[[[addressComponents objectAtIndex:7] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"postal_code"])
            {
                zipcode = [[addressComponents objectAtIndex:7] objectForKey:@"short_name"];
            }
        }

        // Get Country
        if ( [[placemark objectAtIndex:1] objectForKey:@"address_components"] &&
            [[[[placemark objectAtIndex:1] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"postal_code"])
        {
            NSArray * addressComponents2 = [[placemark objectAtIndex:1] objectForKey:@"address_components"];
            NSUInteger lastObject = [addressComponents2 count] - 1;

            // Country should always be "US", but adding this code just to make sure
            if ([[addressComponents2 objectAtIndex:lastObject] objectForKey:@"short_name"])
            {
                country = [[addressComponents2 objectAtIndex:lastObject] objectForKey:@"short_name"];
                if ([country rangeOfString:@"US"].location == NSNotFound)
                {
                    country = @"NOT US";
                }
            }
            else
            {
                country = @"USA";
            }
        }

        //NSLog(@"1.) ADDRESS NOW IS: %@, %@, %@, %@, %@",addressLine1,city, state, zipcode, country);

        // Old method of parsing by getting entire formatted address and breaking it down
        if ([addressLine1 length] < 2 && [city length] < 2 && [zipcode length] < 5)
        {
            NSString * addr = [[placemark objectAtIndex:0] objectForKey:@"formatted_address"];

            NSLog(@"addr is: %@", addr);

            NSArray *addrParse = [addr componentsSeparatedByString:@","];

            if ([addrParse count] == 4)
            {
                addressLine1 = [addrParse objectAtIndex:0];
                city = [addrParse objectAtIndex:1];
                state = [[addrParse objectAtIndex:2] substringToIndex:3];
                zipcode = [[addrParse objectAtIndex:2] substringFromIndex:3];
                country = [addrParse objectAtIndex:3];
            }
            else if ([addrParse count] > 4)
            {
                addressLine1 = [addrParse objectAtIndex:0];
                addressLine2 = [addrParse objectAtIndex:1];
                city = [addrParse objectAtIndex:2];
                state = [[addrParse objectAtIndex:3] substringToIndex:3];
                zipcode = [[addrParse objectAtIndex:3] substringFromIndex:3];
                country = [addrParse objectAtIndex:4];
            }
            else
            {
                addressLine1 = [addrParse objectAtIndex:0];
                addressLine2 = @"";
                city = [addrParse objectAtIndex:1];
            }

            NSLog(@"2.) ADDRESS NOW IS: %@, %@, %@, %@, %@",addressLine1,city, state, zipcode, country);
        }
    }

    // In case any of the above components is still not set
    if ([city rangeOfString:@"null"].location != NSNotFound || city == NULL) {
        city = @"";
    }
    if ([state rangeOfString:@"null"].location != NSNotFound || state == NULL) {
        state = @"";
    }
    if ([zipcode rangeOfString:@"null"].location != NSNotFound || zipcode == NULL) {
        zipcode = @"";
    }
    if ([addressLine1 rangeOfString:@"null"].location != NSNotFound || addressLine1 == NULL) {
        addressLine1 = @"";
    }
    if ([addressLine2 rangeOfString:@"null"].location != NSNotFound || addressLine2 == NULL) {
        addressLine2 = @"";
    }
    if ([Altitude rangeOfString:@"null"].location != NSNotFound || Altitude == NULL) {
        Altitude = @"0.0";
    }
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.type isEqualToString:@"send"])
    {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    }
    else if([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"])
    {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;
    }

    int len = [textField.text length] + [string length];

    if ([string length] == 0)
    {
        switch (len) {
            case 4:
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 3:
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 2:
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 1:
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    else
    {
        UIColor * color;
        if ([self.type isEqualToString:@"send"] || [self.type isEqualToString:@"requestRespond"]) {
            color = kNoochGreen;
        }
        else if([self.type isEqualToString:@"request"] ){
            color = kNoochBlue;
        }

        switch (len) {
            case 5:
                return NO;
                break;
            case 4:
                [self.fourth_num setBackgroundColor:color];
                //start pin validation
                break;
            case 3:
                [self.third_num setBackgroundColor:color];
                break;
            case 2:
                [self.second_num setBackgroundColor:color];
                break;
            case 1:
                [self.first_num setBackgroundColor:color];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    
    if (len == 4)
    {
        NSString * textLoading=@"";
        if ([self.type isEqualToString:@"send"] || [self.type isEqualToString:@"requestRespond"]) {
            textLoading = @"Sending your payment...";
        }
        else if ([self.type isEqualToString:@"request"]) {
            textLoading = @"Generating your request...";
        }

        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        self.hud.labelText = textLoading;
        [self.hud show:YES];

        serve * pin = [serve new];
        pin.Delegate = self;
        pin.tagName = @"ValidatePinNumber";
        [pin getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
    }
    return YES;
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
     UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    dictResult= [NSJSONSerialization
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                 error:&error];

    if ([self.receiver valueForKey:@"nonuser"])
    {
        if ([tagName isEqualToString:@"ValidatePinNumber"])
        {
            encryptedPINNonUser = [dictResult valueForKey:@"Status"];
            serve *checkValid = [serve new];
            checkValid.tagName = @"checkValid";
            checkValid.Delegate = self;
            [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPINNonUser];
        }
        else if ([tagName isEqualToString:@"checkValid"])
        {
            if ([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"])
            {
                transactionInputTransfer = [[NSMutableDictionary alloc]init];

                if ([[assist shared] getTranferImage])
                {
                    NSData *data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
                    NSUInteger len = data.length;
                    uint8_t *bytes = (uint8_t *)[data bytes];
                    NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];

                    for (NSUInteger i = 0; i < len; i++) {
                        if (i) {
                            [result1 appendString:@","];
                        }
                        [result1 appendFormat:@"%d", bytes[i]];
                    }
                    NSArray*arr=[result1 componentsSeparatedByString:@","];
                    [transactionInputTransfer setValue:arr forKey:@"Picture"];
                }

                NSDate *date = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
                NSString *TransactionDate = [dateFormat stringFromDate:date];

                [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
                [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] forKey:@"DeviceId"];
                [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
                [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
                [transactionInputTransfer setValue:encryptedPINNonUser forKey:@"PinNumber"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
                [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
                [transactionInputTransfer setValue:Altitude forKey:@"Altitude"];
                [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
                [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
                [transactionInputTransfer setValue:city forKey:@"City"];
                [transactionInputTransfer setValue:state forKey:@"State"];
                [transactionInputTransfer setValue:country forKey:@"Country"];
                [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
 
                NSLog(@"SEND/REQUEST --> transactionInputTransfer #1 is: %@", transactionInputTransfer);
    
                if ([self.type isEqualToString:@"send"])
                {
                    if ([self.receiver objectForKey:@"email"])
                    {
                        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                transactionInputTransfer, @"transactionInput",
                                                [[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"], @"accessToken",
                                                @"personal",@"inviteType",
                                                [self.receiver objectForKey:@"email"],@"receiverEmailId", nil];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                               transactionInputTransfer, @"transactionInput",
                                               [[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"], @"accessToken",
                                               @"personal",@"inviteType",
                                               self.phone,@"receiverPhoneNumer", nil];
                    }
                }
                NSLog(@"SEND/REQUEST --> transactionInputTransfer #2 is: %@", transactionInputTransfer);
                if ([self.type isEqualToString:@"request"])
                {
                 /* transactionInputTransfer = [[NSMutableDictionary alloc]init];
                    if ([[assist shared] getTranferImage])
                    {
                        NSData *data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
                        NSUInteger len = data.length;
                        uint8_t *bytes = (uint8_t *)[data bytes];
                        NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];
                        
                        for (NSUInteger i = 0; i < len; i++) {
                            if (i) {
                                [result1 appendString:@","];
                            }
                            [result1 appendFormat:@"%d", bytes[i]];
                        }
                        NSArray*arr=[result1 componentsSeparatedByString:@","];
                        [transactionInputTransfer setValue:arr forKey:@"Picture"];
                    }


                    [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
                    [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
                    [transactionInputTransfer setValue:encryptedPINNonUser forKey:@"PinNumber"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];

                    NSDate *date = [NSDate date];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
                    NSString *TransactionDate = [dateFormat stringFromDate:date];

                    [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
                    [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
                    [transactionInputTransfer setValue:@"0.0" forKey:@"Altitude"];
                    [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
                    [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
                    [transactionInputTransfer setValue:city forKey:@"City"];
                    [transactionInputTransfer setValue:state forKey:@"State"];
                    [transactionInputTransfer setValue:country forKey:@"Country"];
                    [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
*/
                    // set 'RecepientId' (sic) to be the Sender's MemberID, this is how some Server methods identify a Request to a Non-Noocher
                    [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
                    [transactionInputTransfer setValue:@"" forKey:@"SenderId"];
                    [transactionInputTransfer setValue:@"Pending" forKey:@"TransactionStatus"];

                    NSString * receiverName = @"";
                    if ([self.receiver objectForKey:@"firstName"] && [self.receiver objectForKey:@"lastName"])
                    {
                        receiverName = [NSString stringWithFormat:@"%@ %@", [self.receiver objectForKey:@"firstName"], [self.receiver objectForKey:@"lastName"]];
                    }
                    else if ([self.receiver objectForKey:@"email"])
                    {
                        receiverName = [self.receiver valueForKey:@"email"];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        receiverName = [self.receiver valueForKey:@"phone"];
                    }
                    [transactionInputTransfer setValue:receiverName forKey:@"Name"];

                    if ([self.receiver objectForKey:@"email"])
                    {
                        [transactionInputTransfer setObject:[self.receiver objectForKey:@"email"] forKey:@"MoneySenderEmailId"];

                        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                    transactionInputTransfer, @"requestInput",
                                                    [[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
                    }
                    else if ([self.receiver objectForKey:@"phone"] )
                    {
                        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                               transactionInputTransfer, @"transactionInput",
                                               [[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"], @"accessToken",
                                               self.phone,@"receiverPhoneNumer", nil];
                    }
                }

                NSLog(@"SEND/REQUEST --> transactionINPUTTransfer #3 is: %@", transactionInputTransfer);
                NSLog(@"Type: %@ - transactionTransfer: %@", self.type, transactionTransfer);

                postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                               options:NSJSONWritingPrettyPrinted error:&error];;
                postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
                self.respData = [NSMutableData data];
                urlStrTranfer = [[NSString alloc] initWithString:MyUrl];

                if ([self.type isEqualToString:@"request"])
                {
                    if ([self.receiver objectForKey:@"email"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoneyFromNonNoochUserUsingKnox"];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyToNonNoochUserThroughPhoneUsingKnox"];
                    }
                }
                else if ([self.type isEqualToString:@"send"])
                {
                    if ([self.receiver objectForKey:@"email"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyToNonNoochUserUsingKnox"];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyToNonNoochUserThroughPhoneUsingKnox"];
                    }
                }


                urlTransfer = [NSURL URLWithString:urlStrTranfer];
                requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
                [requestTransfer setHTTPMethod:@"POST"];
                [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
                [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [requestTransfer setHTTPBody:postTransfer];
                requestTransfer.timeoutInterval=12000;

                NSLog(@"SEND/REQUEST --> requestTransfer is: %@", requestTransfer);

                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
                if (connection) {
                    self.respData = [NSMutableData data];
                }
            }
            else
            {
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                self.pin.text=@"";
            }
            
            if ([[dictResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
            {
                [spinner stopAnimating];
                [spinner setHidden:YES];
                [self.hud hide:YES];

                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                self.fourth_num.layer.borderColor = kNoochRed.CGColor;
                self.third_num.layer.borderColor = kNoochRed.CGColor;
                self.second_num.layer.borderColor = kNoochRed.CGColor;
                self.first_num.layer.borderColor = kNoochRed.CGColor;
                [self.fourth_num setStyleClass:@"shakePin4"];
                [self.third_num setStyleClass:@"shakePin3"];
                [self.second_num setStyleClass:@"shakePin2"];
                [self.first_num setStyleClass:@"shakePin1"];

                self.prompt.text=@"1 failed attempt. Please try again.";
                self.prompt.textColor = kNoochRed;

            }
            else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
            {
                [spinner stopAnimating];
                [spinner setHidden:YES];
                [self.hud hide:YES];

                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                self.fourth_num.layer.borderColor = kNoochRed.CGColor;
                self.third_num.layer.borderColor = kNoochRed.CGColor;
                self.second_num.layer.borderColor = kNoochRed.CGColor;
                self.first_num.layer.borderColor = kNoochRed.CGColor;
                [self.fourth_num setStyleClass:@"shakePin4"];
                [self.third_num setStyleClass:@"shakePin3"];
                [self.second_num setStyleClass:@"shakePin2"];
                [self.first_num setStyleClass:@"shakePin1"];

                self.prompt.text=@"2nd Failed Attempt";
                self.prompt.textColor = kNoochRed;
            }
            else if (([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))
            {
                [spinner stopAnimating];
                [spinner setHidden:YES];
                [self.hud hide:YES];

                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Account Suspended"
                                                             message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:@"Contact Support",nil];
                [av setTag:50];
                [av show];

                [[assist shared] setSusPended:YES];

                self.fourth_num.layer.borderColor = kNoochRed.CGColor;
                self.third_num.layer.borderColor = kNoochRed.CGColor;
                self.second_num.layer.borderColor = kNoochRed.CGColor;
                self.first_num.layer.borderColor = kNoochRed.CGColor;
                [self.fourth_num setStyleClass:@"shakePin4"];
                [self.third_num setStyleClass:@"shakePin3"];
                [self.second_num setStyleClass:@"shakePin2"];
                [self.first_num setStyleClass:@"shakePin1"];

                self.prompt.text=@"Account suspended.";
                self.prompt.textColor = kNoochRed;
            }
            else if (([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))
            {
                [spinner stopAnimating];
                [spinner setHidden:YES];
                [self.hud hide:YES];

                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Account Suspended"
                                                             message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:@"Contact Support",nil];
                [av setTag:50];
                [av show];

                [[assist shared] setSusPended:YES];

                self.prompt.text = @"Account suspended.";
                self.prompt.textColor = kNoochRed;
            }
        }
    }

    else if ([self.type isEqualToString:@"send"] || [self.type isEqualToString:@"request"])
    {
        if ([tagName isEqualToString:@"ValidatePinNumber"])
        {
            transactionInputTransfer = [[NSMutableDictionary alloc]init];

            if ([[assist shared] getTranferImage])
            {
                NSData *data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
                NSUInteger len = data.length;
                uint8_t *bytes = (uint8_t *)[data bytes];
                NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];
                for (NSUInteger i = 0; i < len; i++)
                {
                    if (i) {
                        [result1 appendString:@","];
                    }
                    [result1 appendFormat:@"%d", bytes[i]];
                }
                NSArray *arr = [result1 componentsSeparatedByString:@","];
                [transactionInputTransfer setValue:arr forKey:@"Picture"];
            }

            [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
            [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
            if ([self.type isEqualToString:@"request"])
            {
                [transactionInputTransfer setValue:@"Request" forKey:@"TransactionType"];
                if ([[assist shared]isRequestMultiple])
                {
                    receiverId = @"";
                    for (NSDictionary *dictRecord in [[assist shared]getArray]) {
                        receiverId=[receiverId stringByAppendingString:[NSString stringWithFormat:@",%@",dictRecord[@"MemberId"]]];
                    }
 
                    receiverId=[receiverId substringFromIndex:1];
                    [transactionInputTransfer setValue:receiverId forKey:@"SenderId"];
                }
                else
                    [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"SenderId"];
                    [transactionInputTransfer setValue:@"Pending" forKey:@"TransactionStatus"];
            }
            else
            {
                [transactionInputTransfer setValue:@"Transfer" forKey:@"TransactionType"];
                [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
            }

            NSString * receiverName = [[self.receiver valueForKey:@"FirstName"] stringByAppendingString:[NSString stringWithFormat:@" %@",[self.receiver valueForKey:@"LastName"]]];
            [transactionInputTransfer setValue:receiverName forKey:@"Name"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];

            NSDate * date = [NSDate date];
            NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
            NSString * TransactionDate = [dateFormat stringFromDate:date];

            NSLog(@"SEND/REQUEST --> transactionInputTransfer A) is: %@", transactionInputTransfer);
            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
            if ([self.type isEqualToString:@"request"]) {
                transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"requestInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
            }
            else {
                transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
            }
            NSLog(@"SEND/REQUEST --> transactionInputTransfer B) is: %@", transactionInputTransfer);

        }

        NSLog(@"TransactionTransfer Object is: %@",transactionTransfer);

        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];;
        postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        if ([self.type isEqualToString:@"request"]) {
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoney"];
        }
        else {
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyUsingKnox"];
        }
        urlTransfer = [NSURL URLWithString:urlStrTranfer];

        NSLog(@"SEND/REQUEST --> urlStrTranfer is: %@", urlStrTranfer);

        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        NSLog(@"SEND/REQUEST --> requestTransfer is: %@", requestTransfer);

        requestTransfer.timeoutInterval=12000;
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        NSLog(@"NSURLConnection is: %@", connection);
        if (connection) {
            self.respData = [NSMutableData data];
        }

    }

    else if ([self.type isEqualToString:@"requestRespond"])
    {
        if ([tagName isEqualToString:@"ValidatePinNumber"])
        {
            transactionInputTransfer = [[NSMutableDictionary alloc]init];
            [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
            [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
            [transactionInputTransfer setValue:[self.receiver objectForKey:@"TransactionId"] forKey:@"TransactionId"];

            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
            NSString *TransactionDate = [dateFormat stringFromDate:date];
            
            if ([[self.receiver objectForKey:@"response"] isEqualToString:@"accept"])
            {
                [transactionInputTransfer setValue:@"Success" forKey:@"Status"];
            } 
            else if ([[self.receiver objectForKey:@"response"] isEqualToString:@"deny"])
            {
                [transactionInputTransfer setValue:@"Cancelled" forKey:@"Status"];
            }

            NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];

            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"RequestRespond" forKey:@"TransactionType"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];

            transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"handleRequestInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
        }

        NSLog(@"TransactionTransfer Object is: %@", transactionTransfer);

        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];;
        postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];

        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"HandleRequestMoney"];
        urlTransfer = [NSURL URLWithString:urlStrTranfer];

        
        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];
        NSLog(@"requestTransfer is: %@", requestTransfer);
        requestTransfer.timeoutInterval=12000;
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        NSLog(@"NSURLConnection is: %@", connection);
        if (connection) {
            self.respData = [NSMutableData data];
        }
        return;
    }

    /*else if ([self.type isEqualToString:@"donation"])
    {
        if ([tagName isEqualToString:@"ValidatePinNumber"])
        {
            transactionInputTransfer=[[NSMutableDictionary alloc]init];
            [transactionInputTransfer setValue:@"Donation" forKey:@"TransactionType"];

            [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
            [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
            [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];

            NSString *receiveName = [[self.receiver valueForKey:@"FirstName"] stringByAppendingString:[NSString stringWithFormat:@" %@",[self.receiver valueForKey:@"LastName"]]];
            [transactionInputTransfer setValue:receiveName forKey:@"Name"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];

            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];

            NSString *TransactionDate = [dateFormat stringFromDate:date];
            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];

            transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
        }
    
        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];
        postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoney"];
        urlTransfer = [NSURL URLWithString:urlStrTranfer];
        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];
        requestTransfer.timeoutInterval=70;
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        if (connection) {
            self.respData = [NSMutableData data];
        }
    }*/

    if (self.receiver[@"Photo"] !=NULL && ![self.receiver[@"Photo"] isKindOfClass:[NSNull class]])
    {
        [transactionInputTransfer setObject:self.receiver[@"Photo"]forKey:@"Photo"];
    }
    else if (self.receiver[@"PhotoUrl"] !=NULL && ![self.receiver[@"PhotoUrl"] isKindOfClass:[NSNull class]])
        [transactionInputTransfer setObject:self.receiver[@"PhotoUrl"]forKey:@"Photo"];
    
    if ([self.type isEqualToString:@"donation"] && self.receiver[@"PhotoIcon"] != NULL && ![self.receiver[@"PhotoIcon"] isKindOfClass:[NSNull class]])
    {
        [transactionInputTransfer setObject:self.receiver[@"PhotoIcon"]forKey:@"Photo"];
    }
    self.trans = [transactionInputTransfer copy];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            [nav_ctrl popToRootViewControllerAnimated:YES];
        }
        else if (buttonIndex == 1)
        {
            [nav_ctrl popToRootViewControllerAnimated:NO];
            NSMutableDictionary *input = [self.trans mutableCopy];
            
            if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"] &&
                [[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]])
            {
                NSString *MemberId = [input valueForKey:@"MemberId"];
                NSString *ResID = [input valueForKey:@"SenderId"];
                [input setObject:MemberId forKey:@"RecepientId"];
                [input setObject:ResID forKey:@"MemberId"];
                NSLog(@"Input: %@",input);
                [input setObject:dictResultTransfer[@"requestId"] forKey:@"TransactionId"];
            }
            else  if ([self.type isEqualToString:@"send"])
            {
                 [input setObject:dictResultTransfer[@"trnsactionId"] forKey:@"TransactionId"];
            }

            if ([self.receiver objectForKey:@"nonuser"])
            {
                if ([self.receiver objectForKey:@"firstName"] && [self.receiver objectForKey:@"lastName"])
                {
                    NSString * fullName = [NSString stringWithFormat:@"%@ %@", [self.receiver objectForKey:@"firstName"], [self.receiver objectForKey:@"lastName"]];
                    [input setObject:fullName forKey:@"InvitationSentTo"];
                }
                else if ([self.receiver objectForKey:@"firstName"])
                {
                    [input setObject:[self.receiver objectForKey:@"email"] forKey:@"InvitationSentTo"];
                }
                else if ([self.receiver objectForKey:@"email"])
                {
                    [input setObject:[self.receiver objectForKey:@"email"] forKey:@"InvitationSentTo"];
                }
                else if ([self.receiver objectForKey:@"phone"])
                {
                    [input setObject:[self.receiver objectForKey:@"phone"] forKey:@"InvitationSentTo"];
                }

                if ([self.type isEqualToString:@"request"])
                {
                    [input setObject:@"InviteRequest" forKey:@"TransactionType"];
                    [input setObject:dictResultTransfer[@"requestId"] forKey:@"TransactionId"];
                }
                else
                {
                    [input setObject:@"Invite" forKey:@"TransactionType"];
                    [input setObject:dictResultTransfer[@"trnsactionId"] forKey:@"TransactionId"];
                    [input setObject:@"Pending" forKey:@"TransactionStatus"];
                }
            }
            NSLog(@"Input: %@",input);
            TransactionDetails *td = [[TransactionDetails alloc] initWithData:input];
            [nav_ctrl pushViewController:td animated:YES];
        }
    }
    else if (alertView.tag == 2500)
    {
        if (buttonIndex == 0) {
            [nav_ctrl popToRootViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 20230)
    {
        if (buttonIndex == 0) {
            [nav_ctrl popToRootViewControllerAnimated:YES];
        }
    }
    else if ((alertView.tag == 50 || alertView.tag == 51 || alertView.tag == 52) && buttonIndex == 1)
    {
        if (![MFMailComposeViewController canSendMail])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
    else if (alertView.tag == 50 && buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - connection handling
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.respData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.respData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.hud hide:YES];
    responseString = [[NSString alloc] initWithData:self.respData encoding:NSASCIIStringEncoding];
    NSError * error;
    dictResultTransfer = [NSJSONSerialization
                         JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];

    NSLog(@"This is the response:  %@",responseString);
    if ([self.receiver valueForKey:@"nonuser"])
    {
        if ([[[dictResultTransfer valueForKey:@"TransferMoneyToNonNoochUserUsingKnoxResult"] valueForKey:@"Result"]isEqualToString:@"Your cash was sent successfully"])
        {
            [[assist shared] setTranferImage:nil];
            UIImage * imgempty = [UIImage imageNamed:@""];
            [[assist shared] setTranferImage:imgempty];
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Great Success"
                                                          message:@"\xF0\x9F\x91\x8D\nYour transfer was sent successfully.\n\nThe recipient must accept this payment by linking a bank account. We will contact them and let you know when they respond."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"View Details",nil];
            av.tag = 1;
            [av show];
            return;
        }
        if ([[[dictResultTransfer valueForKey:@"RequestMoneyFromNonNoochUserUsingKnoxResult"] valueForKey:@"Result"]isEqualToString:@"Request made successfully."])
        {
            [[assist shared] setTranferImage:nil];
            UIImage * imgempty = [UIImage imageNamed:@""];
            [[assist shared] setTranferImage:imgempty];
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Great Success"
                                                          message:@"\xF0\x9F\x91\x8D\nYour request was sent successfully.\n\nThe recipient can pay this request by clicking the link we emailed to them.\n\nThey do not have to download this app to pay the request (but they totally can too)."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"View Details",nil];
            av.tag = 1;
            [av show];
            return;
        }
    }
    
    if ([self.type isEqualToString:@"send"])
    {
        if (![[dictResultTransfer objectForKey:@"trnsactionId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"trnsactionId"];
    }
    else if([self.type isEqualToString:@"request"])
    {
        if (![[dictResultTransfer objectForKey:@"requestId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"requestId"];
    }
    NSLog(@"%@",transactionId);
    
    if ([self.receiver valueForKey:@"FirstName"] != NULL || [self.receiver valueForKey:@"LastName"] != NULL)
    {
        [transactionInputTransfer setObject:[self.receiver valueForKey:@"FirstName"] forKey:@"FirstName"];
        [transactionInputTransfer setObject:[self.receiver valueForKey:@"LastName"] forKey:@"LastName"]; 
    }

    self.trans = [transactionInputTransfer copy];
    resultValueTransfer = [dictResultTransfer valueForKey:@"TransferMoneyUsingKnoxResult"];

    if ([[resultValueTransfer valueForKey:@"Result"] isEqualToString:@"Recepient does not have any active bank account."])
    {
         UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Transfer Failed"
                                                      message:@"\xF0\x9F\x98\xA9\nThe recepient has a Nooch account, but has not linked a bank funding source yet, so they can't receive transfers quite yet!"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK",nil];
         [av show];
    }
    else if ([[resultValueTransfer valueForKey:@"Result"] isEqualToString:@"Your cash was sent successfully"])
    {
        [[assist shared] setTranferImage:nil];
        UIImage * imgempty = [UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];

        int randNum = arc4random() % 14;
        UIAlertView *av;
        NSString * alertTitleFromArtisan = [ARPowerHookManager getValueForHookById:@"transSuccessAlertTitle"];
        NSString * alertMsgFromArtisan = [ARPowerHookManager getValueForHookById:@"transSuccessAlertMsg"];
        switch (randNum) {
            case 0:
                av = [[UIAlertView alloc] initWithTitle:@"Nice Work"
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x98\x8E\nYou just sent money to %@, and you did it with style… and class.",[receiverFirst capitalizedString]]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details",nil];
                break;
            case 1:
                av = [[UIAlertView alloc] initWithTitle:@"Payment Sent"
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x92\xB8\nYour money has successfully been digitalized into pixie dust and is currently floating over our heads in a million pieces on its way to %@.",[receiverFirst capitalizedString]]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details",nil];
                break;
            case 2:
                av = [[UIAlertView alloc] initWithTitle:@"Success"
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x98\x89\nYou have officially 'Nooched' %@. That's right, it's a verb.",[receiverFirst capitalizedString]]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 3:
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                message:@"\xE2\x98\xBA\nYou now have less money. Eh, it's just money."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 4:
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                message:@"\xF0\x9F\x91\x8F\nYour debt burden has been lifted!"
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 5:
                av = [[UIAlertView alloc] initWithTitle:@"Money Sent"
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x98\x87\nNo need to thank us, it's our job.\n\n%@ should probably thank you though.",[receiverFirst capitalizedString]]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 6:
                av = [[UIAlertView alloc] initWithTitle:@"Payment Sent"
                                                message:@"\xF0\x9F\x91\x8D\nYou are now free to close Nooch and put your phone away. You're good to go." delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 7:
                av = [[UIAlertView alloc] initWithTitle:@"You're Welcome"
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x91\x8C\nThat was some good Nooching. Money sent to %@.",[receiverFirst capitalizedString]]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 8:
                av = [[UIAlertView alloc] initWithTitle:@"Great Scott!"
                                                message:@"\xE2\x9A\xA1\nThis sucker generated 1.21 gigawatts and sent your money, even without plutonium."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details", nil];
                break;
            case 9:
                av = [[UIAlertView alloc] initWithTitle:@"Knowledge Is Power"
                                                message:@"You know how easy Nooch is. But with great power, comes great responsibility..."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 10:
                av = [[UIAlertView alloc] initWithTitle:@"Humpty Dumpty Sat on a Wall"
                                                message:@"And processed Nooch transfers."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details", nil];
                break;
            case 11:
                av = [[UIAlertView alloc] initWithTitle:@"Nooch Haiku"
                                                message:@"Nooch application.\nEasy, Simple, Convenient.\nGetting the job done." delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
            case 12:
                av = [[UIAlertView alloc] initWithTitle:@"Nooch Loves You"
                                                message:@"\xF0\x9F\x92\x99\nThat is all. Pay it forward.\n\n...and yes, Nooch's heart is actually blue."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details",nil];
                break;
            case 13:
                av = [[UIAlertView alloc] initWithTitle:@"Easy As Pie"
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x8D\xB0\nWasn't that easier than lugging to an ATM and forking over colored pieces of paper to %@?",[receiverFirst capitalizedString]]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details",nil];
                break;
            case 14:
                av = [[UIAlertView alloc] initWithTitle:alertTitleFromArtisan
                                                message:alertMsgFromArtisan
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details",nil];
                break;
            default:
                av = [[UIAlertView alloc] initWithTitle:@"Nice Work"
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x92\xB8\nYour cash was sent successfully to %@.",[receiverFirst capitalizedString]]
                                               delegate:self cancelButtonTitle:@"OK"
                                      otherButtonTitles:@"View Details" ,nil];
                break;
        }
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
        [av setTag:1];
        
    }
    else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request processed successfully."])
    {
        [[assist shared] setTranferImage:nil];
        UIImage * imgempty = [UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];

        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Request Fulfilled"
                                                      message:[NSString stringWithFormat:@"\xF0\x9F\x91\x8D\nYou successfully fulfilled %@'s request for $%.02f.",[receiverFirst capitalizedString],self.amnt]
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }
    /* else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully declined."])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Denied"
                                                     message:[NSString stringWithFormat:@"You successfully denied %@'s request for $%.02f.",[receiverFirst capitalizedString],self.amnt]
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }
    else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully cancelled."])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Cancelled"
                                                     message:[NSString stringWithFormat:@"You successfully cancelled your request for $%.02f from %@.",self.amnt,[receiverFirst capitalizedString]]
                                                    delegate:self cancelButtonTitle:nil
                                           otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }*/
    else if ([[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request made successfully."])
    {
        [[assist shared] setTranferImage:nil];
        UIImage * imgempty = [UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];

        if ([[assist shared]isRequestMultiple])
        {
            [[assist shared]setRequestMultiple:NO];
            NSString * strMultiple = @"";
            for (NSDictionary *dictRecord in [[assist shared]getArray])
            {
                strMultiple = [strMultiple stringByAppendingString:[NSString stringWithFormat:@", %@",[dictRecord[@"FirstName"] capitalizedString]]];
            }

            strMultiple = [strMultiple substringFromIndex:1];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pay Me"
                                                         message:[NSString stringWithFormat:@"You requested $%.02f from %@ successfully.",self.amnt,strMultiple]
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK",nil];
            [av setTag:1];
            [av show];
        }
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pay Me"
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x98\x80\nYou requested $%.02f from %@ successfully.",self.amnt,[receiverFirst capitalizedString]]
                                                        delegate:self
                                               cancelButtonTitle:nil otherButtonTitles:@"OK",@"View Details",nil];
            [av setTag:1];
            [av show];
        }
    }
    else if ([[[dictResultTransfer objectForKey:@"TransferMoneyUsingKnoxResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."] ||
             [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]||[[dictResultTransfer valueForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."] ||
             [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]||
             [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        self.prompt.textColor = kNoochRed;
        self.prompt.text=@"1 failed attempt. Please try again.";
        self.fourth_num.layer.borderColor = kNoochRed.CGColor;
        self.third_num.layer.borderColor = kNoochRed.CGColor;
        self.second_num.layer.borderColor = kNoochRed.CGColor;
        self.first_num.layer.borderColor = kNoochRed.CGColor;
        [self.fourth_num setStyleClass:@"shakePin4"];
        [self.third_num setStyleClass:@"shakePin3"];
        [self.second_num setStyleClass:@"shakePin2"];
        [self.first_num setStyleClass:@"shakePin1"];
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";
    }
    else if ([[resultValueTransfer valueForKey:@"Result"] isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]
            || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]
            || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
    {
        self.prompt.text = @"2nd failed attempt";
        self.fourth_num.layer.borderColor = kNoochRed.CGColor;
        self.third_num.layer.borderColor = kNoochRed.CGColor;
        self.second_num.layer.borderColor = kNoochRed.CGColor;
        self.first_num.layer.borderColor = kNoochRed.CGColor;
        [self.fourth_num setStyleClass:@"shakePin4"];
        [self.third_num setStyleClass:@"shakePin3"];
        [self.second_num setStyleClass:@"shakePin2"];
        [self.first_num setStyleClass:@"shakePin1"];
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";

        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:@""
                                                              message:@"\xE2\x9A\xA0\n\nTo protect your account, your Nooch account will be suspended for 24 hours if you enter another incorrect PIN."
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
        [suspendedAlert show];
        [suspendedAlert setTag:9];
    }
    else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])
    {
        [[assist shared]setSusPended:YES];
        self.prompt.text=@"3rd failed attempt";
        self.fourth_num.layer.borderColor = kNoochRed.CGColor;
        self.third_num.layer.borderColor = kNoochRed.CGColor;
        self.second_num.layer.borderColor = kNoochRed.CGColor;
        self.first_num.layer.borderColor = kNoochRed.CGColor;
        [self.fourth_num setStyleClass:@"shakePin4"];
        [self.third_num setStyleClass:@"shakePin3"];
        [self.second_num setStyleClass:@"shakePin2"];
        [self.first_num setStyleClass:@"shakePin1"];
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";

        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:@"\xE2\x9B\x94"
                                                              message:@"We're terribly sorry, but to keep Nooch safe, your account has been suspended for 24 hours. Please contact us anytime at support@nooch.com if you believe this was a mistake or would like more information."
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:@"Contact Support",nil];
        [suspendedAlert setTag:50];
        [suspendedAlert show];
    }
    else if ([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Receiver does not exist."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Transfer Error #1350"
                                                     message:@"\xF0\x9F\x98\xB3\nLooks like we screwed up. We hate when this happens - sorry for the delay!\n\nPlease try making your transfer again or contact us if the problem persists."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:@"Contact Support",nil];
        [av setTag:51];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
    }

    else
    {
        NSString *resultValue = [dictResultTransfer objectForKey:@"RaiseDisputeResult"];
        if ([resultValue valueForKey:@"Result"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:[resultValue valueForKey:@"Result"]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
            return;
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error #2650"
                                                         message:@"\xF0\x9F\x98\xB3\nUnfortunately something is not quite right. This is a polite way of saying we screwed up.\n\nPlease try your transfer again or contact us if the problem persists."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:@"Contact Support",nil];
            [av setTag:52];
            [av show];
            return;
        }

        transferFinished = YES;
        sendingMoney = NO;
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end