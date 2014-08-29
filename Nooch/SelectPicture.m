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
@interface SelectPicture ()
@property(nonatomic,strong) NSMutableDictionary *user;
@property(nonatomic,strong) UIImageView *pic;
@property(nonatomic,strong) UILabel *message;
@property(nonatomic,strong) UIButton *choose_pic;
@property(nonatomic,strong) UIButton *next_button;
@property(nonatomic) UIImagePickerController *picker;
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
    self.trackedViewName = @"Select Picture Screen";
}
- (void)change_pic {
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Facebook Picture", @"Use Camera", @"From iPhone Library", nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    if(buttonIndex == 0) {
        self.pic.layer.borderColor = kNoochBlue.CGColor;
        [self.pic setImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];
    }
    else if(buttonIndex == 1) {
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
        [self presentViewController:self.picker animated:YES completion:Nil];
        // [self presentModalViewController:self.picker animated:YES];
    }
    else if(buttonIndex == 2) {
        self.picker.allowsEditing = YES;
        [self.picker.view setStyleClass:@"pickerstyle"];
        
        //  [self.picker setModalInPopover:YES];
        self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:self.picker animated:YES completion:Nil];
        //   [self presentModalViewController:self.picker animated:YES];
    }
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

- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info{

    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(120, 120) interpolationQuality:kCGInterpolationMedium];
    [self.pic setImage:image];
    [[assist shared]setTranferImage:image];
    [self dismissViewControllerAnimated:YES completion:^{
        self.slidingViewController.panGesture.enabled=NO;
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    }];
    [self.next_button setTitle:@"Continue" forState:UIControlStateNormal];
    [self.next_button removeTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.next_button addTarget:self action:@selector(cont) forControlEvents:UIControlEventTouchUpInside];
    [self.next_button setStyleClass:@"button_green"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1{
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.panGesture.enabled=NO;
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)next {
    //[self.user setObject:self.pic.image forKey:@"image"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[nav_ctrl performSelector:@selector(disable)];
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.panGesture.enabled=NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView*subview=[[UIView alloc]init];
    subview.frame=self.view.frame;
    subview.backgroundColor=[UIColor clearColor];
    [self.view addSubview:subview];
    
    //back button
    UIButton* btnback=[UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnback setImage:[UIImage imageNamed:@"back-arrow-blue.png"] forState:UIControlStateNormal];
    [btnback setStyleClass:@"back_button-icon"];
    btnback.frame=CGRectMake(0, 7, 50, 30);
    
    [btnback addTarget:self action:@selector(BackClicked1:) forControlEvents:UIControlEventTouchUpInside];
    [subview addSubview:btnback];
    
    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [subview addSubview:logo];
    
    NSArray *array = [[self.user objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    
    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(0, 135, 320, 25)];
    [welcome setText:[NSString stringWithFormat:@"Hey %@!",[[self.user objectForKey:@"first_name" ] capitalizedString]]]; [welcome setBackgroundColor:[UIColor clearColor]];
    [welcome setStyleClass:@"header_signupflow"];
    [subview addSubview:welcome];
    
    self.pic = [[UIImageView alloc] initWithFrame:CGRectMake(89, 170, 144, 144)];
    self.pic.layer.borderColor = kNoochLight.CGColor;
    self.pic.layer.borderWidth = 4;
    self.pic.layer.cornerRadius = 72;
    self.pic.clipsToBounds = YES;
    if ([self.user objectForKey:@"image"]) {
        self.pic.layer.borderColor = kNoochBlue.CGColor;
        [self.pic setImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];
    }
    else {
        [self.pic setImage:[UIImage imageNamed:@"silhouette.png"]];
    }
    [subview addSubview:self.pic];
    
    self.message = [[UILabel alloc] initWithFrame:CGRectMake(20, 315, 280, 70)];
    [self.message setBackgroundColor:[UIColor clearColor]];
    
    if ([self.user objectForKey:@"image"]) {
        [self.message setText:@"Great Pic! If you're happy with it tap \"Continue\" or if you wish to change it tap \"Change Picture\""];
    }
    else{
        [self.message setText:@"Add a picture so people will be able to identify you better when sending you money."];
    }
    [self.message setStyleClass:@"instruction_text"];
    [self.message setNumberOfLines:0];
    [subview addSubview:self.message];
    
    self.choose_pic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.choose_pic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if ([[self.user objectForKey:@"facebook"] objectForKey:@"image"]) {
        [self.choose_pic setStyleClass:@"button_green"];
        [self.choose_pic setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.3) forState:UIControlStateNormal];
        self.choose_pic.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.choose_pic setTitle:@"Change Picture" forState:UIControlStateNormal];
    }
    else{
        [self.choose_pic setStyleClass:@"button_gray"];
        [self.choose_pic setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.3) forState:UIControlStateNormal];
        self.choose_pic.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.choose_pic setTitle:@"Choose Picture" forState:UIControlStateNormal];
    }
    [self.choose_pic addTarget:self action:@selector(change_pic) forControlEvents:UIControlEventTouchUpInside];
    [self.choose_pic setFrame:CGRectMake(10, 390, 300, 60)];
    [subview addSubview:self.choose_pic];
    
    self.next_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.next_button setFrame:CGRectMake(10, 460, 300, 60)];
    [self.next_button addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [self.next_button setFrame:CGRectMake(10, 450, 300, 60)];
    }
    if ([self.user objectForKey:@"image"]) {
        [self.next_button setTitle:@"Continue" forState:UIControlStateNormal];
        [self.next_button removeTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [self.next_button addTarget:self action:@selector(cont) forControlEvents:UIControlEventTouchUpInside];
        [self.next_button setStyleClass:@"button_green"];
    }
    else{
        [self.next_button setBackgroundColor:[UIColor clearColor]];
        [self.next_button setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
        [self.next_button setTitle:@"I don't want to add a picture now..." forState:UIControlStateNormal];
        [self.next_button setStyleClass:@"label_small"];
    }
    
    [subview addSubview:self.next_button];
    
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end