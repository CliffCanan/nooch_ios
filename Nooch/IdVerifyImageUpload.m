//
//  IdVerifyImageUpload.m
//  Nooch
//
//  Created by Clifford Canan on 7/16/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "IdVerifyImageUpload.h"
#import <QuartzCore/QuartzCore.h>
#import "assist.h"
#import "ECSlidingViewController.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"

@interface IdVerifyImageUpload ()

@property(nonatomic,strong) UIImageView *pic;
@property(nonatomic,strong) UILabel *message;
@property(nonatomic,strong) UIButton *choose_pic;
@property(nonatomic,strong) UILabel *btnGlyph;
@property(nonatomic) UIImagePickerController *picker;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation IdVerifyImageUpload

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationItem setTitle:@"ID Verification"];

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

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToSettings)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

    [self.navigationItem setLeftBarButtonItem:menu];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 250, 25)];
    [title setStyleClass:@"refer_header"];
    [title setText:@"ID Verification"];
    [self.view addSubview:title];

    UILabel * introTxt = [UILabel new];
    [introTxt setNumberOfLines:0];
    [introTxt setFont:[UIFont fontWithName:@"Roboto" size:15]];
    [introTxt setFrame:CGRectMake(16, 43, 288, 72)];
    [introTxt setText:@"To complete the verification process, please upload any photo ID that includes your name and a clear picture. (Driver's License, university ID, etc.)"];
    [introTxt setTextColor:[Helpers hexColor:@"313233"]];
    [self.view addSubview:introTxt];

    self.pic = [[UIImageView alloc] initWithFrame:CGRectMake(70, introTxt.frame.origin.y + introTxt.frame.size.height + 10, 182, 130)];
    self.pic.layer.cornerRadius = 8;
    self.pic.clipsToBounds = YES;
    self.pic.contentMode = UIViewContentModeScaleAspectFit;
    [self.pic setImage:[UIImage imageNamed:@"silhouette.png"]];
    [self.pic setUserInteractionEnabled:YES];
    [self.pic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attach_pic)]];
    
    self.choose_pic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.choose_pic setFrame:CGRectMake(20, self.pic.frame.origin.y + self.pic.frame.size.height + 15, 280, 50)];
    [self.choose_pic setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.19) forState:UIControlStateNormal];
    self.choose_pic.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.choose_pic setTitle:@"  Take Picture Now" forState:UIControlStateNormal];
    [self.choose_pic setStyleClass:@"button_gray"];
    [self.choose_pic addTarget:self action:@selector(attach_pic) forControlEvents:UIControlEventTouchUpInside];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    self.btnGlyph = [UILabel new];
    [self.btnGlyph setFrame:CGRectMake(19, 9, 30, 30)];
    [self.btnGlyph setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
    [self.btnGlyph setTextColor:[UIColor whiteColor]];
    self.btnGlyph.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-file-image-o"] attributes:textAttributes];

    [self.choose_pic addSubview:self.btnGlyph];
    [self.view addSubview:self.choose_pic];

    UILabel * header2 = [[UILabel alloc] initWithFrame:CGRectMake(16, self.choose_pic.frame.origin.y + self.choose_pic.frame.size.height + 17, 250, 25)];
    [header2 setStyleClass:@"refer_header"];
    [header2 setText:@"Why We Ask"];
    [self.view addSubview:header2];

    UILabel * info = [UILabel new];
    [info setFrame:CGRectMake(16, header2.frame.origin.y + header2.frame.size.height + 2, 288, 126)];
    [info setNumberOfLines:0];
    [info setTextAlignment:NSTextAlignmentLeft];
    [info setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [info setTextColor:[Helpers hexColor:@"6c6e71"]];
    [info setText:@"Nooch is a money transfer business regulated by the US Treasury Department. To protect all users' accounts, we must collect certain information from our users to verify their identities. We never share your data without your permission and all data is stored with encryption on secure servers."];
    [self.view addSubview:info];

    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Id Verify Img Upload";
    self.artisanNameTag = @"ID Verify Img Upload";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ARTrackingManager trackEvent:@"IdVerImg_viewDidAppear"];

    [self.pic addStyleClass:@"animate_bubble_slow"];
    [self.view addSubview:self.pic];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma Image Picker methods
- (void)attach_pic
{
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"SelPic_CancelTxt", @"Select Picture screen 'Cancel' Btn Text")
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"SelPic_UseCamTxt", @"Select Picture screen 'Use Camera' Text"), NSLocalizedString(@"SelPic_UseiPhnLibTxt", @"Select Picture screen 'From iPhone Library' Text"), nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
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

    [self dismissViewControllerAnimated:YES completion:^{
        self.slidingViewController.panGesture.enabled = NO;
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    }];

    self.pic.layer.borderWidth = 2;
    self.pic.layer.borderColor = kNoochGreen.CGColor;

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    self.btnGlyph.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-upload"] attributes:textAttributes];
    [self.btnGlyph setFrame:CGRectMake(75, 9, 30, 30)];

    [self.choose_pic setTitle:@"   Submit" forState:UIControlStateNormal];
    [self.choose_pic removeTarget:self action:@selector(attach_pic) forControlEvents:UIControlEventTouchUpInside];
    [self.choose_pic addTarget:self action:@selector(submit_pic) forControlEvents:UIControlEventTouchUpInside];
    [self.choose_pic setStyleClass:@"button_blue"];
    [self.choose_pic setTitleShadowColor:Rgb2UIColor(26, 32, 38, 0.2) forState:UIControlStateNormal];
    self.choose_pic.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1
{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.panGesture.enabled = NO;
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma Alert & Action Sheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    
    if (buttonIndex == 0)
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
        
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.allowsEditing = YES;
        [self presentViewController:self.picker animated:YES completion:Nil];
    }
    else if (buttonIndex == 1)
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10 && buttonIndex == 1)
    {

    }
}

-(void)backToSettings
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submit_pic
{
    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Submitting image...";
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    [self.hud show:YES];

    serve * serveOBJ = [serve new];
    serveOBJ.Delegate = self;
    serveOBJ.tagName = @"SubmitIdImg";
    //[serveOBJ RemoveSynapseBankAccount];

    [self performSelector:@selector(test01) withObject:nil afterDelay:1];
}

-(void)test01 {
    [self.hud hide:YES];
}

#pragma mark - server Delegation
-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];
    NSError *error;
    
    if ([tagName isEqualToString:@"SubmitIdImg"])
    {
        NSMutableDictionary * resp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];

        NSLog(@"Listen results for SubmitIdImg: %@", resp);
    }
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    /*UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle:@"Connection Error"
     message:@"Looks like there was some trouble connecting to the right place. Please try again!"
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];*/
}

#pragma mark - file paths
-(NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end