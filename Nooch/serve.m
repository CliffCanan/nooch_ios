//
//  serve.m
//  Nooch
//
//  Created by Preston Hults on 2/6/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "serve.h"
#import "NoochHome.h"
//
//Charan's edit 19nov2013
//seconds for 3 days
#define secondsFor3days 259200
//seconds for 6 days
#define secondsFor6days 518400
//seconds for 9 days
#define secondsFor9days 777600

NSMutableDictionary *transactionfund;
//
NSMutableDictionary *transactionInputW;
NSMutableDictionary *transactionW;
NSMutableURLRequest *requestRecent;
//
NSMutableDictionary *transactionInputaddfund;
NSMutableURLRequest *requestmemid;
NSMutableURLRequest*requestList;
NSURLConnection*connectionList;
NSMutableURLRequest *requestS;
NSMutableDictionary*dictValidate;
//
NSDictionary*Dictresponse;

NSMutableURLRequest *requestMem;
//
NSMutableURLRequest *requestLogin;
NSURLConnection *connectionLogin;
//
NSData *postDataBNK;
NSString *postLengthBNK;
NSMutableURLRequest *requestBNK;
//
NSMutableDictionary*dictInv;

NSData *postDataInv;

NSString *postLengthInv;
NSMutableURLRequest *requestInv;
NSURLConnection *connectionInv;
//
NSString *postSet;
NSMutableURLRequest *requestSet;
NSData *postDataSet;
NSString *postLengthSet;
NSString *urlStrSet;
NSMutableURLRequest *requestgetCards;
NSMutableURLRequest *requestgetbanks;
NSMutableURLRequest *requestdup;
NSMutableURLRequest *requestnewUser;
NSMutableURLRequest *requestEncryption;
//
NSMutableDictionary*dictRef;

NSData *postDataRef;

NSString *postLengthRef;
NSMutableURLRequest *requestRef;
NSURLConnection *connectionRef;
//
NSMutableDictionary*dictSMS;
NSString*ServiceType;
NSData *postDataSMS;

NSString *postLengthSMS;
NSMutableURLRequest *requestSMS;
NSURLConnection *connectionSMS;
BOOL isCheckValidation;
NSMutableDictionary*emailParam;
NSDictionary*dictResponse;
NSString *responseString;
@implementation serve
@synthesize Delegate,tagName,responseData,locationManager,Latitude,Longitude;
//NSString * const ServerUrl = @"https://74.117.228.120/NoochService.svc"; //production server
//NSString * const ServerUrl = @"https://192.203.102.254/NoochService.svc"; //development server
//NSString * const ServerUrl =@"https://noochweb.venturepact.com/noochservice/noochservice.svc";
//http://noochweb.venturepact.com/NoochService.svck
//NSString * const ServerUrl = @"https://192.203.102.254/noochservice/NoochService.svc";
NSString * const ServerUrl = @"https://172.17.60.150/NoochService/NoochService.svc";
//NSString * const ServerUrl = @"https://10.200.1.40/noochservice/NoochService.svc";
//NSString * const ServerUrl = @"http://noochweb.venturepact.com/NoochService.svc"; //testing server Venturepact isCheckValidation;
bool locationUpdate;
NSString *tranType;
NSString *amnt;
-(void)addFund:(NSString*)amount{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
   while ((!locationUpdate) &&
           ([loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate
                                                           distantFuture]]))
    {

    }
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"latlon%@%@",self.Longitude,self.Latitude);
    NSLog(@"oauthnd%@",[defaults valueForKey:@"OAuthToken"]);
    transactionInputaddfund=[[NSMutableDictionary alloc]init];
    [transactionInputaddfund setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
    [transactionInputaddfund setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"RecepientId"];
    [transactionInputaddfund setValue:amount forKey:@"Amount"];
    [transactionInputaddfund setValue:TransactionDate forKey:@"TransactionDate"];
    [transactionInputaddfund setValue:@"false" forKey:@"IsPrePaidTransaction"];
    [transactionInputaddfund setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] forKey:@"DeviceId"];
    [transactionInputaddfund setValue:self.Latitude forKey:@"Latitude"];
    [transactionInputaddfund setValue:self.Longitude forKey:@"Longitude"];
    [transactionInputaddfund setValue:Altitude forKey:@"Altitude"];
    [transactionInputaddfund setValue:addressLine1 forKey:@"AddressLine1"];
    [transactionInputaddfund setValue:addressLine2 forKey:@"AddressLine2"];
     [transactionInputaddfund setValue:city forKey:@"City"];
     [transactionInputaddfund setValue:state forKey:@"State"];
     [transactionInputaddfund setValue:country forKey:@"Country"];
     [transactionInputaddfund setValue:zipcode forKey:@"Zipcode"];
    
//     transactionInputaddfund = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"MemberId", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"RecepientId", amount, @"Amount", TransactionDate, @"TransactionDate", @"false", @"IsPrePaidTransaction",  [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"], @"DeviceId", self.Latitude, @"Latitude", self.Longitude, @"Longitude", Altitude, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode", nil];
    
    transactionfund = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputaddfund, @"transactionInput",[defaults valueForKey:@"OAuthToken"],@"accessToken", nil];
    NSString *post = [transactionfund JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

    responseData = [NSMutableData data];

    NSString *urlStr = [NSString stringWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"AddFund"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");

    locationUpdate = NO;
}
-(void)getSettings {
    self.responseData = [NSMutableData data];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    requestS = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?id=%@&accessToken=%@", ServerUrl, @"GetMyDetails", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], [defaults valueForKey:@"OAuthToken"] 
]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestS delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)deleteBank:(NSString*)bankId{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&bankAcctId=%@&accessToken=%@", ServerUrl, @"DeleteBankAccountDetails", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], bankId,[[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"]]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)deleteCard:(NSString*)cardId{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&bankAcctId=%@", ServerUrl, @"DeleteCardAccountDetails", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], cardId]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)forgotPass:(NSString *)email{
    self.responseData = [[NSMutableData alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@/ForgotPassword", ServerUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *emailData = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)email,@"Input", nil];
    NSDictionary *emailParam = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)emailData,@"userName", nil];
    NSString *post = [emailParam JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
    
    
}
-(void)getBanks{
   
    self.responseData = [NSMutableData data];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
   requestgetbanks = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&accessToken=%@", ServerUrl, @"GetBankAccountCollection", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"],[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:requestgetbanks delegate:self];
    if (!connection)
        NSLog(@"connect error");
    
}
-(void)getCards{
     NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    self.responseData = [NSMutableData data];
    requestgetCards = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&accessToken=%@", ServerUrl, @"GetCardAccountCollection", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"],[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:requestgetCards delegate:self];
    if (!connection)
        NSLog(@"connect error");
    
}
-(void)getEncrypt:(NSString *)in{
    self.responseData = [[NSMutableData alloc] init];
    requestEncryption = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl,@"GetEncryptedData",@"data",in]]];
    [requestEncryption setHTTPMethod:@"GET"];
    [requestEncryption setTimeoutInterval:20.0f];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:requestEncryption delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getDetails:(NSString*)username{
    //self.tagName=@"memberDetail";
        islogOutUnconditional=YES;
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];

    self.responseData = [[NSMutableData alloc] init];
   // requestMem=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?name=%@&accessToken=%@&memberId=%@",ServerUrl,@"GetMemberDetails",username,[defaults valueForKey:@"OAuthToken"],[defaults valueForKey:@"memberId"]]]];
     requestMem=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&accessToken=%@",ServerUrl,@"GetMemberDetails",username,[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:requestMem delegate:self];
    if (!connection)
        NSLog(@"connect error");
    
}
//-(void)getLatestTrans
-(void)getMemIdFromuUsername:(NSString*)username{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
        self.responseData = [[NSMutableData alloc] init];
    NSLog(@"%@",[defaults valueForKey:@"OAuthToken"]);
   requestmemid=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetMemberIdByUsername?name=%@",ServerUrl,username
]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:requestmemid delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getMemberIds:(NSMutableArray*)input{
    self.responseData = [[NSMutableData alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@/GetMemberIds",ServerUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableDictionary *emailParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:input,@"phoneEmailList", nil];
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:emailParam,@"phoneEmailListDto", nil];
    NSString *post = [entry JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getNoteSettings{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    

    self.responseData = [[NSMutableData alloc] init];
    NSString *method=@"GetMemberNotificationSettings";
    NSString *parameter=@"memberId";
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&accessToken=%@",ServerUrl,method,parameter,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getTargus{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetMemberTargusScores?memberId=%@&accessToken=%@",ServerUrl,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getRecents{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    self.responseData = [[NSMutableData alloc] init];
    requestRecent=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetRecentMembers?id=%@&accessToken=%@",ServerUrl,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:requestRecent delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)privacyPolicy{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&accessToken=%@&memberId=%@", ServerUrl,@"GetTemplateContent",@"tempName",@"Privacy",[[NSUserDefaults standardUserDefaults]stringForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)tos{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl,@"GetTemplateContent",@"tempName",@"Terms"]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)dupCheck:(NSString*)email{
    self.responseData = [NSMutableData data];
    //IsDuplicateMember?name={userName}&udId={deviceId}
    requestdup = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl, @"IsDuplicateMember", @"name", email]]];
    //Load the request in the UIWebView.
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:requestdup delegate:self];
    if (!connection)
        NSLog(@"connect error");
}


-(void)login:(NSString*)email password:(NSString*)pass remember:(BOOL)isRem lat:(float)lat lon:(float)lng {
   
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
//    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
//    [locationManager startUpdatingLocation];
    ServiceType=@"Login";
    self.responseData = [[NSMutableData alloc] init];
       if (isRem) {
        requestLogin = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&rememberMeEnabled=true&lat=%f&lng=%f", ServerUrl, @"LoginRequest", @"name", email, @"pwd", pass,lat,lng]]];

    }
    else
    {
         requestLogin = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&rememberMeEnabled=false&lat=%f&lng=%f", ServerUrl, @"LoginRequest", @"name", email, @"pwd", pass,lat,lng]]];
    }
    [requestLogin setTimeoutInterval:10000];
      connectionLogin = [[NSURLConnection alloc] initWithRequest:requestLogin delegate:self];
    NSLog(@"url %@",[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@", ServerUrl, @"LoginRequest", @"name", email, @"pwd", pass]);
    if (!connectionLogin)
        NSLog(@"connect error");
}
-(void)makeBankPrimary:(NSString*)bankId{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&cardAcctId=%@", ServerUrl, @"MakeBankAccountAsPrimary", [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"], bankId]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)makeCardPrimary:(NSString*)cardId{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&cardAcctId=%@", ServerUrl, @"MakeCardAccountAsPrimary", [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"], cardId]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)memberDevice:(NSString *)deviceToken{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&deviceToken=%@&accessToken=%@", ServerUrl, @"MemberDevice", [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],deviceToken,[defaults valueForKey:@"OAuthToken"]]]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)setEmailSets:(NSDictionary*)notificationDictionary{
    NSString *post = [notificationDictionary JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString *urlStr = [[NSString alloc] initWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"MemberEmailNotificationSettings"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:3600];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)setPushSets:(NSDictionary*)notificationDictionary{
    NSString *post = [notificationDictionary JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString *urlStr = [[NSString alloc] initWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"MemberPushNotificationSettings"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:3600];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)newUser:(NSString *)email first:(NSString *)fName last:(NSString *)lName password:(NSString *)password pin:(NSString*)pin invCode:(NSString*)inv{
    /*
     "http://localhost:3479/NoochService.svc/MemberRegistration?uName=baljeet.singh@venturepact.com&fName=Baljeet&lName=Singh&secMail=baljeet.singh@venturepact.com&rEmail=baljeet.singh@venturepact.com&pwd=1234&pinNo=1234&deviceToken=90234&udId=&friendReqId=&invitedFriendFacebookId=&inviteCode=NOOCH123&facebookAccountLogin=&validatedDate=2013-10-25
     &inviteCodeId=41030432-a62e-47d4-bb62-04f08512c7c0"
     */
    
    self.responseData = [[NSMutableData alloc] init];
    //NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
   requestnewUser = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?uName=%@&fName=%@&lName=%@&secMail=%@&rEmail=%@&pwd=%@&pinNo=%@&deviceToken=%@&udId=&friendReqId=&invitedFriendFacebookId=&inviteCode=%@&facebookAccountLogin=", ServerUrl,@"MemberRegistration", email, fName, lName,email,email,password, pin, @"12345678977",inv]]];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestnewUser delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)setSets:(NSDictionary*)settingsDictionary{
    
    self.responseData = [NSMutableData data];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [settingsDictionary setValue:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
   postSet = [settingsDictionary JSONRepresentation];
    postDataSet = [postSet dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    postLengthSet = [NSString stringWithFormat:@"%d", [postDataSet length]];
    urlStrSet = [[NSString alloc] initWithString:ServerUrl];
    urlStrSet = [urlStrSet stringByAppendingFormat:@"/%@", @"MySettings"];
    NSURL *url = [NSURL URLWithString:urlStrSet];
    requestSet = [[NSMutableURLRequest alloc] initWithURL:url];
    [requestSet setHTTPMethod:@"POST"];
    [requestSet setValue:postLengthSet forHTTPHeaderField:@"Content-Length"];
    [requestSet setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSet setHTTPBody:postDataSet];
    [requestSet setTimeoutInterval:3600];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestSet delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)resetPassword:(NSString*)old new:(NSString*)new{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@",ServerUrl,@"ResetPassword",@"memberId", [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"newPassword",new]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)resetPIN:(NSString*)old new:(NSString*)new{
    self.responseData = [NSMutableData data];
    NSString *memberStringID=@"memberId";
    NSString *newPin=@"newpin";
    NSString *oldPin=@"oldPin";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&%@=%@",ServerUrl,@"ResetPin",memberStringID,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],oldPin,old,newPin,new]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)saveBank:(NSMutableDictionary *)bankDetails{
    self.responseData = [NSMutableData data];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [bankDetails setValue:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    
    NSString *post = [bankDetails JSONRepresentation];
    postDataBNK = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    postLengthBNK = [NSString stringWithFormat:@"%d", [postDataBNK length]];
    NSString *urlStr = [[NSString alloc] initWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"SaveBankAccountDetails"];
    NSURL *url = [NSURL URLWithString:urlStr];
    requestBNK = [[NSMutableURLRequest alloc] initWithURL:url];
    [requestBNK setHTTPMethod:@"POST"];
    [requestBNK setValue:postLengthBNK forHTTPHeaderField:@"Content-Length"];
    [requestBNK setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestBNK setHTTPBody:postDataBNK];
    [requestBNK setTimeoutInterval:3600];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:requestBNK delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)saveCard:(NSMutableDictionary*)cardDetails{
    self.responseData = [NSMutableData data];
   NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [cardDetails setValue:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    
    NSString *post = [cardDetails JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString *urlStr = [[NSString alloc] initWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"SaveCardAccountDetails"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:3600];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
//-(void)sendInvite:(NSString)
-(void)setSharing:(NSString*)sharingValue{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *requestObject = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@",ServerUrl,@"SetAllowSharing",@"memberID",[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"],@"allow",sharingValue]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestObject delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)pinCheck:(NSString*)memId pin:(NSString*)pin{
    self.responseData = [NSMutableData data];
    //GetNoochFriends?id={memberId}&inviteType={inviteType}
    /* NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
     
     NSString *urlString = [NSString stringWithFormat:@"%@/GetAllBanks&accessToken=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"]];*/
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&accessToken=%@", ServerUrl, @"ValidatePinNumber", @"memberId", memId, @"pinNo", pin,[[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"]]]];
    [request setTimeoutInterval:50.0f];
    //Load the request in the UIWebView.
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)verifyBank:(NSString *)bankAcctId microOne:(NSString *)microOne microTwo:(NSString *)microTwo{

    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&bankAcctId=%@&microOne=%@&microTwo=%@", ServerUrl, @"VerifyBankAccount", [[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"], bankAcctId,microOne,microTwo]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)withdrawFund:(NSString*)amount{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    while ((!locationUpdate) &&           ([loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate
                                                           distantFuture]]))
    {
        
    }
    transactionInputW=[[NSMutableDictionary alloc]init];
    [transactionInputW setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
    [transactionInputW setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"RecepientId"];
    [transactionInputW setValue:amount forKey:@"Amount"];
    [transactionInputW setValue:TransactionDate forKey:@"TransactionDate"];
    [transactionInputW setValue:@"false" forKey:@"IsPrePaidTransaction"];
    [transactionInputW setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] forKey:@"DeviceId"];
    [transactionInputW setValue:self.Latitude forKey:@"Latitude"];
    [transactionInputW setValue:self.Longitude forKey:@"Longitude"];
    [transactionInputW setValue:Altitude forKey:@"Altitude"];
    [transactionInputW setValue:addressLine1 forKey:@"AddressLine1"];
    [transactionInputW setValue:addressLine2 forKey:@"AddressLine2"];
    [transactionInputW setValue:city forKey:@"City"];
    [transactionInputW setValue:state forKey:@"State"];
    [transactionInputW setValue:country forKey:@"Country"];
    [transactionInputW setValue:zipcode forKey:@"Zipcode"];

//   transactionInputW = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"MemberId", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"RecepientId", amount, @"Amount", TransactionDate, @"TransactionDate", @"false", @"IsPrePaidTransaction",  [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"], @"DeviceId", self.Latitude, @"Latitude", self.Longitude, @"Longitude", Altitude, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode", nil];
     transactionW = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputW, @"transactionInput",[[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"],@"accessToken"
, nil];
    NSString *post = [transactionW JSONRepresentation];
    NSLog(@"transaction input %@",transactionW);

    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    responseData = [NSMutableData data];
    NSString *urlStr = [NSString stringWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"WithdrawFund"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
    locationUpdate = NO;
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code] == kCLErrorDenied){
        NSLog(@"Error : %@",error);
    }
}
-(void) updateLocation:(NSString*)latitudeField longitudeField:(NSString*)longitudeField{
    //http://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&sensor=true_or_false
    NSLog(@"%@%@",longitudeField,latitudeField);
    //  NSString *fetchURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true_or_false", latitudeField, longitudeField];
    NSString *fetchURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", latitudeField, longitudeField];
    NSURL *url = [NSURL URLWithString:fetchURL];
    NSError *error = nil;
    NSString *htmlData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:htmlData error:nil];
    NSArray *placemark = [NSArray new];
    placemark = [json objectForKey:@"results"];
    NSString *addr = [[placemark objectAtIndex:0] objectForKey:@"formatted_address"];
  
    NSArray *addrParse = [addr componentsSeparatedByString:@" "];
    NSLog(@"loc %@",addrParse);
    if ([addrParse count] == 4) {
        addressLine1 = [addrParse objectAtIndex:0];
        city = [addrParse objectAtIndex:1];
        state = [[addrParse objectAtIndex:2] substringToIndex:3];
        zipcode = [[addrParse objectAtIndex:2] substringFromIndex:3];
        country = [addrParse objectAtIndex:3];
    }else{
        addressLine1 = [addrParse objectAtIndex:0];
        addressLine2 = [addrParse objectAtIndex:1];
        city = [addrParse objectAtIndex:2];
        state = [[addrParse objectAtIndex:3] substringToIndex:3];
        zipcode = [[addrParse objectAtIndex:3] substringFromIndex:3];
        country = [addrParse objectAtIndex:4];
    }
    if ([city rangeOfString:@"null"].location != NSNotFound || city == NULL) {
        city = @"";
    }
    if ([state rangeOfString:@"null"].location != NSNotFound || state == NULL) {
        state = @"";
    }
    if ([zipcode rangeOfString:@"null"].location != NSNotFound || zipcode == NULL) {
        zipcode = @"";
    }
    if ([addressLine1 rangeOfString:@"null"].location != NSNotFound || addressLine1 == NULL) {
        addressLine1 = @"";
    }
    if ([addressLine2 rangeOfString:@"null"].location != NSNotFound || addressLine2 == NULL) {
        addressLine2 = @"";
    }
    if (TransactionDate == NULL || [TransactionDate rangeOfString:@"null"].location != NSNotFound || [TransactionDate isEqual: [NSNull null]]) {
        TransactionDate = @"";
    }
    if (latitudeField == NULL || [latitudeField rangeOfString:@"null"].location != NSNotFound) {
        latitudeField = @"0.0";
    }
    if (longitudeField == NULL || [longitudeField rangeOfString:@"null"].location != NSNotFound) {
        longitudeField = @"0.0";
    }
    if (Altitude == NULL || [Altitude rangeOfString:@"null"].location != NSNotFound) {
        Altitude = @"0.0";
    }
    NSLog(@"%@%@",latitudeField,longitudeField);

    self.Latitude = latitudeField;
    self.Longitude = longitudeField;
    locationUpdate = YES;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [manager stopUpdatingLocation];

    CLLocationCoordinate2D loc = [newLocation coordinate];
	Latitude = [[NSString alloc] initWithFormat:@"%f",loc.latitude];
	Longitude = [[NSString alloc] initWithFormat:@"%f",loc.longitude];
	Altitude = [[NSString alloc] initWithFormat:@"%f",newLocation.altitude];
    [locationManager stopUpdatingLocation];
    
    [self updateLocation:Latitude longitudeField:Longitude];
}
 
# pragma  mark - NSURL Delegate Methods

//response method for all request
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"serve connect error: %@",self.tagName);
    if ([tagName isEqualToString:@"EncryptReqImm"]) {
        
    }
    NSLog(@"Error aya %@",error);
    /*self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [[connection originalRequest] mutableCopy];
    [request setTimeoutInterval:7.0f];
    NSURLConnection *connect =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connect)
        NSLog(@"connect error");*/
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
   
    
    responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    if ([responseString rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound) {
        // [self viewDidDisaislogOutUnconditionalppear:YES];
        if ([[assist shared]isloggedout]) {
            
        }
        else
        {
        if (islogOutUnconditional) {
            UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Nooch Money" message:@"You've Logged in From Another Device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil                , nil];
            
            [Alert show];
            
                        
            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];
            
            NSLog(@"test: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"]);
            
            sendingMoney = NO;
            
            [navCtrl dismissViewControllerAnimated:YES completion:nil];
            
            // [navCtrl dismissModalViewControllerAnimated:NO];
            
            [navCtrl performSelector:@selector(disable)];
            
            [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"tutorial"] animated:YES];
            
            me = [core new];
            
            islogOutUnconditional=NO;

        }
        }
    }
    else if([responseString rangeOfString:@"Invalid OAuth 2 Access"].location==NSNotFound)
    {
        if ([tagName isEqualToString:@"logout"]) {
            Dictresponse=[responseString JSONValue];
            if ([[Dictresponse valueForKey:@"Result"]isEqualToString:@"Success."]) {
                isloggedout=YES;
            }
        }

    if (![tagName isEqualToString:@"info"]) {
        NSLog(@"serve connected for %@",self.tagName);
        
    }
            //20ov
    if ([tagName isEqualToString:@"info"]) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        
        //ADDING LOCAL NOTIFICATION CHARAN 19NOV 2013
        
        
        if ([defaults objectForKey:@"FullyVerified"] && !([[defaults objectForKey:@"NotifPlaced"] isEqualToString:@"1"])) {
            if ([[defaults objectForKey:@"FullyVerified"] isEqualToString:@"1"] &&
                [[defaults objectForKey:@"NotifPlaced"] isEqualToString:@"1"]) {
                NSLog(@"Fully Verified");
                //removing further notifications as the account is verified
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                //setting notifications to 0 as the notifications are placed
                [defaults setObject:@"0" forKey:@"NotifPlaced"];
                [defaults synchronize];
            }
            else
            {
                //adding local notification for 3 days
                UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:secondsFor3days];
                localNotification.alertBody = @"Hey! Just a reminder that your Nooch account is almost ready. Open Nooch to complete your profile and start sending money!- Team Nooch";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                
                //adding local notification for 6 days
                localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:secondsFor6days];
                localNotification.alertBody = @"Hey! Just a reminder that your Nooch account is almost ready. Open Nooch to complete your profile and start sending money!- Team Nooch";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                
                //adding local notification for 9 days
                localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:secondsFor9days];
                localNotification.alertBody = @"Hey! Just a reminder that your Nooch account is almost ready. Open Nooch to complete your profile and start sending money!- Team Nooch";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                
                [defaults setObject:@"1" forKey:@"NotifPlaced"];
                [defaults synchronize];
                
            }
        }
        
        
        
        
        
        
        Dictresponse=[responseString JSONValue]; //setting the token in the user defaults
        //Charan's edit 19 Nov 2013
        if (![[Dictresponse objectForKey:@"LastLocationLat"] isKindOfClass:[NSNull class]]&& ![[Dictresponse objectForKey:@"LastLocationLng"] isKindOfClass:[NSNull class]]) {
            [defaults setObject:[Dictresponse objectForKey:@"LastLocationLat"] forKey:@"LastLat"];
            [defaults setObject:[Dictresponse objectForKey:@"LastLocationLng"] forKey:@"LastLng"];
            [defaults synchronize];
        }
        
        //--
        
        
        if ([Dictresponse valueForKey:@"PhotoUrl"]!=NULL || ![[Dictresponse valueForKey:@"PhotoUrl"] isKindOfClass:[NSNull class]]) {
            [defaults setObject:[Dictresponse valueForKey:@"PhotoUrl"] forKey:@"PhotoUrlRef"];
            
        }
        if ([Dictresponse valueForKey:@"BalanceAmount"]!=NULL || ![[Dictresponse valueForKey:@"BalanceAmount"] isKindOfClass:[NSNull class]])
            
        {
            [defaults setObject:[NSString stringWithFormat:@"%@",[Dictresponse valueForKey:@"BalanceAmount"]] forKey:@"BalanceAmountRef"];
            
        }
        [defaults synchronize];
        
    }
    NSLog(@"RS%@",responseString);
    NSLog(@"TAG%@",tagName);
    if ([tagName isEqualToString:@"sets"]) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        Dictresponse=[responseString JSONValue];
        
        
        
        //Charan's Edit 19Nov 2013
        if ([Dictresponse valueForKey:@"IsValidProfile"]
            &&
            [Dictresponse valueForKey:@"IsVerifiedPhone"]) {
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"1" forKey:@"FullyVerified"];
            [defaults synchronize];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"FullyVerified"];
            [defaults synchronize];
        }
        //--
        
        
        if ([[Dictresponse valueForKey:@"ContactNumber"]isKindOfClass:[NSNull class]]||[[Dictresponse valueForKey:@"State"]isKindOfClass:[NSNull class]]||[[Dictresponse valueForKey:@"Address"]isKindOfClass:[NSNull class]]||[[Dictresponse valueForKey:@"City"]isKindOfClass:[NSNull class]]) {
            
            
            
            [defaults setObject:@"NO"forKey:@"ProfileComplete"];
            
        }
        else
        {
             [[me usr] setObject:@"YES" forKey:@"validated"];
            [defaults setObject:@"YES"forKey:@"ProfileComplete"];
        }
        [defaults synchronize];
        
    }
    //modification by charanjit starts
    if ([tagName isEqualToString:@"loginRequest"]) {
        
        NSLog(@"Response Login %@",responseString);
        //converting the result into Dictionary
        NSDictionary * result = [responseString JSONValue];
        NSLog(@"dict object %@",[result objectForKey:@"Result"]);
        //getting the token
        NSString * token = [result objectForKey:@"Result"];
        //storing the token
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        //setting the token in the user defaults
        [defaults setObject:token forKey:@"OAuthToken"];
        //syncing the defaults
        [defaults synchronize];
    }
    //modification by charanjit ends.
    
    
    
    if ([ServiceType isEqualToString:@"SMS"])
    {
        NSLog(@"%@",responseString);
    }
    
    }
   
[self.Delegate listen:responseString tagName:self.tagName];
}
#pragma mark - file paths
- (NSString *)autoLogin{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
    
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

//Vneturepact Code
-(void)validateInviteCode:(NSString *)inviteCode {
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:inviteCode forKey:@"RefCode"];
    [defaults synchronize];
    ServiceType=@"inviteCode";
    isCheckValidation=YES;
    self.responseData = [[NSMutableData alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@/validateInvitationCode",ServerUrl];
    NSURL *url = [NSURL URLWithString:urlString];
   emailParam=[[NSMutableDictionary alloc]init];
    [emailParam setObject:inviteCode forKey:@"invitationCode"];
    //NSDictionary*emailParam=[NSDictionary dictionaryWithObjectsAndKeys:inviteCode,@"invitationCode", nil];
  // emailParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:inviteCode,@"invitationCode" , nil];
    NSString *post = [emailParam JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getTotalReferralCode:(NSString *)inviteCode {
    //StringResult getTotalReferralCode(string referalCode, string accessToken);
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:inviteCode forKey:@"RefCode"];
    [defaults synchronize];
    
    
    self.responseData = [[NSMutableData alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@/getTotalReferralCode",ServerUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    emailParam=[[NSMutableDictionary alloc]init];
    [emailParam setObject:inviteCode forKey:@"referalCode"];
    //NSDictionary*emailParam=[NSDictionary dictionaryWithObjectsAndKeys:inviteCode,@"invitationCode", nil];
    // emailParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:inviteCode,@"invitationCode" , nil];
    NSString *post = [emailParam JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)ValidateBank:(NSString*)bankName routingNo:(NSString*)routingNumber
{
    ServiceType=@"ValidateBank";
    
    self.responseData = [[NSMutableData alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/ValidateBank",ServerUrl];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dictValidate=[[NSMutableDictionary alloc]init];
    
    [dictValidate setObject:bankName forKey:@"bankName"];
    [dictValidate setObject:routingNumber forKey:@"routingNumber"];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [dictValidate setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    [dictValidate setObject:[defaults valueForKey:@"MemberId"] forKey:@"memberId"];
    // NSString *post = [dictSMS JSONRepresentation];
    NSLog(@"%@",[dictValidate JSONRepresentation]);
    postDataRef = [[dictValidate JSONRepresentation] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    postLengthRef = [NSString stringWithFormat:@"%d", [postDataRef length]];
    
    requestRef = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [requestRef setHTTPMethod:@"POST"];
    
    [requestRef setValue:postLengthRef forHTTPHeaderField:@"Content-Length"];
    
    [requestRef setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [requestRef setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    
    [requestRef setHTTPBody:postDataRef];
    
    connectionRef = [[NSURLConnection alloc] initWithRequest:requestRef delegate:self];
    
    if (!connectionRef)
        
        NSLog(@"connect error");
}

-(void)SendSMSApi:(NSString*)phoneNo msg:(NSString*)msgText
{
    ServiceType=@"SMS";
    self.responseData = [[NSMutableData alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@/ApiSMS",ServerUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    dictSMS=[[NSMutableDictionary alloc]init];
    [dictSMS setObject:phoneNo forKey:@"phoneto"];
    [dictSMS setObject:msgText forKey:@"msg"];

    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [dictSMS setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
     [dictSMS setObject:[defaults valueForKey:@"MemberId"] forKey:@"memberId"];
   // NSString *post = [dictSMS JSONRepresentation];
    postDataSMS = [[dictSMS JSONRepresentation] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    postLengthSMS = [NSString stringWithFormat:@"%d", [postDataSMS length]];
    requestSMS = [[NSMutableURLRequest alloc] initWithURL:url];
    [requestSMS setHTTPMethod:@"POST"];
    [requestSMS setValue:postLengthSMS forHTTPHeaderField:@"Content-Length"];
    [requestSMS setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSMS setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    [requestSMS setHTTPBody:postDataSMS];
    connectionSMS = [[NSURLConnection alloc] initWithRequest:requestSMS delegate:self];
    if (!connectionSMS)
        NSLog(@"connect error");

}
-(void)getBankList
{
    ServiceType=@"GetBankList";
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetAllBanks?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
 
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetReferralCode:(NSString*)memberid

{
    
    ServiceType=@"ReferralCode";
    
    self.responseData = [[NSMutableData alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/getReferralCode",ServerUrl];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dictRef=[[NSMutableDictionary alloc]init];
    
    
    [dictRef setObject:memberid forKey:@"memberId"];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [dictRef setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    // NSString *post = [dictSMS JSONRepresentation];
    NSLog(@"%@",[dictRef JSONRepresentation]);
    postDataRef = [[dictRef JSONRepresentation] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    postLengthRef = [NSString stringWithFormat:@"%d", [postDataRef length]];
    
    requestRef = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [requestRef setHTTPMethod:@"POST"];
    
    [requestRef setValue:postLengthRef forHTTPHeaderField:@"Content-Length"];
    
    [requestRef setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [requestRef setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    
    [requestRef setHTTPBody:postDataRef];
    
    connectionRef = [[NSURLConnection alloc] initWithRequest:requestRef delegate:self];
    
    if (!connectionRef)
        
        NSLog(@"connect error");
    
    
    
}
-(void)getInvitedMemberList:(NSString*)memId
{
    
    
    self.responseData = [[NSMutableData alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/getInvitedMemberList",ServerUrl];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dictInv=[[NSMutableDictionary alloc]init];
    
    [dictInv setObject:memId forKey:@"memberId"];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [dictInv setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    // NSString *post = [dictSMS JSONRepresentation];
    NSLog(@"%@",[dictInv JSONRepresentation]);
    postDataInv = [[dictInv JSONRepresentation] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    postLengthInv = [NSString stringWithFormat:@"%d", [postDataInv length]];
    
    requestInv = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [requestInv setHTTPMethod:@"POST"];
    
    [requestInv setValue:postLengthInv forHTTPHeaderField:@"Content-Length"];
    
    [requestInv setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [requestInv setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    
    [requestInv setHTTPBody:postDataInv];
    
    connectionInv = [[NSURLConnection alloc] initWithRequest:requestInv delegate:self];
    
    if (!connectionInv)
        
        NSLog(@"connect error");
    

}


//Venturepact Edit
-(void)sendCsvTrasactionHistory:(NSString *)emailaddress {
    self.responseData = [[NSMutableData alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/sendTransactionInCSV",ServerUrl];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dictInv=[[NSMutableDictionary alloc]init];
    
    [dictInv setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"memberId"];
    [dictInv setObject:emailaddress forKey:@"toAddress"];
    
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [dictInv setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    // NSString *post = [dictSMS JSONRepresentation];
    NSLog(@"dict %@",[dictInv JSONRepresentation]);
    postDataInv = [[dictInv JSONRepresentation] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    postLengthInv = [NSString stringWithFormat:@"%d", [postDataInv length]];
    
    requestInv = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [requestInv setHTTPMethod:@"POST"];
    
    [requestInv setValue:postLengthInv forHTTPHeaderField:@"Content-Length"];
    
    [requestInv setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [requestInv setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    
    [requestInv setHTTPBody:postDataInv];
    
    connectionInv = [[NSURLConnection alloc] initWithRequest:requestInv delegate:self];
    
    if (!connectionInv)
        
        NSLog(@"connect error");

}

//charanjit's edit 26/11
-(void)getLocationBasedSearch:(NSString *)radius {
    ServiceType = @"LocationSearch";
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSString * memId = [defaults objectForKey:@"MemberId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetLocationSearch?memberId=%@&accessToken=%@&Radius=%@",ServerUrl,memId,[defaults valueForKey:@"OAuthToken"],radius];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetAllWithdrawalTrigger
{
   // ServiceType=@"GetBankList";
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
  //  NSString *urlString = [NSString stringWithFormat:@"%@/GetAllWithdrawalTrigger?accessToken=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"]];
    NSString *urlString = [NSString stringWithFormat:@"%@/GetAllWithdrawalTrigger?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[defaults valueForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void) GetAllWithdrawalFrequency
{
    //ServiceType=@"GetBankList";
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetAllWithdrawalFrequency?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[defaults valueForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void) LogOutRequest:(NSString*) memberId
{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/LogOutRequest?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],memberId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)SaveFrequency:(NSString*) withdrawalId type:(NSString*) type frequency: (float)withdrawalFrequency
{
 //accessToken
    self.responseData = [[NSMutableData alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/SaveFrequency",ServerUrl];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dictInv=[[NSMutableDictionary alloc]init];
    
    [dictInv setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"memberId"];
    [dictInv setObject:withdrawalId forKey:@"withdrawalId"];
     [dictInv setObject:type forKey:@"type"];
    //withdrawalFrequency
    [dictInv setObject:[NSString stringWithFormat:@"%f",withdrawalFrequency] forKey:@"withdrawalFrequency"];

    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [dictInv setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    // NSString *post = [dictSMS JSONRepresentation];
    NSLog(@"dict %@",[dictInv JSONRepresentation]);
    postDataInv = [[dictInv JSONRepresentation] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    postLengthInv = [NSString stringWithFormat:@"%d", [postDataInv length]];
    
    requestInv = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [requestInv setHTTPMethod:@"POST"];
    
    [requestInv setValue:postLengthInv forHTTPHeaderField:@"Content-Length"];
    
    [requestInv setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [requestInv setValue:@"charset" forHTTPHeaderField:@"UTF-8"];
    
    [requestInv setHTTPBody:postDataInv];
    
    connectionInv = [[NSURLConnection alloc] initWithRequest:requestInv delegate:self];
    
    if (!connectionInv)
        
        NSLog(@"connect error");
}
//  public StringResult GetMemberAutomaticWithdrawalOption(string memberId,string accessToken)
-(void)getAutoWithDrawalSelectedOption{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetMemberAutomaticWithdrawalOption?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetNonProfiltList{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetNonprofits?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)GetFeaturedNonprofit{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetFeaturedNonprofit?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetNonProfiltDetail:(NSString*)npId{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetNonprofitDetails?accessToken=%@&nonProfitMemberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],npId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
@end
