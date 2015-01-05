//  SelectPicture.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "SelectPicture.h"
#import <QuartzCore/QuartzCore.h>
#import "CreatePIN.h"
#import "assist.h"
#import "ECSlidingViewController.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"
#import <FacebookSDK/FacebookSDK.h>
@interface SelectPicture ()<FBLoginViewDelegate>{
    NSString * fbID;
}
@property(nonatomic,strong) NSMutableDictionary *user;
@property(nonatomic,strong) UIImageView *pic;
@property(nonatomic,strong) UILabel *message;
@property(nonatomic,strong) UIButton *choose_pic;
@property(nonatomic,strong) UIButton *next_button;
@property(nonatomic) UIImagePickerController *picker;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation SelectPicture

- (id)initWithData:(NSDictionary *)usr
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.user = [usr mutableCopy];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.screenName = @"Select Picture Screen";
}

- (void)change_pic
{
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Use Facebook Picture", @"Use Camera", @"From iPhone Library", nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    
    if (buttonIndex == 0)
    {
        [self toggleFacebookLogin];
    }
    else if (buttonIndex == 1)
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
       
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.allowsEditing = YES;
        [self presentViewController:self.picker animated:YES completion:Nil];
    }
    else if (buttonIndex == 2)
    {
        self.picker.allowsEditing = YES;
        if ([[UIScreen mainScreen] bounds].size.height < 500) {
            [self.picker.view setStyleClass:@"pickerstyle_4"];
        }
        else {
            [self.picker.view setStyleClass:@"pickerstyle"];
        }
        self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:self.picker animated:YES completion:Nil];
    }
}

-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;
    
    if(imgRatio!=maxRatio){
        if (imgRatio < maxRatio){
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

- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageShow = [info objectForKey:UIImagePickerControllerEditedImage];
    imageShow = [imageShow resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(150, 150) interpolationQuality:kCGInterpolationMedium];
    [self.pic setImage:imageShow];
    
    [[assist shared]setTranferImage:imageShow];
    [self dismissViewControllerAnimated:YES completion:^{
        self.slidingViewController.panGesture.enabled = NO;
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    }];
    
    self.pic.layer.borderWidth = 3;
    self.pic.layer.borderColor = kNoochBlue.CGColor;

    [self.message setText:@"Great Pic! If you're happy with it tap \"Continue\" or if you wish to change it tap \"Change Picture\""];

    [self.choose_pic setTitle:@"Change Picture" forState:UIControlStateNormal];

    [self.next_button setTitle:@"Continue" forState:UIControlStateNormal];
    [self.next_button removeTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.next_button addTarget:self action:@selector(cont) forControlEvents:UIControlEventTouchUpInside];
    [self.next_button setStyleClass:@"button_green"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1
{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.panGesture.enabled = NO;
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)next {
    CreatePIN *create_pin = [[CreatePIN alloc] initWithData:self.user];
    [self.navigationController pushViewController:create_pin animated:YES];
}

- (void) cont {
    [self.user setObject:self.pic.image forKey:@"image"];
    CreatePIN *create_pin = [[CreatePIN alloc] initWithData:self.user];
    [self.navigationController pushViewController:create_pin animated:YES];
}

-(void) BackClicked1:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.panGesture.enabled=NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];

    UIView * subview = [[UIView alloc]init];
    subview.frame = self.view.frame;
    subview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:subview];

    UIButton *btnback = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnback setBackgroundColor:[UIColor whiteColor]];
    [btnback setFrame:CGRectMake(7, 20, 44, 44)];
    [btnback addTarget:self action:@selector(BackClicked1:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *glyph_back = [UILabel new];
    [glyph_back setBackgroundColor:[UIColor clearColor]];
    [glyph_back setFont:[UIFont fontWithName:@"FontAwesome" size:26]];
    [glyph_back setTextAlignment:NSTextAlignmentCenter];
    [glyph_back setFrame:CGRectMake(0, 14, 44, 44)];
    [glyph_back setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-circle-o-left"]];
    [glyph_back setTextColor:kNoochBlue];
    [btnback addSubview:glyph_back];

    [self.view addSubview:btnback];

    UIImageView * logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];

    NSString * sloganFromArtisan = [ARPowerHookManager getValueForHookById:@"slogan"];
    UILabel * slogan = [[UILabel alloc] initWithFrame:CGRectMake(75, 82, 170, 16)];
    [slogan setBackgroundColor:[UIColor clearColor]];
    [slogan setText:sloganFromArtisan];
    [slogan setFont:[UIFont fontWithName:@"VarelaRound-Regular" size:15]];
    [slogan setStyleClass:@"prelogin_slogan"];
    [self.view addSubview:slogan];

    UILabel * welcome = [[UILabel alloc] initWithFrame:CGRectMake(0, 115, 320, 35)];
    [welcome setText:[NSString stringWithFormat:@"Hey %@!",[[self.user objectForKey:@"first_name" ] capitalizedString]]];
    [welcome setBackgroundColor:[UIColor clearColor]];
    [welcome setStyleClass:@"header_signupflow"];

    self.pic = [[UIImageView alloc] initWithFrame:CGRectMake(89, 166, 144, 144)];
    self.pic.layer.cornerRadius = 72;
    self.pic.clipsToBounds = YES;

    self.message = [[UILabel alloc] initWithFrame:CGRectMake(24, 314, 272, 70)];
    [self.message setBackgroundColor:[UIColor clearColor]];
    [self.message setStyleClass:@"instruction_text"];
    [self.message setNumberOfLines:0];

    self.choose_pic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.choose_pic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.choose_pic setStyleClass:@"button_blue"];
    [self.choose_pic setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.21) forState:UIControlStateNormal];
    self.choose_pic.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.choose_pic addTarget:self action:@selector(change_pic) forControlEvents:UIControlEventTouchUpInside];
    [self.choose_pic setFrame:CGRectMake(10, 392, 300, 50)];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .21);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes1 = @{NSShadowAttributeName: shadow };

    UILabel * glyphcamera = [UILabel new];
    [glyphcamera setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    [glyphcamera setFrame:CGRectMake(40, 10, 26, 28)];
    glyphcamera.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-camera"]
                                                             attributes:textAttributes1];
    [glyphcamera setTextColor:[UIColor whiteColor]];
    
    self.next_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.next_button setFrame:CGRectMake(10, 458, 300, 60)];
    [self.next_button addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [self.pic setFrame:CGRectMake(89, 164, 138, 138)];
        self.pic.layer.cornerRadius = 69;
        [self.message setFrame:CGRectMake(15, 304, 290, 66)];
        [self.choose_pic setFrame:CGRectMake(10, 374, 300, 58)];
        [self.next_button setFrame:CGRectMake(10, 428, 300, 60)];
    }
    
    if ([self.user objectForKey:@"image"])
    {
        self.pic.layer.borderWidth = 3;
        self.pic.layer.borderColor = kNoochBlue.CGColor;
        [self.pic setImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];
        [[assist shared]setTranferImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];

        [self.message setText:@"Great Pic! If you're happy with it tap \"Continue\" or if you wish to change it tap \"Change Picture\""];
        [self.choose_pic setTitle:@"  Change Picture" forState:UIControlStateNormal];

        [self.next_button setTitle:@"Continue" forState:UIControlStateNormal];
        [self.next_button removeTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [self.next_button addTarget:self action:@selector(cont) forControlEvents:UIControlEventTouchUpInside];
        [self.next_button setStyleClass:@"button_green"];
    }
    else
    {
        [self.pic setImage:[UIImage imageNamed:@"silhouette.png"]];

        [self.message setText:@"Add a picture so people can find you more easily when sending you money."];

        [self.choose_pic setTitle:@"  Choose Picture" forState:UIControlStateNormal];

        [self.next_button setBackgroundColor:[UIColor clearColor]];
        [self.next_button setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
        [self.next_button setTitle:@"I don't want to add a picture now..." forState:UIControlStateNormal];
        [self.next_button setStyleClass:@"label_small"];
    }

    [self.choose_pic addSubview:glyphcamera];
    [subview addSubview:welcome];
    [subview addSubview:self.pic];
    [subview addSubview:self.message];
    [subview addSubview:self.choose_pic];
    [subview addSubview:self.next_button];

    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
}

- (void)toggleFacebookLogin
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [self userLoggedIn];
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
    // If the session is closed
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {
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
                alertText = [NSString stringWithFormat:@"Please retry. \n\nIf the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Facebook: Show the user the logged-out UI
- (void)userLoggedOut
{
    [self.pic setImage:[UIImage imageNamed:@"silhouette.png"]];

    [self.message setText:@"Add a picture so people can find you more easily when sending you money."];

    [self.choose_pic setTitle:@"  Choose Picture" forState:UIControlStateNormal];

    [self.next_button setBackgroundColor:[UIColor clearColor]];
    [self.next_button setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
    [self.next_button setTitle:@"I don't want to add a picture now..." forState:UIControlStateNormal];
    [self.next_button setStyleClass:@"label_small"];
}

// Facebook: Show the user the logged-in UI
- (void)userLoggedIn
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
        if (!error)
        {
            // Success! Now set the facebook_id to be the fb_id that was just returned & send to Nooch DB
            fbID = [result objectForKey:@"id"];

            [[NSUserDefaults standardUserDefaults] setObject:fbID forKey:@"facebook_id"];
            NSLog(@"Login w FB successful --> fb id is %@",[result objectForKey:@"id"]);

            // isloginWithFB = YES;
            NSString * imgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbID];

            [self.pic sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:@"profile_picture.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                {
                    [[assist shared]setTranferImage:nil];
                    [[assist shared]setTranferImage:image];
                }
            }];

            self.pic.layer.borderWidth = 4;
            self.pic.layer.borderColor = kNoochBlue.CGColor;
            //  [self.pic setImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];
            
            [self.message setText:@"Great Pic! If you're happy with it tap \"Continue\" or if you wish to change it tap \"Change Picture\""];
            [self.choose_pic setTitle:@"  Change Picture" forState:UIControlStateNormal];
            
            [self.next_button setTitle:@"Continue" forState:UIControlStateNormal];
            [self.next_button removeTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
            [self.next_button addTarget:self action:@selector(cont) forControlEvents:UIControlEventTouchUpInside];
            [self.next_button setStyleClass:@"button_green"];
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
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end