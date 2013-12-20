//
//  refer.m
//  Nooch
//
//  Created by Preston Hults on 7/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "refer.h"
#import "serve.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#define NUMBERSPERIOD       @"0123456789+"
@interface refer ()<MFMailComposeViewControllerDelegate,UITextFieldDelegate>
{
    UIButton*btnToSend;
    NSMutableData*pic;
    NSRange start;
    NSRange end;
    NSString *betweenBraces;
    NSString *newString;
    UITextField*textPhoneto;
    UITextView*msgTextView;
    UIView*SMSView;
   IBOutlet UITableView*tbleViewRefferedUser;
    NSMutableDictionary*dictInviteUserList;

}
@property(nonatomic,retain)NSMutableDictionary*dictInviteUserList;

@property(nonatomic,retain)IBOutlet UITableView*tbleViewRefferedUser;

@end

@implementation refer
@synthesize tbleViewRefferedUser,dictInviteUserList;
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
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    bAmtlbl.text=[NSString stringWithFormat:@"$ %@",[defaults valueForKey:@"BalanceAmountRef"]];
   // NSURL *photoUrl=[[NSURL alloc]initWithString:[defaults objectForKey:@"PhotoUrlRef"]];
    //pic = [NSMutableData dataWithContentsOfURL:photoUrl];
   // Profilepic.image=[UIImage imageWithData:pic];
    
	// Do any additional setup after loading the view.
    ServiceType=@"ReferralCode";
    serve*serveOBJ=[serve new];
    [serveOBJ setDelegate:self];
    [serveOBJ GetReferralCode:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];

    
    
    
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
    //[navCtrl dismissModalViewControllerAnimated:YES];
    [navCtrl dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)fbClicked:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
        [fbSheet setInitialText:[NSString stringWithFormat:@"%@[%@]-download here :",@"Check out @NoochMoney, the simplest way to pay me back(and pay you back)! Use my referral code",[arrReferCode objectAtIndex:1]]];
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
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Message" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
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
    
    
    [SMSView removeFromSuperview];
    SMSView=[[UIView alloc]initWithFrame:CGRectMake(20, 50, 280, 350)];
    SMSView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:SMSView];
    UIButton*crossbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    crossbtn.frame=CGRectMake(220, 0, 40, 40);
    [crossbtn setTitle:@"X" forState:UIControlStateNormal];
    [crossbtn setBackgroundColor:[UIColor orangeColor]];
    [crossbtn addTarget:self action:@selector(crossClicked) forControlEvents:UIControlEventTouchUpInside];
    [SMSView addSubview:crossbtn];
    
    
    textPhoneto=[[UITextField alloc]initWithFrame:CGRectMake(10, 60, 260, 30)];
   
    textPhoneto.textColor = [UIColor blackColor];
    textPhoneto.borderStyle = UITextBorderStyleRoundedRect;
    textPhoneto.font = [UIFont systemFontOfSize:17.0];
    textPhoneto.placeholder = @"Phone Number";
    textPhoneto.backgroundColor = [UIColor whiteColor];
    [SMSView addSubview:textPhoneto];
    [textPhoneto setDelegate:self];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
   msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, 260, 150)];
    [msgTextView setFont:[UIFont systemFontOfSize:16]];
    NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
    msgTextView.textColor=[UIColor blackColor];
    msgTextView.text=[NSString stringWithFormat:@"Hey,%@ has invited you to use Nooch, the simplest way to pay friends back. Use my referral code [%@] - download here: %@",[[defaults valueForKey:@"FullName"] capitalizedString], [arrReferCode objectAtIndex:1],@"ow.ly/nGocT"];
    [SMSView addSubview:msgTextView];
    
    btnToSend=[UIButton buttonWithType:UIButtonTypeCustom];
    btnToSend.frame=CGRectMake(80,260 , 100, 30);
    [btnToSend setBackgroundColor:[UIColor blueColor]];
   
    [btnToSend setTitle:@"Send" forState:UIControlStateNormal];
    [SMSView addSubview:btnToSend];
    [btnToSend addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
    
    
}
-(void)crossClicked
{
    [SMSView removeFromSuperview];

}
-(void)sendSMS:(id)sender

{
    if ([textPhoneto.text length]!=13) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter 13 digit Cell number to send Message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if([textPhoneto.text length]>=13)
    {
        ServiceType=@"SMS";
        serve*serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ SendSMSApi:textPhoneto.text msg:msgTextView.text];
 
    }
    
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
             NSString *output;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled: output = @"Action Cancelled";
                     break;
                 case SLComposeViewControllerResultDone: output = @" Tweet  Successfully"; [self dismissViewControllerAnimated:YES completion:nil]; break;
                 default: break;
             }
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Message" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alert show];
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
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *messageBody; // Change the message body to HTML
    messageBody=[NSString stringWithFormat:@"<h5>\"Hi, Your friend %@ has invited you to become a member of Nooch, the simplest way to pay back friends.<br />Accept this invitation by downloading Nooch and using this Referral Code: %@ <br /><br />To learn more about Nooch, check us out</h5> <a href=\"https://www.nooch.com/overview/\">here</a><br /><h6>-Team Nooch\"</h6>",[[defaults valueForKey:@"FullName"] capitalizedString],[arrReferCode objectAtIndex:1]];
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
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nooch Money" message:@"Mail cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
           // [alert show];
            
            [alert setTitle:@"Mail cancelled"];
            [alert show];
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
           
            [alert setTitle:@"Mail saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
           
            [alert setTitle:@"Mail sent"];
            [alert show];
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
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
    if ([tableView isEqual:tbleViewRefferedUser]) {
        return [[dictInviteUserList valueForKey:@"getInvitedMemberListResult"] count];
    }
    else
    {
    return 4;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    if ([tableView isEqual:tbleViewRefferedUser]) {
      
        NSDictionary*dict=[[dictInviteUserList valueForKey:@"getInvitedMemberListResult"] objectAtIndex:indexPath.row];
        NSString*imageName;
        if ([[dict valueForKey:@"Photo"] isKindOfClass:[NSNull class]]) {
            imageName=@"profile_picture.png";
        }
        else
        {
            imageName=[dict valueForKey:@"Photo"];
        }
        UIImageView*imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame=CGRectMake(10, 5, 50, 50);
        imageView.layer.cornerRadius=25;
        [cell.contentView addSubview:imageView];
        
        
        UILabel*lbl=[[UILabel alloc]initWithFrame:CGRectMake(65, 15, 150, 25)];
        lbl.text=[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"FirstName"],[dict valueForKey:@"LastName"]];
        lbl.font=[UIFont fontWithName:@"Arial" size:12.0f];
        lbl.textColor=[UIColor blackColor];
        lbl.backgroundColor=[UIColor clearColor];
        [cell.contentView addSubview:lbl];
        
       
        start = [[dict valueForKey:@"DateCreated"] rangeOfString:@"("];
         end = [[dict valueForKey:@"DateCreated"] rangeOfString:@")"];
        if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location)
        {
          betweenBraces = [[dict valueForKey:@"DateCreated"] substringWithRange:NSMakeRange(start.location+1, end.location-(start.location+1))];
        }
      newString = [betweenBraces substringToIndex:[betweenBraces length]-8];
        
       // NSString*timeStampString=[[dict valueForKey:@"DateCreated"] substringFromIndex:6];
      //  NSString * timeStampString =[[dict valueForKey:@"DateCreated"] integerValue];
        NSTimeInterval _interval=[newString doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *_date=[_formatter stringFromDate:date];
        
//        NSDate *dateTraded = [NSDate dateWithTimeIntervalSince1970 :[[dict valueForKey:@"DateCreated"] integerValue]];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"dd/mm/yyyy"];
//        
//        //Optionally for time zone converstions
//        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
//        
//        NSString *stringFromDate = [formatter stringFromDate:dateTraded];
        

        UILabel*lbl1=[[UILabel alloc]initWithFrame:CGRectMake(200, 15, 120, 25)];
        lbl1.text=_date;
        lbl1.font=[UIFont fontWithName:@"Arial" size:15];
        lbl1.textColor=[UIColor blueColor];
        lbl1.backgroundColor=[UIColor clearColor];
        [cell.contentView addSubview:lbl1];
        
        

    }
    
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
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Friends you referred";
}
-(void) listen:(NSString *)result tagName:(NSString *)tagName{
    if ([ServiceType isEqualToString:@"ReferralCode"]) {
        dictResponse=[result JSONValue];
        //edit
        NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
        [defaults setValue:[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"] forKey:@"ReferralCode"];
        [defaults synchronize];
        referCode.text=[NSString stringWithFormat:@"Your Code :%@",[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"]];
        NSLog(@"%@",dictResponse);
        serve*serveOBJ=[serve new];
        ServiceType=@"GetReffereduser";
        [serveOBJ setDelegate:self];
        [serveOBJ getInvitedMemberList:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    }
    else if ([ServiceType isEqualToString:@"GetReffereduser"])
    {
        dictInviteUserList=[[NSMutableDictionary alloc]init];
        dictInviteUserList=[result JSONValue];
        [tbleViewRefferedUser reloadData];
        
        
    }
    else if ([ServiceType isEqualToString:@"SMS"])
    {
        [SMSView removeFromSuperview];
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch" message:@"Message Sent Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == textPhoneto)
    {
        if ([string isEqualToString:@""]) {
            if (!textField.text.length)
                return NO;
            if ([[textField.text stringByReplacingCharactersInRange:range withString:string]rangeOfString:@""].length)
                return NO;
        }
        
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 13) {
            
            return NO;
        }
//        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length==13) {
//            btnToSend.enabled=YES;
//        }
//        else
//        {
//            btnToSend.enabled=NO;
//        }
        NSCharacterSet *charcter = [NSCharacterSet characterSetWithCharactersInString:NUMBERSPERIOD];
        if ([string rangeOfCharacterFromSet:charcter].location != NSNotFound) {
            return YES;
        }
        return NO;
    }
    return YES;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)viewDidUnload {
    navBar = nil;
    options = nil;
    referCode = nil;
    [super viewDidUnload];
}
@end
