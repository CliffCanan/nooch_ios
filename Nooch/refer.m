//
//  refer.m
//  Nooch
//
//  Created by Preston Hults on 7/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "refer.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
@interface refer ()<MFMailComposeViewControllerDelegate>

@end

@implementation refer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [options setScrollEnabled:NO];
    options.layer.cornerRadius = 10;
    options.layer.borderColor = [core hexColor:@"000000"].CGColor;
    options.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(id)sender {
    [navCtrl dismissModalViewControllerAnimated:YES];
}
- (IBAction)fbClicked:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
        [fbSheet setInitialText:[NSString stringWithFormat:@"%@[%@]-download here :",@"Check out @NoochMoney, the simplest way to pay me back! Use my referral code",[arrReferCode objectAtIndex:1]]];
        [fbSheet addURL:[NSURL URLWithString:@"ow.ly/nGocT"]];
        [self presentViewController:fbSheet animated:YES completion:nil];
        
        [fbSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             //NSLog(@"dfsdf");
             NSString *output;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled: output = @"Action Cancelled";
                     break;
                 case SLComposeViewControllerResultDone: output = @" Report Shared Successfully"; [self dismissViewControllerAnimated:YES completion:nil]; break;
                 default: break;
             }
             //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Message" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             //                             [alert show];
         }];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Enable Settings you have at least one Facebook account setup,and make sure your device has an internet connection"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }

}
- (IBAction)SMSClicked:(id)sender {
}
- (IBAction)TwitterClicked:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@[%@]-download here :",@"Check out @NoochMoney, the simplest way to pay me back! Use my referral code",[arrReferCode objectAtIndex:1]]];
        [tweetSheet addURL:[NSURL URLWithString:@"ow.ly/nGocT"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             //NSLog(@"dfsdf");
             NSString *output;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled: output = @"Action Cancelled";
                     break;
                 case SLComposeViewControllerResultDone: output = @"Share Successfully"; [self dismissViewControllerAnimated:YES completion:nil]; break;
                 default: break;
             }
            }];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Enable Settings you have at least one Twitter account setup,and make sure your device has an internet connection"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    

}
- (IBAction)EmailCLicked:(id)sender {
    NSString *emailTitle = @"NoochMoney";
    // Email Content
    NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
   
    NSString *messageBody; // Change the message body to HTML
    messageBody=[NSString stringWithFormat:@"<h2>Hi, Your friend %@ has invited you to become a member of Nooch, the simplest way to pay back friends.<br />Accept this invitation by downloading Nooch and using this Referral Code: %@ <br /><br />To learn more about Nooch, check us out</h2> <a href=\"https://www.nooch.com/overview/\">here</a><br /><h4>-Team Nooch</h4>",@"ABC",[arrReferCode objectAtIndex:1]];
    // To address
    //NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    //[mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.userInteractionEnabled = YES;
    cell.indentationLevel = 1;
    cell.indentationWidth = 60;
    cell.textLabel.font = [core nFont:@"Regular" size:18.0];
    cell.textLabel.textColor = [core hexColor:@"FFFFFF"];
    //UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(24, 4, 32, 32)];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void) listen:(NSString *)result tagName:(NSString *)tagName{
    
}

- (void)viewDidUnload {
    navBar = nil;
    options = nil;
    referCode = nil;
    [super viewDidUnload];
}
@end
