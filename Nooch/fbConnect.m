//
//  fbConnect.m
//  Nooch
//
//  Created by Vicky Mathneja on 13/11/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import "fbConnect.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "Home.h"
@interface fbConnect ()
@property(nonatomic,strong) UIButton *facebook;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation fbConnect

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Social Settings"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:nil];
    UIButton * back_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back_button setStyleId:@"navbar_back"];
    [back_button addTarget:self action:@selector(backtn) forControlEvents:UIControlEventTouchUpInside];
    [back_button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] forState:UIControlStateNormal];
    [back_button setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.16) forState:UIControlStateNormal];
    back_button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.facebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebook setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.19) forState:UIControlStateNormal];
    self.facebook.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.facebook setTitle:@"  Facebook" forState:UIControlStateNormal];
    [self.facebook setFrame:CGRectMake(0, 153, 0, 0)];
   
    [self.facebook setStyleClass:@"button_blue"];
    [self.view addSubview:self.facebook];
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(26, 38, 32, .18);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
    NSLog(@"%@",[user valueForKey:@"facebook_id"]);
    if ([user valueForKey:@"facebook_id"] && [[user valueForKey:@"facebook_id"] length] == 0)
     {
         
         UILabel * glyphFB = [UILabel new];
         [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
         [glyphFB setFrame:CGRectMake(60, 8, 30, 30)];
         glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"]
                                                                  attributes:textAttributes];
         [glyphFB setTextColor:[UIColor whiteColor]];
         
         [self.facebook addSubview:glyphFB];
          [self.facebook addTarget:self action:@selector(connect_to_facebook) forControlEvents:UIControlEventTouchUpInside];

     }
    else{
        [self.facebook setTitle:@"       Facebook Connected" forState:UIControlStateNormal];
        
        UILabel * glyphFB = [UILabel new];
        [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
        [glyphFB setFrame:CGRectMake(17, 8, 26, 30)];
        glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];
        [glyphFB setTextColor:[UIColor whiteColor]];
        [self.facebook addSubview:glyphFB];
        
        UILabel * glyph_check = [UILabel new];
        [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_check setFrame:CGRectMake(39, 8, 20, 30)];
        glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:textAttributes];
        [glyph_check setTextColor:[UIColor whiteColor]];
        
        [self.facebook addSubview:glyph_check];
         [self.facebook addTarget:self action:@selector(disconnect_fb) forControlEvents:UIControlEventTouchUpInside];
       
    }

    
}
-(void)disconnect_fb{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to disconnect Nooch from facebook?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
    [av show];
    av.tag=6;
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
     if (alertView.tag == 6) {
     if (buttonIndex==0) {
     serve *fb = [serve new];
     [fb setDelegate:self];
     [fb setTagName:@"fb_NO"];
     if ([facebook_info objectForKey:@"id"]) {
     
     [fb storeFB:@"" isConnect:@"NO"];
     }

     }
     }
    
}

-(void)backtn {
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - facebook integration
- (void)connect_to_facebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        accountStore = [[ACAccountStore alloc] init];
        facebookAccount = nil;
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"198279616971457",
                                  ACFacebookPermissionsKey: @[@"email",@"user_about_me"],
                                  ACFacebookAudienceKey: ACFacebookAudienceOnlyMe
                                  };
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [accountStore requestAccessToAccountsWithType:facebookAccountType
                                              options:options completion:^(BOOL granted, NSError *e)
         {
             if (!granted) {
                 NSLog(@"didnt grant because: %@",e.description);
             }
             else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                     [self.navigationController.view addSubview:self.hud];
                     self.hud.delegate = self;
                     self.hud.labelText = @"Loading Facebook Info...";
                     [self.hud show:YES];
                 });
                 NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                 facebookAccount = [accounts lastObject];
                 
                 [self finishFb];
             }
         }];
    }
    else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"You do not have a Facebook account attached to this phone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

-(void)renewFb
{
    [accountStore renewCredentialsForAccount:(ACAccount *)facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error){
        if(!error)
        {
            switch (renewResult) {
                case ACAccountCredentialRenewResultRenewed:
                    break;
                case ACAccountCredentialRenewResultRejected:
                    NSLog(@"User declined permission");
                    break;
                case ACAccountCredentialRenewResultFailed:
                    NSLog(@"non-user-initiated cancel, you may attempt to retry");
                    break;
                default:
                    break;
            }
            [self finishFb];
        }
        else{
            NSLog(@"error from renew credentials%@",error);
        }
    }];
}

-(void)finishFb
{
    NSString *acessToken = [NSString stringWithFormat:@"%@",facebookAccount.credential.oauthToken];
    NSDictionary *parameters = @{@"access_token": acessToken,@"fields":@"id,username,first_name,last_name,email"};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodGET
                              URL:feedURL
                              parameters:parameters];
    feedRequest.account = facebookAccount;
    facebook_info = [NSMutableDictionary new];
    [feedRequest performRequestWithHandler:^(NSData *respData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         facebook_info = [NSJSONSerialization
                          JSONObjectWithData:respData //1
                          options:kNilOptions
                          error:&error];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.hud hide:YES];
             
             [[NSUserDefaults standardUserDefaults] setObject:[facebook_info objectForKey:@"id"] forKey:@"facebook_id"];
             serve *fb = [serve new];
             [fb setDelegate:self];
             [fb setTagName:@"fb_YES"];
             if ([facebook_info objectForKey:@"id"]) {
                 [user setObject:[facebook_info objectForKey:@"id"] forKey:@"facebook_id"];
                 [user synchronize];
             [fb storeFB:[facebook_info objectForKey:@"id"] isConnect:@"YES"];
             }
         });
         
     }];
}


#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    NSError *error;
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(26, 38, 32, .18);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    
    if ([tagName isEqualToString:@"fb_YES"])
    {
    NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"%@",temp);
        for (UIView*subview in self.facebook.subviews) {
            if([subview isMemberOfClass:[UILabel class]]) {
                [subview removeFromSuperview];
            }
        }
       
        [self.facebook setTitle:@"       Facebook Connected" forState:UIControlStateNormal];
        
        UILabel * glyphFB = [UILabel new];
        [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
        [glyphFB setFrame:CGRectMake(17, 8, 26, 30)];
        glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];
        [glyphFB setTextColor:[UIColor whiteColor]];
        [self.facebook addSubview:glyphFB];
        
        UILabel * glyph_check = [UILabel new];
        [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_check setFrame:CGRectMake(39, 8, 20, 30)];
        glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:textAttributes];
        [glyph_check setTextColor:[UIColor whiteColor]];
        
        [self.facebook addSubview:glyph_check];
       
        [self.facebook removeTarget:self action:@selector(connect_to_facebook) forControlEvents:UIControlEventTouchUpInside];
        [self.facebook addTarget:self action:@selector(disconnect_fb) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"%@",temp);
        [user  removeObjectForKey:@"facebook_id"];
         [user synchronize];
        NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
        for (UIView*subview in self.facebook.subviews) {
            if([subview isMemberOfClass:[UILabel class]]) {
                [subview removeFromSuperview];
            }
        }
        [self.facebook setTitle:@" Facebook " forState:UIControlStateNormal];
        UILabel * glyphFB = [UILabel new];
        [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
        [glyphFB setFrame:CGRectMake(17, 8, 26, 30)];
        glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];
        [glyphFB setTextColor:[UIColor whiteColor]];
        [self.facebook addSubview:glyphFB];
        
        UILabel * glyph_check = [UILabel new];
        [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
        [glyph_check setFrame:CGRectMake(39, 8, 20, 30)];
        glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:textAttributes];
        [glyph_check setTextColor:[UIColor whiteColor]];
        
        [self.facebook addSubview:glyph_check];
         [self.facebook removeTarget:self action:@selector(disconnect_fb) forControlEvents:UIControlEventTouchUpInside];
        [self.facebook addTarget:self action:@selector(connect_to_facebook) forControlEvents:UIControlEventTouchUpInside];
       
    }
}
-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Error"
                          message:@"Looks like there was some trouble connecting to the right place.  Please try again!"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
