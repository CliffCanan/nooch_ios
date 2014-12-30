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
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
@interface fbConnect ()<FBLoginViewDelegate>
@property(nonatomic,strong) UIButton *facebook;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation fbConnect

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Social Settings";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"Social Settings"];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .25;
    [self.view addSubview:backgroundImage];

    [self.navigationItem setLeftBarButtonItem:nil];
    UIButton * back_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back_button setStyleId:@"navbar_back"];
    [back_button addTarget:self action:@selector(backtn) forControlEvents:UIControlEventTouchUpInside];
    [back_button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] forState:UIControlStateNormal];
    [back_button setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.16) forState:UIControlStateNormal];
    back_button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 250, 25)];
    [title setStyleClass:@"refer_header"];
    [title setText:@"Linked Social Networks"];
    [self.view addSubview:title];

    self.facebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.facebook setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.19) forState:UIControlStateNormal];
    self.facebook.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.facebook setTitle:@"    Connect To Facebook" forState:UIControlStateNormal];
    [self.facebook setFrame:CGRectMake(20, 60, 280, 50)];
    [self.facebook setStyleClass:@"button_blue"];
    [self.view addSubview:self.facebook];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    NSLog(@"fb id: %@",[user valueForKey:@"facebook_id"]);

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
              (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) )
    {
        [self.facebook setTitle:@"       Facebook Connected" forState:UIControlStateNormal];

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
    [info setText:@"Connect your Facebook account to Nooch to allow quicker login and to share payments with friends."];
    [self.view addSubview:info];

}

-(void)disconnect_fb
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                 message:@"Are you sure you want to disconnect Nooch from facebook?"
                                                delegate:self
                                       cancelButtonTitle:@"No"
                                       otherButtonTitles:@"Yes",nil];
    av.tag = 10;
    [av show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10 && buttonIndex == 1)
    {
        [self userLoggedOut];
        [FBSession.activeSession closeAndClearTokenInformation];

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

- (void)toggleFacebookLogin:(id)sender
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else // If the session state is NOT any of the two "open" states when the button is clicked
    {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Call the sessionStateChanged:state:error method to handle session state changes
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        NSLog(@"FB Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }

    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {  // If the session is closed
        NSLog(@"FB Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }

    // Handle errors
    if (error)
    {
        NSLog(@"FB Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");
            }
            // Handle session closures that happen outside of the app
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
            }
            // For simplicity, here we just show a generic message for all other errors
            // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        // [self userLoggedOut];
    }
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

    [self.facebook setTitle:@"    Connect To Facebook" forState:UIControlStateNormal];
    UILabel * glyphFB = [UILabel new];
    [glyphFB setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [glyphFB setFrame:CGRectMake(19, 8, 30, 30)];
    [glyphFB setTextColor:[UIColor whiteColor]];
    glyphFB.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"] attributes:textAttributes];
    [self.facebook addSubview:glyphFB];

    [self.facebook removeTarget:self action:@selector(disconnect_fb) forControlEvents:UIControlEventTouchUpInside];
    [self.facebook addTarget:self action:@selector(toggleFacebookLogin:) forControlEvents:UIControlEventTouchUpInside];
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

    [self.facebook setTitle:@"       Facebook Connected" forState:UIControlStateNormal];

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

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            // Success! Now set the facebook_id to be the fb_id that was just returned & send to Nooch DB
            [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:@"facebook_id"];
            NSLog(@"fbConnect -> FB id stored in user defaults as: %@",[result objectForKey:@"id"]);

            serve * storeFbID = [serve new];
            [storeFbID setDelegate:self];
            [storeFbID setTagName:@"fb_YES"];
            [storeFbID storeFB:[result objectForKey:@"id"] isConnect:@"YES"];
        }
        else
        {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
}
// Show an alert message (For Facebook methods)
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
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
@end
