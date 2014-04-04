//
//  HowMuch.m
//  Nooch
//
//  Created by crks on 9/26/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "HowMuch.h"
#import "TransferPIN.h"
#import "UIImageView+WebCache.h"
#import "Deposit.h"
#import "UIImage+Resize.h"
#import "SelectRecipient.h"
#import "WTGlyphFontSet.h"
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
    if (!isAddRequest) {
        [[assist shared]setRequestMultiple:NO];
        [arrRecipientsForRequest removeAllObjects];
        [[assist shared]setArray:[arrRecipientsForRequest copy]];
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"How Much"];

    self.amnt = [@"" mutableCopy];
    self.decimals = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 248)];
    [back setStyleClass:@"how_much_mainbox"];
    [back setStyleClass:@"raised_view"];
    [back setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:back];
    
    self.recip_back=  [UILabel new];
    [self.recip_back setStyleClass:@"barbackground"];
    [self.recip_back setStyleClass:@"barbackground_gray"];
    [self.view addSubview:self.recip_back];
    
    UILabel *to = [UILabel new]; [to setText:@"To: "];
    [to setStyleId:@"label_howmuch_to"];
    [self.view addSubview:to];
    
    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    if ([self.receiver valueForKey:@"nonuser"]) {
        //
        [to_label setStyleId:@"label_howmuch_recipientnamenonuser"];
        [to_label setText:[NSString stringWithFormat:@"%@",[self.receiver objectForKey:@"email"]]];
    }
    else
    {
        if ([[assist shared]isRequestMultiple]) {
            NSString*strMultiple=@"";
            for (NSDictionary *dictRecord in [[assist shared]getArray]) {
                strMultiple=[strMultiple stringByAppendingString:[NSString stringWithFormat:@",%@ %@",[dictRecord[@"FirstName"] capitalizedString],[dictRecord[@"LastName"] capitalizedString]]];
            }
            [to_label setStyleId:@"label_howmuch_recipientname"];
            strMultiple=[strMultiple substringFromIndex:1];
            [to_label setText:strMultiple];
        }
        else
        {
        [to_label setStyleId:@"label_howmuch_recipientname"];
        [to_label setText:[NSString stringWithFormat:@"%@ %@",[[self.receiver objectForKey:@"FirstName"] capitalizedString],[[self.receiver objectForKey:@"LastName"] capitalizedString]]];
        }
    }
    
    [self.view addSubview:to_label];
    if (![self.receiver valueForKey:@"nonuser"] &&  !isPayBack  && !isUserByLocation) {
        UIButton*add=[[UIButton alloc]initWithFrame:CGRectMake(260, 15, 30, 30)];
        [add setImage:[UIImage imageNamed:@"add-icon-white.png"] forState:UIControlStateNormal];
        [add addTarget:self action:@selector(addRecipient:) forControlEvents:UIControlEventTouchUpInside];
        [add setStyleCSS:@"addbutton_request"];
        [self.view addSubview:add];
    }
    UIImageView *user_pic = [UIImageView new];
    [user_pic setFrame:CGRectMake(28, 62, 74, 74)];
    user_pic.layer.borderColor = [Helpers hexColor:@"939598"].CGColor;
    user_pic.layer.borderWidth = 2; user_pic.clipsToBounds = YES;
    user_pic.layer.cornerRadius = 37;
    if ([self.receiver valueForKey:@"nonuser"]) {
        [user_pic setImage:[UIImage imageNamed:@"silhouette.png"]];
    }
    else{
        [user_pic setHidden:NO];
        
        if (self.receiver[@"Photo"]) {
            [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"Photo"]]
                     placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        }
        else
        {
            [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"PhotoUrl"]]
                     placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        }
    }
    [self.view addSubview:user_pic];
    
    self.amount = [[UITextField alloc] initWithFrame:CGRectMake(30, 40, 260, 80)];
    [self.amount setTextAlignment:NSTextAlignmentRight]; [self.amount setPlaceholder:@"$ 0.00"];
    [self.amount setDelegate:self]; [self.amount setTag:1];
    [self.amount setKeyboardType:UIKeyboardTypeNumberPad];
    [self.amount setStyleId:@"howmuch_amountfield"];
    [self.view addSubview:self.amount];
    [self.amount becomeFirstResponder];
    self.memo = [[UITextField alloc] initWithFrame:CGRectMake(10, 120, 260, 40)];
    [self.memo setPlaceholder:@"Enter a memo"];
    [self.memo setDelegate:self]; [self.memo setTag:2];
    [self.memo setKeyboardType:UIKeyboardTypeDefault];
    [self.memo setStyleId:@"howmuch_memo"];
    [self.view addSubview:self.memo];
    
    self.camera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.camera setFrame:CGRectMake(260, 161, 22, 22)];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [self.camera setFrame:CGRectMake(260, 71, 22, 22)];
    }
    [self.camera addTarget:self action:@selector(attach_pic) forControlEvents:UIControlEventTouchUpInside];
    [WTGlyphFontSet setDefaultFontSetName: @"fontawesome"];
    UIImageView *ttt = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [ttt setImage:[UIImage imageGlyphNamed:@"camera" height:30 color:kNoochGrayLight]];
    [self.camera setBackgroundImage:ttt.image forState:UIControlStateNormal];
    [self.view addSubview:self.camera];
    self.send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.send setBackgroundColor:kNoochGreen];
    [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; [self.send setTitle:@"Send" forState:UIControlStateNormal];
    [self.send addTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.send setFrame:CGRectMake(160, 160, 150, 50)];
    
    self.request = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.request setBackgroundColor:kNoochBlue];
    [self.request setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; [self.request setTitle:@"Request" forState:UIControlStateNormal];
    [self.request addTarget:self action:@selector(initialize_request) forControlEvents:UIControlEventTouchUpInside];
    
    [self.request setStyleId:@"howmuch_request"];
    [self.request setFrame:CGRectMake(10, 160, 150, 50)];
    [self.view addSubview:self.request];
    if ([[assist shared]isRequestMultiple]) {
        [self.send removeFromSuperview];
        [self.request setStyleClass:@"howmuch_buttons"];
        [self.request setStyleId:@"howmuch_request_mult_expand"];
        [self.request setFrame:CGRectMake(10, 160, 300, 50)];

    }
    else if ([self.receiver valueForKey:@"nonuser"]) {
        [self.request removeFromSuperview];
        [self.send setStyleClass:@"nonhowmuch_send"];
        [self.send setFrame:CGRectMake(10, 160, 300, 50)];
        [self.view addSubview:self.send];
    }
    else{
        
        [self.send setStyleClass:@"howmuch_buttons"];
        [self.send setStyleId:@"howmuch_send"];
        [self.send setFrame:CGRectMake(160, 160, 150, 50)];
        [self.view addSubview:self.send];
        [self.request setStyleClass:@"howmuch_buttons"];
        self.divider = [UIImageView new];
        [self.divider setStyleId:@"howmuch_divider"];
        [self.view addSubview:self.divider];
        
    }
    
    
    self.reset_type = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.reset_type setFrame:CGRectMake(0, 160, 0, 50)]; [self.reset_type setBackgroundColor:[UIColor clearColor]]; [self.reset_type setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reset_type addTarget:self action:@selector(reset_send_request) forControlEvents:UIControlEventTouchUpInside];
    [self.reset_type setStyleId:@"cancel_hidden"];
    [self.reset_type setAlpha:0];
    [self.view addSubview:self.reset_type];
    
    [self.navigationItem setRightBarButtonItem:Nil];
    /*self.balance = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.balance setFrame:CGRectMake(0, 0, 60, 30)];
    [self.balance.titleLabel setFont:kNoochFontMed];
    [self.balance setStyleId:@"navbar_balance"];
    
    if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
        [self.navigationItem setRightBarButtonItem:Nil];
        if ([[user objectForKey:@"Balance"] rangeOfString:@"."].location!=NSNotFound) {
            [self.balance setTitle:[NSString stringWithFormat:@"$%@",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
        }
        else
            [self.balance setTitle:[NSString stringWithFormat:@"$%@.00",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
        UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:self.balance];
        [self.navigationItem setRightBarButtonItem:funds];
    }
    else
    {
        [self.balance setTitle:[NSString stringWithFormat:@"$%@",@"00.00"] forState:UIControlStateNormal];
    }*/
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        CGRect frame = back.frame;
        frame.size.height = 175;
        back.frame = frame;
        [self.send setStyleId:@"howmuch_send_4"];
        [self.request setStyleId:@"howmuch_request_4"];
        [self.divider setStyleId:@"howmuch_divider_4"];
        [user_pic setFrame:CGRectMake(28, 55, 46, 46)];
        user_pic.layer.cornerRadius = 23;
        [self.amount setStyleId:@"howmuch_amountfield_4"];
        [self.memo setStyleId:@"howmuch_memo_4"];
        [self.camera setStyleId:@"howmuch_camera_4"];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.amount becomeFirstResponder];
    [self.navigationItem setTitle:@"How Much?"];
}
#pragma mark- Request Multiple case
-(void)addRecipient:(id)sender{
    [[assist shared]setRequestMultiple:YES];
   // isMutipleRequest=YES;
    isAddRequest=YES;
    
   if ([[[assist shared]getArray] count]==0) {
        arrRecipientsForRequest=[[NSMutableArray alloc] init];
        [arrRecipientsForRequest addObject:self.receiver];
        [[assist shared]setArray:[arrRecipientsForRequest mutableCopy]];
    }
  
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - type of transaction
- (void) initialize_send
{
    CGRect origin = self.reset_type.frame;
    origin.origin.x = 160;
    [self.reset_type setFrame:origin];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.recip_back setStyleClass:@"barbackground_green"];
    origin.origin.x = 10; origin.size.width = 40;
    [self.reset_type setFrame:origin];
    origin = self.send.frame;
    origin.size.width = 260; origin.origin.x = 50;
    [self.send setFrame:origin];
    origin = self.request.frame;
    origin.size.width = 0; //origin.origin.x = 50;
    [self.request setFrame:origin];
    
    [self.send addTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reset_type setTitle:@">" forState:UIControlStateNormal];
    [self.reset_type setAlpha:1];
    [self.send setTitle:@"Confirm Send" forState:UIControlStateNormal];
    
    [self.reset_type setStyleClass:@"button_blue"];
    [UIView commitAnimations];
    
    [self.divider setStyleClass:@"animate_roll_left"];
    [self.send setStyleId:@"howmuch_send_expand"];
    [self.request setStyleId:@"howmuch_request_hide"];
    [self.reset_type setStyleId:@"cancel_request"];
}
- (void) initialize_request
{
    CGRect origin = self.reset_type.frame;
    origin.origin.x = 160;
    [self.reset_type setFrame:origin];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.recip_back setStyleClass:@"barbackground_blue"];
    origin.origin.x = 270; origin.size.width = 40;
    [self.reset_type setFrame:origin];
    origin = self.send.frame;
    origin.size.width = 0; origin.origin.x = 310;
    [self.send setFrame:origin];
    origin = self.request.frame;
    origin.size.width = 260; origin.origin.x = 10;
    [self.request setFrame:origin];
    
    [self.request addTarget:self action:@selector(confirm_request) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reset_type setAlpha:1];
    [self.reset_type setTitle:@"<" forState:UIControlStateNormal];
    [self.request setTitle:@"Confirm Request" forState:UIControlStateNormal];
    
    [self.reset_type setStyleClass:@"button_green"];
    [UIView commitAnimations];
    
    [self.divider setStyleClass:@"animate_roll_right"];
    [self.send setStyleId:@"howmuch_send_hide"];
    [self.request setStyleId:@"howmuch_request_expand"];
    [self.reset_type setStyleId:@"cancel_send"];
}
- (void) reset_send_request
{
    if (![[assist shared] isRequestMultiple] && ![self.receiver valueForKey:@"nonuser"]) {
        self.divider = [UIImageView new];
        [self.divider setStyleId:@"howmuch_divider"];
        [self.divider setAlpha:0];
        [self.view addSubview:self.divider];
    }
   
    
    CGRect origin = self.reset_type.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.recip_back setStyleClass:@"barbackground_gray"];
    origin = self.send.frame;
    origin.size.width = 150; origin.origin.x = 160;
    [self.send setFrame:origin];
    origin = self.request.frame;
    origin.size.width = 150; origin.origin.x = 10;
    [self.request setFrame:origin];
    
    [self.send removeTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
    [self.request removeTarget:self action:@selector(confirm_request) forControlEvents:UIControlEventTouchUpInside];
    [self.send addTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];
    [self.request addTarget:self action:@selector(initialize_request) forControlEvents:UIControlEventTouchUpInside];
    
    [self.divider setAlpha:1];
    [self.reset_type setAlpha:0];
    [self.reset_type setTitle:@"" forState:UIControlStateNormal];
    [self.send setTitle:@"Send" forState:UIControlStateNormal];
    [self.request setTitle:@"Request" forState:UIControlStateNormal];
    [UIView commitAnimations];
    
    [self.send setStyleId:@"howmuch_send"];
    [self.request setStyleId:@"howmuch_request"];
}

- (void) confirm_send
{

    if ([self.amnt floatValue] == 0)
            
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!" message:@"Minimum amount that can be transferred is any amount." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            return;
        }
    if ([[self.amount text] length] < 3) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:@"Please enter a valid amount" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    else if ([[[self.amount text] substringFromIndex:1] doubleValue] > 100)
        
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa Now" message:[NSString stringWithFormat:@"Sorry I’m not sorry, but don’t %@ more than $100. It’s against the rules (and protects the account from abuse.)", @"send"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
        
    }
    /*if ([[[self.amount text] substringFromIndex:1] floatValue]>[[user objectForKey:@"Balance"] floatValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!" message:@"Thanks for testing this impossibility, but you can't transfer more than you have in your Nooch account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Add Funds", nil];
        [alert setTag:2122];
        [alert show];
        return;
    }*/
    //[user objectForKey:@"Balance"]
    NSMutableDictionary *transaction = [self.receiver mutableCopy];
    [transaction setObject:[self.memo text] forKey:@"memo"];
    
    float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
    if ([self.receiver valueForKey:@"nonuser"]) {
        TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"nonuser" amount:input_amount];
        [self.navigationController pushViewController:pin animated:YES];
    }
    else
    {
        TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"send" amount: input_amount];
        [self.navigationController pushViewController:pin animated:YES];
    }
}
#pragma mark  - alert view delegation
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([actionSheet tag] == 2122 && buttonIndex==1)
    {
        Deposit *dp=[Deposit new];
        [self.navigationController pushViewController:dp animated:YES];
        
    }
}
- (void) confirm_request
{
   // isAddRequest=YES;
    if ([[self.amount text] length] < 3) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:@"Please enter a valid amount" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    else if ([[[self.amount text] substringFromIndex:1] doubleValue] > 100)
        
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa Now" message:[NSString stringWithFormat:@"Sorry I’m not sorry, but don’t %@ more than $100. It’s against the rules (and protects the account from abuse.)", @"request"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
        
    }
    if ([[assist shared]isRequestMultiple]) {
        NSMutableDictionary *transaction = [[NSMutableDictionary alloc]init];
        [transaction setObject:[self.memo text] forKey:@"memo"];
        float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
        TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"request" amount:input_amount];
        [self.navigationController pushViewController:pin animated:YES];
    }
    else{
    NSMutableDictionary *transaction = [self.receiver mutableCopy];
    [transaction setObject:[self.memo text] forKey:@"memo"];
    float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];
    TransferPIN *pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"request" amount:input_amount];
    [self.navigationController pushViewController:pin animated:YES];
    }
}

#pragma mark - picture attaching
- (void) attach_pic
{
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    [self.shade setBackgroundColor:kNoochGrayDark]; [self.shade setAlpha:0.0];
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
    [UIView setAnimationDuration:1];
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
    //[self.shade removeFromSuperview];
    [self.choose removeFromSuperview];
    [self.shade setAlpha:0.0];
    [UIView commitAnimations];
}
- (void) take_photo
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
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
    //[self.amount becomeFirstResponder];
    
    //[self cancel_photo];
}
- (void) from_album
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self cancel_photo];
   
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    chosenImage = [chosenImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(150,150) interpolationQuality:kCGInterpolationMedium];

    //[self.camera setStyleId:@"howmuch_camera_attached"];
    
    [WTGlyphFontSet setDefaultFontSetName: @"fontawesome"];
    UIImageView *ttt = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [ttt setImage:[UIImage imageGlyphNamed:@"camera" height:30 color:kNoochPurple]];
    [self.camera setBackgroundImage:ttt.image forState:UIControlStateNormal];
    
    [[assist shared]setTranferImage:chosenImage];
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        // [self close:nil];
    }];
    
}
-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 75.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 115.0;
        }
        else{
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self cancel_photo];
    [self.camera setStyleId:@"howmuch_camera"];
    [picker dismissViewControllerAnimated:YES completion:^{
        // [self close:nil];
    }];
    // [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1) {
        //        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //        [formatter setNumberStyle:NSNumberFormatterNoStyle];
        //        [formatter setPositiveFormat:@"$ ##.##"];
        //        [formatter setLenient:YES];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setGeneratesDecimalNumbers:YES];
        [formatter setUsesGroupingSeparator:YES];
        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        
        if([string length] == 0){ //backspace
            if ([self.amnt length] > 0) {
                self.amnt = [[self.amnt substringToIndex:[self.amnt length]-1] mutableCopy];
            }
        }else{
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
        } else {
            [textField setText:@""];
        }
        
        
        return NO;
    }
    
    if (textField.tag == 2) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 25) ? NO : YES;
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
