//
//  self.m
//  Nooch
//
//  Created by Preston Hults on 1/25/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import "assist.h"
#import <QuartzCore/QuartzCore.h>
#import "Home.h"
#import "Register.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <LocalAuthentication/LocalAuthentication.h>

@implementation assist
@synthesize arrRecordsCheck;

NSString *responseStringForHis;
NSMutableArray *newHistForHis;
NSString *urlForHis;
NSMutableURLRequest *requestForHis;
NSURLConnection *connectionForHis;
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

-(BOOL)getSuspended
{
    return isUserSuspended;
}
-(void)setSusPended:(BOOL)istrue
{
    isUserSuspended=istrue;
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
-(BOOL)isloginFromOther
{
    return isLoginFromOther;
}
-(void)setIsloginFromOther:(BOOL)islog
{
    isLoginFromOther=islog;
}

-(BOOL)isPOP
{
    return isPOP;
}
-(void)setPOP:(BOOL)istrue
{
    isPOP=istrue;
}
// Next 2 are for 'Show In Search' setting
-(BOOL)islocationAllowed
{
    return islocationAllowed;
}
-(void)setlocationAllowed:(BOOL)istrue
{
    islocationAllowed=istrue;
}
-(BOOL)checkIfLocAllowed
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized ||
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            NSLog(@"Assist: Location Services Allowed");
            return YES;
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            NSLog(@"Assist: Location Services NOT Allowed");
            return NO;
        }
    }
    return NO;
}
-(BOOL)checkIfTouchIdAvailable
{
    NSString * useTouchId = [ARPowerHookManager getValueForHookById:@"UseTouchID"];

    if ([[useTouchId lowercaseString] isEqualToString:@"no"])
    {
        return NO;
    }

    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
-(BOOL)needsReload
{
    return isNeed;
}
-(void)setneedsReload:(BOOL)istrue
{
    isNeed=istrue;
}
-(NSMutableArray*)getArray
{
    return arrRequestMultiple;
}
-(void)setArray:(NSMutableArray*)arr{
    
    arrRequestMultiple=[arr copy];
}
-(BOOL)isRequestMultiple
{
    return isMutipleRequest;
}
-(void)setRequestMultiple:(BOOL)istrue
{
    isMutipleRequest=istrue;
}
-(NSString*)getPass
{
    return passValue;
}
-(void)setPassValue:(NSString*)value
{
    passValue=value;
}

-(void)birth
{
    needsUpdating = YES;
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
    if (pic == NULL || [pic length] == 0)
    {
        [self fetchPic];
    }

    [usr setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] forKey:@"email"];

    timer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(getAcctInfo) userInfo:nil repeats:YES];

    [[assist shared] setneedsReload:YES];
    [self getSettings];
    [self getAcctInfo];
}
-(void)renewFb
{
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
        else
        {
            //handle error gracefully
            NSLog(@"FB error from renew credentials %@",error);
        }
    }];
}
-(void)stamp
{
    if (!histSafe) {
        return;
    }
    //nslog(@"saving user object");
    if ([usr objectForKey:@"PhotoUrl"] != NULL && [pic isKindOfClass:[NSNull class]])
    {
        NSURL *photoUrl=[[NSURL alloc]initWithString:[usr objectForKey:@"PhotoUrl"]];
        pic = [NSMutableData dataWithContentsOfURL:photoUrl];
    }
    [usr setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
    NSMutableDictionary *usrB = [NSMutableDictionary new];
    NSMutableData *picB = [NSMutableData new];
    NSMutableDictionary *assosB = [NSMutableDictionary new];
    if ([self isAlive:[self path:@"currentUser"]])
    {
        archivedData = [NSMutableData dataWithContentsOfFile:[self path:@"currentUser"]];
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedData];
    usrB = [NSMutableDictionary dictionaryWithDictionary:[unarchiver decodeObjectForKey:@"core"]];
    picB = [NSMutableData dataWithData:[unarchiver decodeObjectForKey:@"pic"]];
    assosB = [NSMutableDictionary dictionaryWithDictionary:[unarchiver decodeObjectForKey:@"asso"]];
    [unarchiver finishDecoding];

    @try
    {
        archivedData = [NSMutableData new];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archivedData];
        [archiver encodeObject:usr forKey:@"core"];
        [archiver encodeObject:pic forKey:@"pic"];
        //[archiver encodeObject:histCache forKey:@"hist"];
        [archiver encodeObject:assosciateCache forKey:@"asso"];
        [archiver finishEncoding];
        [archivedData writeToFile:[self path:@"currentUser"] atomically:YES];
    }
    @catch (NSException *exception)
    {
        //nslog(@"failed saving, was updating during attempt,reverting to last save");
        archivedData = [NSMutableData new];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archivedData];
        [archiver encodeObject:usrB forKey:@"core"];
        [archiver encodeObject:picB forKey:@"pic"];
        [archiver encodeObject:assosB forKey:@"asso"];
        [archiver finishEncoding];
        [archivedData writeToFile:[self path:@"currentUser"] atomically:YES];
    }
    @finally {
        //nslog(@"done saving");
    }
    
}
-(void)fetchPic
{
    if ([usr objectForKey:@"PhotoUrl"] != NULL)
    {
        if ([[usr objectForKey:@"PhotoUrl"] rangeOfString:@"gv_no_photo"].location == NSNotFound )
        {
            NSURL * photoUrl = [[NSURL alloc] initWithString:[usr objectForKey:@"PhotoUrl"]];
            pic = [NSMutableData dataWithContentsOfURL:photoUrl];
        }
    }
}
-(void)death:(NSString *)path
{
    NSFileManager *dfm = [NSFileManager defaultManager];
    [dfm removeItemAtPath:path error:nil];
}
-(NSMutableArray*)allHist
{
    return histCache;
}
-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len
{
    histSafe=NO;
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];

    responseData = [NSMutableData data];
    urlForHis = [NSString stringWithFormat:@"%@"@"/%@?memberId=%@&listType=%@&%@=%@&%@=%@&accessToken=%@", MyUrl, @"GetTransactionsList", [usr objectForKey:@"MemberId"], type, @"pSize", [NSString stringWithFormat:@"%ld",(long)len], @"pIndex", [NSString stringWithFormat:@"%ld",(long)sPos],[defaults valueForKey:@"OAuthToken"]];

    requestForHis = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlForHis]];
    connectionForHis=[[NSURLConnection alloc] initWithRequest:requestForHis delegate:self];
    if (!connectionForHis) {
        NSLog(@"failed to connect for history");
    }
}
-(NSMutableArray*)histFilter:(NSString*)filterPick
{
    if (!histSafe) {
        return sortedHist;
    }
    if (!needsUpdating && [histSearching isEqualToString:@""]) {
        return sortedHist;
    }
    NSMutableArray *histCopy = [[self hist] mutableCopy];
    NSMutableArray *tempHistArray = [NSMutableArray new];
    if ([filterPick isEqualToString:@"DISPUTED"]){
        for (NSDictionary *dict in histCopy){
            if ([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent to"] || [[dict objectForKey:@"TransactionType"] isEqualToString:@"Received from"]){
                [tempHistArray addObject:dict];
            }
        }
    }
    else if([filterPick isEqualToString:@"DEPOSIT"]){
        for (NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Deposit"]){
                [tempHistArray addObject:dict];
            }
        }
    }
    else if ([filterPick isEqualToString:@"WITHDRAW"]){
        for (NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Withdraw"]){
                [tempHistArray addObject:dict];
            }
        }
    }
    else if ([filterPick isEqualToString:@"RECEIVED"]){
        for (NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Received"]){
                [tempHistArray addObject:dict];
            }
        }
    }
    else if ([filterPick isEqualToString:@"SENT"]){
        for (NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Sent"]){
                [tempHistArray addObject:dict];
            }
        }
    }
    else if ([filterPick isEqualToString:@"REQUEST"]){
        for (NSDictionary *dict in histCopy){
            if([[dict objectForKey:@"TransactionType"] isEqualToString:@"Request"]){
                [tempHistArray addObject:dict];
            }
        }
    }
    else if([filterPick isEqualToString:@"ALL"]){
        [tempHistArray setArray:histCopy];
    }

    if (![histSearching isEqualToString:@""])
    {
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *dict in tempHistArray)
        {
            NSRange isRange = [[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"FirstName"],[dict objectForKey:@"LastName"]] rangeOfString:histSearching options:NSCaseInsensitiveSearch];
            if (isRange.location != NSNotFound)
            {
                [temp addObject:dict];
            }
        }
        [tempHistArray setArray:temp];
    }
    [sortedHist setArray:[tempHistArray mutableCopy]];
    needsUpdating = NO;
    return sortedHist;
}

-(void)getSettings
{
    serve *sets = [serve new];
    sets.Delegate = self;
    sets.tagName = @"sets";
    [sets getSettings];
}

-(void)getAcctInfo
{
    if (!islogout)
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

        serve * info = [serve new];
        info.Delegate = self;
        info.tagName = @"info";
        [info getDetails:[defaults valueForKey:@"MemberId"]];
    }
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    
}
-(void)Error:(NSError *)Error{
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound)
    {
        if (timer!=nil)
        {
            [timer invalidate];
            timer=nil;
        }
    }
    else if ([tagName isEqualToString:@"sets"])
    {
        NSError *error;
        NSMutableDictionary *setsResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if (setsResult != NULL)
        {
            [usr setObject:setsResult forKey:@"sets"];
        }
        else
        {
            NSLog(@"assist.m --> 'sets' returned NULL from server");
        }
    }
    else if ([tagName isEqualToString:@"info"])
    {
        NSError *error;

        NSMutableDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if (loginResult != NULL)
        {
            NSLog(@"User Info: %@",loginResult);
        }
        else
        {
            NSLog(@"assist.m --> 'info' returned NULL from server");
        }
        

        if (  [loginResult valueForKey:@"Status"] != NULL &&
            ![[loginResult valueForKey:@"Status"] isKindOfClass:[NSNull class]])
        {
            [user setObject:[loginResult valueForKey:@"Status"] forKey:@"Status"];
            [usr setObject:[loginResult objectForKey:@"Status"] forKey:@"Status"];

            if ([[loginResult valueForKey:@"Status"] isEqualToString:@"Suspended"])
            {
                isUserSuspended = YES;
            }
            else
            {
               isUserSuspended = NO;
            }

            if ( [loginResult valueForKey:@"DateCreated"] &&
                ([[user valueForKey:@"DateCreated"] isKindOfClass:[NSNull class]] ||
                  [user valueForKey:@"DateCreated"] == NULL ||
                 [[user valueForKey:@"DateCreated"] isEqualToString:@""] ||
                ![[user valueForKey:@"DateCreated"] isEqualToString:[loginResult valueForKey:@"DateCreated"]]) )
            {
                [user setObject:[loginResult valueForKey:@"DateCreated"] forKey:@"DateCreated"];
            }

            if ([[loginResult valueForKey:@"IsKnoxBankAdded"] boolValue] == YES)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"IsBankAvailable"];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"IsBankAvailable"];
            }
        }

        if (![[loginResult objectForKey:@"UserName"] isKindOfClass:[NSNull class]] &&
              [loginResult objectForKey:@"UserName"] != NULL)
        {
            [user setObject:[loginResult objectForKey:@"UserName"] forKey:@"UserName"];
        }

        if (![[loginResult objectForKey:@"FirstName"] isKindOfClass:[NSNull class]] &&
              [loginResult objectForKey:@"FirstName"] != NULL)
        {
            [usr setObject:[loginResult objectForKey:@"FirstName"] forKey:@"firstName"];
            [usr setObject:[loginResult objectForKey:@"LastName"] forKey:@"lastName"];
            
            [user setObject:[loginResult objectForKey:@"FirstName"] forKey:@"firstName"];
            [user setObject:[loginResult objectForKey:@"LastName"] forKey:@"lastName"];
        }

        if (![[loginResult objectForKey:@"PhotoUrl"] isKindOfClass:[NSNull class]] &&
              [loginResult objectForKey:@"PhotoUrl"] != NULL)
        {
            [user setObject:[loginResult valueForKey:@"PhotoUrl"] forKey:@"Photo"];

            if ([pic isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:@"profile_picture.png"])] ||
                [pic isKindOfClass:[NSNull class]] ||
                [pic length] == 0)
            {
                [self fetchPic];
            }
        }

        if (![[loginResult objectForKey:@"MemberId"] isKindOfClass:[NSNull class]] &&
              [loginResult objectForKey:@"MemberId"] != NULL)
        {
            if (![[loginResult objectForKey:@"MemberId"] isEqualToString:[usr objectForKey:@"MemberId"]])
            {
                [usr setObject:[loginResult objectForKey:@"MemberId"] forKey:@"MemberId"];

                if (![[loginResult objectForKey:@"MemberId"] isEqualToString:@"00000000-0000-0000-0000-000000000000"])
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[loginResult objectForKey:@"MemberId"] forKey:@"MemberId"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }

        if ( [loginResult valueForKey:@"FacebookAccountLogin"] &&
            [[loginResult valueForKey:@"FacebookAccountLogin"]length] > 1)
        {
            [user setObject:[loginResult valueForKey:@"FacebookAccountLogin"] forKey:@"facebook_id"];
        }
        else
        {
            [user setObject:@"" forKey:@"facebook_id"];
        }
    }
}
- (NSDate*) dateFromString:(NSString*)aStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSDate *aDate = [dateFormatter dateFromString:aStr];

    return aDate;
}
# pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    responseStringForHis = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSError *error;
    
    newHistForHis = [NSJSONSerialization JSONObjectWithData:[responseStringForHis dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    [self performSelectorInBackground:@selector(processNew:) withObject:newHistForHis];
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
-(void)processNew:(NSMutableArray*)newHist
{
    [newHist setArray:[self sortByStringDate:newHist]];
    arrRecordsCheck=[[NSArray alloc]initWithArray:newHist];
    /*if ([[[newHist lastObject] objectForKey:@"TransactionId"] isEqualToString:[[sortedHist lastObject] objectForKey:@"TransactionId"]])
    {
        limit = YES;
    }*/
    NSMutableArray *hist = [histCache mutableCopy];
    NSMutableArray *toAddTrans = [NSMutableArray new];
    if ([hist count] != 0)
    {
        bool found = NO;
        for (NSDictionary *nTran in newHist)
        {
            for(NSMutableDictionary *tran in hist)
            {
                if([[nTran objectForKey:@"TransactionId"] isEqualToString:[tran objectForKey:@"TransactionId"]])
                {
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
        if([toAddTrans count] != 0)
        {
            [toAddTrans addObjectsFromArray:hist];
            [histCache setArray:[toAddTrans mutableCopy]];
        }
        else
        {
            [histCache setArray:[hist mutableCopy]];
        }

        [histCache setArray:[self sortByStringDate:histCache]];
    }
    else{
        [histCache setArray:newHist];
    }
    histSafe = YES;
    //loadingCheck = NO;
    needsUpdating = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableReload" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self userInfo:nil];
    [self performSelectorInBackground:@selector(getImages) withObject:nil];
}
-(void)getImages
{
    NSMutableArray *tempArry = [histCache mutableCopy];
    for (NSMutableDictionary *dict in tempArry)
    {
        if (![dict objectForKey:@"image"] && ![[dict objectForKey:@"Photo"] isKindOfClass:[NSNull class]] && [[dict objectForKey:@"Photo"] rangeOfString:@"gv_no_photo"].location == NSNotFound )
        {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"Photo"]]];
            if (![imageData isKindOfClass:[NSNull class]])
            {
                if ([imageData length] != 0)
                {
                    [dict setObject:imageData forKey:@"image"];
                }
            }
        }
    }
    [histCache setArray:tempArry];
    needsUpdating = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableReload" object:self userInfo:nil];
}
-(NSMutableArray *)sortByStringDate:(NSMutableArray *)unsortedArray
{
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i = 0; i < [unsortedArray count]; i++)
    {
        NSDateFormatter *df=[[NSDateFormatter alloc]init];
        objModel=[[NSMutableDictionary alloc]initWithDictionary:[unsortedArray objectAtIndex:i]];

        [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSDate *date1;

        if ([objModel valueForKey:@"TransactionDate"]) {
            date1=[df dateFromString:[objModel objectForKey:@"TransactionDate"]];
        }

        dictsort=[[NSMutableDictionary alloc]init];
        if (objModel) {
            [dictsort setObject:objModel forKey:@"entity"];
        }

        if (date1) {
            [dictsort setObject:date1 forKey:@"date"];
        }

        [tempArray addObject:dictsort];
    }

    NSInteger counter=[tempArray count];
    NSDate *compareDate;
    NSInteger index;
    for (int i = 0; i < counter; i++)
    {
        index=i;
        if ([[tempArray objectAtIndex:i] valueForKey:@"date"])
        {
            compareDate=[[tempArray objectAtIndex:i] valueForKey:@"date"];
            NSDate *compareDateSecond;
            for (int j = i + 1; j < counter; j++)
            {
                if ([[tempArray objectAtIndex:j] valueForKey:@"date"])
                {
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

    [unsortedArray removeAllObjects];
    if ([tempArray count]>0)
    {
        for (int i = 0; i < [tempArray count]; i++)
        {
            if ([[tempArray objectAtIndex:i] valueForKey:@"entity"])
            {
                [unsortedArray addObject:[[tempArray objectAtIndex:i] valueForKey:@"entity"]];
            }
        }
    }
    return unsortedArray;
}
#pragma mark - User objects
-(NSMutableDictionary*)usr
{
    return usr;
}
-(NSMutableArray *)hist
{
    return histCache;
}
-(NSMutableDictionary *)assos
{
    return assosciateCache;
}
-(NSMutableArray *)assosAll
{
    return [ArrAllContacts mutableCopy];
}
-(void)SaveAssos:(NSMutableArray*)additions
{
    ArrAllContacts = [[NSArray alloc] init];
    ArrAllContacts = [additions copy];
}
-(void)addAssos:(NSMutableArray*)additions
{
    @try {
        if ([additions count] == 0)
            return;

        if ([assosciateCache isKindOfClass:[NSNull class]])
        {
            assosciateCache = [NSMutableDictionary new];
        }
        else if ( [assosciateCache allKeys].count == 0)
        {
            assosciateCache = [NSMutableDictionary new];
        }

        for (NSDictionary * person in additions)
        {
            // NSLog(@"Person is: %@",person);
            if (person[@"UserName"])
            {
                if (!assosciateCache[person[@"UserName"]])
                {
                    [assosciateCache setObject:person forKey:person[@"UserName"]];
                }
                else
                {
                    for (NSString *key in person.allKeys)
                    {
                        if (!assosciateCache[person[@"UserName"]][key])
                        {
                            [assosciateCache[person[@"UserName"]] setObject:person[key] forKey:key];
                        }
                    }
                }
            }

            else if (person[@"phoneNo"])  // if the AB entry has at least 1 Phone Number, NOT an email
            {
                if (!assosciateCache[person[@"phoneNo"]])
                {
                    [assosciateCache setObject:person forKey:person[@"phoneNo"]];
                }
                else
                {
                    for (NSString * phoneKey in person.allKeys)
                    {
                        [assosciateCache[person[@"phoneNo"]] setObject:person[phoneKey] forKey:phoneKey];
                    }
                }
            }

            else if (person[@"MemberId"])
            {
                for (NSString *key in assosciateCache.allKeys)
                {
                    if (![assosciateCache[key][@"MemberId"] isKindOfClass:[NSNull class]])
                    {
                        if ( [assosciateCache[key][@"MemberId"] isEqualToString:person[@"MemberId"]])
                        {
                            for (NSString *key2 in person.allKeys)
                            {
                                if (!assosciateCache[key][key2])
                                {
                                    [assosciateCache[key] setObject:person[key2] forKey:key2];
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"caught exception in Assist.m --> - addAssos %@",[exception description]);
        NSLog(@"adding... %@",additions);
    }
    @finally {
        
    }
}
-(NSMutableArray*)assosSearch:(NSString*)searchText
{
    NSMutableArray *responseArray = [NSMutableArray new];
    NSArray *keys = [[[assosciateCache objectForKey:@"people"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    for (NSString *key in keys)
    {
        NSDictionary *dict = [[assosciateCache objectForKey:@"people"] objectForKey:key];

        NSString *name = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];

        if ([name length] >= [searchText length]) {
            if ([[name substringToIndex:[searchText length]] caseInsensitiveCompare:searchText] == NSOrderedSame) {
                [responseArray addObject:dict];
                continue;
            }
        }
        if ([[dict objectForKey:@"lastName"] length] >= [searchText length])
        {
            if ([[[dict objectForKey:@"lastName"] substringToIndex:[searchText length]] caseInsensitiveCompare:searchText] == NSOrderedSame)
            {
                [responseArray addObject:dict];
            }
        }
    }

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [responseArray setArray:[responseArray sortedArrayUsingDescriptors:sortDescriptors]];
    return responseArray;
}
-(void)getAssosPics
{
    @try {
        NSArray *keys = [NSArray new];
        keys = [[assosciateCache objectForKey:@"people"] allKeys];
        for (NSString *key in keys)
        {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict = [[assosciateCache objectForKey:@"people"] objectForKey:key];
            if (![dict objectForKey:@"image"] && [dict objectForKey:@"Photo"])
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"Photo"]]];
                if ([imageData length] > 0) {
                    [dict setObject:imageData forKey:@"image"];
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
-(NSMutableData*)pic
{
    if (pic != NULL)
    {
        if ([pic length] != 0)
        {
            return pic;
        }
        else
        {
            return [UIImagePNGRepresentation([UIImage imageNamed:@"profile_picture.png"]) mutableCopy];
        }
    }
    else
    {
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
-(UIColor*)hexColor:(NSString*)hex
{
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
-(UIFont *)nFont:(NSString*)weight size:(int)size
{
    NSString *fontName = [NSString stringWithFormat:@"Roboto"];
    if(![weight isEqualToString:@"def"])
        fontName = [fontName stringByAppendingFormat:@"-%@",weight];
    UIFont *font = [UIFont fontWithName:fontName size:size];
    return font;
}

@end
