//  SendInvite.m
//  Nooch
//
//  Created by crks on 10/8/13.
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "SendInvite.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Home.h"
#import "ECSlidingViewController.h"
#import "UIImageView+WebCache.h"
#import "Register.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"

@interface SendInvite ()<ABPeoplePickerNavigationControllerDelegate>
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) NSMutableArray *recents;
@property(nonatomic,strong) MBProgressHUD *hud;

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
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
    self.trackedViewName = @"Refer a Friend Screen";
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];
    
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.navigationItem setTitle:@"Refer a Friend"];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .3;
    [self.view addSubview:backgroundImage];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
    [title setText:@"Your referral code:"];
    [title setStyleId:@"refer_introtext"];
    [self.view addSubview:title];

    code = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 100)];
    [code setStyleId:@"refer_invitecode"];
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

    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWordPress];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = @"Loading important stuff...";
    [self.hud show:YES];
    [spinner1 startAnimating];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    serve * serveOBJ = [serve new];
    serveOBJ.tagName = @"GetReffereduser";
    [serveOBJ setDelegate:self];
    [serveOBJ getInvitedMemberList:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
}

#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

#pragma mark - server Delegation

-(void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    [self.hud hide:YES];

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        
        [timer invalidate];
        
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }
    
    if ([tagName isEqualToString:@"recents"])
    {
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        [self.contacts reloadData];
    }

    else if ([tagName isEqualToString:@"ReferralCode"])
    {
        [blankView removeFromSuperview];
        
        dictResponse = [NSJSONSerialization
                      JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                      options:kNilOptions
                      error:&error];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"] forKey:@"ReferralCode"];
        [defaults synchronize];
        code.text = [NSString stringWithFormat:@"%@",[[dictResponse valueForKey:@"getReferralCodeResult"] valueForKey:@"Result"]];
    }
    else if ([tagName isEqualToString:@"GetReffereduser"])
    {
        [self.hud hide:YES];

        dictInviteUserList=[[NSMutableDictionary alloc]init];
        dictInviteUserList=[NSJSONSerialization
                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                            options:kNilOptions
                            error:&error];
        if ([[dictInviteUserList valueForKey:@"getInvitedMemberListResult"]count] > 0)
        {
            UIView*view_table = [[UIView alloc]initWithFrame:CGRectMake(10, 296, 300, 200)];
            view_table.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:view_table];
            self.contacts = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 300, 190)];
            [self.contacts setDataSource:self];
            [self.contacts setDelegate:self];

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
            [invited setText:@"Friends you referred:"];
            [self.view addSubview:invited];
            [self.contacts setHidden:NO];
            [self.contacts reloadData];
        }
        else
            [self.contacts  setHidden:YES];

        serve * serveOBJ = [serve new];
        serveOBJ.tagName = @"ReferralCode";
        [serveOBJ setDelegate:self];
        [serveOBJ GetReferralCode:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    }
    else if ([tagName isEqualToString:@"SMS"])
    {
        [self.navigationController setNavigationBarHidden:NO];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        SMSView.frame= CGRectMake(0, 568, 320, 568);
        [UIView commitAnimations];
        [SMSView removeFromSuperview];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message Sent Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
         [self callService:@"SM"];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.rowHeight=60;
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
    
    UIImageView *user_pic = [UIImageView new];
    user_pic.clipsToBounds = YES;
    [user_pic setFrame:CGRectMake(12, 7, 46, 46)];
    user_pic.layer.cornerRadius = 23;
    user_pic.layer.borderWidth = 1;
    user_pic.layer.borderColor = [Helpers hexColor:@"6d6e71"].CGColor;
    if ([dict objectForKey:@"Photo"]!=NULL && ![[dict objectForKey:@"Photo"] isKindOfClass:[NSNull class]]) {
        [user_pic setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"Photo"]]
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
    if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location) {
        betweenBraces = [[dict valueForKey:@"DateCreated"] substringWithRange:NSMakeRange(start.location+1, end.location-(start.location+1))];
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
    cell.backgroundColor=[UIColor clearColor];

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

        [fbSheet setInitialText:[NSString stringWithFormat:@"%@ %@ - download here:",@"Check out @NoochMoney, the simplest way to pay me back(and pay you back)! Use my referral code ",code.text]];
        [fbSheet addURL:[NSURL URLWithString:@"ow.ly/nGocT"]];
        [self presentViewController:fbSheet animated:YES completion:nil];

        [fbSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *output;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled: output = @"Action Cancelled";
                     break;
                 case SLComposeViewControllerResultDone: output = @"Post Shared Successfully"; [self dismissViewControllerAnimated:YES completion:nil];
                     [self callService:@"FB"];
                     break;
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
                                  message:@"Please make sure your Facebook account is connected to your iPhone!"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)SMSClicked:(id)sender
{
    [SMSView removeFromSuperview];

    SMSView = [[UIView alloc]initWithFrame:CGRectMake(0, 568, 320, 568)];
    SMSView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:SMSView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.35];
    SMSView.frame = CGRectMake(0, 0, 320, 568);
    [UIView commitAnimations];

    UIView * navBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 62)];
    [navBar setBackgroundColor:[UIColor colorWithRed:63.0f/255.0f green:171.0f/255.0f blue:225.0f/255.0f alpha:1.0f]];
    [SMSView addSubview:navBar];

    UILabel * lbl = [[UILabel alloc]initWithFrame:CGRectMake(100, 23, 120, 33)];
    [lbl setText:@"Send Text"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont systemFontOfSize:21]];
    [lbl setTextColor:[UIColor whiteColor]];
    [SMSView addSubview:lbl];

    UIButton * cancel_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel_btn.frame = CGRectMake(10, 23, 60, 35);
    [cancel_btn setStyleClass:@"smscrossbuttn-icon"];
    [cancel_btn setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    cancel_btn.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [cancel_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel_btn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel_btn addTarget:self action:@selector(crossClicked) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:cancel_btn];

    btnToSend = [UIButton buttonWithType:UIButtonTypeCustom];
    btnToSend.frame = CGRectMake(251, 23, 68, 30);
    [btnToSend setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
    btnToSend.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [btnToSend setTitle:@"Send" forState:UIControlStateNormal];
    [btnToSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [navBar addSubview:btnToSend];
    [btnToSend addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];

    UIButton * phonebookbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phonebookbtn.frame = CGRectMake(245,75, 50,50);
    [phonebookbtn setStyleClass:@"plusbutton"];
    [phonebookbtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    [phonebookbtn setTitle:@"+" forState:UIControlStateNormal];
    [phonebookbtn addTarget:self action:@selector(showcontacts) forControlEvents:UIControlEventTouchUpInside];
    [SMSView addSubview:phonebookbtn];

    msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 125, 300, 200)];
    [msgTextView setFont:[UIFont systemFontOfSize:18]];
    msgTextView.textColor=[UIColor blackColor];
    msgTextView.text=[NSString stringWithFormat:@"Heyo, you should check out Nooch, a great new app for paying me back. Use my referral code: \"%@\" - download here: %@", code.text,@"http://ow.ly/BCuC6"];
    [SMSView addSubview:msgTextView];
    
    textPhoneto = [[UITextField alloc]initWithFrame:CGRectMake(10, 74, 240, 40)];
    textPhoneto.textColor = kNoochGrayDark;
    [textPhoneto setKeyboardType:UIKeyboardTypeNumberPad];
    textPhoneto.inputAccessoryView = [[UIView alloc] init];
    textPhoneto.borderStyle = UITextBorderStyleRoundedRect;
    textPhoneto.font = [UIFont systemFontOfSize:22.0];
    textPhoneto.placeholder = @"Phone Number";
    textPhoneto.backgroundColor = [UIColor whiteColor];
    [textPhoneto becomeFirstResponder];
    [textPhoneto setDelegate:self];
    [SMSView addSubview:textPhoneto];
    
    [self.navigationController setNavigationBarHidden:YES];

}

-(void)showcontacts
{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationController Delegate method implementation

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{

    // Initialize a mutable dictionary and give it initial values.
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                                            forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];

    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }

    // Get the phone numbers as a multi-value property.
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++)
    {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    CFRelease(phonesRef);

    // Get the e-mail addresses as a multi-value property.
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++)
    {
        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
        
        if (CFStringCompare(currentEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"homeEmail"];
        }
        if (CFStringCompare(currentEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"workEmail"];
        }
        CFRelease(currentEmailLabel);
        CFRelease(currentEmailValue);
    }
    CFRelease(emailsRef);

    // Get the first street address among all addresses of the selected contact.
    ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
    if (ABMultiValueGetCount(addressRef) > 0)
    {
        CFTypeRef addressDictV = ABRecordCopyValue(person, kABPersonAddressProperty);
        NSDictionary *addressDict =(__bridge NSDictionary *)(addressDictV);
          [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressStreetKey] forKey:@"address"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressZIPKey] forKey:@"zipCode"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressCityKey] forKey:@"city"];
        CFRelease(addressDictV);

    }
    CFRelease(addressRef);

    // If the contact has an image then get it too.
    if (ABPersonHasImageData(person)) {
        CFTypeRef contactImageV = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
         NSData *contactImageData = (__bridge NSData *)(contactImageV);
          [contactInfoDict setObject:contactImageData forKey:@"image"];
        CFRelease(contactImageV);
    }

    // Initialize the array if it's not yet initialized.
    
    // Add the dictionary to the array.
    if (![[contactInfoDict valueForKey:@"mobileNumber"] isEqualToString:@""]) {
        textPhoneto.text= [contactInfoDict  valueForKey:@"mobileNumber"];
    }
    else
        textPhoneto.text= [contactInfoDict valueForKey:@"homeNumber"];    
    NSLog(@"%@",contactInfoDict );
    // Dismiss the address book view controller.
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

-(void)crossClicked
{
    [self.navigationController setNavigationBarHidden:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    SMSView.frame= CGRectMake(0, 568, 320, 568);
    [UIView commitAnimations];
    [SMSView removeFromSuperview];
}

-(void)sendSMS:(id)sender
{
    if ([textPhoneto.text rangeOfString:@"("].location !=NSNotFound) {
        [textPhoneto.text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    }
    if ([textPhoneto.text rangeOfString:@")"].location !=NSNotFound) {
        [textPhoneto.text stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    if ([textPhoneto.text rangeOfString:@"-"].location !=NSNotFound) {
        [textPhoneto.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    if([textPhoneto.text length]>=10) {
        serve*serveOBJ=[serve new];
        serveOBJ.tagName=@"SMS";
        [serveOBJ setDelegate:self];
        [serveOBJ SendSMSApi:textPhoneto.text msg:msgTextView.text];        
    }
}

- (IBAction)TwitterClicked:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        //NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ %@ - download here :",@"Check out @NoochMoney, the simplest way to pay me back! Use my referral code: ",code.text]];
        [tweetSheet addURL:[NSURL URLWithString:@"ow.ly/nGocT"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];

        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *output;
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled: output = @"Action Cancelled";
                     break;
                 case SLComposeViewControllerResultDone: output = @"Tweet Posted"; [self dismissViewControllerAnimated:YES completion:nil];
                     [self callService:@"TW"];
                     break;
                 default: break;
             }
             if ([output  isEqualToString:@"Tweet Posted"])
             {
                 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Twitter Message" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
    NSString *emailTitle = @"Check out Nooch - a Free App to Pay Me Back";

    NSString * messageBody; // Change the message body to HTML
    messageBody=[NSString stringWithFormat:@"<h5>\"Hi, Your friend %@ has invited you to become a member of Nooch, the simplest way to pay back friends.<br/><br/>Accept this invitation by downloading Nooch from the App Store.  You can use this Referral Code to get exclusive access:<br />  %@  <br /><br />To learn more about Nooch, check us out</h5> <a href=\"https://www.nooch.com/overview/\">here</a><br /><h6>-Team Nooch\"</h6>",[user objectForKey:@"firstName"],code.text];

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
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end