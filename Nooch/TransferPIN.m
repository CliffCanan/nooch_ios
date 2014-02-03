//
//  TransferPIN.m
//  Nooch
//
//  Created by crks on 9/30/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "TransferPIN.h"
#import <QuartzCore/QuartzCore.h>
#import "GetLocation.h"
#import "TransactionDetails.h"
#import "UIImageView+WebCache.h"

@interface TransferPIN ()<GetLocationDelegate>
{
    GetLocation*getlocation;
}
@property(nonatomic,strong)NSMutableData*respData;
@property(nonatomic,strong) NSString *memo;
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSDictionary *receiver;
@property(nonatomic) float amnt;
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@property(nonatomic,strong) NSDictionary *trans;
@end

@implementation TransferPIN

- (id)initWithReceiver:(NSMutableDictionary *)receiver type:(NSString *)type amount:(float)amount
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        // Custom initialization
        receiverFirst=[receiver valueForKey:@"FirstName"];
        self.memo=[receiver valueForKey:@"memo"];
        self.type = type;
        self.receiver = receiver;
        self.amnt = amount;
        NSLog(@"%f",self.amnt);
        if ([type isEqualToString:@"donation"]) {
            receiverFirst=[receiver valueForKey:@"OrganizationName"];
        }
        else if ([type isEqualToString:@"addfund"]|| [type isEqualToString:@"withdrawfund"] ){
            receiverFirst=type;
            self.memo=[receiver valueForKey:@"memo"];
        }
        else if ([type isEqualToString:@"nonuser"]){
            // self.memo=@"";
            
            
        }
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    getlocation = [[GetLocation alloc] init];
	getlocation.delegate = self;
	[getlocation.locationManager startUpdatingLocation];
    
    // Do any additional setup after loading the view from its nib.
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:@"PIN Confirmation"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 60)];
    [title setText:@"Enter Your PIN to confirm your"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"pin_instructiontext"];
    [self.view addSubview:title];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 30)];
    if ([self.type isEqualToString:@"send"]||[self.receiver valueForKey:@"nonuser"]) {
        [self.prompt setText:@"transfer"];
        [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
    } else if ([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"]) {

                    [self.prompt setText:@"request"];
                    [self.prompt setStyleId:@"pin_instructiontext_request"];
    }
    else if ([self.type isEqualToString:@"addfund"])
             {
                 [self.prompt setText:@"Deposit"];
                 [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
             }
    else if ([self.type isEqualToString:@"withdrawfund"])
    {
        [self.prompt setText:@"withdraw"];
        [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
    }

    //addfund
    else {
                [self.prompt setText:@"donatation"];
                [self.prompt setStyleId:@"pin_instructiontext_donate"];
        }
    [self.prompt setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.prompt];



    
    UIView *back = [UIView new];
    [back setStyleClass:@"raised_view"];
    [back setStyleClass:@"pin_recipientbox"];
    [self.view addSubview:back];
    
    UIView *bar = [UIView new];
    [bar setStyleClass:@"pin_recipientname_bar"];
    if ([self.type isEqualToString:@"send"]|| [self.type isEqualToString:@"addfund"]|| [self.type isEqualToString:@"withdrawfund"]||[self.receiver valueForKey:@"nonuser"]) {
                [bar setStyleId:@"pin_recipientname_send"];
            }
    else if ([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"]) {
                    [bar setStyleId:@"pin_recipientname_request"];
                }
    else {
        
        [bar setStyleId:@"pin_recipientname_donate"];
      
    }

//    if ([self.type isEqualToString:@"send"]) {
//        [bar setStyleId:@"pin_recipientname_send"];
//    } else if ([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"]) {
//        [bar setStyleId:@"pin_recipientname_request"];
//    } else {
//        [bar setStyleId:@"pin_recipientname_donate"];
//    }
    [self.view addSubview:bar];
    
    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 300, 30)];
    if (![[self.receiver objectForKey:@"email"] length] == 0 && [self.receiver objectForKey:@"nonuser"]) {
        [to_label setText:[NSString stringWithFormat:@" %@",[self.receiver objectForKey:@"email"]]];
    }
    else
    {
        if ([[self.receiver objectForKey:@"FirstName"] length] == 0) {
            //[to_label setText:@"   4K For Cancer"];
            [to_label setBackgroundColor:kNoochPurple];
        } else {
            [to_label setText:[NSString stringWithFormat:@" %@ %@",[[self.receiver objectForKey:@"FirstName"] capitalizedString],[[self.receiver objectForKey:@"LastName"] capitalizedString]]];
        }
    }
    [to_label setStyleClass:@"pin_recipientname_text"];
    [self.view addSubview:to_label];
    
    UILabel *memo_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 230, 300, 30)];
    if ([[self.receiver objectForKey:@"memo"] length] > 0) {
        [memo_label setText:[self.receiver objectForKey:@"memo"]];
    }else{
        [memo_label setText:@"No memo attached"];
    }
    [memo_label setTextAlignment:NSTextAlignmentCenter];
    [memo_label setStyleClass:@"pin_memotext"];
    [self.view addSubview:memo_label];
    
    UIImageView *user_pic = [UIImageView new];
    [user_pic setFrame:CGRectMake(20, 204, 52, 52)];

    if ([self.receiver valueForKey:@"nonuser"]) {
        [user_pic setHidden:YES];
    }
    else{
        [user_pic setHidden:NO];
        
        if (self.receiver[@"Photo"]) {
            [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"Photo"]]
                     placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        }
        else
        {
            [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"PhotoUrl"]]
                     placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
        }
    }

    user_pic.layer.borderColor = [UIColor whiteColor].CGColor;
    user_pic.layer.borderWidth = 2; user_pic.clipsToBounds = YES;
    user_pic.layer.cornerRadius = 26;
    [self.view addSubview:user_pic];
    
    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 290, 30)];
    [total setBackgroundColor:[UIColor clearColor]];
    [total setTextColor:[UIColor whiteColor]]; [total setTextAlignment:NSTextAlignmentRight];
    [total setText:[NSString stringWithFormat:@"$ %.02f",self.amnt]];
    [total setStyleClass:@"pin_amountfield"];
    [self.view addSubview:total];
    
    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(44,70,32,32)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(107,70,32,32)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(170,70,32,32)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(233,70,32,32)];
    
    //self.first_num.alpha = self.second_num.alpha = self.third_num.alpha = self.fourth_num.alpha = 0.5;
    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 16;
    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;

   
    if ([self.type isEqualToString:@"send"]||[self.type isEqualToString:@"donation"]||[self.type isEqualToString:@"addfund"]||[self.type isEqualToString:@"withdrawfund"]||[self.receiver valueForKey:@"nonuser"]) {

        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
        
    }else if([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"]){
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;
        
    }
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}
#pragma mark-Location Tracker Delegates
- (void)locationUpdate:(CLLocation *)location{
    
    lat=location.coordinate.latitude;
    lon=location.coordinate.longitude;
    latitude=[NSString stringWithFormat:@"%f",lat];
    longitude=[NSString stringWithFormat:@"%f",lon];
    [self updateLocation:[NSString stringWithFormat:@"%f",lat] longitudeField:[NSString stringWithFormat:@"%f",lon]];
    
}
-(void) updateLocation:(NSString*)latitudeField longitudeField:(NSString*)longitudeField{
    
    NSLog(@"%@%@",longitudeField,latitudeField);
    
    NSString *fetchURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", latitudeField, longitudeField];
    NSURL *url = [NSURL URLWithString:fetchURL];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    __block NSArray *jsonArray;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *data, NSError *err) {
        //NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSError * e;
        jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
        NSLog(@"RESPONSE %@",jsonArray);
        [self setLocation];
    }];
    
    // latitude = latitudeField;
    //longitude = longitudeField;
    // locationUpdate = YES;
}
-(void)setLocation{
    NSLog(@"RESPONSE %@",jsonDictionary);
    NSArray *placemark = [NSArray new];
    placemark = [jsonDictionary  objectForKey:@"results"];
    if ([placemark count]>1) {
        NSString *addr = [[placemark  objectAtIndex:1]objectForKey:@"formatted_address"];
        
        NSArray *addrParse = [addr componentsSeparatedByString:@" "];
        NSLog(@"loc %@",addrParse);
        if ([addrParse count] == 4) {
            addressLine1 = [addrParse objectAtIndex:0];
            city = [addrParse objectAtIndex:1];
            state = [[addrParse objectAtIndex:2] substringToIndex:3];
            zipcode = [[addrParse objectAtIndex:2] substringFromIndex:3];
            country = [addrParse objectAtIndex:3];
        }else{
            if ([addrParse count]>4) {
                addressLine1 = [addrParse objectAtIndex:0];
                addressLine2 = [addrParse objectAtIndex:1];
                city = [addrParse objectAtIndex:2];
                state = [[addrParse objectAtIndex:3] substringToIndex:3];
                zipcode = [[addrParse objectAtIndex:3] substringFromIndex:3];
                country = [addrParse objectAtIndex:4];
            }
            
        }
        
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
    //    if (latitudeField == NULL || [latitudeField rangeOfString:@"null"].location != NSNotFound) {
    //        latitudeField = @"0.0";
    //    }
    //    if (longitudeField == NULL || [longitudeField rangeOfString:@"null"].location != NSNotFound) {
    //        longitudeField = @"0.0";
    //    }
    if (Altitude == NULL || [Altitude rangeOfString:@"null"].location != NSNotFound) {
        Altitude = @"0.0";
    }
    // NSLog(@"%@%@",latitudeField,longitudeField);
    
    // latitude = latitudeField;
    //longitude = longitudeField;
    // locationUpdate = YES;
}
- (void)locationError:(NSError *)error {
	//locationLabel.text = [error description];
}
#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int len = [textField.text length] + [string length];
    if([string length] == 0) //deleting
    {
        switch (len) {
            case 4:
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 3:
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 2:
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 1:
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 0:
                break;
            default:
                break;
        }
    }else{
        UIColor *which;
        if ([self.type isEqualToString:@"send"]) {
            which = kNoochGreen;
        }else if([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"]){
            which = kNoochBlue;
        }
        else if ([self.type isEqualToString:@"donation"]|| [self.type isEqualToString:@"addfund"]||[self.type isEqualToString:@"withdrawfund"]|| [self.type isEqualToString:@"nonuser"])
        {
            which = kNoochGreen;
        }
        switch (len) {
            case 5:
                return NO;
                break;
            case 4:
                [self.fourth_num setBackgroundColor:which];
                //start pin validation
                break;
            case 3:
                [self.third_num setBackgroundColor:which];
                break;
            case 2:
                [self.second_num setBackgroundColor:which];
                break;
            case 1:
                [self.first_num setBackgroundColor:which];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    
    if (len==4) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:spinner];
        spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [spinner startAnimating];
        
        serve *pin = [serve new];
        pin.Delegate = self;
        pin.tagName = @"ValidatePinNumber";
        [pin getEncrypt:[NSString stringWithFormat:@"%@%@",textField.text,string]];
    }
    return YES;
}
#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError* error;
    dictResult= [NSJSONSerialization
                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                 error:&error];
    
    if ([self.type isEqualToString:@"send"]|| [self.type isEqualToString:@"request"]) {
        
        
        
        
        
        
        if ([tagName isEqualToString:@"ValidatePinNumber"]) {
            transactionInputTransfer=[[NSMutableDictionary alloc]init];
            if ([[assist shared] getTranferImage]) {
                NSData *data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
                NSUInteger len = data.length;
                uint8_t *bytes = (uint8_t *)[data bytes];
                NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];
                for (NSUInteger i = 0; i < len; i++) {
                    if (i) {
                        [result1 appendString:@","];
                    }
                    [result1 appendFormat:@"%d", bytes[i]];
                }
                NSArray*arr=[result1 componentsSeparatedByString:@","];
                [transactionInputTransfer setValue:arr forKey:@"Picture"];
            }
            [[assist shared] setTranferImage:nil];
            UIImage*imgempty=[UIImage imageNamed:@""];
            [[assist shared] setTranferImage:imgempty];
            
            NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
            [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
            [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
            if ([self.type isEqualToString:@"request"]) {
                [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"SenderId"];
                [transactionInputTransfer setValue:@"Pending" forKey:@"Status"];
            }
            [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
            NSString *receiveName = [[self.receiver valueForKey:@"FirstName"] stringByAppendingString:[NSString stringWithFormat:@" %@",[self.receiver valueForKey:@"LastName"]]];
            [transactionInputTransfer setValue:receiveName forKey:@"Name"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            NSString *TransactionDate = [dateFormat stringFromDate:date];
            
            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
            if ([self.type isEqualToString:@"request"]) {
                transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"requestInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
            }
            else {
                transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
            }
        }
        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];;
        postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        if ([self.type isEqualToString:@"request"]) {
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoney"];
        }else{
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoney"];
        }
        urlTransfer = [NSURL URLWithString:urlStrTranfer];
        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        if (connection)
        {
            self.respData = [NSMutableData data];
        }
    }
    else if ([self.type isEqualToString:@"requestRespond"]) {
        transactionInputTransfer=[[NSMutableDictionary alloc]init];
        [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
        [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
        [transactionInputTransfer setValue:[self.trans objectForKey:@"TransactionId"] forKey:@"TransactionId"];
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSString *TransactionDate = [dateFormat stringFromDate:date];
        [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
        if ([[self.trans objectForKey:@"Response"] isEqualToString:@"accept"]) {
            [transactionInputTransfer setValue:@"ACCEPT" forKey:@"Status"];
        } else if ([[self.trans objectForKey:@"Response"] isEqualToString:@"deny"]){
            [transactionInputTransfer setValue:@"DENY" forKey:@"Status"];
        } else {
            //cancel
        }
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
        [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
        [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
        [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
        [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
        [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
        [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine2"];
        [transactionInputTransfer setValue:city forKey:@"City"];
        [transactionInputTransfer setValue:state forKey:@"State"];
        [transactionInputTransfer setValue:country forKey:@"Country"];
        [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
        [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
        
        transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"handleRequestInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];;
        postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"HandleRequestMoney"];
        urlTransfer = [NSURL URLWithString:urlStrTranfer];
        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        if (connection)
        {
            self.respData = [NSMutableData data];
        }
        return;
    }
    else if ([self.type isEqualToString:@"donation"]){
        if ([tagName isEqualToString:@"ValidatePinNumber"]) {
            transactionInputTransfer=[[NSMutableDictionary alloc]init];
            [transactionInputTransfer setValue:@"Donation" forKey:@"TransactionType"];
            NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
            [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
            [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
            [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
            NSString *receiveName = [[self.receiver valueForKey:@"FirstName"] stringByAppendingString:[NSString stringWithFormat:@" %@",[self.receiver valueForKey:@"LastName"]]];
            [transactionInputTransfer setValue:receiveName forKey:@"Name"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            NSString *TransactionDate = [dateFormat stringFromDate:date];
            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
            
            transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
        }
        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];
        postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoney"];
        urlTransfer = [NSURL URLWithString:urlStrTranfer];
        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        if (connection)
        {
            self.respData = [NSMutableData data];
        }
    }
    else if ([self.type isEqualToString:@"addfund"] || [self.type isEqualToString:@"withdrawfund"]) {
        if ([tagName isEqualToString:@"ValidatePinNumber"]) {
            NSString *encryptedPIN=[dictResult valueForKey:@"Status"];
            
            serve *checkValid = [serve new];
            checkValid.tagName = @"checkValid";
            checkValid.Delegate = self;
            [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
        }
        else if ([tagName isEqualToString:@"checkValid"]){
            if([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"]){
                if ([self.type isEqualToString:@"withdrawfund"]) {
                    transactionInputTransfer=[[NSMutableDictionary alloc]init];
                    [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
                    [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"RecepientId"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
                    
                    NSDate *date = [NSDate date];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                    NSString *TransactionDate = [dateFormat stringFromDate:date];
                    [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
                    [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
                    [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] forKey:@"DeviceId"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
                    [transactionInputTransfer setValue:Altitude forKey:@"Altitude"];
                    [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
                    [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
                    [transactionInputTransfer setValue:city forKey:@"City"];
                    [transactionInputTransfer setValue:state forKey:@"State"];
                    [transactionInputTransfer setValue:country forKey:@"Country"];
                    [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
                    transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"],@"accessToken"
                                           , nil];
                    postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                    
                                                                   options:NSJSONWritingPrettyPrinted error:&error];;
                    
                    
                    postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
                    self.respData = [NSMutableData data];
                    urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
                    
                    urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"WithdrawFund"];
                    
                    
                    urlTransfer = [NSURL URLWithString:urlStrTranfer];
                    
                    requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
                    
                    [requestTransfer setHTTPMethod:@"POST"];
                    
                    [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
                    
                    [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    
                    [requestTransfer setHTTPBody:postTransfer];
                    
                    
                    
                    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
                    
                    if (connection)
                        
                    {
                        
                        self.respData = [NSMutableData data];
                        
                    }
                    
                    
                }
                else if ([self.type isEqualToString:@"addfund"])
                {
                    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
                    //NSLog(@"latlon%@%@",self.Longitude,self.Latitude);
                    NSLog(@"oauthnd%@",[defaults valueForKey:@"OAuthToken"]);
                    transactionInputTransfer=[[NSMutableDictionary alloc]init];
                    [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
                    [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
                    [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
                    
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
                    
                    
                    NSDate *date = [NSDate date];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                    NSString *TransactionDate = [dateFormat stringFromDate:date];
                    
                    [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
                    [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
                    [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] forKey:@"DeviceId"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
                    
                    //[transactionInputTransfer setValue:self.Latitude forKey:@"Latitude"];
                    // [transactionInputTransfer setValue:self.Longitude forKey:@"Longitude"];
                    [transactionInputTransfer setValue:Altitude forKey:@"Altitude"];
                    [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
                    [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
                    [transactionInputTransfer setValue:city forKey:@"City"];
                    [transactionInputTransfer setValue:state forKey:@"State"];
                    [transactionInputTransfer setValue:country forKey:@"Country"];
                    [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
                    
                    //     transactionInputTransfer = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"MemberId", [[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"RecepientId", amount, @"Amount", TransactionDate, @"TransactionDate", @"false", @"IsPrePaidTransaction",  [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"], @"DeviceId", self.Latitude, @"Latitude", self.Longitude, @"Longitude", Altitude, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode", nil];
                    
                    transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[defaults valueForKey:@"OAuthToken"],@"accessToken", nil];
                    
                    postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                    
                                                                   options:NSJSONWritingPrettyPrinted error:&error];;
                    
                    
                    postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
                    self.respData = [NSMutableData data];
                    urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
                    
                    urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"AddFund"];
                    
                    
                    urlTransfer = [NSURL URLWithString:urlStrTranfer];
                    
                    requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
                    
                    [requestTransfer setHTTPMethod:@"POST"];
                    
                    [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
                    
                    [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    
                    [requestTransfer setHTTPBody:postTransfer];
                    
                    
                    
                    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
                    
                    if (connection)
                        
                    {
                        
                        self.respData = [NSMutableData data];
                        
                    }
                    
                }
                
            }else{
                
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                self.pin.text=@"";
            }
            
            if([[dictResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]){
                self.prompt.text=@"1 failed attempt. Please try again.";
                [spinner stopAnimating];
                [spinner setHidden:YES];
            }else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]){
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.prompt.text=@"2 Failed Attempts";
            }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.prompt.text=@"Account suspended.";
            }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.prompt.text=@"Account suspended.";
            }
            
        }
    }
    else if ([self.type isEqualToString:@"nonuser"]){
        if ([tagName isEqualToString:@"ValidatePinNumber"]) {
            encryptedPINNonUser=[dictResult valueForKey:@"Status"];
            
            serve *checkValid = [serve new];
            checkValid.tagName = @"checkValid";
            checkValid.Delegate = self;
            [checkValid pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPINNonUser];
        }
        else if ([tagName isEqualToString:@"checkValid"]){
            if([[dictResult objectForKey:@"Result"] isEqualToString:@"Success"]){
                transactionInputTransfer=[[NSMutableDictionary alloc]init];
                [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
                // [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
                
                [transactionInputTransfer setValue:encryptedPINNonUser forKey:@"PinNumber"];
                
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
                
                
                NSDate *date = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                NSString *TransactionDate = [dateFormat stringFromDate:date];
                
                [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
                [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
                [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] forKey:@"DeviceId"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
                
                //[transactionInputTransfer setValue:self.Latitude forKey:@"Latitude"];
                // [transactionInputTransfer setValue:self.Longitude forKey:@"Longitude"];
                [transactionInputTransfer setValue:Altitude forKey:@"Altitude"];
                [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
                [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
                [transactionInputTransfer setValue:city forKey:@"City"];
                [transactionInputTransfer setValue:state forKey:@"State"];
                [transactionInputTransfer setValue:country forKey:@"Country"];
                [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
                
                
                transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken",@"personal",@"inviteType",[self.receiver objectForKey:@"email"],@"receiverEmailId", nil];
                NSLog(@"%@",transactionTransfer);
                postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                
                                                               options:NSJSONWritingPrettyPrinted error:&error];;
                
                
                postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
                self.respData = [NSMutableData data];
                urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
                
                urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyToNonNoochUser"];
                
                
                urlTransfer = [NSURL URLWithString:urlStrTranfer];
                
                requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
                
                [requestTransfer setHTTPMethod:@"POST"];
                
                [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
                
                [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                
                [requestTransfer setHTTPBody:postTransfer];
                
                
                
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
                
                if (connection)
                    
                {
                    
                    self.respData = [NSMutableData data];
                    
                }
                
            }
            else
            {
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                self.pin.text=@"";
            }
            if([[dictResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]){
                self.prompt.text=@"1 failed attempt. Please try again.";
                [spinner stopAnimating];
                [spinner setHidden:YES];
            }else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]){
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.prompt.text=@"2 Failed Attempts";
            }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.prompt.text=@"Account suspended.";
            }else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.prompt.text=@"Account suspended.";
            }
            
        }
    }

    NSLog(@"%@",self.receiver[@"Photo"]);
    if (self.receiver[@"Photo"] !=NULL && ![self.receiver[@"Photo"] isKindOfClass:[NSNull class]]) {
        [transactionInputTransfer setObject:self.receiver[@"Photo"]forKey:@"Photo"];
    }
    

    self.trans = [transactionInputTransfer copy];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [nav_ctrl popToRootViewControllerAnimated:YES];
            
            
        }else if (buttonIndex == 1){
            [nav_ctrl popToRootViewControllerAnimated:NO];
            TransactionDetails *td = [[TransactionDetails alloc] initWithData:self.trans];
            [nav_ctrl pushViewController:td animated:YES];
        }
    }
}
#pragma mark - connection handling
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.respData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.respData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [spinner stopAnimating];
    [spinner setHidden:YES];
    responseString= [[NSString alloc] initWithData:self.respData encoding:NSASCIIStringEncoding];
    
    NSLog(@"response is %@",responseString);
    
    NSError* error;
    dictResultTransfer= [NSJSONSerialization
                         JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];
    NSLog(@"Array is : %@", dictResultTransfer);
    if ([self.type isEqualToString:@"nonuser"]) {
        if ([[[dictResultTransfer valueForKey:@"TransferMoneyToNonNoochUserResult"] valueForKey:@"Result"]isEqualToString:@"Your cash was sent successfully"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[[dictResultTransfer valueForKey:@"TransferMoneyToNonNoochUserResult"] valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
    }
    else if ([self.type isEqualToString:@"withdrawfund"]) {
        NSDictionary *resultValue = [dictResultTransfer valueForKey:@"WithDrawFundResult"];
        NSLog(@"resultValue is : %@", resultValue);
        
        if([[resultValue valueForKey:@"Result"] isEqualToString:[NSString stringWithFormat:@"You have withdrawn $%.02f from your nooch account successfully.",self.amnt ]])
        {
            NSString *alertTitleString = [NSString stringWithFormat:@"Success, your request to withdraw $"];
            NSString *amt = [NSString stringWithFormat:@"%.02f", self.amnt];
            alertTitleString = [alertTitleString stringByAppendingFormat:@"%@ from your Nooch account has been submitted.", amt];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:alertTitleString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        return;
    }
    else if ([self.type isEqualToString:@"addfund"]) {
        NSDictionary *resultValue = [dictResultTransfer valueForKey:@"AddFundResult"];
        NSLog(@"resultValue is : %@", dictResultTransfer);
        if([[resultValue valueForKey:@"Result"] isEqualToString:[NSString stringWithFormat:@"Fund you transferred has been added to your account successfully."]])
        {
            NSString *alertTitleString = [NSString stringWithFormat:@"Success, your request to deposit $"];
            NSString *amt = [NSString stringWithFormat:@"%.02f",self.amnt];
            alertTitleString = [alertTitleString stringByAppendingFormat:@"%@ from your Nooch account has been submitted.", amt];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:alertTitleString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        else if([[resultValue valueForKey:@"Result"] isEqualToString:[NSString stringWithFormat:@"Your bank account is not verified. Please verify your bank account now."]])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            //Your bank account is not verified. Please verify your bank account now.
        }
        else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    if ([self.type isEqualToString:@"send"]) {
        if (![[dictResultTransfer objectForKey:@"trnsactionId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"trnsactionId"];
    }else{
        if (![[dictResultTransfer objectForKey:@"requestId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"requestId"];
    }
    
    NSLog(@"transactionId %@",transactionId);

    //TransactionId
    if (![transactionId isKindOfClass:[NSNull class]] && transactionId!=NULL) {
        [transactionInputTransfer setObject:transactionId forKey:@"TransactionId"];
    }
    
    self.trans = [transactionInputTransfer copy];


    resultValueTransfer = [dictResultTransfer valueForKey:@"TransferMoneyResult"];
    if ([[resultValueTransfer valueForKey:@"Result"] isEqualToString:@"Your cash was sent successfully"])
    {
        int randNum = arc4random() % 12;
        NSString * sentMessage =[NSString stringWithFormat:@"You just sent money to %@, and you did it with style… and class.",receiverFirst] ;
        UIAlertView *av;
        switch (randNum) {
            case 0:
                av = [[UIAlertView alloc] initWithTitle:@"Nice Work" message:sentMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",nil];
                break;
            case 1:
                av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your money has successfully been digitalized into pixie dust and is currently floating over our heads in a million pieces." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",nil];
                break;
            case 2:
                av = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You have officially 'Nooched' %@. That's right, it's a verb.",receiverFirst] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 3:
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You now have less money." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 4:
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Your debt burden has been lifted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 5:
                av = [[UIAlertView alloc] initWithTitle:@"Money Sent" message:@"No need to thank us, it's our job." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 6:
                av = [[UIAlertView alloc] initWithTitle:@"Money Sent" message:@"You can close the app now. You're done." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 7:
                av = [[UIAlertView alloc] initWithTitle:@"You're Welcome" message:@"We did all the work here. Money sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 8:
                av = [[UIAlertView alloc] initWithTitle:@"Great Scott!" message:@"This sucker generated 1.21 gigawatts and sent your money, even without plutonium." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details", nil];
                break;
            case 9:
                av = [[UIAlertView alloc] initWithTitle:@"Knowledge Is Power" message:@"You know how easy Nooch is. But with great power, comes great responsibility..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 10:
                av = [[UIAlertView alloc] initWithTitle:@"Humpty Dumpty Sat on a Wall" message:@"And processed Nooch transfers." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details", nil];
                break;
            case 11:
                av = [[UIAlertView alloc] initWithTitle:@"Nooch Haiku" message:@"Nooch application. \nEasy, Simple, Convenient. \nGetting the job done." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 12:
                av = [[UIAlertView alloc] initWithTitle:@"Nooch Loves You" message:@"That is all." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",nil];
                break;
            default:
                av = [[UIAlertView alloc] initWithTitle:@"Nice Work" message:sentMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
        }
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
        [av setTag:1];
    }else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request processed successfully."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Fulfilled" message:[NSString stringWithFormat:@"You successfully fulfilled %@'s request for $%.02f.",[receiverFirst capitalizedString],self.amnt] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully declined."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Denied" message:[NSString stringWithFormat:@"You successfully denied %@'s request for $%.02f.",[receiverFirst capitalizedString],self.amnt] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully cancelled."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Cancelled" message:[NSString stringWithFormat:@"You successfully cancelled your request for $%.02f from %@.",self.amnt,[receiverFirst capitalizedString]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }
    else if ([[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request made successfully."]){
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pay Me" message:[NSString stringWithFormat:@"You requested $%.02f from %@ successfully.",self.amnt,[receiverFirst capitalizedString]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",@"View Details",nil];
        [av setTag:1];
        [av show];
    }else if([[[dictResultTransfer objectForKey:@"TransferMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]||[[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]||[[dictResultTransfer valueForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
    {
        self.prompt.text=@"1 failed attempt. Please try again.";
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";
    }
    else if([[resultValueTransfer valueForKey:@"Result"] isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]
            || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]
            || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
    {
        self.prompt.text=@"2 failed attempt. Please try again.";
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";
        
        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"Your account will be suspended for 24 hours if you enter another incorrect PIN." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [suspendedAlert show];
        [suspendedAlert setTag:9];
    }
    else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])
    {
        self.prompt.text=@"3 failed attempt. Please try again.";
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";
        
        
        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [suspendedAlert show];
        [suspendedAlert setTag:3];
        
    }else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Receiver does not exist."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sending money to non-Noochers is not yet supported."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
    }else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Please go to 'My Account' menu and configure your account details."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sending money to non-Noochers is not yet supported."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
    }else{
        NSString *resultValue = [dictResultTransfer objectForKey:@"RaiseDisputeResult"];
        if ([resultValue valueForKey:@"Result"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }else{
            NSString *resultValue = [dictResultTransfer objectForKey:@"HandleRequestMoneyResult"];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Oops" message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
