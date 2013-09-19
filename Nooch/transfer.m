//
//  transfer.m
//  Nooch
//
//  Created by Preston Hults on 10/16/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import "transfer.h"
#import <QuartzCore/QuartzCore.h>
#import "NoochHome.h"
#import "SBJSON.h"
#import "JSON.h"
#import "CJSONSerializer.h"
#import "CJSONDataSerializer.h"
#import "NoochHelper.h"
#import <stdlib.h>
#import "history.h"

@interface transfer ()

@end

@implementation transfer

@synthesize userPic,recipFirst,recipImage,receiveBack,recipLast,firstName,lastName,amountToSend,firstPIN,secondPIN,thirdPIN,fourthPIN,balance,prompt,dollarSign,confirm,PINText,respData,spinner,backImage;
@synthesize activityView,loadingView,loadingLabel,customKeyboard,inputAccess,enterAmountField,decimal,memoField;
NSString *transactionId;
NSString *processValue;
NSString *memoCat;
NSDictionary *allowValue;
bool allowSharingValue;

#pragma mark - inits
-(void)navCustomization{
    [leftNavButton addTarget:self action:@selector(backToSelect) forControlEvents:UIControlEventTouchUpInside];

}
-(void)viewWillDisappear:(BOOL)animated{
    if (viewDetails) {
        [navCtrl pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"history"] animated:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated{
     [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    confirm = NO;
    progressImage.highlighted = NO;
    [self navCustomization];
    [self.enterAmountField becomeFirstResponder];
    if (requestRespond) {
        transactionId = requestId;
        confirm = YES;
        prompt.hidden = NO;
        memoField.hidden = YES;
        memoBack.hidden = YES;
        amountToSend.text = requestAmount;
        amountToSend.hidden = NO;
        sendToggle.hidden = YES;
        requestToggle.hidden = YES;
        enterAmountField.hidden = YES;
        sendButton.hidden = YES;
        dollarSign.hidden = YES;
        if ([acceptOrDeny isEqualToString:@"DENY"]) {
            promptForPIN.hidden = YES;
            prompt.text = @"Enter your PIN to confirm declining this request.";
        }else if ([acceptOrDeny isEqualToString:@"Cancelled"]){
            prompt.text = @"Enter your PIN to confirm cancelling this request.";
            promptForPIN.hidden = YES;
        }else{
            prompt.text = @"";
            promptForPIN.hidden = NO;
            [promptForPIN setHighlighted:NO];
        }
        self.navigationItem.title = @"";
        progressImage.highlighted = YES;
        enterAmountField.hidden = YES;
        memoDefaultButton.hidden = YES;
        memoFoodButton.hidden = YES;
        memoTicketsButton.hidden = YES;
        memoUtilitiesButton.hidden = YES;
        memoIOUButton.hidden = YES;
        firstPIN.hidden = NO;
        sendButton.hidden = YES;
        secondPIN.hidden = NO;
        thirdPIN.hidden = NO;
        fourthPIN.hidden = NO;
        prompt.hidden = NO;
        [decimal setBackgroundImage:[UIImage imageNamed:@"NumPadBlank.png"] forState:UIControlStateNormal];
        [decimal setBackgroundImage:[UIImage imageNamed:@"NumPadBlank.png"] forState:UIControlStateDisabled];
        sendToggle.hidden = YES;
        requestToggle.hidden = YES;
    }else if (causes) {
        sendToggle.hidden = YES;
        requestToggle.hidden = YES;
    }else{
        sendToggle.hidden = NO;
        requestToggle.hidden = NO;
    }
}
-(void)viewDidAppear:(BOOL)animated{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    sendToggle.showsTouchWhenHighlighted = NO;
    requestToggle.showsTouchWhenHighlighted = NO;
    memoCat = @"";
    firstName.text=[[me usr] objectForKey:@"firstName"];
    lastName.text=[[me usr] objectForKey:@"lastName"];
    if([[[me usr] objectForKey:@"Balance"] length] != 0)
        balance.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    else
        balance.text = @"";
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
    }else{
        userPic.image = [UIImage imageNamed:@"profile_picture.png"];
    }
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateBanner) userInfo:nil repeats:YES];
    [sendToggle setSelected:YES];
    self.trackedViewName = @"Transfer";
	// Do any additional setup after loading the view.
    spinner.hidesWhenStopped = YES;
    PINText = [[NSString alloc] init];
    [self.enterAmountField setInputView:customKeyboard];
    [self.enterAmountField setInputAccessoryView:inputAccess];
    [self.memoField setInputAccessoryView:inputAccess];
    userPic.hidden = NO;
    recipFirst.text = receiverFirst;
    recipLast.text = receiverLast;
    if (![receiverImgData isKindOfClass:[NSNull class]]) {
        if ([receiverImgData length] != 0) {
            recipImage.image = [UIImage imageWithData:receiverImgData];
        }else{
            recipImage.image = [UIImage imageNamed:@"profile_picture.png"];
        }
    }else{
        recipImage.image = [UIImage imageNamed:@"profile_picture.png"];
    }

    firstName.font = [core nFont:@"Medium" size:16];
    lastName.font = [core nFont:@"Bold" size:17];
    balance.font = [core nFont:@"Medium" size:20];
    recipLast.font = [core nFont:@"Bold" size:17];
    recipFirst.font = [core nFont:@"Medium" size:16];
    amountToSend.font = [core nFont:@"Bold" size:20];
    dollarSign.font = [core nFont:@"Bold" size:24];
    dollarSign.textColor = [core hexColor:@"293033"];
    prompt.font = [core nFont:@"Medium" size:12];
    memoField.font = [core nFont:@"Medium" size:12];
    [sendButton setEnabled:NO];
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(75,( [[UIScreen mainScreen] bounds].size.height/2)-230, 170, 130)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 15.0;

    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 20, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];

    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 130, 50)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    [loadingLabel setFont:[core nFont:@"Medium" size:15]];
    [loadingLabel setNumberOfLines:2];
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
    userPic.clipsToBounds = YES;
    userPic.layer.cornerRadius = 4;
    recipImage.layer.cornerRadius = 4;
    recipImage.layer.borderWidth = 1;
    recipImage.layer.borderColor = [UIColor whiteColor].CGColor;
    recipImage.clipsToBounds = YES;
    actualAmount = [[NSString alloc] init];
    

    firstName.font = [core nFont:@"Medium" size:16];
    lastName.font = [core nFont:@"Medium" size:16];
    balance.font = [core nFont:@"Medium" size:20];
    enterAmountField.font = [core nFont:@"Medium" size:16];

    prompt.text = [NSString stringWithFormat:@"How much do you want to send to %@?",receiverFirst];
    actualAmount = @"";
}

#pragma mark - constants
-(void)goBack{
    requestRespond = NO;
    [navCtrl dismissModalViewControllerAnimated:YES];
}
-(void)backToSelect{
    sendingMoney = YES;
    requestRespond = NO;
    [navCtrl dismissModalViewControllerAnimated:YES];
}
-(void)updateBanner{
    firstName.text=[[me usr] objectForKey:@"firstName"];
    lastName.text=[[me usr] objectForKey:@"lastName"];
    if([[[me usr] objectForKey:@"Balance"] length] != 0)
        balance.text =[@"$" stringByAppendingString:[[me usr] objectForKey:@"Balance"]];
    else
        balance.text = @"";
    if([me pic] != NULL){
        userPic.image = [UIImage imageWithData:[me pic]];
    }else{
        userPic.image = [UIImage imageNamed:@"profile_picture.png"];
        //[me fetchPic];
    }
}
-(IBAction)okGoBack:(id)sender {
    transferFinished = YES;
    sendingMoney = NO;
    [self goBack];
}
-(void)dismissFP:(NSNotification *)notification{
    memoList = NO;
    @try {
        [fp dismissPopoverAnimated:YES];
        NSString *img = [notification.userInfo objectForKey:@"img"];
        if (![img isEqualToString:@"CANCELLED"]) {
            [memoDefaultButton setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
        }
        memoCat = [notification.userInfo objectForKey:@"cat"];
    }
    @catch (NSException *exception) {
        NSLog(@"error setting memo category");
    }
    @finally {
        [memoField becomeFirstResponder];
    }
}

#pragma mark - request/send handling
- (IBAction)switchRequest:(id)sender {
    [sendToggle setSelected:NO];
    [requestToggle setSelected:YES];
    [requestBar setHidden:NO];
    [enterAmountField setBackground:[UIImage imageNamed:@"EnterAmountFieldRequest.png"]];
    if ([memoField.text length] > 0) {
        [memoBack setImage:[UIImage imageNamed:@"MemoFieldRequest.png"]];
    }
    [sendButton setImage:[UIImage imageNamed:@"RequestButtonDefault.png"] forState:UIControlStateDisabled];
    [sendButton setImage:[UIImage imageNamed:@"RequestButtonLight.png"] forState:UIControlStateNormal];
    [sendButton setImage:[UIImage imageNamed:@"RequestButtonDark.png"] forState:UIControlStateHighlighted];
    [sendButton setImage:[UIImage imageNamed:@"RequestButtonLight.png"] forState:UIControlStateSelected];
}
- (IBAction)switchSend:(id)sender {
    [requestToggle setSelected:NO];
    [sendToggle setSelected:YES];
    [requestBar setHidden:YES];
    [enterAmountField setBackground:[UIImage imageNamed:@"EnterAmountFieldSend.png"]];
    if ([memoField.text length] > 0) {
        [memoBack setImage:[UIImage imageNamed:@"MemoFieldSend.png"]];
    }
    [sendButton setImage:[UIImage imageNamed:@"SendButtonDefault.png"] forState:UIControlStateDisabled];
    [sendButton setImage:[UIImage imageNamed:@"SendButtonLight.png"] forState:UIControlStateNormal];
    [sendButton setImage:[UIImage imageNamed:@"SendButtonLight.png"] forState:UIControlStateSelected];
    [sendButton setImage:[UIImage imageNamed:@"SendButtonDark.png"] forState:UIControlStateHighlighted];
}

#pragma mark - keypad stuffs and amount checking
-(void)confirmPIN{
    AppDelegate *appD = [UIApplication sharedApplication].delegate;
    [appD showWait:@"Processing your transfer..."];

    serve *pin = [serve new];
    pin.Delegate = self;
    pin.tagName = @"ValidatePinNumber";
    [pin getEncrypt:PINText];

}
-(IBAction)okAmount:(id)sender {
    [enterAmountField becomeFirstResponder];
    [self validAmount];
    if(confirm){
        prompt.hidden = NO;
        memoField.hidden = YES;
        memoBack.hidden = YES;
        amountToSend.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%.02f", [actualAmount floatValue]]];
        amountToSend.hidden = NO;
        enterAmountField.hidden = YES;
        sendButton.hidden = YES;
        dollarSign.hidden = YES;
        prompt.text = @"";
        promptForPIN.hidden = NO;
        if (!sendToggle.isSelected) {
            [promptForPIN setHighlighted:YES];
        }
        progressImage.highlighted = YES;
        enterAmountField.hidden = YES;

        memoDefaultButton.hidden = YES;
        memoFoodButton.hidden = YES;
        memoTicketsButton.hidden = YES;
        memoUtilitiesButton.hidden = YES;
        memoIOUButton.hidden = YES;

        firstPIN.hidden = NO;
        sendButton.hidden = YES;
        secondPIN.hidden = NO;
        thirdPIN.hidden = NO;
        fourthPIN.hidden = NO;
        prompt.hidden = NO;
        [decimal setBackgroundImage:[UIImage imageNamed:@"NumPadBlank.png"] forState:UIControlStateNormal];
        [decimal setBackgroundImage:[UIImage imageNamed:@"NumPadBlank.png"] forState:UIControlStateDisabled];
        sendToggle.hidden = YES;
        requestToggle.hidden = YES;
    }
}
-(void)validAmount{
    NSString *decimalPointRegex = @"[0-9]+(\.[0-9][0-9]?)?";
    //NSString *decimalPointRegex=@"/^\$?[0-9]+(\.[0-9][0-9]?)?";
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"$ "];
    actualAmount= [[enterAmountField.text componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    NSPredicate *decimalPointTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalPointRegex];
    actualAmount = [NSString stringWithFormat:@"%.02f", [actualAmount floatValue]];
    if ([actualAmount doubleValue] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!" message:@"Minimum amount that can be transferred is any amount." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    else if ([actualAmount doubleValue] > 100)
    {
        NSString *which;
        if(sendToggle.selected)which=@"send";
        else which=@"request";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa Now" message:[NSString stringWithFormat:@"Sorry I’m not sorry, but don’t %@ more than $100. It’s against the rules (and protects the account from abuse.)", which] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }else if ([actualAmount doubleValue] > [[balance.text substringFromIndex:1]doubleValue] && sendToggle.isSelected){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!" message:@"Thanks for testing this impossibility, but you can't transfer more than you have in your Nooch account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Add Funds", nil];
        [alert setTag:21];
        [alert show];
    }else if ([decimalPointTest evaluateWithObject:actualAmount] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a valid amount." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }else {
        confirm = YES;
    }
}

# pragma mark - serve delegation
-(void)listen:(NSString*)result tagName:(NSString*)tagName{
    NSDictionary *loginResult = [result JSONValue];
    NSLog(@"pincheck result %@",loginResult);

    NSString *receiveName = [receiverFirst stringByAppendingString:[NSString stringWithFormat:@" %@",receiverLast]];

    if ([city rangeOfString:@"null"].location != NSNotFound || city == NULL) {
        city = @"";
    }
    if ([state rangeOfString:@"null"].location != NSNotFound || state ==NULL) {
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
    if (TransactionDate == NULL || [TransactionDate rangeOfString:@"null"].location != NSNotFound || TransactionDate == NULL) {
        TransactionDate = @"";
    }
    if (latitudeField == NULL || [latitudeField rangeOfString:@"null"].location != NSNotFound) {
        latitudeField = @"0.0";
    }
    if (longitudeField == NULL || [longitudeField rangeOfString:@"null"].location != NSNotFound) {
        longitudeField = @"0.0";
    }
    if (altitudeField == NULL || [altitudeField rangeOfString:@"null"].location != NSNotFound) {
        altitudeField = @"0.0";
    }
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];

    if([tagName isEqualToString:@"ValidatePinNumber"] ){
        if (requestRespond) {
            //NSString *idToUse;
            NSMutableDictionary *transactionInput = [NSMutableDictionary dictionaryWithObjectsAndKeys:[loginResult valueForKey:@"Status"], @"PinNumber", [[me usr] objectForKey:@"MemberId"], @"MemberId", requestId, @"TransactionId", TransactionDate, @"TransactionDate", uid, @"DeviceId", latitudeField, @"Latitude", longitudeField, @"Longitude", altitudeField, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode", acceptOrDeny, @"Status", nil];

            NSMutableDictionary *transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"handleRequestInput", nil];

            NSLog(@"Request %@", transaction);

            NSString *post = [transaction JSONRepresentation];

            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

            self.respData = [NSMutableData data];

            NSString *urlStr = [[NSString alloc] initWithString:MyUrl];
            urlStr = [urlStr stringByAppendingFormat:@"/%@", @"HandleRequestMoney"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSLog(@"URL string %@", url);

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (connection)
            {
                respData = [NSMutableData data];
            }
            return;
        }
        NSMutableDictionary *transaction;
        NSDictionary *transactionInput;
        NSString *transMemo = [NSString stringWithFormat:@"%@%@",memoCat,memoField.text];
        if (!requestBar.hidden) {
            transactionInput = [NSDictionary dictionaryWithObjectsAndKeys:[loginResult valueForKey:@"Status"], @"PinNumber", [[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"], @"MemberId", receiverId, @"SenderId", receiveName, @"Name", [NSString stringWithFormat:@"%.02f", [actualAmount floatValue]], @"Amount", TransactionDate, @"TransactionDate", @"false", @"IsPrePaidTransaction", uid, @"DeviceId", latitudeField, @"Latitude", longitudeField, @"Longitude", altitudeField, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode",transMemo,@"Memo",@"Pending",@"Status", nil];
            transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"requestInput", nil];
        }else{
            transactionInput = [NSDictionary dictionaryWithObjectsAndKeys:[loginResult valueForKey:@"Status"], @"PinNumber", [[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"], @"MemberId", receiverId, @"RecepientId", receiveName, @"Name", [NSString stringWithFormat:@"%.02f", [actualAmount floatValue]], @"Amount", TransactionDate, @"TransactionDate", @"false", @"IsPrePaidTransaction", uid, @"DeviceId", latitudeField, @"Latitude", longitudeField, @"Longitude", altitudeField, @"Altitude", addressLine1, @"AddressLine1", addressLine2, @"AddressLine2", city, @"City", state, @"State", country, @"Country", zipcode, @"ZipCode",transMemo,@"Memo", nil];
            transaction = [[NSMutableDictionary alloc] initWithObjectsAndKeys:transactionInput, @"transactionInput", nil];
        }

        NSLog(@"Transaction %@", transaction);

        NSString *post = [transaction JSONRepresentation];

        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

        self.respData = [NSMutableData data];
        NSString *urlStr = [[NSString alloc] initWithString:MyUrl];

        if (!requestBar.hidden) {
            urlStr = [urlStr stringByAppendingFormat:@"/%@", @"RequestMoney"];
        }else{
            urlStr = [urlStr stringByAppendingFormat:@"/%@", @"TransferMoney"];
        }

        NSURL *url = [NSURL URLWithString:urlStr];
        NSLog(@"transaction server call: %@",url);

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection)
        {
            respData = [NSMutableData data];
        }
    }
}

#pragma mark - connection handling
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[respData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [respData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:respData encoding:NSASCIIStringEncoding];
    NSDictionary *loginResult = [responseString JSONValue];
    NSLog(@"Array is : %@", loginResult);
    if (requestRespond) {
        requestRespond = NO;
    }
    if (sendToggle.isSelected) {
        if (![[loginResult objectForKey:@"trnsactionId"] isKindOfClass:[NSNull class]])
            transactionId=[loginResult valueForKey:@"trnsactionId"];
    }else{
        if (![[loginResult objectForKey:@"requestId"] isKindOfClass:[NSNull class]])
            transactionId=[loginResult valueForKey:@"requestId"];
    }
    
    NSLog(@"transactionId %@",transactionId);
    
    NSDictionary *resultValue = [loginResult valueForKey:@"TransferMoneyResult"];
    AppDelegate *appD = [UIApplication sharedApplication].delegate;
    [appD endWait];
    if ([[resultValue valueForKey:@"Result"] isEqualToString:@"Your cash was sent successfully"])
    {
        [me histUpdate];
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
        [backImage setHighlighted:NO];
        transferFinished = YES;
        sendingMoney = NO;
        [av setTag:1];
    }else if ([[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request processed successfully."]){
        [me histUpdate];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Fulfilled" message:[NSString stringWithFormat:@"You successfully fulfilled %@'s request for %@.",receiverFirst,amountToSend.text] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }else if ([[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully declined."]){
        [me histUpdate];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Denied" message:[NSString stringWithFormat:@"You successfully denied %@'s request for %@.",receiverFirst,amountToSend.text] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }else if ([[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request successfully cancelled."]){
        [me histUpdate];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Cancelled" message:[NSString stringWithFormat:@"You successfully cancelled your request for %@ from %@.",amountToSend.text,receiverFirst] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [av setTag:1];
        [av show];
    }else if ([[[loginResult objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Request made successfully."]){
        [me histUpdate];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Pay Me" message:[NSString stringWithFormat:@"You requested %@ from %@ successfully.",amountToSend.text,receiverFirst] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",@"View Details",nil];
        [av setTag:1];
        [av show];
    }else if([[resultValue valueForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."]
             || [[[loginResult objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
    {
        [promptForPIN setHidden:YES];
        prompt.text=@"1 failed attempt. Please try again.";
        firstPIN.highlighted = NO;
        secondPIN.highlighted = NO;
        thirdPIN.highlighted = NO;
        fourthPIN.highlighted = NO;
        receiveBack.image = [UIImage imageNamed:@"PINfailBar.png"];
        [backImage setHighlighted:YES];
        PINText = @"";
    }
    else if([[resultValue valueForKey:@"Result"] isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]
            || [[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."]
            || [[[loginResult objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
    {
        prompt.text = @"2 failed attempts. Please try again.";
        [promptForPIN setHidden:YES];
        firstPIN.highlighted = NO;
        secondPIN.highlighted = NO;
        thirdPIN.highlighted = NO;
        fourthPIN.highlighted = NO;
        PINText = @"";
        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"Your account will be suspended for 24 hours if you enter another incorrect PIN." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [suspendedAlert show];
        [suspendedAlert setTag:9];
    }
    else if([[resultValue valueForKey:@"Result"]isEqual:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]
            || [[[loginResult objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."])
    {
        prompt.text = @"3 failed attempt. Your account has been suspended.";
        [promptForPIN setHidden:YES];
        suspended = YES;
        firstPIN.highlighted = NO;
        secondPIN.highlighted = NO;
        thirdPIN.highlighted = NO;
        fourthPIN.highlighted = NO;
        PINText = @"";
        UIAlertView *suspendedAlert=[[UIAlertView alloc]initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [suspendedAlert show];
        [suspendedAlert setTag:3];
    }else if([[resultValue valueForKey:@"Result"]isEqual:@"Receiver does not exist."]
             || [[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."]
             || [[[loginResult objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Receiver does not exist."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sending money to non-Noochers is not yet supported."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
        [self goBack];
    }else if([[resultValue valueForKey:@"Result"]isEqual:@"Please go to 'My Account' menu and configure your account details."]
             || [[[loginResult objectForKey:@"HandleRequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."]
             || [[[loginResult objectForKey:@"RequestMoneyResult"] objectForKey:@"Result"] isEqualToString:@"Please go to 'My Account' menu and configure your account details."]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sending money to non-Noochers is not yet supported."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
        [self goBack];
    }else{
        NSString *resultValue = [loginResult objectForKey:@"RaiseDisputeResult"];
        if ([resultValue valueForKey:@"Result"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }else{
            NSString *resultValue = [loginResult objectForKey:@"HandleRequestMoneyResult"];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Oops" message:[resultValue valueForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        transferFinished = YES;
        sendingMoney = NO;
        [self goBack];
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

#pragma mark  - alert view delegation
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [me stamp];
    if([actionSheet tag] == 1)
    {
        if(buttonIndex==0)
        {
            requestRespond = NO;
            transferFinished = YES;
            sendingMoney = NO;
            if (causes) {
                [self dismissModalViewControllerAnimated:YES];
                [navCtrl popToRootViewControllerAnimated:NO];
            }else{
                [self dismissModalViewControllerAnimated:YES];
            }
            
        }
        else if(buttonIndex==1)
        {
            tId = transactionId;
            requestRespond = NO;
            transferFinished = YES;
            sendingMoney = NO;
            viewDetails = YES;
            if (causes) {
                [self dismissModalViewControllerAnimated:YES];
                [navCtrl popToRootViewControllerAnimated:NO];
            }else{
                [self dismissModalViewControllerAnimated:YES];
            }
        }
        else if(buttonIndex==2){
            requestRespond = NO;
            transferFinished = YES;
            sendingMoney = NO;
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
                me.accountStore = [[ACAccountStore alloc] init];
                ACAccountType *facebookAccountType = [me.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
                me.facebookAccount = nil;
                
                NSDictionary *options = @{
                                          ACFacebookAppIdKey: @"198279616971457",
                                          ACFacebookPermissionsKey: @[@"publish_stream"],
                                          ACFacebookAudienceKey: ACFacebookAudienceFriends
                                          };

                [me.accountStore requestAccessToAccountsWithType:facebookAccountType
                                                      options:options completion:^(BOOL granted, NSError *e)
                 {
                     
                     if (granted)
                     {
                         NSArray *accounts = [me.accountStore accountsWithAccountType:facebookAccountType];

                         me.facebookAccount = [accounts lastObject];
                         [self performSelectorOnMainThread:@selector(post) withObject:nil waitUntilDone:NO];
                     }
                     else
                     {
                         // Handle Failure
                         NSLog(@"fbposting not allowed");
                         [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:NO];
                     }
                     
                 }];
            }

        }else if(buttonIndex==3){
            requestRespond = NO;
            transferFinished = YES;
            sendingMoney = NO;
            if(me.twitterAllowed){
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [controller setInitialText:[NSString stringWithFormat:@"I just Nooch'ed %@ %@!",receiverFirst,receiverLast]];
                [controller addURL:[NSURL URLWithString:@"http://www.nooch.com"]];
                [self presentViewController:controller animated:YES completion:Nil];

                SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                    NSString *output= nil;
                    switch (result) {
                        case SLComposeViewControllerResultCancelled:
                            [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:NO];
                            NSLog (@"cancelled");
                            break;
                        case SLComposeViewControllerResultDone:
                            output= @"Post Succesfull";
                            NSLog (@"success");
                            break;
                        default:
                            break;
                    }
                    if ([output isEqualToString:@"Post Succesfull"]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [alert setTag:11];
                    }

                    [controller dismissViewControllerAnimated:YES completion:Nil];
                };
                controller.completionHandler =myBlock;
            }
        }
    }else if([actionSheet tag] == 2)
    {
        if(buttonIndex==0){
            respData = [[NSMutableData alloc] init];
            NSString *subjectLine = @"Confirmation mail for disputing transaction.";
            NSString *bodyText = [NSString stringWithFormat:@"%@%@",@"Dispute raised with transaction ID : ",transactionId];

            NSDictionary *disputInfo = [NSDictionary dictionaryWithObjectsAndKeys: [[me usr] objectForKey:@"MemberId"], @"MemberId", receiverId, @"RecepientId", transactionId, @"TransactionId", @"SENT", @"ListType", @"", @"CcMailIds", @"", @"BccMailIds", subjectLine, @"Subject", bodyText, @"BodyText", nil];

            NSDictionary *disputeInput = [NSDictionary dictionaryWithObjectsAndKeys: disputInfo, @"raiseDisputeInput", nil];

            NSLog(@"DisputeInput %@", disputeInput);

            NSString *post = [disputeInput JSONRepresentation];

            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

            respData = [NSMutableData data];

            NSString *urlStr = [[NSString alloc] initWithString:MyUrl];
            urlStr = [urlStr stringByAppendingFormat:@"/%@", @"RaiseDispute"];
            NSURL *url = [NSURL URLWithString:urlStr];

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
    }else if([actionSheet tag] == 3){
        transferFinished = YES;
        sendingMoney = NO;
        [self dismissModalViewControllerAnimated:YES];
    }else if ([actionSheet tag] == 21 && buttonIndex == 1){
        [self dismissModalViewControllerAnimated:NO];
        [navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"addFunds"] animated:YES];
    }else if([actionSheet tag] == 11){
        NSLog(@"hmph");
         [self performSelectorOnMainThread:@selector(finishedPosting) withObject:nil waitUntilDone:NO];
    }
}
-(void)post{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"I just Nooch'ed %@ %@!",receiverFirst,receiverLast]];
    [controller addURL:[NSURL URLWithString:@"http://www.nooch.com"]];
    [self presentViewController:controller animated:YES completion:Nil];

    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        NSString *output= nil;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output= @"Action Cancelled";
                NSLog (@"cancelled");
                break;
            case SLComposeViewControllerResultDone:
                output= @"Post Succesfull";
                NSLog (@"success");
                break;
            default:
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [controller dismissViewControllerAnimated:YES completion:Nil];
        [self performSelectorOnMainThread:@selector(finishedPosting) withObject:nil waitUntilDone:NO];
    };
    controller.completionHandler =myBlock;
    
}
-(void)finishedPosting{
    if (causes) {
        [self dismissModalViewControllerAnimated:YES];
        [navCtrl popToRootViewControllerAnimated:NO];
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

# pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error : %@",error);
    if ([error code] == kCLErrorDenied){
        NSLog(@"Error : %@",error);
    }
}
-(void) updateLocation:(NSString*)latitude longitude:(NSString*)longitude{
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
    /*if ([[[[[placemark objectAtIndex:0]     objectForKey:@"AddressDetails"]objectForKey:@"Country"]objectForKey:@"AdministrativeArea"]objectForKey:@"SubAdministrativeArea"] == NULL){


        addressLine1 = [[ NSString alloc] initWithFormat:@"%@",[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"Thoroughfare"] objectForKey:@"ThoroughfareName"]];

        addressLine2 = [[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"LocalityName"]];

        city = [[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"LocalityName"]];

        state = [[ NSString alloc] initWithFormat:@"%@",[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"AdministrativeAreaName"]];

        country = [[ NSString alloc] initWithFormat:@"%@",[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"CountryName"]];

        zipcode = [[ NSString alloc] initWithFormat:@"%@",[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"PostalCode"] objectForKey:@"PostalCodeNumber"]];

    }
    else {

        addressLine1 = [[ NSString alloc] initWithFormat:@"%@",[[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"Thoroughfare"] objectForKey:@"ThoroughfareName"]];

        addressLine2 = [[ NSString alloc] initWithFormat:@"%@",[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"LocalityName"]];

        city = [[ NSString alloc] initWithFormat:@"%@",[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"SubAdministrativeAreaName"]];

        state = [[ NSString alloc] initWithFormat:@"%@",[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"AdministrativeAreaName"]];

        country = [[ NSString alloc] initWithFormat:@"%@",[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"CountryName"]];

        zipcode = [[ NSString alloc] initWithFormat:@"%@",[[[[[[[[placemark objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"PostalCode"] objectForKey:@"PostalCodeNumber"]];
    }*/
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
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [manager stopUpdatingLocation];

    CLLocationCoordinate2D loc = [newLocation coordinate];
	latitudeField = [[NSString alloc] initWithFormat:@"%f",loc.latitude];
	longitudeField = [[NSString alloc] initWithFormat:@"%f",loc.longitude];
	altitudeField = [[NSString alloc] initWithFormat:@"%f",newLocation.altitude];
    [locationManager stopUpdatingLocation];

    [self updateLocation:latitudeField longitude:longitudeField];
}

#pragma mark - dispute transfer
- (IBAction)disputeTransfer:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to dispute this transfer? Your account will be suspended while we investigate." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:2];
}
- (IBAction)disputeTrans:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to dispute this transfer? Your account will be suspended while we investigate." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [av show];
    [av setTag:2];
}

#pragma mark - custom keyboard
- (IBAction)decimal:(id)sender {
    [self calculateAmount:10];
}
- (IBAction)zero:(id)sender {
    [self calculateAmount:0];
}
- (IBAction)backspace:(id)sender {
    [self calculateAmount:11];
}
- (IBAction)nine:(id)sender {
    [self calculateAmount:9];
}
- (IBAction)eight:(id)sender {
    [self calculateAmount:8];
}
- (IBAction)seven:(id)sender {
    [self calculateAmount:7];
}
- (IBAction)four:(id)sender {
    [self calculateAmount:4];
}
- (IBAction)five:(id)sender {
    [self calculateAmount:5];
}
- (IBAction)six:(id)sender {
    [self calculateAmount:6];
}
- (IBAction)two:(id)sender {
    [self calculateAmount:2];
}
- (IBAction)three:(id)sender {
    [self calculateAmount:3];
}
- (IBAction)one:(id)sender {
    [self calculateAmount:1];
}
- (void)calculateAmount:(int)number{
    enterAmountField.font = [core nFont:@"Bold" size:24];
    if(confirm){
        switch(number)
        {
            case 0:{
                PINText = [PINText stringByAppendingString:@"0"];
                break;
            }case 1:{
                PINText = [PINText stringByAppendingString:@"1"];
                break;
            }case 2:{
                PINText = [PINText stringByAppendingString:@"2"];
                break;
            }case 3:{
                PINText = [PINText stringByAppendingString:@"3"];
                break;
            }case 4:{
                PINText = [PINText stringByAppendingString:@"4"];
                break;
            }case 5:{
                PINText = [PINText stringByAppendingString:@"5"];
                break;
            }case 6:{
                PINText = [PINText stringByAppendingString:@"6"];
                break;
            }case 7:{
                PINText = [PINText stringByAppendingString:@"7"];
                break;
            }case 8:{
                PINText = [PINText stringByAppendingString:@"8"];
                break;
            }case 9:{
                PINText = [PINText stringByAppendingString:@"9"];
                break;
            }case 11:{
                if([PINText length] != 0)
                    PINText = [PINText substringToIndex:[PINText length] - 1];
                break;
            }
        }
        if([PINText length] == 4){
            fourthPIN.highlighted = YES;
            [self confirmPIN];
        }else if([PINText length] == 1){
            firstPIN.highlighted = YES;
            secondPIN.highlighted = NO;
            thirdPIN.highlighted = NO;
            fourthPIN.highlighted = NO;
        }else if([PINText length] == 2){
            secondPIN.highlighted = YES;
            thirdPIN.highlighted = NO;
            fourthPIN.highlighted = NO;
        }else if([PINText length] == 3){
            thirdPIN.highlighted = YES;
            fourthPIN.highlighted = NO;
        }else{
            firstPIN.highlighted = NO;
            secondPIN.highlighted = NO;
            thirdPIN.highlighted = NO;
            fourthPIN.highlighted = NO;
        }
    }else{
        switch(number)
        {
            case 0:{
                actualAmount = [actualAmount stringByAppendingString:@"0"];
                break;
            }case 1:{
                actualAmount = [actualAmount stringByAppendingString:@"1"];
                break;
            }case 2:{
                actualAmount = [actualAmount stringByAppendingString:@"2"];
                break;
            }case 3:{
                actualAmount = [actualAmount stringByAppendingString:@"3"];
                break;
            }case 4:{
                actualAmount = [actualAmount stringByAppendingString:@"4"];
                break;
            }case 5:{
                actualAmount = [actualAmount stringByAppendingString:@"5"];
                break;
            }case 6:{
                actualAmount = [actualAmount stringByAppendingString:@"6"];
                break;
            }case 7:{
                actualAmount = [actualAmount stringByAppendingString:@"7"];
                break;
            }case 8:{
                actualAmount = [actualAmount stringByAppendingString:@"8"];
                break;
            }case 9:{
                actualAmount = [actualAmount stringByAppendingString:@"9"];
                break;
            }case 10:{
                actualAmount = [actualAmount stringByAppendingString:@"."];
                break;
            }case 11:{
                if([actualAmount length] != 0)
                    actualAmount = [actualAmount substringToIndex:[actualAmount length] - 1];
                break;
            }
        }
        if([actualAmount length] > 0) [sendButton setEnabled:YES];
        else [sendButton setEnabled:NO];
        if([actualAmount length] > 6)
            actualAmount = [actualAmount substringToIndex:[actualAmount length] -1];

        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:actualAmount
                                                            options:0
                                                              range:NSMakeRange(0, [actualAmount length])];
        if (numberOfMatches != 0) enterAmountField.text = actualAmount;
        else [actualAmount substringToIndex:[actualAmount length] -1];
        actualAmount = enterAmountField.text;
        if([actualAmount length] == 0)
            enterAmountField.font = [UIFont fontWithName:@"Roboto-Medium" size:16];
    }
}

#pragma mark - memo's
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(textField == enterAmountField){
        if(newLength !=0) enterAmountField.textColor = [core hexColor:@"556c6c"];
        else enterAmountField.textColor = [core hexColor:@"293033"];

        if(newLength !=0){
            if (sendToggle.isSelected){
                enterAmountField.background = [UIImage imageNamed:@"EnterAmountFieldSend.png"];
            }else{
                enterAmountField.background = [UIImage imageNamed:@"EnterAmountFieldRequest.png"];
            }
        }
    }

    return (newLength > 25) ? NO : YES;
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField == memoField){
        if ([memoField.text length] > 0) {
            if (sendToggle.isSelected) {
                 [memoBack setImage:[UIImage imageNamed:@"MemoFieldSend.png"]];
            }else{
                 [memoBack setImage:[UIImage imageNamed:@"MemoFieldRequest.png"]];
            }
        }else{
             [memoBack setImage:[UIImage imageNamed:@"MemoFieldDefault.png"]];
        }
        [enterAmountField becomeFirstResponder];
        return YES;
    }
    [writeMemo dismissWithClickedButtonIndex:0 animated:YES];
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)enterMemo:(id)sender {
    writeMemo = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [writeMemo setBackgroundColor:[UIColor clearColor]];
    UIImageView *textBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 75)];
    UIImage *textBack2 = [UIImage imageNamed:@"FundsField.png"];
    [textBack setImage:textBack2];
    [writeMemo addSubview:textBack];
    UITextField *memoText = [[UITextField alloc] initWithFrame:CGRectMake(12, 30, 260, 25)];
    [memoText setTextAlignment:NSTextAlignmentCenter];
    memoText.returnKeyType = UIReturnKeyDone;
    [writeMemo addSubview:memoText];
    [writeMemo show];
    [writeMemo setTag:12];
    [memoText setDelegate:self];
    [memoText setFont:[UIFont fontWithName:@"Roboto" size:14]];
    [memoText becomeFirstResponder];
}
- (IBAction)defaultMemo:(id)sender {
    memoList = YES;
    [enterAmountField resignFirstResponder];
    [memoField resignFirstResponder];
    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = nil;
    fp =  [[FPPopoverController alloc] initWithViewController:popOver];
    fp.border = NO;
    fp.tint = FPPopoverWhiteTint;
    fp.arrowDirection = FPPopoverArrowDirectionUp;
    fp.delegate = self;
    fp.contentSize = CGSizeMake(300, 248);
    [fp presentPopoverFromPoint:CGPointMake(160, 200)];
}
-(void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController{
    if (memoList) {
        memoList = NO;
        [memoField becomeFirstResponder];
        return;
    }
    [memoField becomeFirstResponder];
}

#pragma mark - file paths
- (NSString *)userImageFilePath{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"]]];

}
- (NSString *)userFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"]]];

}
- (NSString *)userMemos{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-memos.plist",[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"]]];

}

#pragma mark -unloading and memory
- (void)viewDidUnload {
    [self setDecimal:nil];
    [self setUserPic:nil];
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setBalance:nil];
    [self setRecipImage:nil];
    [self setRecipFirst:nil];
    [self setRecipLast:nil];
    [self setFirstPIN:nil];
    [self setSecondPIN:nil];
    [self setThirdPIN:nil];
    [self setFourthPIN:nil];
    [self setPrompt:nil];
    [self setReceiveBack:nil];
    [self setDollarSign:nil];
    [self setSpinner:nil];
    [self setBackImage:nil];
    [self setCustomKeyboard:nil];
    [self setInputAccess:nil];
    [self setEnterAmountField:nil];
    [self setDecimal:nil];
    [self setMemoField:nil];
    requestToggle = nil;
    sendToggle = nil;
    sendButton = nil;
    sendArrow1 = nil;
    sendArrow2 = nil;
    sendArrow3 = nil;
    requestArrows = nil;
    requestBar = nil;
    promptForPIN = nil;
    memoDefaultButton = nil;
    memoFoodButton = nil;
    memoUtilitiesButton = nil;
    memoTicketsButton = nil;
    memoIOUButton = nil;
    userBar = nil;
    leftNavButton = nil;
    navBar = nil;
    progressImage = nil;
    memoBack = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
