//
//  self.m
//  Nooch
//
//  Created by Preston Hults on 1/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "assist.h"
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"

@implementation assist
@synthesize arrRecordsCheck;

NSString *responseStringForHis;
NSMutableArray *newHistForHis;
NSString *urlForHis;
NSMutableURLRequest *requestForHis;
NSURLConnection *connectionForHis;
NSString *whichPing;
NSString *endTransId;
NSString *oldFilter;
NSMutableDictionary *objModel;
NSMutableDictionary *dictsort;
@synthesize fbAllowed,twitterAllowed,facebookAccount,accountStore,twitterAccount;
static assist * _sharedInstance = nil;

+ (assist *)shared
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}
-(UIImage*)getTranferImage
{
    return imageOBJFortransfer;
}
-(void)setTranferImage:(UIImage*)image
{
    imageOBJFortransfer=image;
}

-(BOOL)isloggedout
{
    return islogout;
}
-(void)setisloggedout:(BOOL)islog
{
    islogout=islog;
}


-(void)birth{/*{{{*/
    limit = NO; oldFilter = @""; needsUpdating = YES;
    sortedHist = [NSMutableArray new];
    usr = [NSMutableDictionary new];
    histCache = [NSMutableArray new];
    pic = [NSMutableData new];
    assosciateCache = [NSMutableDictionary new];
    if ([self isAlive:[self path:@"currentUser"]]) {
        archivedData = [NSMutableData dataWithContentsOfFile:[self path:@"currentUser"]];
    }
    @try {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedData];
        usr = [NSMutableDictionary dictionaryWithDictionary:[unarchiver decodeObjectForKey:@"core"]];
        pic = [NSMutableData dataWithData:[unarchiver decodeObjectForKey:@"pic"]];
        //histCache = [NSMutableArray arrayWithArray:[unarchiver decodeObjectForKey:@"hist"]];
        assosciateCache = [NSMutableDictionary dictionaryWithDictionary:[unarchiver decodeObjectForKey:@"asso"]];
        [unarchiver finishDecoding];
    }
    @catch (NSException *exception) {
        NSLog(@"got an error... %@",exception);
    }
    @finally {

    }
    if (![usr objectForKey:@"firstName"]) {
        [usr setObject:@" " forKey:@"firstName"];
    }
    if (![usr objectForKey:@"lastName"]) {
        [usr setObject:@" " forKey:@"lastName"];
    }
    if (pic == NULL) {
        [self fetchPic];
    }else if([pic length] == 0){
        [self fetchPic];
    }
    [usr setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] forKey:@"email"];
    NSLog(@"user object: %@",usr);
    accountStore = [[ACAccountStore alloc] init];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        facebookAccount = nil;
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"198279616971457",
                                  ACFacebookPermissionsKey: @[@"email",@"user_about_me"],
                                  ACFacebookAudienceKey: ACFacebookAudienceFriends
                                  };

        [accountStore requestAccessToAccountsWithType:facebookAccountType
                                              options:options completion:^(BOOL granted, NSError *e)
         {
             if (granted)
             {
                 NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                 
                 facebookAccount = [accounts lastObject];
                 fbAllowed = YES;
                 [self renewFb];
                 NSLog(@"fb connected");
             }
             else
             {
                 // Handle Failure
                 fbAllowed = NO;
                 NSLog(@"fb not connected");
             }
         }];

        
    }else{
        fbAllowed = NO;
    }

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        twitterAccount = nil;
        [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *e){
            if (granted) {
                NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
                twitterAccount = [accounts lastObject];
                twitterAllowed = YES;
                NSLog(@"twitter granted");
            }else{
                twitterAllowed = NO;
                NSLog(@"twitter not granted");
            }
        }];
    }

   timer= [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getAcctInfo) userInfo:nil repeats:YES];
    [self getBanks];
    [self getCards];
    [self getSettings];
}/*}}}*/
-(void)renewFb{
    [accountStore renewCredentialsForAccount:(ACAccount *)facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error){
        if(!error)
        {
            switch (renewResult) {
                case ACAccountCredentialRenewResultRenewed:
                    break;
                case ACAccountCredentialRenewResultRejected:
                    NSLog(@"User declined permission");
                    break;
                case ACAccountCredentialRenewResultFailed:
                    NSLog(@"non-user-initiated cancel, you may attempt to retry");
                    break;
                default:
                    break;
            }
        }
        else{
            //handle error gracefully
            NSLog(@"error from renew credentials%@",error);
        }
    }];
}
-(void)stamp{/*{{{*/
    if (!histSafe) {
        return;
    }
    NSLog(@"saving user object");
    if ([usr objectForKey:@"PhotoUrl"] != NULL && [pic isKindOfClass:[NSNull class]]) {
        NSURL *photoUrl=[[NSURL alloc]initWithString:[usr objectForKey:@"PhotoUrl"]];
        pic = [NSMutableData dataWithContentsOfURL:photoUrl];
        if ([pic isKindOfClass:[NSNull class]]) {
            NSLog(@"pic is null...");
        }else{
            NSLog(@"downloaded pic successfully");
        }
    }
    [usr setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
    NSMutableDictionary *usrB = [NSMutableDictionary new];
    NSMutableData *picB = [NSMutableData new];
    //NSMutableArray *histB = [NSMutableArray new];
    NSMutableDictionary *assosB = [NSMutableDictionary new];
    if ([self isAlive:[self path:@"currentUser"]]) {
        archivedData = [NSMutableData dataWithContentsOfFile:[self path:@"currentUser"]];
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedData];
    usrB = [NSMutableDictionary dictionaryWithDictionary:[unarchiver decodeObjectForKey:@"core"]];
    picB = [NSMutableData dataWithData:[unarchiver decodeObjectForKey:@"pic"]];
    //histB = [NSMutableArray arrayWithArray:[unarchiver decodeObjectForKey:@"hist"]];
    assosB = [NSMutableDictionary dictionaryWithDictionary:[unarchiver decodeObjectForKey:@"asso"]];
    [unarchiver finishDecoding];
    @try {
        archivedData = [NSMutableData new];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archivedData];
        [archiver encodeObject:usr forKey:@"core"];
        [archiver encodeObject:pic forKey:@"pic"];
        //[archiver encodeObject:histCache forKey:@"hist"];
        [archiver encodeObject:assosciateCache forKey:@"asso"];
        [archiver finishEncoding];
        [archivedData writeToFile:[self path:@"currentUser"] atomically:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"failed saving, was updating during attempt,reverting to last save");
        archivedData = [NSMutableData new];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archivedData];
        [archiver encodeObject:usrB forKey:@"core"];
        [archiver encodeObject:picB forKey:@"pic"];
        //[archiver encodeObject:histB forKey:@"hist"];
        [archiver encodeObject:assosB forKey:@"asso"];
        [archiver finishEncoding];
        [archivedData writeToFile:[self path:@"currentUser"] atomically:YES];
    }
    @finally {
        NSLog(@"done saving");
    }
    
}/*}}}*/
-(void)fetchPic{/*{{{*/
    //NSLog(@"photourl %@",[usr objectForKey:@"PhotoUrl"]);
    if ([usr objectForKey:@"PhotoUrl"] != NULL) {
        if ([[usr objectForKey:@"PhotoUrl"] rangeOfString:@"gv_no_photo"].location == NSNotFound ) {
            NSURL *photoUrl=[[NSURL alloc]initWithString:[usr objectForKey:@"PhotoUrl"]];
            pic = [NSMutableData dataWithContentsOfURL:photoUrl];
        }
        if (pic == NULL) {
            NSLog(@"pic is null...");
        }else{
            if ([pic length] != 0) {
                NSLog(@"downloaded pic successfully");
            }
        }
    }
}/*}}}*/
-(void)death:(NSString *)path{/*{{{*/
    NSFileManager *dfm = [NSFileManager defaultManager];
    [dfm removeItemAtPath:path error:nil];
}/*}}}*/
-(NSMutableArray*)allHist{/*{{{*/
    return histCache;
}/*}}}*/
-(void)histPoll{
    histSafe=NO;
  responseData = [NSMutableData data];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    
    
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&listType=%@&%@=%@&%@=%@&accessToken=%@", MyUrl, @"GetTransactionsList", [usr objectForKey:@"MemberId"], @"ALL", @"pSize", [NSString stringWithFormat:@"%d",[histCache count]], @"pIndex", @"1",[defaults valueForKey:@"OAuthToken"]]]];
  [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)histUpdate{
    histSafe=NO;
     NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
   responseData = [NSMutableData data];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&listType=%@&%@=%@&%@=%@&accessToken=%@", MyUrl, @"GetTransactionsList", [usr objectForKey:@"MemberId"], @"ALL", @"pSize", @"20", @"pIndex", @"1",[defaults valueForKey:@"OAuthToken"]]]];
  [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len{
    histSafe=NO;
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    responseData = [NSMutableData data];
    urlForHis = [NSString stringWithFormat:@"%@"@"/%@?memberId=%@&listType=%@&%@=%@&%@=%@&accessToken=%@", MyUrl, @"GetTransactionsList", [usr objectForKey:@"MemberId"], type, @"pSize", [NSString stringWithFormat:@"%d",len], @"pIndex", [NSString stringWithFormat:@"%d",sPos],[defaults valueForKey:@"OAuthToken"]];
    NSLog(@"more hist %@",type);
    requestForHis = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlForHis]];
  connectionForHis=[[NSURLConnection alloc] initWithRequest:requestForHis delegate:self];
    if (!connectionForHis) {
        NSLog(@"failed to connect for history");
    }
}
-(NSMutableArray*)histFilter:(NSString*)filterPick{
    if (!histSafe) {
        return sortedHist; 
    }
    if (!needsUpdating && [histSearching isEqualToString:@""]) {
        return sortedHist;
    }
    NSMutableArray *histCopy = [[self hist] mutableCopy];
    NSMutableArray *tempHistArray = [NSMutableArray new];
    if([filterPick isEqualToString:@"DISPUTED"]){
        for(NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent to"] || [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received from"]){
                [tempHistArray addObject:dict];
            }
        }
    }else if([filterPick isEqualToString:@"DEPOSIT"]){
        for(NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Deposit"]){
                [tempHistArray addObject:dict];
            }
        }
    }else if([filterPick isEqualToString:@"WITHDRAW"]){
        for(NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Withdraw"]){
                [tempHistArray addObject:dict];
            }
        }
    } else if([filterPick isEqualToString:@"RECEIVED"]){
        for(NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"]){
                [tempHistArray addObject:dict];
            }
        }
    }else if([filterPick isEqualToString:@"SENT"]){
        for(NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent"]){
                [tempHistArray addObject:dict];
            }
        }
    }else if([filterPick isEqualToString:@"REQUEST"]){
        for(NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"]){
                [tempHistArray addObject:dict];
            }
        }
    }else if([filterPick isEqualToString:@"ALL"]){
        [tempHistArray setArray:histCopy];
    }
    if (![histSearching isEqualToString:@""]) {
        NSMutableArray *temp = [NSMutableArray new];
        for(NSDictionary *dict in tempHistArray){
            NSRange isRange = [[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"FirstName"],[dict objectForKey:@"LastName"]] rangeOfString:histSearching options:NSCaseInsensitiveSearch];
            if(isRange.location != NSNotFound){
                [temp addObject:dict];
            }
        }
        [tempHistArray setArray:temp];
    }
    [sortedHist setArray:[tempHistArray mutableCopy]];
  //21  [sortedHist setArray:[self sortByStringDate:sortedHist]];
    needsUpdating = NO;
    return sortedHist;
}
-(void)getBanks{
    serve *banks = [serve new];
    banks.Delegate = self;
    banks.tagName = @"banks";
    [banks getBanks];
}
-(void)getCards{
    serve *cards = [serve new];
    cards.Delegate = self;
    cards.tagName = @"cards";
    [cards getCards];
}
-(void)getSettings{
    serve *sets = [serve new];
    sets.Delegate = self;
    sets.tagName = @"sets";
    [sets getSettings];
}
-(void)getAcctInfo{
    if (!islogout) {
        serve *info = [serve new];
        info.Delegate = self;
        info.tagName = @"info";
        //
        NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
                NSLog(@"UserName%@",[usr objectForKey:@"email"]);
        [info getDetails:[defaults valueForKey:@"MemberId"]
];
    }
    
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        
        if (timer!=nil) {
           [timer invalidate];
            timer=nil;
        }
    }
    if ([tagName isEqualToString:@"banks"]) {
        NSMutableArray *bankResult = [result JSONValue];
        if ([bankResult isKindOfClass:[NSNull class]] || bankResult == nil) {
            bankResult = [NSMutableArray new];
        }
        [usr setObject:bankResult forKey:@"banks"];
    }else if([tagName isEqualToString:@"cards"]){
        NSMutableArray *cardResult = [result JSONValue];
        
        if ([cardResult isKindOfClass:[NSNull class]] || cardResult == nil) {
            cardResult = [NSMutableArray new];
        }
        
        [usr setObject:cardResult forKey:@"cards"];
    }else if([tagName isEqualToString:@"sets"]){
        NSMutableDictionary *setsResult = [result JSONValue];
        [usr setObject:setsResult forKey:@"sets"];
    }else if([tagName isEqualToString:@"info"]){
        NSDictionary *loginResult = [result JSONValue];
        //[usr setObject:@"YES" forKey:@"validated"];
        if(![[loginResult objectForKey:@"BalanceAmount"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"BalanceAmount"] != NULL)
        {
            [usr setObject:[loginResult objectForKey:@"BalanceAmount"] forKey:@"Balance"];
            
        }
        if(![[loginResult objectForKey:@"FirstName"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"FirstName"] != NULL)
        {
                    [usr setObject:[loginResult objectForKey:@"FirstName"] forKey:@"firstName"];
            [usr setObject:[loginResult objectForKey:@"LastName"] forKey:@"lastName"];
        }
        if(![[loginResult objectForKey:@"Status"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"Status"] != NULL){
            [usr setObject:[loginResult objectForKey:@"Status"] forKey:@"Status"];
        }
        if(![[loginResult objectForKey:@"PhotoUrl"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"PhotoUrl"] != NULL){
           // [usr setObject:[loginResult objectForKey:@"PhotoUrl"] forKey:@"PhotoUrl"];
            [usr setObject:@"http://172.17.60.150/NoochService/Photos/gv_no_photo.jpg" forKey:@"PhotoUrl"];

            if ([pic isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:@"profile_picture.png"])] || [pic isKindOfClass:[NSNull class]] || [pic length] == 0) {
                [self fetchPic];
            }
        }
        if(![[loginResult objectForKey:@"MemberId"] isKindOfClass:[NSNull class]] && [loginResult objectForKey:@"MemberId"] != NULL)
        {
            if (![[loginResult objectForKey:@"MemberId"] isEqualToString:[usr objectForKey:@"MemberId"]]) {
                [usr setObject:[loginResult objectForKey:@"MemberId"] forKey:@"MemberId"];
                NSLog(@"gotmemid%@",[loginResult objectForKey:@"MemberId"]);
                if (![[loginResult objectForKey:@"MemberId"] isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
                    [defaults setObject:[loginResult objectForKey:@"MemberId"] forKey:@"MemberId"];
                    [defaults synchronize];//00000000-0000-0000-0000-000000000000
                }
               
               // [[NSUserDefaults standardUserDefaults] setObject:[loginResult objectForKey:@"MemberId"] forKey:@"MemberId"];
                
            }
        }
    }
}
# pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"Connection failed: %@", [error description]);
    NSLog(@"failed updating lists");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    responseStringForHis = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    newHistForHis = [responseStringForHis JSONValue];
    [self performSelectorInBackground:@selector(processNew:) withObject:newHistForHis];
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
-(void)processNew:(NSMutableArray*)newHist{
    [newHist setArray:[self sortByStringDate:newHist]];
  //  arrRecordsCheck=[[NSArray alloc]initWithArray:newHist];
    if ([[[newHist lastObject] objectForKey:@"TransactionId"] isEqualToString:[[sortedHist lastObject] objectForKey:@"TransactionId"]] && loadingCheck) {
        limit = YES;
    }
    NSMutableArray *hist = [histCache mutableCopy];
    NSMutableArray *toAddTrans = [NSMutableArray new];
    if([hist count] != 0){
        bool found = NO;
        for(NSDictionary *nTran in newHist){
            for(NSMutableDictionary *tran in hist){
                if([[nTran objectForKey:@"TransactionId"] isEqualToString:[tran objectForKey:@"TransactionId"]]){
                    found = YES;
                    [tran setObject:[nTran objectForKey:@"Status"] forKey:@"Status"];
                    [tran setObject:[nTran objectForKey:@"DisputeStatus"] forKey:@"DisputeStatus"];
                    [tran setObject:[nTran objectForKey:@"DisputeId"] forKey:@"DisputeId"];
                    [tran setObject:[nTran objectForKey:@"DisputeReportedDate"] forKey:@"DisputeReportedDate"];
                    [tran setObject:[nTran objectForKey:@"DisputeResolvedDate"] forKey:@"DisputeResolvedDate"];
                    [tran setObject:[nTran objectForKey:@"DisputeReviewDate"] forKey:@"DisputeReviewDate"];
                    break;
                }
            }
            if(!found)
                [toAddTrans addObject:nTran];
            found = NO;
        }
        if([toAddTrans count] != 0){
            NSLog(@"appended %d to history size of %d",[toAddTrans count],[hist count]);
            [toAddTrans addObjectsFromArray:hist];
            [histCache setArray:[toAddTrans mutableCopy]];
        }else{
            [histCache setArray:[hist mutableCopy]];
        }
        
        [histCache setArray:[self sortByStringDate:histCache]];
    }else{
        [histCache setArray:newHist];
        arrRecordsCheck=[[NSArray alloc]initWithArray:newHist];
    }
    histSafe = YES;
    loadingCheck = NO;
    needsUpdating = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableReload" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self userInfo:nil];
    [self performSelectorInBackground:@selector(getImages) withObject:nil];
}
-(void)getImages{
    NSMutableArray *tempArry = [histCache mutableCopy];
    NSLog(@"tempArray%d",tempArry.count);
    for (NSMutableDictionary *dict in tempArry) {
        if (![dict objectForKey:@"image"] && ![[dict objectForKey:@"Photo"] isKindOfClass:[NSNull class]] && [[dict objectForKey:@"Photo"] rangeOfString:@"gv_no_photo"].location == NSNotFound ) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"Photo"]]];
            if (![imageData isKindOfClass:[NSNull class]]) {
                if ([imageData length] != 0) {
                    
                    [dict setObject:imageData forKey:@"image"];
                }
            }
        }
    }
     NSLog(@"tempArray%d",tempArry.count);
    [histCache setArray:tempArry];
    needsUpdating = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableReload" object:self userInfo:nil];
}
-(NSMutableArray *)sortByStringDate:(NSMutableArray *)unsortedArray{
    NSMutableArray *tempArray=[NSMutableArray array];
    for(int i=0;i<[unsortedArray count];i++)
    {
        NSDateFormatter *df=[[NSDateFormatter alloc]init];
        objModel=[[NSMutableDictionary alloc]initWithDictionary:[unsortedArray objectAtIndex:i]];

        [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *date1;
       
        if ([objModel valueForKey:@"TransactionDate"]) {
             NSLog(@"objectIssue%@",objModel);
            date1=[df dateFromString:[objModel objectForKey:@"TransactionDate"]];
            NSLog(@"Date12Dec%@",date1);
        }
      
       // NSLog(@"objmodel%@",objModel);
        dictsort=[[NSMutableDictionary alloc]init];
        if (objModel) {
            [dictsort setObject:objModel forKey:@"entity"];
        }
        
        if (date1) {
              [dictsort setObject:date1 forKey:@"date"];
        }
      
        [tempArray addObject:dictsort];
    }
    NSLog(@"%@",tempArray);

    NSInteger counter=[tempArray count];
    NSDate *compareDate;
    NSInteger index;
    for(int i=0;i<counter;i++)
    {
        index=i;
        if ([[tempArray objectAtIndex:i] valueForKey:@"date"]) {
             compareDate=[[tempArray objectAtIndex:i] valueForKey:@"date"];
            NSDate *compareDateSecond;
            for(int j=i+1;j<counter;j++)
            {
                if ([[tempArray objectAtIndex:j] valueForKey:@"date"]) {
                    compareDateSecond=[[tempArray objectAtIndex:j] valueForKey:@"date"];
                    NSComparisonResult result = [compareDate compare:compareDateSecond];
                    if(result == NSOrderedAscending)
                    {
                        compareDate=compareDateSecond;
                        index=j;
                    }
                    
                }
            }
        }
       
       
        if(i!=index)
            [tempArray exchangeObjectAtIndex:i withObjectAtIndex:index];
    }

    NSLog(@"%@",tempArray);
    [unsortedArray removeAllObjects];
    if ([tempArray count]>0) {
        for(int i=0;i<[tempArray count];i++)
        {
            if ([[tempArray objectAtIndex:i] valueForKey:@"entity"]) {
                [unsortedArray addObject:[[tempArray objectAtIndex:i] valueForKey:@"entity"]];
            }
            
        }
    }
    
    return unsortedArray;
}
#pragma mark - User objects
-(NSMutableDictionary*)usr{
    return usr;
}
-(NSMutableArray*)hist{
    return histCache;
}
-(NSMutableDictionary*)assos{
    return assosciateCache;
}
-(void)addAssos:(NSMutableArray*)additions{
    @try {
        if ([additions count] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self userInfo:nil];
            return;
        }
        NSMutableArray *members = [[NSMutableArray alloc] init];
        if ([assosciateCache objectForKey:@"members"]) {
            members = [[assosciateCache objectForKey:@"members"] mutableCopy];
        }

        NSMutableArray *nonmembers = [[NSMutableArray alloc] init];
        if ([assosciateCache objectForKey:@"nonmembers"]) {
            nonmembers = [[assosciateCache objectForKey:@"nonmembers"] mutableCopy];
        }

        NSMutableDictionary *people = [[NSMutableDictionary alloc] init];
        if ([assosciateCache objectForKey:@"people"]) {
            people = [[assosciateCache objectForKey:@"people"] mutableCopy];
        }
        if ([[additions objectAtIndex:0] objectForKey:@"recent"]) {
            //NSLog(@"recents %@",additions);
            members = [[NSMutableArray alloc] init];
            for (int i = 0; i<[additions count]; i++) {
                if ([[[additions objectAtIndex:i] objectForKey:@"firstName"] isKindOfClass:[NSNull class]] || [[[additions objectAtIndex:i] objectForKey:@"firstName"] length] < 1) {
                    continue;
                }
                NSMutableDictionary *recEntry = [NSMutableDictionary new];
                [recEntry setObject:[[additions objectAtIndex:i] objectForKey:@"MemberId"] forKey:@"MemberId"];
                [recEntry setObject:[[additions objectAtIndex:i] objectForKey:@"firstName"] forKey:@"firstName"];
                [recEntry setObject:[[additions objectAtIndex:i] objectForKey:@"lastName"] forKey:@"lastName"];
                [members addObject:recEntry];
            }
        }
        for (NSMutableDictionary *dict in additions) {
            if ([dict objectForKey:@"image"]) {
                if ([[dict objectForKey:@"image"]isKindOfClass:[UIImage class]]) {
                    [dict setObject:UIImagePNGRepresentation([dict objectForKey:@"image"]) forKey:@"image"];
                }
            }
        }
        
        NSMutableDictionary *arrayEntry = [NSMutableDictionary new];
        for (NSMutableDictionary *dict in additions) {
            
            if ([dict objectForKey:@"MemberId"]) {
                //NSMutableDictionary *pers = [NSMutableDictionary new];
                
                //nooch member entry
                if ([people objectForKey:[dict objectForKey:@"MemberId"]]) {
                    NSMutableDictionary *pers = [people objectForKey:[dict objectForKey:@"MemberId"]];
                    //person is in cache
                    if ([pers objectForKey:@"Photo"]) {
                        [dict removeObjectForKey:@"Photo"];
                    }
                    if ([pers objectForKey:@"image"] && [dict objectForKey:@"image"]) {
                        [dict removeObjectForKey:@"image"];
                    }
                    if (![[pers objectForKey:@"firstName"] isKindOfClass:[NSNull class]]) {
                        [dict removeObjectForKey:@"firstName"];
                    }
                    if (![[pers objectForKey:@"lastName"] isKindOfClass:[NSNull class]]) {
                        [dict removeObjectForKey:@"lastName"];
                    }
                    [pers addEntriesFromDictionary:dict];
                    [people setObject:pers forKey:[pers objectForKey:@"MemberId"]];
                }else{
                    //not in cache
                    bool found = NO;
                    for (NSString *strings in people) {
                        NSMutableDictionary *d = [people objectForKey:strings];
                        if([[d objectForKey:@"firstName"] isEqualToString:[dict objectForKey:@"firstName"]] &&
                           [[d objectForKey:@"lastName"] isEqualToString:[dict objectForKey:@"lastName"]]){
                            found = YES;
                            //[dict removeObjectForKey:@"MemberId"];
                            [d addEntriesFromDictionary:dict];
                            [people setObject:d forKey:[d objectForKey:@"MemberId"]];
                            break;
                        }
                    }
                    if (!found) {
                        NSMutableDictionary *pers = [NSMutableDictionary dictionaryWithDictionary:dict];
                        
                        [people setObject:pers forKey:[pers objectForKey:@"MemberId"]];
                    }
                }
                [arrayEntry setObject:[dict objectForKey:@"MemberId"] forKey:@"MemberId"];
                if ([dict objectForKey:@"firstName"]) {
                    [arrayEntry setObject:[dict objectForKey:@"firstName"] forKey:@"firstName"];
                }
                if ([dict objectForKey:@"lastName"]) {
                    [arrayEntry setObject:[dict objectForKey:@"lastName"] forKey:@"lastName"];
                }
            }else{
                //non nooch member entry
                
                if ([dict objectForKey:@"firstName"]) {
                    [arrayEntry setObject:[dict objectForKey:@"firstName"] forKey:@"firstName"];
                }
                if ([dict objectForKey:@"lastName"]) {
                    [arrayEntry setObject:[dict objectForKey:@"lastName"] forKey:@"lastName"];
                }
                if ([dict objectForKey:@"email"]) {
                    [arrayEntry setObject:[dict objectForKey:@"email"] forKey:@"email"];
                }
                if ([dict objectForKey:@"number"]) {
                    [arrayEntry setObject:[dict objectForKey:@"number"] forKey:@"number"];
                }
                if ([dict objectForKey:@"number"]) {
                    [people setObject:dict forKey:[dict objectForKey:@"number"]];
                }else if([dict objectForKey:@"email"]){
                    [people setObject:dict forKey:[dict objectForKey:@"email"]];
                }
                if ([dict objectForKey:@"facebookId"]) {
                    [people setObject:dict forKey:[dict objectForKey:@"facebookId"]];
                }
                
                
                if (![nonmembers containsObject:arrayEntry]) {
                    [nonmembers addObject:arrayEntry];
                }

                
            }

        }
        //NSLog(@"recents %@",members);
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [nonmembers setArray:[nonmembers sortedArrayUsingDescriptors:sortDescriptors]];
        NSMutableDictionary *finishedAdditions = [NSMutableDictionary new];
        [finishedAdditions setObject:members forKey:@"members"];
        //NSLog(@"members %@",members);
        [finishedAdditions setObject:nonmembers forKey:@"nonmembers"];
        [finishedAdditions setObject:people forKey:@"people"];
        [assosciateCache setDictionary:[finishedAdditions mutableCopy]];
        
    }
    @catch (NSException *exception) {
        NSLog(@"caugt exception in assos adding %@",[exception description]);
    }
    @finally {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self userInfo:nil];

    [self performSelectorInBackground:@selector(getAssosPics) withObject:nil];
}
-(NSMutableArray*)assosSearch:(NSString*)searchText{
    NSMutableArray *responseArray = [NSMutableArray new];
    NSArray *keys = [[[assosciateCache objectForKey:@"people"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in keys) {
        NSDictionary *dict = [[assosciateCache objectForKey:@"people"] objectForKey:key];
        NSString *name = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
        if ([name length] >= [searchText length]) {
            if ([[name substringToIndex:[searchText length]] caseInsensitiveCompare:searchText] == NSOrderedSame) {
                [responseArray addObject:dict];
                continue;
            }
        }
        if ([[dict objectForKey:@"lastName"] length] >= [searchText length]) {
            if ([[[dict objectForKey:@"lastName"] substringToIndex:[searchText length]] caseInsensitiveCompare:searchText] == NSOrderedSame) {
                [responseArray addObject:dict];
            }
        }
        //isRange = [[NSString stringWithFormat:@"%@ %@",[[dict objectForKey:@"firstName"] substringToIndex:[searchText length]-1],[[dict objectForKey:@"lastName"] substringToIndex:[searchText length]-1]] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        //if(isRange.location != NSNotFound)
        //    [responseArray addObject:dict];
    }   
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [responseArray setArray:[responseArray sortedArrayUsingDescriptors:sortDescriptors]];
    return responseArray;
}
-(void)getAssosPics{
    @try {
        NSLog(@"grabbing pictures");
        NSArray *keys = [NSArray new];
        keys = [[assosciateCache objectForKey:@"people"] allKeys];
        for (NSString *key in keys) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict = [[assosciateCache objectForKey:@"people"] objectForKey:key];
            if (![dict objectForKey:@"image"] && [dict objectForKey:@"Photo"]) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"Photo"]]];
                if ([imageData length] > 0) {
                    [dict setObject:imageData forKey:@"image"];
                    ////malloc here
                }
                
                
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"error gettin pictures");
    }
    @finally {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:nil userInfo:nil];
}
-(NSMutableData*)pic{
    if (pic != NULL) {
        if ([pic length] != 0) {
            return pic;
        }else{
            return [UIImagePNGRepresentation([UIImage imageNamed:@"profile_picture.png"]) mutableCopy];
        }
    }else{
        return [UIImagePNGRepresentation([UIImage imageNamed:@"profile_picture.png"]) mutableCopy];
    }
}
-(BOOL)isAlive:(NSString *)path{/*{{{*/
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    else return NO;
}/*}}}*/
-(BOOL)isClean:(id)object{/*{{{*/
    [object writeToFile:[self path:@"test"] atomically:YES];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self path:@"test"]])return YES;
    else return NO;
}/*}}}*/
-(UIColor*)hexColor:(NSString*)hex{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
-(NSString *)path:(NSString *)type{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"]]];
    if ([type isEqualToString:@"image"])
        return [documentsDirectory stringByAppendingPathExtension:@"png"];
    else if([type isEqualToString:@"core"])
        return [documentsDirectory stringByAppendingPathExtension:@"plist"];
    else if([type isEqualToString:@"recents"])
        return [documentsDirectory stringByAppendingPathComponent:@"-recent.plist"];
    else if([type isEqualToString:@"fb"])
        return [documentsDirectory stringByAppendingPathComponent:@"-fbList.plist"];
    else if([type isEqualToString:@"addr"])
        return [documentsDirectory stringByAppendingPathComponent:@"-addr.plist"];
    else if([type isEqualToString:@"hCheck"])
        return [documentsDirectory stringByAppendingPathExtension:@"history"];
    else if([type isEqualToString:@"hist"])
        return [documentsDirectory stringByAppendingPathComponent:@"History-cache.plist"];
    else if([type isEqualToString:@"test"])
        return [documentsDirectory stringByAppendingPathComponent:@"test"];
    else if([type isEqualToString:@"currentUser"])
        return [documentsDirectory stringByAppendingPathExtension:@"currentUser"];
    else return @"check typo...";
}
-(id)cleanForSave:(id)array{
    if ([array isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *cleanedArray = [NSMutableArray new];
        for(int i = 0; i < [array count]; i++){
            NSDictionary *dict = [array objectAtIndex:i];
            NSMutableDictionary *prunedDictionary = [NSMutableDictionary dictionary];
            for (NSString * key in [dict allKeys])
            {
                if (![[dict objectForKey:key] isKindOfClass:[NSNull class]])
                    [prunedDictionary setObject:[dict objectForKey:key] forKey:key];
            }
            [cleanedArray addObject:prunedDictionary];
        }
        return cleanedArray;
    }else if([array isKindOfClass:[NSMutableDictionary class]]){
        NSMutableArray *swapArray = [NSMutableArray new];
        NSMutableDictionary *prunedDictionary = [NSMutableDictionary new];
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:array];
        for(NSString *key in [array allKeys]){
            NSMutableArray *workArray = [NSMutableArray arrayWithArray:[array objectForKey:key]];
            for(NSMutableDictionary *dict in workArray){
                for (NSString * key2 in [dict allKeys])
                {
                    if (![[dict objectForKey:key2] isKindOfClass:[NSNull class]])
                        [prunedDictionary setObject:[dict objectForKey:key2] forKey:key2];
                }
                [swapArray addObject:prunedDictionary];
            }
            [resultDict setObject:swapArray forKey:key];
            [swapArray removeAllObjects];
        }
        return resultDict;
    }
    return array;
}
-(UIFont *)nFont:(NSString*)weight size:(int)size{
    NSString *fontName = [NSString stringWithFormat:@"Roboto"];
    if(![weight isEqualToString:@"def"])
        fontName = [fontName stringByAppendingFormat:@"-%@",weight];
    UIFont *font = [UIFont fontWithName:fontName size:size];
    return font;
}

@end
