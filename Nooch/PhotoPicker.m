//
//  PhotoPicker.m
//  Nooch
//
//  Created by Vicky Mathneja on 21/11/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "PhotoPicker.h"

@interface PhotoPicker ()

@end

@implementation PhotoPicker
@synthesize isCamra;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // upstatus=0;
	// Do any additional setup after loading the view.
}
-(IBAction)isCamra:(id)sender
{
    switch ([sender tag]) {
        case 1:
            isCamra=YES;
            [self imagepickerOpen:isCamra];
            break;
        case 2:
            isCamra=NO;
            [self imagepickerOpen:isCamra];
            break;
        default:
            break;
    }
}
-(void)imagepickerOpen:(BOOL)cam
{
    if (cam) {
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
    }
    
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
   // if (upstatus==0) {
   //            upstatus=1;
   // }


}

-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
  //  transferOBJ = [self.storyboard instantiateViewControllerWithIdentifier:@"transfer"];
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [[assist shared]setTranferImage:chosenImage];
  
    //imagetoShow.image=chosenImage;
     [picker dismissViewControllerAnimated:YES completion:^{
         [self close:nil];
     }];
    
 //   [self dismissViewControllerAnimated:YES completion:<#^(void)completion#>]
//    [self dismissViewControllerAnimated:YES  completion:^{
//        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES completion:nil];
//    }];
   
     //[self dismissViewControllerAnimated:YES completion:nil];
   
    //sending the map View Controller the pointers to be placed
    
    
    //[nav presentViewController:transferOBJ animated:YES completion:nil];
   
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self close:nil];
    }];
   // [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
