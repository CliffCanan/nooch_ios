//
//  SendInvite.m
//  Nooch
//
//  Created by crks on 10/8/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "SendInvite.h"
#import "Home.h"

@interface SendInvite ()
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) NSMutableArray *recents;
@end

@implementation SendInvite

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
    // Do any additional setup after loading the view from its nib.
    
    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, [[UIScreen mainScreen] bounds].size.height-90)];
    [self.contacts setDataSource:self]; [self.contacts setDelegate:self];
    [self.contacts setStyleId:@"refer"];
    [self.contacts setStyleClass:@"raised_view"];
    [self.view addSubview:self.contacts]; [self.contacts reloadData];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
    [title setText:@"Your referral code:"];
    [title setStyleId:@"refer_introtext"];
    [self.view addSubview:title];
    
    code = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 100)];
    [code setStyleId:@"refer_invitecode"];
    [code setText:@"MIKE123"];
    [self.view addSubview:code];
    
    UILabel *with = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 170, 40)];
    [with setStyleClass:@"refer_header"];
    [with setText:@"Refer a friend with..."];
    [self.view addSubview:with];
    
    CGRect frame;
    
    UIButton *sms = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sms setStyleClass:@"refer_buttons"];
    [sms setStyleId:@"refer_sms"];
    [sms addTarget:self action:@selector(SMSClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:sms];
    UILabel *sms_label = [UILabel new];
    frame = sms.frame;
    frame.origin.x -= 5;
    [sms_label setFrame:frame];
    [sms_label setStyleClass:@"refer_buttons_labels"];
    [sms_label setText:@"SMS Text"];
    [self.view addSubview:sms_label];
    
    UIButton *fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fb setStyleClass:@"refer_buttons"];
    [fb setStyleId:@"refer_fb"];
    [fb addTarget:self action:@selector(fbClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:fb];
    UILabel *fb_label = [UILabel new];
    frame = fb.frame;
    frame.origin.x -= 5;
    [fb_label setFrame:frame];
    [fb_label setStyleClass:@"refer_buttons_labels"];
    [fb_label setText:@"Facebook"];
    [self.view addSubview:fb_label];
    
    UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setStyleClass:@"refer_buttons"];
    [twit setStyleId:@"refer_twit"];
    [twit addTarget:self action:@selector(TwitterClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:twit];
    UILabel *twit_label = [UILabel new];
    frame = twit.frame;
    frame.origin.x -= 5;
    [twit_label setFrame:frame];
    [twit_label setStyleClass:@"refer_buttons_labels"];
    [twit_label setText:@"Twitter"];
    [self.view addSubview:twit_label];
    
    UIButton *email = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [email setStyleClass:@"refer_buttons"];
    [email setStyleId:@"refer_email"];
    [email addTarget:self action:@selector(EmailCLicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:email];
    UILabel *email_label = [UILabel new];
    frame = email.frame;
    frame.origin.x -= 5;
    [email_label setFrame:frame];
    [email_label setStyleClass:@"refer_buttons_labels"];
    [email_label setText:@"Email"];
    [self.view addSubview:email_label];
    
    UILabel *invited = [[UILabel alloc] initWithFrame:CGRectMake(20, 265, 170, 40)];
    [invited setStyleClass:@"refer_header"];
    [invited setText:@"Friends you referred:"];
    [self.view addSubview:invited];
    
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"ReferralCode";
    [serveOBJ setDelegate:self];
    [serveOBJ GetReferralCode:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    

}

#pragma mark - server Delegation

-(void) listen:(NSString *)result tagName:(NSString *)tagName{
     NSError* error;
    if ([tagName isEqualToString:@"recents"]) {
       
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        [self.contacts reloadData];
    }
    
   else if ([tagName isEqualToString:@"ReferralCode"]) {
       dictResponse=[NSJSONSerialization
                     JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                     options:kNilOptions
                     error:&error];
        //edit
        NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
        [defaults setValue:[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"] forKey:@"ReferralCode"];
        [defaults synchronize];
        code.text=[NSString stringWithFormat:@"%@",[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"]];
        NSLog(@"%@",dictResponse);
        serve*serveOBJ=[serve new];
       serveOBJ.tagName=@"GetReffereduser";
       
        [serveOBJ setDelegate:self];
        [serveOBJ getInvitedMemberList:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    }
    else if ([tagName isEqualToString:@"GetReffereduser"])
    {
        dictInviteUserList=[[NSMutableDictionary alloc]init];
        dictInviteUserList=[NSJSONSerialization
                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                            options:kNilOptions
                            error:&error];;
        [self.contacts reloadData];
        
        
    }
    else if ([tagName isEqualToString:@"SMS"])
    {
        [SMSView removeFromSuperview];
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch" message:@"Message Sent Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dictInviteUserList valueForKey:@"getInvitedMemberListResult"] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kNoochGrayLight];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    NSDictionary*dict=[[dictInviteUserList valueForKey:@"getInvitedMemberListResult"] objectAtIndex:indexPath.row];
    //commented till url is valid
//    if ([[dict valueForKey:@"Photo"] isKindOfClass:[NSNull class]]) {
//        imageName=@"profile_picture.png";
//    }
//    else
//    {
//        imageName=[dict valueForKey:@"Photo"];
//    }
    UIImageView *user_pic = [UIImageView new];
    [user_pic setStyleClass:@"list_userprofilepic"];
    [user_pic setStyleCSS:@"background-image : url(Preston.png)"];
    [cell.contentView addSubview:user_pic];
    
    UILabel *name = [UILabel new];
    [name setText:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"FirstName"],[dict valueForKey:@"LastName"]]];
    [name setStyleClass:@"refer_name"];
    [cell.contentView addSubview:name];
    start = [[dict valueForKey:@"DateCreated"] rangeOfString:@"("];
    end = [[dict valueForKey:@"DateCreated"] rangeOfString:@")"];
    if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location)
    {
        betweenBraces = [[dict valueForKey:@"DateCreated"] substringWithRange:NSMakeRange(start.location+1, end.location-(start.location+1))];
    }
    newString = [betweenBraces substringToIndex:[betweenBraces length]-8];
    
    NSTimeInterval _interval=[newString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *_date=[_formatter stringFromDate:date];
    

    UILabel *datelbl = [UILabel new];
    [datelbl setText:_date];
    [datelbl setStyleClass:@"refer_datetext"];
    [cell.contentView addSubview:datelbl];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)fbClicked:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
       
        [fbSheet setInitialText:[NSString stringWithFormat:@"%@[%@]-download here :",@"Check out @NoochMoney, the simplest way to pay me back(and pay you back)! Use my referral code",code.text]];
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
    SMSView.backgroundColor=[UIColor grayColor];
    SMSView.alpha=0.0f;
    [self.view addSubview:SMSView];
    UIButton*crossbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    crossbtn.frame=CGRectMake(220, 0, 40, 40);
    [crossbtn setStyleClass:@"smscrossbuttn-icon"];
    
   // [crossbtn setTitle:@"X" forState:UIControlStateNormal];
   // [crossbtn setBackgroundColor:[UIColor orangeColor]];
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
    //NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, 260, 150)];
    [msgTextView setFont:[UIFont systemFontOfSize:16]];
    //NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
    msgTextView.textColor=[UIColor blackColor];
    msgTextView.text=[NSString stringWithFormat:@"Hey,%@ has invited you to use Nooch, the simplest way to pay friends back. Use my referral code [%@] - download here: %@",@"Noochuser" , code.text,@"ow.ly/nGocT"];
    [SMSView addSubview:msgTextView];
    
    btnToSend=[UIButton buttonWithType:UIButtonTypeCustom];
    btnToSend.frame=CGRectMake(80,260 , 70, 30);
   // [btnToSend setBackgroundColor:[UIColor blueColor]];
    [btnToSend setStyleClass:@"invitesendbutton"];
    [btnToSend setTitle:@"Send" forState:UIControlStateNormal];
    [SMSView addSubview:btnToSend];
    [btnToSend addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    SMSView.alpha=1.0f;
       [UIView commitAnimations];
}
-(void)crossClicked
{
    SMSView.alpha=0.0f;
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
       
        serve*serveOBJ=[serve new];
        serveOBJ.tagName=@"SMS";
        [serveOBJ setDelegate:self];
        [serveOBJ SendSMSApi:textPhoneto.text msg:msgTextView.text];
        
    }
    
}
- (IBAction)TwitterClicked:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        //NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@[%@]-download here :",@"Check out @NoochMoney, the simplest way to pay me back! Use my referral code",code.text]];
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
    //NSArray*arrReferCode=[code.text componentsSeparatedByString:@":"];
   // NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *messageBody; // Change the message body to HTML
    messageBody=[NSString stringWithFormat:@"<h5>\"Hi, Your friend %@ has invited you to become a member of Nooch, the simplest way to pay back friends.<br />Accept this invitation by downloading Nooch and using this Referral Code: %@ <br /><br />To learn more about Nooch, check us out</h5> <a href=\"https://www.nooch.com/overview/\">here</a><br /><h6>-Team Nooch\"</h6>",@"Noochuser",code.text];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
