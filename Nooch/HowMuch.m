//  HowMuch.m
//  Nooch
//
//  Created by crks on 9/26/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

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

@end

@implementation HowMuch

- (id)initWithReceiver:(NSDictionary *)receiver
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.receiver = [receiver copy];
    }
    return self;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];   
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.amount becomeFirstResponder];
}

-(void)backPressed:(id)sender{
    isphoneBook=NO;
    isEmailEntry=NO;
    [[assist shared]setRequestMultiple:NO];
    [arrRecipientsForRequest removeAllObjects];
    [[assist shared]setArray:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.topItem.title = @"";
    
    NSDictionary *navbarTtlAts = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIColor whiteColor], UITextAttributeTextColor,
                                 Rgb2UIColor(19, 32, 38, .26), UITextAttributeTextShadowColor,
                                 [NSValue valueWithUIOffset:UIOffsetMake(0.0, -1.0)], UITextAttributeTextShadowOffset, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTtlAts];
    
    [self.navigationItem setTitle:@"How Much?"];

    [[assist shared] setTranferImage:nil];
    
    self.amnt = [@"" mutableCopy];
    self.decimals = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];

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
    
    UIButton *back_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [back_button setStyleId:@"navbar_back"];
    [back_button setImage:[UIImage imageNamed:@"whiteBack30.png"] forState:UIControlStateNormal];
    [back_button setImage:[UIImage imageNamed:@"whiteBack30.png"] forState:UIControlStateHighlighted];
    [back_button addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    self.recip_back = [UILabel new];
    [self.recip_back setStyleClass:@"barbackground"];
    [self.recip_back setStyleClass:@"barbackground_gray"];
    [self.back addSubview:self.recip_back];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(64, 65, 66, .3);
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    NSDictionary * textAttributes =
    @{NSShadowAttributeName: shadow };
    
    UILabel *to = [UILabel new];
    to.attributedText = [[NSAttributedString alloc] initWithString:@"To: "
                                                           attributes:textAttributes];
    [to setStyleId:@"label_howmuch_to"];
    [self.back addSubview:to];

    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    if ([self.receiver valueForKey:@"nonuser"])
    {
        [to_label setStyleId:@"label_howmuch_recipientnamenonuser"];
        [to_label setText:[NSString stringWithFormat:@"%@",[self.receiver objectForKey:@"email"]]];
    }
    else
    {
        if ([[assist shared]isRequestMultiple])
        {
            NSString*strMultiple=@"";
            for (NSDictionary *dictRecord in [[assist shared]getArray]) {
                strMultiple=[strMultiple stringByAppendingString:[NSString stringWithFormat:@", %@",[dictRecord[@"FirstName"] capitalizedString]]];
            }
            [to_label setStyleId:@"label_howmuch_recipientnamenonuser"];
            strMultiple=[strMultiple substringFromIndex:1];
            [to_label setText:strMultiple];
        }
        else
        {
            [to_label setStyleId:@"label_howmuch_recipientname"];
            [to_label setText:[NSString stringWithFormat:@"%@ %@",[[self.receiver objectForKey:@"FirstName"] capitalizedString],[[self.receiver objectForKey:@"LastName"] capitalizedString]]];
        }
    }
    [self.back addSubview:to_label];

    if (![self.receiver valueForKey:@"nonuser"]  && !isUserByLocation)
    {
        UIButton*add=[[UIButton alloc]initWithFrame:CGRectMake(266, 16, 28, 28)];
        [add addTarget:self action:@selector(addRecipient:) forControlEvents:UIControlEventTouchUpInside];
        [add setStyleClass:@"addbutton_request"];
        [add setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-circle"] forState:UIControlStateNormal];
        [self.view addSubview:add];
    }
    
    UIImageView *user_pic = [UIImageView new];
    [user_pic setFrame:CGRectMake(18, 48, 84, 84)];
    user_pic.layer.borderColor = [Helpers hexColor:@"939598"].CGColor;
    user_pic.layer.borderWidth = 1;
    user_pic.clipsToBounds = YES;
    user_pic.layer.cornerRadius = 42;
    if ([self.receiver valueForKey:@"nonuser"]) {
        [user_pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    else
    {
        [user_pic setHidden:NO];
        if (self.receiver[@"Photo"]) {
            [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"Photo"]]
                     placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        }
        else {
            [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"PhotoUrl"]]
                     placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        }
    }
    [self.back addSubview:user_pic];

    self.amount = [[UITextField alloc] initWithFrame:CGRectMake(110, 30, 260, 80)];
    [self.amount setTextAlignment:NSTextAlignmentRight];
    [self.amount setPlaceholder:@"$ 0.00"];
    [self.amount setDelegate:self];
    [self.amount setTag:1];
    [self.amount setKeyboardType:UIKeyboardTypeNumberPad];
    self.amount.inputAccessoryView = [[UIView alloc] init];
    [self.amount setStyleId:@"howmuch_amountfield"];
    [self.back addSubview:self.amount];
    [self.amount becomeFirstResponder];

    self.memo = [[UITextField alloc] initWithFrame:CGRectMake(10, 120, 260, 38)];
    [self.memo setPlaceholder:@"Enter a memo"];
    [self.memo setDelegate:self];
    [self.memo setStyleId:@"howmuch_memo"];
    [self.memo setTag:2];
    [self.memo setKeyboardType:UIKeyboardTypeDefault];
    self.memo.inputAccessoryView = [[UIView alloc] init];
    [self.back addSubview:self.memo];

    self.camera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [self.camera.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
        [self.camera setFrame:CGRectMake(260, 105, 28, 24)];
    }
    else {
        [self.camera.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:21]];
        [self.camera setFrame:CGRectMake(259, 154, 30, 26)];
    }
    [self.camera addTarget:self action:@selector(attach_pic) forControlEvents:UIControlEventTouchUpInside];
    
    [self.camera setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-camera"] forState:UIControlStateNormal];
    [self.camera setTitleColor:kNoochGrayLight forState:UIControlStateNormal];
    
    UILabel *glyph_plus = [UILabel new];
    [glyph_plus setFont:[UIFont fontWithName:@"FontAwesome" size:12]];
    [glyph_plus setFrame:CGRectMake(23, -4, 15, 15)];
    [glyph_plus setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus"]];
    [glyph_plus setTextColor:kNoochBlue];
    
    [self.camera addSubview:glyph_plus];
    [self.back addSubview:self.camera];
    
    self.send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.send setTitle:@"Send" forState:UIControlStateNormal];
    [self.send setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.26) forState:UIControlStateNormal];
    self.send.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.send addTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];

    self.request = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.request setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.request setTitle:@"Request" forState:UIControlStateNormal];
    [self.request setTitleShadowColor:Rgb2UIColor(26, 32, 38, 0.26) forState:UIControlStateNormal];
    self.request.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.request addTarget:self action:@selector(initialize_request) forControlEvents:UIControlEventTouchUpInside];
    [self.request setStyleId:@"howmuch_request"];
    [self.request setFrame:CGRectMake(10, 160, 150, 50)];
    [self.back addSubview:self.request];

    if ([[assist shared]isRequestMultiple])
    {
        [self.send removeFromSuperview];
        [self.request setStyleClass:@"howmuch_buttons"];
        [self.request setStyleId:@"howmuch_request_mult_expand"];
    }
    else
    {
        [self.send setStyleClass:@"howmuch_buttons"];
        [self.send setStyleId:@"howmuch_send"];
        [self.send setFrame:CGRectMake(160, 160, 150, 50)];
        [self.back addSubview:self.send];

        [self.request setStyleClass:@"howmuch_buttons"];

        self.divider = [UIImageView new];
        [self.divider setStyleId:@"howmuch_divider"];
        [self.back addSubview:self.divider];
    }

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
    [self.back addSubview:self.reset_type];

    [self.navigationItem setRightBarButtonItem:Nil];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        [self.send setStyleId:@"howmuch_send_4"];
        [self.request setStyleId:@"howmuch_request_4"];
        [self.divider setStyleId:@"howmuch_divider_4"];
        
        [user_pic setFrame:CGRectMake(6, 45, 72, 72)];
        user_pic.layer.cornerRadius = 36;
        
        [self.amount setStyleId:@"howmuch_amountfield_4"];
        [self.memo setStyleId:@"howmuch_memo_4"];
        [self.camera setStyleId:@"howmuch_camera_4"];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.trackedViewName = @"HowMuch Screen";
    [self.amount becomeFirstResponder];
    [self.navigationItem setTitle:@"How Much?"];
}

#pragma mark- Request Multiple case
-(void)addRecipient:(id)sender
{
    [[assist shared]setRequestMultiple:YES];
  
    isAddRequest=YES;
    NSLog(@"%@",self.receiver);
    
    if ([[[assist shared]getArray] count]==0)
    {
        arrRecipientsForRequest=[[NSMutableArray alloc] init];
        NSLog(@"%@",self.receiver);
        [arrRecipientsForRequest addObject:self.receiver];
        NSLog(@"%@",arrRecipientsForRequest);
        [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
    }
    if (isFromHome)
    {
        isAddRequest=YES;
        SelectRecipient*selOBJ=[[SelectRecipient alloc]init];
        
        NSMutableArray*arrNav=[nav_ctrl.viewControllers mutableCopy];
        NSLog(@"%@",arrNav);
        [arrNav insertObject:selOBJ atIndex:1];
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
    [UIView setAnimationDuration:0.7];

    origin.size.width = 149;
    origin.origin.x = 162;
    
    origin = self.request.frame;
    origin.size.width = 149;
    origin.origin.x = 9;

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
    [UIView setAnimationDuration:0.7];

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

- (void) reset_send_request {
    [self.recip_back setStyleClass:@"barbackground_gray"];

    if (![[assist shared] isRequestMultiple]) {
        self.divider = [UIImageView new];
        [self.divider setStyleId:@"howmuch_divider"];
        [self.divider setAlpha:0];
        [self.back addSubview:self.divider];
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!" message:@"Please enter a value over $0.00. We'd love to send a negative amount, but it's actually pretty difficult." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            return;
    }
    if ([[self.amount text] length] < 3)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Just A Little More" message:@"Please enter an amount greater than $1.00." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    else if ([[[self.amount text] substringFromIndex:1] doubleValue] > 100)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa Now" message:[NSString stringWithFormat:@"To keep Nooch safe, please don’t %@ more than $100. We hope to raise this limit very soon!", @"send"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }

    NSMutableDictionary *transaction = [self.receiver mutableCopy];
    [transaction setObject:[self.memo text] forKey:@"memo"];
    float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
    
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
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
}

- (void) confirm_request
{
    if ([[self.amount text] length] < 3)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Just A Little More" message:@"Please enter an amount greater than $1.00." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    else if ([[[self.amount text] substringFromIndex:1] doubleValue] > 100)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa Big Spender" message:[NSString stringWithFormat:@"While we definitely appreciate your enthusiasm, we are limiting transfers to $100 for now in order to minimize our risk (and yours). We're working to raise the limit soon! "] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }

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
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    [self.shade setBackgroundColor:kNoochGrayDark]; 
    [self.shade setAlpha:0.0];
    [self.shade setUserInteractionEnabled:YES];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel_photo)];
    [self.shade addGestureRecognizer:recognizer];
    [self.navigationController.view addSubview:self.shade];

    CGRect frame = self.camera.frame;
    self.choose = [[UIView alloc] initWithFrame:frame];

    UIButton *take = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [take addTarget:self action:@selector(take_photo) forControlEvents:UIControlEventTouchUpInside];
    [take setTitle:@"" forState:UIControlStateNormal];
    [self.choose addSubview:take];

    UIButton *album = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [album addTarget:self action:@selector(from_album) forControlEvents:UIControlEventTouchUpInside];
    [album setTitle:@"" forState:UIControlStateNormal];
    [self.choose addSubview:album];

    [self.navigationController.view addSubview:self.choose];

    [UIView beginAnimations:Nil context:nil];
    [UIView setAnimationDuration:.5];
    [self.choose setFrame:CGRectMake(20, 125, 280, 120)];
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
    [take_label setText:@"Take a Photo"];
    [self.choose addSubview:take_label];
    
    UILabel *album_label = [UILabel new];
    [album_label setText:@"Choose from Album"];
    [album_label setStyleId:@"attachpic_choosefrom_label"];
    [self.choose addSubview:album_label];
    
    UILabel *or = [UILabel new];
    [or setStyleId:@"attachpic_or"];
    [or setText:@"or"];
    [self.choose addSubview:or];
    [self.shade setAlpha:0.6];
    [self.amount resignFirstResponder];
    
    [UIView commitAnimations];
}

- (void) cancel_photo
{
    [UIView beginAnimations:Nil context:nil];
    [UIView setAnimationDuration:1];
    [self.choose removeFromSuperview];
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
    [self.camera setTitleColor:kNoochBlue forState:UIControlStateNormal];

    [[assist shared]setTranferImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size{
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
        
        if([string length] == 0) //backspace
        {
            if ([self.amnt length] > 0) {
                self.amnt = [[self.amnt substringToIndex:[self.amnt length]-1] mutableCopy];
            }
        }
        else {
            NSString *temp = [self.amnt stringByAppendingString:string];
            self.amnt = [temp mutableCopy];
        }
        float maths = [self.amnt floatValue];
        maths /= 100;
        if (maths > 1000) {
            self.amnt = [[self.amnt substringToIndex:[self.amnt length]-1] mutableCopy];
            return NO;
        }
        if (maths != 0) {
            [textField setText:[formatter stringFromNumber:[NSNumber numberWithFloat:maths]]];
        } 
        else {
            [textField setText:@""];
        }
        return NO;
    }
    if (textField.tag == 2)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 50) ? NO : YES;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField  {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
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