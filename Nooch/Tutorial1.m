//
//  Tutorial1.m
//  Nooch
//
//  Created by Preston Hults on 9/13/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "Tutorial1.h"
#import "terms.h"
#import "NoochHome.h"
#import "AppSkel.h"
#import "Signup.h"
#import "privacy.h"
#import "JSON.h"

@interface Tutorial1 ()
{ serve*serveOBJ;
    NSMutableDictionary*dictResponse;
}
@end

@implementation Tutorial1

@synthesize background,position,backgroundArray,swiper1,swiper2,pageControl,tutorialImage,info1,info2,stepLabel,stepArray,info1Array,info2Array,logo,image2;
@synthesize createAccountButton,loginButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    rainbows = NO;
    fbCreate = NO;
    NSLog(@"%@",v);
    if (![self.view.subviews containsObject:v])
    {
    v=[[UIView alloc]initWithFrame:CGRectMake(320, 0, 320, 600)];
    v.backgroundColor=[UIColor clearColor];
    //shadow.hidden = YES;
    [shadow setAlpha:0.0f];
    UIImageView *temp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
    temp.userInteractionEnabled = YES;
    [shadow addSubview:temp];
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remPopup)];
    [v addGestureRecognizer:touch];
    
        [self.view addSubview:v];
    }
    else
    {
        [v setFrame:CGRectMake(320, 0, 320, 600)];
        v.backgroundColor=[UIColor clearColor];
        //shadow.hidden = YES;
        [shadow setAlpha:0.0f];
        UIImageView *temp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
        temp.userInteractionEnabled = YES;
        [shadow addSubview:temp];
        UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remPopup)];
        [v addGestureRecognizer:touch];
    }
    CGRect frame = requestInviteView.frame;
    frame.origin.x = 10;
    frame.origin.y = 50;
    [requestInviteView setFrame:frame];
    [enterInviteView setFrame:frame];
    [v addSubview:requestInviteView];
    [v addSubview:enterInviteView];

//    CGRect lPos = loginButton.frame;
    //lPos.origin.y = [UIScreen mainScreen].bounds.size.height - 54;
    //[loginButton setFrame:CGRectMake(240, 443, 69, 34)];
}

-(void)listen:(NSString *)result tagName:(NSString*)tagName{
    
        dictResponse=[result JSONValue];
    if ([ServiceType isEqualToString:@"invitecheck"]) {
        
        if ([[[dictResponse valueForKey:@"validateInvitationCodeResult"] stringValue]isEqualToString:@"1"])
        {
            ServiceType=@"validate";
            serveOBJ=[serve new];
            [serveOBJ setDelegate:self];
            [serveOBJ getTotalReferralCode:checkCodeField.text];
            
        }
        else if([[[dictResponse valueForKey:@"validateInvitationCodeResult"] stringValue]isEqualToString:@"0"])
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch" message:@"Not a Valid Invite Code" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    else if ([ServiceType isEqualToString:@"validate"])
    {
        if ([[[dictResponse valueForKey:@"getTotalReferralCodeResult"] valueForKey:@"Result"] isEqualToString:@"True"]) {
            checkCodeField.text=@"";
            Signup*pNooch=[self.storyboard instantiateViewControllerWithIdentifier:@"signup"];
            [self.navigationController pushViewController:pNooch animated:YES];
 
        }
        else
        {
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Sorry! Referral Code Expired" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
           }
    
}



-(void)viewWillDisappear:(BOOL)animated{
    [checkCodeField resignFirstResponder];
    [reqInvField resignFirstResponder];
}
- (IBAction)login:(id)sender {
    [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"login"] animated:YES];
}
- (IBAction)createAcct:(id)sender {
    // [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"signup"] animated:YES];
}
- (IBAction)fbSignup:(id)sender {
    fbCreate = YES;
    [self requestInvite:self];
    //[navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"signup"] animated:YES];
}
- (IBAction)emailSignup:(id)sender {
    fbCreate = NO;
    [self requestInvite:self];
    //[navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"signup"] animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [checkCodeField resignFirstResponder];
    [inviteCodeField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [checkCodeField resignFirstResponder];
    [inviteCodeField resignFirstResponder];
}

-(void)remPopup{
    NSLog(@"%@",v);
    [UIView transitionFromView:enterInviteView toView:requestInviteView
                      duration:1.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:NULL];
    CGRect frame = v.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.5f];
    frame.origin.x = 320;
    [v setFrame:frame];
    [shadow setAlpha:0.0f];
    [UIView commitAnimations];

    [UIView transitionFromView:requestInviteView toView:enterInviteView
                      duration:1.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:NULL];
}
- (IBAction)requestInvite:(id)sender {
    //[self.view addSubview:requestInviteView];
    shadow.hidden = NO;
    [UIView transitionFromView:enterInviteView toView:requestInviteView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:NULL];
    CGRect frame = v.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    frame.origin.x = 0;
    [v setFrame:frame];
    [shadow setAlpha:1.0f];
    [UIView commitAnimations];
    
}

- (IBAction)checkCode:(id)sender {
    if ([checkCodeField.text length]==0) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Enter Referral Code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSString*get4chr=[checkCodeField.text substringToIndex:3];
    if ([[get4chr uppercaseStringWithLocale:[NSLocale currentLocale]]isEqualToString:get4chr]) {
        ServiceType=@"invitecheck";
        serveOBJ=[serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ validateInviteCode:checkCodeField.text];
    }
    else
    {
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"Please Check Your Referral Code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
 //   Boolean validateInvitationCode(string invitationCode);
    
    
    
//    if () {
//        inviteCode = [NSString new];
//        [UIView transitionFromView:enterInviteView toView:requestInviteView
//                          duration:0
//                           options:UIViewAnimationOptionTransitionFlipFromRight
//                        completion:NULL];
//        CGRect frame = v.frame;
//        frame.origin.x = 320;
//        [v setFrame:frame];
//        [shadow setAlpha:0.0f];
//
//        [UIView transitionFromView:requestInviteView toView:enterInviteView
//                          duration:0
//                           options:UIViewAnimationOptionTransitionFlipFromRight
//                        completion:NULL];
//        inviteCode = [NSString stringWithString:checkCodeField.text];
//        [[NSUserDefaults standardUserDefaults] setObject:inviteCode forKey:@"invCode"];
//        [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"signup"] animated:YES];
//    }else{
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Code" message:@"The invite code you have entered is invalid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//    }
}
- (IBAction)enterCode:(id)sender {
    [UIView transitionFromView:requestInviteView toView:enterInviteView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:NULL];
    CGRect frame = v.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    frame.origin.x = 0;
    [v setFrame:frame];
    [UIView commitAnimations];
}
- (IBAction)okRequestInvite:(id)sender {
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //venturepact
    
    
    arrSignUpEntry=[[NSMutableArray alloc]init];
    [arrSignUpEntry addObject:@"Name"];
    [arrSignUpEntry addObject:@"Email"];
    [arrSignUpEntry addObject:@"Password"];
   // [btnfbSignup setStyleClass:@"button_blue"];
   // [btnContinue setStyleClass:@"button_green"];
   // [instruction_text setStyleClass:@"instruction_text"];
    
 //  [loginButton setStyleClass:@"label_small"];
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 480){
        
        loginButton.frame=CGRectMake(200, 443, 70, 34);
    }
    else
        loginButton.frame=CGRectMake(200, 527, 70, 34);
    
    
	// Do any additional setup after loading the view.
    NSLog(@"Tutorial loaded");
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.navigationItem.hidesBackButton = YES;
    swiper1 = [[UISwipeGestureRecognizer alloc] init];
    swiper2 = [[UISwipeGestureRecognizer alloc] init];
    pageControl.contentScaleFactor = 2.0f;
    position = 0;
    stepArray = [[NSMutableArray alloc] initWithObjects:@" ",@"Step One",@"Step Two",@"Step Three",@"Step Four", nil];
    info1Array = [[NSMutableArray alloc] initWithObjects:@" ",@"Create an account!",@"Link a Bank Account!",@"Find your friends!",@"Send Money!", nil];
    info2Array = [[NSMutableArray alloc] initWithObjects:@"Swipe to learn more!",@"Enter your info, choose a picture,\n and validate your account.",@"Add bank info to fund and withdraw \n from your account. Link a credit \n card to send money instantly.",@"Connect with Facebook, your address \n book, or enter email addresses.",@"Select your recepient, enter your \n amount, and press send!", nil];
    info1.font = [UIFont fontWithName:@"Roboto-Medium" size:22];
    info2.font = [UIFont fontWithName:@"Roboto-Medium" size:14];
    stepLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:20];
    backgroundArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"Pic 2.png"],[UIImage imageNamed:@"Tutorial1.png"],[UIImage imageNamed:@"Tutorial2.png"],[UIImage imageNamed:@"Tutorial3.png"],[UIImage imageNamed:@"Tutorial4.png"], nil ];
    if([[UIScreen mainScreen] bounds].size.height > 480){
        pageControl.frame = CGRectMake(pageControl.frame.origin.x,pageControl.frame.origin.y+55,pageControl.frame.size.width,pageControl.frame.size.height);
       // loginButton.frame = CGRectMake(loginButton.frame.origin.x,loginButton.frame.origin.y+68,loginButton.frame.size.width,loginButton.frame.size.height);
        createAccountButton.frame = CGRectMake(createAccountButton.frame.origin.x, createAccountButton.frame.origin.y+68, createAccountButton.frame.size.width, createAccountButton.frame.size.height);
    }
}

- (void)viewDidUnload{
    [self setTutorialImage:nil];
    [self setPageControl:nil];
    [self setInfo2:nil];
    [self setInfo1:nil];
    [self setStepLabel:nil];
    [self setLogo:nil];
    [self setImage2:nil];
    [self setCreateAccountButton:nil];
    [self setLoginButton:nil];
    requestInviteView = nil;
    enterInviteView = nil;
    emailField = nil;
    inviteCodeField = nil;
    shadow = nil;
    reqInvField = nil;
    checkCodeField = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)nextTutorialPage:(id)sender{
    return;
    if(position!=4){
        position++;
        CGRect inFrame = [tutorialImage frame];
        inFrame.origin.x -= 320;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [tutorialImage setFrame:inFrame];
        inFrame = [stepLabel frame];
        inFrame.origin.x -= 320;
        [stepLabel setFrame:inFrame];
        if(position == 1){
            inFrame = [logo frame];
            inFrame.origin.x -= 320;
            [logo setFrame:inFrame];
        }
        inFrame = [info1 frame];
        inFrame.origin.x -= 320;
        [info1 setFrame:inFrame];
        inFrame = [info2 frame];
        inFrame.origin.x -= 320;
        [info2 setFrame:inFrame];
        [UIView commitAnimations];
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(finishNext) userInfo:nil repeats:NO];
    }
}

-(void)finishNext{
    return;
    CGRect inFrame = [tutorialImage frame];
    inFrame.origin.x +=640;
    [tutorialImage setFrame:inFrame];
    inFrame = [stepLabel frame];
    inFrame.origin.x += 640;
    [stepLabel setFrame:inFrame];
    inFrame = [info1 frame];
    inFrame.origin.x += 640;
    [info1 setFrame:inFrame];
    inFrame = [info2 frame];
    inFrame.origin.x += 640;
    [info2 setFrame:inFrame];
    tutorialImage.image = [backgroundArray objectAtIndex:position];
    tutorialImage.hidden = NO;
    stepLabel.text = [stepArray objectAtIndex:position];
    info1.text = [info1Array objectAtIndex:position];
    info2.text = [info2Array objectAtIndex:position];
    inFrame = [tutorialImage frame];
    inFrame.origin.x -= 320;
    logo.hidden = YES;
    tutorialImage.hidden = NO;
    stepLabel.hidden = NO;
    info1.hidden = NO;
    info2.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [tutorialImage setFrame:inFrame];
    inFrame = [stepLabel frame];
    inFrame.origin.x -= 320;
    [stepLabel setFrame:inFrame];
    inFrame = [info1 frame];
    inFrame.origin.x -= 320;
    [info1 setFrame:inFrame];
    inFrame = [info2 frame];
    inFrame.origin.x -= 320;
    [info2 setFrame:inFrame];
    [UIView commitAnimations];
    pageControl.currentPage = position;

}

-(IBAction)previousTutorialPage:(id)sender{
    return;
    if(position!=0){
        position--;
        CGRect inFrame = [tutorialImage frame];
        inFrame.origin.x += 320;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [tutorialImage setFrame:inFrame];
        inFrame = [stepLabel frame];
        inFrame.origin.x += 320;
        [stepLabel setFrame:inFrame];
        inFrame = [info1 frame];
        inFrame.origin.x += 320;
        [info1 setFrame:inFrame];
        inFrame = [info2 frame];
        inFrame.origin.x += 320;
        [info2 setFrame:inFrame];
        [UIView commitAnimations];
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(finishPrevious) userInfo:nil repeats:NO];
    }
}

-(void)finishPrevious{
    return;
    CGRect inFrame = [tutorialImage frame];
    inFrame.origin.x -=640;
    [tutorialImage setFrame:inFrame];
    inFrame = [stepLabel frame];
    inFrame.origin.x -= 640;
    [stepLabel setFrame:inFrame];
    inFrame = [info1 frame];
    inFrame.origin.x -= 640;
    [info1 setFrame:inFrame];
    inFrame = [info2 frame];
    inFrame.origin.x -= 640;
    [info2 setFrame:inFrame];
    tutorialImage.image = [backgroundArray objectAtIndex:position];
    stepLabel.text = [stepArray objectAtIndex:position];
    info1.text = [info1Array objectAtIndex:position];
    info2.text = [info2Array objectAtIndex:position];

    if(position == 0){
        info1.hidden = YES;
        info2.hidden = YES;
        stepLabel.hidden = YES;
        tutorialImage.hidden = YES;
        logo.hidden = NO;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    if(position == 0){
        inFrame = [logo frame];
        inFrame.origin.x += 320;
        [logo setFrame:inFrame];
    }
    inFrame = [tutorialImage frame];
    inFrame.origin.x += 320;
    [tutorialImage setFrame:inFrame];
    inFrame = [stepLabel frame];
    inFrame.origin.x += 320;
    [stepLabel setFrame:inFrame];
    inFrame = [info1 frame];
    inFrame.origin.x += 320;
    [info1 setFrame:inFrame];
    inFrame = [info2 frame];
    inFrame.origin.x += 320;
    [info2 setFrame:inFrame];
    [UIView commitAnimations];
    pageControl.currentPage = position;
}
//Edit by Venturepact iOS7 Design
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.rowHeight=50.0f;
    // Return the number of rows in the section.
    return [arrSignUpEntry count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [arrSignUpEntry objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    //[cell setStyleClass:@"table_view_cell_1"];
    
    if ([CellIdentifier isEqualToString:@"Name"]) {
        UILabel*lblName=(UILabel*)[cell.contentView.subviews objectAtIndex:1];
       // [lblName setStyleClass:@"table_view_cell_textlabel_1"];
        name = (UITextField*)[cell.contentView.subviews objectAtIndex:0];
               name.tag = indexPath.row;
        name.textAlignment=NSTextAlignmentLeft;
        name.delegate=self;
      //  [name setStyleClass:@"table_view_cell_detailtext_1"];
        
    }
   
    else if ([CellIdentifier isEqualToString:@"Password"]) {
        UILabel*lblpwd=(UILabel*)[cell.contentView.subviews objectAtIndex:1];
      //  [lblpwd setStyleClass:@"table_view_cell_textlabel_1"];
        
        password = (UITextField*)[cell.contentView.subviews objectAtIndex:0];
         password.textAlignment=NSTextAlignmentLeft;
       // [password setStyleClass:@"table_view_cell_detailtext_1"];

    password.delegate=self;
       
        
    }
    else if ([CellIdentifier isEqualToString:@"Email"]) {
        UILabel*lblemail=(UILabel*)[cell.contentView.subviews objectAtIndex:1];
       // [lblemail setStyleClass:@"table_view_cell_textlabel_1"];
        email = (UITextField*)[cell.contentView.subviews objectAtIndex:0];
       email.tag = indexPath.row;
        email.delegate=self;
         email.textAlignment=NSTextAlignmentLeft;
       // [email setStyleClass:@"table_view_cell_detailtext_1"];
    
    }
    
       return cell;
}

@end
