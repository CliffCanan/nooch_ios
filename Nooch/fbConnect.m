//
//  fbConnect.m
//  Nooch
//
//  Created by Vicky Mathneja on 13/11/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "fbConnect.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "Home.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface fbConnect ()

@property(nonatomic,strong) UIButton *facebook;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation fbConnect

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Social Settings";
    self.artisanNameTag = @"Social Settings Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:NSLocalizedString(@"SocSettings_ScrnTitle", @"Social Settings Screen Title")];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .25;
    [self.view addSubview:backgroundImage];

    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setHidesBackButton:YES];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backtn)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

    [self.navigationItem setLeftBarButtonItem:menu];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 250, 25)];
    [title setStyleClass:@"refer_header"];
    [title setText:NSLocalizedString(@"SocSettings_LnkdNtwrksHdr", @"Social Settings linked networks header")];
    [self.view addSubview:title];

    self.facebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebook setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.19) forState:UIControlStateNormal];
    self.facebook.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.facebook setTitle:NSLocalizedString(@"SocSettings_FbBtn1", @"Social Settings FB Btn not connected text") forState:UIControlStateNormal];
    [self.facebook setFrame:CGRectMake(20, 60, 280, 50)];
    [self.facebook setStyleClass:@"button_blue"];
    [self.view addSubview:self.facebook];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    //NSLog(@"fb id: %@",[user valueForKey:@"facebook_id"]);

    if ([[user valueForKey:@"facebook_id"] length] == 0 ||
        [[user valueForKey:@"facebook_id"] isKindOfClass:[NSNull class]])
    {
        UILabel * glyphFB = [UILabel new];
        [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
        [glyphFB setFrame:CGRectMake(19, 8, 30, 30)];
        [glyphFB setTextColor:[UIColor whiteColor]];
        glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];

        [self.facebook addSubview:glyphFB];
        [self.facebook addTarget:self action:@selector(toggleFacebookLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ( ([user valueForKey:@"facebook_id"] && [[user valueForKey:@"facebook_id"] length] > 2) ||
              [FBSDKAccessToken currentAccessToken] )
    {
        [self.facebook setTitle:NSLocalizedString(@"SocSettings_FbBtn2", @"Social Settings FB Btn connected text") forState:UIControlStateNormal];

        UILabel * glyphFB = [UILabel new];
        [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
        [glyphFB setFrame:CGRectMake(17, 8, 26, 30)];
        glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];
        [glyphFB setTextColor:[UIColor whiteColor]];
        [self.facebook addSubview:glyphFB];

        UILabel * glyph_check = [UILabel new];
        [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:13]];
        [glyph_check setFrame:CGRectMake(36, 8, 18, 30)];
        glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:textAttributes];
        [glyph_check setTextColor:[UIColor whiteColor]];

        [self.facebook addSubview:glyph_check];
        [self.facebook addTarget:self action:@selector(disconnect_fb) forControlEvents:UIControlEventTouchUpInside];
    }

    UILabel * info = [UILabel new];
    [info setFrame:CGRectMake(15, 118, 290, 60)];
    [info setNumberOfLines:0];
    [info setTextAlignment:NSTextAlignmentCenter];
    [info setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [info setTextColor:[Helpers hexColor:@"6c6e71"]];
    [info setText:NSLocalizedString(@"SocSettings_Instruct", @"Social Settings instruction text")];
    [self.view addSubview:info];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ARTrackingManager trackEvent:@"SocSet_viewDidAppear"];
}

-(void)disconnect_fb
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SocSettings_DisconnectAlrtTitle", @"Social Settings FB disconnect Alert Title")
                                                 message:NSLocalizedString(@"SocSettings_DisconnectAlrtBody", @"Social Settings FB disconnect Alert Body Text")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"SocSettings_NoTxt", @"'No' button")
                                       otherButtonTitles:NSLocalizedString(@"SocSettings_YesTxt", @"'Yes' button"),nil];
    av.tag = 10;
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10 && buttonIndex == 1)
    {
        [self userLoggedOut];

        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];

        if ([user valueForKey:@"facebook_id"])
        {
            serve *fb = [serve new];
            [fb setDelegate:self];
            [fb setTagName:@"fb_NO"];
            [fb storeFB:@"" isConnect:@"NO"];
        }
    }
}

-(void)backtn
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)toggleFacebookLogin:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error)
        {
            [self userLoggedOut];
        }
        else if (result.isCancelled)
        {
            // Handle cancellations
            [self userLoggedOut];
        }
        else
        {
            // If you ask for multiple permissions at once, you should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"email"])
            {
                NSLog(@"fbConnect.m -> Login w FB successful - FB ID is: %@",[[FBSDKAccessToken currentAccessToken] userID]);

                [user setObject:[[FBSDKAccessToken currentAccessToken] userID] forKey:@"facebook_id"];
                [user synchronize];

                serve * storeFbID = [serve new];
                [storeFbID setDelegate:self];
                [storeFbID setTagName:@"fb_YES"];
                [storeFbID storeFB:[[FBSDKAccessToken currentAccessToken] userID] isConnect:@"YES"];

                [ARProfileManager setUserFacebook:[[FBSDKAccessToken currentAccessToken] userID]];

                // Update UI
                [self userLoggedIn];
            }
        }
    }];
}

// Facebook: Show the user the logged-out UI
- (void)userLoggedOut
{
    for (UIView *subview in self.facebook.subviews) {
        if ([subview isMemberOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    [self.facebook setTitle:NSLocalizedString(@"SocSettings_FbBtn1", @"Social Settings FB Btn not connected text") forState:UIControlStateNormal];
    UILabel * glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyphFB setFrame:CGRectMake(19, 8, 30, 30)];
    [glyphFB setTextColor:[UIColor whiteColor]];
    glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];
    [self.facebook addSubview:glyphFB];

    [self.facebook removeTarget:self action:@selector(disconnect_fb) forControlEvents:UIControlEventTouchUpInside];
    [self.facebook addTarget:self action:@selector(toggleFacebookLogin:) forControlEvents:UIControlEventTouchUpInside];

    [ARProfileManager clearVariable:@"UserFacebook"];
}

// Facebook: Show the user the logged-in UI
- (void)userLoggedIn
{
    for (UIView *subview in self.facebook.subviews) {
        if ([subview isMemberOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    [self.facebook setTitle:NSLocalizedString(@"SocSettings_FbBtn2", @"Social Settings FB Btn connected text") forState:UIControlStateNormal];

    UILabel * glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:19]];
    [glyphFB setFrame:CGRectMake(17, 8, 26, 30)];
    [glyphFB setTextColor:[UIColor whiteColor]];
    glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];
    
    UILabel * glyph_check = [UILabel new];
    [glyph_check setFont:[UIFont fontWithName:@"FontAwesome" size:15]];
    [glyph_check setFrame:CGRectMake(39, 8, 20, 30)];
    [glyph_check setTextColor:[UIColor whiteColor]];
    glyph_check.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] attributes:textAttributes];

    [self.facebook addSubview:glyphFB];
    [self.facebook addSubview:glyph_check];

    [self.facebook removeTarget:self action:@selector(toggleFacebookLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebook addTarget:self action:@selector(disconnect_fb) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - server Delegation
-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    NSError *error;

    if ([tagName isEqualToString:@"fb_YES"])
    {
        NSMutableDictionary *temp = [NSJSONSerialization
                                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                 options:kNilOptions
                                 error:&error];
        NSLog(@"Listen results for fb_YES: %@",temp);
    }
    else if ([tagName isEqualToString:@"fb_NO"])
    {
        NSMutableDictionary *temp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];
        NSLog(@"Listen results for fb_NO %@",temp);
        [user removeObjectForKey:@"facebook_id"];
        //[user synchronize];
    }
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
}

#pragma mark - file paths
- (NSString *)autoLogin {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end