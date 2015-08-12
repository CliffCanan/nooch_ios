//
//  IdVerifyImageUpload.m
//  Nooch
//
//  Created by Clifford Canan on 7/16/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//
#import "SettingsOptions.h"
#import "IdVerifyImageUpload.h"
#import <QuartzCore/QuartzCore.h>
#import "assist.h"
#import "ECSlidingViewController.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"
#import <MMProgressHUD/MMProgressHUD.h>
#import <MMProgressHUD/MMLinearProgressView.h>

@interface IdVerifyImageUpload (){
    UIScrollView * scrollView;
}

@property(nonatomic,strong) UIImageView *pic;
@property(nonatomic,strong) UILabel *message;
@property(nonatomic,strong) UIButton *choose_pic;
@property(nonatomic,strong) UILabel *btnGlyph;
@property(nonatomic) UIImagePickerController *picker;
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

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [scrollView setContentSize:CGSizeMake(320, 600)];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 250, 25)];
    [title setStyleClass:@"refer_header"];
    [title setText:@"ID Verification"];
    [scrollView addSubview:title];

    UILabel * introTxt = [UILabel new];
    [introTxt setNumberOfLines:0];
    [introTxt setFont:[UIFont fontWithName:@"Roboto" size:15]];
    [introTxt setFrame:CGRectMake(16, 43, 288, 72)];
    [introTxt setText:@"To complete the verification process, please upload any photo ID that includes your name and a clear picture. (Driver's license, passport, university ID, etc.)"];
    [introTxt setTextColor:[Helpers hexColor:@"313233"]];
    [scrollView addSubview:introTxt];

    self.pic = [[UIImageView alloc] initWithFrame:CGRectMake(92, introTxt.frame.origin.y + introTxt.frame.size.height + 15, 136, 136)];
    self.pic.layer.cornerRadius = 8;
    self.pic.clipsToBounds = YES;
    self.pic.contentMode = UIViewContentModeScaleAspectFit;
    [self.pic setImage:[UIImage imageNamed:@"silhouette.png"]];
    [self.pic setUserInteractionEnabled:YES];
    [self.pic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attach_pic)]];
    
    self.choose_pic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.choose_pic setFrame:CGRectMake(20, self.pic.frame.origin.y + self.pic.frame.size.height + 18, 280, 50)];
    [self.choose_pic setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.19) forState:UIControlStateNormal];
    self.choose_pic.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.choose_pic setTitle:@"  Take Picture Now" forState:UIControlStateNormal];
    [self.choose_pic setStyleClass:@"button_gray"];
    [self.choose_pic addTarget:self action:@selector(attach_pic) forControlEvents:UIControlEventTouchUpInside];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(32, 33, 34, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    self.btnGlyph = [UILabel new];
    [self.btnGlyph setFrame:CGRectMake(25, 9, 30, 30)];
    [self.btnGlyph setFont:[UIFont fontWithName:@"FontAwesome" size:21]];
    [self.btnGlyph setTextColor:[UIColor whiteColor]];
    self.btnGlyph.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-file-image-o"] attributes:textAttributes];

    [self.choose_pic addSubview:self.btnGlyph];
    [scrollView addSubview:self.choose_pic];

    UILabel * header2 = [[UILabel alloc] initWithFrame:CGRectMake(16, self.choose_pic.frame.origin.y + self.choose_pic.frame.size.height + 20, 250, 20)];
    [header2 setStyleClass:@"refer_header"];
    [header2 setText:@"Why We Ask"];
    [scrollView addSubview:header2];

    UILabel * info = [UILabel new];
    [info setFrame:CGRectMake(16, header2.frame.origin.y + header2.frame.size.height + 2, 288, 130)];
    [info setNumberOfLines:0];
    [info setTextAlignment:NSTextAlignmentLeft];
    [info setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [info setTextColor:[Helpers hexColor:@"6c6e71"]];
    [info setText:@"Nooch is a money transfer business regulated by the US Treasury Department. To protect all accounts, we must collect certain information from our users to verify their identities. We never share your data without your permission and all data is stored with encryption on secure servers."];
    [scrollView addSubview:info];

    [self.view addSubview:scrollView];

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
    [scrollView addSubview:self.pic];
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

#pragma mark - ImagePicker
-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;

    if (imgRatio != maxRatio)
    {
        if (imgRatio < maxRatio)
        {
            imgRatio = 115.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 115.0;
        }
        else
        {
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
    imageShow = [imageShow resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(300, 300) interpolationQuality:kCGInterpolationHigh];
    [[assist shared] setIdDocImage:imageShow];
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

#pragma mark - Alert & Action Sheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];

    if (buttonIndex == 0)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.picker.allowsEditing = YES;
            [self presentViewController:self.picker animated:YES completion:Nil];
        }
        else
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"\xF0\x9F\x98\xAB\nCan't find a camera for this device unfortunately.\n;-("
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            [av show];
        }
    }
    else if (buttonIndex == 1)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            if (self.picker == nil)
            {
                self.picker = [[UIImagePickerController alloc] init];
                self.picker.delegate = self;
            }

            self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            self.picker.allowsEditing = YES;
            if ([[UIScreen mainScreen] bounds].size.height < 500) {
                [self.picker.view setStyleClass:@"pickerstyle_4"];
            }
            else {
                [self.picker.view setStyleClass:@"pickerstyle"];
            }

            [self presentViewController:self.picker animated:true completion:Nil];
        }
        else
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_ErrorTxt", @"Profile 'Error' Text")
                                                                  message:@"We're having a little trouble accessing your device's photo library.\n;-("
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            [av show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        // Go back to main Settings screen
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)backToSettings
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submit_pic
{
    isCancelled = false;

    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:@"Processing..."
                          status:@"Submitting your picture"
             confirmationMessage:@"Cancel Submission?"
                     cancelBlock:^{
                         isCancelled = true;

                         // Go back to main Settings screen after 1s delay
                         double _delayInSeconds = 1;
                         dispatch_time_t _popTime = dispatch_time(DISPATCH_TIME_NOW, _delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(_popTime, dispatch_get_main_queue(), ^(void){
                             [self.navigationController popViewControllerAnimated:YES];
                         });
                     }];
    [[MMProgressHUD sharedHUD] setProgressCompletion:^{
        [MMProgressHUD dismissWithSuccess:@"Success!"];
    }];

    double _delayInSeconds = .9;
    dispatch_time_t _popTime = dispatch_time(DISPATCH_TIME_NOW, _delayInSeconds * NSEC_PER_SEC);
    dispatch_after(_popTime, dispatch_get_main_queue(), ^(void){
        [MMProgressHUD updateProgress:0.3f];

        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (!isCancelled)
            {
                [MMProgressHUD updateProgress:0.52f];

                double delayInSeconds = 0.7;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if (!isCancelled)
                    {
                        [MMProgressHUD updateProgress:0.6f];

                        double delayInSeconds = 1.3;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            if (!isCancelled)
                            {
                                [MMProgressHUD updateProgress:0.72f];

                                double delayInSeconds = 0.9;
                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                    if (!isCancelled)
                                    {
                                        [MMProgressHUD updateProgress:0.86f];
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    });

    serve * submitIdDoc = [serve new];
    submitIdDoc.Delegate = self;
    submitIdDoc.tagName = @"SubmitIdImg";
    [submitIdDoc submitIdDocument];
}

#pragma mark - server Delegation
-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    [MMProgressHUD updateProgress:1.f];

    NSError *error;

    if ([tagName isEqualToString:@"SubmitIdImg"])
    {
        NSMutableDictionary * resp = [NSJSONSerialization
                                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                     options:kNilOptions
                                     error:&error];

        if (resp != NULL)
        {
            if ([[[resp objectForKey:@"SaveVerificationIdDocumentResult"] valueForKey:@"Result"] rangeOfString:@"saved successfully"].length != 0)
            {
                [user setBool:YES forKey:@"isIdVerDocSubmitted"];

                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Picture Submitted"
                                                              message:@"\xF0\x9F\x91\x8D \xF0\x9F\x91\x8D\nWe have received your document.  We will process it as quickly as possible so you can begin sending and receiving money. Usually it takes less than  48 hours\n\nPlease contact support@nooch.com if you have any questions."
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil,nil];
                av.tag = 1;
                [av show];
                return;
            }
        }

        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Picture Not Submitted"
                                                      message:@"Unfortunately we were unable to process that image. Please try again, or if you already have, please email the image to support@nooch.com and we will process it as quickly as possible so you can begin sending and receiving money.\n\nUsually it takes less than  24 hours once we have to document."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil,nil];
        av.tag = 2;
        [av show];
        return;
    }
}

-(void)Error:(NSError *)Error
{
    isCancelled = true;
    [MMProgressHUD dismissWithError:@"Error :-(" title:@"Oh No!"];
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