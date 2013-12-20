//
//  history.m
//  Nooch
//
//  Created by Preston Hults on 10/21/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "history.h"
#import <QuartzCore/QuartzCore.h>
#import "NoochHelper.h"
#import "transfer.h"
#import "UAPush.h"
#import "AllMapViewController.h"
@interface history ()
{
    NSMutableArray * mapArrays;
    NSMutableArray*oldRecordsArray;
    NSMutableDictionary *tableViewBind1;
}
@end

@implementation history

@synthesize dipusteNote,firstNamehist,lastNamehist,balance,historyTable,userPic,responseData,
spinner,blankLabel,transferDetails,transerAmount,sender,recipient,date,location,disputeStatus
,memo,dispDate,dispId,dispStatus,disputeDetailsView,resDate,reviewDate,disputeMessage,
disputeRequest,disputeSubject,disputeDetailsButton,goDisputeButton,allTrans,detailsTable,
partyTransferImage,youImage,secondPartyImage,statusOfTransfer;
bool disputing;
bool bankTransfer;
int loadingIndex;
bool histSearch;
bool details4;
NSString *curMemo;


#pragma mark - inits
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    
    //oldRecordsArray=[[NSMutableArray alloc]init];
    load=0;
    index=1;
    if([transactionId length] != 0){
        NSLog(@"checking for transaction to update");
        for (NSMutableDictionary *dict in [me histFilter:filterPick]) {
            if ([transactionId isEqualToString:[dict objectForKey:@"TransactionId"]]) {
                NSLog(@"found transaction");
                [self applyUpdateToDetails:dict];
                [me waitStat:@"Updating details..."];
                break;
            }
        }
    }
    if([[me histFilter:filterPick] count] == 0){
        newTransfersDecrement = newTransfers;
        NSLog(@"getting initial");
        [self.view addSubview:[me waitStat:@"Loading your history..."]];
        loadingCheck = YES;
        loadingHide = YES;
        [me histMore:filterPick sPos:index len:20];
    }else{
        loadingHide = NO;
        loadingCheck = NO;
        NSLog(@"updating");
        [me histPoll];
        [me endWaitStat];
    }
    //[self hideMenu];
}
-(void)viewWillDisappear:(BOOL)animated{
    newTransfers = 0;
    //[self hideMenu];
}
-(void)hideMenu{
    [self.slidingViewController resetTopView];
}
-(void)goHome{
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.window cache: YES];
    [UIView setAnimationDuration:1];
    [self dismissViewControllerAnimated:YES completion:nil];

    //[self dismissModalViewControllerAnimated:NO];
    [UIView commitAnimations];
}
-(void)showMenu{
    [self.slidingViewController anchorTopViewTo:ECRight];
}
-(void)viewWillAppear:(BOOL)animated{
    //[self hideMenu];
     isSearching = NO;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UAPush shared] resetBadge];

    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    [leftNavBar addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableReload:) name:@"tableReload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    if(suspended){
        [userBar setHighlighted:YES];
    }else{
        [userBar setHighlighted:NO];
    }
    firstNamehist.textColor = lastNamehist.textColor = balance.textColor = [UIColor whiteColor];
    [filterButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    navBar.topItem.title = @"History";
    newTransfersDecrement = 0;
    historyTable.hidden = NO;
    if (viewDetails) {
        histSafe = NO;
        bool found = NO;
        for (NSMutableDictionary *dict in [me hist]) {
            if ([[dict objectForKey:@"TransactionId"] isEqualToString:tId]) {
                found = YES;
                [self applyUpdateToDetails:dict];
                if (transferDetails.frame.origin.x != 0) {
                    CGRect inFrame = [transferDetails frame];
                    inFrame.origin.x -=320;
                    [transferDetails setFrame:inFrame];
                    inFrame = historyTable.frame;
                    inFrame.origin.x -=320;
                    [historyTable setFrame:inFrame];
                }
                break;
            }
        }
        if (!found) {
            for (NSMutableDictionary *dict in [me hist]) {
                if ([[dict objectForKey:@"TransactionId"] isEqualToString:tId]) {
                    found = YES;
                    [self applyUpdateToDetails:dict];
                    if (transferDetails.frame.origin.x != 0) {
                        CGRect inFrame = [transferDetails frame];
                        inFrame.origin.x -=320;
                        [transferDetails setFrame:inFrame];
                        inFrame = historyTable.frame;
                        inFrame.origin.x -=320;
                        [historyTable setFrame:inFrame];
                    }
                    break;
                }
            }
        }
        histSafe = YES;
        navBar.topItem.title = @"Transfer Details";
        filterButton.hidden = YES;
        transactionId = tId;
        viewDetails = NO;
        [leftNavBar setBackgroundImage:[UIImage imageNamed:@"HistoryBack.png"] forState:UIControlStateNormal];
        [leftNavBar setFrame:CGRectMake(0, 0, 65, 30)];
        [leftNavBar removeTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [leftNavBar addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        navBar.topItem.title = @"Transfer Details";
        filterButton.hidden = YES;
        return;
    }
    if (getRequests) {
        filterPick = @"REQUEST";
        getRequests = NO;
    }
    historyTable.backgroundColor = [UIColor clearColor];
    historyTable.opaque = NO;
    historyTable.backgroundView = nil;
    if ([[me hist] count] > 0) [[me usr] setObject:[[[me hist] objectAtIndex:0] objectForKey:@"TransactionId"] forKey:@"lastSeen"];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (([scrollView contentOffset].y + scrollView.frame.size.height) == [scrollView contentSize].height) {
        NSLog(@"scrolled to bottom");
        
//        [[self footerActivityIndicator] startAnimating];
//        [self performSelector:@selector(stopAnimatingFooter) withObject:nil afterDelay:0.5];
        return;
	}
	if ([scrollView contentOffset].y == scrollView.frame.origin.y) {
//        NSLog(@"scrolled to top %@",[self activityIndicatorView]);
//        [[self headerActivityIndicator] startAnimating];
      //  [self performSelector:@selector(stopAnimatingHeader) withObject:nil afterDelay:0.5];
	}
    
    
}


-(void)tableReload:(NSNotification *)notification{
    
    historyTable.hidden = NO;
    [me endWaitStat];
    newTransfersDecrement = newTransfers;
    [self.historyTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    loadingCheck = NO;
    loadingHide = NO;
    histSafe = NO;
    if ([transactionId length] != 0) {
        for (NSDictionary *dict in [me hist]) {
            if ([transactionId isEqualToString:[dict objectForKey:@"TransactionId"]]) {
                [self performSelectorOnMainThread:@selector(applyUpdateToDetails:) withObject:dict waitUntilDone:NO];
                break;
            }
        }
    }
    histSafe = YES;
    if ([[me hist] count] == 0 && !histSearch) {
        limit = YES;
    }
    else
    {
    [[me usr] setObject:[[[me hist] objectAtIndex:0] objectForKey:@"TransactionId"] forKey:@"lastSeen"];
        
        if (load==0) {
            if ([[me arrRecordsCheck] count]==0) {
                limit=YES;
            }
            else
            {
                oldRecordsArray=[[NSMutableArray alloc]init];
                NSLog(@"Ginti %d",[[me histFilter:filterPick] count]);
                mapArrays = [[NSMutableArray alloc] init];
                if ([me histFilter:filterPick]) {
                    for ( int i=0;i<[[me histFilter:filterPick] count];i++) {
                        NSDictionary*dict=[[me histFilter:filterPick]objectAtIndex:i];
                        //making a locations array CHARANJIT
                        NSLog(@"%@",dict);
                        NSLog(@"DICT %@",[dict objectForKey:@"Longitude"]);
                        NSMutableDictionary * tempMapsDict = [[NSMutableDictionary alloc] init];
                        if ([dict objectForKey:@"FirstName"]) {
                             [tempMapsDict setObject:[dict objectForKey:@"FirstName"] forKey:@"fname"];
                        }
                        if ([dict objectForKey:@"LastName"]) {
                             [tempMapsDict setObject:[dict objectForKey:@"LastName"] forKey:@"lname"];
                        }
                        if ([dict objectForKey:@"Latitude"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"Latitude"] forKey:@"lat"];
                        }
                        if ([dict objectForKey:@"Longitude"]) {
                             [tempMapsDict setObject:[dict objectForKey:@"Longitude"] forKey:@"lng"];
                        }
                        if ([dict objectForKey:@"TransactionType"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"TransactionType"] forKey:@"TransactionType"];
                        }
                        if ([dict objectForKey:@"AddressLine1"]) {
                             [tempMapsDict setObject:[dict objectForKey:@"AddressLine1"] forKey:@"AddressLine1"];
                        }
                        if ([dict objectForKey:@"AddressLine2"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"AddressLine2"] forKey:@"AddressLine2"];
                        }
                        if ([dict objectForKey:@"Amount"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"Amount"] forKey:@"Amount"];
                        }
                        if ([dict objectForKey:@"City"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"City"] forKey:@"City"];
                        }
                        
                        if ([dict objectForKey:@"TxnDate"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"TxnDate"] forKey:@"TxnDate"];
                        }
                        if ([dict objectForKey:@"Photo"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"Photo"] forKey:@"Photo"];
                        }
                        if ([dict objectForKey:@"Date"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"Date"] forKey:@"Date"];
                        }
                        if ([dict objectForKey:@"Country"]) {
                            [tempMapsDict setObject:[dict objectForKey:@"Country"] forKey:@"Country"];
                        }
                        
                        //
                        
                       
//                                                [tempMapsDict setObject:[dict objectForKey:@"City"] forKey:@"City"];
//                        [tempMapsDict setObject:[dict objectForKey:@"Country"] forKey:@"Country"];
//                        [tempMapsDict setObject:[dict objectForKey:@"Date"] forKey:@"Date"];
//                        [tempMapsDict setObject:[dict objectForKey:@"Photo"] forKey:@"Photo"];
//                        [tempMapsDict setObject:[dict objectForKey:@"TxnDate"] forKey:@"TxnDate"];
                        [mapArrays addObject:tempMapsDict];
                        //-------
                        [oldRecordsArray addObject:dict];
                        
                    }
                    limit=NO;
                }
            
            }
            NSLog(@"%d",oldRecordsArray.count);
            load=1;
            
        }
            }
    [historyTable reloadData];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    loadingHide = YES;
    startNewTransfer.userInteractionEnabled = NO;
    filterPick = @"ALL";
    histSearching = @"";
    spinner.hidesWhenStopped = YES;
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateBanner) userInfo:nil repeats:YES];
    limit=NO;
    loadingIndex = -1;
    loadingCheck = NO;
    self.trackedViewName = @"History";
    [self.detailsTable setScrollEnabled:NO];
    allTrans = YES;
    firstNamehist.font = sender.font = recipient.font = date.font = location.font = disputeStatus.font = memo.font = dispStatus.font = dispId.font = dispDate.font =
    reviewDate.font = resDate.font = [core nFont:@"Medium" size:16];
    date.font = [core nFont:@"Bold" size:10];
    lastNamehist.font =  [core nFont:@"Bold" size:17];
    balance.font = [core nFont:@"Medium" size:20];
    transerAmount.font = [core nFont:@"Medium" size:26];
    statusOfTransfer.font = [core nFont:@"Medium" size:18];
    memo.font = [core nFont:@"Italic" size:14];
    
    if([[[me usr] objectForKey:@"Balance"] length] != 0)
        balance.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    firstNamehist.text=[[me usr] objectForKey:@"firstName"];
    lastNamehist.text=[[me usr] objectForKey:@"lastName"];
    firstNamehist.text=[firstNamehist.text capitalizedString];
    NSLog(@"%@naam%@doja",firstNamehist.text,lastNamehist.text);
    lastNamehist.text=[lastNamehist.text capitalizedString];
    //firstName.text=[[me usr] objectForKey:@"firstName"];
    //lastName.text=[[me usr] objectForKey:@"lastName"];
    requestBadgeName.font = [core nFont:@"Bold" size:14];
    requestBadgeName.text = @"";
    requestBadgeName.hidden = YES;
    recipRequestBadge.hidden = YES;
    senderRequestBadge.hidden = YES;
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
    }else{
        userPic.image = [UIImage imageNamed:@"profile_picture.png"];
    }
    blankLabel.text = @"You don't have any transactions yet!";
    disputing = NO;
    recipId = [NSString new];
    sendId = [NSString new];
    transactionId = [NSString new];

    detailsTable.layer.cornerRadius = 10;
    detailsTable.layer.borderWidth = 1;
    detailsTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
    partyTransferImage = [NSData new];

    userPic.layer.cornerRadius = 4;
    userPic.clipsToBounds = YES;
    youImage.layer.cornerRadius = 7;
    secondPartyImage.layer.cornerRadius = 7;
    youImage.layer.borderWidth = 1;
    secondPartyImage.layer.borderWidth = 1;
    secondPartyImage.clipsToBounds = YES;
    youImage.clipsToBounds = YES;
    historyTable.hidden = YES;
}
-(void)applyUpdateToDetails:(NSMutableDictionary*)dict{
    bool cancelledReq = NO;
    [whichArrows setHighlighted:NO];
    requestBadgeName.hidden = YES;
    recipRequestBadge.hidden = YES;
    senderRequestBadge.hidden = YES;
    cancelledRequestBadge.hidden = YES;
    ignoreButton.hidden = YES;
    payButton.hidden = YES;
    cancelButton.hidden = YES;
    bankTransfer = NO;
    CGRect frame = transferDetails.frame;
    frame.origin.y = 53;
    transferDetails.frame = frame;
    
    if ([[dict objectForKey:@"Status"] isKindOfClass:[NSNull class]]) {
        [dict setObject:@"Cancelled" forKey:@"Status"];
    }
    
    if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent"])
    {
        sender.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
        if([dict objectForKey:@"image"] != NULL) secondPartyImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        else secondPartyImage.image = [UIImage imageNamed:@"profile_picture.png"];
        youImage.image = userPic.image;
    }

    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"])
    {
        recipient.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
        if([dict objectForKey:@"image"] != NULL) youImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        else youImage.image = [UIImage imageNamed:@"profile_picture.png"];
        secondPartyImage.image = userPic.image;
        goDisputeButton.hidden = YES;
        dipusteNote.hidden = YES;
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"])
    {
        
        [whichArrows setHighlighted:YES];
        if ([[dict objectForKey:@"Status"] isEqualToString:@"Pending"]) {
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            cancelButton.hidden = NO;
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Declined"]){
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            requestBadgeName.hidden = NO;
            recipRequestBadge.hidden = NO;
            senderRequestBadge.hidden = NO;
            recipRequestBadge.highlighted = YES;
            senderRequestBadge.highlighted = YES;
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            cancelledReq = YES;
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            requestBadgeName.hidden = NO;
            recipRequestBadge.hidden = YES;
            senderRequestBadge.hidden = YES;
            recipRequestBadge.highlighted = YES;
            senderRequestBadge.highlighted = YES;
            cancelledRequestBadge.hidden = NO;
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            cancelledReq = YES;
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else{
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            statusOfTransfer.text = @"Requested";
            isRequest = NO;
            recipRequestBadge.highlighted = NO;
            senderRequestBadge.highlighted = NO;
            recipRequestBadge.hidden = NO;
            senderRequestBadge.hidden = NO;
            requestBadgeName.hidden = NO;
        }
        if ([[dict objectForKey:@"RecepientId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) { //I initiated request
            recipRequestBadge.hidden = YES;
            cancelledRequestBadge.highlighted = YES;
            if (isRequest && cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]) {
                requestBadgeName.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FirstName"]];
            }else if(!isRequest && !cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                requestBadgeName.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FirstName"]];
            }else{
                requestBadgeName.text = @"";
            }
            sender.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
            recipient.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
            if([dict objectForKey:@"image"] != NULL) secondPartyImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
            else secondPartyImage.image = [UIImage imageNamed:@"profile_picture.png"];
            youImage.image = userPic.image;
        }else{
            cancelledRequestBadge.highlighted = NO;
            cancelButton.hidden = YES;
            if (isRequest && cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]) {
                requestBadgeName.text = [NSString stringWithFormat:@""];
            }else if(!isRequest && !cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                requestBadgeName.text = [NSString stringWithFormat:@""];
            }else{
                requestBadgeName.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FirstName"]];
            }
            senderRequestBadge.hidden = YES;
            if (!cancelledReq) {
                ignoreButton.hidden = NO;
                payButton.hidden = NO;
            }
            if ([[dict objectForKey:@"Status"] isEqualToString:@"Success"] || [[dict objectForKey:@"Status"] isEqualToString:@"Declined"]) {
                ignoreButton.hidden = YES;
                payButton.hidden = YES;
            }
            recipient.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
            sender.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
            if([dict objectForKey:@"image"] != NULL) youImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
            else youImage.image = [UIImage imageNamed:@"profile_picture.png"];
            secondPartyImage.image = userPic.image;
        }
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Deposit"])
    {
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        sender.text = @"Bank\nAccount";
        secondPartyImage.image = userPic.image;
        youImage.image = [UIImage imageNamed:@"Blue_Bank_Icon.png"];
        bankTransfer = YES;

        NSString *stringFormattedDate = [[NSString alloc] init];
        stringFormattedDate = @"";
        NSString *strMessageToAppend = @"Deposit into Nooch";
        stringFormattedDate=[NoochHelper dateTimeStamp:[dict objectForKey:@"TransactionDate"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *tranDate = [dateFormat dateFromString:[dict objectForKey:@"TransactionDate"]];
        NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
        double time1 = [time doubleValue];
        double timeSecond = [time2 doubleValue];
        double diff = time1 - timeSecond;
        [dateFormat setDateFormat:@"EEEE"];
        NSString *day = [dateFormat stringFromDate:tranDate];
        if([day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"] || [day isEqualToString:@"Thursday"]){
            diff = diff-172800;
        }else if([day isEqualToString:@"Sunday"]){
            diff = diff - 86400;
        }
        if(diff < 172800){
            strMessageToAppend = @"Submitted";
            memo.textColor = [core hexColor:@"DDDD2A"];
        }else{ strMessageToAppend = @"Completed"; memo.textColor = [core hexColor:@"99CC66"];}
        memo.text = strMessageToAppend;
        statusOfTransfer.text = memo.text; //memo.text = @"";
    }

    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Withdraw"])
    {
        youImage.image = userPic.image;
        secondPartyImage.image = [UIImage imageNamed:@"Blue_Bank_Icon.png"];
        recipient.text = @"Bank\nAccount";
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        memo.text = @"Pending";
        memo.textColor = [core hexColor:@"99CC66"];
        statusOfTransfer.text = @"Pending";
        bankTransfer = YES;

        NSString *stringFormattedDate = [[NSString alloc] init];
        stringFormattedDate = @"";
        NSString *strMessageToAppend = @"Deposit into Nooch";
        stringFormattedDate=[NoochHelper dateTimeStamp:[dict objectForKey:@"TransactionDate"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *tranDate = [dateFormat dateFromString:[dict objectForKey:@"TransactionDate"]];
        NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
        double time1 = [time doubleValue];
        double timeSecond = [time2 doubleValue];
        double diff = time1 - timeSecond;
        [dateFormat setDateFormat:@"EEEE"];
        NSString *day = [dateFormat stringFromDate:tranDate];
        if([day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"] || [day isEqualToString:@"Thursday"]){
            diff = diff-172800;
        }else if([day isEqualToString:@"Sunday"]){
            diff = diff - 86400;
        }
        if(diff < 172800){
            strMessageToAppend = @"Pending";
            memo.textColor = [core hexColor:@"DDDD2A"];
        }else{ strMessageToAppend = @"Completed"; memo.textColor = [core hexColor:@"99CC66"];}
        memo.text = strMessageToAppend;
        statusOfTransfer.text = memo.text; //memo.text = @"";
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent to"])
    {
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
        if([dict objectForKey:@"image"] != NULL) secondPartyImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        youImage.image = userPic.image;
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received from"])
    {
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        if([dict objectForKey:@"image"] != NULL) youImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        else youImage.image = [UIImage imageNamed:@"profile_picture.png"];
        secondPartyImage.image = userPic.image;
        goDisputeButton.hidden = YES;
        dipusteNote.hidden = YES;
    }
    NSString *amount = [NSString stringWithFormat:@"$%.02f", [[dict objectForKey:@"Amount"] floatValue]];
    transerAmount.text = amount;
    date.text = [NSString stringWithFormat:@"       %@           %@",[NoochHelper hourMinuteAP:[dict objectForKey:@"TransactionDate"]],[NoochHelper dayMonthYear:[dict objectForKey:@"TransactionDate"]]];
    NSMutableString *compare = [[NSMutableString alloc] init];
    compare = [dict objectForKey:@"City"];
    NSMutableString *compare2 = [[NSMutableString alloc] init];
    compare2 = [dict objectForKey:@"State"];
    NSString *cityName = [dict objectForKey:@"City"];
    if((NSNull *)compare != [NSNull null] && (NSNull *)compare2 != [NSNull null] && [compare length] != 0 && [compare2 length] != 0)
        location.text = [NSString stringWithFormat:@"%@, %@",cityName,[dict objectForKey:@"State"]];
    else
        location.text = @"Not Shared";

    compare = [dict objectForKey:@"DisputeStatus"];
    if((NSNull *)compare == [NSNull null] || [dict objectForKey:@"DisputeStatus"] == NULL){
        goDisputeButton.hidden = NO;
        dipusteNote.hidden = NO;
        disputeStatus.text = @"";
    }else if([compare isEqualToString:@"Resolved"]){
        goDisputeButton.hidden = YES;
        dipusteNote.hidden = YES;
        disputeStatus.text = @"Resolved";
        disputeStatus.textColor = dispStatus.textColor = [core hexColor:@"99CC66"];
        disputeDetailsButton.userInteractionEnabled = YES;
        dispStatus.text = [dict objectForKey:@"DisputeStatus"];
        dispId.text = [dict objectForKey:@"DisputeId"];
        dispDate.text = [[dict objectForKey:@"DisputeReportedDate"] substringToIndex:10];
        compare = [dict objectForKey:@"DisputeResolvedDate"];
        if((NSNull *)compare != [NSNull null])
            resDate.text = [[dict objectForKey:@"DisputeResolvedDate"] substringToIndex:10];
        else
            resDate.text = @"";
        compare = [dict objectForKey:@"DisputeReviewDate"];
        if((NSNull *)compare != [NSNull null])
            reviewDate.text = [[dict objectForKey:@"DisputeReviewDate"] substringToIndex:10];
        else
            reviewDate.text = @"";

        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280,186,7,10)];
        arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
    }else{
        goDisputeButton.hidden = YES;
        dispStatus.textColor = [core hexColor:@"bf4444"];
        dispStatus.text = [dict objectForKey:@"DisputeStatus"];
        dispId.text = [dict objectForKey:@"DisputeId"];
        if([dict objectForKey:@"DIsputeReportedDate"] != NULL)
            dispDate.text = [[dict objectForKey:@"DisputeReportedDate"] substringToIndex:10];
        compare = [dict objectForKey:@"DisputeResolvedDate"];
        if((NSNull *)compare == [NSNull null])
            resDate.text = [[dict objectForKey:@"DisputeResolvedDate"] substringToIndex:10];
        else
            resDate.text = @"";
        compare = [dict objectForKey:@"DisputeReviewDate"];
        if((NSNull *)compare == [NSNull null])
            reviewDate.text = [[dict objectForKey:@"DisputeReviewDate"] substringToIndex:10];
        else
            reviewDate.text = @"";

        disputeDetailsButton.userInteractionEnabled = YES;
        disputeStatus.text = [dict objectForKey:@"DisputeStatus"];
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280,193,7,10)];
        arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
        disputeStatus.textColor = [core hexColor:@"bf4444"];
        if( [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received from"] || [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"] ){
            disputeStatus.text = @"Not in Dispute";
            disputeStatus.textColor = [core hexColor:@"99CC66"];
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
        }
    }
    if (![[dict objectForKey:@"Memo"] isKindOfClass:[NSNull class]]) {
        if ([[dict objectForKey:@"Memo"] length] != 0) {
            if ([[dict objectForKey:@"Memo"] rangeOfString:@"0dm"].location != NSNotFound ) {
                if([[dict objectForKey:@"Memo"] length] != 3) memo.text = [[dict objectForKey:@"Memo"] substringFromIndex:3];
                else memo.text = @"";
            }else if ([[dict objectForKey:@"Memo"] rangeOfString:@"0fm"].location != NSNotFound ) {
                if([[dict objectForKey:@"Memo"] length] != 3) memo.text = [[dict objectForKey:@"Memo"] substringFromIndex:3];
                else memo.text = @"";
            }else if ([[dict objectForKey:@"Memo"] rangeOfString:@"0im"].location != NSNotFound ) {
                if([[dict objectForKey:@"Memo"] length] != 3) memo.text = [[dict objectForKey:@"Memo"] substringFromIndex:3];
                else memo.text = @"";
            }else if ([[dict objectForKey:@"Memo"] rangeOfString:@"0tm"].location != NSNotFound ) {
                if([[dict objectForKey:@"Memo"] length] != 3) memo.text = [[dict objectForKey:@"Memo"] substringFromIndex:3];
                else memo.text = @"";
            }else if ([[dict objectForKey:@"Memo"] rangeOfString:@"0um"].location != NSNotFound ) {
                if([[dict objectForKey:@"Memo"] length] != 3) memo.text = [[dict objectForKey:@"Memo"] substringFromIndex:3];
                else memo.text = @"";
            }else{
                memo.text = [dict objectForKey:@"Memo"];
            }
            memo.textColor = [core hexColor:@"006699"];
            if([memo.text length] != 0)memo.text = [NSString stringWithFormat:@"for \"%@\"",memo.text];
            else{ memo.text = @"No memo attached"; memo.textColor = [UIColor grayColor];}
        }else{
            memo.text = @"No memo attached";
            memo.textColor = [UIColor grayColor];
        }
    }else{
        memo.text = @"No memo attached";
        memo.textColor = [UIColor grayColor];
    }
    CGRect tranFrame;
    receiverFirst = [dict objectForKey:@"FirstName"];
    receiverLast = [dict objectForKey:@"LastName"];
    receiverImgData = [dict objectForKey:@"image"];
    if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent"]){
        receiverId = [dict objectForKey:@"RecepientId"];
        tranFrame = secondPartyImage.frame;
        tranFrame.size.height += 50;
        startNewTransfer.userInteractionEnabled = YES;
    }else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"]){
        receiverId = [dict objectForKey:@"MemberId"];
        tranFrame = youImage.frame;
        tranFrame.size.height += 50;
        startNewTransfer.userInteractionEnabled = YES;
    }else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"]){
        details4 = NO;
        if ([[dict objectForKey:@"RecepientId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
            tranFrame = secondPartyImage.frame;
        else
            tranFrame = youImage.frame;
        startNewTransfer.userInteractionEnabled = YES;
        if ([[dict objectForKey:@"Status"] isEqualToString:@"Pending"]) {
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.text = @"Not in Dispute";
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Declined"]){
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            requestBadgeName.hidden = NO;
            recipRequestBadge.hidden = YES;
            senderRequestBadge.hidden = YES;
            cancelledRequestBadge.hidden = NO;
            recipRequestBadge.highlighted = YES;
            senderRequestBadge.highlighted = YES;
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            cancelledReq = YES;
            cancelButton.hidden = YES;
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else{
            isRequest = NO;
            details4 = YES;
            CGRect frame = detailsTable.frame;
            frame.size.height = 120;
            [detailsTable setFrame:frame];
        }
    }
    startNewTransfer.frame = tranFrame;
    [me endWaitStat];
    [mapView_ removeFromSuperview];
    if (![[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"] || ([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"] && ![[dict objectForKey:@"Status"] isEqualToString:@"Pending"])) {
        if ([[dict objectForKey:@"Latitude"] doubleValue] == 0 || [[dict objectForKey:@"Longitude"] doubleValue] == 0) {
            return;
        }
        double lat = [[dict objectForKey:@"Latitude"] doubleValue];
        double lon = [[dict objectForKey:@"Longitude"] doubleValue];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                                longitude:lon
                                                                     zoom:13];
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(-1, transferDetails.bounds.size.height-50, 322, 190) camera:camera];
        if ([UIScreen mainScreen].bounds.size.height==480) {
            CGRect frame = mapView_.frame;
            if (!isRequest || details4){
                //21
                frame.origin.y = transferDetails.bounds.size.height-90;
                frame.size.height = 100;
            }else{
                frame.origin.y = transferDetails.bounds.size.height-100;
                frame.size.height = 100;
            }

            [mapView_ setFrame:frame];
        }
        mapView_.myLocationEnabled = YES;
        mapView_.layer.borderWidth = 1;
        mapView_.layer.borderColor = [core hexColor:@"808080"].CGColor;
        [transferDetails addSubview:mapView_];

        // Creates a marker in the center of the map.
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lat, lon);
        //marker.title = @"Sydney";
        //marker.snippet = @"Australia";
        marker.map = mapView_;
    }
    [self.detailsTable reloadData];
}

#pragma mark - constants
-(IBAction)goFunds:(id)sender {
    profileGO = YES;
}
-(IBAction)goSettings:(id)sender {
}
- (IBAction)nameHighlight:(id)sender {
    //firstName.textColor = lastName.textColor = [core hexColor:@"6c92a6"];
}
- (IBAction)balanceHigh:(id)sender {
    //balance.textColor = [core hexColor:@"6c92a6"];
}
- (IBAction)nameDeHighlight:(id)sender {
    firstNamehist.textColor = lastNamehist.textColor = [UIColor whiteColor];
}
- (IBAction)balanceDeHighlight:(id)sender {
    balance.textColor = [UIColor whiteColor];
}

-(void)updateBanner{
    if([[[me usr] objectForKey:@"Balance"] length] != 0)
        balance.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    firstNamehist.text=[[me usr] objectForKey:@"firstName"];
    lastNamehist.text=[[me usr] objectForKey:@"lastName"];
    firstNamehist.text=[firstNamehist.text capitalizedString];
    lastNamehist.text=[lastNamehist.text capitalizedString];
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
    }else{
        userPic.image = [UIImage imageNamed:@"profile_picture.png"];
        //[me fetchPic];
    }
}
-(void)goBack{
    transactionId = @"";
    historyTable.hidden = NO;
    memo.textColor = [core hexColor:@"006699"];
    filterButton.hidden = NO;
    navBar.topItem.title = @"History";
    [leftNavBar setBackgroundImage:[UIImage imageNamed:@"HamburgerButton.png"] forState:UIControlStateNormal];
    [leftNavBar setFrame:CGRectMake(0, 0, 43, 43)];
    [leftNavBar removeTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavBar addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    CGRect inFrame = [transferDetails frame];
    inFrame.origin.x = 320;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [transferDetails setFrame:inFrame];
    inFrame = historyTable.frame;
    inFrame.origin.x = 0;
    [historyTable setFrame:inFrame];
    [UIView commitAnimations];
    [self.historyTable reloadData];
    startNewTransfer.userInteractionEnabled = NO;
    [navCtrl.view addGestureRecognizer:self.slidingViewController.panGesture];
}
-(void)goBackDetails{
    navBar.topItem.title = @"Transfer Details";
    CGRect inFrame = [disputeDetailsView frame];
    inFrame.origin.x = 320;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [disputeDetailsView setFrame:inFrame];
    inFrame = transferDetails.frame;
    inFrame.origin.x = 0;
    [transferDetails setFrame:inFrame];
    [UIView commitAnimations];
    [leftNavBar setBackgroundImage:[UIImage imageNamed:@"HistoryBack.png"] forState:UIControlStateNormal];
    [leftNavBar setFrame:CGRectMake(0, 0, 65, 30)];
    [leftNavBar removeTarget:self action:@selector(goBackDetails) forControlEvents:UIControlEventTouchUpInside];
    [leftNavBar addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}
- (IBAction)goTransfer:(id)sender {
    if(suspended || [[[me usr] objectForKey:@"Status"] isEqualToString:@"Suspended"]){
        UIAlertView *susAV = [[UIAlertView alloc] initWithTitle:@"Account Suspended" message:@"For your protection your account has been temporarily suspended. Please contact us for more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
        [susAV setTag:13];
        [susAV show];
        suspended = YES;
        return;
    }
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES completion:nil];
  //  [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES];
}

#pragma mark - request handling
- (IBAction)ignoreRequest:(id)sender {
    if(suspended || [[[me usr] objectForKey:@"Status"] isEqualToString:@"Suspended"]){
        UIAlertView *susAV = [[UIAlertView alloc] initWithTitle:@"Account Suspended" message:@"For your protection your account has been temporarily suspended. Please contact us for more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
        [susAV setTag:13];
        [susAV show];
        suspended = YES;
        return;
    }
    requestRespond = YES;
    requestId = transactionId;
    requestAmount = transerAmount.text;
    acceptOrDeny = @"DENY";
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES completion:nil];
    //[navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES];
}
- (IBAction)fulfillRequest:(id)sender {
    if(suspended || [[[me usr] objectForKey:@"Status"] isEqualToString:@"Suspended"]){
        UIAlertView *susAV = [[UIAlertView alloc] initWithTitle:@"Account Suspended" message:@"For your protection your account has been temporarily suspended. Please contact us for more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
        [susAV setTag:13];
        [susAV show];
        suspended = YES;
        return;
    }
    requestRespond = YES;
    requestId = transactionId;
    requestAmount = transerAmount.text;
    acceptOrDeny = @"Success";
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES completion:nil];
    //[navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES];
}
- (IBAction)cancelRequest:(id)sender {
    if(suspended || [[[me usr] objectForKey:@"Status"] isEqualToString:@"Suspended"]){
        UIAlertView *susAV = [[UIAlertView alloc] initWithTitle:@"Account Suspended" message:@"For your protection your account has been temporarily suspended. Please contact us for more information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
        [susAV setTag:13];
        [susAV show];
        suspended = YES;
        return;
    }
    requestRespond = YES;
    requestId = transactionId;
    requestAmount = transerAmount.text;
    acceptOrDeny = @"Cancelled";
    NSLog(@"transId %@",transactionId);
    cancelling = YES;
    if ([recipId isEqualToString:[[me usr] objectForKey:@"MemberId"]]) {
        receiverId = sendId;
    }else{
        receiverId = recipId;
    }
    [navCtrl presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES completion:nil];
    //[navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES];
}

#pragma Table view Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == detailsTable){
        if (!isRequest || details4){
            CGRect frame = location.frame;
            frame.origin.y = 269;
            [location setFrame:frame];
            return 3;
        }else{
            CGRect frame = location.frame;
            frame.origin.y = 229;
            [location setFrame:frame];
            return 2;
        }
    }
    //if([[me histFilter:filterPick] count] != 0)
    if ([tableView isEqual:historyTable])    {
        if (isSearching)
            return [arrSearchedRecords count];
    
        else
        return [oldRecordsArray count]+1;
    }
    else
        return 1;
}

- (void) searchTableView
{
   
   
    arrSearchedRecords =[[NSMutableArray alloc]init];
    for (NSMutableDictionary *tableViewBind in oldRecordsArray)
    {
        
        NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:histSearching options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [histSearching length])];
        if (result == NSOrderedSame)
        {
            [arrSearchedRecords addObject:tableViewBind];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == detailsTable)
        return 40;

    return 90;

}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
  /*  if(tableView == detailsTable){
        return;
    }
    
    if(indexPath.row == [[me histFilter:filterPick] count])
        return;
    if ([oldRecordsArray count]>indexPath.row) {
        tableViewBind1 = [[NSMutableDictionary alloc] init];
        tableViewBind1 = [oldRecordsArray  objectAtIndex:indexPath.row];
    }

    
    //return;
    if(newTransfersDecrement != 0 && ([[tableViewBind1 objectForKey:@"TransactionType"] isEqualToString:@"Received from"] || [[tableViewBind1 objectForKey:@"TransactionType"] isEqualToString:@"Received"] ||
                                      ([[tableViewBind1 objectForKey:@"TransactionType"] isEqualToString:@"Request"] && ![[tableViewBind1 objectForKey:@"RecepientId"] isEqualToString:[[me usr] objectForKey:@"MemberId"]]))){
        newTransfersDecrement--;
        
        cell.backgroundView.alpha = 0.2f;
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TransferHighlight.png"]];
    }else{
        cell.backgroundView.alpha = 0.0f;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }*/
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,7)];
    separator.image = [UIImage imageNamed:@"ShadowHistory.png"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];

    cell.userInteractionEnabled = YES;
    if(tableView == detailsTable){
        cell.detailTextLabel.text = @"";
        [cell.textLabel setText:@""];
        cell.userInteractionEnabled = NO;
        cell.indentationLevel = 1;
        cell.indentationWidth = 10;
        //[cell.textLabel setFont:[core nFont:@"Medium" size:14.0]];
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280,15,7,10)];
        arrow.image = [UIImage imageNamed:@"df.png"];
        [cell.textLabel setFont:[core nFont:@"Mediumr" size:16.0]];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        if(indexPath.row == 0){
            //21
            cell.textLabel.text=@"Memo:";
            [cell.textLabel setTextColor:[core hexColor:@"003c5e"]];
            //[cell.textLabel setFont:[core nFont:@"Medium" size:24.0]];
            if(bankTransfer) [cell.textLabel setText:@"Status"];
            else {
                UIImageView *hasMemo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 24, 22)];
                if ([curMemo rangeOfString:@"0dm"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"Memo_Icon.png"]];
                }else if ([curMemo rangeOfString:@"0fm"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconFoodSelected.png"]];
                }else if ([curMemo rangeOfString:@"0im"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconIOUselected.png"]];
                }else if ([curMemo rangeOfString:@"0tm"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconTixSelected.png"]];
                }else if ([curMemo rangeOfString:@"0um"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconUtilitiesSelected.png"]];
                }else{
                    [hasMemo setImage:[UIImage imageNamed:@"Memo_Icon.png"]];
                }

                [cell.contentView addSubview:hasMemo];
            }
            if(![sender.text isEqualToString:@"You"]){
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(265, 5, 30, 30)];
                iv.clipsToBounds = YES;
                iv.layer.cornerRadius = 5;
                iv.layer.borderColor = [UIColor blackColor].CGColor;
                iv.layer.borderWidth = 0.9f;
                iv.image = [UIImage imageWithData:partyTransferImage];
            }
        }else if(indexPath.row == 2){
            cell.textLabel.text=@"Location:";
//            UIImageView *hasLocation = [[UIImageView alloc] initWithFrame:CGRectMake(19, 7, 17, 23)];
//            [hasLocation setImage:[UIImage imageNamed:@"Map_Icon.png"]];
//            [cell.contentView addSubview:hasLocation];
            if(![recipient.text isEqualToString:@"You"]){
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(265, 5, 30, 30)];
                iv.clipsToBounds = YES;
                iv.layer.cornerRadius = 10;
                iv.layer.borderColor = [UIColor blackColor].CGColor;
                iv.layer.borderWidth = 0.9f;
                iv.image = [UIImage imageWithData:partyTransferImage];
            }
        }else if(indexPath.row == 1){
            if (!isRequest || details4){
                
                cell.textLabel.text=@"Status:";

                
                //[cell.textLabel setText:@"Dispute Status"];
                arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
                if(![disputeStatus.text isEqualToString:@"Not in Dispute"] && goDisputeButton.isHidden && ![statusOfTransfer.text isEqualToString:@"Requested"]){
                    [cell.contentView addSubview:arrow];
                    cell.userInteractionEnabled = YES;
                }
            }else{
                
//                UIImageView *hasLocation = [[UIImageView alloc] initWithFrame:CGRectMake(19, 7, 17, 23)];
//                [hasLocation setImage:[UIImage imageNamed:@"Map_Icon.png"]];
//                [cell.contentView addSubview:hasLocation];
                if(![recipient.text isEqualToString:@"You"]){
                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(265, 5, 30, 30)];
                    iv.clipsToBounds = YES;
                    iv.layer.cornerRadius = 10;
                    iv.layer.borderColor = [UIColor blackColor].CGColor;
                    iv.layer.borderWidth = 0.9f;
                    iv.image = [UIImage imageWithData:partyTransferImage];
                }
            }
            
        }
        return cell;
    }
    //21 Added 13 Dec
    
    
    if (isSearching) {
        cell.textLabel.text = nil;
        UIImageView *buble = [[UIImageView alloc] initWithFrame:CGRectMake(4, 6, 312, 77)];
        [buble setImage:[UIImage imageNamed:@"Table_Row_History.png"]];
        [cell.contentView addSubview:buble];
        if ([arrSearchedRecords count] == 1 && isSearching && [[arrSearchedRecords objectAtIndex:[arrSearchedRecords count]-1]isEqualToString:@"No Records"]) {
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 30)];
            [endLabel setFont:[core nFont:@"Medium" size:16.0]];
            [endLabel setTextAlignment:NSTextAlignmentCenter];
            [endLabel setText:@"No Results."];
            [cell.contentView addSubview:endLabel];
            cell.userInteractionEnabled = NO;
            return cell;
        }
//        if(indexPath.row == [arrSearchedRecords count] && !loadingCheck && !limit && !histSearch && !loadingHide){
//            loadingIndex = indexPath.row;
//            loadingCheck = YES;
//            NSLog(@"loading more");
//            [self loadMoreRecords];
//            
//        }
        
        if(indexPath.row == [arrSearchedRecords count] && !histSearch && !loadingHide){
            cell.userInteractionEnabled = NO;
            cell.contentView.clearsContextBeforeDrawing = YES;
            if(limit && [oldRecordsArray count]>0){
                UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 30)];
                [endLabel setFont:[core nFont:@"Medium" size:16.0]];
                [endLabel setTextAlignment:NSTextAlignmentCenter];
                [endLabel setText:@"End of records."];
                [cell.contentView addSubview:endLabel];
            }
            else if (!limit)
            {
                UIActivityIndicatorView *spinner2 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                spinner2.frame = CGRectMake(150,30,20,20);
                [cell.contentView addSubview:spinner2];
                [spinner2 startAnimating];
            }
        }
        if (indexPath.row == 0 && [[me hist] count] == 0 && limit) {
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 30)];
            [endLabel setFont:[core nFont:@"Medium" size:16.0]];
            [endLabel setTextAlignment:NSTextAlignmentCenter];
            [endLabel setText:@"No history."];
            [cell.contentView addSubview:endLabel];
        }
        if(indexPath.row == [arrSearchedRecords count]){
            return cell;
        }
        cell.userInteractionEnabled = YES;
        //[cell.contentView addSubview:separator];
        cell.contentView.clearsContextBeforeDrawing = NO;
        cell.indentationLevel = 1;
        cell.indentationWidth = 100;
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 50, 50)];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
        [v setBackgroundColor:[core hexColor:@"007fb7"]];
        [v setAlpha:0.5f];
        cell.selectedBackgroundView = v;
        iv.clipsToBounds = YES;
        iv.layer.cornerRadius = 6;
        iv.layer.borderColor = [UIColor blackColor].CGColor;
        iv.layer.borderWidth = 0.7f;
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(290,40,10,15)];
        arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
        //[cell.contentView addSubview:arrow];
        [cell.textLabel setFont:[core nFont:@"Medium" size:14.0]];
        NSMutableDictionary *tableViewBind = [NSMutableDictionary new];
        tableViewBind = [arrSearchedRecords  objectAtIndex:indexPath.row];
        NSString *stringFormattedDate = [NSString new];
        stringFormattedDate = @"";
        CGRect dateFrame = CGRectMake(80, 43, 180, 10);
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateFrame];
        dateLabel.font = [core nFont:@"Medium" size:10];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.clearsContextBeforeDrawing = YES;
        UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(228, 15, 70, 30)];
        [amountLabel setTextAlignment:NSTextAlignmentRight];
        amountLabel.font = [core nFont:@"Regular" size:18];
        NSString *amount = [NSString stringWithFormat:@"$%.02f", [[tableViewBind objectForKey:@"Amount"] floatValue]];
        amountLabel.text = amount;
        UILabel *action = [[UILabel alloc] initWithFrame:CGRectMake(70, 23, 180, 15)];
        action.font = [core nFont:@"Medium" size:14.0];
        if([tableViewBind objectForKey:@"image"] != NULL){
            iv.image = [UIImage imageWithData:[tableViewBind objectForKey:@"image"]];
        }else{
            NSArray *keys = [[[[me assos] objectForKey:@"people"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            bool found = NO;
            for (NSString *key in keys) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                dict = [[[me assos] objectForKey:@"people"] objectForKey:key];
                if ([[dict objectForKey:@"firstName"] isEqualToString:[tableViewBind objectForKey:@"FirstName"]] && [[dict objectForKey:@"lastName"] isEqualToString:[tableViewBind objectForKey:@"LastName"]]
                    && [dict objectForKey:@"image"]) {
                    iv.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
                    found = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self userInfo:nil];
                    break;
                }
                
            }
            if (!found)
                iv.image = [UIImage imageNamed:@"profile_picture.png"];
            
        }
        if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Sent"])
        {
            NSString *strMessageToAppend = @"You paid ";
            action.text = [strMessageToAppend stringByAppendingString:[tableViewBind objectForKey:@"FirstName"]];
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            amountLabel.textColor = [core hexColor:@"bf4444"];
        }
        else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Received"])
        {
            NSString *strMessageToAppend = @" paid you";
            action.text = [[tableViewBind objectForKey:@"FirstName"] stringByAppendingString:strMessageToAppend];
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            amountLabel.textColor = [core hexColor:@"72bf44"];
            
        }
        else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Request"])
        {
            if ([[tableViewBind objectForKey:@"RecepientId"] isEqualToString:[[me usr] objectForKey:@"MemberId"]]) { //I initiated request
                NSString *strMessageToAppend = @"You requested from ";
                action.text = [strMessageToAppend stringByAppendingString:[tableViewBind objectForKey:@"FirstName"]];
                stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
                amountLabel.textColor = [core hexColor:@"007fb7"];
                if (![[tableViewBind objectForKey:@"Status"] isKindOfClass:[NSNull class]]) {
                    if ([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Declined"]) {
                        amountLabel.font = [core nFont:@"Medium" size:12];
                        amountLabel.text = @"Ignored";
                        amountLabel.textColor = [core hexColor:@"bf4444"];
                        
                    }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                        amountLabel.font = [core nFont:@"Medium" size:12];
                        amountLabel.text = @"Cancelled";
                        amountLabel.textColor = [core hexColor:@"bf4444"];
                        
                    }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Success"]){
                        amountLabel.textColor = [core hexColor:@"72bf44"];
                        
                    }
                }
            }else{
                NSString *strMessageToAppend = @" requested from you";
                action.text = [[tableViewBind objectForKey:@"FirstName"] stringByAppendingString:strMessageToAppend];
                stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
                amountLabel.textColor = [core hexColor:@"007fb7"];
                if (![[tableViewBind objectForKey:@"Status"] isKindOfClass:[NSNull class]]) {
                    if ([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Declined"]) {
                        amountLabel.font = [core nFont:@"Medium" size:12];
                        amountLabel.text = @"Ignored";
                        amountLabel.textColor = [core hexColor:@"bf4444"];
                        
                    }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                        amountLabel.font = [core nFont:@"Medium" size:12];
                        amountLabel.text = @"Cancelled";
                        amountLabel.textColor = [core hexColor:@"bf4444"];
                        
                    }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Success"]){
                        amountLabel.textColor = [core hexColor:@"bf4444"];
                        
                    }
                }
            }
        }
        
        else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Deposit"])
        {
            NSString *strMessageToAppend = @"Deposit into Nooch";
            
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            NSDate *tranDate = [dateFormat dateFromString:[tableViewBind objectForKey:@"TransactionDate"]];
            NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
            NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
            double time1 = [time doubleValue];
            double timeSecond = [time2 doubleValue];
            double diff = time1 - timeSecond;
            amountLabel.textColor = [core hexColor:@"72bf44"];
            
            [dateFormat setDateFormat:@"EEEE"];
            NSString *day = [dateFormat stringFromDate:tranDate];
            if([day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"] || [day isEqualToString:@"Thursday"]){
                diff = diff-172800;
            }else if([day isEqualToString:@"Sunday"]){
                diff = diff - 86400;
            }
            if(diff < 172800){
                strMessageToAppend = @"Pending deposit into Nooch";
                amountLabel.textColor = [core hexColor:@"DDDD2A"];
                
            }
            action.text = strMessageToAppend;
            iv.image = userPic.image;
        }
        
        else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Withdraw"])
        {
            NSString *strMessageToAppend = @"Withdrawal from Nooch";
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            NSDate *tranDate = [dateFormat dateFromString:[tableViewBind objectForKey:@"TransactionDate"]];
            NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
            NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
            int time1 = [time intValue];
            int  timeSecond = [time2 intValue];
            int diff = time1 - timeSecond;
            amountLabel.textColor = [core hexColor:@"bf4444"];
            
            if(diff < 172800){
                //strMessageToAppend = @"Pending withdrawal from Nooch";
                //amountLabel.textColor = [UIColor yellowColor];
                //action.font = [core nFont:@"Medium" size:12.0];
            }
            action.text = strMessageToAppend;
            iv.image = userPic.image;
        }
        else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Sent to"])
        {
            NSString *strMessageToAppend = @"You disputed ";
            action.text = [strMessageToAppend stringByAppendingString:[tableViewBind objectForKey:@"FirstName"]];
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            amountLabel.textColor = [core hexColor:@"bf4444"];
            
        }
        else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Received from"])
        {
            NSString *strMessageToAppend = @" disputed you";
            action.text = [[tableViewBind objectForKey:@"FirstName"] stringByAppendingString:strMessageToAppend];
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            amountLabel.textColor = [core hexColor:@"72bf44"];
            
        }
        else{
            action.text = [tableViewBind objectForKey:@"Name"];
        }
        
        dateLabel.text = stringFormattedDate;
        [action setBackgroundColor:[UIColor clearColor]];
        [amountLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:action];
        [cell.contentView addSubview:amountLabel];
        [cell.contentView addSubview:dateLabel];
        [cell.contentView addSubview:iv];
        if (![[tableViewBind objectForKey:@"Memo"] isKindOfClass:[NSNull class]]) {
            if ([[tableViewBind objectForKey:@"Memo"] length] != 0) {
                UILabel *tableMemo = [[UILabel alloc] initWithFrame:CGRectMake(72, 57, 210, 14)];
                UIImageView *hasMemo = [[UIImageView alloc] initWithFrame:CGRectMake(260, 55, 15, 14)];
                tableMemo.backgroundColor = [UIColor clearColor];
                tableMemo.font = [core nFont:@"Medium" size:12];
                if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0dm"].location != NSNotFound ) {
                    if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                    else tableMemo.text = @"";
                    [hasMemo setImage:[UIImage imageNamed:@"Memo_Icon.png"]];
                }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0fm"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconFoodSelected.png"]];
                    if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                    else tableMemo.text = @"";
                }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0im"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconIOUselected.png"]];
                    if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                    else tableMemo.text = @"";
                }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0tm"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconTixSelected.png"]];
                    if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                    else tableMemo.text = @"";
                }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0um"].location != NSNotFound ) {
                    [hasMemo setImage:[UIImage imageNamed:@"MemoIconUtilitiesSelected.png"]];
                    if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                    else tableMemo.text = @"";
                }else{
                    [hasMemo setImage:[UIImage imageNamed:@"Memo_Icon.png"]];
                    tableMemo.text = [tableViewBind objectForKey:@"Memo"];
                }
                if([tableMemo.text length] != 0) tableMemo.text = [NSString stringWithFormat:@"for \"%@\"",tableMemo.text];
                tableMemo.textColor = [UIColor grayColor];
                [cell.contentView addSubview:tableMemo];
                [cell.contentView addSubview:hasMemo];
            }
        }
        NSMutableString *compare = [[NSMutableString alloc] init];
        compare = [tableViewBind objectForKey:@"City"];
        NSMutableString *compare2 = [[NSMutableString alloc] init];
        compare2 = [tableViewBind objectForKey:@"State"];
        if((NSNull *)compare != [NSNull null] && (NSNull *)compare2 != [NSNull null] && [compare length] != 0 && [compare2 length] != 0){
            UIImageView *hasLocation = [[UIImageView alloc] initWithFrame:CGRectMake(280, 55, 12, 14)];
            [hasLocation setImage:[UIImage imageNamed:@"Map_Icon.png"]];
            [cell.contentView addSubview:hasLocation];
        }
        action.textColor = amountLabel.textColor;
        
        return cell;
    }
    
    //
    cell.textLabel.text = nil;
    UIImageView *buble = [[UIImageView alloc] initWithFrame:CGRectMake(4, 6, 312, 77)];
    [buble setImage:[UIImage imageNamed:@"Table_Row_History.png"]];
    [cell.contentView addSubview:buble];
    if ([oldRecordsArray count] == 0 && histSearch) {
        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 30)];
        [endLabel setFont:[core nFont:@"Medium" size:16.0]];
        [endLabel setTextAlignment:NSTextAlignmentCenter];
        [endLabel setText:@"No Results."];
        [cell.contentView addSubview:endLabel];
        cell.userInteractionEnabled = NO;
        return cell;
    }
    if(indexPath.row == [oldRecordsArray count] && !loadingCheck && !limit && !histSearch && !loadingHide){
        loadingIndex = indexPath.row;
        loadingCheck = YES;
        NSLog(@"loading more");
        [self loadMoreRecords];
        
    }

    if(indexPath.row == [oldRecordsArray count] && !histSearch && !loadingHide){
        cell.userInteractionEnabled = NO;
        cell.contentView.clearsContextBeforeDrawing = YES;
        if(limit && [oldRecordsArray count]>0){
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 30)];
            [endLabel setFont:[core nFont:@"Medium" size:16.0]];
            [endLabel setTextAlignment:NSTextAlignmentCenter];
            [endLabel setText:@"End of records."];
            [cell.contentView addSubview:endLabel];
        }
        else if (!limit)
        {
            UIActivityIndicatorView *spinner2 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner2.frame = CGRectMake(150,30,20,20);
            [cell.contentView addSubview:spinner2];
            [spinner2 startAnimating];
        }
    }
    if (indexPath.row == 0 && [[me hist] count] == 0 && limit) {
        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 30)];
        [endLabel setFont:[core nFont:@"Medium" size:16.0]];
        [endLabel setTextAlignment:NSTextAlignmentCenter];
        [endLabel setText:@"No history."];
        [cell.contentView addSubview:endLabel];
    }
    if(indexPath.row == [oldRecordsArray count]){
        return cell;
    }
    cell.userInteractionEnabled = YES;
    //[cell.contentView addSubview:separator];
    cell.contentView.clearsContextBeforeDrawing = NO;
    cell.indentationLevel = 1;
    cell.indentationWidth = 100;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 50, 50)];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    [v setBackgroundColor:[core hexColor:@"007fb7"]];
    [v setAlpha:0.5f];
    cell.selectedBackgroundView = v;
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = 6;
    iv.layer.borderColor = [UIColor blackColor].CGColor;
    iv.layer.borderWidth = 0.7f;
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(290,40,10,15)];
    arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
    //[cell.contentView addSubview:arrow];
    [cell.textLabel setFont:[core nFont:@"Medium" size:14.0]];
    NSMutableDictionary *tableViewBind = [NSMutableDictionary new];
    tableViewBind = [oldRecordsArray  objectAtIndex:indexPath.row];
    NSString *stringFormattedDate = [NSString new];
    stringFormattedDate = @"";
    CGRect dateFrame = CGRectMake(80, 43, 180, 10);
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateFrame];
    dateLabel.font = [core nFont:@"Medium" size:10];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.clearsContextBeforeDrawing = YES;
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(228, 15, 70, 30)];
    [amountLabel setTextAlignment:NSTextAlignmentRight];
    amountLabel.font = [core nFont:@"Regular" size:18];
    NSString *amount = [NSString stringWithFormat:@"$%.02f", [[tableViewBind objectForKey:@"Amount"] floatValue]];
    amountLabel.text = amount;
    UILabel *action = [[UILabel alloc] initWithFrame:CGRectMake(70, 23, 180, 15)];
    action.font = [core nFont:@"Medium" size:14.0];
    if([tableViewBind objectForKey:@"image"] != NULL){
        iv.image = [UIImage imageWithData:[tableViewBind objectForKey:@"image"]];
    }else{
        NSArray *keys = [[[[me assos] objectForKey:@"people"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        bool found = NO;
        for (NSString *key in keys) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict = [[[me assos] objectForKey:@"people"] objectForKey:key];
            if ([[dict objectForKey:@"firstName"] isEqualToString:[tableViewBind objectForKey:@"FirstName"]] && [[dict objectForKey:@"lastName"] isEqualToString:[tableViewBind objectForKey:@"LastName"]]
                && [dict objectForKey:@"image"]) {
                iv.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
                found = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self userInfo:nil];
                break;
            }

        }
        if (!found)
            iv.image = [UIImage imageNamed:@"profile_picture.png"];
        
    }
    if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Sent"])
    {
        NSString *strMessageToAppend = @"You paid ";
        action.text = [strMessageToAppend stringByAppendingString:[tableViewBind objectForKey:@"FirstName"]];
        stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
        amountLabel.textColor = [core hexColor:@"bf4444"];
    }
    else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Received"])
    {
        NSString *strMessageToAppend = @" paid you";
        action.text = [[tableViewBind objectForKey:@"FirstName"] stringByAppendingString:strMessageToAppend];
        stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
        amountLabel.textColor = [core hexColor:@"72bf44"];

    }
    else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Request"])
    {
        if ([[tableViewBind objectForKey:@"RecepientId"] isEqualToString:[[me usr] objectForKey:@"MemberId"]]) { //I initiated request
            NSString *strMessageToAppend = @"You requested from ";
            action.text = [strMessageToAppend stringByAppendingString:[tableViewBind objectForKey:@"FirstName"]];
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            amountLabel.textColor = [core hexColor:@"007fb7"];
            if (![[tableViewBind objectForKey:@"Status"] isKindOfClass:[NSNull class]]) {
                if ([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Declined"]) {
                    amountLabel.font = [core nFont:@"Medium" size:12];
                    amountLabel.text = @"Ignored";
                    amountLabel.textColor = [core hexColor:@"bf4444"];

                }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                    amountLabel.font = [core nFont:@"Medium" size:12];
                    amountLabel.text = @"Cancelled";
                    amountLabel.textColor = [core hexColor:@"bf4444"];

                }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Success"]){
                    amountLabel.textColor = [core hexColor:@"72bf44"];

                }
            }
        }else{
            NSString *strMessageToAppend = @" requested from you";
            action.text = [[tableViewBind objectForKey:@"FirstName"] stringByAppendingString:strMessageToAppend];
            stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
            amountLabel.textColor = [core hexColor:@"007fb7"];
            if (![[tableViewBind objectForKey:@"Status"] isKindOfClass:[NSNull class]]) {
                if ([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Declined"]) {
                    amountLabel.font = [core nFont:@"Medium" size:12];
                    amountLabel.text = @"Ignored";
                    amountLabel.textColor = [core hexColor:@"bf4444"];

                }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                    amountLabel.font = [core nFont:@"Medium" size:12];
                    amountLabel.text = @"Cancelled";
                    amountLabel.textColor = [core hexColor:@"bf4444"];

                }else if([[tableViewBind objectForKey:@"Status"] isEqualToString:@"Success"]){
                    amountLabel.textColor = [core hexColor:@"bf4444"];

                }
            }
        }
    }

    else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Deposit"])
    {
        NSString *strMessageToAppend = @"Deposit into Nooch";

        stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *tranDate = [dateFormat dateFromString:[tableViewBind objectForKey:@"TransactionDate"]];
        NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
        double time1 = [time doubleValue];
        double timeSecond = [time2 doubleValue];
        double diff = time1 - timeSecond;
        amountLabel.textColor = [core hexColor:@"72bf44"];

        [dateFormat setDateFormat:@"EEEE"];
        NSString *day = [dateFormat stringFromDate:tranDate];
        if([day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"] || [day isEqualToString:@"Thursday"]){
            diff = diff-172800;
        }else if([day isEqualToString:@"Sunday"]){
            diff = diff - 86400;
        }
        if(diff < 172800){
            strMessageToAppend = @"Pending deposit into Nooch";
            amountLabel.textColor = [core hexColor:@"DDDD2A"];

        }
        action.text = strMessageToAppend;
        iv.image = userPic.image;
    }

    else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Withdraw"])
    {
        NSString *strMessageToAppend = @"Withdrawal from Nooch";
        stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *tranDate = [dateFormat dateFromString:[tableViewBind objectForKey:@"TransactionDate"]];
        NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
        int time1 = [time intValue];
        int  timeSecond = [time2 intValue];
        int diff = time1 - timeSecond;
        amountLabel.textColor = [core hexColor:@"bf4444"];

        if(diff < 172800){
            //strMessageToAppend = @"Pending withdrawal from Nooch";
            //amountLabel.textColor = [UIColor yellowColor];
            //action.font = [core nFont:@"Medium" size:12.0];
        }
        action.text = strMessageToAppend;
        iv.image = userPic.image;
    }
    else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Sent to"])
    {
        NSString *strMessageToAppend = @"You disputed ";
        action.text = [strMessageToAppend stringByAppendingString:[tableViewBind objectForKey:@"FirstName"]];
        stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
        amountLabel.textColor = [core hexColor:@"bf4444"];

    }
    else if([[tableViewBind objectForKey:@"TransactionType"] isEqualToString:@"Received from"])
    {
        NSString *strMessageToAppend = @" disputed you";
        action.text = [[tableViewBind objectForKey:@"FirstName"] stringByAppendingString:strMessageToAppend];
        stringFormattedDate=[NoochHelper dateTimeStamp:[tableViewBind objectForKey:@"TransactionDate"]];
        amountLabel.textColor = [core hexColor:@"72bf44"];

    }
    else{
        action.text = [tableViewBind objectForKey:@"Name"];
    }

    dateLabel.text = stringFormattedDate;
    [action setBackgroundColor:[UIColor clearColor]];
    [amountLabel setBackgroundColor:[UIColor clearColor]];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [cell.contentView addSubview:action];
    [cell.contentView addSubview:amountLabel];
    [cell.contentView addSubview:dateLabel];
    [cell.contentView addSubview:iv];
    if (![[tableViewBind objectForKey:@"Memo"] isKindOfClass:[NSNull class]]) {
        if ([[tableViewBind objectForKey:@"Memo"] length] != 0) {
            UILabel *tableMemo = [[UILabel alloc] initWithFrame:CGRectMake(72, 57, 210, 14)];
            UIImageView *hasMemo = [[UIImageView alloc] initWithFrame:CGRectMake(260, 55, 15, 14)];
            tableMemo.backgroundColor = [UIColor clearColor];
            tableMemo.font = [core nFont:@"Medium" size:12];
            if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0dm"].location != NSNotFound ) {
                if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                else tableMemo.text = @"";
                [hasMemo setImage:[UIImage imageNamed:@"Memo_Icon.png"]];
            }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0fm"].location != NSNotFound ) {
                [hasMemo setImage:[UIImage imageNamed:@"MemoIconFoodSelected.png"]];
                if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                else tableMemo.text = @"";
            }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0im"].location != NSNotFound ) {
                [hasMemo setImage:[UIImage imageNamed:@"MemoIconIOUselected.png"]];
                if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                else tableMemo.text = @"";
            }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0tm"].location != NSNotFound ) {
                [hasMemo setImage:[UIImage imageNamed:@"MemoIconTixSelected.png"]];
                if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                else tableMemo.text = @"";
            }else if ([[tableViewBind objectForKey:@"Memo"] rangeOfString:@"0um"].location != NSNotFound ) {
                [hasMemo setImage:[UIImage imageNamed:@"MemoIconUtilitiesSelected.png"]];
                if([[tableViewBind objectForKey:@"Memo"] length] !=3) tableMemo.text = [[tableViewBind objectForKey:@"Memo"] substringFromIndex:3];
                else tableMemo.text = @"";
            }else{
                [hasMemo setImage:[UIImage imageNamed:@"Memo_Icon.png"]];
                tableMemo.text = [tableViewBind objectForKey:@"Memo"];
            }
            if([tableMemo.text length] != 0) tableMemo.text = [NSString stringWithFormat:@"for \"%@\"",tableMemo.text];
            tableMemo.textColor = [UIColor grayColor];
            [cell.contentView addSubview:tableMemo];
            [cell.contentView addSubview:hasMemo];
        }
    }
    NSMutableString *compare = [[NSMutableString alloc] init];
    compare = [tableViewBind objectForKey:@"City"];
    NSMutableString *compare2 = [[NSMutableString alloc] init];
    compare2 = [tableViewBind objectForKey:@"State"];
    if((NSNull *)compare != [NSNull null] && (NSNull *)compare2 != [NSNull null] && [compare length] != 0 && [compare2 length] != 0){
        UIImageView *hasLocation = [[UIImageView alloc] initWithFrame:CGRectMake(280, 55, 12, 14)];
        [hasLocation setImage:[UIImage imageNamed:@"Map_Icon.png"]];
        [cell.contentView addSubview:hasLocation];
    }
    action.textColor = amountLabel.textColor;

    return cell;
}
-(void)loadMoreRecords
{
    load=0;
    index++;
    [me histMore:filterPick sPos:index len:20];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [navCtrl.view removeGestureRecognizer:self.slidingViewController.panGesture];
    if(tableView == detailsTable){
        [detailsTable deselectRowAtIndexPath:indexPath animated:YES];
        if(indexPath.row == 0){
            if(!bankTransfer) {
                return;
            }
        }else if(indexPath.row == 1){
            if(![disputeStatus.text isEqualToString:@"Not in Dispute"] && goDisputeButton.isHidden && ![statusOfTransfer.text isEqualToString:@"Requested"]){
                [self disputeDetails];
                return;
            }
        }
    }
    [self.view endEditing:YES];
    CGRect frame = detailsTable.frame;
    frame.size.height = 120;
    [detailsTable setFrame:frame];
    frame = transferDetails.frame;
    frame.origin.y = 53;
    transferDetails.frame = frame;
    requestBadgeName.hidden = YES;
    recipRequestBadge.hidden = YES;
    senderRequestBadge.hidden = YES;
    cancelledRequestBadge.hidden = YES;
    ignoreButton.hidden = YES;
    payButton.hidden = YES;
    cancelButton.hidden = YES;
    isRequest = NO;
    [historyTable deselectRowAtIndexPath:indexPath animated:YES];
    statusOfTransfer.text = @"Paid";
    navBar.topItem.title = @"Transfer Details";
    [leftNavBar setBackgroundImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [leftNavBar setFrame:CGRectMake(0, 0, 43, 43)];
    [leftNavBar removeTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [leftNavBar addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict = [[me histFilter:filterPick] objectAtIndex:indexPath.row];

    /////////asdf
    
    if ([[dict objectForKey:@"Status"] isKindOfClass:[NSNull class]]) {
        [dict setObject:@"Cancelled" forKey:@"Status"];
    }

    transactionId = [dict objectForKey:@"TransactionId"];
    recipId = [dict objectForKey:@"RecepientId"];
    sendId = [dict objectForKey:@"MemberId"];
    goDisputeButton.hidden = NO;
    dipusteNote.hidden = NO;
    disputeStatus.hidden = NO;
    bankTransfer = NO;
    [whichArrows setHighlighted:NO];
    bool cancelledReq = NO;

    NSArray *keys = [[[[me assos] objectForKey:@"people"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in keys) {
        NSMutableDictionary *dict2 = [NSMutableDictionary new];
        dict2 = [[[me assos] objectForKey:@"people"] objectForKey:key];
        if ([[dict2 objectForKey:@"firstName"] isEqualToString:[dict objectForKey:@"FirstName"]] && [[dict2 objectForKey:@"lastName"] isEqualToString:[dict objectForKey:@"LastName"]]
            && [dict2 objectForKey:@"image"]) {
            if([dict objectForKey:@"image"] == NULL) [dict setObject:[dict2 objectForKey:@"image"] forKey:@"image"];
            break;
        }

    }

    
    NSLog(@"hereFIRST");
    if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent"])
    {
        sender.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"firstName"] ,[dict objectForKey:@"LastName"] ];
        if([dict objectForKey:@"image"] != NULL) secondPartyImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        else secondPartyImage.image = [UIImage imageNamed:@"profile_picture.png"];
        youImage.image = userPic.image;
    }

    

    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"])
    {
        recipient.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
        if([dict objectForKey:@"image"] != NULL) youImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        else youImage.image = [UIImage imageNamed:@"profile_picture.png"];
        secondPartyImage.image = userPic.image;
        goDisputeButton.hidden = YES;
        dipusteNote.hidden = YES;
        NSLog(@"here");
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"])
    {
        [whichArrows setHighlighted:YES];
        if ([[dict objectForKey:@"Status"] isEqualToString:@"Pending"]) {
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            cancelButton.hidden = NO;
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Declined"]){
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            requestBadgeName.hidden = NO;
            recipRequestBadge.hidden = NO;
            senderRequestBadge.hidden = NO;
            recipRequestBadge.highlighted = YES;
            senderRequestBadge.highlighted = YES;
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            cancelledReq = YES;
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            requestBadgeName.hidden = NO;
            recipRequestBadge.highlighted = YES;
            senderRequestBadge.highlighted = YES;
            cancelledRequestBadge.hidden = NO;
            recipRequestBadge.highlighted = YES;
            senderRequestBadge.highlighted = YES;
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            cancelledReq = YES;
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else{
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            recipRequestBadge.highlighted = NO;
            senderRequestBadge.highlighted = NO;
            recipRequestBadge.hidden = NO;
            senderRequestBadge.hidden = NO;
            requestBadgeName.hidden = NO;
            statusOfTransfer.text = @"Requested";
        }
        if ([[dict objectForKey:@"RecepientId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]) { //I initiated request
            recipRequestBadge.hidden = YES;
            cancelledRequestBadge.highlighted = YES;
            if (isRequest && cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]) {
                requestBadgeName.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FirstName"]];
            }else if(!isRequest && !cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                requestBadgeName.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FirstName"]];
            }else{
                requestBadgeName.text = @"";
            }
            sender.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
            recipient.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
            if([dict objectForKey:@"image"] != NULL) secondPartyImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
            else secondPartyImage.image = [UIImage imageNamed:@"profile_picture.png"];
            youImage.image = userPic.image;
        }else{
            cancelledRequestBadge.highlighted = NO;
            senderRequestBadge.hidden = YES;
            cancelButton.hidden = YES;
            if (!cancelledReq) {
                ignoreButton.hidden = NO;
                payButton.hidden = NO;
            }
            if ([[dict objectForKey:@"Status"] isEqualToString:@"Success"]) {
                ignoreButton.hidden = YES;
                payButton.hidden = YES;
                
            }
            if (isRequest && cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]) {
                requestBadgeName.text = [NSString stringWithFormat:@""];
            }else if(!isRequest && !cancelledReq && ![[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
                requestBadgeName.text = [NSString stringWithFormat:@""];
            }else{
                requestBadgeName.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FirstName"]];
            }
            recipient.text = [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
            sender.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
            if([dict objectForKey:@"image"] != NULL) youImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
            else youImage.image = [UIImage imageNamed:@"profile_picture.png"];
            secondPartyImage.image = userPic.image;
        }
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Deposit"])
    {
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        sender.text = @"Bank\nAccount";
        secondPartyImage.image = userPic.image;
        youImage.image = [UIImage imageNamed:@"Blue_Bank_Icon.png"];
        bankTransfer = YES;

        NSString *stringFormattedDate = [[NSString alloc] init];
        stringFormattedDate = @"";
        NSString *strMessageToAppend = @"Deposit into Nooch";
        stringFormattedDate=[NoochHelper dateTimeStamp:[dict objectForKey:@"TransactionDate"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *tranDate = [dateFormat dateFromString:[dict objectForKey:@"TransactionDate"]];
        NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
        double time1 = [time doubleValue];
        double timeSecond = [time2 doubleValue];
        double diff = time1 - timeSecond;
        [dateFormat setDateFormat:@"EEEE"];
        NSString *day = [dateFormat stringFromDate:tranDate];
        if([day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"] || [day isEqualToString:@"Thursday"]){
            diff = diff-172800;
        }else if([day isEqualToString:@"Sunday"]){
            diff = diff - 86400;
        }
        if(diff < 172800){
            strMessageToAppend = @"Submitted";
            memo.textColor = [core hexColor:@"DDDD2A"];
        }else{ strMessageToAppend = @"Completed"; memo.textColor = [core hexColor:@"99CC66"];}
        memo.text = strMessageToAppend;
        statusOfTransfer.text = memo.text;
    }

    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Withdraw"])
    {
        youImage.image = userPic.image;
        secondPartyImage.image = [UIImage imageNamed:@"Blue_Bank_Icon.png"];
        recipient.text = @"Bank\nAccount";
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        memo.text = @"Pending";
        memo.textColor = [core hexColor:@"99CC66"];
        statusOfTransfer.text = @"Pending";
        bankTransfer = YES;

        NSString *stringFormattedDate = [[NSString alloc] init];
        stringFormattedDate = @"";
        NSString *strMessageToAppend = @"Deposit into Nooch";
        stringFormattedDate=[NoochHelper dateTimeStamp:[dict objectForKey:@"TransactionDate"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *tranDate = [dateFormat dateFromString:[dict objectForKey:@"TransactionDate"]];
        NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        NSString *time2 = [NSString stringWithFormat:@"%ld",(long)[tranDate timeIntervalSince1970]];
        double time1 = [time doubleValue];
        double timeSecond = [time2 doubleValue];
        double diff = time1 - timeSecond;
        [dateFormat setDateFormat:@"EEEE"];
        NSString *day = [dateFormat stringFromDate:tranDate];
        if([day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"] || [day isEqualToString:@"Thursday"]){
            diff = diff-172800;
        }else if([day isEqualToString:@"Sunday"]){
            diff = diff - 86400;
        }
        if(diff < 172800){
            strMessageToAppend = @"Pending";
            memo.textColor = [core hexColor:@"DDDD2A"];
        }else{ strMessageToAppend = @"Completed"; memo.textColor = [core hexColor:@"99CC66"];}
        memo.text = strMessageToAppend;
        statusOfTransfer.text = memo.text;
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent to"])
    {
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
        if([dict objectForKey:@"image"] != NULL) secondPartyImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        youImage.image = userPic.image;
    }
    else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received from"])
    {
        sender.text =  [NSString stringWithFormat:@"%@ \n%@",[dict objectForKey:@"FirstName"] ,[dict objectForKey:@"LastName"] ];
        recipient.text =  [NSString stringWithFormat:@"%@ \n%@",firstNamehist.text,lastNamehist.text];
        if([dict objectForKey:@"image"] != NULL) youImage.image = [UIImage imageWithData:[dict objectForKey:@"image"]];
        else youImage.image = [UIImage imageNamed:@"profile_picture.png"];
        secondPartyImage.image = userPic.image;
        goDisputeButton.hidden = YES;
        dipusteNote.hidden = YES;
    }
    NSString *amount = [NSString stringWithFormat:@"$%.02f", [[dict objectForKey:@"Amount"] floatValue]];
    transerAmount.text = amount;
    date.text = [NSString stringWithFormat:@"       %@           %@",[NoochHelper hourMinuteAP:[dict objectForKey:@"TransactionDate"]],[NoochHelper dayMonthYear:[dict objectForKey:@"TransactionDate"]]];
    NSMutableString *compare = [[NSMutableString alloc] init];
    compare = [dict objectForKey:@"City"];
    NSMutableString *compare2 = [[NSMutableString alloc] init];
    compare2 = [dict objectForKey:@"State"];
    NSString *cityName = [dict objectForKey:@"City"];
    if((NSNull *)compare != [NSNull null] && (NSNull *)compare2 != [NSNull null] && [compare length] != 0 && [compare2 length] != 0)
        location.text = [NSString stringWithFormat:@"%@, %@",cityName,[dict objectForKey:@"State"]];
    else
        location.text = @"Not Shared";

    compare = [dict objectForKey:@"DisputeStatus"];
    if((NSNull *)compare == [NSNull null] || [dict objectForKey:@"DisputeStatus"] == NULL){
        //goDisputeButton.hidden = NO;
        dipusteNote.hidden = NO;
        disputeStatus.text = @"";
        if( [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received from"] || [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"] ){
            disputeStatus.text = @"Not in Dispute";
            disputeStatus.textColor = [core hexColor:@"99CC66"];
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
        }
    }else if([compare isEqualToString:@"Resolved"]){
        goDisputeButton.hidden = YES;
        dipusteNote.hidden = YES;
        disputeStatus.text = @"Resolved";
        disputeStatus.textColor = dispStatus.textColor = [core hexColor:@"99CC66"];
        disputeDetailsButton.userInteractionEnabled = YES;
        dispStatus.text = [dict objectForKey:@"DisputeStatus"];
        dispId.text = [dict objectForKey:@"DisputeId"];
        dispDate.text = [[dict objectForKey:@"DisputeReportedDate"] substringToIndex:10];
        compare = [dict objectForKey:@"DisputeResolvedDate"];
        if((NSNull *)compare != [NSNull null])
            resDate.text = [[dict objectForKey:@"DisputeResolvedDate"] substringToIndex:10];
        else
            resDate.text = @"";
        compare = [dict objectForKey:@"DisputeReviewDate"];
        if((NSNull *)compare != [NSNull null])
            reviewDate.text = [[dict objectForKey:@"DisputeReviewDate"] substringToIndex:10];
        else
            reviewDate.text = @"";

        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280,186,7,10)];
        arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
    }else{
        goDisputeButton.hidden = YES;
        dispStatus.textColor = [core hexColor:@"bf4444"];
        dispStatus.text = [dict objectForKey:@"DisputeStatus"];
        dispId.text = [dict objectForKey:@"DisputeId"];
        if([dict objectForKey:@"DIsputeReportedDate"] != NULL)
            dispDate.text = [[dict objectForKey:@"DisputeReportedDate"] substringToIndex:10];
        compare = [dict objectForKey:@"DisputeResolvedDate"];
        if((NSNull *)compare == [NSNull null])
            resDate.text = [[dict objectForKey:@"DisputeResolvedDate"] substringToIndex:10];
        else
            resDate.text = @"";
        compare = [dict objectForKey:@"DisputeReviewDate"];
        if((NSNull *)compare == [NSNull null])
            reviewDate.text = [[dict objectForKey:@"DisputeReviewDate"] substringToIndex:10];
        else
            reviewDate.text = @"";

        disputeDetailsButton.userInteractionEnabled = YES;
        disputeStatus.text = [dict objectForKey:@"DisputeStatus"];
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280,193,7,10)];
        arrow.image = [UIImage imageNamed:@"ArrowGrey.png"];
        disputeStatus.textColor = [core hexColor:@"bf4444"];
        if( [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received from"] || [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"] ){
            disputeStatus.text = @"Not in Dispute";
            disputeStatus.textColor = [core hexColor:@"99CC66"];
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
        }
    }
    if (!bankTransfer) {
        if (![[dict objectForKey:@"Memo"] isKindOfClass:[NSNull class]]) {
            if ([[dict objectForKey:@"Memo"] length] != 0) {
                curMemo = [dict objectForKey:@"Memo"];
                if ([curMemo rangeOfString:@"0dm"].location != NSNotFound ) {
                    if([curMemo length] != 3) memo.text = [curMemo substringFromIndex:3];
                    else memo.text = @"";
                }else if ([curMemo rangeOfString:@"0fm"].location != NSNotFound ) {
                    if([curMemo length] != 3) memo.text = [curMemo substringFromIndex:3];
                    else memo.text = @"";
                }else if ([curMemo rangeOfString:@"0im"].location != NSNotFound ) {
                    if([curMemo length] != 3) memo.text = [curMemo substringFromIndex:3];
                    else memo.text = @"";
                }else if ([curMemo rangeOfString:@"0tm"].location != NSNotFound ) {
                    if([curMemo length] != 3) memo.text = [curMemo substringFromIndex:3];
                    else memo.text = @"";
                }else if ([curMemo rangeOfString:@"0um"].location != NSNotFound ) {
                    if([curMemo length] != 3) memo.text = [curMemo substringFromIndex:3];
                    else memo.text = @"";
                }else{
                    memo.text = curMemo;
                }
                memo.textColor = [core hexColor:@"006699"];
                if([memo.text length] != 0)memo.text = [NSString stringWithFormat:@"for \"%@\"",memo.text];
                else{ memo.text = @"No memo attached"; memo.textColor = [UIColor grayColor];}
            }else{
                memo.text = @"No memo attached";
                memo.textColor = [UIColor grayColor];
            }
        }else{
            memo.text = @"No memo attached";
            memo.textColor = [UIColor grayColor];
        }
    }
    filterButton.hidden = YES;
    CGRect inFrame = [transferDetails frame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    inFrame.origin.x -=320;
    [transferDetails setFrame:inFrame];
    inFrame = historyTable.frame;
    inFrame.origin.x -=320;
    [historyTable setFrame:inFrame];
    [UIView commitAnimations];
    [self.detailsTable reloadData];
    CGRect tranFrame;
    receiverFirst = [dict objectForKey:@"FirstName"];
    receiverLast = [dict objectForKey:@"LastName"];
    NSLog(@"hereee");
    receiverImgData = [dict objectForKey:@"image"];
    if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent"]){
        receiverId = [dict objectForKey:@"RecepientId"];
        tranFrame = secondPartyImage.frame;
        tranFrame.size.height += 50;
        startNewTransfer.userInteractionEnabled = YES;
    }else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"]){
        receiverId = [dict objectForKey:@"MemberId"];
        tranFrame = youImage.frame;
        tranFrame.size.height += 50;
        startNewTransfer.userInteractionEnabled = YES;
    }else if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"]){
        if ([[dict objectForKey:@"RecepientId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]])
            tranFrame = secondPartyImage.frame;
        else
            tranFrame = youImage.frame;
        startNewTransfer.userInteractionEnabled = YES;
        if ([[dict objectForKey:@"Status"] isEqualToString:@"Pending"]) {
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.text = @"Not in Dispute";
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Cancelled"]){
            frame = transferDetails.frame;
            frame.origin.y = 95;
            transferDetails.frame = frame;
            requestBadgeName.hidden = NO;
            recipRequestBadge.hidden = YES;
            senderRequestBadge.hidden = YES;
            cancelledRequestBadge.hidden = NO;
            recipRequestBadge.highlighted = YES;
            senderRequestBadge.highlighted = YES;
            CGRect frame = detailsTable.frame;
            frame.size.height = 80;
            [detailsTable setFrame:frame];
            isRequest = YES;
            statusOfTransfer.text = @"Requested";
            cancelledReq = YES;
            cancelButton.hidden = YES;
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
            disputeStatus.hidden = YES;
        }else if([[dict objectForKey:@"Status"] isEqualToString:@"Declined"]){
            goDisputeButton.hidden = YES;
            dipusteNote.hidden = YES;
        }
    }
    startNewTransfer.frame = tranFrame;
    [mapView_ removeFromSuperview];
    if (![[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"] || ([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"] && ![[dict objectForKey:@"Status"] isEqualToString:@"Pending"])) {
        if ([[dict objectForKey:@"Latitude"] doubleValue] == 0 || [[dict objectForKey:@"Longitude"] doubleValue] == 0) {
            return;
        }
        double lat = [[dict objectForKey:@"Latitude"] doubleValue];
        double lon = [[dict objectForKey:@"Longitude"] doubleValue];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                                longitude:lon
                                                                     zoom:13];
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(-1, transferDetails.bounds.size.height-50, 322, 190) camera:camera];
        if ([UIScreen mainScreen].bounds.size.height==480) {
            CGRect frame = mapView_.frame;
            if (!isRequest || details4){
                frame.origin.y = transferDetails.bounds.size.height-50;
                frame.size.height = 100;
            }else{
                frame.origin.y = transferDetails.bounds.size.height-100;
                frame.size.height = 100;
            }
            
            [mapView_ setFrame:frame];
        }
        mapView_.myLocationEnabled = YES;
        mapView_.layer.borderWidth = 1;
        mapView_.layer.borderColor = [core hexColor:@"808080"].CGColor;
        [transferDetails addSubview:mapView_];

        // Creates a marker in the center of the map.
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lat, lon);
        //marker.title = @"Sydney";
        //marker.snippet = @"Australia";
        marker.map = mapView_;
    }

    [detailsTable reloadData];

    NSLog(@"selected transaction: %@",transactionId); //zIqcoIHnEeK3PfBNogOYmg
}

#pragma mark - searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    histSearch = NO;
    isSearching = NO;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    [historyTable setContentOffset:CGPointMake(0, 44)];
    [searchBar setShowsCancelButton:NO];
    newTransfersDecrement = newTransfers;
    [self.historyTable reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
    //newTransfersDecrement = newTransfers;
    [self.historyTable reloadData];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    histSearch = YES;
    [searchBarObj becomeFirstResponder];
   // [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length]>0) {
        histSearching = searchText;
        isSearching = YES;
        [self searchTableView];
        [self.historyTable reloadData];
    }
    else{
        isSearching=NO;
    [self.historyTable reloadData];
    }
}

#pragma mark - disputing
-(void) raiseDispute:(NSString *)raiseDispute idvalue:(NSString*)idvalue MemID:(NSString*)MemID recepientId:(NSString*)recepientId recepientIdValue:(NSString*)recepientIdValue txnId:(NSString*)txnId txnIdValue:(NSString*)txnIdValue listType:(NSString*)listType listTypeValue:(NSString*)listTypeValue{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&%@=%@&%@=%@", MyUrl, raiseDispute, idvalue, MemID, recepientId, recepientIdValue, txnId, txnIdValue, listType, listTypeValue]]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}
- (IBAction)okDisputeDetails:(id)sender {
    [self goBackDetails];
}
- (void)disputeDetails {
    disputeDetailsView.hidden = NO;
    CGRect inFrame = [disputeDetailsView frame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    inFrame.origin.x = 0;
    [disputeDetailsView setFrame:inFrame];
    inFrame = transferDetails.frame;
    inFrame.origin.x = -320;
    [transferDetails setFrame:inFrame];
    [UIView commitAnimations];
    //transferDetails.hidden = YES;
    navBar.topItem.title = @"Dispute Details";
    [leftNavBar removeTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [leftNavBar addTarget:self action:@selector(goBackDetails) forControlEvents:UIControlEventTouchUpInside];
}
-(IBAction)disputeTransfer:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to dispute this transfer? Your account will be suspended while we investigate." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:1];
}

# pragma mark - NSURLConnection Delegate Methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSLog(@"server response %@",responseString);
    NSMutableArray *loginResult = [responseString JSONValue];
    NSMutableDictionary *res = [responseString JSONValue];
    NSMutableArray *tempHistArray = [[NSMutableArray alloc] init];
    if ([loginResult count] != 0){
        if(!disputing){
            tempHistArray = [[NSMutableArray alloc] initWithArray:loginResult];
            NSMutableArray *tempArray = [me hist];
            NSDictionary *tDict = [tempArray lastObject];
            NSString *tId = [tDict objectForKey:@"TransactionId"];
            if(updateHistory){ //new user-generated transaction (aka sent money or bank interaction)
                //[self performSelectorInBackground:@selector(processNew:) withObject:tempHistArray];
                updateHistory = NO;
                return;
            }
            if([tId isEqualToString:[[tempHistArray objectAtIndex:0] objectForKey:@"TransactionId"]] || [tId isEqualToString:[[tempHistArray lastObject] objectForKey:@"TransactionId"]]){
                NSLog(@"hit limit");
                limit = YES;
                newTransfersDecrement = newTransfers;
                [self.historyTable reloadData];
                return;
            }
            //[self performSelectorInBackground:@selector(processNew:) withObject:tempHistArray];
        }else{
            NSString *resultValue = [res objectForKey:@"RaiseDisputeResult"];
            [me endWaitStat];
            if ([resultValue valueForKey:@"Result"]) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Welp" message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [av setTag:5];
                disputing = NO;
                [me histPoll];
            }
        }
    }else{
        if(!disputing){
            limit = YES;
        }else{
            NSString *resultValue = [res objectForKey:@"RaiseDisputeResult"];
            [me endWaitStat];
            if ([resultValue valueForKey:@"Result"]) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Welp" message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [av setTag:5];
            }else{
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Welp" message:@"Transaction disputed, as a precaution you won't be able to Nooch people until it is resolved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [av setTag:15];
                for (NSDictionary *dict in [me histFilter:@"ALL"]) {
                    if ([transactionId isEqualToString:[dict objectForKey:@"TransactionId"]]) {
                        NSLog(@"found transaction");
                        [self applyUpdateToDetails:[dict mutableCopy]];
                        [me waitStat:@"Updating details..."];
                        break;
                    }
                }
            }
            
            disputing = NO;
            [me histUpdate];
        }
    }
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#pragma mark - filtering
-(void)showActionSheet:(id)sender{
    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = nil;
    fp =  [[FPPopoverController alloc] initWithViewController:popOver];
    fp.border = NO;
    fp.tint = FPPopoverWhiteTint;
    fp.arrowDirection = FPPopoverArrowDirectionUp;
    fp.contentSize = CGSizeMake(200, 355);
    [fp presentPopoverFromPoint:CGPointMake(280, 45)];
}
-(void)dismissFP:(NSNotification *)notification{
    [fp dismissPopoverAnimated:YES];
    needsUpdating = YES;
    newTransfers = 0;
    isSearching=YES;
    arrSearchedRecords=[[NSMutableArray alloc]init];
    NSLog(@"%@",filterPick);
    if ([filterPick isEqualToString:@"CANCEL"]) {
        isSearching=NO;
    }
    else{
    for (NSDictionary*dict in oldRecordsArray) {
        if (![filterPick isEqualToString:@"ALL"] ) {
            if ([[[dict valueForKey:@"TransactionType"] uppercaseString]isEqualToString:filterPick]) {
                [arrSearchedRecords addObject:dict];
            }
        }
        else
            [arrSearchedRecords addObject:dict];
    }
        if ([arrSearchedRecords count]==0) {
            [arrSearchedRecords addObject:@"No Records"];
        }
    }
    [self.historyTable reloadData];
    [me endWaitStat];
    
}

#pragma mark - alert view delegation
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([actionSheet tag] == 1)
    {
        if(buttonIndex == 0)
        {
            [self.view addSubview:[me waitStat:@"Processing your dispute request..."]];
            disputing = YES;
            NSString *type = [[NSString alloc] init];
            if([recipient.text isEqualToString:@"You"]){
                type = @"RECEIVED";
            }else{
                type = @"SENT";
            }
            respData = [[NSMutableData alloc] init];
            NSString *subjectLine = @"Confirmation mail for disputing transaction.";
            NSString *bodyText = [NSString stringWithFormat:@"%@%@",@"Dispute raised with transaction ID : ",transactionId];

            NSDictionary *disputInfo = [NSDictionary dictionaryWithObjectsAndKeys: sendId, @"MemberId", recipId, @"RecepientId", transactionId, @"TransactionId", type, @"ListType", @"", @"CcMailIds", @"", @"BccMailIds", subjectLine, @"Subject", bodyText, @"BodyText", nil];

            NSDictionary *disputeInput = [NSDictionary dictionaryWithObjectsAndKeys: disputInfo, @"raiseDisputeInput",@"accessToken",[[NSUserDefaults standardUserDefaults] stringForKey:@"OAuthToken"], nil];

            NSLog(@"DisputeInput %@", disputeInput);

            NSString *post = [disputeInput JSONRepresentation];
            NSLog(@"Json value : %@", post);

            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

            respData = [NSMutableData data];

            NSString *urlStr = [[NSString alloc] initWithString:MyUrl];
            urlStr = [urlStr stringByAppendingFormat:@"/%@", @"RaiseDispute"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSLog(@"URL %@", url);

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"POST"];

            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (connection)   {
                respData = [NSMutableData data];
            }
        }
    }else if([actionSheet tag] == 5){
        [self goBack];
    }else if([actionSheet tag] == 13){
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        [self emailSupport];
    }
    else if (actionSheet.tag == 11)
    {
        if (buttonIndex == 0) {
            NSLog(@"Cancelled");
        }
        else
        {
            NSString * email = [[actionSheet textFieldAtIndex:0] text];
            serve * s = [[serve alloc] init];
            [s sendCsvTrasactionHistory:email];
        }
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
    [self presentViewController:mailComposer animated:YES completion:nil];
    //[self presentModalViewController:mailComposer animated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
   // [self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultSent) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Thanks for Contacting Us" message:@"Our detectives will get the case." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

#pragma mark - memo's
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 30) ? NO : YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

#pragma mark - filepaths
-(NSString *)userMemos{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-memos.plist",[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"]]];

}
//edit by venturepact
- (IBAction)ShowMap:(id)sender {
    AllMapViewController * map = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    //sending the map View Controller the pointers to be placed
    [map setPointsList:mapArrays];
    [self.navigationController pushViewController:map animated:YES];
}

#pragma mark Exporting History
- (IBAction)ExportHistory:(id)sender {
    
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter email ID" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 11;
    [alert show];
    
}
#pragma mark - unloading and memory
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setUserPic:nil];
    [self setFirstNamehist:nil];
    [self setLastNamehist:nil];
    [self setBalance:nil];
    [self setHistoryTable:nil];
    [self setSpinner:nil];
    [self setBlankLabel:nil];
    [self setTransferDetails:nil];
    [self setSender:nil];
    [self setRecipient:nil];
    [self setTranserAmount:nil];
    [self setDate:nil];
    [self setLocation:nil];
    [self setDisputeStatus:nil];
    [self setMemo:nil];
    [self setDisputeDetailsView:nil];
    [self setDispStatus:nil];
    [self setDispDate:nil];
    [self setDispId:nil];
    [self setReviewDate:nil];
    [self setResDate:nil];
    [self setDisputeRequest:nil];
    [self setDisputeSubject:nil];
    [self setDisputeMessage:nil];
    [self setDisputeDetailsButton:nil];
    [self setGoDisputeButton:nil];
    [self setDipusteNote:nil];
    [self setDetailsTable:nil];
    [self setYouImage:nil];
    [self setSecondPartyImage:nil];
    [self setStatusOfTransfer:nil];
    payButton = nil;
    ignoreButton = nil;
    cancelButton = nil;
    recipRequestBadge = nil;
    senderRequestBadge = nil;
    requestBadgeName = nil;
    whichArrows = nil;
    userBar = nil;
    cancelledRequestBadge = nil;
    navBar = nil;
    leftNavBar = nil;
    filterButton = nil;
    [super viewDidUnload];
}





@end
