//
//  NoochHome.m
//  Nooch
//
//  Created by Preston Hults on 9/14/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "NoochHome.h"
#import "JSON.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CommonCrypto/CommonHMAC.h>
#import "transfer.h"
#import "Reachability.h"
#import "history.h"

@interface NoochHome ()

@end

//static NSString *pUnreservedCharsString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~";
static	const   char	*Base64Chars	=	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/0=";
static	unsigned char	Base64Inverted[128];
BOOL recentUpdating;
bool emailEntry;
NSMutableArray *tutsArray;
int tutPos;

@implementation NoochHome
@synthesize mailComposer,userPic,firstNameLabel,lastNameLabel,balanceLabel,sendMoneyView,friendTable,blankLabel,
spinner,display,emailSend,startButton,goSelectRecip,
sorter,sections,sectionsSearch,buttonView,connectFbButton,bannerView;

float progressTotal,progressPosition;
NSString *searchString;

#pragma mark - inits
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    //just a sanity check
    NSLog(@"memberId from userDefaults %@ and from userObject %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"],[[me usr] objectForKey:@"MemberId"]);
    
    
    if (![[me usr] objectForKey:@"MemberId"]) {
        [[me usr] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
    }
    progressImage.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:@"updateTable" object:nil];
    [splashView removeFromSuperview];
    if(suspended){
        [userBar setHighlighted:YES]; //userbar is red when someone is suspended
    }else{
        [userBar setHighlighted:NO];
    }
    
    if(transferFinished){     //boolean for when coming back to NoochHome after completing a transfer, so that a user isnt returned to the select recipient screen
        buttonView.hidden = NO;
        bannerView.hidden = NO;
        sendingMoney = NO;
        pendingRequestView.hidden = NO;
        CGRect inFrame = sendMoneyView.frame;
        inFrame.origin.x = 320;
        [sendMoneyView setFrame:inFrame];
        inFrame = buttonView.frame;
        inFrame.origin.x = 37;
        [buttonView setFrame:inFrame];
        inFrame = bannerView.frame;
        inFrame.origin.x = 0;
        [bannerView setFrame:inFrame];
        inFrame = [pendingRequestView frame];
        inFrame.origin.x = 0;
        [pendingRequestView setFrame:inFrame];
        transferFinished = NO;
    }

    if(sendingMoney){ //for when someone left the home screen on the Select Recipient 'screen'
        navBar.topItem.title = @"";
        progressImage.hidden = NO;
        [leftNavButton removeTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftNavButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
        CGRect frame = leftNavButton.frame;
        //frame.size.width = 40;
        [leftNavButton setFrame:frame];
    }else{
        navBar.topItem.title = @"Nooch";
        [leftNavButton removeTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftNavButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [leftNavButton setImage:[UIImage imageNamed:@"HamburgerButton.png"] forState:UIControlStateNormal];
        CGRect frame = leftNavButton.frame;
        [leftNavButton setFrame:frame];
    }
    
    [self refreshBalance];
    searching = NO;

    [me histMore:@"ALL" sPos:1 len:20];
    
    balanceLabel.textColor = firstNameLabel.textColor = lastNameLabel.textColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:nil];
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    curpage = @"noochHome";


    pendingRequestView.hidden = YES;
    userPic.clipsToBounds = YES;
    userPic.layer.cornerRadius = 4;
    firstNameLabel.text=[[me usr] objectForKey:@"firstName"];
    lastNameLabel.text=[[me usr] objectForKey:@"lastName"];
    if(![[[me usr] objectForKey:@"Balance"] isKindOfClass:[NSNull class]] && [[me usr] objectForKey:@"Balance"] != NULL)
        balanceLabel.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    else
        balanceLabel.text = @"";
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
    }else{
        userPic.image = [UIImage imageNamed:@"profile_picture.png"];
    }
    if ([[[me usr] objectForKey:@"UserName"] length] == 0 && [[[me usr] objectForKey:@"email"] length] > 0) {
        [[me usr] setObject:[[me usr] objectForKey:@"email"] forKey:@"UserName"];
    }
    updateHistory = NO;
    self.trackedViewName = @"Home";

    transferFinished = NO;
    sectionsSearch = [NSMutableDictionary new];
    sections = [NSMutableDictionary new];
    addrBookUsername = [NSMutableArray new];
    fbFriends = [NSMutableArray new];
    fbNoochFriends = [NSMutableArray new];
    addrBook = [NSMutableArray new];
    addrBookNooch = [NSMutableArray new];

    profileGO = NO;
    Updating = NO;

    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadingView) forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[core hexColor:@"3FABE1"]];
    [self.friendTable addSubview:refreshControl];

    firstNameLabel.font = [core nFont:@"Medium" size:16];
    lastNameLabel.font = [core nFont:@"Bold" size:17];
    balanceLabel.font = [core nFont:@"Medium" size:20];
    newRequests.font = [core nFont:@"Medium" size:16];
    emailSend = NO;
    spinner.hidesWhenStopped = YES;
    blankLabel.hidden = YES;
    goSelectRecip = YES;
    startButton.userInteractionEnabled = YES;
    sorter = [[NSMutableArray alloc] init];
    display = 0;

    [navCtrl performSelector:@selector(reenable)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:nil];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"setPrompt"]) {
        [self showTutorial];
    }
    //[self getFB];
}
-(void)viewWillDisappear:(BOOL)animated{
    Updating = NO;
    searchField.text = @"";
    searching = NO;
    [searchField resignFirstResponder];
}
-(void)viewDidAppear:(BOOL)animated{
    //[self hideMenu];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    sendingMoney = NO;
    tutsArray = [NSMutableArray new];
    tutPos = 0;
    [buttonView setFrame:CGRectMake(35,140,255,255)];
    if([[UIScreen mainScreen] bounds].size.height > 480){
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks1-568h@2x.png"]];
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks2-568h@2x.png"]];
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks3-568h@2x.png"]];
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks4-568h@2x.png"]];
        //[buttonView setFrame:CGRectMake(buttonView.frame.origin.x+7,buttonView.frame.origin.y+70,buttonView.frame.size.width,buttonView.frame.size.height)];
    }else{
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks1.png"]];
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks2.png"]];
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks3.png"]];
        [tutsArray addObject:[UIImage imageNamed:@"CoachMarks4.png"]];
        CGRect frame = buttonView.frame;
        frame.origin.y = 180;
        //[buttonView setFrame:frame];
        //[buttonView setFrame:CGRectMake(buttonView.frame.origin.x+7,buttonView.frame.origin.y+18,buttonView.frame.size.width,buttonView.frame.size.height)];
    }
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"] != NULL){
        serve *memDevice = [serve new];
        memDevice.Delegate = self;
        memDevice.tagName = @"SetDeviceToken";
        [memDevice memberDevice:[[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"]];
    }
    nHome = self;
    //CAUSES SHIT
    causesArr = [NSMutableArray new];
    NSMutableDictionary *cause = [NSMutableDictionary new];
    [cause setObject:@"4K for" forKey:@"firstName" ];
    [cause setObject:@"Cancer" forKey:@"lastName"];
    [cause setObject:[UIImage imageNamed:@"4KforCancer.png"] forKey:@"image"];
    [cause setObject:@"754d9dc0-870d-4715-bbf4-fb90717da6db" forKey:@"MemberId"];
    [causesArr addObject:[cause mutableCopy]];
    [cause removeAllObjects];

    [cause setObject:@"Boston One" forKey:@"firstName" ];
    [cause setObject:@"Fund" forKey:@"lastName"];
    [cause setObject:[UIImage imageNamed:@"BostonFund.png"] forKey:@"image"];
    [cause setObject:@"3909daad-5626-404c-a903-b30441932d5e" forKey:@"MemberId"];
    [causesArr addObject:[cause mutableCopy]];
    [cause removeAllObjects];

    [cause setObject:@"Boy Scouts" forKey:@"firstName" ];
    [cause setObject:@"of America" forKey:@"lastName"];
    [cause setObject:[UIImage imageNamed:@"BoyScouts_Icon.png"] forKey:@"image"];
    [cause setObject:@"26A44193-E0BC-43EC-A763-256B17EA12CA" forKey:@"MemberId"];
    [causesArr addObject:[cause mutableCopy]];
    [cause removeAllObjects];

    [cause setObject:@"Grassroot" forKey:@"firstName" ];
    [cause setObject:@"Soccer" forKey:@"lastName"];
    [cause setObject:[UIImage imageNamed:@"GrassrootSoccer.png"] forKey:@"image"];
    [cause setObject:@"5d651d3d-122d-4370-9fc3-000fd794bb74" forKey:@"MemberId"];
    [causesArr addObject:[cause mutableCopy]];
    [cause removeAllObjects];

    [cause setObject:@"Philadelphia Children's" forKey:@"firstName" ];
    [cause setObject:@"Foundation" forKey:@"lastName"];
    [cause setObject:[UIImage imageNamed:@"PCL_Icon.png"] forKey:@"image"];
    [cause setObject:@"0DA56BF0-ECCE-4A45-9494-529B17E30399" forKey:@"MemberId"];
    [causesArr addObject:[cause mutableCopy]];
    [cause removeAllObjects];

    [cause setObject:@"Ulman Cancer" forKey:@"firstName" ];
    [cause setObject:@"Fund" forKey:@"lastName"];
    [cause setObject:[UIImage imageNamed:@"UlmanCancerFund.png"] forKey:@"image"];
    [cause setObject:@"00fc2cd8-e650-438a-819d-80953383a716" forKey:@"MemberId"];
    [causesArr addObject:[cause mutableCopy]];
    [cause removeAllObjects];

    [cause setObject:@"Rebecca Davis" forKey:@"firstName" ];
    [cause setObject:@"Dance Co" forKey:@"lastName"];
    [cause setObject:[UIImage imageNamed:@"RDDC_Logo.png"] forKey:@"image"];
    [cause setObject:@"692635B9-65CB-48A4-A87A-39DC7121F85A" forKey:@"MemberId"];
    [causesArr addObject:[cause mutableCopy]];

    [nextTut addTarget:self action:@selector(nextScreen) forControlEvents:UIControlEventTouchUpInside];
    [prevTut addTarget:self action:@selector(prevScreen) forControlEvents:UIControlEventTouchUpInside];
    tutorialView.hidden = YES;
    tutorialView.alpha = 0.0f;

    navCtrl = self.navigationController;
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    sendMoneyView.hidden = YES;
    [rightMenuButton addTarget:self action:@selector(showFundsMenu) forControlEvents:UIControlEventTouchUpInside];
    causes = NO;
    searchString = [NSString new];
    newRequests.hidden = YES;
    emailEntry = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(flashButton) userInfo:nil repeats:YES];
    transp = 1.0f;
    fadeIn = NO;
    if ([core isAlive:[self autoLogin]]) {
        me = [core new];
        NSMutableDictionary *loadInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:[self autoLogin]];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"MemberId"] forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:[loadInfo valueForKey:@"UserName"] forKey:@"UserName"];
        [me birth];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
        [navCtrl performSelector:@selector(disable)];
        [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"tutorial"] animated:NO];
        return;
    }
    if (![[me usr] objectForKey:@"requiredImmediately"]) {
        reqImm = YES;
        [self presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"pin"] animated:NO];
    }else if([[[me usr] objectForKey:@"requiredImmediately"] boolValue]){
        reqImm = YES;
        [self presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"pin"] animated:NO];
    }
}

#pragma mark - side menus
-(void)showMenu{
    [self.slidingViewController anchorTopViewTo:ECRight];
}
-(void)hideMenu{
    [self.slidingViewController resetTopView];
}
-(void)showFundsMenu{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

#pragma mark - how nooch works
-(void)showTutorial{
    tutorialView.hidden = NO;
    prevTut.hidden = YES;
    tutPos = 0;
    tutorialImage.image = [tutsArray objectAtIndex:0];
    CGRect frame = tutorialView.frame;
    frame.origin.y = 0;
    [nextTut setBackgroundImage:[UIImage imageNamed:@"Next_button.png"] forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    [tutorialView setAlpha:1.0f];
    [UIView commitAnimations];
    [navCtrl.view removeGestureRecognizer:self.slidingViewController.panGesture];
}
-(void)tutDelay{
    if (tutPos == 3) {
        [nextTut setBackgroundImage:[UIImage imageNamed:@"GotItt_button.png"] forState:UIControlStateNormal];
    }else{
        [nextTut setBackgroundImage:[UIImage imageNamed:@"Next_button.png"] forState:UIControlStateNormal];
    }
    if (tutPos > 1) {
        [navCtrl.view addGestureRecognizer:self.slidingViewController.panGesture];
    }else{
        [navCtrl.view removeGestureRecognizer:self.slidingViewController.panGesture];
    }
    tutorialImage.image = [tutsArray objectAtIndex:tutPos];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    [tutorialView setAlpha:1.0f];
    [UIView commitAnimations];
}
-(void)nextScreen{
    prevTut.hidden = NO;
    if (tutPos==3) {
        tutPos = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [tutorialView setAlpha:0.0f];
        [UIView commitAnimations];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"setPrompt"]) {
            UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"One Last Step..." message:@"Before you can send money we must verify who you are. Please help us keep Nooch safe and complete your profile." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
            [set setTag:16];
            [set show];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"setPrompt"];
        }
    }else if(tutPos == 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [tutorialView setAlpha:0.1f];
        [UIView commitAnimations];
        tutPos++;
        
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(tutDelay) userInfo:nil repeats:NO];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [tutorialView setAlpha:0.1f];
        [UIView commitAnimations];
        tutPos++;
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(tutDelay) userInfo:nil repeats:NO];
    }
}
-(void)prevScreen{
    if (tutPos == 1) {
        prevTut.hidden = YES;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    [tutorialView setAlpha:0.1f];
    [UIView commitAnimations];
    tutPos--;
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(tutDelay) userInfo:nil repeats:NO];
}

#pragma mark - constants
-(void)flashButton{
    if (sendingMoney) {
        return;
    }
    if (startButton.isHighlighted) {
        return;
    }
    if (transp >= 1) {
        fadeIn = NO;
    }else if(transp <= 0){
        fadeIn = YES;
    }
    if (fadeIn) {
        transp += 0.02;
    }else{
        transp -= 0.02;
    }
    [sendMoneyOverlay setAlpha:transp];
}
- (IBAction)hideOverlay:(id)sender {
    [sendMoneyOverlay setHidden:YES];
}
- (IBAction)bringBackOverlay:(id)sender {
    [sendMoneyOverlay setHidden:NO];
}
-(void)refreshBalance{
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateBanner) userInfo:nil repeats:YES];
}
-(void)goBack{
    progressImage.hidden = YES;
    navBar.topItem.title = @"Nooch";
    buttonView.hidden = NO;
    bannerView.hidden = NO;
    pendingRequestView.hidden = NO;
    [leftNavButton removeTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [leftNavButton setImage:[UIImage imageNamed:@"HamburgerButton.png"] forState:UIControlStateNormal];
    CGRect frame = leftNavButton.frame;
    //frame.size.width = 30;
    //frame.origin.x = 20;
    [leftNavButton setFrame:frame];
    sendingMoney = NO;
    CGRect inFrame = [sendMoneyView frame];
    inFrame.origin.x = 320;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [sendMoneyView setFrame:inFrame];
    inFrame = [buttonView frame];
    inFrame.origin.x = 37;
    [buttonView setFrame:inFrame];
    inFrame = [bannerView frame];
    inFrame.origin.x = 0;
    [bannerView setFrame:inFrame];
    inFrame = [pendingRequestView frame];
    inFrame.origin.x = 0;
    [pendingRequestView setFrame:inFrame];
    [UIView commitAnimations];
    Updating = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideSelect) userInfo:nil repeats:NO];
    [searchField resignFirstResponder];


    int numReq = 0;
    if (!histSafe) {
        return;
    }
    @try {
        for (NSDictionary *dict in [me histFilter:filterPick]) {
            if (![dict objectForKey:@"TransactionType"]) {
                break;
            }
            if ([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"]) {
                //NSLog(@"dict %@",[dict objectForKey:@"RecepientId"]);
                if (![dict objectForKey:@"Status"] || ![dict objectForKey:@"RecepientId"]) {
                    break;
                }
                if ([[dict objectForKey:@"Status"] isKindOfClass:[NSNull class]] || [[dict objectForKey:@"RecepientId"] isKindOfClass:[NSNull class]]){
                    break;
                }
                if ([[dict objectForKey:@"Status"] isEqualToString:@"Pending"] && ![[dict objectForKey:@"RecepientId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) {
                    numReq++;
                }
            }
        }
    }
    @catch (NSException *exception) {
        return;
    }
    @finally {
    }

    if (numReq > 0) {
        [pendingRequestView setHidden:NO];
        if (numReq == 1) {
            //newRequests.text = [NSString stringWithFormat:@"%d New Request",numReq];
            [requestBadge setHighlighted:NO];
        }else{
            [requestBadge setHighlighted:YES];
            //newRequests.text = [NSString stringWithFormat:@"%d",numReq];
        }
    }else{
        [pendingRequestView setHidden:YES];
    }
}
-(void)hideHome{
    buttonView.hidden = YES;
    bannerView.hidden = YES;
    pendingRequestView.hidden = YES;
}
-(void)hideSelect{
    sendMoneyView.hidden = YES;
}
-(void)updateBanner{
    firstNameLabel.text=[[me usr] objectForKey:@"firstName"];
    lastNameLabel.text=[[me usr] objectForKey:@"lastName"];
    if([[me usr] objectForKey:@"Balance"] != NULL)
        balanceLabel.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    else
        balanceLabel.text = @"";
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
    }else{
        userPic.image = [UIImage imageNamed:@"profile_picture.png"];
        [me fetchPic];
    }
    
    if ([[[me usr] objectForKey:@"Status"] isEqualToString:@"Suspended"]) {
        suspended = YES;
        [userBar setHighlighted:YES];
    }else{
        suspended = NO;
        [userBar setHighlighted:NO];
    }
}
-(IBAction)goSettings:(id)sender {
    profileGO = YES;
    [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES];
    
}
-(IBAction)goFunds:(id)sender {
    [self showFundsMenu];
    [self balanceDeHighlight:self];
}
- (IBAction)highLightName:(id)sender {
    firstNameLabel.textColor = lastNameLabel.textColor = [core hexColor:@"6c92a6"];
}
- (IBAction)balanceHighlight:(id)sender {
    balanceLabel.textColor = [core hexColor:@"6c92a6"];
}
- (IBAction)nameDeHighlight:(id)sender {
    firstNameLabel.textColor = lastNameLabel.textColor = [UIColor whiteColor];
}
- (IBAction)balanceDeHighlight:(id)sender {
    balanceLabel.textColor = [UIColor whiteColor];
}
-(void)inviteProcess{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Coming Soon" message:@"You can't invite people just yet. In the meantime, use word of mouth! Add us on Facebook, Twitter, Google+, Instagram, and tell your friends!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}


- (IBAction)lookAtRequests:(id)sender {
    getRequests = YES;
    curpage = @"history";
    filterPick = @"REQUEST";
    if ([tId length] > 0)
        viewDetails = YES;
    [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"history"] animated:YES];
}
- (IBAction)people:(id)sender {
    causes = NO;
    peepsOrCauses.highlighted = NO;
    [self.friendTable reloadData];
}
- (IBAction)causes:(id)sender {
    causes = YES;
    peepsOrCauses.highlighted = YES;
    [self.friendTable reloadData];
}
-(void)donate{
    [self selectRecip:self];
}

#pragma mark - start send process
- (IBAction)selectRecip:(id)sender {
    NSLog(@"started send money process");
    if(suspended || [[[me usr] objectForKey:@"Status"] isEqualToString:@"Suspended"]){
        UIAlertView *susAV = [[UIAlertView alloc] initWithTitle:@"Account Suspended" message:@"For your protection your account has been temporarily suspended. Please contact us for more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
        [susAV setTag:1];
        [susAV show];
        suspended = YES;
    }else{
        startButton.userInteractionEnabled = NO;
        [self startSelectRecip];
        return;
        if( [[me usr] objectForKey:@"validated"] && [[[me usr] objectForKey:@"validated"] boolValue]){
            [self startSelectRecip];
        }else{
            UIAlertView *set = [[UIAlertView alloc] initWithTitle:@"One Last Step..." message:@"Before you can send money we must verify who you are. Please help us keep Nooch safe and complete your profile." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Go Now", nil];
            [set setTag:16];
            [set show];
        }
    }
}
-(void)startSelectRecip{
    [connectFbButton setHidden:YES];
    if(goSelectRecip){
        sendMoneyView.hidden = NO;
        [self clearSearch:self];
        navBar.topItem.title = @"";
        progressImage.hidden = NO;
        sendMoneyView.hidden = NO;
        clearSearchButton.hidden = YES;
        peepsOrCauses.highlighted = NO;
        [sendMoneyOverlay setHidden:NO];
        //set back button
        [leftNavButton removeTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [leftNavButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
        
        CGRect frame = leftNavButton.frame;
        //frame.size.width = 40;
        [leftNavButton setFrame:frame];
        sendingMoney = YES;
        CGRect inFrame = [sendMoneyView frame];
        inFrame.origin.x = 320;
        [sendMoneyView setFrame:inFrame];
        inFrame.origin.x = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [sendMoneyView setFrame:inFrame];
        inFrame = [buttonView frame];
        inFrame.origin.x = -320;
        [buttonView setFrame:inFrame];
        inFrame = [bannerView frame];
        inFrame.origin.x = -320;
        [bannerView setFrame:inFrame];
        inFrame = [pendingRequestView frame];
        inFrame.origin.x = -320;
        [pendingRequestView setFrame:inFrame];
        [UIView commitAnimations];
        recentUpdating = YES;
        startButton.userInteractionEnabled = YES;
        [self reallow];
        blankLabel.font = [core nFont:@"Medium" size:14];
        if (causes) {
            [self causes:self];
        }
        else if([[[me assos] objectForKey:@"members"] count] != 0){
            [self getRecentDetails];
            [self.friendTable reloadData];
        }else{
            [self.view addSubview:[me waitStat:@"Loading your contacts..."]];
            [self syncAssos];
        }
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideHome) userInfo:nil repeats:NO];
    }
}
-(void)syncAssos{
    [self getRecentDetails];
    [self getFB];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        [self getAddressBookContacts];
    }
    [refreshControl endRefreshing];
}
-(void)getFB{
    if(me.fbAllowed){
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"198279616971457",
                                  ACFacebookPermissionsKey: @[@"friends_about_me"],
                                  ACFacebookAudienceKey: ACFacebookAudienceFriends
                                  };
        ACAccountType *facebookAccountType = [me.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [me.accountStore requestAccessToAccountsWithType:facebookAccountType
                                              options:options completion:^(BOOL granted, NSError *e)
         {
             
         }];
        NSString *acessToken = [NSString stringWithFormat:@"%@",me.facebookAccount.credential.oauthToken];
        NSDictionary *parameters = @{@"access_token": acessToken,@"fields":@"id,installed,username,first_name,last_name"};
        NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
        SLRequest *feedRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeFacebook
                                  requestMethod:SLRequestMethodGET
                                  URL:feedURL
                                  parameters:parameters];
        feedRequest.account = me.facebookAccount;
        [feedRequest performRequestWithHandler:^(NSData *respData,
                                                 NSHTTPURLResponse *urlResponse, NSError *error)
         {
             NSString *resp = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
             NSDictionary *d = [resp JSONValue];
             NSMutableArray *friends = [d objectForKey:@"data"];
             for(NSMutableDictionary *dict in friends){
                 if (![dict objectForKey:@"id"]) continue;
                 [dict setObject:[dict objectForKey:@"id"] forKey:@"facebookId"];
                 if([dict objectForKey:@"installed"]) [dict setObject:@"wut2do" forKey:@"MemberId"];
             }
             friends = [me cleanForSave:friends];
             [self facebookProcess:friends];
         }];
    }else{
        NSLog(@"fb not allowed");
    }
}

#pragma mark - facebook handling
- (NSString *)ToBase64:(NSData *)pBase64Data;{
	unsigned char *pInData = (unsigned char *)[pBase64Data bytes];
	int InLength = [pBase64Data length];
	int OutLength=0;
	unsigned char *pOutData = malloc(InLength*4);


	int	I=0;
	//	for(I=0;I<	((Length>>2)<<2);I	+=	3)
	for(I=0;I<	InLength-2;I	+=	3)
	{
		uint32_t	I32	=	(pInData[I]	<<	16)	+(pInData[I+1]	<<	8)	+	pInData[I+2];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	6)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	)	&	0x3f];
	}
	if(InLength-I	==	1)
	{
		uint32_t	I32	=	(pInData[I]	<<	16);
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	'=';
		pOutData[OutLength++]	=	'=';
	}	else		if(InLength-I	==	2)
	{
		uint32_t	I32	=	(pInData[I]	<<	16)	+(pInData[I+1]	<<	8);
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	6)	&	0x3f];
		pOutData[OutLength++]	=	'=';
	}
	pOutData[OutLength]	=	0;
	NSString *pRetVal = [[NSString alloc] initWithBytes:pOutData length:OutLength encoding:NSUTF8StringEncoding];
	free(pOutData);
	return pRetVal;
}
- (NSData *)FromBase64:(NSString *)pBase64String{
	unsigned char	*InData = (unsigned char	*)[pBase64String UTF8String];
	int InLength	=	[pBase64String length];
	unsigned char	*OutData	=	malloc(InLength);
	int OutDataLen=0;
	if(Base64Inverted['B']	!=	1)
	{
		for(int	I=0;I	< 64;I++)
		{
			Base64Inverted[Base64Chars[I]]	=	I;
		}
	}
	for(int	I=0;I	<	(int)InLength;I+=4)
	{
		if(InData[I+3]	!=	'=')
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12)	+
			(Base64Inverted[InData[I+2]]	<<	6)	+
			Base64Inverted[InData[I+3]];
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
			OutData[OutDataLen++]	=	(I32	>>	8)	&	0xff;
			OutData[OutDataLen++]	=	(I32	)	&	0xff;
		}	else	if(InData[I+2]	!=	'=')
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12)	+
			(Base64Inverted[InData[I+2]]	<<	6);
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
			OutData[OutDataLen++]	=	(I32	>>	8)	&	0xff;
		}	else
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12);
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
		}
	}
	NSData *pRetVal = [NSData dataWithBytes:OutData length:OutDataLen];
	free(OutData);
	return pRetVal;
}
- (NSString *)signClearText:(NSString *)base withSecret:(NSData *)secret{
    NSData *data = [base dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_SHA1_DIGEST_LENGTH+1];
    CCHmac(kCCHmacAlgSHA1,secret.bytes,secret.length,data.bytes,data.length,result);
    NSData *hash = [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    return [self ToBase64:hash];
}
-(void)facebookProcess:(id)temp{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSMutableArray *temp2 = [[NSMutableArray alloc] init];
    NSMutableArray *temp3 = [[NSMutableArray alloc] init];
    NSMutableArray *fbFriendsTemp = [[NSMutableArray alloc] init];
    NSMutableArray *fbNoochFriendsTemp = [[NSMutableArray alloc] init];
    for(int i= 0; i<[temp count];i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if([[temp objectAtIndex:i] objectForKey:@"first_name"] != NULL)[dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"first_name"]] forKey:@"firstName"];
        if([[temp objectAtIndex:i] objectForKey:@"last_name"] != NULL)[dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"last_name"]] forKey:@"lastName"];
        [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"name"]] forKey:@"name"];
        if([[temp objectAtIndex:i] objectForKey:@"username"] != NULL) [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"username"]] forKey:@"username"];
        [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"facebookId"]] forKey:@"facebookId"];
        NSString *photoURL;
        if([dict objectForKey:@"username"] != NULL) photoURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [dict objectForKey:@"username"]];
        else if([dict objectForKey:@"facebookId"] != NULL) photoURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [dict objectForKey:@"facebookId"]];
        [dict setObject:photoURL forKey:@"Photo"];
        if([[temp objectAtIndex:i] objectForKey:@"MemberId"] != NULL){
            [dict setObject:[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] objectForKey:@"MemberId"]] forKey:@"MemberId"];
            [temp3 addObject:dict];
        }else
            [temp2 addObject:dict];
    }
    fbFriendsTemp = [[temp2 sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
    fbNoochFriendsTemp = [[temp3 sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
    [me addAssos:fbFriendsTemp];
    [me addAssos:fbNoochFriendsTemp];
}

#pragma mark - recent handling
-(void)getRecentDetails{
    recentUpdating = YES;
    serve *recentFetch =[serve new];
    recentFetch.Delegate = self;
    recentFetch.tagName = @"GetrecentCache";
    [recentFetch getRecents];
}
-(void)recentProcess:(id)loginResult{
    NSMutableArray *loginResultForRecentUpdate = loginResult;
    NSMutableArray *workArray = [NSMutableArray new];
    for(NSDictionary *edit in loginResultForRecentUpdate)
    {
        NSMutableDictionary *addDict = [NSMutableDictionary dictionary];
        [addDict setObject:[NSString stringWithFormat:@"%@",[edit objectForKey:@"FirstName"] ] forKey:@"firstName"];
        [addDict setObject:[NSString stringWithFormat:@"%@",[edit objectForKey:@"LastName"] ] forKey:@"lastName"];
        [addDict setObject:[NSString stringWithFormat:@"%@",[edit objectForKey:@"MemberId"] ] forKey:@"MemberId"];
        [addDict setObject:[NSString stringWithFormat:@"%@",[edit objectForKey:@"NoochId"] ] forKey:@"NoochId"];
        [addDict setObject:[NSString stringWithFormat:@"%@",[edit objectForKey:@"UserName"] ] forKey:@"UserName"];
        if(![[edit objectForKey:@"Photo"] isKindOfClass:[NSNull class]]){
            NSString *imageURL = (NSString *)[edit objectForKey:@"Photo"];
            imageURL = [imageURL stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            [addDict setObject:imageURL forKey:@"Photo"];
        }
        [addDict setObject:@"YES" forKey:@"recent"];

        if (![[addDict objectForKey:@"MemberId"] isEqualToString:@"754d9dc0-870d-4715-bbf4-fb90717da6db"] && ![[addDict objectForKey:@"MemberId"] isEqualToString:@"3909daad-5626-404c-a903-b30441932d5e"]
            && ![[addDict objectForKey:@"MemberId"] isEqualToString:@"5d651d3d-122d-4370-9fc3-000fd794bb74"] && ![[addDict objectForKey:@"MemberId"] isEqualToString:@"00fc2cd8-e650-438a-819d-80953383a716"]) {
            [workArray addObject:addDict];
        }
    }
    [me addAssos:workArray];
    [self performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
}

#pragma mark - addressbook handling
-(void)getAddressBookContacts{
    addrBook = [NSMutableArray new];
    addrBookNooch = [NSMutableArray new];
    addrBookUsername = [NSMutableArray new];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for(int i=0; i<nPeople; i++){
        NSMutableDictionary *curContact=[[NSMutableDictionary alloc] init];
        ABRecordRef person=CFArrayGetValueAtIndex(people, i);
        NSString *contacName = [[NSMutableString alloc] init];
        contacName =(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *firstName = [[NSString alloc] init];
        NSString *lastName = [[NSString alloc] init];
        firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if((__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty))
        {
            [contacName stringByAppendingString:[NSString stringWithFormat:@" %@", (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)]];
            lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        }
        NSData *contactImage;
        if(ABPersonHasImageData(person) > 0 )
        {
            contactImage = (__bridge NSData *)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail));
        }
        else
        {
            contactImage = UIImageJPEGRepresentation([UIImage imageNamed:@"profile_picture.png"], 1);
        }
        ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);
        if(YES){
            NSString *emailId = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailInfo, 0);
            if (YES){
                if (YES){//[emailTest evaluateWithObject:emailId] == YES) {
                    if(emailId != NULL) [curContact setObject:emailId forKey:@"emailAddy"];
                    if(contacName != NULL)  [curContact setObject:contacName forKey:@"Name"];
                    if(firstName != NULL) [curContact setObject:firstName forKey:@"firstName"];
                    if(lastName != NULL)  [curContact setObject:lastName forKey:@"lastName"];
                    [curContact setObject:contactImage forKey:@"image"];
                    NSString *phone,*phone2,*phone3;
                    if(ABMultiValueGetCount(phoneNumber)> 0)
                        phone =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 0));

                    if(ABMultiValueGetCount(phoneNumber)> 1){
                        phone2=  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber, 1));
                        phone2 = [phone2 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone2 length])];
                        [curContact setObject:phone2 forKey:@"phoneNo2"];
                    }

                    if(ABMultiValueGetCount(phoneNumber)> 2){
                        phone3 =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,2));
                        phone3 = [phone3 stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone3 length])];
                        [curContact setObject:phone3 forKey:@"phoneNo3"];
                    }
                    if(phone == NULL && (emailId == NULL || [emailId rangeOfString:@"facebook"].location != NSNotFound)){
                        [addrBook addObject:curContact];
                    }else if( contacName == NULL){
                    }else{
                        NSString * strippedNumber = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
                        if([strippedNumber length] == 11){
                            strippedNumber = [strippedNumber substringFromIndex:1];
                        }
                        if(strippedNumber != NULL)
                            [curContact setObject:strippedNumber forKey:@"phoneNo"];
                        [addrBookUsername addObject:curContact];
                    }
                }
            }
        }
    }
    CFRelease(people);
    CFRelease(addressBook);
    //For Ascending Order
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    addrBookUsername = [[NSMutableArray alloc] initWithArray:[addrBookUsername sortedArrayUsingDescriptors:sortDescriptors]];
    NSLog(@"finished grabbing addressbook, count %d",[addrBookUsername count]);
    [self performSelectorOnMainThread:@selector(addressBookProcess) withObject:nil waitUntilDone:NO];
}
-(void)addressBookCancel{
    if([addrBookUsername count] == 0)
        return;
    if(([addrBook count] == 0 && [addrBookNooch count] == 0) || [[[addrBook lastObject] valueForKey:@"email" ] isEqualToString:[[addrBookUsername objectAtIndex:0] objectForKey:@"email" ]] || [[[addrBookNooch lastObject] valueForKey:@"email" ] isEqualToString:[[addrBookUsername objectAtIndex:0] objectForKey:@"email" ]] ){
        NSLog(@"cancelled adress book loading");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh" message:@"Processing your address book is proving difficult, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [self endRefreshing];
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(addressBookCancel) userInfo:nil repeats:NO];
}
-(void)addressBookProcess{
    serve *addrCheck = [serve new];
    addrCheck.Delegate = self;
    addrCheck.tagName = @"AddressCheck";
    NSMutableArray *addrIn = [NSMutableArray new];
    for (NSDictionary *dict in addrBookUsername) {
        NSMutableDictionary *contact = [NSMutableDictionary new];
        if ([dict objectForKey:@"emailAddy"]) {
            [contact setObject:[dict objectForKey:@"emailAddy"] forKey:@"emailAddy"];
        }else{
            [contact setObject:@"" forKey:@"emailAddy"];
        }
        if ([dict objectForKey:@"phoneNo"]) {
            [contact setObject:[dict objectForKey:@"phoneNo"] forKey:@"phoneNo"];
        }else{
            [contact setObject:@"" forKey:@"phoneNo"];
        }
        [addrIn addObject:contact];
    }
    [addrCheck getMemberIds:addrIn];
}

#pragma mark - email handling
-(void)getMemberIdByUsingUserName{
    [searchField resignFirstResponder];
    if ([searchField.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Denied" message:@"You are attempting a transfer paradox, the results of which could cause a chain reaction that would unravel the very fabric of the space-time continuum and destroy the entire universe!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av setTag:4];
        [av show];
    }
    else
    {
        [self.view addSubview:[me waitStat:@"Checking email address."]];
        serve *emailCheck = [serve new];
        emailCheck.Delegate = self;
        emailCheck.tagName = @"emailCheck";
        [emailCheck getMemIdFromuUsername:searchField.text];
    }
}

#pragma mark - table global updating and resources
-(void)loadingView{
    [self.view addSubview:[me waitStat:@"Loading your contacts..."]];
    [self syncAssos];
}
-(void)updateLists{
    NSLog(@"updateLists");
    //[self.view addSubview:[me waitStat:@"Loading your contacts..."]];
    Updating = NO;
    friendTable.userInteractionEnabled = NO;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    __block BOOL accessGranted = NO;
    if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
            accessGranted = granted;
        });
    }
    while(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined);
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Why Don't You Like Us" message:@"You've previously disallowed us from integrating with your address book, please change your privacy settings for Nooch in Settings -> Privacy ->  Contacts if you would like to use this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self endRefreshing];
        return;
    }
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if(networkStatus == NotReachable){
        [self endRefreshing];
        return;
    }
    [self syncAssos];
}
-(void)endRefreshing{
    [refreshControl endRefreshing];
    recentUpdating = NO;
    [self.friendTable reloadData];
    friendTable.hidden = NO;
    blankLabel.hidden = YES;
    progressPosition = 0;
    NSLog(@"ending refreshing");
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(reallow) userInfo:nil repeats:NO];
}
-(void)reallow{
    friendTable.userInteractionEnabled = YES;
}
-(void)updateTable:(NSNotification *)notification{
    [self.friendTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    int numReq = 0;
    if (!histSafe) {
        return;
    }
    @try {
        bool first =YES;
        for (NSDictionary *dict in [me hist]) {
            if ([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"]) {
                if ([[dict objectForKey:@"Status"] isEqualToString:@"Pending"] && ![[dict objectForKey:@"RecepientId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) {
                    if (first)
                        tId = [dict objectForKey:@"TransactionId"];
                    else
                        tId = @"";
                    numReq++;
                    first = NO;
                }
            }
        }
    }
    @catch (NSException *exception) {
        return;
    }
    @finally {
    }

    if (numReq > 0) {
        [pendingRequestView setHidden:NO];
        if (numReq == 1) {
            //newRequests.text = [NSString stringWithFormat:@"%d New Request",numReq];
            [requestBadge setHighlighted:NO];
        }else{
            [requestBadge setHighlighted:YES];
            //newRequests.text = [NSString stringWithFormat:@"%d",numReq];
        }
    }else{
        [pendingRequestView setHidden:YES];
    }
    //NSLog(@"update table/pending requests");
    [me endWaitStat];
}

#pragma mark - table view delegation
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    title = @"Recent";
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (causes) {
        return [causesArr count];
    }
    if(emailEntry){
        return 1;
    }else if(searching){
        if([[me assosSearch:searchString] count] != 0)
            return [[me assosSearch:searchString] count];
        else
            return 1;
    }else{
        //NSLog(@"members %@",[[me assos] objectForKey:@"members"]);
        return [[[me assos] objectForKey:@"members"] count];
        if ([[[me assos] objectForKey:@"members"] count] < 20) {
            for (NSDictionary *dict in [[me assos] objectForKey:@"members"]) {
                if ([[dict objectForKey:@"MemberId"] isEqualToString:@"e9821324-08ac-43f6-ad9d-5b6aabe8e8c3"]) {
                    return [[[me assos] objectForKey:@"members"] count];
                }
            }
            /*if (![[me usr] objectForKey:@"fbUID"]) {
                return [[[me assos] objectForKey:@"members"] count] + 2;
            }*/
            return [[[me assos] objectForKey:@"members"] count] + 1;
        }else{
            /*if (![[me usr] objectForKey:@"fbUID"]) {
                return [[[me assos] objectForKey:@"members"] count] + 1;
            }*/
            return [[[me assos] objectForKey:@"members"] count];
        }
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
    cell.userInteractionEnabled = YES;
    cell.indentationLevel = 1;
    cell.indentationWidth = 60;
    cell.textLabel.font = [core nFont:@"Bold" size:18.0];
    cell.textLabel.textColor = [core hexColor:@"172126"];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10,40,40)];
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = 6;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (causes) {
        dict = [causesArr objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
        iv.image = [dict objectForKey:@"image"];
        [cell.contentView addSubview:iv];
        return cell;
    }
    iv.layer.borderColor = [UIColor blackColor].CGColor;
    iv.layer.borderWidth = 1.3f;
    if(emailEntry){
        cell.indentationWidth = 10;
        cell.textLabel.text = [NSString stringWithFormat:@"Send to %@",searchField.text];
        return cell;
    }
    else if (searching) {
        @try {
            if([[me assosSearch:searchString] count] == 0){
                cell.userInteractionEnabled = NO;
                cell.textLabel.text = @"No results found :(";
                return cell;
            }
            dict = [[me assosSearch:searchString] objectAtIndex:indexPath.row];
            if ([dict objectForKey:@"MemberId"]) {
                UIImageView *noo = [[UIImageView alloc] initWithFrame:CGRectMake(280, 20,21,21)];
                noo.image = [UIImage imageNamed:@"noochn.png"];
                [cell.contentView addSubview:noo];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"error searching");
        }
        @finally {
            
        }
        
    }else{
        if ([[[me assos] objectForKey:@"members"] count] < 20 && indexPath.row == [[[me assos] objectForKey:@"members"] count] +1){
            [dict setObject:@"e9821324-08ac-43f6-ad9d-5b6aabe8e8c3" forKey:@"MemberId"];
            [dict setObject:@"Team" forKey:@"firstName"];
            [dict setObject:@"Nooch" forKey:@"lastName"];
            [dict setObject:UIImagePNGRepresentation([UIImage imageNamed:@"noochLogo.png"]) forKey:@"image"];
        }else{
            @try {
                if ([[[me assos] objectForKey:@"people"] objectForKey:[[[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row] objectForKey:@"MemberId"]]) {
                    dict = [[[me assos] objectForKey:@"people"] objectForKey:[[[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row] objectForKey:@"MemberId"]];
                }else{
                    dict = [[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row];
                }
                
                
            }
            @catch (NSException *exception) {
                NSLog(@"error grabbing person %@",exception.description);
                dict = [[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row];
            }
            @finally {
                
            }
        }
    }
    if([dict objectForKey:@"image"] != NULL){
        iv.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
    }else{
        iv.image = [UIImage imageNamed:@"profile_picture.png"];
    }

    [cell.contentView addSubview:iv];
    if([dict objectForKey:@"firstName"] != NULL && [dict objectForKey:@"lastName"] != NULL)
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
    else if([dict objectForKey:@"name"] != NULL)
        cell.textLabel.text = [dict objectForKey:@"name"];

    if ([dict objectForKey:@"facebookId"]) {
        UIImageView *fb = [[UIImageView alloc] initWithFrame:CGRectMake(40, 40, 15, 15)];
        [fb setImage:[UIImage imageNamed:@"fb_image.png"]];
        [cell.contentView addSubview:fb];
    }
    if ([dict objectForKey:@"number"] || [dict objectForKey:@"email"] || [dict objectForKey:@"emailAddy"]) {
        UIImageView *ab = [[UIImageView alloc] initWithFrame:CGRectMake(5, 40, 15, 15)];
        //[ab setImage:[UIImage imageNamed:@"Address_Book_Image.png"]];
        [ab setImage:[UIImage imageNamed:@"AddressBookIconMini.png"]];
        [cell.contentView addSubview:ab];
    }
    if (indexPath.row == [[[me assos] objectForKey:@"members"] count]-1) {
        [me endWaitStat];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [friendTable deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (causes) {
        dict = [causesArr objectAtIndex:indexPath.row];
    }
    else if (emailEntry){
        [self getMemberIdByUsingUserName];
        return;
    }
    else if (searching) {
        @try {
            dict = [[me assosSearch:searchString] objectAtIndex:indexPath.row];
        }
        @catch (NSException *exception) {
            NSLog(@"error searching");
        }
        @finally {

        }
    }else{
        if ([[[me assos] objectForKey:@"members"] count] < 20 && indexPath.row == [[[me assos] objectForKey:@"members"] count]+1){
            [dict setObject:@"e9821324-08ac-43f6-ad9d-5b6aabe8e8c3" forKey:@"MemberId"];
            [dict setObject:@"Team" forKey:@"firstName"];
            [dict setObject:@"Nooch" forKey:@"lastName"];
            [dict setObject:UIImagePNGRepresentation([UIImage imageNamed:@"noochLogo.png"]) forKey:@"image"];
        }else{
            @try {
                dict = [[[me assos] objectForKey:@"people"] objectForKey:[[[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row] objectForKey:@"MemberId"]];
                /*if (![[me usr] objectForKey:@"fbUID"]){
                    dict = [[[me assos] objectForKey:@"people"] objectForKey:[[[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row-1] objectForKey:@"MemberId"]];
                }else{
                    dict = [[[me assos] objectForKey:@"people"] objectForKey:[[[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row] objectForKey:@"MemberId"]];
                }*/
            }
            @catch (NSException *exception) {
                NSLog(@"error grabbing person %@",exception.description);
                dict = [[[me assos] objectForKey:@"members"] objectAtIndex:indexPath.row];
            }
            @finally {
                
            }
        }
    }
    
    receiverFirst = [dict objectForKey:@"firstName"];
    receiverLast = [dict objectForKey:@"lastName"];
    receiverId = [dict objectForKey:@"MemberId"];
    if (causes) {
        receiverImgData = UIImagePNGRepresentation([dict objectForKey:@"image"]);
    }else{
        receiverImgData = [dict objectForKey:@"image"];
    }
    if([dict objectForKey:@"image"] == NULL){
        receiverImgData = UIImagePNGRepresentation([UIImage imageNamed:@"profile_picture.png"]);
    }
    if([receiverId length] == 0 || receiverId == NULL){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Slow down" message:@"Since this is a private release, sending money to non-Noochers is not supported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }else{
        sendingMoney = YES;
        if (causes) {
            [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"causes"] animated:YES];
        }else{
            [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES];
        }
    }
}

#pragma mark - connection handling
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
}

#pragma mark - text field delegation
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [searchField resignFirstResponder];
    [self.friendTable reloadData];
    return YES;
}
- (IBAction)clearSearch:(id)sender {
    searchField.text = @"";
    [searchField resignFirstResponder];
    searching = NO;
    emailEntry = NO;
    clearSearchButton.hidden = YES;
    [self.friendTable reloadData];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([[searchField.text stringByAppendingString:string] length] == 0 || ([searchField.text length] == 1 && [string length] == 0) ){
        searching = NO;
        emailEntry = NO;
    }else if([string length] == 0){
        searchString = [searchField.text substringToIndex:[searchField.text length] - 1];
        //searchString = searchField.text;
        [self.friendTable reloadData];
    }else{
        clearSearchButton.hidden = NO;
        searching = YES;
        NSRange isRange = [[searchField.text stringByAppendingString:string] rangeOfString:[NSString stringWithFormat:@"@"] options:NSCaseInsensitiveSearch];
        if(isRange.location != NSNotFound){
            emailEntry = YES;
            searching = NO;
        }else
            emailEntry = NO;

        searchString = [searchField.text stringByAppendingString:string];
    }
    
    [self.friendTable reloadData];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if([searchField.text length] == 0 ){
        searching = NO;
        emailEntry = NO;
        NSLog(@"nahh");
    }
    [searchField resignFirstResponder];
    [self.friendTable reloadData];
}

#pragma- server response delegation
-(void) listen:(NSString *)result tagName:(NSString*)tagName{
    
    NSDictionary *loginResult = [result JSONValue];
    if([tagName isEqualToString:@"SetDeviceToken"]){
        return;
    }
    if ((loginResult != NULL) && ([loginResult count] > 0) && ([tagName isEqualToString:@"getMemberDetails"]))
    {
        if(emailSend){
            NSLog(@"email push");
            [me endWaitStat];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setDictionary:[result JSONValue]];
            receiverFirst = [dict objectForKey:@"FirstName"];
            receiverLast = [dict objectForKey:@"LastName"];
            receiverId = [dict objectForKey:@"MemberId"];
            NSURL *photoUrl=[[NSURL alloc]initWithString:[loginResult objectForKey:@"PhotoUrl"]];
            receiverImgData = [NSData dataWithContentsOfURL:photoUrl];
            [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES];
            return;
        }else{
            if([loginResult objectForKey:@"BalanceAmount"] != [NSNull null])
            {
                [[me usr] setObject:[loginResult objectForKey:@"BalanceAmount"] forKey:@"Balance"];
            }
            else
            {
                balanceLabel.text=@"$0.00";
            }

            if([loginResult objectForKey:@"FirstName"] != [NSNull null])
            {
                [[me usr] setObject:[loginResult objectForKey:@"FirstName"] forKey:@"firstName"];
                [[me usr] setObject:[loginResult objectForKey:@"LastName"] forKey:@"lastName"];
            }
            [self updateBanner];
        }
    }

    else if ([tagName isEqualToString:@"GetrecentCache"])
    {
        NSMutableArray *loginResult = [result JSONValue];
        [self performSelectorInBackground:@selector(recentProcess:) withObject:loginResult];
    }

    else if([tagName isEqualToString:@"emailCheck"])
    {
        NSMutableDictionary *loginResult = [result JSONValue];
        if([loginResult objectForKey:@"Result"] != [NSNull null])
        {
            emailSend = YES;
            serve *getDetails = [serve new];
            getDetails.Delegate = self;
            getDetails.tagName = @"getMemberDetails";
            [getDetails getDetails:searchField.text];
        }
        else
        {
            //[me endWaitStat];
            UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Unknown" message:@"We at Nooch have no knowledge of this email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertRedirectToProfileScreen show];
            [me endWaitStat];
        }
    }else if([tagName isEqualToString:@"GetMemberTargusScoresForBank"]){
        if(([loginResult objectForKey:@"Address"]==[NSNull null]) || ([loginResult objectForKey:@"EmailId"]==[NSNull null]) || ([loginResult objectForKey:@"ContactNumber"]==[NSNull null]))
        {
            UIAlertView *alertRedirectToProfileScreen=[[UIAlertView alloc]initWithTitle:@"Profile Validation Failed!" message:@"Please provide valid contact information such as address, city, state and contact number details in the profile information page." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertRedirectToProfileScreen show];
            startButton.userInteractionEnabled = YES;
            [self goSettings:self];
        }
        else
        {
            NSString *validated = @"YES";
            [[me usr] setObject:validated forKey:@"validated"];
            [self startSelectRecip];
        }
    }else if([tagName isEqualToString:@"AddressCheck"]){
        NSMutableArray *addrParse = [[loginResult objectForKey:@"GetMemberIdsResult"] objectForKey:@"phoneEmailList"];
        for (NSDictionary *dict in addrBookUsername) {
            NSMutableDictionary *addrAdd = [NSMutableDictionary new];
            for (NSDictionary *responseDict in addrParse) {
                if ([[dict objectForKey:@"emailAddy"] isEqualToString:[responseDict objectForKey:@"emailAddy"]] || [[dict objectForKey:@"phoneNo"] isEqualToString:[responseDict objectForKey:@"phoneNo"]]) {
                    [addrAdd addEntriesFromDictionary:dict];
                    if (![[responseDict objectForKey:@"memberId"] isKindOfClass:[NSNull class]]) {
                        [addrAdd setObject:[responseDict objectForKey:@"memberId"] forKey:@"MemberId"];
                        [addrBookNooch addObject:addrAdd];
                    }else{
                        [addrBook addObject:addrAdd];
                    }
                    break;
                }
            }
            [me endWaitStat];
        }
        NSLog(@"addrBook size %i and addrBookNooch %i",[addrBook count],[addrBookNooch count]);
        [me addAssos:addrBook];
        [me addAssos:addrBookNooch];
    }else{
    }
}

#pragma mark - alert view delegation
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1 && buttonIndex == 1){
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        [self emailSupport];
    }else if(alertView.tag ==16 && buttonIndex == 1){
        profileGO = YES;
        [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"settings"] animated:YES];
    }
}
- (void)emailSupport {
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
    [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
    [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:mailComposer animated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultSent) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Thanks for Contacting Us" message:@"Our detectives will get the case." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

#pragma mark - other stuffs
- (void)viewDidUnload{
    [self setUserPic:nil];
    [self setFirstNameLabel:nil];
    [self setLastNameLabel:nil];
    [self setBalanceLabel:nil];
    [self setSendMoneyView:nil];
    [self setFriendTable:nil];
    [self setSpinner:nil];
    [self setBlankLabel:nil];
    [self setStartButton:nil];
    [self setButtonView:nil];
	[self setConnectFbButton:nil];
    [self setBannerView:nil];
    newRequests = nil;
    pendingRequestView = nil;
    userBar = nil;
    sendMoneyOverlay = nil;
    requestBadge = nil;
    searchField = nil;
    peepsOrCauses = nil;
    clearSearchButton = nil;
    navBar = nil;
    navBar = nil;
    leftNavButton = nil;
    leftNavButton = nil;
    rightMenuButton = nil;
    progressImage = nil;
    tutorialView = nil;
    tutorialImage = nil;
    nextTut = nil;
    prevTut = nil;
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

@end