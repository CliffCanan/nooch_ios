//  HowMuch.m
//  Nooch
//
//  Created by crks on 9/26/13.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "HowMuch.h"
#import "TransferPIN.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "SelectRecipient.h"
@interface HowMuch ()
@property(nonatomic,strong) NSDictionary *receiver;
@property(nonatomic,strong) UITextField *amount;
@property(nonatomic,strong) UITextField *memo;
@property(nonatomic,strong) UIButton *camera;
@property(nonatomic,strong) UIButton *send;
@property(nonatomic,strong) UIButton *request;
@property(nonatomic,strong) UIButton *reset_type;
@property(nonatomic) NSMutableString *amnt;
@property(nonatomic) BOOL decimals;
@property(nonatomic,strong) UIView *shade;
@property(nonatomic,strong) UIView *choose;
@property(nonatomic,strong) UIImageView *divider;
@property(nonatomic,strong) UILabel *recip_back;
@property(nonatomic,strong) UIView *back;
@property(nonatomic,strong) UIButton *trans_image;
@property(nonatomic,strong) UIImageView * user_pic;

@end

@implementation HowMuch

- (id)initWithReceiver:(NSDictionary *)receiver
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.receiver = [receiver copy];
        NSLog(@"Selected Recipient is: %@",self.receiver);
    }
    return self;
}

-(void)backPressed:(id)sender
{
    [[assist shared]setRequestMultiple:NO];
    [arrRecipientsForRequest removeAllObjects];
    [[assist shared]setArray:nil];

    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"How Much?"];
    [self.navigationItem setHidesBackButton:YES];

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
    [self.navigationItem setRightBarButtonItem:Nil];

    [[assist shared] setTranferImage:nil];

    self.amnt = [@"" mutableCopy];
    
    self.decimals = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .3;
    [self.view addSubview:backgroundImage];

    self.back = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 248)];
    [self.back setStyleClass:@"raised_view"];

    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [self.back setStyleClass:@"howmuch_mainbox_smscrn"];
    }
    else {
        [self.back setStyleClass:@"howmuch_mainbox"];
    }
    self.back.layer.cornerRadius = 4;
    [self.back setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.back];

    self.recip_back = [UILabel new];
    [self.recip_back setStyleClass:@"barbackground"];
    [self.recip_back setStyleClass:@"barbackground_gray"];
    self.recip_back.clipsToBounds = YES;
    [self.back addSubview:self.recip_back];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(64, 65, 66, .3);
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    UILabel * to = [UILabel new];
    to.attributedText = [[NSAttributedString alloc] initWithString:@"To: " attributes:textAttributes];
    [to setStyleId:@"label_howmuch_to"];
    [self.back addSubview:to];

    UILabel * to_label = [[UILabel alloc] initWithFrame:CGRectMake(43, 0, 300, 38)];
    if ([self.receiver valueForKey:@"nonuser"])
    {
        [to_label setStyleId:@"label_howmuch_recipientnamenonuser"];

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
            float numOfChars = [[self.receiver objectForKey:@"firstName"] length] + [[self.receiver objectForKey:@"lastName"] length];

            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [self.receiver objectForKey:@"firstName"], [self.receiver objectForKey:@"lastName"]] attributes:textAttributes];

            [glyph_nonuserType setFrame:CGRectMake(52 + numOfChars * 10, 1, 20, 37)];
            [self.back addSubview:glyph_nonuserType];
        }
        else if ([self.receiver objectForKey:@"firstName"])
        {
            float numOfChars = [[self.receiver objectForKey:@"firstName"] length];

            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self.receiver objectForKey:@"firstName"]] attributes:textAttributes];

            [glyph_nonuserType setFrame:CGRectMake(52 + numOfChars * 10, 1, 20, 37)];
            [self.back addSubview:glyph_nonuserType];
        }
        else if ([self.receiver objectForKey:@"email"])
        {
            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self.receiver objectForKey:@"email"]] attributes:textAttributes];
        }
        else if ([self.receiver objectForKey:@"phone"])
        {
            to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self.receiver objectForKey:@"phone"]] attributes:textAttributes];
        }
    }
    else
    {
        if ([[assist shared]isRequestMultiple])
        {
            NSString * strMultiple = @"";

            if ([[[assist shared]getArray] count] > 1)
            {
                for (NSDictionary * dictRecord in [[assist shared]getArray])
                {
                    strMultiple = [strMultiple stringByAppendingString:[NSString stringWithFormat:@", %@",[dictRecord[@"FirstName"] capitalizedString]]];
                }

                [to_label setStyleId:@"label_howmuch_recipientnamenonuser"];
                strMultiple = [strMultiple substringFromIndex:1];
            }
            else
            {
                for (NSDictionary * dictRecord in [[assist shared]getArray])
                {
                    strMultiple = [NSString stringWithFormat:@"%@ %@", dictRecord[@"FirstName"], dictRecord[@"LastName"]];
                }
                [to_label setStyleId:@"label_howmuch_recipientname"];
            }

            to_label.attributedText = [[NSAttributedString alloc] initWithString:[strMultiple capitalizedString] attributes:textAttributes];
        }
        else
        {
            [to_label setStyleId:@"label_howmuch_recipientname"];

            if (isFromMyApt && [self.receiver objectForKey:@"AptName"])
            {
                to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self.receiver objectForKey:@"AptName"]] attributes:textAttributes];
            }
            else if ([self.receiver objectForKey:@"FirstName"])
            {
                to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [[self.receiver objectForKey:@"FirstName"] capitalizedString],[[self.receiver objectForKey:@"LastName"] capitalizedString]]
                                                                          attributes:textAttributes];
            }
        }
    }
    [self.back addSubview:to_label];

    if (![self.receiver valueForKey:@"nonuser"] && !isUserByLocation && !isFromMyApt)
    {
        UIButton * add = [[UIButton alloc]initWithFrame:CGRectMake(272, 15, 32, 30)];
        [add addTarget:self action:@selector(addRecipient:) forControlEvents:UIControlEventTouchUpInside];
        [add setStyleClass:@"addbutton_request"];
        [add setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-square"] forState:UIControlStateNormal];
        [add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [add setTitleColor:Rgb2UIColor(220, 221, 222, .94) forState:UIControlStateHighlighted];
        [add setTitleShadowColor:Rgb2UIColor(64, 65, 66, 0.3) forState:UIControlStateNormal];
        add.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.view addSubview:add];
    }

    self.user_pic = [UIImageView new];
    [self.user_pic setFrame:CGRectMake(12, 48, 84, 84)];
    self.user_pic.layer.borderColor = kNoochGrayLight.CGColor;
    self.user_pic.layer.borderWidth = 2;
    self.user_pic.clipsToBounds = YES;
    self.user_pic.layer.cornerRadius = 42;
    if ([self.receiver valueForKey:@"nonuser"])
    {
        [self.user_pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    else
    {
        [self.user_pic setHidden:NO];
        if (self.receiver[@"Photo"])
        {
            [self.user_pic sd_setImageWithURL:[NSURL URLWithString:self.receiver[@"Photo"]]
                     placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        }
        else
        {
            if ([[[assist shared]getArray] count] == 1)
            {
                NSString * photoURL = @"";
                for (NSDictionary * dictRecord in [[assist shared]getArray])
                {
                    //NSLog(@"DictRecord is: %@",dictRecord);
                    photoURL = [NSString stringWithFormat:@"%@", dictRecord[@"Photo"]];
                }
                [self.user_pic sd_setImageWithURL:[NSURL URLWithString:photoURL]
                            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];

            }
            else
            {
                [self.user_pic sd_setImageWithURL:[NSURL URLWithString:self.receiver[@"PhotoUrl"]]
                     placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
            }
        }
    }
    [self.back addSubview:self.user_pic];

    self.amount = [[UITextField alloc] initWithFrame:CGRectMake(104, 58, 190, 68)];
    [self.amount setTextAlignment:NSTextAlignmentRight];
    [self.amount setPlaceholder:@"$ 0.00"];
    [self.amount setDelegate:self];
    [self.amount setTag:1];
    [self.amount setKeyboardType:UIKeyboardTypeNumberPad];
    [self.amount setInputAccessoryView:[[UIView alloc] init]];
    [self.amount setStyleId:@"howmuch_amountfield"];
    [self.back addSubview:self.amount];
    [self.amount becomeFirstResponder];

    UIView * memoShell = [[UIView alloc] initWithFrame:CGRectMake(8, 148, 288, 38)];
    memoShell.layer.cornerRadius = 3;
    memoShell.layer.borderWidth = 1;
    memoShell.layer.borderColor = kNoochGrayLight.CGColor;
    [self.back addSubview:memoShell];

    self.memo = [[UITextField alloc] initWithFrame:CGRectMake(2, 0, 255, 38)];
    [self.memo setPlaceholder:@"     Enter a memo"];
    [self.memo setTextAlignment:NSTextAlignmentCenter];
    [self.memo setTextColor:kNoochGrayDark];
    [self.memo setDelegate:self];
    [self.memo setStyleId:@"howmuch_memo"];
    [self.memo setTag:2];
    [self.memo setKeyboardType:UIKeyboardTypeDefault];
    self.memo.inputAccessoryView = [[UIView alloc] init]; // To override the IQ Keyboard Mgr
    [memoShell addSubview:self.memo];

    if (isFromMyApt)
    {
        if ([self.receiver objectForKey:@"RentAmount"])
        {
            self.amnt = [self.receiver objectForKey:@"RentAmount"];
            [self.amount setText:[NSString stringWithFormat:@"$%@", [self.receiver objectForKey:@"RentAmount"]]];
        }
        if ([self.receiver objectForKey:@"AptName"])
        {
            NSDate * date = [NSDate date];
            NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMM"];
            NSString * dateString = [dateFormat stringFromDate:date];

            [self.memo setText:[NSString stringWithFormat:@"%@ Rent from %@ %@", dateString, [[user objectForKey:@"firstName"] capitalizedString], [[user objectForKey:@"lastName"] capitalizedString]]];
        }
    }

    self.camera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [self.camera.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
        [self.camera setFrame:CGRectMake(169, 3, 28, 24)];
    }
    else {
        [self.camera.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:21]];
        [self.camera setFrame:CGRectMake(251, 4, 36, 31)];
    }
    [self.camera addTarget:self action:@selector(attach_pic) forControlEvents:UIControlEventTouchUpInside];
    [self.camera setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-camera"] forState:UIControlStateNormal];
    [self.camera setTitleColor:kNoochGrayLight forState:UIControlStateNormal];

    UILabel * glyph_plus = [UILabel new];
    [glyph_plus setFont:[UIFont fontWithName:@"FontAwesome" size:12]];
    [glyph_plus setFrame:CGRectMake(25, -3, 15, 15)];
    [glyph_plus setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus"]];
    [glyph_plus setTextColor:kNoochBlue];

    UIView * memoDivider = [[UIView alloc] initWithFrame:CGRectMake(248, 8, 1, 22)];
    memoDivider.backgroundColor = kNoochGrayLight;
    memoDivider.alpha = 0.4;
    [memoShell addSubview:memoDivider];

    [self.camera addSubview:glyph_plus];
    [memoShell addSubview:self.camera];

    self.send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.send setFrame:CGRectMake(160, 194, 150, 50)];
    [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.send setTitle:@"Send" forState:UIControlStateNormal];
    [self.send setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.21) forState:UIControlStateNormal];
    self.send.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.send addTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];

    self.request = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.request setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.request setTitleShadowColor:Rgb2UIColor(26, 32, 38, 0.21) forState:UIControlStateNormal];
    self.request.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.request addTarget:self action:@selector(initialize_request) forControlEvents:UIControlEventTouchUpInside];
    [self.request setStyleId:@"howmuch_request"];
    [self.request setFrame:CGRectMake(10, 160, 150, 50)];
    [self.back addSubview:self.request];

    self.reset_type = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.reset_type setFrame:CGRectMake(0, 160, 30, 56)];
    [self.reset_type setBackgroundColor:[UIColor clearColor]];
    [self.reset_type setStyleId:@"reset_glyph"];
    [self.reset_type setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
    [self.reset_type setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    self.reset_type.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    if ([UIScreen mainScreen].bounds.size.height > 500) {
        [self.reset_type setStyleId:@"cancel_hidden"];
    }
    else {
        [self.reset_type setStyleId:@"cancel_hidden_4"];
    }

    [self.reset_type addTarget:self action:@selector(reset_send_request) forControlEvents:UIControlEventTouchUpInside];

    if ( [[assist shared] isRequestMultiple] &&
        [[[assist shared] getArray] count] > 1)
    {
        UILabel * multRecipNote = [[UILabel alloc] initWithFrame:CGRectMake(144, 120, 172, 17)];
        [multRecipNote setFont:[UIFont fontWithName:@"Roboto-light" size:14]];
        [multRecipNote setText:@"(from each person)"];
        [multRecipNote setTextAlignment:NSTextAlignmentCenter];
        [multRecipNote setTextColor:kNoochGrayDark];
        [self.back addSubview: multRecipNote];

        [self.send removeFromSuperview];
        [self.request setStyleClass:@"howmuch_buttons"];
        [self.request setStyleId:@"howmuch_request_mult_expand"];
        [self.request setTitle:@"Confirm Request" forState:UIControlStateNormal];
        [self.request removeTarget:self action:@selector(initialize_request) forControlEvents:UIControlEventTouchUpInside];
        [self.request addTarget:self action:@selector(confirm_request) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (isFromMyApt)
    {
        [self.request removeFromSuperview];

        [self.send setStyleClass:@"howmuch_buttons"];
        [self.send setStyleId:@"howmuch_send"];
        [self.send setStyleId:@"howmuch_send_expand"];
        [self.send setTitle:@"Confirm Payment" forState:UIControlStateNormal];
        [self.send removeTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];
        [self.send addTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
        [self.back addSubview:self.send];
    }
    else
    {
        [self.request setTitle:@"Request" forState:UIControlStateNormal];
        [self.send setStyleClass:@"howmuch_buttons"];
        [self.send setStyleId:@"howmuch_send"];
        [self.back addSubview:self.send];

        [self.request setStyleClass:@"howmuch_buttons"];

        self.divider = [UIImageView new];
        [self.divider setStyleId:@"howmuch_divider"];
        [self.back addSubview:self.divider];
    }

    [self.back addSubview:self.reset_type];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        [self.send setStyleId:@"howmuch_send_4"];
        [self.request setStyleId:@"howmuch_request_4"];
        [self.divider setStyleId:@"howmuch_divider_4"];

        [self.user_pic setFrame:CGRectMake(6, 45, 72, 72)];
        self.user_pic.layer.cornerRadius = 36;

        [self.amount setStyleId:@"howmuch_amountfield_4"];
        [self.memo setStyleId:@"howmuch_memo_4"];
        [self.camera setStyleId:@"howmuch_camera_4"];
    }

    transLimitFromArtisanString = [ARPowerHookManager getValueForHookById:@"transLimit"];
    transLimitFromArtisanInt = [transLimitFromArtisanString floatValue];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.amount becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:NO];

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
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"HowMuch Screen";
    [self.amount becomeFirstResponder];
    [self.navigationItem setTitle:@"How Much?"];
}

#pragma mark- Request Multiple case
-(void)addRecipient:(id)sender
{
    [[assist shared]setRequestMultiple:YES];
    [self.navigationItem setLeftBarButtonItem:nil];

    isAddRequest = YES;
    
    if ([[[assist shared]getArray] count] == 0)
    {
        arrRecipientsForRequest = [[NSMutableArray alloc] init];
        [arrRecipientsForRequest addObject:self.receiver];
        [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
    }

    if (isFromHome || isFromStats)
    {
        SelectRecipient * selOBJ = [[SelectRecipient alloc]init];

        NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];

        [arrNav insertObject:selOBJ atIndex: [arrNav count] - 1];
        [self.navigationController setViewControllers:arrNav];

        [nav_ctrl setViewControllers:arrNav animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - type of transaction
- (void) initialize_send
{
    [self.recip_back setStyleClass:@"barbackground_green"];

    CGRect origin = self.reset_type.frame;
    origin.origin.x = 10;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.55];

    origin.size.width = 149;
    origin.origin.x = 162;

    origin = self.request.frame;
    origin.size.width = 149;
    origin.origin.x = 9;

    self.user_pic.layer.borderColor = kNoochGreen.CGColor;

    [self.send addTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
    [self.send setTitle:@"Confirm Send" forState:UIControlStateNormal];
    [self.request setStyleId:@"howmuch_request_hide"];
    [self.send setStyleId:@"howmuch_send_expand"];
    [self.reset_type setAlpha:1];
    [self.reset_type setStyleId:@"cancel_request"];
    [self.back bringSubviewToFront:self.reset_type];

    [UIView commitAnimations];

    [self.divider setStyleClass:@"animate_roll_left"];
}

- (void) initialize_request
{
    [self.recip_back setStyleClass:@"barbackground_blue"];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.55];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    self.user_pic.layer.borderColor = kNoochBlue.CGColor;

    [self.request addTarget:self action:@selector(confirm_request) forControlEvents:UIControlEventTouchUpInside];
    [self.request setTitle:@"Confirm Request" forState:UIControlStateNormal];
    [self.send setStyleId:@"howmuch_send_hide"];
    [self.request setStyleId:@"howmuch_request_expand"];
    [self.reset_type setAlpha:1];
    [self.reset_type setStyleId:@"cancel_send"];
    [self.back bringSubviewToFront:self.reset_type];

    [UIView commitAnimations];

    [self.divider setStyleClass:@"animate_roll_right"];
}

- (void) reset_send_request
{
    [self.recip_back setStyleClass:@"barbackground_gray"];

    if (![[assist shared] isRequestMultiple]) {
        self.divider = [UIImageView new];
        [self.divider setStyleId:@"howmuch_divider"];
        [self.divider setAlpha:0];
        [self.back addSubview:self.divider];
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];

    self.user_pic.layer.borderColor = [Helpers hexColor:@"939598"].CGColor;

    [self.send setTitle:@"Send" forState:UIControlStateNormal];
    [self.request setTitle:@"Request" forState:UIControlStateNormal];

    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        [self.send setStyleId:@"howmuch_send_4"];
        [self.request setStyleId:@"howmuch_request_4"];
        [self.divider setStyleId:@"howmuch_divider_4"];
    }
    else {
        [self.send setStyleId:@"howmuch_send"];
        [self.request setStyleId:@"howmuch_request"];
    }

    [self.send removeTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
    [self.request removeTarget:self action:@selector(confirm_request) forControlEvents:UIControlEventTouchUpInside];
    [self.send addTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];
    [self.request addTarget:self action:@selector(initialize_request) forControlEvents:UIControlEventTouchUpInside];

    [self.divider setAlpha:1];
    [self.reset_type setAlpha:0];
    [UIView commitAnimations];
}

- (void) confirm_send
{
    if ([self.amnt floatValue] == 0)
    {
        NSString * alertMessage = @"";

        if (([self.receiver valueForKey:@"nonuser"] && ![self.receiver objectForKey:@"firstName"]) ||
            ([[assist shared] isRequestMultiple] && [[[assist shared] getArray] count] > 1))
        {
            alertMessage = @"\xF0\x9F\x98\xAC\nPlease enter a value over $0.\n\nWe'd love to send a $0 payment, but it's actually surprisingly tricky.";
        }
        else if ([self.receiver valueForKey:@"nonuser"] && [self.receiver objectForKey:@"firstName"])
        {
            alertMessage = [NSString stringWithFormat:@"\xF0\x9F\x98\xAC\nPlease enter a value over $0.\n\nWe'd love to send a $0 payment to %@, but it's actually rather tricky.",[[self.receiver objectForKey:@"firstName"] capitalizedString]];
        }
        else
        {
            alertMessage = [NSString stringWithFormat:@"\xF0\x9F\x98\xAC\nPlease enter a value over $0.\n\nWe'd love to send a $0 payment to %@, but it's actually rather tricky.",[[self.receiver objectForKey:@"FirstName"] capitalizedString]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!"
                                                        message:alertMessage
                                                        delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    else if ([[[self.amount text] substringFromIndex:1] doubleValue] > transLimitFromArtisanInt && !isFromMyApt)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa Now"
                                                        message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB3\nTo keep Nooch safe, please don’t send more than $%@. We hope to raise this limit very soon!", transLimitFromArtisanString]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }

    NSMutableDictionary *transaction = [self.receiver mutableCopy];
    [transaction setObject:[self.memo text] forKey:@"memo"];
    float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];

    [self.navigationItem setLeftBarButtonItem:nil];

    if ([self.receiver valueForKey:@"nonuser"])
    {
        TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"send" amount:input_amount];
        [self.navigationController pushViewController:pin animated:YES];
    }
    else {
        TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"send" amount: input_amount];
        [self.navigationController pushViewController:pin animated:YES];
    }
}

#pragma mark  - alert view delegation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11 && buttonIndex == 1)
    {
        [[assist shared]setTranferImage:nil];
        [UIView animateKeyframesWithDuration:0.2
                                       delay:0
                                     options:2 << 16
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                          [self.trans_image setAlpha:0];
                                      }];
                                  } completion: ^(BOOL finished) {
                                      [self.trans_image removeFromSuperview];
                                      [self.camera setHidden:NO];
                                  }
         ];
        [self attach_pic];
    }
}

- (void) confirm_request
{
    if ([self.amnt floatValue] == 0)
    {
        NSString * alertMessage = @"";
        if (([self.receiver valueForKey:@"nonuser"] && ![self.receiver objectForKey:@"firstName"]) ||
           ([[assist shared] isRequestMultiple] && [[[assist shared] getArray] count] > 1))
        {
            alertMessage = @"\xF0\x9F\x98\xAC\nPlease enter a value over $0.\n\nWe'd love to send a $0 request, but it would just get too confusing for everyone.";
        }
        else if ([self.receiver valueForKey:@"nonuser"] && [self.receiver objectForKey:@"firstName"])
        {
            alertMessage = [NSString stringWithFormat:@"\xF0\x9F\x98\xAC\nPlease enter a value over $0.\n\nSurely %@ owes you more than that...", [[self.receiver objectForKey:@"firstName"] capitalizedString]];
        }
        else
        {
            alertMessage = [NSString stringWithFormat:@"\xF0\x9F\x98\xAC\nPlease enter a value over $0.\n\nSurely %@ owes you more than that...", [[self.receiver objectForKey:@"FirstName"] capitalizedString]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!"
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    else if ([[[self.amount text] substringFromIndex:1] doubleValue] > transLimitFromArtisanInt && !isFromMyApt)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa Big Spender"
                                                        message:[NSString stringWithFormat:@"\xF0\x9F\x98\x87\nWhile we definitely appreciate your enthusiasm, we are limiting transfers to $%@ for now in order to minimize our risk (and yours). We're working to raise the limit soon!", transLimitFromArtisanString]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }

    [self.navigationItem setLeftBarButtonItem:nil];

    if ([[assist shared]isRequestMultiple])
    {
        NSMutableDictionary *transaction = [[NSMutableDictionary alloc]init];
        [transaction setObject:[self.memo text] forKey:@"memo"];
        float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
        TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"request" amount:input_amount];
        [self.navigationController pushViewController:pin animated:YES];
    }
    else
    {
        NSMutableDictionary *transaction = [self.receiver mutableCopy];
        [transaction setObject:[self.memo text] forKey:@"memo"];
        float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
        TransferPIN *pin;
        
        if ([self.receiver valueForKey:@"nonuser"]) {
            pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"request" amount:input_amount];
        }
        else {
            pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"request" amount:input_amount];
        }
        [self.navigationController pushViewController:pin animated:YES];
    }
}

#pragma mark - picture attaching
- (void) attach_pic
{
    [self.amount resignFirstResponder];

    if ([[assist shared] getTranferImage])
    {
        if ([UIAlertController class]) // for iOS 8
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Replace Picture?"
                                         message:@"Do you want to remove the current picture?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * yes = [UIAlertAction
                                  actionWithTitle:@"Yes"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [[assist shared]setTranferImage:nil];
                                      [UIView animateKeyframesWithDuration:0.2
                                                                     delay:0
                                                                   options:2 << 16
                                                                animations:^{
                                                                    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                                                        [self.trans_image setAlpha:0];
                                                                    }];
                                                                } completion: ^(BOOL finished) {
                                                                    [self.trans_image removeFromSuperview];
                                                                    [self.camera setHidden:NO];
                                                                }
                                       ];

                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      [self attach_pic];
                                  }];
            UIAlertAction * no = [UIAlertAction
                                  actionWithTitle:@"No"
                                  style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                  }];
            [alert addAction:no];
            [alert addAction:yes];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Replace Picture?"
                                                          message:@"Do you want to remove the current picture?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
            [av show];
            [av setTag:11];
            return;
        }
    }
    else
    {
        self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
        [self.shade setBackgroundColor:kNoochGrayDark];
        [self.shade setAlpha:0.0];
        [self.shade setUserInteractionEnabled:YES];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel_photo)];
        [self.shade addGestureRecognizer:recognizer];
        [self.navigationController.view addSubview:self.shade];
        
        // Set starting point to be the frame of Camera Icon, it will expand/grow from there
        self.choose = [[UIView alloc] initWithFrame:CGRectMake(270, 220, 8, 6)];
        self.choose.clipsToBounds = YES;

        UIButton *take = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [take addTarget:self action:@selector(take_photo) forControlEvents:UIControlEventTouchUpInside];
        [take setTitle:@"" forState:UIControlStateNormal];
        [self.choose addSubview:take];

        UIButton *album = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [album addTarget:self action:@selector(from_album) forControlEvents:UIControlEventTouchUpInside];
        [album setTitle:@"" forState:UIControlStateNormal];
        [self.choose addSubview:album];

        [UIView beginAnimations:Nil context:nil];
        [UIView setAnimationDuration:0.4];
        
        [self.shade setAlpha:0.65];

        [self.choose setStyleId:@"attachpic_container"];
        [take setStyleId:@"attachpic_takephoto_box"];
        [album setStyleId:@"attachpic_choosefrom_box"];
        
        UIImageView *camera_icon = [UIImageView new];
        [camera_icon setStyleId:@"attachpic_takephoto_icon"];
        [self.choose addSubview:camera_icon];
        
        UIImageView *album_icon = [UIImageView new];
        [album_icon setStyleId:@"attachpic_choosefrom_icon"];
        [self.choose addSubview:album_icon];
        
        UILabel *take_label = [UILabel new];
        [take_label setStyleId:@"attachpic_takephoto_label"];
        [take_label setText:@"Use Camera"];
        [self.choose addSubview:take_label];
        
        UILabel *album_label = [UILabel new];
        [album_label setText:@"Choose From Album"];
        [album_label setStyleId:@"attachpic_choosefrom_label"];
        [self.choose addSubview:album_label];
        
        UILabel *or = [UILabel new];
        [or setStyleId:@"attachpic_or"];
        [or setText:@"or"];
        [self.choose addSubview:or];

        [self.navigationController.view addSubview:self.choose];

        [UIView commitAnimations];
    }
}

- (void) cancel_photo
{
    [UIView beginAnimations:Nil context:nil];
    [UIView setAnimationDuration:.5];
    
//    self.choose = [[UIView alloc] initWithFrame:CGRectMake(270, 220, 8, 6)];

    for (UIView *subview in [self.choose subviews]) {
        [subview removeFromSuperview];
    }
    [self.choose removeFromSuperview];
    [self.choose setAlpha:0.0];
    [self.shade setAlpha:0.0];

    [UIView commitAnimations];
}

- (void) take_photo
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
        return;        
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void) from_album
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self cancel_photo];
   
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    chosenImage = [chosenImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(150,150) interpolationQuality:kCGInterpolationMedium];

    [[assist shared]setTranferImage:chosenImage];
    
    [self.camera setHidden:YES];

    self.trans_image = [[UIButton alloc] initWithFrame:CGRectMake(252, 205, 56, 56)];
    self.trans_image.layer.cornerRadius = 5;
    self.trans_image.clipsToBounds = YES;
    [self.trans_image setBackgroundImage:chosenImage forState:UIControlStateNormal];
    [self.trans_image addTarget:self action:@selector(attach_pic) forControlEvents:UIControlEventTouchUpInside];
    [self.trans_image setAlpha:1];
    [self.back addSubview:self.trans_image];

    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [self.trans_image setFrame:CGRectMake(266, 100, 27, 27)];
    }
    else {
        [self.trans_image setFrame:CGRectMake(259, 150, 34, 34)];
    }

    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;

    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 115.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 115.0;
        }
        else {
            imgRatio = 75.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 75.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancel_photo];
    [self.camera setStyleId:@"howmuch_camera"];
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1)
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setGeneratesDecimalNumbers:YES];
        [formatter setUsesGroupingSeparator:YES];

        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        
        if ([string length] == 0) //backspace
        {
            if ([self.amnt length] > 0)
            {
                self.amnt = [[self.amnt substringToIndex:[self.amnt length] - 1] mutableCopy];
            }
        }
        else
        {
            NSString * temp = [self.amnt stringByAppendingString:string];
            self.amnt = [temp mutableCopy];
        }

        float maths = [self.amnt floatValue];
        maths /= 100;

        if (maths > 1000)
        {
            self.amnt = [[self.amnt substringToIndex:[self.amnt length] - 1] mutableCopy];
            return NO;
        }

        if (maths != 0)
        {
            [textField setText:[formatter stringFromNumber:[NSNumber numberWithFloat:maths]]];
        } 
        else
        {
            [textField setText:@""];
        }
        return NO;
    }
    if (textField.tag == 2)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 55) ? NO : YES;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)Error:(NSError *)Error
{
    /* UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show]; */
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
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