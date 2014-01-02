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
    
    [self.navigationItem setTitle:@"PIN Confirmation"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 60)];
    [title setText:@"Enter Your PIN to confirm your"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"pin_instructiontext"];
    [self.view addSubview:title];
    
    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 30)];
    [self.prompt setText:@"transfer"]; [self.prompt setTextAlignment:NSTextAlignmentCenter];
    [self.prompt setStyleId:@"pin_instructiontext_send"];
    [self.view addSubview:self.prompt];
    
    UIView *back = [UIView new];
    [back setStyleClass:@"raised_view"];
    [back setStyleClass:@"pin_recipientbox"];
    [self.view addSubview:back];
    
    UIView *bar = [UIView new];
    [bar setStyleClass:@"pin_recipientname_bar"];
    [self.view addSubview:bar];
    
    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 300, 30)];
    if ([[self.receiver objectForKey:@"FirstName"] length] == 0) {
        [to_label setText:@"   4K For Cancer"];
        [to_label setBackgroundColor:kNoochPurple];
    } else {
        [to_label setText:[NSString stringWithFormat:@" %@ %@",[self.receiver objectForKey:@"FirstName"],[self.receiver objectForKey:@"LastName"]]];
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
    if ([self.type isEqualToString:@"send"]) {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    }else if([self.type isEqualToString:@"request"]){
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;
    }
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}
#pragma mark-Location Tracker Delegates

- (void)locationUpdate:(CLLocation *)location{
    //dictLocation=[info copy];
    //self.selectedLocation=location;
	//NSString*current = [location description];
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
   // NSError *error = nil;
 //   NSString *htmlData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
   __block NSArray *jsonArray;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *data, NSError *err) {
        //NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSError * e;
        jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
        NSLog(@"RESPONSE %@",jsonArray);
    
    }];

    

  
    NSArray *placemark = [NSArray new];
    placemark = [[jsonArray objectAtIndex:0] objectForKey:@"results"];
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
        if ([addrParse count]>4) {
            addressLine1 = [addrParse objectAtIndex:0];
            addressLine2 = [addrParse objectAtIndex:1];
            city = [addrParse objectAtIndex:2];
            state = [[addrParse objectAtIndex:3] substringToIndex:3];
            zipcode = [[addrParse objectAtIndex:3] substringFromIndex:3];
            country = [addrParse objectAtIndex:4];
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
        }else if([self.type isEqualToString:@"request"]){
            which = kNoochBlue;
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
     
    NSLog(@"%@",dictResult);
    
     if ([tagName isEqualToString:@"ValidatePinNumber"]) {
     
     transactionInputTransfer=[[NSMutableDictionary alloc]init];
     
     // NSString *imageString;
     
     if ([[assist shared] getTranferImage]) {
     
         
     NSData *data = UIImagePNGRepresentation([[assist shared] getTranferImage]);
     
     NSUInteger len = data.length;
     
     uint8_t *bytes = (uint8_t *)[data bytes];
     
     NSMutableString *result1 = [NSMutableString stringWithCapacity:len * 3];
     
     //  [result1 appendString:@"["];
     
     for (NSUInteger i = 0; i < len; i++) {
     
     if (i) {
     
     [result1 appendString:@","];
     
     }
     
     [result1 appendFormat:@"%d", bytes[i]];
     
     }
     
     //[result1 appendString:@"]"];
     
     NSArray*arr=[result1 componentsSeparatedByString:@","];
     
     // NSLog(@"%@image",image64);
     
     [transactionInputTransfer setValue:arr forKey:@"Picture"];
     
     
     
     
     
     }
     
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
     
         NSString *TransactionDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterFullStyle];
         NSLog(@"%@",TransactionDate);
         
        
        
     
     [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
     
     
     
     [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
     
     [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
     
     [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
     
     
     
     [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
     
  //   [transactionInputTransfer setValue:altitudeField forKey:@"Altitude"];
         
         //            [self.addressOutlet setText:[dictionary valueForKey:@"Street"]];
         //            [self.cityOutlet setText:[dictionary valueForKey:@"City"]];
         //            [self.stateOutlet setText:[dictionary valueForKey:@"State"]];
         //            [self.zipOutlet setText:[dictionary valueForKey:@"ZIP"]];

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
         else{
             transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"transactionInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
         }
         
     }
     
     
     
     NSLog(@"Transaction %@", transactionTransfer);
     
   // NSError *error;
    
        NSLog(@"connect error");
    //postTransfer = [transactionTransfer JSONRepresentation];
    
   // postTransfer = [[transactionTransfer JSONRepresentation] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
   // postLengthTransfer = [NSString stringWithFormat:@"%d", [postDataTransfer length]];
    

    postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
          
                                                    options:NSJSONWritingPrettyPrinted error:&error];;
     
    NSLog(@"%@",postTransfer);
    
     //postDataTransfer = [postTransfer dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    //postTransfer = [transactionTransfer JSONRepresentation];
    
  //  postDataTransfer = [postTransfer dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
     
     
     
     self.respData = [NSMutableData data];
     
     urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
     
  
    
    if ([self.type isEqualToString:@"request"]) {
    
    urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoney"];
    
    }else{
 
  urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoney"];
  
    }
  
  
     
     urlTransfer = [NSURL URLWithString:urlStrTranfer];
     
     NSLog(@"transaction server call: %@",urlTransfer);
     
     
     
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
    responseString= [[NSString alloc] initWithData:self.respData encoding:NSASCIIStringEncoding];
    NSError* error;
    dictResultTransfer= [NSJSONSerialization
                 
                 JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                 
                 options:kNilOptions
                 
                 error:&error];

   
    NSLog(@"Array is : %@", dictResultTransfer);
//    if (requestRespond) {
//        requestRespond = NO;
//    }
    if ([self.type isEqualToString:@"send"]) {
        if (![[dictResultTransfer objectForKey:@"trnsactionId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"trnsactionId"];
    }else{
        if (![[dictResultTransfer objectForKey:@"requestId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"requestId"];
    }
    
    NSLog(@"transactionId %@",transactionId);
    
    resultValueTransfer = [dictResultTransfer valueForKey:@"TransferMoneyResult"];
    
    if ([[resultValueTransfer valueForKey:@"Result"] isEqualToString:@"Your cash was sent successfully"])
    {
        //[me histUpdate];
        int randNum = arc4random() % 12;
        NSString * sentMessage =[NSString stringWithFormat:@"You just sent money to %@, and you did it with style… and class.",receiverFirst] ;
        UIAlertView *av;
        switch (randNum) {
            case 0:
                av = [[UIAlertView alloc] initWithTitle:@"Nice Work" message:sentMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 1:
                av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your money has successfully been digitalized into pixie dust and is currently floating over our heads in a million pieces." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 2:
                av = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You have officially 'Nooched' %@. That's right, it's a verb.",receiverFirst] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 3:
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You now have less money." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 4:
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Your debt burden has been lifted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 5:
                av = [[UIAlertView alloc] initWithTitle:@"Money Sent" message:@"No need to thank us, it's our job." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 6:
                av = [[UIAlertView alloc] initWithTitle:@"Money Sent" message:@"You can close the app now. You're done." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 7:
                av = [[UIAlertView alloc] initWithTitle:@"You're Welcome" message:@"We did all the work here. Money sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 8:
                av = [[UIAlertView alloc] initWithTitle:@"Great Scott!" message:@"This sucker generated 1.21 gigawatts and sent your money, even without plutonium." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 9:
                av = [[UIAlertView alloc] initWithTitle:@"Knowledge Is Power" message:@"You know how easy Nooch is. But with great power, comes great responsibility..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 10:
                av = [[UIAlertView alloc] initWithTitle:@"Humpty Dumpty Sat on a Wall" message:@"And processed Nooch transfers." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 11:
                av = [[UIAlertView alloc] initWithTitle:@"Nooch Haiku" message:@"Nooch application. \nEasy, Simple, Convenient. \nGetting the job done." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            case 12:
                av = [[UIAlertView alloc] initWithTitle:@"Nooch Loves You" message:@"That is all." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
            default:
                av = [[UIAlertView alloc] initWithTitle:@"Nice Work" message:sentMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",@"Post to Facebook",@"Share on Twitter",nil];
                break;
        }
        [av show];
       // [backImage setHighlighted:NO];
        transferFinished = YES;
        sendingMoney = NO;
        [av setTag:1];
    }else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request processed successfully."]){
       // [me histUpdate];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Fulfilled" message:[NSString stringWithFormat:@"You successfully fulfilled %@'s request for %f.",receiverFirst,self.amnt] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully declined."]){
       // [me histUpdate];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Denied" message:[NSString stringWithFormat:@"You successfully denied %@'s request for %f.",receiverFirst,self.amnt] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully cancelled."]){
       // [me histUpdate];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Cancelled" message:[NSString stringWithFormat:@"You successfully cancelled your request for %f from %@.",self.amnt,receiverFirst] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }
   
    else if ([[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request made successfully."]){
       
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pay Me" message:[NSString stringWithFormat:@"You requested %f from %@ successfully.",self.amnt,receiverFirst] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",@"View Details",nil];
        [av setTag:1];
        [av show];
    }else if([[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]||[[dictResultTransfer valueForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
    {
       // [promptForPIN setHidden:YES];
        self.prompt.text=@"1 failed attempt. Please try again.";
         [self.fourth_num setBackgroundColor:[UIColor clearColor]];
         [self.third_num setBackgroundColor:[UIColor clearColor]];
         [self.second_num setBackgroundColor:[UIColor clearColor]];
         [self.first_num setBackgroundColor:[UIColor clearColor]];
    self.pin.text=@"";
      //  receiveBack.image = [UIImage imageNamed:@"PINfailBar.png"];
      //  [backImage setHighlighted:YES];
      //  PINText = @"";
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

//        prompt.text = @"3 failed attempt. Your account has been suspended.";
//        [promptForPIN setHidden:YES];
//        suspended = YES;
//        firstPIN.highlighted = NO;
//        secondPIN.highlighted = NO;
//        thirdPIN.highlighted = NO;
//        fourthPIN.highlighted = NO;
//        PINText = @"";
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
       // [self goBack];
    }else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Please go to 'My Account' menu and configure your account details."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sending money to non-Noochers is not yet supported."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
     //   [self goBack];
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
     //   [self goBack];
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
