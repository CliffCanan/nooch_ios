//
//  serve.m
//  Nooch
//
//  Created by Preston Hults on 2/6/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "serve.h"
@implementation serve
@synthesize Delegate,tagName,responseData;
//NSString * const ServerUrl = @"https://74.117.228.120/NoochService.svc";
NSString * const ServerUrl = @"https://192.203.102.254/NoochService.svc";
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
    NSDictionary *transactionInput = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"MemberId", @"", @"RecepientId", amount, @"Amount", TransactionDate, @"TransactionDate", @"false", @"IsPrePaidTransaction",  [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"], @"DeviceId", Latitude, @"Latitude", Longitude, @"Longitude", Altitude, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode", nil];
    NSMutableDictionary *transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"transactionInput", nil];
    NSString *post = [transaction JSONRepresentation];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?id=%@", ServerUrl, @"GetMyDetails", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)deleteBank:(NSString*)bankId{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&bankAcctId=%@", ServerUrl, @"DeleteBankAccountDetails", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], bankId]]];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@", ServerUrl, @"GetBankAccountCollection", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getCards{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@", ServerUrl, @"GetCardAccountCollection", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getEncrypt:(NSString *)in{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl,@"GetEncryptedData",@"data",in]]];
    [request setTimeoutInterval:7.0f];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getDetails:(NSString*)username{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?name=%@",ServerUrl,@"GetMemberDetails",username]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
//-(void)getLatestTrans
-(void)getMemIdFromuUsername:(NSString*)username{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetMemberIdByUsername?name=%@",ServerUrl,username]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    self.responseData = [[NSMutableData alloc] init];
    NSString *method=@"GetMemberNotificationSettings";
    NSString *parameter=@"memberId";
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@",ServerUrl,method,parameter,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getTargus{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetMemberTargusScores?memberId=%@",ServerUrl,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)getRecents{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetRecentMembers?id=%@",ServerUrl,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)privacyPolicy{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl,@"GetTemplateContent",@"tempName",@"Privacy"]]];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl, @"IsDuplicateMember", @"name", email]]];
    //Load the request in the UIWebView.
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)login:(NSString*)email password:(NSString*)pass{
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@", ServerUrl, @"LoginRequest", @"name", email, @"pwd", pass]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"url %@",[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@", ServerUrl, @"LoginRequest", @"name", email, @"pwd", pass]);
    if (!connection)
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&deviceToken=%@", ServerUrl, @"MemberDevice",  [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],deviceToken]]];
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
    self.responseData = [[NSMutableData alloc] init];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?uName=%@&fName=%@&lName=%@&pwd=%@&pinNo=%@&deviceToken=%@&inviteCode=%@", ServerUrl,@"MemberRegistration", email, fName, lName,password, pin, deviceToken,inv]]];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}
-(void)setSets:(NSDictionary*)settingsDictionary{
    self.responseData = [NSMutableData data];
    NSString *post = [settingsDictionary JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString *urlStr = [[NSString alloc] initWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"MySettings"];
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
    NSString *post = [bankDetails JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString *urlStr = [[NSString alloc] initWithString:ServerUrl];
    urlStr = [urlStr stringByAppendingFormat:@"/%@", @"SaveBankAccountDetails"];
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
-(void)saveCard:(NSMutableDictionary*)cardDetails{
    self.responseData = [NSMutableData data];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@", ServerUrl, @"ValidatePinNumber", @"memberId", memId, @"pinNo", pin]]];
    [request setTimeoutInterval:7.0f];
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
    while ((!locationUpdate) &&
           ([loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate
                                                           distantFuture]]))
    {
        
    }
    NSMutableDictionary *transactionInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"MemberId", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"RecepientId", amount, @"Amount", TransactionDate, @"TransactionDate", @"false", @"IsPrePaidTransaction",  [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"], @"DeviceId", Latitude, @"Latitude", Longitude, @"Longitude", Altitude, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode", nil];
    NSMutableDictionary *transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"transactionInput", nil];
    NSString *post = [transaction JSONRepresentation];
    NSLog(@"transaction input %@",transaction);

    
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
    NSArray *addrParse = [addr componentsSeparatedByString:@","];
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
    Latitude = latitudeField;
    Longitude = longitudeField;
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
    /*self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [[connection originalRequest] mutableCopy];
    [request setTimeoutInterval:7.0f];
    NSURLConnection *connect =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connect)
        NSLog(@"connect error");*/
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (![tagName isEqualToString:@"info"]) {
        NSLog(@"serve connected for %@",self.tagName);
    }
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    [self.Delegate listen:responseString tagName:self.tagName];
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
