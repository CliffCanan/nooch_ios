//  TransferPIN.m
//  Nooch
//
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "TransferPIN.h"
#import <QuartzCore/QuartzCore.h>
#import "GetLocation.h"
#import "HistoryFlat.h"
#import "TransactionDetails.h"
#import "UIImageView+WebCache.h"
#import "SelectRecipient.h"
#import <AudioToolbox/AudioToolbox.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "addBank.h"
#import "SettingsOptions.h"

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
        //NSLog(@"PIN: self.receiver is: %@", receiver);
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

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setTitle:NSLocalizedString(@"EnterPIN_ScrnTitle", @"Enter PIN Screen Title")];
    [self.navigationItem setHidesBackButton:YES];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToHowMuch)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

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

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 60)];
    [title setText:NSLocalizedString(@"EnterPIN_InstructionTxt", @"Enter PIN Screen instruction text")]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"pin_instructiontext"];
    [self.view addSubview:title];

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
        [self.prompt setText:NSLocalizedString(@"EnterPIN_InstructTransfer", @"Enter PIN Screen instructions transfer")];
        [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
    }
    else if ([self.type isEqualToString:@"request"])
    {
        [self.prompt setText:NSLocalizedString(@"EnterPIN_InstructRequest", @"Enter PIN Screen instructions request")];
        [self.prompt setStyleId:@"pin_instructiontext_request"];
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
            short numOfChars = [[self.receiver objectForKey:@"firstName"] length] + [[self.receiver objectForKey:@"lastName"] length];
            if (numOfChars > 23) {numOfChars = 23;}

            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",[self.receiver objectForKey:@"firstName"],[self.receiver objectForKey:@"lastName"]] attributes:textAttributes];

            [glyph_nonuserType setFrame:CGRectMake(198 + ((numOfChars * 10) / 2), 198, 20, 38)];
            [self.view addSubview:glyph_nonuserType];
        }
        else if ([self.receiver objectForKey:@"firstName"])
        {
            short numOfChars = [[self.receiver objectForKey:@"firstName"] length];

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
        [memo_label setText:NSLocalizedString(@"EnterPIN_NoMemoTxt", @"Enter PIN Screen no memo attached text")];
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

    if ([self.type isEqualToString:@"send"])
    {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;        
    }
    else
    {
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

    if ([[assist shared] checkIfTouchIdAvailable] &&
        [[user objectForKey:@"requiredTouchId"] boolValue] == YES)
    {
        LAContext *context = [[LAContext alloc] init];

        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Are you the owner of this device?"
                          reply:^(BOOL success, NSError *error) {
                              if (success)
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                      message:@"You are the device owner!"
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  });
                              }
                              else if (error)
                              {
                                  NSLog(@"TouchID Error is: %ld",(long)error.code);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      NSString * alertBody, * alertTitle;
                                      if (error.code == LAErrorUserCancel || error.code == LAErrorSystemCancel)
                                      {
                                          alertTitle = @"TouchID Cancelled";
                                          alertBody = @"You have TouchID turned on for making payments. To turn this off, please go to Nooch's settings and select \"Security Settings\".";
                                      }
                                      else if (error.code == LAErrorTouchIDNotAvailable)
                                      {
                                          alertTitle = @"TouchID Not Available";
                                          alertBody = @"";
                                      }
                                      else if (error.code == LAErrorUserFallback)
                                      {
                                          alertTitle = @"TouchID Password Not Set";
                                          alertBody = @"You have TouchID turned on for making payments. To turn this off, please go to Nooch's settings and select \"Security Settings\".";
                                      }
                                      else if (error.code == LAErrorAuthenticationFailed)
                                      {
                                          alertTitle = @"Oh No!";
                                          alertBody = @"It seems like you are not the device owner! Please try verifying your fingerprint again.\n\nTo turn this off, please go to Nooch's settings and select \"Security Settings\".";
                                      }
                                      else
                                      {
                                          alertTitle = @"TouchID Error";
                                          alertBody = @"There was a problem verifying your identity.\n\nYou have TouchID turned on for making payments. To turn this off, please go to Nooch's settings and select \"Security Settings\".";
                                      }
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                                      message:alertBody
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                      
                                      [self backToHowMuch];
                                  });
                                  return;
                              }
                              else
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      NSString * alertBody;
                                      if ([[user objectForKey:@"requiredTouchId"] boolValue] == YES)
                                      {
                                          alertBody = @"You have TouchID turned on for making payments. To turn this off, please go to Nooch's settings and select \"Security Settings\".";
                                      }
                                      else
                                      {
                                          alertBody = @"You are not the device owner.";
                                      }
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TouchID Error"
                                                                                      message:alertBody
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      [alert show];

                                      [self backToHowMuch];
                                  });
                              }
                          }];
    }

    [[assist shared] setneedsReload:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"TransferPin Screen";
    self.artisanNameTag = @"TransferPIN Screen";
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

#pragma mark - Helper Methods
-(void)backToHowMuch
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

NSString * calculateArrivalDate()
{
    NSDate *date = [NSDate date];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    [dateFormat setDateFormat:@"E"];
    NSString * dateString = [dateFormat stringFromDate:date];

    NSDateFormatter * timeFormat = [[NSDateFormatter alloc] init];
    timeFormat.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    [timeFormat setDateFormat:@"k"];
    short timeOfDay = [[timeFormat stringFromDate:date] intValue];

    //NSLog(@"Today's Day of Week: %@", dateString);
    NSLog(@"Time of Day (Hour) is: %d", timeOfDay);

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    short achXtraDays = [[ARPowerHookManager getValueForHookById:@"knox_xtraTime"] intValue];

    if ([dateString isEqualToString:@"Mon"] ||
        [dateString isEqualToString:@"Tue"] ||
        [dateString isEqualToString:@"Wed"])
    {
        if (timeOfDay < 15) // its BEFORE 3:00pm EST
        {
            [offsetComponents setDay: (1 + achXtraDays)];
        }
        else // its AFTER 3:00pm EST
        {
            if ([dateString isEqualToString:@"Mon"] ||
                [dateString isEqualToString:@"Tue"])
            {
                [offsetComponents setDay:(2 + achXtraDays)];
            }
            else if ([dateString isEqualToString:@"Wed"])
            {
                if (achXtraDays == 0)
                {
                    [offsetComponents setDay:2]; // arrive by Friday
                }
                else if (achXtraDays == 1)
                {
                    [offsetComponents setDay:5]; // arrive by Monday
                }
                else
                {
                    [offsetComponents setDay:(5 + achXtraDays)];
                }
            }
        }
    }
    else if ([dateString isEqualToString:@"Thu"])
    {
        if (timeOfDay < 15) // its BEFORE 3:00pm EST
        {
            if (achXtraDays == 0)
            {
                [offsetComponents setDay:1]; // arrive by Friday
            }
            else if (achXtraDays == 1)
            {
                [offsetComponents setDay:4]; // arrive by Monday
            }
            else
            {
                [offsetComponents setDay:(4 + achXtraDays)];
            }
        }
        else // its AFTER 3:00pm EST
        {
            [offsetComponents setDay:(4 + achXtraDays)];
        }
    }
    else if ([dateString isEqualToString:@"Fri"])
    {
        if (timeOfDay < 15) // its BEFORE 3:00pm EST
        {
            [offsetComponents setDay:(3 + achXtraDays)];
        }
        else // its AFTER 3:00pm EST
        {
            [offsetComponents setDay:(4 + achXtraDays)];
        }
    }
    else if ([dateString isEqualToString:@"Sat"])
    {
        [offsetComponents setDay:(3 + achXtraDays)];
    }
    else if ([dateString isEqualToString:@"Sun"])
    {
        [offsetComponents setDay:(2 + achXtraDays)];
    }

    NSDate * arrivalDate = [[[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar] dateByAddingComponents:offsetComponents
                            toDate:date options:0];

    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EEEEdMMMM" // e.g.: "Monday, March 15"
                                                             options:0
                                                              locale:[NSLocale currentLocale]];
    NSDateFormatter * finalDateFormatter = [[NSDateFormatter alloc] init];
    finalDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    [finalDateFormatter setDateFormat:formatString];

    NSString * arrivalDateFormatted = [finalDateFormatter stringFromDate:arrivalDate];



    NSTimeZone * systimeZone = [NSTimeZone systemTimeZone];
    NSString * timeZoneString = [systimeZone localizedName:NSTimeZoneNameStyleGeneric locale:[NSLocale currentLocale]];

    [ARProfileManager registerString:@"Time_Zone" withValue:timeZoneString];

    return arrivalDateFormatted;
}

-(void)errorAlerts:(NSString *)referenceNumber
{
    NSDictionary * dictionary = @{@"MemberId": [user valueForKey:@"MemberId"],
                                  @"errorAlertNumber": referenceNumber};
    [ARTrackingManager trackEvent:@"TrnsfrPIN_ErrorAlert_Displayed" parameters:dictionary];

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"EnterPIN_ErrorAlrtTitle", @"Enter PIN Screen error Alert Title"),referenceNumber]
                                                 message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB3\n%@", NSLocalizedString(@"EnterPIN_ErrorAlrtBody", @"Enter PIN Screen error alert Body Text")]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:NSLocalizedString(@"EnterPIN_ContactSupportBtn", @"Enter PIN Screen account suspended Alert Button Contact Support"),nil];
    [av setTag:52];
    [av show];
}

#pragma mark - Location Delegates
-(void)transferPinLocationUpdateManager:(CLLocationManager *)manager
                     didUpdateLocations:(NSArray *)locationsArray
{
    if (lat == 0 || lon == 0)
    {
        CLLocationCoordinate2D loc = manager.location.coordinate;
        lat = [[[NSString alloc] initWithFormat:@"%f",loc.latitude] floatValue];
        lon = [[[NSString alloc] initWithFormat:@"%f",loc.longitude] floatValue];

        latitude = [NSString stringWithFormat:@"%f",lat];
        longitude = [NSString stringWithFormat:@"%f",lon];

        [self updateLocation:[NSString stringWithFormat:@"%f",lat]
          longitudeField:[NSString stringWithFormat:@"%f",lon]];
    }
}

-(void)updateLocation:(NSString*)latitudeField
       longitudeField:(NSString*)longitudeField
{
    // The parameter 'result_type = locality' below makes Google return only a City level address. Since that's all we need, we shouldn't ask for everything, which can be a lot more unnecessary data from Google parsing the variations of the address
    NSString * googleGeocodeUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&result_type=locality&key=AIzaSyDrUnX1gGpPL9fWmsWfhOxIDIy3t7YjcEY", latitudeField, longitudeField];

    NSURL * url = [NSURL URLWithString:googleGeocodeUrl];

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response, NSData *data, NSError *err) {
        NSError * error;
        googleLocationResults = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
        [self setLocation];
    }];
}

-(void)locationError:(NSError *)error
{
    NSLog(@"LocationManager didFailWithError %@", error);
}

-(void)setLocation
{
    NSArray * addressResults = [googleLocationResults objectForKey:@"results"];

    if (![[googleLocationResults objectForKey:@"status"] isEqualToString:@"OK"])
    {
        NSLog(@"Google Geocode Results Error --> Status is: %@", [googleLocationResults objectForKey:@"status"]);

        if ([googleLocationResults objectForKey:@"error_message"])
        {
            NSLog(@"Google Geocode Error Message: %@",[googleLocationResults objectForKey:@"error_message"]);
        }
    }
    else if ([addressResults count] > 0)
    {
        // if Google returned a City
        if (  [[addressResults objectAtIndex:0] objectForKey:@"address_components"] &&
            [[[[addressResults objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0] isEqualToString: @"locality"])
        {
            NSArray * address_components = [[addressResults objectAtIndex:0] objectForKey:@"address_components"];

            // Get City
            if ( [[[[address_components objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"locality"] ||
                 [[[[address_components objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_3"])
            {
                city = [[address_components objectAtIndex:0] objectForKey:@"long_name"];
            }
            else if ( [[[[address_components objectAtIndex:1] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"locality"] ||
                      [[[[address_components objectAtIndex:1] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_3"])
            {
                city = [[address_components objectAtIndex:1] objectForKey:@"long_name"];
            }
            // There was no city/locality, so attempt to grab the County instead
            else if ( [[[[address_components objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_2"])
            {
                city = [[address_components objectAtIndex:0] objectForKey:@"long_name"];
            }
            else if ([[[[address_components objectAtIndex:1] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_2"])
            {
                city = [[address_components objectAtIndex:1] objectForKey:@"long_name"];
            }

            // Get State
            if ( [[[[address_components objectAtIndex:1] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_1"])
            {
                state = [[address_components objectAtIndex:1] objectForKey:@"short_name"];
            }
            else if ([[[[address_components objectAtIndex:2] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_1"])
            {
                state = [[address_components objectAtIndex:2] objectForKey:@"short_name"];
            }

            // Get Country
            if ([[[[address_components objectAtIndex:3] objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"country"])
            {
                if ([[address_components objectAtIndex:3] objectForKey:@"short_name"])
                {
                    country = [[address_components objectAtIndex:3] objectForKey:@"short_name"];
                    if ([country rangeOfString:@"US"].location == NSNotFound)
                    {
                        country = [@"NOT US" stringByAppendingFormat:@" - %@", country];
                    }
                }
                else
                {
                    country = @"US of A";
                }
            }
        }
    }

    // In case any of the above components is still not set
    if ([city rangeOfString:@"null"].location != NSNotFound || city == NULL) {
        city = @"";
    }
    if ([state rangeOfString:@"null"].location != NSNotFound || state == NULL) {
        state = @"";
    }
    if ([country rangeOfString:@"null"].location != NSNotFound || country == NULL) {
        country = @"";
    }
    if ([addressLine1 rangeOfString:@"null"].location != NSNotFound || addressLine1 == NULL) {
        addressLine1 = @"";
    }

    //NSLog(@"Full Address Is: %@, %@, %@, %@", addressLine1, city, state, country);
}

#pragma mark - UITextField delegation
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.type isEqualToString:@"send"])
    {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    }
    else if ([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"])
    {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;
    }

    short len = [textField.text length] + [string length];

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
        else if ([self.type isEqualToString:@"request"] ){
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
        if ([[assist shared] getSuspended])
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Account Suspended"
                                                            message:@"Your account has been suspended pending a review. Please email support@nooch.com if you believe this was a mistake and we will be glad to help."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Contact Support", nil];
            [alert setTag:53];
            [alert show];
        }

        else if (![user boolForKey:@"IsSynapseBankAvailable"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Connect A Funding Source \xF0\x9F\x92\xB0"
                                                         message:@"To make a payment, you must attach a bank account first - it's lightning quick!\n\n• No routing or account number needed\n• Bank-grade encryption keeps your info safe\n\nWould you like to take care of this now?"
                                                        delegate:self
                                               cancelButtonTitle:@"Later"
                                               otherButtonTitles:@"Go Now", nil];
            [av setTag:11];
            [av show];
        }

        else if (![user boolForKey:@"IsSynapseBankVerified"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Bank Account Un-Verified"
                                                         message:@"Looks like your bank account remains un-verified.  This usually happens when the contact info listed on the bank account does not match your Nooch profile information. Please contact Nooch support for more information."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:@"Learn More", nil];
            [av setTag:54];
            [av show];
        }

        else
        {
            NSString * textLoading=@"";
            if ([self.type isEqualToString:@"send"] || [self.type isEqualToString:@"requestRespond"])
            {
                textLoading = NSLocalizedString(@"EnterPIN_HUDlblSend", @"Enter PIN Screen HUD label text for sending a payment");
            }
            else if ([self.type isEqualToString:@"request"])
            {
                textLoading = NSLocalizedString(@"EnterPIN_HUDlblRequest", @"Enter PIN Screen HUD label text for sending a request");
            }

            RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
            spinner1.color = [UIColor whiteColor];
            self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:self.hud];

            self.hud.mode = MBProgressHUDModeCustomView;
            self.hud.customView = spinner1;
            self.hud.delegate = self;
            self.hud.labelText = textLoading;
            self.hud.detailsLabelText = nil;
            [self.hud show:YES];

            serve * pin = [serve new];
            pin.Delegate = self;
            pin.tagName = @"ValidatePinNumber";
            [pin getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Server Response Handling
-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    NSDictionary * dictResult = [NSJSONSerialization
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
            [checkValid pinCheck:[user stringForKey:@"MemberId"] pin:encryptedPINNonUser];
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

                    for (NSUInteger i = 0; i < len; i++)
                    {
                        if (i) {
                            [result1 appendString:@","];
                        }
                        [result1 appendFormat:@"%d", bytes[i]];
                    }

                    NSArray * arr = [result1 componentsSeparatedByString:@","];
                    [transactionInputTransfer setValue:arr forKey:@"Picture"];
                }

                NSDate * date = [NSDate date];
                NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
                NSString * TransactionDate = [dateFormat stringFromDate:date];

                [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
                [transactionInputTransfer setValue:[user objectForKey:@"DeviceToken"] forKey:@"DeviceId"];
                [transactionInputTransfer setValue:[user stringForKey:@"MemberId"] forKey:@"MemberId"];
                [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
                [transactionInputTransfer setValue:encryptedPINNonUser forKey:@"PinNumber"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
                [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
                [transactionInputTransfer setValue:@"0" forKey:@"Altitude"];
                [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
                [transactionInputTransfer setValue:@"" forKey:@"AddressLine2"];
                [transactionInputTransfer setValue:city forKey:@"City"];
                [transactionInputTransfer setValue:state forKey:@"State"];
                [transactionInputTransfer setValue:country forKey:@"Country"];
                [transactionInputTransfer setValue:@"" forKey:@"Zipcode"];

                if ([self.type isEqualToString:@"send"])
                {
                    if ([self.receiver objectForKey:@"email"])
                    {
                        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                transactionInputTransfer, @"transactionInput",
                                                [user valueForKey:@"OAuthToken"], @"accessToken",
                                                @"personal",@"inviteType",
                                                [self.receiver objectForKey:@"email"],@"receiverEmailId", nil];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                               transactionInputTransfer, @"transactionInput",
                                               [user valueForKey:@"OAuthToken"], @"accessToken",
                                               @"personal",@"inviteType",
                                               self.phone,@"receiverPhoneNumer", nil];
                    }
                }

                if ([self.type isEqualToString:@"request"])
                {
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
                                                    [user valueForKey:@"OAuthToken"],@"accessToken", nil];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                               transactionInputTransfer, @"requestInput",
                                               [user valueForKey:@"OAuthToken"], @"accessToken",
                                               self.phone,@"PayorPhoneNumber", nil];
                    }
                }

                NSLog(@"SEND/REQUEST --> transactionINPUTTransfer is: %@", transactionInputTransfer);
                NSLog(@"Type: %@ - transactionTransfer: %@", self.type, transactionTransfer);

                postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                               options:NSJSONWritingPrettyPrinted error:&error];;
                postLengthTransfer = [NSString stringWithFormat:@"%lu", (unsigned long)[postTransfer length]];
                self.respData = [NSMutableData data];
                urlStrTranfer = [[NSString alloc] initWithString:MyUrl];

                if ([self.type isEqualToString:@"request"])
                {
                    if ([self.receiver objectForKey:@"email"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoneyToNonNoochUserUsingSynapse"];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoneyToNonNoochUserThroughPhoneUsingSynapse"];
                    }
                }
                else if ([self.type isEqualToString:@"send"])
                {
                    if ([self.receiver objectForKey:@"email"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyToNonNoochUserUsingSynapse"];
                    }
                    else if ([self.receiver objectForKey:@"phone"])
                    {
                        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyToNonNoochUserThroughPhoneUsingsynapse"];
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

                self.prompt.text = NSLocalizedString(@"EnterPIN_IncorrectPin1x", @"Enter PIN Screen PIN entered incorrectly once text");
                self.prompt.textColor = kNoochRed;
            }
            else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
            {
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

                self.prompt.text = NSLocalizedString(@"EnterPIN_IncorrectPin2x", @"Enter PIN Screen PIN entered incorrectly twice text");
                self.prompt.textColor = kNoochRed;
            }
            else if (([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))
            {
                [self.hud hide:YES];

                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_AccntSuspAlertTitle", @"Enter PIN Screen account suspended Alert Title")
                                                             message:NSLocalizedString(@"EnterPIN_AccntSuspAlertBody", @"Enter PIN Screen account suspended Alert Body Text")
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:NSLocalizedString(@"EnterPIN_ContactSupportBtn", @"Enter PIN Screen account suspended Alert Button Contact Support"),nil];
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

                self.prompt.text = NSLocalizedString(@"EnterPIN_InstructAccntSusp", @"Enter PIN Screen account suspended Instruction Text");
                self.prompt.textColor = kNoochRed;
            }
            else if (([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))
            {
                [self.hud hide:YES];

                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_AccntSuspAlertTitle", @"Enter PIN Screen account suspended Alert Title")
                                                             message:NSLocalizedString(@"EnterPIN_AccntSuspAlertBody", @"Enter PIN Screen account suspended Alert Body Text")
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:NSLocalizedString(@"EnterPIN_ContactSupportBtn", @"Enter PIN Screen account suspended Alert Button Contact Support"),nil];
                [av setTag:50];
                [av show];

                [[assist shared] setSusPended:YES];

                self.prompt.text = NSLocalizedString(@"EnterPIN_InstructAccntSusp", @"Enter PIN Screen account suspended Instruction Text");
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
            [transactionInputTransfer setValue:[user stringForKey:@"MemberId"] forKey:@"MemberId"];
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

            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:@"" forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:@"" forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
            if ([self.type isEqualToString:@"request"])
            {
                transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"requestInput",[user valueForKey:@"OAuthToken"],@"accessToken", nil];
            }
            else
            {
                transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[user valueForKey:@"OAuthToken"],@"accessToken", nil];
            }

            //NSLog(@"SEND/REQUEST --> transactionInputTransfer is: %@", transactionInputTransfer);
        }

        NSLog(@"TransactionTransfer Object is: %@",transactionTransfer);

        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];;
        postLengthTransfer = [NSString stringWithFormat:@"%lu", (unsigned long)[postTransfer length]];
        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        if ([self.type isEqualToString:@"request"])
        {
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoney"];
        }
        else
        {
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyUsingSynapse"];
        }
        urlTransfer = [NSURL URLWithString:urlStrTranfer];

        NSLog(@"SEND/REQUEST --> urlStrTranfer is: %@", urlStrTranfer);

        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        //NSLog(@"SEND/REQUEST --> requestTransfer is: %@", requestTransfer);

        requestTransfer.timeoutInterval=12000;
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        //NSLog(@"NSURLConnection is: %@", connection);
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
            [transactionInputTransfer setValue:[user stringForKey:@"MemberId"] forKey:@"MemberId"];
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

            NSString *uid = [user objectForKey:@"DeviceToken"];

            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"RequestRespond" forKey:@"TransactionType"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:@"" forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:@"" forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];

            transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"handleRequestInput",[user valueForKey:@"OAuthToken"],@"accessToken", nil];
        }

        NSLog(@"TransactionTransfer Object is: %@", transactionTransfer);

        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];;
        postLengthTransfer = [NSString stringWithFormat:@"%lu", (unsigned long)[postTransfer length]];

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

    if (self.receiver[@"Photo"] != NULL && ![self.receiver[@"Photo"] isKindOfClass:[NSNull class]])
    {
        [transactionInputTransfer setObject:self.receiver[@"Photo"]forKey:@"Photo"];
    }
    else if (self.receiver[@"PhotoUrl"] != NULL && ![self.receiver[@"PhotoUrl"] isKindOfClass:[NSNull class]])
        [transactionInputTransfer setObject:self.receiver[@"PhotoUrl"]forKey:@"Photo"];
    
    if ([self.type isEqualToString:@"donation"] && self.receiver[@"PhotoIcon"] != NULL && ![self.receiver[@"PhotoIcon"] isKindOfClass:[NSNull class]])
    {
        [transactionInputTransfer setObject:self.receiver[@"PhotoIcon"]forKey:@"Photo"];
    }
    self.trans = [transactionInputTransfer copy];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"TrnsfrPIN_CnctnErrAlrtTitle", @"Transfer PIN screen 'Connection Error' Alert Text")
                          message:NSLocalizedString(@"TrnsfrPIN_CnctnErrAlrtBody", @"Transfer PIN screen Connection Error Alert Body Text")
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Connection Handling
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.respData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.respData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.hud hide:YES];
    responseString = [[NSString alloc] initWithData:self.respData encoding:NSASCIIStringEncoding];
    NSError * error;
    dictResultTransfer = [NSJSONSerialization
                         JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];

    NSLog(@"TransferPIN --> This is the response:  %@",responseString);


    if ([self.receiver valueForKey:@"nonuser"])
    {
        // Specific 'Result' Strings - SYNAPSE
        NSString * sendNonNoochUser_Email_SynapseResult = [[dictResultTransfer valueForKey:@"TransferMoneyToNonNoochUserUsingSynapseResult"] valueForKey:@"Result"];
        NSString * sendNonNoochUser_Phone_SynapseResult = [[dictResultTransfer valueForKey:@"TransferMoneyToNonNoochUserThroughPhoneUsingsynapseResult"] valueForKey:@"Result"];
        NSString * requestNonNoochUser_Email_SynapseResult = [[dictResultTransfer valueForKey:@"RequestMoneyToNonNoochUserUsingSynapseResult"] valueForKey:@"Result"];
        NSString * requestNonNoochUser_Phone_SynapseResult = [[dictResultTransfer valueForKey:@"RequestMoneyToNonNoochUserThroughPhoneUsingSynapseResult"] valueForKey:@"Result"];

        //NSLog(@"sendNonNoochUser_Email_SynapseResult is: %@",sendNonNoochUser_Email_SynapseResult);
        //NSLog(@"sendNonNoochUser_Phone_SynapseResult is: %@",sendNonNoochUser_Phone_SynapseResult);
        //NSLog(@"requestNonNoochUser_Email_SynapseResult is: %@",requestNonNoochUser_Email_SynapseResult);
        //NSLog(@"requestNonNoochUser_Phone_SynapseResult is: %@",requestNonNoochUser_Phone_SynapseResult);

        if ([sendNonNoochUser_Email_SynapseResult rangeOfString:@"successfully"].length != 0 ||
            [sendNonNoochUser_Phone_SynapseResult rangeOfString:@"successfully"].length != 0 ||
            [requestNonNoochUser_Email_SynapseResult rangeOfString:@"successfully"].length != 0 ||
            [requestNonNoochUser_Phone_SynapseResult rangeOfString:@"successfully"].length != 0 )
        {
            [[assist shared] setTranferImage:nil];
            UIImage * imgempty = [UIImage imageNamed:@""];
            [[assist shared] setTranferImage:imgempty];
            NSString * alertMsg = @"";
            if ([self.type isEqualToString:@"request"])
            {
                alertMsg = NSLocalizedString(@"EnterPIN_NonUsrSuccessAlrtTitle", @"Enter PIN Screen send to nonuser success Alert Body Text");
            }
            else
            {
                alertMsg = NSLocalizedString(@"EnterPIN_NonUsrRqstSuccessAlrtTitle", @"Enter PIN Screen request to nonuser success Alert Body Text");
            }
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_GrtSuccessAlrtTitle", @"Enter PIN Screen Great Success Alert Title")
                                                          message:[NSString stringWithFormat:@"\xF0\x9F\x91\x8D\n%@", alertMsg]
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
            av.tag = 1;
            [av show];
            return;
        }

        else if ([sendNonNoochUser_Email_SynapseResult rangeOfString:@"not have any bank added"].length != 0 ||
                 [sendNonNoochUser_Phone_SynapseResult rangeOfString:@"not have any bank added"].length != 0 ||
                 [requestNonNoochUser_Email_SynapseResult rangeOfString:@"not have any bank added"].length != 0 ||
                 [requestNonNoochUser_Phone_SynapseResult rangeOfString:@"not have any bank added"].length != 0)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_TrnsfrFaildAlrtTitle", @"Enter PIN Screen transfer failed Alert Title")
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x98\xA9\n%@", NSLocalizedString(@"EnterPIN_TrnsfrFaildAlrtBody", @"Enter PIN Screen transfer failed Alert Body Text")]
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK",nil];
            [av setTag:61];
            [av show];
            return;
        }

        // Per Transaction Limit Exceeded
        else if ([sendNonNoochUser_Email_SynapseResult rangeOfString:@"maximum amount you can"].length != 0 ||
                 [sendNonNoochUser_Phone_SynapseResult rangeOfString:@"maximum amount you can"].length != 0 ||
                 [requestNonNoochUser_Email_SynapseResult rangeOfString:@"maximum amount you can"].length != 0 ||
                 [requestNonNoochUser_Phone_SynapseResult rangeOfString:@"maximum amount you can"].length != 0)
        {
            NSString * transLimitFromArtisan = [ARPowerHookManager getValueForHookById:@"transLimit"];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoa Now"
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB3\nTo keep Nooch safe, please don’t send or request more than $%@. We hope to raise this limit very soon!",transLimitFromArtisan]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av setTag:31];
            [av show];
            return;
        }

        // Weekly Transaction Limit Exceeded (only matters for Sends/Invites not Requests
        else if ([sendNonNoochUser_Email_SynapseResult rangeOfString:@"Weekly transfer limit exceeded"].length != 0 ||
                 [sendNonNoochUser_Phone_SynapseResult rangeOfString:@"Weekly transfer limit exceeded"].length != 0)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Weekly Transfer Limit Exceeded"
                                                         message:@"\xF0\x9F\x98\xA5\nUnfortunately this transfer would put you over the weekly transfer limit. Please try sending a smaller amount, or wait until Monday to try again.\n\nVery sorry for the inconvenience - our limits are in place to protect all users and keep Nooch safe."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK",nil];
            [av setTag:32];
            [av show];
            return;
        }

        else if ([sendNonNoochUser_Email_SynapseResult rangeOfString:@"send money to the same user"].length != 0 ||
                 [sendNonNoochUser_Phone_SynapseResult rangeOfString:@"send money to the same user"].length != 0)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Very Sneaky"
                                                         message:@"\xF0\x9F\x98\xB1\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try sending money to someone ELSE!"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av setTag:71];
            [av show];
            return;
        }

        else if ([requestNonNoochUser_Email_SynapseResult rangeOfString:@"failed"].length != 0 ||
                 [requestNonNoochUser_Phone_SynapseResult rangeOfString:@"failed"].length != 0)
        {
            [self errorAlerts:@"420"];
            return;
        }

        else if (requestNonNoochUser_Phone_SynapseResult != NULL)
        {
            [self errorAlerts:@"421"];
            return;
        }

    }

    // Specific 'Result' Strings
    NSString * sendMoneyToExistingUserSynapseResult = [[dictResultTransfer valueForKey:@"TransferMoneyUsingSynapseResult"] valueForKey:@"Result"];
    NSString * makeRequestToExistingUserResult = [[dictResultTransfer objectForKey:@"RequestMoneyResult"] valueForKey:@"Result"];
    NSString * payRequestResult = [[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] valueForKey:@"Result"];

    if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"cash was sent successfully"].length != 0)
    {
        [[assist shared] setTranferImage:nil];
        UIImage * imgempty = [UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];

        int randNum = arc4random() % 15;

        NSString * alertTitleFromArtisan = [ARPowerHookManager getValueForHookById:@"transSuccessAlertTitle"];
        NSString * alertMsgFromArtisan = [ARPowerHookManager getValueForHookById:@"transSuccessAlertMsg"];
        
        NSString * arrivalDateAlone = calculateArrivalDate();
        NSString * arrivalDateForAlert = [NSString stringWithFormat:@"This payment will arrive by:\n%@", arrivalDateAlone];
        NSLog(@"arrivalDateForAlert is: %@", arrivalDateForAlert);

        UIAlertView *av;
        
        switch (randNum) {
            case 0:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt1", @"Enter PIN Screen success alert title - Nice Work")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x98\x8E\nYou just sent money to %@, and you did it with style… and class.\n\n%@",[receiverFirst capitalizedString], arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 1:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt2", @"Enter PIN Screen success alert title - Payment Sent")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x92\xB8\nYour money has successfully been digitalized into pixie dust and is currently floating over our heads in a million pieces on its way to %@.\n\n%@",[receiverFirst capitalizedString], arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 2:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt3", @"Enter PIN Screen success alert title - Success")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x98\x89\nYou have officially 'Nooched' %@. That's right, it's a verb.\n\n%@",[receiverFirst capitalizedString], arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details") ,nil];
                break;
            case 3:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt4", @"Enter PIN Screen success alert title - Congratulations")
                                                message:[NSString stringWithFormat:@"\xE2\x98\xBA\nYou now have less money. Eh, it's just money.\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 4:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt4", @"Enter PIN Screen success alert title - Congratulations")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x91\x8F\nYour debt burden has been lifted!\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 5:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt5", @"Enter PIN Screen success alert title - Money Sent")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x98\x87\nNo need to thank us, it's our job.\n\n%@ should probably thank you though.\n\n%@",[receiverFirst capitalizedString], arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 6:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt6", @"Enter PIN Screen success alert title - Payment Sent")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x91\x8D\nYou are now free to close Nooch and put your phone away. You're good to go.\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 7:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt7", @"Enter PIN Screen success alert title - Payment Sent")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x91\x8C\nThat was some good Nooching. Money sent to %@.\n\n%@",[receiverFirst capitalizedString], arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 8:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt8", @"Enter PIN Screen success alert title - Great Scott")
                                                message:[NSString stringWithFormat:@"\xE2\x9A\xA1\nThis sucker generated 1.21 gigawatts and sent your money, even without plutonium.\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"), nil];
                break;
            case 9:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt9", @"Enter PIN Screen success alert title - Knowledge Is Power")
                                                message:[NSString stringWithFormat:@"You know how easy Nooch is. But with great power, comes great responsibility...\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 10:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt10", @"Enter PIN Screen success alert title - Humpty Dumpty")
                                                message:[NSString stringWithFormat:@"And processed Nooch transfers.\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"), nil];
                break;
            case 11:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt11", @"Enter PIN Screen success alert title - Nooch Haiku")
                                                message:[NSString stringWithFormat:@"Nooch application.\nEasy, Simple, Convenient.\nGetting the job done.\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 12:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt12", @"Enter PIN Screen success alert title - Nooch Loves You")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x92\x99\nThat is all. Pay it forward.\n\n...and yes, Nooch's heart is actually blue.\n\n%@", arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 13:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt13", @"Enter PIN Screen success alert title - Easy As Pie")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x8D\xB0\nWasn't that easier than lugging to an ATM and forking over colored pieces of paper to %@?\n\n%@",[receiverFirst capitalizedString], arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            case 14:
                av = [[UIAlertView alloc] initWithTitle:alertTitleFromArtisan
                                                message:[NSString stringWithFormat:@"%@\n\n%@", alertMsgFromArtisan, arrivalDateForAlert]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
            default:
                av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_SuccessAlrt1", @"Enter PIN Screen success alert title - Nice Work")
                                                message:[NSString stringWithFormat:@"\xF0\x9F\x92\xB8\nYour cash was sent successfully to %@.\n\n%@",[receiverFirst capitalizedString], arrivalDateForAlert]
                                               delegate:self cancelButtonTitle:@"OK"
                                      otherButtonTitles:NSLocalizedString(@"EnterPIN_SuccessAlrtViewDetails", @"Enter PIN Screen success alert button for View Details"),nil];
                break;
        }

        [av setTag:1];
        [av show];
        return;
    }

    else if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"not have any active bank account"].length != 0 ||
             [sendMoneyToExistingUserSynapseResult rangeOfString:@"not linked to any bank account"].length != 0 ||
             [sendMoneyToExistingUserSynapseResult rangeOfString:@"Recepient does not have any verified bank account"].length != 0 ||
             [payRequestResult rangeOfString:@"not have any active bank account"].length != 0 ||
             [payRequestResult rangeOfString:@"not linked to any bank account"].length != 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_TrnsfrFaildAlrtTitle", @"Enter PIN Screen transfer failed Alert Title")
                                                     message:[NSString stringWithFormat:@"\xF0\x9F\x98\xA9\n%@", NSLocalizedString(@"EnterPIN_TrnsfrFaildAlrtBody", @"Enter PIN Screen transfer failed Alert Body Text")]
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK",nil];
        [av setTag:61];
        [av show];
        return;
    }

    // Per Transaction Limit Exceeded
    else if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"maximum amount you can send"].length != 0 ||
             [makeRequestToExistingUserResult rangeOfString:@"maximum amount you can"].length != 0)
    {
        NSString * transLimitFromArtisan = [ARPowerHookManager getValueForHookById:@"transLimit"];

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoa Now"
                                                     message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB3\nTo keep Nooch safe, please don’t send or request more than $%@. We hope to raise this limit very soon!",transLimitFromArtisan]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av setTag:31];
        [av show];
        return;
    }

    // Weekly Transaction Limit Exceeded
    else if ([payRequestResult rangeOfString:@"Weekly transfer limit exceeded"].length != 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Weekly Transfer Limit Exceeded"
                                                     message:@"\xF0\x9F\x98\xA5\nUnfortunately this transfer would put you over the weekly transfer limit. Please try sending a smaller amount, or wait until Monday to try again.\n\nVery sorry for the inconvenience - our limits are in place to protect all users and keep Nooch safe."
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK",nil];
        [av setTag:32];
        [av show];
        return;
    }

    // Per Transaction Limit Exceeded
    else if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"send money to the same user"].length != 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Very Sneaky"
                                                     message:@"\xF0\x9F\x98\xB1\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try sending money to someone ELSE!"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av setTag:71];
        [av show];
        return;
    }
    else if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"user details not found"].length != 0)
    {
        [self errorAlerts:@"510"];
        return;
    }
    else if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"Sender does not have any verified bank account"].length != 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Bank Account Un-Verified"
                                                     message:@"Looks like your bank account remains un-verified.  This usually happens when the contact info listed on the bank account does not match your Nooch profile information. Please contact Nooch support for more information."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:@"Learn More", nil];
        [av setTag:54];
        [av show];
        return;
    }

    // Making a Request to an Existing User
    else if ([makeRequestToExistingUserResult rangeOfString:@"successfully"].length != 0)
    {
        [[assist shared] setTranferImage:nil];
        UIImage * imgempty = [UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];
        
        if ([[assist shared] isRequestMultiple])
        {
            [[assist shared] setRequestMultiple:NO];
            NSString * strMultiple = @"";
            for (NSDictionary * dictRecord in [[assist shared]getArray])
            {
                strMultiple = [strMultiple stringByAppendingString:[NSString stringWithFormat:@", %@",[dictRecord[@"FirstName"] capitalizedString]]];
            }
            
            strMultiple = [strMultiple substringFromIndex:1];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_RequestSuccessAlrtTitle", @"Enter PIN Screen request made successfully Alert Title")
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x98\x80\nYou requested $%.02f from %@ successfully.",self.amnt,strMultiple]
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK",nil];
            [av setTag:1];
            [av show];
        }
        else
        {
            NSLog(@"Request to 1 existing user ALERT");
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_RequestSuccessAlrtTitle", @"Enter PIN Screen request made successfully Alert Title")
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x98\x80\nYou requested $%.02f from %@ successfully.",self.amnt,[receiverFirst capitalizedString]]
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK",@"View Details",nil];
            [av setTag:1];
            [av show];
        }
    }

    else if ([makeRequestToExistingUserResult rangeOfString:@"Not allowed to request money from yourself"].length != 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Very Sneaky"
                                                     message:@"\xF0\x9F\x98\xB1\nYou are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!\n\nPlease try requesting money from someone ELSE!"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av setTag:71];
        [av show];
        return;
    }


    // Paying a Request From An Existing User
    else if ([payRequestResult rangeOfString:@"successfully"].length != 0)
    {
        [[assist shared] setTranferImage:nil];
        UIImage * imgempty = [UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];

        NSString * arrivalDateAlone = calculateArrivalDate();
        NSString * arrivalDateForAlert = [NSString stringWithFormat:@"This payment will arrive by:\n%@", arrivalDateAlone];

        UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPIN_RequestFulfilledAlertTitle", @"Enter PIN Screen request fulfilled successfully Alert Title")
                                                      message:[NSString stringWithFormat:@"\xF0\x9F\x91\x8D\nYou successfully fulfilled %@'s request for $%.02f.\n\n%@",[receiverFirst capitalizedString],self.amnt,arrivalDateForAlert]
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }

    else if ([payRequestResult rangeOfString:@"No such request exists"].length != 0)
    {
        [self errorAlerts:@"610"];
    }

    else if ([payRequestResult rangeOfString:@"Internal error"].length != 0)
    {
        [self errorAlerts:@"620"];
    }

    // PIN-related errors common to all methods
    else if ([sendMoneyToExistingUserSynapseResult isEqualToString:@"PIN number you have entered is incorrect."] ||
             [makeRequestToExistingUserResult isEqualToString:@"PIN number you have entered is incorrect."] ||
             [payRequestResult isEqualToString:@"PIN number you have entered is incorrect."] ||
             [[dictResultTransfer valueForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        self.prompt.textColor = kNoochRed;
        self.prompt.text = NSLocalizedString(@"EnterPIN_IncorrectPin1x", @"Enter PIN Screen PIN entered incorrectly once text");
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
        return;
    }

    else if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"PIN number you entered again is incorrect"].length != 0 ||
             [makeRequestToExistingUserResult rangeOfString:@"PIN number you entered again is incorrect"].length != 0 ||
             [payRequestResult rangeOfString:@"PIN number you entered again is incorrect"].length != 0)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        self.prompt.text = NSLocalizedString(@"EnterPIN_IncorrectPin2x", @"Enter PIN Screen PIN entered incorrectly twice text");
        self.prompt.textColor = kNoochRed;
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
                                                              message:@"\xE2\x9A\xA0\n\nTo protect your account and prevent unauthorized payments, your Nooch account will be suspended for 24 hours if you enter another incorrect PIN."
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [suspendedAlert show];
        return;
    }

    else if ([sendMoneyToExistingUserSynapseResult rangeOfString:@"Your account has been suspended for 24 hours from now"].length != 0 ||
             [makeRequestToExistingUserResult rangeOfString:@"Your account has been suspended for 24 hours from now"].length != 0 ||
             [payRequestResult rangeOfString:@"Your account has been suspended for 24 hours from now"].length != 0)
    {
        [[assist shared]setSusPended:YES];
        self.prompt.text = NSLocalizedString(@"EnterPIN_InstructAccntSusp", @"Enter PIN Screen account suspended Instruction Text");
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
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:NSLocalizedString(@"EnterPIN_ContactSupportBtn", @"Enter PIN Screen account suspended Alert Button Contact Support"),nil];
        [suspendedAlert setTag:50];
        [suspendedAlert show];
        return;
    }

    else if ([sendMoneyToExistingUserSynapseResult isEqualToString:@"Receiver does not exist."] ||
             [makeRequestToExistingUserResult rangeOfString:@"user does not exist"].length != 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Transfer Error #423"
                                                     message:@"\xF0\x9F\x98\xB3\nLooks like we screwed up. We hate when this happens - sorry for the delay!\n\nPlease try making your transfer again or contact us if the problem persists."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:NSLocalizedString(@"EnterPIN_ContactSupportBtn", @"Enter PIN Screen account suspended Alert Button Contact Support"),nil];
        [av setTag:51];
        [av show];
    }

    else if ([makeRequestToExistingUserResult rangeOfString:@"failed"].length != 0 ||
             [payRequestResult rangeOfString:@"failed"].length != 0)
    {
        [self errorAlerts:@"710"];
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
        }
        else
        {
            [self errorAlerts:@"430"];
        }
    }


    if ([self.type isEqualToString:@"send"])
    {
        if (![[dictResultTransfer objectForKey:@"trnsactionId"] isKindOfClass:[NSNull class]])
        {
            transactionId = [dictResultTransfer valueForKey:@"trnsactionId"];
        }
    }
    else if([self.type isEqualToString:@"request"])
    {
        if (![[dictResultTransfer objectForKey:@"requestId"] isKindOfClass:[NSNull class]])
        {
            transactionId = [dictResultTransfer valueForKey:@"requestId"];
        }
    }
    //NSLog(@"Transaction ID: %@",transactionId);
    
    if ([self.receiver valueForKey:@"FirstName"] != NULL || [self.receiver valueForKey:@"LastName"] != NULL)
    {
        [transactionInputTransfer setObject:[self.receiver valueForKey:@"FirstName"] forKey:@"FirstName"];
        [transactionInputTransfer setObject:[self.receiver valueForKey:@"LastName"] forKey:@"LastName"];
    }
    
    self.trans = [transactionInputTransfer copy];
}

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#pragma mark - Alert View Handling

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            NSLog(@"buttonIndex was 0");
            [nav_ctrl popToRootViewControllerAnimated:YES];
        }

        else if (buttonIndex == 1)
        {
            NSMutableDictionary *input = [self.trans mutableCopy];

            if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"] &&
                [[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]])
            {
                NSString *MemberId = [input valueForKey:@"MemberId"];
                NSString *ResID = [input valueForKey:@"SenderId"];
                [input setObject:MemberId forKey:@"RecepientId"];
                [input setObject:ResID forKey:@"MemberId"];
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

            NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];

            for (short i = [arrNav count]; i > 1; i--)
            {
                [arrNav removeLastObject];
            }

            isFromTransferPIN = YES;

            HistoryFlat * mainHistoryScreen = [HistoryFlat new];
            [arrNav addObject: mainHistoryScreen];
            [nav_ctrl setViewControllers:arrNav animated:NO];

            //NSLog(@"TransferPIN -> nav_ctrl.viewControllers is: %@", nav_ctrl.viewControllers);

            TransactionDetails *td = [[TransactionDetails alloc] initWithData:input];
            [nav_ctrl pushViewController:td animated:YES];
        }
    }

    // Contact Support alerts
    else if ((alertView.tag == 50 || alertView.tag == 51 ||
              alertView.tag == 52 || alertView.tag == 53) &&
             buttonIndex == 1)
    {
        if (buttonIndex == 1)
        {
            if (![MFMailComposeViewController canSendMail])
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                              message:@"You don't have an email account configured for this device."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
                [av show];
                return;
            }

            NSString * memberId = [user valueForKey:@"MemberId"];
            NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
            NSString * userStatus = [user objectForKey:@"Status"];
            NSString * userEmail = [user objectForKey:@"UserName"];
            NSString * IsVerifiedPhone = [[user objectForKey:@"IsVerifiedPhone"] lowercaseString];
            NSString * iOSversion = [[UIDevice currentDevice] systemVersion];
            NSString * msgBody = [NSString stringWithFormat:@"<!doctype html> <html><body><br><br><br><br><br><br><small>• MemberID: %@<br>• Name: %@<br>• Status: %@<br>• Email: %@<br>• Is Phone Verified: %@<br>• iOS Version: %@<br></small></body></html>",memberId, fullName, userStatus, userEmail, IsVerifiedPhone, iOSversion];

            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            mailComposer.navigationBar.tintColor=[UIColor whiteColor];
            [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
            [mailComposer setMessageBody:msgBody isHTML:YES];
            [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
            [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
            [mailComposer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        else if (buttonIndex == 0)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }

    else if (alertView.tag == 54 && buttonIndex == 1) // No Bank attached, go to Settings
    {
        shouldDisplayBankNotVerifiedLtBox = YES;
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
    }

    else if (alertView.tag == 11 && buttonIndex == 1) // Bank Not Verified - go to Settings
    {
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
    }

    else if (alertView.tag == 31 || alertView.tag == 32) // Attempt to send more than transaction limit (on server), go back to How Much screen
    {
        [self backToHowMuch];
    }

    else if (alertView.tag == 61)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

    else if (alertView.tag == 71) // Attempt to send to self, go back to Select Recipient screen
    {
        [self.navigationItem setLeftBarButtonItem:nil];
        NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];

        SelectRecipient * selectRecipScrn = [SelectRecipient new];
        [arrNav replaceObjectAtIndex:[arrNav count]-2 withObject:selectRecipScrn];
        
        [nav_ctrl setViewControllers:arrNav animated:NO];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Mail Controller
-(void) mailComposeController:(MFMailComposeViewController *)controller
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

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end