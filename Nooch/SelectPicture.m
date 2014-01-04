//
//  SelectPicture.m
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "SelectPicture.h"
#import <QuartzCore/QuartzCore.h>
#import "CreatePIN.h"
#import "assist.h"
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

- (void)change_pic
{
    UIActionSheet *actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Facebook Picture", @"Use Camera", @"From iPhone Library", nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)
    {
        
        self.pic.layer.borderColor = kNoochBlue.CGColor;
        [self.pic setImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];
    }
    else if(buttonIndex == 1)
    {
        
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.picker animated:YES completion:Nil];
       // [self presentModalViewController:self.picker animated:YES];
    }
    
    else if(buttonIndex == 2)
    {
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self.pic setImage:[self imageWithImage:image scaledToSize:CGSizeMake(40, 40)]];
    [[assist shared]setTranferImage:[self imageWithImage:image scaledToSize:CGSizeMake(40, 40)]];
    [self dismissViewControllerAnimated:YES completion:Nil];
   // 29/12
    //[self dismissModalViewControllerAnimated:YES];
    [self.next_button setTitle:@"Continue" forState:UIControlStateNormal];
    [self.next_button removeTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.next_button addTarget:self action:@selector(cont) forControlEvents:UIControlEventTouchUpInside];
    [self.next_button setStyleClass:@"button_green"];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1{
     [self dismissViewControllerAnimated:YES completion:Nil];
    // 29/12
	//[self dismissModalViewControllerAnimated:YES];
}

- (void)next
{
    //[self.user setObject:self.pic.image forKey:@"image"];
    CreatePIN *create_pin = [[CreatePIN alloc] initWithData:self.user];
    [self.navigationController pushViewController:create_pin animated:YES];
}

- (void) cont
{
    [self.user setObject:self.pic.image forKey:@"image"];
    CreatePIN *create_pin = [[CreatePIN alloc] initWithData:self.user];
    [self.navigationController pushViewController:create_pin animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *logo = [UIImageView new];
    [logo setStyleId:@"prelogin_logo"];
    [self.view addSubview:logo];
    
    NSArray *array = [[self.user objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    
    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(0, 135, 320, 25)];
    [welcome setText:[NSString stringWithFormat:@"Hey %@!",[self.user objectForKey:@"first_name" ]]]; [welcome setBackgroundColor:[UIColor clearColor]];
    [welcome setStyleClass:@"header_signupflow"];
    [self.view addSubview:welcome];
    
    self.pic = [[UIImageView alloc] initWithFrame:CGRectMake(89, 170, 144, 144)];
    self.pic.layer.borderColor = kNoochLight.CGColor;
    self.pic.layer.borderWidth = 4;
    self.pic.layer.cornerRadius = 72;
    self.pic.clipsToBounds = YES;
    if ([self.user objectForKey:@"image"]) {
        self.pic.layer.borderColor = kNoochBlue.CGColor;
        [self.pic setImage:[UIImage imageWithData:[self.user objectForKey:@"image"]]];
    } else {
        [self.pic setImage:[UIImage imageNamed:@"silhouette.png"]];
    }
    [self.view addSubview:self.pic];
    
    self.message = [[UILabel alloc] initWithFrame:CGRectMake(20, 310, 280, 70)];
    [self.message setBackgroundColor:[UIColor clearColor]];
    
    if ([self.user objectForKey:@"image"])
    {
        [self.message setText:@"Great Pic! If you're happy with it tap \"Continue\" or if you wish to change it tap \"Change Picture\""];
    }else{
        [self.message setText:@"How about you add a picture so people will be able to identify you better when trasnferring money to you."];
    }
    [self.message setStyleClass:@"instruction_text"];
    [self.message setNumberOfLines:0];
    [self.view addSubview:self.message];
    
    self.choose_pic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.choose_pic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if ([[self.user objectForKey:@"facebook"] objectForKey:@"image"])
    {
        [self.choose_pic setBackgroundColor:kNoochGrayLight];
        [self.choose_pic setTitle:@"Change Picture" forState:UIControlStateNormal];
    }else{
        [self.choose_pic setBackgroundColor:kNoochGreen];
        [self.choose_pic setTitle:@"Choose Picture" forState:UIControlStateNormal];
    }
    [self.choose_pic addTarget:self action:@selector(change_pic) forControlEvents:UIControlEventTouchUpInside];
    [self.choose_pic setFrame:CGRectMake(10, 390, 300, 60)];
    [self.choose_pic setStyleClass:@"button_gray"];
    [self.view addSubview:self.choose_pic];
    
    self.next_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.next_button setFrame:CGRectMake(10, 460, 300, 60)];
    [self.next_button addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.user objectForKey:@"image"])
    {
        [self.next_button setTitle:@"Continue" forState:UIControlStateNormal];
        [self.next_button removeTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [self.next_button addTarget:self action:@selector(cont) forControlEvents:UIControlEventTouchUpInside];
        [self.next_button setStyleClass:@"button_green"];
    }else{
        [self.next_button setBackgroundColor:[UIColor clearColor]];
        [self.next_button setTitleColor:kNoochGrayDark forState:UIControlStateNormal];
        [self.next_button setTitle:@"I don't want to add a picture now..." forState:UIControlStateNormal];
        [self.next_button setStyleClass:@"label_small"];
    }
    
    [self.view addSubview:self.next_button];
    
    self.picker = [UIImagePickerController new];
    self.picker.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
