//  SendInvite.m
//  Nooch
//
//  Created by crks on 10/8/13.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "SendInvite.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "Home.h"
#import "ECSlidingViewController.h"
#import "UIImageView+WebCache.h"
#import "Register.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

@interface SendInvite ()<MFMessageComposeViewControllerDelegate>
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) MBProgressHUD *hud;

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

-(void)showMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.screenName = @"Refer a Friend Screen";
    self.artisanNameTag = @"Refer a Friend Screen";
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];

    if (!sentFromStatsScrn)
    {
        UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [hamburger setStyleId:@"navbar_hamburger"];
        [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
        [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
        hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
        [self.navigationItem setLeftBarButtonItem:menu];
    }
    else
    {
        [self.navigationItem setHidesBackButton:YES];

        NSShadow * shadowNavText = [[NSShadow alloc] init];
        shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
        shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
        NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

        UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToStats)];

        UILabel * back_button = [UILabel new];
        [back_button setStyleId:@"navbar_back"];
        [back_button setUserInteractionEnabled:YES];
        [back_button addGestureRecognizer: backTap];
        back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

        UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

        [self.navigationItem setLeftBarButtonItem:menu];
    }
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.navigationItem setTitle:NSLocalizedString(@"ReferFriend_ScrnTitle", @"Profile 'Refer A Friend' Screen Title")];

    UIView *backgroundWhiteLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    backgroundWhiteLayer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backgroundWhiteLayer];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .3;
    [self.view addSubview:backgroundImage];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
    [title setText:NSLocalizedString(@"ReferFriend_YourCdHdr", @"Profile 'Your Referral Code' header label")];
    [title setStyleId:@"refer_introtext"];
    [self.view addSubview:title];

    code = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 100)];
    [code setStyleId:@"refer_invitecode"];
    [self.view addSubview:code];

    UILabel *with = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 170, 40)];
    [with setStyleClass:@"refer_header"];
    [with setText:NSLocalizedString(@"ReferFriend_RfrHdr", @"Profile 'Refer a friend with...' header label")];
    [self.view addSubview:with];

    CGRect frame;

    UIButton * sms = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sms setStyleClass:@"refer_buttons"];
    [sms setStyleId:@"refer_sms"];
    [sms addTarget:self action:@selector(SMSClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:sms];
    UILabel * sms_label = [UILabel new];
    frame = sms.frame;
    frame.origin.x -= 5;
    [sms_label setFrame:frame];
    [sms_label setStyleClass:@"refer_buttons_labels"];
    [sms_label setText:NSLocalizedString(@"ReferFriend_SmsTxt", @"Profile 'SMS Text' label")];
    [self.view addSubview:sms_label];

    UIButton * fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fb setStyleClass:@"refer_buttons"];
    [fb setStyleId:@"refer_fb"];
    [fb addTarget:self action:@selector(fbClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:fb];
    UILabel * fb_label = [UILabel new];
    frame = fb.frame;
    frame.origin.x -= 5;
    [fb_label setFrame:frame];
    [fb_label setStyleClass:@"refer_buttons_labels"];
    [fb_label setText:@"Facebook"];
    [self.view addSubview:fb_label];

    UIButton * twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setStyleClass:@"refer_buttons"];
    [twit setStyleId:@"refer_twit"];
    [twit addTarget:self action:@selector(TwitterClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twit];

    UILabel * twit_label = [UILabel new];
    frame = twit.frame;
    frame.origin.x -= 5;
    [twit_label setFrame:frame];
    [twit_label setStyleClass:@"refer_buttons_labels"];
    [twit_label setText:@"Twitter"];
    [self.view addSubview:twit_label];

    UIButton * email = [UIButton buttonWithType:UIButtonTypeRoundedRect];
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

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWordPress];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"ReferFriend_HUDlbl", @"Profile 'Loading important stuff...' HUD Text");//@"Loading important stuff...";
    [self.hud show:YES];
    [spinner1 startAnimating];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    serve * serveOBJ = [serve new];
    serveOBJ.tagName = @"GetReffereduser";
    [serveOBJ setDelegate:self];
    [serveOBJ getInvitedMemberList:[user objectForKey:@"MemberId"]];

    [ARTrackingManager trackEvent:@"Refer_ViewDidLoad_End"];
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    /*UIAlertView * alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];*/
}

#pragma mark - server Delegation
-(void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    [self.hud hide:YES];

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];

        [timer invalidate];

        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }

    if ([tagName isEqualToString:@"ReferralCode"])
    {
        dictResponse = [NSJSONSerialization
                      JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                      options:kNilOptions
                      error:&error];

        code.text = [NSString stringWithFormat:@"%@",[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"]];
        [code setStyleClass:@"animate_bubble_slow"];

        [user setValue:[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"] forKey:@"ReferralCode"];
        [user synchronize];
    }
    else if ([tagName isEqualToString:@"GetReffereduser"])
    {
        [self.hud hide:YES];

        dictInviteUserList = [NSJSONSerialization
                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                            options:kNilOptions
                            error:&error];

        if ([[dictInviteUserList valueForKey:@"getInvitedMemberListResult"]count] > 0)
        {
            UIView *view_table = [[UIView alloc]initWithFrame:CGRectMake(10, 296, 300, 200)];
            view_table.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:view_table];

            self.contacts = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 300, 190)];
            [self.contacts setDataSource:self];
            [self.contacts setDelegate:self];
            [self.contacts setRowHeight:60];

            view_table.layer.masksToBounds = NO;
            view_table.layer.cornerRadius = 0;
            view_table.layer.shadowOffset = CGSizeMake(0, 2);
            view_table.layer.shadowRadius = 2;
            view_table.layer.shadowOpacity = 0.4;

            self.contacts.backgroundColor = [UIColor clearColor];
            [self.contacts setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            self.contacts.separatorColor = [UIColor clearColor];
            [view_table addSubview:self.contacts];
            [self.contacts reloadData];

            UILabel *invited = [[UILabel alloc] initWithFrame:CGRectMake(20, 262, 170, 40)];
            [invited setStyleClass:@"refer_header"];
            [invited setText:NSLocalizedString(@"ReferFriend_FrndsRfrdHdr", @"Profile 'Friends You Referred:' header label")];
            [self.view addSubview:invited];
            [self.contacts setHidden:NO];
            [self.contacts reloadData];
        }
        else
            [self.contacts  setHidden:YES];

        serve * serveOBJ = [serve new];
        serveOBJ.tagName = @"ReferralCode";
        [serveOBJ setDelegate:self];
        [serveOBJ GetReferralCode:[user objectForKey:@"MemberId"]];
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
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kNoochGrayLight];
    }

    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];

    NSDictionary *dict = [[dictInviteUserList valueForKey:@"getInvitedMemberListResult"] objectAtIndex:indexPath.row];

    UIImageView *user_pic = [UIImageView new];
    user_pic.clipsToBounds = YES;
    [user_pic setFrame:CGRectMake(12, 7, 46, 46)];
    user_pic.layer.cornerRadius = 23;
    user_pic.layer.borderWidth = 1;
    user_pic.layer.borderColor = [Helpers hexColor:@"6d6e71"].CGColor;

    if (  [dict objectForKey:@"Photo"] != NULL &&
        ![[dict objectForKey:@"Photo"] isKindOfClass:[NSNull class]])
    {
        [user_pic sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"Photo"]]
                 placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    else
        [user_pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
    [cell.contentView addSubview:user_pic];
    
    UILabel *name = [UILabel new];
    [name setText:[NSString stringWithFormat:@"%@ %@",[[dict valueForKey:@"FirstName"] capitalizedString],[[dict valueForKey:@"LastName"] capitalizedString]]];
    [name setStyleClass:@"refer_name"];
    [cell.contentView addSubview:name];
    //Date from Time stamp
    start = [[dict valueForKey:@"DateCreated"] rangeOfString:@"("];
    end = [[dict valueForKey:@"DateCreated"] rangeOfString:@")"];
    if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location)
    {
        betweenBraces = [[dict valueForKey:@"DateCreated"] substringWithRange:NSMakeRange(start.location + 1, end.location - (start.location + 1))];
    }
    newString = [betweenBraces substringToIndex:[betweenBraces length]-8];

    NSTimeInterval _interval=[newString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"M/d/yy"];
    NSString *_date=[_formatter stringFromDate:date];

    UILabel *datelbl = [UILabel new];
    [datelbl setText:_date];
    [datelbl setStyleClass:@"refer_datetext"];
    [cell.contentView addSubview:datelbl];

    UILabel *seperatorlbl = [UILabel new];
    [seperatorlbl setBackgroundColor:[UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
    [seperatorlbl setStyleClass:@"refer_seperator"];
    [cell.contentView addSubview:seperatorlbl];
    cell.backgroundColor = [UIColor clearColor];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)fbClicked:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

        [fbSheet setInitialText:[NSString stringWithFormat:@"Check out @Nooch, the simplest way to pay me back (and get paid by anyone - for free)! Use my invite code to sign up: \"%@\"",[code.text uppercaseString]]];
        [fbSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/nooch/id917955306?mt=8"]];
        [self presentViewController:fbSheet animated:YES completion:nil];

        [fbSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *output;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled:
                     [ARTrackingManager trackEvent:@"Refer_FBshare_Canc"];
                     break;
                 case SLComposeViewControllerResultDone:
                     output = @"Post Shared Successfully";
                     [self dismissViewControllerAnimated:YES completion:nil];
                     [self callService:@"FB"];
                     [ARTrackingManager trackEvent:@"Refer_FBshare_Success"];
                     break;
                 default: break;
             }
             if ([output isEqualToString:@"Post Shared Successfully"])
             {
                 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook Message"
                                                                  message:output
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Please connt your Facebook account to your iPhone to make a Facebook post."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)backToStats
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavBarColor:(UIColor *)navBarColor titleColor:(UIColor *)titleColor
{
    [[UINavigationBar appearance] setBarTintColor:navBarColor];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont fontWithName:@"Roboto-Medium" size:18.0f],
                                                          NSFontAttributeName,
                                                          titleColor,
                                                          NSForegroundColorAttributeName,
                                                          nil]];
}

- (IBAction)SMSClicked:(id)sender
{
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView * warningAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Your device doesn't support SMS!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [warningAlert show];
        return;
    }

    [self setNavBarColor:[UIColor whiteColor] titleColor:kNoochGrayDark];

    NSString * message = [NSString stringWithFormat:@"Hey! You should check out Nooch, a great new free app for paying me back. Use my invite code: \"%@\" - download here: %@", code.text,@"http://bit.ly/1xdG2le"];
    
    MFMessageComposeViewController * messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)TwitterClicked:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"Check out @NoochMoney, the simplest free way to pay me back! Use my invite code to sign up: \"%@\"",[code.text uppercaseString]]];
        [tweetSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/nooch/id917955306?mt=8"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];

        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *output;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled: output = @"Action Cancelled";
                     [ARTrackingManager trackEvent:@"Refer_TwtShare_Canc"];
                     break;
                 case SLComposeViewControllerResultDone: output = @"Tweet Posted";
                     [self dismissViewControllerAnimated:YES completion:nil];
                     [self callService:@"TW"];
                     [ARTrackingManager trackEvent:@"Refer_TwtShare_Success"];
                     break;
                 default: break;
             }
             if ([output isEqualToString:@"Tweet Posted"])
             {
                 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Twitter Message"
                                                                  message:output
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                 [alert show];
             }
        }];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Please make sure you have at least one Twitter account setup on your iPhone!"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)callService:(NSString*)shareTo
{
    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    [serveOBJ setTagName:@"ShareCount"];
    [serveOBJ saveShareToFB_Twitter:shareTo];
}

- (IBAction)EmailCLicked:(id)sender
{
    NSString * emailTitle = @"Check out Nooch - a free app to pay me back";

    NSString * messageBody; // Change the message body to HTML
    messageBody=[NSString stringWithFormat:@"Hey there,<br/><p>You should check out Nooch, a great <strong>free iOS app</strong> that lets me pay you back anytime, anywhere.  Since I know you don't like carrying cash around either, I thought you would love using Nooch!</p><p>You can <a href=\"https://itunes.apple.com/us/app/nooch/id917955306?mt=8\">download Nooch</a> from the App Store - and be sure to use my Referral Code to get exclusive access:</p><p style=\"text-align:center;font-size:1.5em;\"><strong>%@</strong></p><p>To learn more about Nooch, here's the website: <a href=\"https://www.nooch.com/overview/\">www.nooch.com</a>.</p><p>- %@</p>",code.text,[user objectForKey:@"firstName"]];

    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];

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
            break;
        case MFMailComposeResultSaved:
            [alert setTitle:@"Mail saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            [alert setTitle:@"Email sent"];
            [alert show];
            [self callService:@"EM"];
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;

        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                   message:@"Failed to send SMS!"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MessageComposeResultSent:
            break;

        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end