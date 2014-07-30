//  TransferPIN.m
//  Nooch
//
//  Copyright (c) 2014 Nooch. All rights reserved.

#import "TransferPIN.h"
#import <QuartzCore/QuartzCore.h>
#import "GetLocation.h"
#import "TransactionDetails.h"
#import "UIImageView+WebCache.h"
#import "SelectRecipient.h"
#import <AudioToolbox/AudioToolbox.h>
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
        if ([receiver valueForKey:@"memo"]) {
            self.memo=[receiver valueForKey:@"memo"];
        }
        else if ([receiver valueForKey:@"Memo"]) {
            self.memo=[receiver valueForKey:@"Memo"];
        }
        
        self.type = type;
        self.receiver = receiver;

        self.amnt = amount;
        //NSLog(@"%@",receiver);
//        if ([type isEqualToString:@"donation"]) {
//            receiverFirst=[receiver valueForKey:@"OrganizationName"];
//        }
//        else if ([type isEqualToString:@"addfund"]|| [type isEqualToString:@"withdrawfund"] ){
//            receiverFirst=type;
//            self.memo=[receiver valueForKey:@"memo"];
//        }
//        else if ([type isEqualToString:@"nonuser"]){
//            // self.memo=@"";
//        }
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //set right bar buton
    self.navigationController.navigationBar.topItem.title = @"";
    UIButton*balance = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [balance setFrame:CGRectMake(0, 0, 60, 30)];
    if ([user objectForKey:@"Balance"] && ![[user objectForKey:@"Balance"] isKindOfClass:[NSNull class]]&& [user objectForKey:@"Balance"]!=NULL) {
        
        [balance setTitle:[NSString stringWithFormat:@"$%@",[user objectForKey:@"Balance"]] forState:UIControlStateNormal];
        
    }

    getlocation = [[GetLocation alloc] init];
	getlocation.delegate = self;
	[getlocation.locationManager startUpdatingLocation];
    
    // Do any additional setup after loading the view from its nib.
    self.pin = [UITextField new]; [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self]; [self.pin setFrame:CGRectMake(800, 800, 20, 20)];
    [self.view addSubview:self.pin]; [self.pin becomeFirstResponder];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self.navigationItem setTitle:@"Enter PIN"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 60)];
    [title setText:@"Enter Your PIN to confirm your"]; [title setTextAlignment:NSTextAlignmentCenter];
    [title setNumberOfLines:2];
    [title setStyleClass:@"pin_instructiontext"];
    [self.view addSubview:title];

    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 30)];
    if ([self.type isEqualToString:@"send"]||[self.receiver valueForKey:@"nonuser"]|| [self.type isEqualToString:@"requestRespond"]) {
        if ([self.type isEqualToString:@"request"] && [self.receiver valueForKey:@"nonuser"]) {
            [self.prompt setText:@"request"];
            [self.prompt setStyleId:@"pin_instructiontext_request"];
        } else {
            [self.prompt setText:@"transfer"];
            [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
        }
    }
    else if ([self.type isEqualToString:@"request"] ) {    
        [self.prompt setText:@"request"];
        [self.prompt setStyleId:@"pin_instructiontext_request"];
    }
    else if ([self.type isEqualToString:@"addfund"]) {
        [self.prompt setText:@"Deposit"];
        [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
    }
    else if ([self.type isEqualToString:@"withdrawfund"]) {
        [self.prompt setText:@"withdraw"];
        [self.prompt setStyleId:@"Transferpin_instructiontext_send"];
    }
    
    //addfund
    else {
        [self.prompt setText:@"contribution"];
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
    if ([self.type isEqualToString:@"send"]|| [self.type isEqualToString:@"addfund"]|| [self.type isEqualToString:@"withdrawfund"]||[self.receiver valueForKey:@"nonuser"]|| [self.type isEqualToString:@"requestRespond"]) {
        if ([self.type isEqualToString:@"request"] && [self.receiver valueForKey:@"nonuser"]) {
             [bar setStyleId:@"pin_recipientname_request"];
        }
        [bar setStyleId:@"pin_recipientname_send"];
    }
    else if ([self.type isEqualToString:@"request"] ) {
        [bar setStyleId:@"pin_recipientname_request"];
    }
    else {
        [bar setStyleId:@"pin_recipientname_donate"];
    }
    [self.view addSubview:bar];

    UILabel *to_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 300, 30)];
    if (![[self.receiver objectForKey:@"email"] length] == 0 && [self.receiver objectForKey:@"nonuser"]) {
        [to_label setText:[NSString stringWithFormat:@" %@",[self.receiver objectForKey:@"email"]]];
    }
    else {
        if ([[assist shared] isRequestMultiple]) {
            NSString*strMultiple=@"";
            for (NSDictionary *dictRecord in [[assist shared]getArray]) {
                strMultiple=[strMultiple stringByAppendingString:[NSString stringWithFormat:@", %@",[dictRecord[@"FirstName"] capitalizedString]]];
            }
            strMultiple=[strMultiple substringFromIndex:1];
            [to_label setText:strMultiple];
        }
        else {
            if ([[self.receiver objectForKey:@"FirstName"] length] == 0) {
                //[to_label setText:@"   4K For Cancer"];
                [to_label setBackgroundColor:kNoochPurple];
            } 
            else {
                [to_label setText:[NSString stringWithFormat:@" %@ %@",[[self.receiver objectForKey:@"FirstName"] capitalizedString],[[self.receiver objectForKey:@"LastName"] capitalizedString]]];
            }
        }
    }
    [to_label setStyleClass:@"pin_recipientname_text"];
    [self.view addSubview:to_label];

    UILabel *memo_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 230, 300, 30)];
    if ([[self.receiver objectForKey:@"memo"] length] > 0) {
        [memo_label setText:[self.receiver objectForKey:@"memo"]];
    }
    else if ([[self.receiver objectForKey:@"Memo"] length] > 0) {
        [memo_label setText:[self.receiver objectForKey:@"Memo"]];
    }
    else {
        [memo_label setText:@"No memo attached"];
    }
    [memo_label setTextAlignment:NSTextAlignmentCenter];
    [memo_label setStyleClass:@"pin_memotext"];
    [self.view addSubview:memo_label];

    UIImageView *user_pic = [UIImageView new];
    [user_pic setFrame:CGRectMake(10, 205, 56, 56)];

    if ([self.receiver valueForKey:@"nonuser"]) {
        [user_pic setImage:[UIImage imageNamed:@"silhouette.png"]];
    }
    else {
        [user_pic setHidden:NO];
        if ([self.type isEqualToString:@"donation"]) {
            if (![[self.receiver valueForKey:@"BannerImage"]isKindOfClass:[NSNull class]]&&[self.receiver valueForKey:@"BannerImage"]!=NULL) {
                [user_pic setImageWithURL:[NSURL URLWithString:[self.receiver valueForKey:@"BannerImage"]]
                      placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
            }
            else {
                [user_pic setImage:[UIImage imageNamed:@"RoundLoading.png"]];
            }
        }
        else {
            if (self.receiver[@"Photo"]) {
                [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"Photo"]]
                         placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
            }
            else {
                [user_pic setImageWithURL:[NSURL URLWithString:self.receiver[@"PhotoUrl"]]
                placeholderImage:[UIImage imageNamed:@"RoundLoading.png"]];
            }
        }
    }
    user_pic.layer.borderColor = [UIColor whiteColor].CGColor;
    user_pic.layer.borderWidth = 2; user_pic.clipsToBounds = YES;
    user_pic.layer.cornerRadius = 27;
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
        if ([self.type isEqualToString:@"request"] && [self.receiver valueForKey:@"nonuser"]) {
            self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;
        }
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;        
    }
    else if([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"]){
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;    
    }
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
    
    if ([[assist shared] getTranferImage])
    {
        UIImageView *trans_image = [[UIImageView alloc] initWithFrame:CGRectMake(251, 206, 54, 54)];
        trans_image.layer.cornerRadius = 5;
        trans_image.layer.borderWidth = 1; trans_image.clipsToBounds = YES;
        trans_image.layer.borderColor = [UIColor whiteColor].CGColor;
        [trans_image setImage:[[assist shared] getTranferImage]];
        [self.view addSubview:trans_image];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Email cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [alert setTitle:@"Email saved"];
            [alert show];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"Email sent"];
            [alert show];
            break;
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
        // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

    // NSLog(@"%@%@",longitudeField,latitudeField);

    NSString *fetchURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", latitudeField, longitudeField];
    NSURL *url = [NSURL URLWithString:fetchURL];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *data, NSError *err) {
        //NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSError * e;
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
        // NSLog(@"RESPONSE %@",jsonDictionary);
        [self setLocation];
    }];
    
    // latitude = latitudeField;
    //longitude = longitudeField;
    // locationUpdate = YES;
}
-(void)setLocation{
    NSArray *placemark = [NSArray new];
    placemark = [jsonDictionary  objectForKey:@"results"];
    if ([placemark count]>0) {
        NSString *addr = [[placemark  objectAtIndex:1]objectForKey:@"formatted_address"];
        
        NSArray *addrParse = [addr componentsSeparatedByString:@","];
        //NSLog(@"loc %@",addrParse);
        if ([addrParse count] == 4) {
            addressLine1 = [addrParse objectAtIndex:0];
            city = [addrParse objectAtIndex:1];
            state = [[addrParse objectAtIndex:2] substringToIndex:3];
            zipcode = [[addrParse objectAtIndex:2] substringFromIndex:3];
            country = [addrParse objectAtIndex:3];
        }
        else if ([addrParse count]>4) {
            addressLine1 = [addrParse objectAtIndex:0];
            addressLine2 = [addrParse objectAtIndex:1];
            city = [addrParse objectAtIndex:2];
            state = [[addrParse objectAtIndex:3] substringToIndex:3];
            zipcode = [[addrParse objectAtIndex:3] substringFromIndex:3];
            country = [addrParse objectAtIndex:4];

        }
        else {
            addressLine1 = [addrParse objectAtIndex:0];
            addressLine2 = @"";
            city = [addrParse objectAtIndex:1];
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
    if (Altitude == NULL || [Altitude rangeOfString:@"null"].location != NSNotFound) {
        Altitude = @"0.0";
    }
}
- (void)locationError:(NSError *)error {
	//locationLabel.text = [error description];
}
#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.type isEqualToString:@"send"]||[self.type isEqualToString:@"donation"]||[self.type isEqualToString:@"addfund"]||[self.type isEqualToString:@"withdrawfund"]||[self.receiver valueForKey:@"nonuser"]) {
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochGreen.CGColor;
    }
    else if([self.type isEqualToString:@"request"] || [self.type isEqualToString:@"requestRespond"]){
        self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kNoochBlue.CGColor;
    }
    int len = [textField.text length] + [string length];
    if([string length] == 0) { //deleting {
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
    }
    else {
        UIColor *which;
        if ([self.type isEqualToString:@"send"]|| [self.type isEqualToString:@"requestRespond"]) {
            which = kNoochGreen;
        }
        else if([self.type isEqualToString:@"request"] ){
            which = kNoochBlue;
        } 
        else if ([self.type isEqualToString:@"donation"]|| [self.type isEqualToString:@"addfund"]||[self.type isEqualToString:@"withdrawfund"]|| [self.type isEqualToString:@"nonuser"]) {
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
    if ([self.receiver valueForKey:@"nonuser"]){
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
                [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
                // [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
                [transactionInputTransfer setValue:encryptedPINNonUser forKey:@"PinNumber"];
                [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
                
                NSDate *date = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
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
                if ([self.type isEqualToString:@"request"]) {
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
                    
                    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
                    
                    [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
                    [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
                    [transactionInputTransfer setValue:@"" forKey:@"SenderId"];
                    [transactionInputTransfer setValue:@"Pending" forKey:@"Status"];
                    
                    NSString *receiveName = [self.receiver valueForKey:@"email"];
                    [transactionInputTransfer setValue:receiveName forKey:@"Name"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
                    NSDate *date = [NSDate date];
                    // NSLog(@"%@",date);
                    
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
                    NSString *TransactionDate = [dateFormat stringFromDate:date];
                    
                    [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
                    [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
                    [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
                    [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
                    [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
                    [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
                    [transactionInputTransfer setValue:city forKey:@"City"];
                    [transactionInputTransfer setValue:state forKey:@"State"];
                    [transactionInputTransfer setValue:country forKey:@"Country"];
                    [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
                    [transactionInputTransfer setValue:self.memo forKey:@"Memo"];
                    
                    [transactionInputTransfer setObject:[self.receiver objectForKey:@"email"] forKey:@"MoneySenderEmailId"];
                    transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"requestInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
                    [transactionTransfer setObject:[self.receiver objectForKey:@"email"] forKey:@"MoneySenderEmailId"];
                }
                NSLog(@"%@ asdfasf %@",self.type,transactionTransfer);
                postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                               options:NSJSONWritingPrettyPrinted error:&error];;
                postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
                self.respData = [NSMutableData data];
                urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
                if ([self.type isEqualToString:@"request"]) {
                    urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoneyFromNonNoochUser"];
                } else {
                    urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyToNonNoochUserUsingKnox"];
                }
                urlTransfer = [NSURL URLWithString:urlStrTranfer];
                requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
                [requestTransfer setHTTPMethod:@"POST"];
                [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
                [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [requestTransfer setHTTPBody:postTransfer];
                requestTransfer.timeoutInterval=12000;
                
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
                if (connection) {
                    self.respData = [NSMutableData data];
                }
            }
            else {
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                self.pin.text=@"";
            }
            if([[dictResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]){
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                self.prompt.textColor = kNoochRed;
                self.fourth_num.layer.borderColor = kNoochRed.CGColor;
                self.third_num.layer.borderColor = kNoochRed.CGColor;
                self.second_num.layer.borderColor = kNoochRed.CGColor;
                self.first_num.layer.borderColor = kNoochRed.CGColor;
                [self.fourth_num setStyleClass:@"shakePin4"];
                [self.third_num setStyleClass:@"shakePin3"];
                [self.second_num setStyleClass:@"shakePin2"];
                [self.first_num setStyleClass:@"shakePin1"];
                self.prompt.text=@"1 failed attempt. Please try again.";
                self.prompt.textColor = [UIColor colorWithRed:169 green:68 blue:66 alpha:1];
                [spinner stopAnimating];
                [spinner setHidden:YES];
            }
            else if([[dictResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]){
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.fourth_num.layer.borderColor = kNoochRed.CGColor;
                self.third_num.layer.borderColor = kNoochRed.CGColor;
                self.second_num.layer.borderColor = kNoochRed.CGColor;
                self.first_num.layer.borderColor = kNoochRed.CGColor;
                [self.fourth_num setStyleClass:@"shakePin4"];
                [self.third_num setStyleClass:@"shakePin3"];
                [self.second_num setStyleClass:@"shakePin2"];
                [self.first_num setStyleClass:@"shakePin1"];
                self.prompt.text=@"2nd Failed Attempt";
            }
            else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
                [av setTag:50];
                [av show];
                [[assist shared] setSusPended:YES];
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.fourth_num.layer.borderColor = kNoochRed.CGColor;
                self.third_num.layer.borderColor = kNoochRed.CGColor;
                self.second_num.layer.borderColor = kNoochRed.CGColor;
                self.first_num.layer.borderColor = kNoochRed.CGColor;
                [self.fourth_num setStyleClass:@"shakePin4"];
                [self.third_num setStyleClass:@"shakePin3"];
                [self.second_num setStyleClass:@"shakePin2"];
                [self.first_num setStyleClass:@"shakePin1"];
                self.prompt.text=@"Account suspended.";
            }
            else if(([[dictResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Contact Support",nil];
                [av setTag:50];
                [av show];
                [[assist shared] setSusPended:YES];
                [spinner stopAnimating];
                [spinner setHidden:YES];
                self.prompt.text=@"Account suspended.";
            }
        }
    }
    else if ([self.type isEqualToString:@"send"]|| [self.type isEqualToString:@"request"]) {
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

            NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];

            [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
            [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
            if ([self.type isEqualToString:@"request"]) {
                [transactionInputTransfer setValue:@"Request" forKey:@"TransactionType"];
                if ([[assist shared]isRequestMultiple]) {
                    receiverId=@"";
                    for (NSDictionary *dictRecord in [[assist shared]getArray]) {
                        receiverId=[receiverId stringByAppendingString:[NSString stringWithFormat:@",%@",dictRecord[@"MemberId"]]];
                    }

                    receiverId=[receiverId substringFromIndex:1];
                    [transactionInputTransfer setValue:receiverId forKey:@"SenderId"];
                }
                else
                    [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"SenderId"];
                    [transactionInputTransfer setValue:@"Pending" forKey:@"Status"];
            }
            else {
                [transactionInputTransfer setValue:@"Transfer" forKey:@"TransactionType"];
                [transactionInputTransfer setValue:[self.receiver valueForKey:@"MemberId"] forKey:@"RecepientId"];
            }

            NSString *receiveName = [[self.receiver valueForKey:@"FirstName"] stringByAppendingString:[NSString stringWithFormat:@" %@",[self.receiver valueForKey:@"LastName"]]];
            [transactionInputTransfer setValue:receiveName forKey:@"Name"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%.02f",self.amnt] forKey:@"Amount"];
            NSDate *date = [NSDate date];
            // NSLog(@"%@",date);

            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
            NSString *TransactionDate = [dateFormat stringFromDate:date];

            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
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
        NSLog(@"%@",transactionTransfer);
        postTransfer = [NSJSONSerialization dataWithJSONObject:transactionTransfer
                                                       options:NSJSONWritingPrettyPrinted error:&error];;
        postLengthTransfer = [NSString stringWithFormat:@"%d", [postTransfer length]];
        self.respData = [NSMutableData data];
        urlStrTranfer = [[NSString alloc] initWithString:MyUrl];
        if ([self.type isEqualToString:@"request"]) {
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"RequestMoney"];
        }
        else{
            urlStrTranfer = [urlStrTranfer stringByAppendingFormat:@"/%@", @"TransferMoneyUsingKnox"];
        }
        urlTransfer = [NSURL URLWithString:urlStrTranfer];
        requestTransfer = [[NSMutableURLRequest alloc] initWithURL:urlTransfer];
        requestTransfer.timeoutInterval=12000;
        [requestTransfer setHTTPMethod:@"POST"];
        [requestTransfer setValue:postLengthTransfer forHTTPHeaderField:@"Content-Length"];
        [requestTransfer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestTransfer setHTTPBody:postTransfer];

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        if (connection) {
            self.respData = [NSMutableData data];
        }
    }
    else if ([self.type isEqualToString:@"requestRespond"]) {
        if ([tagName isEqualToString:@"ValidatePinNumber"]) {
            transactionInputTransfer=[[NSMutableDictionary alloc]init];
            [transactionInputTransfer setValue:[dictResult valueForKey:@"Status"] forKey:@"PinNumber"];
            [transactionInputTransfer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] forKey:@"MemberId"];
            [transactionInputTransfer setValue:[self.receiver objectForKey:@"TransactionId"] forKey:@"TransactionId"];
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];
            NSString *TransactionDate = [dateFormat stringFromDate:date];
            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            if ([[self.receiver objectForKey:@"response"] isEqualToString:@"accept"]) {
                [transactionInputTransfer setValue:@"Success" forKey:@"Status"];
            } 
            else if ([[self.receiver objectForKey:@"response"] isEqualToString:@"deny"]){
                [transactionInputTransfer setValue:@"Cancelled" forKey:@"Status"];
            }
            else {
                //cancel
            }
            NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
            [transactionInputTransfer setValue:@"RequestRespond" forKey:@"TransactionType"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
            [transactionInputTransfer setValue:city forKey:@"City"];
            [transactionInputTransfer setValue:state forKey:@"State"];
            [transactionInputTransfer setValue:country forKey:@"Country"];
            [transactionInputTransfer setValue:zipcode forKey:@"Zipcode"];
            [transactionInputTransfer setValue:self.memo forKey:@"Memo"];

            transactionTransfer = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInputTransfer, @"handleRequestInput",[[NSUserDefaults standardUserDefaults] valueForKey:@"OAuthToken"],@"accessToken", nil];
        }
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
        requestTransfer.timeoutInterval=12000;
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        if (connection) {
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
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SS"];

            NSString *TransactionDate = [dateFormat stringFromDate:date];
            [transactionInputTransfer setValue:TransactionDate forKey:@"TransactionDate"];
            [transactionInputTransfer setValue:@"false" forKey:@"IsPrePaidTransaction"];
            [transactionInputTransfer setValue:uid forKey:@"DeviceId"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [transactionInputTransfer setValue:[NSString stringWithFormat:@"%f",lon] forKey:@"Longitude"];
            [transactionInputTransfer setValue:addressLine1 forKey:@"AddressLine1"];
            [transactionInputTransfer setValue:addressLine2 forKey:@"AddressLine2"];
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
        requestTransfer.timeoutInterval=12000;
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestTransfer delegate:self];
        if (connection) {
            self.respData = [NSMutableData data];
        }
    }

    if (self.receiver[@"Photo"] !=NULL && ![self.receiver[@"Photo"] isKindOfClass:[NSNull class]]) {
        [transactionInputTransfer setObject:self.receiver[@"Photo"]forKey:@"Photo"];
    }
    else if (self.receiver[@"PhotoUrl"] !=NULL && ![self.receiver[@"PhotoUrl"] isKindOfClass:[NSNull class]])
        [transactionInputTransfer setObject:self.receiver[@"PhotoUrl"]forKey:@"Photo"];
    if ([self.type isEqualToString:@"donation"] && self.receiver[@"PhotoIcon"]!=NULL && ![self.receiver[@"PhotoIcon"] isKindOfClass:[NSNull class]]) {
        [transactionInputTransfer setObject:self.receiver[@"PhotoIcon"]forKey:@"Photo"];
    }
    self.trans = [transactionInputTransfer copy];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [nav_ctrl popToRootViewControllerAnimated:YES];

        }
        else if (buttonIndex == 1){
            [nav_ctrl popToRootViewControllerAnimated:NO];
            //NSLog(@"%@",self.trans);
            NSMutableDictionary *input = [self.trans mutableCopy];
            if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Request"] && [[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]]) {
                NSString*MemberId=[input valueForKey:@"MemberId"];
                NSString*ResID=[input valueForKey:@"SenderId"];
                [input setObject:MemberId forKey:@"RecepientId"];
                [input setObject:ResID forKey:@"MemberId"];
                NSLog(@"%@",input);
                [input setObject:dictResultTransfer[@"requestId"] forKey:@"TransactionId"];
                // [input setObject:ResID forKey:@"SenderId"];
            }
            else  if ([self.type isEqualToString:@"send"]) {
                 [input setObject:dictResultTransfer[@"trnsactionId"] forKey:@"TransactionId"];
            }
            if ([self.receiver objectForKey:@"nonuser"]) {
                [input setObject:@"Invite" forKey:@"TransactionType"];
                [input setObject:dictResultTransfer[@"trnsactionId"] forKey:@"TransactionId"];
                [input setObject:[self.receiver objectForKey:@"email"] forKey:@"InvitationSentTo"];
            }
              NSLog(@"%@",input);
            TransactionDetails *td = [[TransactionDetails alloc] initWithData:input];
            [nav_ctrl pushViewController:td animated:YES];
        }
    }
    else if (alertView.tag==2500) {
        if (buttonIndex == 0) {
            [nav_ctrl popToRootViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag==20230) {
        if (buttonIndex == 0) {
            [nav_ctrl popToRootViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 50 && buttonIndex == 1) {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Email Detected" message:@"You don't have a mail account configured for this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:mailComposer animated:YES completion:nil];
    } else if (alertView.tag == 50 && buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    NSError* error;
    dictResultTransfer= [NSJSONSerialization
                         JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                         options:kNilOptions
                         error:&error];
   
    
    NSLog(@"%@",responseString);
    if ([self.receiver valueForKey:@"nonuser"]) {
        
        if ([[[dictResultTransfer valueForKey:@"TransferMoneyToNonNoochUserUsingKnoxResult"] valueForKey:@"Result"]isEqualToString:@"Your cash was sent successfully"]) {
            [[assist shared] setTranferImage:nil];
            UIImage*imgempty=[UIImage imageNamed:@""];
            [[assist shared] setTranferImage:imgempty];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your transfer was sent successfully.  The recipient must accept this payment by linking a bank account.  We will contact them and let you know when they respond." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",nil];
            av.tag=1;
            [av show];
            return;
        }
    }
    
    if ([self.type isEqualToString:@"send"]) {
        if (![[dictResultTransfer objectForKey:@"trnsactionId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"trnsactionId"];
        NSLog(@"%@",transactionId);
    }
    else if([self.type isEqualToString:@"request"]) {
        if (![[dictResultTransfer objectForKey:@"requestId"] isKindOfClass:[NSNull class]])
            transactionId=[dictResultTransfer valueForKey:@"requestId"];
    }

    
    if ([self.receiver valueForKey:@"FirstName"]!=NULL || [self.receiver valueForKey:@"LastName"]!=NULL) {
        [transactionInputTransfer setObject:[self.receiver valueForKey:@"FirstName"] forKey:@"FirstName"];
        [transactionInputTransfer setObject:[self.receiver valueForKey:@"LastName"] forKey:@"LastName"];
        
    }
    self.trans = [transactionInputTransfer copy];
    resultValueTransfer = [dictResultTransfer valueForKey:@"TransferMoneyUsingKnoxResult"];
     if ([[resultValueTransfer valueForKey:@"Result"] isEqualToString:@"Recepient does not have any active bank account."]) {
         UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Transfer Failed" message:@"Recepient does not have any active bank account." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        
         [av show];

     }
    else if ([[resultValueTransfer valueForKey:@"Result"] isEqualToString:@"Your cash was sent successfully"]) {
        [[assist shared] setTranferImage:nil];
        UIImage*imgempty=[UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];
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
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You now have less money. Eh, it's just money." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 4:
                av = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Your debt burden has been lifted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 5:
                av = [[UIAlertView alloc] initWithTitle:@"Money Sent" message:@"No need to thank us, it's our job." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 6:
                av = [[UIAlertView alloc] initWithTitle:@"Money Sent" message:@"You are now free to close the app and put your phone away. You're done." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
            case 7:
                av = [[UIAlertView alloc] initWithTitle:@"You're Welcome" message:@"That was some good Nooching. Money sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
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
                av = [[UIAlertView alloc] initWithTitle:@"Nooch Loves You" message:@"That is all. Pay it forward. \n ...get it?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details",nil];
                break;
            default:
                av = [[UIAlertView alloc] initWithTitle:@"Nice Work" message:sentMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View Details" ,nil];
                break;
        }
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
        [av setTag:1];
        
    }
    else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request processed successfully."]) {
        [[assist shared] setTranferImage:nil];
        UIImage*imgempty=[UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Fulfilled" message:[NSString stringWithFormat:@"You successfully fulfilled %@'s request for $%.02f.",[receiverFirst capitalizedString],self.amnt] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }
    else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully declined."]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Denied" message:[NSString stringWithFormat:@"You successfully denied %@'s request for $%.02f.",[receiverFirst capitalizedString],self.amnt] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }
    else if ([[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully cancelled."]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Cancelled" message:[NSString stringWithFormat:@"You successfully cancelled your request for $%.02f from %@.",self.amnt,[receiverFirst capitalizedString]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }
    else if ([[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request made successfully."]) {
        [[assist shared] setTranferImage:nil];
        UIImage*imgempty=[UIImage imageNamed:@""];
        [[assist shared] setTranferImage:imgempty];

        if ([[assist shared]isRequestMultiple]) {
            // NSLog(@"%@",arrRecipientsForRequest);
            [[assist shared]setRequestMultiple:NO];
            NSString*strMultiple=@"";
            for (NSDictionary *dictRecord in [[assist shared]getArray]) {
                strMultiple=[strMultiple stringByAppendingString:[NSString stringWithFormat:@", %@",[dictRecord[@"FirstName"] capitalizedString]]];
            }

            strMultiple=[strMultiple substringFromIndex:1];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pay Me" message:[NSString stringWithFormat:@"You requested $%.02f from %@ successfully.",self.amnt,strMultiple] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            [av setTag:1];
            [av show];
        }
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pay Me" message:[NSString stringWithFormat:@"You requested $%.02f from %@ successfully.",self.amnt,[receiverFirst capitalizedString]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",@"View Details",nil];
            [av setTag:1];
            [av show];
        }
    }
    else if([[[dictResultTransfer objectForKey:@"TransferMoneyUsingKnoxResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]||[[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]||[[dictResultTransfer valueForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        self.prompt.textColor = kNoochRed;
        self.fourth_num.layer.borderColor = kNoochRed.CGColor;
        self.third_num.layer.borderColor = kNoochRed.CGColor;
        self.second_num.layer.borderColor = kNoochRed.CGColor;
        self.first_num.layer.borderColor = kNoochRed.CGColor;
        [self.fourth_num setStyleClass:@"shakePin4"];
        [self.third_num setStyleClass:@"shakePin3"];
        [self.second_num setStyleClass:@"shakePin2"];
        [self.first_num setStyleClass:@"shakePin1"];
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
        self.prompt.text=@"2nd failed attempt.";
        self.fourth_num.layer.borderColor = kNoochRed.CGColor;
        self.third_num.layer.borderColor = kNoochRed.CGColor;
        self.second_num.layer.borderColor = kNoochRed.CGColor;
        self.first_num.layer.borderColor = kNoochRed.CGColor;
        [self.fourth_num setStyleClass:@"shakePin4"];
        [self.third_num setStyleClass:@"shakePin3"];
        [self.second_num setStyleClass:@"shakePin2"];
        [self.first_num setStyleClass:@"shakePin1"];
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";

        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"To protect your money, your Nooch account will be suspended for 24 hours if you enter another incorrect PIN." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [suspendedAlert show];
        [suspendedAlert setTag:9];
    }
    else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])
    {
        [[assist shared]setSusPended:YES];
        self.prompt.text=@"3rd failed attempt.";
        self.fourth_num.layer.borderColor = kNoochRed.CGColor;
        self.third_num.layer.borderColor = kNoochRed.CGColor;
        self.second_num.layer.borderColor = kNoochRed.CGColor;
        self.first_num.layer.borderColor = kNoochRed.CGColor;
        [self.fourth_num setStyleClass:@"shakePin4"];
        [self.third_num setStyleClass:@"shakePin3"];
        [self.second_num setStyleClass:@"shakePin2"];
        [self.first_num setStyleClass:@"shakePin1"];
        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
        [self.third_num setBackgroundColor:[UIColor clearColor]];
        [self.second_num setBackgroundColor:[UIColor clearColor]];
        [self.first_num setBackgroundColor:[UIColor clearColor]];
        self.pin.text=@"";

        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"We're terribly sorry, but to keep Nooch safe, your account has been suspended for 24 hours. Please contact us anytime at support@nooch.com if you believe this was a mistake or would like more information." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Contact Support",nil];
        [suspendedAlert show];
        [suspendedAlert setTag:50];
    }
    else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Receiver does not exist."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sending money to non-Noochers is not yet supported."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
    }
    else if([[resultValueTransfer valueForKey:@"Result"]isEqual:@"Please go to 'My Account' menu and configure your account details."]
             || [[[dictResultTransfer objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."]
             || [[[dictResultTransfer objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sending money to non-Noochers is not yet supported."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
    }
    else {
        NSString *resultValue = [dictResultTransfer objectForKey:@"RaiseDisputeResult"];
        if ([resultValue valueForKey:@"Result"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        else {
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