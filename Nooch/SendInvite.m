//
//  SendInvite.m
//  Nooch
//
//  Created by crks on 10/8/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "SendInvite.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Home.h"
#import "ECSlidingViewController.h"
#import "UIImageView+WebCache.h"
@interface SendInvite ()<ABPeoplePickerNavigationControllerDelegate>
@property(nonatomic,strong) UITableView *contacts;
@property(nonatomic,strong) NSMutableArray *recents;

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.navigationItem setHidesBackButton:YES];
    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setFrame:CGRectMake(0, 0, 40, 40)];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setStyleId:@"navbar_hamburger"];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"Refer a Friend"];
    
    [self.view setStyleClass:@"background_gray"];
    
       UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
    [title setText:@"Your referral code:"];
    [title setStyleId:@"refer_introtext"];
    [self.view addSubview:title];
    
    code = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 100)];
    [code setStyleId:@"refer_invitecode"];
    //[code setText:@"MIKE123"];
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
    
   
    
    serve*serveOBJ=[serve new];
    serveOBJ.tagName=@"GetReffereduser";
    
    [serveOBJ setDelegate:self];
    [serveOBJ getInvitedMemberList:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    
   
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
       
    }
    else if ([tagName isEqualToString:@"GetReffereduser"])
    {
        dictInviteUserList=[[NSMutableDictionary alloc]init];
        dictInviteUserList=[NSJSONSerialization
                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                            options:kNilOptions
                            error:&error];;
        if ([[dictInviteUserList valueForKey:@"getInvitedMemberListResult"]count]>0) {
            self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, [[UIScreen mainScreen] bounds].size.height-90)];
            [self.contacts setDataSource:self]; [self.contacts setDelegate:self];
            
            [self.contacts setStyleId:@"refer"];
            if ([[dictInviteUserList valueForKey:@"getInvitedMemberListResult"] count]==1) {
                [self.contacts setStyleCSS:@"height : 60px"];
            }
          
            [self.contacts setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            self.contacts.separatorColor = [UIColor clearColor];
            //[self.contacts setStyleClass:@"raised_view"];
            [self.view addSubview:self.contacts]; [self.contacts reloadData];
            
            UILabel *invited = [[UILabel alloc] initWithFrame:CGRectMake(20, 265, 170, 40)];
            [invited setStyleClass:@"refer_header"];
            [invited setText:@"Friends you referred:"];
            [self.view addSubview:invited];
           [self.contacts  setHidden:NO];
           [self.contacts reloadData];
            
        }
        else
            [self.contacts  setHidden:YES];
        
        serve*serveOBJ=[serve new];
        serveOBJ.tagName=@"ReferralCode";
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
    NSLog(@"%@",dict);

\
    UIImageView *user_pic = [UIImageView new];
    user_pic.clipsToBounds = YES;
    [user_pic setFrame:CGRectMake(20, 7, 46, 46)];
    user_pic.layer.cornerRadius = 23;
    user_pic.layer.borderWidth = 1;
    user_pic.layer.borderColor = [Helpers hexColor:@"6d6e71"].CGColor;
    if ([dict objectForKey:@"Photo"]!=NULL && ![[dict objectForKey:@"Photo"] isKindOfClass:[NSNull class]]) {
        [user_pic setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"Photo"]]
                 placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
    }
   else
       [user_pic setImage:[UIImage imageNamed:@"RoundLoading.png"]];
    [cell.contentView addSubview:user_pic];
    
    UILabel *name = [UILabel new];
    [name setText:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"FirstName"],[dict valueForKey:@"LastName"]]];
    [name setStyleClass:@"refer_name"];
    [cell.contentView addSubview:name];
    //Date from Time stamp
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
    [_formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *_date=[_formatter stringFromDate:date];
    

    UILabel *datelbl = [UILabel new];
    [datelbl setText:_date];
    [datelbl setStyleClass:@"refer_datetext"];
    [cell.contentView addSubview:datelbl];
  
    UILabel *seperatorlbl = [UILabel new];
    [seperatorlbl setBackgroundColor:[UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
    [seperatorlbl setStyleClass:@"refer_seperator"];
    [cell.contentView addSubview:seperatorlbl];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)fbClicked:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
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
    
    [self.navigationController setNavigationBarHidden:YES];
    [SMSView removeFromSuperview];
    SMSView=[[UIView alloc]initWithFrame:CGRectMake(0, 568, 320, 568)];
    SMSView.backgroundColor=[UIColor whiteColor];
   
    [self.view addSubview:SMSView];
    UIView*navBar=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    [navBar setBackgroundColor:[UIColor colorWithRed:82.0f/255.0f green:176.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
    [SMSView addSubview:navBar];
    UILabel*lbl=[[UILabel alloc]initWithFrame:CGRectMake(135, 20,70, 30)];
    [lbl setText:@"SMS"];
    [lbl setFont:[UIFont systemFontOfSize:22]];
    [lbl setTextColor:[UIColor whiteColor]];
    [SMSView addSubview:lbl];
    
    
    UIButton*crossbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    crossbtn.frame=CGRectMake(10,20, 70,30);
    [crossbtn setStyleClass:@"smscrossbuttn-icon"];
    [crossbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [crossbtn setTitle:@"Cancel" forState:UIControlStateNormal];
   // [crossbtn setBackgroundColor:[UIColor orangeColor]];
    [crossbtn addTarget:self action:@selector(crossClicked) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:crossbtn];
    
    btnToSend=[UIButton buttonWithType:UIButtonTypeCustom];
    btnToSend.frame=CGRectMake(245,20 , 70, 30);
    // [btnToSend setBackgroundColor:[UIColor blueColor]];
    [btnToSend setStyleClass:@"sendInvitebuttn-icon"];
    [btnToSend setTitle:@"Send" forState:UIControlStateNormal];
    [btnToSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [navBar addSubview:btnToSend];
    [btnToSend addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton*phonebookbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    phonebookbtn.frame=CGRectMake(245,75, 50,50);
    [phonebookbtn setStyleClass:@"plusbutton"];
    [phonebookbtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [phonebookbtn setTitle:@"+" forState:UIControlStateNormal];
    // [crossbtn setBackgroundColor:[UIColor orangeColor]];
    [phonebookbtn addTarget:self action:@selector(showcontacts) forControlEvents:UIControlEventTouchUpInside];
    [SMSView addSubview:phonebookbtn];

    
    textPhoneto=[[UITextField alloc]initWithFrame:CGRectMake(10, 74, 240, 40)];
    
    textPhoneto.textColor = [UIColor blackColor];
    textPhoneto.borderStyle = UITextBorderStyleRoundedRect;
    textPhoneto.font = [UIFont systemFontOfSize:30.0];
    textPhoneto.placeholder = @"Phone Number";
    textPhoneto.backgroundColor = [UIColor whiteColor];
    [SMSView addSubview:textPhoneto];
    [textPhoneto becomeFirstResponder];
    [textPhoneto setDelegate:self];
    //NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 125, 300, 200)];
    [msgTextView setFont:[UIFont systemFontOfSize:18]];
    //NSArray*arrReferCode=[referCode.text componentsSeparatedByString:@":"];
    msgTextView.textColor=[UIColor blackColor];
    msgTextView.text=[NSString stringWithFormat:@"Hey,%@ has invited you to use Nooch, the simplest way to pay friends back. Use my referral code [%@] - download here: %@",[user objectForKey:@"firstName"] , code.text,@"ow.ly/nGocT"];
    [SMSView addSubview:msgTextView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
      SMSView.frame= CGRectMake(0, 0, 320, 568);
       [UIView commitAnimations];
}
-(void)showcontacts{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationController Delegate method implementation

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
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
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
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
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
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
    if (ABMultiValueGetCount(addressRef) > 0) {
        NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
        
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressStreetKey] forKey:@"address"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressZIPKey] forKey:@"zipCode"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressCityKey] forKey:@"city"];
    }
    CFRelease(addressRef);
    
    
    // If the contact has an image then get it too.
    if (ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        [contactInfoDict setObject:contactImageData forKey:@"image"];
    }
    
    // Initialize the array if it's not yet initialized.
   
    // Add the dictionary to the array.
   // [_arrContactsData addObject:contactInfoDict];
    if (![[contactInfoDict valueForKey:@"mobileNumber"] isEqualToString:@""]) {
        textPhoneto.text= [contactInfoDict  valueForKey:@"mobileNumber"];
  
    }
    else
        textPhoneto.text= [contactInfoDict valueForKey:@"homeNumber"];

    NSLog(@"%@",contactInfoDict );
    // Reload the table view data.
   // [self.tableView reloadData];
    
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
//    if ([textPhoneto.text length]!=10) {
//        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter 10 digit Cell number to send Message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
    if ([textPhoneto.text rangeOfString:@"("].location !=NSNotFound) {
        [textPhoneto.text stringByReplacingOccurrencesOfString:@"(" withString:@""];
        
    }
    if ([textPhoneto.text rangeOfString:@")"].location !=NSNotFound) {
        [textPhoneto.text stringByReplacingOccurrencesOfString:@")" withString:@""];
        
    }
    if ([textPhoneto.text rangeOfString:@"-"].location !=NSNotFound) {
        [textPhoneto.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
    }
    if([textPhoneto.text length]>=10)
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
    messageBody=[NSString stringWithFormat:@"<h5>\"Hi, Your friend %@ has invited you to become a member of Nooch, the simplest way to pay back friends.<br />Accept this invitation by downloading Nooch and using this Referral Code: %@ <br /><br />To learn more about Nooch, check us out</h5> <a href=\"https://www.nooch.com/overview/\">here</a><br /><h6>-Team Nooch\"</h6>",[user objectForKey:@"firstName"],code.text];
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
