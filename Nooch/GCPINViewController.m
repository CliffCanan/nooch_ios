//
//  GCPINViewController.m
//  PINCode
//
//  Created by Caleb Davenport on 8/28/10.
//  Copyright 2010 GUI Cocoa, LLC. All rights reserved.
//


#import "GCPINViewController.h"
#import "NSData+AESCrypt.h"
#import "NSString+AESCrypt.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "Signup.h"
#import "LoginViewController.h"
#import "NoochHome.h"
#import "AppDelegate.h"
#import "settings.h"
#import "Tutorial1.h"


@implementation GCPINViewController

@synthesize secureTextEntry;
@synthesize userInfo;
@synthesize PINText, secondEntry, prompt, comparePIN;
@synthesize chckPage;
@synthesize pin,targetViewName,lastTransactionDictionary;
@synthesize firstNumber, secondNumber, thirdNumber, fourthNumber;
@synthesize spinner,confirmPIN,backgroundImage;

#pragma mark - view lifecycle

- (void)dealloc {
	pinFields = nil;
	PINText = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    prompt.font = [core nFont:@"Medium" size:14];
    [splashView removeFromSuperview];
    [backgroundImage setHighlighted:NO];
    self.navigationItem.title = @"PIN";
    [pinTextField setInputView:keyboard];
    [pinTextField becomeFirstResponder];
    [self navCustomization];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return NO;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return NO;
}

#pragma mark - keyboard handling
- (IBAction)backspace:(id)sender {
    [self editPIN:sender];
}
- (IBAction)zero:(id)sender {
    [self editPIN:sender];
}
- (IBAction)nine:(id)sender {
    [self editPIN:sender];
}
- (IBAction)eight:(id)sender {
    [self editPIN:sender];
}
- (IBAction)seven:(id)sender {
    [self editPIN:sender];
}
- (IBAction)six:(id)sender {
    [self editPIN:sender];
}
- (IBAction)five:(id)sender {
    [self editPIN:sender];
}
- (IBAction)four:(id)sender {
    [self editPIN:sender];
}
- (IBAction)three:(id)sender {
    [self editPIN:sender];
}
- (IBAction)two:(id)sender {
    [self editPIN:sender];
}
- (IBAction)one:(id)sender {
    [self editPIN:sender];
}

-(void)editPIN:(UIButton*)sender{
    switch(sender.tag)
    {
        case 1:{
            PINText = [PINText stringByAppendingString:@"0"];
            break;
        }case 2:{
            PINText = [PINText stringByAppendingString:@"1"];
            break;
        }case 3:{
            PINText = [PINText stringByAppendingString:@"2"];
            break;
        }case 4:{
            PINText = [PINText stringByAppendingString:@"3"];
            break;
        }case 5:{
            PINText = [PINText stringByAppendingString:@"4"];
            break;
        }case 6:{
            PINText = [PINText stringByAppendingString:@"5"];
            break;
        }case 7:{
            PINText = [PINText stringByAppendingString:@"6"];
            break;
        }case 8:{
            PINText = [PINText stringByAppendingString:@"7"];
            break;
        }case 9:{
            PINText = [PINText stringByAppendingString:@"8"];
            break;
        }case 10:{
            PINText = [PINText stringByAppendingString:@"9"];
            break;
        }case 11:{
            break;
        }case 12:{
            if(PINText.length != 0)
                PINText = [PINText substringToIndex:[PINText length] - 1];
            break;
        }
    }
    
    if (reqImm) {
        if ([PINText length] == 4) {
            fourthNumber.highlighted = YES;
            [spinner startAnimating];
            serve *req = [[serve alloc] init];
            req.tagName=@"EncryptReqImm";
            req.Delegate = self;
            [req getEncrypt:PINText];
            leftNavButton.userInteractionEnabled = NO;
            keyboard.userInteractionEnabled = NO;
            //            [req methodName:@"GetEncryptedData" contentTemplate:@"data" templateData:PINText];
        }else if([PINText length] == 1){
            firstNumber.highlighted = YES;
            secondNumber.highlighted = NO;
            thirdNumber.highlighted = NO;
            fourthNumber.highlighted = NO;
        }else if([PINText length] == 2){
            secondNumber.highlighted = YES;
            thirdNumber.highlighted = NO;
            fourthNumber.highlighted = NO;
        }else if([PINText length] == 3){
            thirdNumber.highlighted = YES;
            fourthNumber.highlighted = NO;
        }else{
             [self resetDisplay:self];
        }
        return;
    }

    if([PINText length] == 4 && !secondEntry && !self.resPin){
        fourthNumber.highlighted = YES;
         [self resetDisplay:self];
        comparePIN = PINText;
        secondEntry = YES;
        PINText = @"";
        prompt.text = @"Please confirm your PIN.";
    }else if([PINText length] == 4 && secondEntry && !self.resPin){
        fourthNumber.highlighted = YES;
        if([PINText isEqualToString:comparePIN]){
            [spinner startAnimating];
            serve *req = [[serve alloc] init];
            req.Delegate = self;
            req.tagName=@"GetEncryptedData";
            [req getEncrypt:PINText];
            keyboard.userInteractionEnabled = NO;
            leftNavButton.userInteractionEnabled = NO;
            //            [req methodName:@"GetEncryptedData" contentTemplate:@"data" templateData:PINText];
        }else{
            prompt.text = @"PINs don't match, please try again.";
            [backgroundImage setHighlighted:YES];
            [self resetDisplay:self];
            PINText = @"";
            secondEntry = NO;
        }
    }else if(self.resPin && [PINText length] == 4 && !secondEntry && confirmPIN){
        fourthNumber.highlighted = YES;
        [self resetDisplay:self];
        keyboard.userInteractionEnabled = NO;
        leftNavButton.userInteractionEnabled = NO;
        serve *req = [[serve alloc] init];
        req.Delegate = self;
        req.tagName=@"GetEncryptedData";
        [req getEncrypt:PINText];
        //        [req methodName:@"GetEncryptedData" contentTemplate:@"data" templateData:PINText];
        PINText = @"";
    }else if(self.resPin && [PINText length] == 4 && !secondEntry && !confirmPIN){
        fourthNumber.highlighted = YES;
        [self resetDisplay:self];
        secondEntry = YES;
        comparePIN = PINText;
        prompt.text = @"Confirm your new PIN.";
        PINText = @"";
    }else if(self.resPin && [PINText length] == 4 && secondEntry && !confirmPIN){
        fourthNumber.highlighted = YES;
        [self resetDisplay:self];
        if([PINText isEqualToString:comparePIN]){
            [spinner startAnimating];
            serve *req = [[serve alloc] init];
            req.Delegate = self;
            req.tagName=@"GetEncryptedData";
            [req getEncrypt:PINText];
            keyboard.userInteractionEnabled = NO;
            leftNavButton.userInteractionEnabled = NO;
            //            [req methodName:@"GetEncryptedData" contentTemplate:@"data" templateData:PINText];
        }else{
            prompt.text = @"PINs don't match, please try again.";
            [backgroundImage setHighlighted:YES];
            [self resetDisplay:self];
            PINText = @"";
            secondEntry = NO;
        }
    }else if([PINText length] == 1){
        firstNumber.highlighted = YES;
        secondNumber.highlighted = NO;
        thirdNumber.highlighted = NO;
        fourthNumber.highlighted = NO;
    }else if([PINText length] == 2){
        secondNumber.highlighted = YES;
        thirdNumber.highlighted = NO;
        fourthNumber.highlighted = NO;
    }else if([PINText length] == 3){
        thirdNumber.highlighted = YES;
        fourthNumber.highlighted = NO;
    }else{
        [self resetDisplay:self];
    }
}

-(void)resetDisplay:(id)sender{
    firstNumber.highlighted = NO;
    secondNumber.highlighted = NO;
    thirdNumber.highlighted = NO;
    fourthNumber.highlighted = NO;
}

- (void)viewDidLoad {
    NSLog(@"Pinlock screen loaded");
	[super viewDidLoad];
    PINText = @"";
    self.title = @"";
    self.secureTextEntry = YES;
    spinner.hidesWhenStopped = YES;
    secondEntry = NO;
    confirmPIN = YES;
    PINText = [[NSString alloc] init];
    comparePIN = [[NSString alloc] init];
    newEncryptedPIN = [[NSString alloc] init];
    encryptedPIN = [[NSString alloc] init];
    

    // setup pinfields list
	pinFields = [[NSArray alloc] initWithObjects:
				 firstNumber, secondNumber,
				 thirdNumber, fourthNumber, nil];
    PINText = @"";
}

-(void)navCustomization
{
    NSLog(@"nav custoing");
    if (resetPIN || self.resPin) {
        NSLog(@"WTF");
        [leftNavButton setBackgroundImage:[UIImage imageNamed:@"CancelButton_Dark.png"] forState:UIControlStateNormal];
        CGRect frame = CGRectMake(0, 0, 51, 34);
        leftNavButton.frame = frame;
        leftNavButton.hidden = NO;
        prompt.text = @"Please confirm your PIN.";
    }
    [leftNavButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

    if(creatingAcct){
        leftNavButton.hidden = NO;
        resetPIN = NO;
        reqImm = NO;
    }

    if (reqImm) {
        leftNavButton.hidden = YES;
        prompt.text = @"Please enter your PIN.";
    }
}

-(void)resetPinFlag{
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"CancelButton_Dark.png"] forState:UIControlStateNormal];
    CGRect frame = CGRectMake(0, 0, 51, 34);
    leftNavButton.frame = frame;
    leftNavButton.hidden = NO;
    leftNavButton.userInteractionEnabled = YES;
    prompt.text = @"Please confirm your PIN.";
    reqImm = NO;
    self.resPin = YES;
}

-(void)goBack
{
    if (self.resPin) {
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [navCtrl popViewControllerAnimated:YES];
    }

    
}

- (void)viewDidUnload {
	
    [self setFirstNumber:nil];
    [self setSecondNumber:nil];
    [self setThirdNumber:nil];
    [self setFourthNumber:nil];
    [self setPrompt:nil];
    [self setSpinner:nil];
    [self setBackgroundImage:nil];
    keyboard = nil;
    pinTextField = nil;
    navBar = nil;
    leftNavButton = nil;
	[super viewDidUnload];
	
	pinFields = nil;
}

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		PINText = @"";
		self.title = @"";
		self.secureTextEntry = YES;
	}
	return self;
}*/


# pragma mark - serve delegation

-(void)listen:(NSString*)result tagName:(NSString*)tagName
{
    NSDictionary *loginResult = [result JSONValue];
    NSDictionary *template =[result JSONValue];
    keyboard.userInteractionEnabled = YES;
    leftNavButton.userInteractionEnabled = YES;
    [pinTextField becomeFirstResponder];
    if([tagName isEqualToString:@"EncryptReqImm"]){
        NSLog(@"got encrypted reqImm %@",template);
        responseData = [NSMutableData data];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@", @"https://192.203.102.254/NoochService.svc", @"ValidatePinNumber", @"memberId",[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"pinNo",[loginResult objectForKey:@"Status"]]]];
        NSString * urlString = [NSString stringWithFormat:@"%@"@"/%@?%@=%@&%@=%@", @"http://172.17.60.150/NoochService/NoochService.svc", @"ValidatePinNumber", @"memberId",[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"], @"pinNo",[loginResult objectForKey:@"Status"]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (!connection) {
            NSLog(@"connection error");
        }
    }else if([tagName isEqualToString:@"GetEncryptedData"] && !self.resPin){
        encryptedPIN=[loginResult objectForKey:@"Status"];
        responseData = [[NSMutableData alloc] init];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/GetEncryptedData?data=%@", MyUrl,[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]]]];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }else if ([tagName isEqualToString:@"getMemId"]){
        [[NSUserDefaults standardUserDefaults] setObject:[loginResult objectForKey:@"Result"] forKey:@"MemberId"];
        [spinner stopAnimating];
        me = [core new];
        [me birth];
        [[me usr] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"] forKey:@"firstName"];
        [[me usr] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"] forKey:@"lastName"];
        [[me usr] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MemberId"] forKey:@"MemberId"];
        [[me usr] setObject:@"0.00" forKey:@"Balance"];
        tempImg = UIImagePNGRepresentation(selectedPic);
        [me stamp];
        [navCtrl popToRootViewControllerAnimated:NO];
        [self dismissModalViewControllerAnimated:YES];
        UIAlertView *decline= [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Thanks for joining us here at Nooch!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [decline show];
        
    }else if([tagName isEqualToString:@"loginRequest"]){
        serve *req = [[serve alloc] init];
        req.Delegate = self;
        req.tagName = @"getMemId";
        [req getMemIdFromuUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]];
    }else if ([tagName isEqualToString:@"MemberRegistration"]){
        NSLog(@"login result %@",result);
        if([[template objectForKey:@"Result"] isEqualToString:@"Thanks for registering! Check your email to complete activation."])
        {
            
            //[decline setTag:1];
            [[NSUserDefaults standardUserDefaults] setObject:@"asdfa" forKey:@"setPrompt"];
            //[spinner stopAnimating];
            serve *login = [serve new];
            login.Delegate = self;
            login.tagName = @"loginRequest";
            [login login:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] password:getEncryptedPassword];
            
            keyboard.userInteractionEnabled = NO;
            leftNavButton.userInteractionEnabled = NO;
            return;
        }
        else if([[template objectForKey:@"Result"] isEqualToString:@"You are already a nooch member."])
        {
            UIAlertView *decline= [[UIAlertView alloc] initWithTitle:@"Well..." message:@"This address already exists in our system, we do not support cloning you."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [decline show];
            [decline setTag:1];
            [spinner stopAnimating];
            return;
        }else{
            [spinner stopAnimating];
            //[self dismissModalViewControllerAnimated:YES];
            return;
        }
        
        pinEncrypted = pinEncrypted;
        passwordEncrypted = getEncryptedPassword;
        [navCtrl popToRootViewControllerAnimated:NO];
        [self dismissModalViewControllerAnimated:YES];
        //[navCtrl presentModalViewController:[storyboard instantiateViewControllerWithIdentifier:@"login"] animated:YES];
    }else if([[loginResult objectForKey:@"Result"] isEqualToString:@"Success"] && [tagName isEqualToString:@"ValidatePinNumber"])
    {
        [spinner stopAnimating];
        prompt.text = @"Enter your new PIN.";
        confirmPIN = NO;
        return;
    }
    else if([[loginResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
    {
        prompt.text=@"1 Failed Attempt";
        [backgroundImage setHighlighted:YES];
        [spinner stopAnimating];
        return;
    }
    else if([[loginResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
    {
        prompt.text=@"2 Failed Attempts";
        [backgroundImage setHighlighted:YES];
        [spinner stopAnimating];
        return;
    }
    
    else if(([[loginResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
        prompt.text=@"3 Failed Attempts";
        [backgroundImage setHighlighted:YES];
        [spinner stopAnimating];
        return;
    }
    else if(([[loginResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [backgroundImage setHighlighted:YES];
        [spinner stopAnimating];
        return;
        
        
    }else if([tagName isEqualToString:@"GetEncryptedData"] && self.resPin && confirmPIN)
    {
        [spinner startAnimating];
        encryptedPIN=[loginResult objectForKey:@"Status"];
        serve *req = [[serve alloc] init];
        req.Delegate = self;
        req.tagName = @"ValidatePinNumber";
        keyboard.userInteractionEnabled = NO;
        leftNavButton.userInteractionEnabled = NO;
        [req pinCheck:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pin:encryptedPIN];
        //[req methodName:@"ValidatePinNumber" memberId:@"memberId" memberIdValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"] pinNumber:@"pinNo" pinNumberValue:encryptedPIN];
    }else if([tagName isEqualToString:@"GetEncryptedData"] && self.resPin && !confirmPIN){
        newEncryptedPIN=[loginResult objectForKey:@"Status"];
        serve *resPin = [[serve alloc] init];
        resPin.Delegate = self;
        resPin.tagName = @"resetPinNumberDetails";
        [resPin resetPIN:encryptedPIN new:newEncryptedPIN];
        keyboard.userInteractionEnabled = NO;
        leftNavButton.userInteractionEnabled = NO;
    }else if([tagName isEqualToString:@"resetPinNumberDetails"]){
        NSDictionary *loginResult = [result JSONValue];
        NSString *statusData= (NSString *)[loginResult objectForKey:@"Result"];
        NSLog(@"Status %@", statusData);
        [self pinChanged:statusData];
    }
}

-(void)pinChanged:(NSString*)status
{
    if([status isEqualToString:@"Pin changed successfully."])
    {
        
        UIAlertView *showAlertMessage = [[UIAlertView alloc] initWithTitle:nil message:@"Your PIN number has been changed successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [showAlertMessage setTag:2];
        [showAlertMessage setDelegate:self];
        [showAlertMessage show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [[me usr] setObject:@"NO" forKey:@"requiredImmediately"];
        }else{
            [[me usr] setObject:@"YES" forKey:@"requiredImmediately"];
        }
        reqImm = NO;

        [navCtrl popToRootViewControllerAnimated:NO];
        [self dismissModalViewControllerAnimated:YES];
    }else if(alertView.tag == 2){
        [self dismissModalViewControllerAnimated:YES];
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
	NSLog(@"Connection failed: %@", [error description]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    keyboard.userInteractionEnabled = YES;
    leftNavButton.userInteractionEnabled = YES;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSDictionary *loginResult = [responseString JSONValue];
    NSLog(@"validation %@",loginResult);
    if (reqImm) {
        PINText = @"";
        if ([[loginResult objectForKey:@"Result"] isEqualToString:@"Success"]) {
            if ([[me usr] objectForKey:@"requiredImmediately"] == NULL || [[[me usr] objectForKey:@"requiredImmediately"] isKindOfClass:[NSNull class]]) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"FYI" message:@"The Require Immediately function is an added security feature to prompt you for your PIN whenever you enter Nooch. Would you like to keep this on or turn it off? You can change this setting later in the PIN Settings page." delegate:self cancelButtonTitle:@"Turn Off" otherButtonTitles:@"Keep On", nil];
                [av setTag:1];
                [av show];
                return;
            }else{
                NSLog(@"yuppppp");
                reqImm = NO;
                [self dismissModalViewControllerAnimated:YES];
                return;
            }
        }else if([[loginResult objectForKey:@"Result"] isEqualToString:@"PIN number you have entered is incorrect."])
        {
            [self resetDisplay:self];
            prompt.text=@"1 Failed Attempt";
            [backgroundImage setHighlighted:YES];
            [spinner stopAnimating];
            return;
        }


        else if([[loginResult objectForKey:@"Result"]isEqual:@"PIN number you entered again is incorrect. Your account will be suspended for 24 hours if you enter wrong PIN number again."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Wrong PIN again... If you enter it in wrong one more time your account will be suspended for 24 hours." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

            [av show];
            [self resetDisplay:self];
            prompt.text=@"2 Failed Attempts";
            [backgroundImage setHighlighted:YES];
            [spinner stopAnimating];
            return;
        }

        else if(([[loginResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended for 24 hours from now. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))            {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

            [av show];
            [self resetDisplay:self];
            prompt.text=@"3 Failed Attempts";
            [backgroundImage setHighlighted:YES];
            [spinner stopAnimating];
            return;
        }
        else if(([[loginResult objectForKey:@"Result"] isEqualToString:@"Your account has been suspended. Please contact admin or send a mail to support@nooch.com if you need to reset your PIN number immediately."]))
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended for 24 hours. Please contact us via email at support@nooch.com if you need to reset your PIN number immediately." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [self resetDisplay:self];
            [backgroundImage setHighlighted:YES];
            [spinner stopAnimating];
            return;
            
            
        }else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"We encountered an error while trying to validate your PIN. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            [self resetDisplay:self];
            [spinner stopAnimating];
            return;
        }
    }

    NSDictionary *template =[responseString JSONValue];


    if([template objectForKey:@"Result"])
    {
        UIAlertView *decline= [[UIAlertView alloc] initWithTitle:@"" message:[template objectForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [decline show];
        [spinner stopAnimating];
    }
    
    if([template objectForKey:@"Status"])
    {
        getEncryptedPassword = [[NSString alloc] initWithString:[template objectForKey:@"Status"]];
        serve *req = [[serve alloc] init];
        req.Delegate = self;
        req.tagName=@"MemberRegistration";
        keyboard.userInteractionEnabled = NO;
        leftNavButton.userInteractionEnabled = NO;
        [req newUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] first:[[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"] last:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"] password:getEncryptedPassword pin:encryptedPIN invCode:@"pilot"];
        //[req methodName:@"MemberRegistration" userName:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] firstName:[[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"] lastName:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"] password:getEncryptedPassword pinNumber:encryptedPIN invCode:@"pilot"];//inviteCode
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
@end
