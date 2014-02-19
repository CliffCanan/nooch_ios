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
#import "UIImageView+WebCache.h"
#import "ECSlidingViewController.h"
#import "ProfileInfo.h"
#import "NewBank.h"
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
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    // self.title=[self.charity valueForKey:@"OrganizationName"];
     [self.navigationItem setTitle:[[self.charity valueForKey:@"OrganizationName"] capitalizedString]];
    UIButton*balance = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [balance setFrame:CGRectMake(0, 0, 60, 30)];
    if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
        
        [balance setTitle:[NSString stringWithFormat:@"$%@",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
    }
    else
        
    {
        [balance setTitle:[NSString stringWithFormat:@"$%@",@"00.00"] forState:UIControlStateNormal];
    }
    
    [balance.titleLabel setFont:kNoochFontMed];
    [balance setStyleId:@"navbar_balance"];
    
    [self.navigationItem setRightBarButtonItem:Nil];
    
    UIBarButtonItem *funds = [[UIBarButtonItem alloc] initWithCustomView:balance];
    
    [self.navigationItem setRightBarButtonItem:funds];
    
    image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    [image setImage:[UIImage imageNamed:@"4k_image.png"]];
    [image setStyleClass:@"featured_nonprofit_banner_details"];
    [image setStyleCSS:@"background-image : url(4k_image.png)"];
    [self.view addSubview:image];
    
    info = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, 0, 0)];
    [info setNumberOfLines:0];
    [info setText:@"The 4K for Cancer is a program of the Ulman Cancer Fund for Young Adults. We are a non-profit organization dedicated to enhancing lives by supporting, educating and connecting young adults, and their loved ones, affected by cancer.  Since 2001, groups of college students have undertaken journeys across America with the goal of offering hope, inspiration and support to cancer communities along the way."];
    [info setStyleClass:@"nonprofit_details_desc"];
    [self.view addSubview:info];
    
    UIButton *web = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [web setTitle:@"" forState:UIControlStateNormal];
    [web addTarget:self action:@selector(webRef) forControlEvents:UIControlEventTouchUpInside];
    [web setStyleClass:@"nonprofit_details_buttons"];
    [web setStyleClass:@"nonprofit_details_button_website"];
    [self.view addSubview:web];
    
    UIButton *fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fb setTitle:@"" forState:UIControlStateNormal];
    [fb addTarget:self action:@selector(fbRef) forControlEvents:UIControlEventTouchUpInside];
    [fb setStyleClass:@"nonprofit_details_buttons"];
    [fb setStyleClass:@"nonprofit_details_button_fb"];
    [self.view addSubview:fb];
    
    UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setBackgroundImage:[UIImage imageNamed:@"twitter-icon.png"] forState:UIControlStateNormal];
    [twit setTitle:@"" forState:UIControlStateNormal];
    [twit addTarget:self action:@selector(twRef) forControlEvents:UIControlEventTouchUpInside];
    [twit setStyleClass:@"nonprofit_details_buttons"];
    [twit setStyleClass:@"nonprofit_details_button_twitter"];
    [self.view addSubview:twit];
    
    UIButton *youtube = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [youtube setBackgroundImage:[UIImage imageNamed:@"YouTube.png"] forState:UIControlStateNormal];
    [youtube setTitle:@"" forState:UIControlStateNormal];
    [youtube addTarget:self action:@selector(youRef) forControlEvents:UIControlEventTouchUpInside];
    [youtube setStyleClass:@"nonprofit_details_buttons"];
    [youtube setStyleClass:@"nonprofit_details_button_youtube"];
    [self.view addSubview:youtube];
    
    UILabel *website = [UILabel new];
    [website setText:@"Website"];
    [website setStyleId:@"nonprofit_details_buttons_label_website"];
    [website setStyleClass:@"nonprofit_details_buttons_labels"];
    
    [self.view addSubview:website];
    
    UILabel *facebook = [UILabel new];
    [facebook setText:@"Facebook"];
    [facebook setStyleId:@"nonprofit_details_buttons_label_fb"];
    [facebook setStyleClass:@"nonprofit_details_buttons_labels"];
    
    [self.view addSubview:facebook];
    
    UILabel *twitter = [UILabel new];
    [twitter setText:@"Twitter"];
    [twitter setStyleId:@"nonprofit_details_buttons_label_twitter"];
    [twitter setStyleClass:@"nonprofit_details_buttons_labels"];
    
    [self.view addSubview:twitter];
    
    UILabel *yt = [UILabel new];
    [yt setText:@"Youtube"];
      [yt setStyleId:@"nonprofit_details_buttons_label_youtube"];
    [yt setStyleClass:@"nonprofit_details_buttons_labels"];
  
    [self.view addSubview:yt];
    
    UIButton *donate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [donate setTitle:@"Donate" forState:UIControlStateNormal];
    [donate setStyleClass:@"button_green"];
    [donate setStyleClass:@"nonprofit_details_donatebutton"];
    [donate addTarget:self action:@selector(donate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:donate];
    
    blankView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,320, self.view.frame.size.height)];
    [blankView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    UIActivityIndicatorView*actv=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [actv setFrame:CGRectMake(140,(self.view.frame.size.height/2)-5, 40, 40)];
    [actv startAnimating];
    [blankView addSubview:actv];
    [self .view addSubview:blankView];
    [self.view bringSubviewToFront:blankView];
    
    serve*serveOBJ=[serve new];
    serveOBJ.Delegate=self;
    serveOBJ.tagName=@"npDetail";
    [serveOBJ GetNonProfiltDetail:[self.charity valueForKey:@"NonprofitId"] memberId:[self.charity valueForKey:@"MemberId"]];
}
-(void)webRef{
    if ([weburl length]>0) {
        [self webView:weburl];
    }
}
-(void)fbRef{
    if ([fburl length]>0) {
        [self webView:fburl];
    }
}
-(void)twRef{
    if ([twurl length]>0) {
        [self webView:twurl];
    }
    
}
-(void)youRef{
    if ([youurl length]>0) {
        [self webView:youurl];
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag==147 || alertView.tag==148) && buttonIndex==1) {
        ProfileInfo *prof = [ProfileInfo new];
        [nav_ctrl pushViewController:prof animated:YES];
        [self.slidingViewController resetTopView];
    }
    else if (alertView.tag == 201){
        if (buttonIndex == 1) {
            
            NewBank *add_bank = [NewBank new];
            [nav_ctrl pushViewController:add_bank animated:NO];
            [self.slidingViewController resetTopView];
        }
    }
}
- (void)donate
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    //NSLog(@"%@",[defaults valueForKey:@"IsPrimaryBankVerified"]);
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
        UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"Attach an Account" message:@"Before you can make any transfer you must attach a bank account." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
        [set setTag:201];
        [set show];
        return;
    }
    
    
    if ( ![[assist shared]isBankVerified]) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please validate your Bank Account before Proceeding." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        
        return;
    }
    
    NSLog(@"%@",self.charity);
    NSMutableDictionary*dict_donate=[self.charity mutableCopy];
    if ([dict valueForKey:@"FirstName"]!=NULL && [dict valueForKey:@"LastName"]!=NULL) {
        [dict_donate setValue:[[self.charity valueForKey:@"OrganizationName"] capitalizedString] forKey:@"FirstName"];
        [dict_donate setValue:@"" forKey:@"LastName"];
    }
    
    NSLog(@"%@",dict_donate);
    DonationAmount *da = [[DonationAmount alloc] initWithReceiver:dict_donate];
    [self.navigationController pushViewController:da animated:YES];
}
-(void)webView :(NSString*)urlstr{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 20, 300, 470)];
    webView.layer.borderColor=[[UIColor colorWithRed:58.0f/255.0f green:170.0f/255.0f blue:227.0f/255.0f alpha:1.0f]CGColor];
    webView.layer.borderWidth=2.0f;
    webView.layer.cornerRadius=5.0f;
    webView.tag=55;
    NSURL *url = [NSURL URLWithString:urlstr];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    [self.view addSubview:webView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(close:)
     forControlEvents:UIControlEventTouchDown];
    [button setStyleClass:@"donation_closebutton"];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.frame = CGRectMake(250,0,70,30);
    [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [webView addSubview:button];
}

- (IBAction)close:(id)sender {
    
    [[self.view viewWithTag:55] removeFromSuperview];
    
    
}
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    detaildict=[[NSMutableDictionary alloc] init];
    
    NSError* error;
    detaildict=[NSJSONSerialization
                JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                options:kNilOptions
                error:&error];
    if (![[detaildict valueForKey:@"Description"]isKindOfClass:[NSNull class]]&& [detaildict valueForKey:@"Description"]!=nil && [detaildict valueForKey:@"Description"]!=NULL) {
        info.text=[detaildict valueForKey:@"Description"];
    }
    if (![[detaildict valueForKey:@"BannerImage"]isKindOfClass:[NSNull class]]||[detaildict valueForKey:@"BannerImage"]!=nil) {
        [image setImageWithURL:[NSURL URLWithString:[detaildict valueForKey:@"BannerImage"]]
              placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        
    }
    
    
    if (![[detaildict valueForKey:@"WebsiteUrl"]isKindOfClass:[NSNull class]]&& [detaildict valueForKey:@"WebsiteUrl"]!=nil && [detaildict valueForKey:@"WebsiteUrl"]!=NULL) {
        weburl=[detaildict valueForKey:@"WebsiteUrl"];
    }
    if (![[detaildict valueForKey:@"FBPageAddress"]isKindOfClass:[NSNull class]]&& [detaildict valueForKey:@"WebsiteUrl"]!=nil && [detaildict valueForKey:@"FBPageAddress"]!=NULL) {
        fburl=[detaildict valueForKey:@"FBPageAddress"];
    }
    if (![[detaildict valueForKey:@"TwitterHandle"]isKindOfClass:[NSNull class]]&& [detaildict valueForKey:@"WebsiteUrl"]!=nil && [detaildict valueForKey:@"TwitterHandle"]!=NULL) {
        twurl=[NSString stringWithFormat:@"http://www.twitter.com/%@",[detaildict valueForKey:@"TwitterHandle"]];
    }
    if (![[detaildict valueForKey:@"WebsiteUrl"]isKindOfClass:[NSNull class]]&& [detaildict valueForKey:@"WebsiteUrl"]!=nil && [detaildict valueForKey:@"WebsiteUrl"]!=NULL) {
    }
    NSLog(@"%@",[detaildict valueForKey:@"FirstName"]);
    
    dict=[[NSMutableDictionary alloc]init];
    if (![[self.charity valueForKey:@"FirstName"] isKindOfClass:[NSNull class]]&& [self.charity valueForKey:@"FirstName"] != NULL) {
        ServiceType=@"Fname";
        Decryption *decry = [[Decryption alloc] init];
        decry.Delegate = self;
        decry->tag = [NSNumber numberWithInteger:2];
        [decry getDecryptionL:@"GetDecryptedData" textString:[self.charity valueForKey:@"FirstName"]];
    }
    
}
-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue{
    
    if ([ServiceType isEqualToString:@"Fname"]) {
        [dict setObject:[sourceData valueForKey:@"Status"] forKey:@"FirstName"];
        // [dict setobject:[sourceData valueForKey:@"Status"] forKey:@"FirstName"];
        NSLog(@"%@  %@",dict,[sourceData valueForKey:@"Status"]);
        ServiceType=@"Lname";
        Decryption *decry = [[Decryption alloc] init];
        decry.Delegate = self;
        decry->tag = [NSNumber numberWithInteger:2];
        [decry getDecryptionL:@"GetDecryptedData" textString:[self.charity valueForKey:@"LastName"]];
        
    
    }
    else
    {
        [dict setValue:[sourceData valueForKey:@"Status"] forKey:@"LastName"];
        NSLog(@"%@  %@",dict,[sourceData valueForKey:@"Status"]);
        [blankView removeFromSuperview];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
