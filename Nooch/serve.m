//
//  serve.m
//  Nooch
//
//  Created by Preston Hults on 2/6/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "serve.h"
#import "Home.h"
#import "Register.h"
#import "NSString+ASBase64.h"
#import "Constant.h"
#import "ECSlidingViewController.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+IdentifierAddition.h"

NSDictionary *transactionInputaddfund;
NSMutableURLRequest *requestmemid;
NSMutableURLRequest*requestList;
NSURLConnection*connectionList;
NSMutableURLRequest *requestS;
NSMutableDictionary*dictValidate;
NSDictionary*Dictresponse;

NSMutableURLRequest *requestMem;
NSMutableURLRequest *requestLogin;
NSURLConnection *connectionLogin;
NSData *postDataBNK;
NSString *postLengthBNK;
NSMutableURLRequest *requestBNK;
NSMutableDictionary*dictInv;

NSData *postDataInv;

NSString *postLengthInv;
NSMutableURLRequest *requestInv;
NSURLConnection *connectionInv;
NSString *postSet;
NSMutableURLRequest *requestSet;
NSData *postDataSet;
NSString *postLengthSet;
NSString *urlStrSet;
NSMutableURLRequest *requestgetbanks;
NSMutableURLRequest *requestdup;
NSMutableURLRequest *requestnewUser;
NSMutableURLRequest *requestEncryption;
NSMutableDictionary*dictRef;

NSData *postDataRef;
NSString *postLengthRef;
NSMutableURLRequest *requestRef;
NSURLConnection *connectionRef;

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
@synthesize Delegate,tagName,responseData;

NSString * const ServerUrl = @"https://www.noochme.com/NoochService/NoochService.svc";
//NSString * const ServerUrl = @"https://54.201.43.89/NoochService/NoochService.svc";// dev server

bool locationUpdate;
NSString *tranType;
NSString *amnt;

-(void)getSettings
{
    self.responseData = [NSMutableData data];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    requestS = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?id=%@&accessToken=%@", ServerUrl, @"GetMyDetails", [user objectForKey:@"MemberId"], [user valueForKey:@"OAuthToken"]
                                                                         ]]];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:requestS delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)getDetails:(NSString*)username
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    requestMem = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&accessToken=%@",ServerUrl,@"GetMemberDetails",username,[user valueForKey:@"OAuthToken"]]]];

    NSURLConnection * connection =[[NSURLConnection alloc] initWithRequest:requestMem delegate:self];

    if (!connection)
        NSLog(@"connect error");
}

-(void)forgotPass:(NSString *)email
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * urlString = [NSString stringWithFormat:@"%@/ForgotPassword", ServerUrl];
    NSURL * url = [NSURL URLWithString:urlString];

    NSDictionary * emailData = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)email,@"Input", nil];
    NSDictionary * emailParam = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)emailData,@"userName", nil];

    NSError *error;

    NSData * postData = [NSJSONSerialization dataWithJSONObject:emailParam
                                                       options:NSJSONWritingPrettyPrinted error:&error];

    NSString * postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)getEncrypt:(NSString *)input
{
    NSString * encodedString = [NSString encodeBase64String:input];
    
    self.responseData = [[NSMutableData alloc] init];
    requestEncryption = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl,@"GetEncryptedData",@"data",encodedString]]];
    [requestEncryption setHTTPMethod:@"GET"];
    [requestEncryption setTimeoutInterval:500.0f];

    NSURLConnection * connection =[[NSURLConnection alloc] initWithRequest:requestEncryption delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)getMemIdFromuUsername:(NSString*)username
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    requestmemid = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetMemberIdByUsername?userName=%@",ServerUrl,username
                                                                           ]]];
    NSURLConnection * connection =[[NSURLConnection alloc] initWithRequest:requestmemid delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)getMemIdFromPhoneNumber:(NSString*)phoneNumber
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    requestmemid = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetMemberIdByPhone?phoneNo=%@&accessToken=%@",ServerUrl,phoneNumber,[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:requestmemid delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)getMemberIds:(NSMutableArray*)input
{
    self.responseData = [[NSMutableData alloc] init];
    for (NSMutableDictionary *temp in input) {
        for (NSString *key in temp.allKeys) {
            if ([temp[key] isKindOfClass:[NSData class]]) {
                [temp removeObjectForKey:key];
            }
        }
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/GetMemberIds",ServerUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableDictionary *emailParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:input,@"phoneEmailList", nil];
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:emailParam,@"phoneEmailListDto", nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:entry
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
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

/*-(void)getNoteSettings
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    NSString *method=@"GetMemberNotificationSettings";
    NSString *parameter=@"memberId";
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&accessToken=%@",ServerUrl,method,parameter,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],[defaults valueForKey:@"OAuthToken"]]]];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}*/

-(void)getRecents
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetRecentMembers?id=%@&accessToken=%@",ServerUrl,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],[user valueForKey:@"OAuthToken"]]]];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)dupCheck:(NSString*)email
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [NSMutableData data];
    
    requestdup = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", ServerUrl, @"IsDuplicateMember", @"name", email]]];
    
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:requestdup delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)login:(NSString*)email password:(NSString*)pass remember:(BOOL)isRem lat:(float)lat lon:(float)lng
{
    [[assist shared] setSusPended:NO];
    ServiceType = @"Login";
   
    [user setObject:@"0" forKey:@"pincheck"];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.responseData = [[NSMutableData alloc] init];

    NSString * remember = (isRem) ? @"true" : @"false";

    if (isRem)
    {
        requestLogin = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/LoginRequest?name=%@&pwd=%@&rememberMeEnabled=%@&lat=%f&lng=%f&udid=%@&devicetoken=%@", ServerUrl,email,pass,remember,lat,lng,[user valueForKey:@"UUID"],[user valueForKey:@"DeviceToken"]]]];
    }

    [requestLogin setTimeoutInterval:10000];
    connectionLogin = [[NSURLConnection alloc] initWithRequest:requestLogin delegate:self];
    if (!connectionLogin)
        NSLog(@"connect error");
}

-(void)loginwithFB:(NSString*)email FBId:(NSString*)FBId remember:(BOOL)isRem lat:(float)lat lon:(float)lng
{
    [[assist shared] setSusPended:NO];
    ServiceType = @"Login";

    [user setObject:@"0" forKey:@"pincheck"];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    self.responseData = [[NSMutableData alloc] init];

    NSString * remember = (isRem) ? @"true" : @"false";

    requestLogin = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/LoginWithFacebook?userEmail=%@&FBId=%@&rememberMeEnabled=%@&lat=%f&lng=%f&udid=%@&devicetoken=%@", ServerUrl,email,FBId,remember,lat,lng,[user valueForKey:@"UUID"],[user valueForKey:@"DeviceToken"]]]];

    [requestLogin setTimeoutInterval:10000];
    connectionLogin = [[NSURLConnection alloc] initWithRequest:requestLogin delegate:self];
    if (!connectionLogin)
        NSLog(@"connect error");
}

-(void)setEmailSets:(NSDictionary*)notificationDictionary
{
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:notificationDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
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

-(void)setPushSets:(NSDictionary*)notificationDictionary
{
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:notificationDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
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

-(void)newUser:(NSString *)email first:(NSString *)fName last:(NSString *)lName password:(NSString *)password pin:(NSString*)pin invCode:(NSString*)inv fbId:(NSString *)fbId
{
    self.responseData = [NSMutableData data];

    NSString * UUID = [NSString stringWithFormat:@"%@-AAPL",[UIDevice currentDevice].identifierForVendor.UUIDString];
    [user setObject:UUID forKey:@"UUID"];

    NSMutableDictionary * dictnew = [[NSMutableDictionary alloc] init];
    [dictnew setObject:email forKey:@"UserName"];
    [dictnew setObject:fName forKey:@"FirstName"];
    [dictnew setObject:lName forKey:@"LastName"];
    [dictnew setObject:email forKey:@"SecondaryMail"];
    [dictnew setObject:email forKey:@"RecoveryMail"];
    [dictnew setObject:password forKey:@"Password"];
    [dictnew setObject:pin forKey:@"PinNumber"];
    [dictnew setObject:inv forKey:@"inviteCode"];
    [dictnew setObject:@"" forKey:@"friendRequestId"];
    [dictnew setObject:@"" forKey:@"invitedFriendFacebookId"];
    [dictnew setObject:fbId forKey:@"facebookAccountLogin"];
    [dictnew setObject:UUID forKey:@"UdId"]; // This is specifically for Device Fingerprinting (for Synapse). Since the user cannot have given permission for Push Notifications yet, we don't actually have the "deviceToken" for that purpose. We will store this value here as "UDID1" on the server.

    if ([[assist shared] getTranferImage])
    {
        NSData * data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
        NSUInteger len = data.length;
        uint8_t * bytes = (uint8_t *)[data bytes];
        NSMutableString * result1 = [NSMutableString stringWithCapacity:len * 3];

        for (NSUInteger i = 0; i < len; i++)
        {
            if (i) {
                [result1 appendString:@","];
            }
            [result1 appendFormat:@"%d", bytes[i]];
        }

        NSArray * arr = [result1 componentsSeparatedByString:@","];
        [dictnew setObject:arr forKey:@"Picture"];
    }

    NSDictionary * memDetails = [NSDictionary dictionaryWithObjectsAndKeys:dictnew,@"MemberDetails", nil];
    //NSLog(@"%@",memDetails);

    UIImage * img = [UIImage imageNamed:@""];
    [[assist shared]setTranferImage:img];
    [[assist shared]setTranferImage:nil];

    NSError *error;
    postDataSet = [NSJSONSerialization dataWithJSONObject:memDetails
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthSet = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataSet length]];
    urlStrSet = [[NSString alloc] initWithString:ServerUrl];
    urlStrSet = [urlStrSet stringByAppendingFormat:@"/%@", @"MemberRegistration"];
    NSURL *url = [NSURL URLWithString:urlStrSet];
    requestSet = [[NSMutableURLRequest alloc] initWithURL:url];
    [requestSet setHTTPMethod:@"POST"];
    [requestSet setValue:postLengthSet forHTTPHeaderField:@"Content-Length"];
    [requestSet setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSet setHTTPBody:postDataSet];
    [requestSet setTimeoutInterval:5000];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestSet delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)setSets:(NSDictionary*)settingsDictionary
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [NSMutableData data];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [settingsDictionary setValue:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    NSError *error;
    postDataSet = [NSJSONSerialization dataWithJSONObject:settingsDictionary
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthSet = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataSet length]];
    urlStrSet = [[NSString alloc] initWithString:ServerUrl];
    urlStrSet = [urlStrSet stringByAppendingFormat:@"/%@", @"MySettings"];
    NSURL *url = [NSURL URLWithString:urlStrSet];
    requestSet = [[NSMutableURLRequest alloc] initWithURL:url];
    [requestSet setHTTPMethod:@"POST"];
    [requestSet setValue:postLengthSet forHTTPHeaderField:@"Content-Length"];
    [requestSet setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSet setHTTPBody:postDataSet];
    [requestSet setTimeoutInterval:3600];

    //NSLog(@"%@  ....  %@",url,urlStrSet);

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestSet delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)resetPassword:(NSString*)old new:(NSString*)new
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@",ServerUrl,@"ResetPassword",@"memberId", [[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],@"newPassword",new]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)resetPIN:(NSString*)old new:(NSString*)new
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [NSMutableData data];

    NSString * memberStringID=@"memberId";
    NSString * newPin=@"newpin";
    NSString * oldPin=@"oldPin";

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&%@=%@",ServerUrl,@"ResetPin",memberStringID,[[NSUserDefaults standardUserDefaults]stringForKey:@"MemberId"],oldPin,old,newPin,new]]];

    NSURLConnection * connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)ValidatePinNumberToEnterForEnterForeground:(NSString*)memId pin:(NSString*)pin{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&accessToken=%@", ServerUrl, @"ValidatePinNumberToEnterForEnterForeground", @"memberId", memId, @"pinNo", pin,[[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"]]]];
    [request setTimeoutInterval:50.0f];

    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)pinCheck:(NSString*)memId pin:(NSString*)pin{
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@&accessToken=%@", ServerUrl, @"ValidatePinNumber", @"memberId", memId, @"pinNo", pin,[[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"]]]];
    [request setTimeoutInterval:50.0f];
    
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

-(void)verifyBank:(NSString *)bankAcctId microOne:(NSString *)microOne microTwo:(NSString *)microTwo{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?memberId=%@&bankAcctId=%@&microOne=%@&microTwo=%@&accessToken=%@", ServerUrl, @"VerifyBankAccount", [[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"], bankAcctId,microOne,microTwo,[[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"]]]];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied){
        NSLog(@"Error : %@",error);
    }
}
-(void) updateLocation:(NSString*)latitudeField longitudeField:(NSString*)longitudeField
{
    //http://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&sensor=true_or_false
    
    //  NSString *fetchURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true_or_false", latitudeField, longitudeField];
    NSString *fetchURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", latitudeField, longitudeField];
    NSURL *url = [NSURL URLWithString:fetchURL];
    NSError *error = nil;
    NSString *htmlData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:[htmlData dataUsingEncoding:NSUTF8StringEncoding]
                          
                          options:0
                          error:&error];
   
    NSArray *placemark = placemark = [json objectForKey:@"results"];
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

# pragma  mark - NSURL Delegate Methods

//response method for all request
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Serve.m Connect ERROR. Service Tag: %@.  Error: %@", self.tagName, error);

    [self.Delegate Error:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];

    //NSLog(@"Serve -> responseString is: %@",responseString);

    if ([responseString rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound)
    {
        //logout in case of invalid OAuth
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"pincheck"]isEqualToString:@"1"] ||
              [[NSUserDefaults standardUserDefaults] objectForKey:@"pincheck"])
        {
            if (![[assist shared] isloginFromOther])
            {
                [self.hud hide:YES];
                
                UIAlertView * Alert = [[UIAlertView alloc]initWithTitle:@"New Device Detected"
                                                                message:@"It looks like you have logged in from a new device.  To protect your account, we will just log you out of all other devices."
                                                               delegate:Nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [Alert show];

                Home * home1 = [Home new];
                [home1 hide];

                [[assist shared] setIsloginFromOther:YES];

                [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MemberId"];

                [timer invalidate];
                [nav_ctrl performSelector:@selector(disable)];
                [nav_ctrl performSelector:@selector(reset)];

                //NSLog(@"Serve -> nav_ctrl.viewControllers is: %@", nav_ctrl.viewControllers);
                NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];

                for (short i = [arrNav count]; i > 1; i--)
                {
                    [arrNav removeLastObject];
                }

                [nav_ctrl setViewControllers:arrNav animated:NO];

                Register *reg = [Register new];
                [nav_ctrl pushViewController:reg animated:YES];
                me = [core new];
            }

            return;

        }
        else if ([self.tagName isEqualToString:@"infopin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"pincheck"]isEqualToString:@"1"])
        {
            [self.Delegate listen:responseString tagName:self.tagName];
            return;
        }
    }

    else if ([tagName isEqualToString:@"info"])
    {
        NSError* error;
        Dictresponse = [NSJSONSerialization
                        JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];

        //NSLog(@"SERVE.M INFO DICTRESPONSE IS:  %@",Dictresponse);

        // LastLocationLat & LastLocationLng
        if (![[Dictresponse objectForKey:@"LastLocationLat"]isKindOfClass:[NSNull class]] &&
            ![[Dictresponse objectForKey:@"LastLocationLng"]isKindOfClass:[NSNull class]])
        {
            [user setObject:[Dictresponse objectForKey:@"LastLocationLat"] forKey:@"LastLat"];
            [user setObject:[Dictresponse objectForKey:@"LastLocationLng"] forKey:@"LastLng"];
        }

        // IsVerifiedPhone
        if ([[Dictresponse valueForKey:@"IsVerifiedPhone"]intValue])
        {
            [user setObject:@"YES" forKey:@"IsVerifiedPhone"];
        }
        else
        {
            [user setObject:@"NO" forKey:@"IsVerifiedPhone"];
        }

        // Status
        if ([[Dictresponse valueForKey:@"Status"]isEqualToString:@"Suspended"] ||
            [[Dictresponse valueForKey:@"Status"]isEqualToString:@"Temporarily_Blocked"])
        {
            [[assist shared] setSusPended:YES];
            [user setObject:@"Suspended" forKey:@"Status"];
        }
        else
        {
            [[assist shared] setSusPended:NO];
            [user setObject:[Dictresponse valueForKey:@"Status"] forKey:@"Status"];
        }

        // IsRequiredImmediatley
        if (  [Dictresponse valueForKey:@"IsRequiredImmediatley"] != NULL ||
            ![[Dictresponse valueForKey:@"IsRequiredImmediatley"]isKindOfClass:[NSNull class]])
        {
            if ([[Dictresponse valueForKey:@"IsRequiredImmediatley"]boolValue]) {
                [user setObject:@"YES" forKey:@"requiredImmediately"];
            }
            else
            {
                [user setObject:@"NO" forKey:@"requiredImmediately"];
            }
        }

        // IsBankAvailable (KNOX)
        if ( [Dictresponse valueForKey:@"IsKnoxBankAdded"] &&
            [[Dictresponse valueForKey:@"IsKnoxBankAdded"] boolValue] == YES)
        {
            [user setBool:YES forKey:@"IsKnoxBankAvailable"];
        }
        else
        {
            [user setBool:NO forKey:@"IsKnoxBankAvailable"];
        }

        // IsBankAvailable (SYNAPSE)
        if ( [Dictresponse valueForKey:@"IsSynapseBankAdded"] &&
            [[Dictresponse valueForKey:@"IsSynapseBankAdded"] boolValue] == YES)
        {
            [user setBool:YES forKey:@"IsSynapseBankAvailable"];

            if ( ![[Dictresponse valueForKey:@"SynapseBankStatus"]isKindOfClass:[NSNull class]] &&
                 [[[Dictresponse valueForKey:@"SynapseBankStatus"]lowercaseString]isEqualToString:@"verified"])
            {
                [user setBool:YES forKey:@"IsSynapseBankVerified"];
            }
            else
            {
                [user setBool:NO forKey:@"IsSynapseBankVerified"];
            }
        }
        else
        {
            [user setBool:NO forKey:@"IsSynapseBankAvailable"];
            [user setBool:NO forKey:@"IsSynapseBankVerified"];
        }


        // FirstName & LastName
        if (![[Dictresponse objectForKey:@"FirstName"] isKindOfClass:[NSNull class]] &&
              [Dictresponse objectForKey:@"FirstName"] != NULL)
        {
            [user setObject:[Dictresponse objectForKey:@"FirstName"] forKey:@"firstName"];
            [user setObject:[Dictresponse objectForKey:@"LastName"] forKey:@"lastName"];
        }
        else
        {
            [user setObject:@"" forKey:@"firstName"];
            [user setObject:@"" forKey:@"lastName"];
        }

        // facebook_id
        if ( [Dictresponse valueForKey:@"FacebookAccountLogin"] &&
            [[Dictresponse valueForKey:@"FacebookAccountLogin"]length] > 2)
        {
            [user setObject:[Dictresponse valueForKey:@"FacebookAccountLogin"] forKey:@"facebook_id"];
        }
        else
        {
            [user setObject:@"" forKey:@"facebook_id"];
        }

        // UserName
        if (  [Dictresponse objectForKey:@"UserName"] != NULL &&
            ![[Dictresponse objectForKey:@"UserName"] isKindOfClass:[NSNull class]])
        {
            [user setObject:[Dictresponse objectForKey:@"UserName"] forKey:@"UserName"];
        }

        // DateCreated
        if (  [Dictresponse valueForKey:@"DateCreated"] &&
            ([[user valueForKey:@"DateCreated"] isKindOfClass:[NSNull class]] ||
              [user valueForKey:@"DateCreated"] == NULL ||
             [[user valueForKey:@"DateCreated"] isEqualToString:@""] ||
            ![[user valueForKey:@"DateCreated"] isEqualToString:[Dictresponse valueForKey:@"DateCreated"]]))
        {
            [user setObject:[Dictresponse valueForKey:@"DateCreated"] forKey:@"DateCreated"];
        }

        // IsSSNAdded
        if ( [Dictresponse valueForKey:@"IsSSNAdded"] &&
            [[Dictresponse valueForKey:@"IsSSNAdded"] boolValue] == YES)
        {
            [user setBool:YES forKey:@"wasSsnAdded"];
        }
        else
        {
            [user setBool:NO forKey:@"wasSsnAdded"];
        }

        // Date of Birth
        if (  [Dictresponse objectForKey:@"DateOfBirth"] != NULL &&
            ![[Dictresponse objectForKey:@"DateOfBirth"] isKindOfClass:[NSNull class]])
        {
            [user setValue:[Dictresponse objectForKey:@"DateOfBirth"] forKey:@"dob"];
        }

        [user synchronize];
    }
    else if ([tagName isEqualToString:@"sets"])
    {        
        NSError * error;
        Dictresponse = [NSJSONSerialization
                        JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];

        //NSLog(@"SETS RESPONSE IS:  %@",Dictresponse);
        if (Dictresponse != NULL)
        {
            // FullyVerified
            if ([Dictresponse valueForKey:@"IsValidProfile"] &&
                [[Dictresponse valueForKey:@"IsValidProfile"] intValue])
            {
                [user setObject:@"1" forKey:@"FullyVerified"];
            }
            else {
                [user setObject:@"0" forKey:@"FullyVerified"];
            }

            // IsVerifiedPhone  -- ISVERIFIED PHONE ALREADY BEING STORED IN "INFO" SERVICE ABOVE, PROBABLY NOT NEEDED HERE ALSO
            if ([[Dictresponse valueForKey:@"IsVerifiedPhone"] intValue])
            {
                [user setObject:@"YES" forKey:@"IsVerifiedPhone"];
            }
            else
            {
                [user setObject:@"NO" forKey:@"IsVerifiedPhone"];
            }

            // ContactNumber
            if (  [Dictresponse valueForKey:@"ContactNumber"] &&
                ![[Dictresponse valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]])
            {
                [user setObject:[Dictresponse valueForKey:@"ContactNumber"] forKey:@"ContactNumber"];
            }

            // ProfileComplete
            if ([[Dictresponse valueForKey:@"ContactNumber"] isKindOfClass:[NSNull class]] ||
                [[Dictresponse valueForKey:@"Address"] isKindOfClass:[NSNull class]] ||
                [[Dictresponse valueForKey:@"City"] isKindOfClass:[NSNull class]] ||
                [[Dictresponse valueForKey:@"Zipcode"] isKindOfClass:[NSNull class]])
            {
                [user setObject:@"NO"forKey:@"ProfileComplete"];
            }
            else
            {
                [user setObject:@"YES"forKey:@"ProfileComplete"]; // Means user has added a Contact Number AND Street Address
            }

            [user synchronize];
        }
        else
        {
            NSLog(@"serve.m --> 'Sets' response from server was NULL:  %@",Dictresponse);

            [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];

            [timer invalidate];
            [nav_ctrl performSelector:@selector(disable)];
            [nav_ctrl performSelector:@selector(reset)];

            // Reset the values of all NSUserDefault items & keys
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[assist shared] setisloggedout:YES];

            NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];
            for (short i = [arrNav count]; i > 1; i--) {
                [arrNav removeLastObject];
            }
            
            [nav_ctrl setViewControllers:arrNav animated:NO];
            Register *reg = [Register new];
            [nav_ctrl pushViewController:reg animated:YES];
            me = [core new];
        }

    }
    else if ([tagName isEqualToString:@"login"] ||
             [tagName isEqualToString:@"loginwithFB"])
    {
        NSError * error;
        NSDictionary * result = [NSJSONSerialization
                                JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                options:kNilOptions
                                error:&error];
        //NSLog(@"Serve -> connectionDidFinishLoading -> Login: dict object %@",[result objectForKey:@"Result"]);
        //getting the token
        if ( [result objectForKey:@"Result"] &&
           ![[result objectForKey:@"Result"] isEqualToString:@"Invalid user id or password."] &&
           ![[result objectForKey:@"Result"] isEqualToString:@"Temporarily_Blocked"] &&
           ![[result objectForKey:@"Result"] isEqualToString:@"The password you have entered is incorrect."] &&
            [[result objectForKey:@"Result"] rangeOfString:@"Your account has been temporarily blocked."].location == NSNotFound &&
              result != nil && ![[result objectForKey:@"Result"] isEqualToString:@"FBID or EmailId not registered with Nooch"])
        {
            NSString * token = [result objectForKey:@"Result"];
            //storing the token
            //setting the token in the user defaults
            [user setObject:token forKey:@"OAuthToken"];
            //syncing the defaults
            [user synchronize];
        }
    }
    [self.Delegate listen:responseString tagName:self.tagName];
}

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)validateInviteCode:(NSString *)inviteCode
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
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
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:emailParam
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
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

-(void)getTotalReferralCode:(NSString *)inviteCode
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:inviteCode forKey:@"RefCode"];
    [defaults synchronize];

    self.responseData = [[NSMutableData alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@/getTotalReferralCode",ServerUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    emailParam=[[NSMutableDictionary alloc]init];
    [emailParam setObject:inviteCode forKey:@"referalCode"];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:emailParam
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
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

-(void)GetReferralCode:(NSString*)memberid
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    ServiceType = @"ReferralCode";

    self.responseData = [[NSMutableData alloc] init];

    NSString *urlString = [NSString stringWithFormat:@"%@/getReferralCode",ServerUrl];

    NSURL *url = [NSURL URLWithString:urlString];

    dictRef = [[NSMutableDictionary alloc] init];
    [dictRef setObject:memberid forKey:@"memberId"];
    [dictRef setObject:[user valueForKey:@"OAuthToken"] forKey:@"accessToken"];

    NSError *error;
    postDataRef = [NSJSONSerialization dataWithJSONObject:dictRef
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthRef = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataRef length]];
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
    
    NSString * urlString = [NSString stringWithFormat:@"%@/getInvitedMemberList",ServerUrl];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    dictInv = [[NSMutableDictionary alloc]init];
    [dictInv setObject:memId forKey:@"memberId"];

    [dictInv setObject:[user valueForKey:@"OAuthToken"] forKey:@"accessToken"];

    NSError *error;
    postDataInv = [NSJSONSerialization dataWithJSONObject:dictInv
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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

-(void)sendCsvTrasactionHistory:(NSString *)emailaddress
{
    self.responseData = [[NSMutableData alloc] init];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString * urlString = [NSString stringWithFormat:@"%@/sendTransactionInCSV",ServerUrl];
    NSURL * url = [NSURL URLWithString:urlString];

    dictInv = [[NSMutableDictionary alloc]init];
    [dictInv setObject:[user objectForKey:@"MemberId"] forKey:@"memberId"];
    [dictInv setObject:emailaddress forKey:@"toAddress"];
    [dictInv setObject:[user valueForKey:@"OAuthToken"] forKey:@"accessToken"];

    NSError *error;

    postDataInv = [NSJSONSerialization dataWithJSONObject:dictInv
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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

/*
//29/12
 -(void)GetFeaturedNonprofit{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString *urlString = [NSString stringWithFormat:@"%@/GetFeaturedNonprofit?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetNonProfiltList{
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString *urlString = [NSString stringWithFormat:@"%@/GetNonprofits?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetNonProfiltDetail:(NSString*)npId memberId:(NSString*)memberId
{
 self.responseData = [[NSMutableData alloc] init];
 NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
 [[NSURLCache sharedURLCache] removeAllCachedResponses];
 NSString *urlString = [NSString stringWithFormat:@"%@/GetNonprofitDetails?accessToken=%@&nonProfitMemberId=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],npId,memberId];
 NSURL *url = [NSURL URLWithString:urlString];
 
 requestList = [[NSMutableURLRequest alloc] initWithURL:url];
 
 connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
 if (!connectionList)
 NSLog(@"connect error");
}
-(void) GetAllWithdrawalFrequency
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];

    NSString *urlString = [NSString stringWithFormat:@"%@/GetAllWithdrawalFrequency?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[defaults valueForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)SaveFrequency:(NSString*) withdrawalId type:(NSString*) type frequency: (float)withdrawalFrequency
{
 self.responseData = [[NSMutableData alloc] init];
 [[NSURLCache sharedURLCache] removeAllCachedResponses];
 NSString *urlString = [NSString stringWithFormat:@"%@/SaveFrequency",ServerUrl];

 NSURL *url = [NSURL URLWithString:urlString];

 dictInv=[[NSMutableDictionary alloc]init];
 [dictInv setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"memberId"];
 [dictInv setObject:withdrawalId forKey:@"withdrawalId"];
 [dictInv setObject:type forKey:@"type"];
 [dictInv setObject:[NSString stringWithFormat:@"%f",withdrawalFrequency] forKey:@"withdrawalFrequency"];

 NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];

 [dictInv setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];

 NSError *error;
 postDataInv = [NSJSONSerialization dataWithJSONObject:dictInv
 options:NSJSONWritingPrettyPrinted error:&error];

 postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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
-(void)getAutoWithDrawalSelectedOption{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];

    NSString *urlString = [NSString stringWithFormat:@"%@/GetMemberAutomaticWithdrawalOption?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetAllWithdrawalTrigger
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];

    NSString *urlString = [NSString stringWithFormat:@"%@/GetAllWithdrawalTrigger?accessToken=%@&memberId=%@",ServerUrl, [defaults valueForKey:@"OAuthToken"],[defaults valueForKey:@"MemberId"]];
    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)getAptDetails:(NSString*) memberId
{}*/

-(void)get_favorites
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/GetMostFrequentFriends?MemberId=%@&accessToken=%@",ServerUrl,memId,[user valueForKey:@"OAuthToken"]];

    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)GetSynapseBankAccountDetails
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/GetSynapseBankAccountDetails?memberId=%@&accessToken=%@",ServerUrl,memId,[user valueForKey:@"OAuthToken"]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)getLocationBasedSearch:(NSString *)radius
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    ServiceType = @"LocationSearch";
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/GetLocationSearch?MemberId=%@&accessToken=%@&Radius=%@",ServerUrl,memId,[user valueForKey:@"OAuthToken"],radius];

    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)getPendingTransfersCount
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * urlString = [NSString stringWithFormat:@"%@/GetMemberPendingTransctionsCount?MemberId=%@&accesstoken=%@",ServerUrl,[user objectForKey:@"MemberId"],[user objectForKey:@"OAuthToken"]];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}
-(void)GetMemberStats:(NSString*)query
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];

    NSString * urlString = [NSString stringWithFormat:@"%@/GetMemberStats?memberId=%@&query=%@&accessToken=%@",ServerUrl,memId,query,[user valueForKey:@"OAuthToken"]];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)GetServerCurrentTime
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    responseData = [NSMutableData data];
    NSString * url = [NSString stringWithFormat:@"%@"@"/%@", ServerUrl, @"GetServerCurrentTime"];

    requestList = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)GetTransactionDetail:(NSString*)transactionId
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/GetsingleTransactionDetail?MemberId=%@&transactionId=%@&accessToken=%@",ServerUrl,memId,transactionId,[user valueForKey:@"OAuthToken"]];

    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len subType:(NSString*)subType
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    responseData = [NSMutableData data];
    NSString * url = [NSString stringWithFormat:@"%@"@"/%@?memberId=%@&listType=%@&SubListType=%@&%@=%@&%@=%@&accessToken=%@", ServerUrl, @"GetTransactionsList", [user valueForKey:@"MemberId"], type,subType, @"pSize", [NSString stringWithFormat:@"%ld",(long)len], @"pIndex", [NSString stringWithFormat:@"%ld",(long)sPos],[user valueForKey:@"OAuthToken"]];

    requestList = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)histMoreSerachbyName:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len name:(NSString*)name subType:(NSString*)subType
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    responseData = [NSMutableData data];

    NSString * url = [NSString stringWithFormat:@"%@"@"/%@?memberId=%@&listType=%@&sublist=%@&friendName=%@&%@=%@&%@=%@&accessToken=%@", ServerUrl, @"GetTransactionsSearchList", [user valueForKey:@"MemberId"], type,subType,name, @"pSize", [NSString stringWithFormat:@"%ld",(long)len], @"pIndex", [NSString stringWithFormat:@"%ld",(long)sPos],[user valueForKey:@"OAuthToken"]];

    requestList = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void) LogOutRequest:(NSString*)memberId
{
    self.responseData = [[NSMutableData alloc] init];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSString * urlString = [NSString stringWithFormat:@"%@/LogOutRequest?accessToken=%@&memberId=%@",ServerUrl, [user valueForKey:@"OAuthToken"],memberId];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)MemberNotificationSettings:(NSDictionary*) memberNotificationSettings type:(NSString*)type
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * servicePath;

    if ([type isEqualToString:@"push"])
    {
        servicePath = @"MemberPushNotificationSettings";
    }
    else
    {
        servicePath = @"MemberEmailNotificationSettings";
    }
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",ServerUrl,servicePath];
    NSURL * url = [NSURL URLWithString:urlString];

    dictInv = [[NSMutableDictionary alloc]init];
    [dictInv setObject:memberNotificationSettings forKey:@"memberNotificationSettings"];
    [dictInv setObject:[user valueForKey:@"OAuthToken"] forKey:@"accessToken"];

    NSError *error;

    postDataInv = [NSJSONSerialization dataWithJSONObject:dictInv
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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

-(void)MemberNotificationSettingsInput
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];

    NSString *urlString = [NSString stringWithFormat:@"%@/GetMemberNotificationSettings?memberId=%@&accessToken=%@",ServerUrl,memId,[user valueForKey:@"OAuthToken"]];

    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)TransferMoneyToNonNoochUser:(NSDictionary*)transactionInput email:(NSString*)email
{
    self.responseData = [[NSMutableData alloc] init];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSString * urlString = [NSString stringWithFormat:@"%@/TransferMoneyToNonNoochUser",ServerUrl];

    NSURL * url = [NSURL URLWithString:urlString];
    dictInv = [[NSMutableDictionary alloc]init];
    [dictInv setObject:transactionInput forKey:@"transactionInput"];
    [dictInv setObject:@"personal" forKey:@"inviteType"];
    [dictInv setObject:email forKey:@"receiverEmailId"];
    [dictInv setObject:[user valueForKey:@"OAuthToken"] forKey:@"accessToken"];

    NSError *error;
    postDataInv = [NSJSONSerialization dataWithJSONObject:dictInv
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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

-(void)SaveImmediateRequire:(BOOL)IsRequiredImmediatley
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * rm;
    if (IsRequiredImmediatley)
    {
        rm = @"true";
    }
    else
        rm = @"false";

    NSString * urlString = [NSString stringWithFormat:@"%@/SaveImmediateRequire?memberId=%@&IsRequiredImmediatley=%@&accessToken=%@",ServerUrl,memId,rm,[user valueForKey:@"OAuthToken"]];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];

    if (!connectionList)
        NSLog(@"connect error");
}

-(void)ReferalCodeRequest:(NSString*)email
{
    self.responseData = [[NSMutableData alloc] init];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSString * urlString = [NSString stringWithFormat:@"%@/ReferalCodeRequest?userName=%@",ServerUrl,email];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)RaiseDispute:(NSDictionary*)Input
{
    self.responseData = [[NSMutableData alloc] init];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSString * urlString = [NSString stringWithFormat:@"%@/RaiseDispute",ServerUrl];
    NSURL * url = [NSURL URLWithString:urlString];

    dictInv = [[NSMutableDictionary alloc]init];
    [dictInv setObject:Input forKey:@"raiseDisputeInput"];
    [dictInv setObject:[user valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    [dictInv setObject:[user objectForKey:@"MemberId"] forKey:@"memberId"];

    NSError *error;
    postDataInv = [NSJSONSerialization dataWithJSONObject:dictInv
                                                  options:NSJSONWritingPrettyPrinted error:&error];
    
    postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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

-(void)saveShareToFB_Twitter:(NSString*)PostTo
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/SaveSocialMediaPost?MemberId=%@&PostTo=%@&PostContent=%@&accessToken=%@",ServerUrl,memId,PostTo,PostTo,[user valueForKey:@"OAuthToken"]];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)UpDateLatLongOfUser:(NSString*)lat lng:(NSString*)lng
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/UpDateLatLongOfUser?memberId=%@&Lat=%@&Long=%@&accessToken=%@",ServerUrl,memId,lat,lng,[user valueForKey:@"OAuthToken"]];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)storeFB:(NSString*)fb_id isConnect:(NSString*)isconnect
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/SaveMembersFBId?MemberId=%@&MemberfaceBookId=%@&accessToken=%@&IsConnect=%@",ServerUrl,memId,fb_id,[user valueForKey:@"OAuthToken"],isconnect];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)CancelMoneyRequestForExistingNoochUser:(NSString*)transactionId
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.responseData = [[NSMutableData alloc] init];

    NSString * urlString = [NSString stringWithFormat:@"%@/CancelMoneyRequestForExistingNoochUser?TransactionId=%@&MemberId=%@",ServerUrl,transactionId,[user objectForKey:@"MemberId"]];
    NSURL * url = [NSURL URLWithString:urlString];
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)CancelMoneyRequestForNonNoochUser:(NSString *)transactionId
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * urlString = [NSString stringWithFormat:@"%@/CancelMoneyRequestForNonNoochUser?TransactionId=%@&MemberId=%@",ServerUrl,transactionId,[user objectForKey:@"MemberId"]];
    NSURL * url = [NSURL URLWithString:urlString];
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)CancelMoneyTransferToNonMemberForSender:(NSString *)transactionId
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.responseData = [[NSMutableData alloc] init];

    NSString * urlString = [NSString stringWithFormat:@"%@/CancelMoneyTransferToNonMemberForSender?TransactionId=%@&MemberId=%@",ServerUrl,transactionId,[user objectForKey:@"MemberId"]];
    NSURL * url = [NSURL URLWithString:urlString];
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)CancelRejectTransaction:(NSString*)transactionId resp:(NSString*)userResponse
{
    self.responseData = [[NSMutableData alloc] init];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSString *urlString = [NSString stringWithFormat:@"%@/CancelRejectTransaction",ServerUrl];

    NSURL *url = [NSURL URLWithString:urlString];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    dictInv = [[NSMutableDictionary alloc]init];
    [dictInv setObject:transactionId forKey:@"transactionId"];
    [dictInv setObject:userResponse forKey:@"userResponse"];
    [dictInv setObject:[defaults valueForKey:@"OAuthToken"] forKey:@"accessToken"];
    [dictInv setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"memberId"];

    NSError *error;
    postDataInv = [NSJSONSerialization dataWithJSONObject:dictInv
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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

#pragma mark Synapse Services
-(void)RemoveSynapseBankAccount
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/RemoveSynapseBankAccount?memberId=%@&accessToken=%@",ServerUrl,memId,[user valueForKey:@"OAuthToken"]];

    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

#pragma mark Reminder Services
-(void)SendReminderToRecepient:(NSString *)transactionId reminderType:(NSString*)reminderType
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * urlString = [NSString stringWithFormat:@"%@/SendTransactionReminderEmail?ReminderType=%@&MemberId=%@&accesstoken=%@&transactionId=%@",ServerUrl,reminderType,[defaults objectForKey:@"MemberId"],[defaults objectForKey:@"OAuthToken"],transactionId];
    NSURL * url = [NSURL URLWithString:urlString];
    
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)resendSMS
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@/ResendVerificationSMS?UserName=%@",ServerUrl,[defaults objectForKey:@"UserName"]];
    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)resendEmail
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * urlString = [NSString stringWithFormat:@"%@/ResendVerificationLink?UserName=%@",ServerUrl,[user objectForKey:@"UserName"]];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)show_in_search:(BOOL)show
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * urlString = [NSString stringWithFormat:@"%@/SetShowInSearch?memberId=%@&showInSearch=%@&accessToken=%@",ServerUrl,[user objectForKey:@"MemberId"],show ? @"YES" : @"NO", [user objectForKey:@"OAuthToken"]];
    NSURL * url = [NSURL URLWithString:urlString];
    requestList = [[NSMutableURLRequest alloc] initWithURL:url];

    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"connect error");
}

-(void)saveUserIpAddressAndDeviceId:(NSString*)IpAddress
{
    self.responseData = [[NSMutableData alloc] init];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSString * urlString = [NSString stringWithFormat:@"%@/UdateMemberIPAddress",ServerUrl];
    NSURL * url = [NSURL URLWithString:urlString];

    NSString * UUID = [NSString stringWithFormat:@"%@-AAPL",[UIDevice currentDevice].identifierForVendor.UUIDString];
    [user setObject:UUID forKey:@"UUID"];

    dictInv = [[NSMutableDictionary alloc] init];
    [dictInv setObject:[user objectForKey:@"MemberId"] forKey:@"MemberId"];
    [dictInv setObject:[user valueForKey:@"OAuthToken"] forKey:@"AccessToken"];
    [dictInv setObject:IpAddress forKey:@"IpAddress"];
    [dictInv setObject:UUID forKey:@"DeviceId"];

    NSMutableDictionary * entry = [[NSMutableDictionary alloc] init];
    [entry setObject:dictInv forKey:@"member"];

    NSError *error;

    postDataInv = [NSJSONSerialization dataWithJSONObject:entry
                                                  options:NSJSONWritingPrettyPrinted error:&error];

    postLengthInv = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataInv length]];

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

-(void)saveSsn:(NSString*)ssn
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/SaveMemberSSN?memberId=%@&accessToken=%@&SSN=%@",ServerUrl,memId,[user valueForKey:@"OAuthToken"],ssn];
    NSURL *url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"Connect Error: Save SSN");
}

-(void)saveDob:(NSString*)dob
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.responseData = [[NSMutableData alloc] init];

    NSString * memId = [user objectForKey:@"MemberId"];
    NSString * urlString = [NSString stringWithFormat:@"%@/SaveDOBForMember?memberId=%@&accessToken=%@&DOB=%@",ServerUrl,memId,[user valueForKey:@"OAuthToken"],dob];
    NSURL * url = [NSURL URLWithString:urlString];

    requestList = [[NSMutableURLRequest alloc] initWithURL:url];
    
    connectionList = [[NSURLConnection alloc] initWithRequest:requestList delegate:self];
    if (!connectionList)
        NSLog(@"Connect Error: Save DoB");
}

-(void)submitIdDocument
{
    self.responseData = [NSMutableData data];

    NSArray * picture;
    
    if ([[assist shared] getIdDocImage])
    {
        NSData * data = UIImagePNGRepresentation([[assist shared] getIdDocImage]);
        NSUInteger len = data.length;
        uint8_t * bytes = (uint8_t *)[data bytes];
        NSMutableString * result = [NSMutableString stringWithCapacity:len * 3];

        for (NSUInteger i = 0; i < len; i++)
        {
            if (i) {
                [result appendString:@","];
            }
            [result appendFormat:@"%d", bytes[i]];
        }

        picture = [result componentsSeparatedByString:@","];
    }
    NSDictionary * DocumentDetails = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      picture, @"Picture",
                                      [user objectForKey:@"MemberId"], @"MemberId",
                                      [user valueForKey:@"OAuthToken"],@"AccessToken", nil];

    NSMutableDictionary * finalPkg = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                                    DocumentDetails,@"DocumentDetails", nil];
    //    NSLog(@"Saving ID Doc -> DocumentDetails... finalPkg is:  %@",finalPkg);

    [[assist shared] setIdDocImage:nil];
    //https://www.noochme.com/NoochService/NoochService.svc/SaveVerificationIdDocument

    NSError *error;
    postDataSet = [NSJSONSerialization dataWithJSONObject:finalPkg
                                                  options:NSJSONWritingPrettyPrinted error:&error];
    postLengthSet = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataSet length]];
    urlStrSet = [[NSString alloc] initWithString:ServerUrl];
    urlStrSet = [urlStrSet stringByAppendingFormat:@"/%@", @"SaveVerificationIdDocument"];
    NSURL * url = [NSURL URLWithString:urlStrSet];
    requestSet = [[NSMutableURLRequest alloc] initWithURL:url];
    [requestSet setHTTPMethod:@"POST"];
    [requestSet setValue:postLengthSet forHTTPHeaderField:@"Content-Length"];
    [requestSet setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSet setHTTPBody:postDataSet];
    [requestSet setTimeoutInterval:4000];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestSet delegate:self];
    if (!connection)
        NSLog(@"connect error");
}

@end