//
//  addNewCard.m
//  Nooch
//
//  Created by Preston Hults on 5/14/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "addNewCard.h"
#import "Constant.h"

@interface addNewCard ()

@end

@implementation addNewCard

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    scrollView.contentSize = CGSizeMake(320,600);
}

-(void)viewWillAppear:(BOOL)animated{
    [navBar setBackgroundImage:[UIImage imageNamed:@"TopNavBarBackground.png"]  forBarMetrics:UIBarMetricsDefault];
    [leftNavButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [nameOnCard setInputAccessoryView:inputAccess];
    [cardNumField setInputAccessoryView:inputAccess];
    [secCodeField setInputAccessoryView:inputAccess];
    [expirationField setInputAccessoryView:inputAccess];
    [zipField setInputAccessoryView:inputAccess];
    [doneEntering addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [previousButton addTarget:self action:@selector(previousField) forControlEvents:UIControlEventTouchUpInside];
    [nextButton addTarget:self action:@selector(nextField) forControlEvents:UIControlEventTouchUpInside];
    detailsTable.layer.cornerRadius = 10;
    detailsTable.layer.borderWidth = 1.0f;
    detailsTable.layer.borderColor = [core hexColor:@"b3b3b3"].CGColor;
}

- (IBAction)scanCard:(id)sender {
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.appToken = @"59f7a8042cb640198a5aeeaffae4e6ff"; // get your app token from the card.io website
     [self presentViewController:scanViewController animated:YES completion:nil];
    //[self presentModalViewController:scanViewController animated:YES];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
    //[scanViewController dismissModalViewControllerAnimated:YES];
}
- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02i/%i, cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    // Use the card info...
    expirationField.text = [NSString stringWithFormat:@"%02i/%i",info.expiryMonth,info.expiryYear];
    cardNumField.text = info.cardNumber;
    secCodeField.text = info.cvv;
    [scanViewController dismissViewControllerAnimated:YES completion:nil];

    //[scanViewController dismissModalViewControllerAnimated:YES];
}

-(void)cancel{
    [[navCtrl.viewControllers objectAtIndex:0] performSelectorOnMainThread:@selector(showFundsMenu) withObject:nil waitUntilDone:YES];
    [navCtrl dismissViewControllerAnimated:YES completion:nil];

   // [navCtrl dismissModalViewControllerAnimated:YES];
}
- (IBAction)addCard:(id)sender {
    
    NSString *urlString =[NSString stringWithFormat:@"%@/GetEncryptedCardDetails", MyUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *accountData = [NSDictionary dictionaryWithObjectsAndKeys: cardNumField.text,@"CardNumber", secCodeField.text,@"VerificationNumber",expirationField.text, @"ExpirationDate", nil];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *acctParam = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)accountData,@"cardDetails",[defaults valueForKey:@"OAuthToken"],@"accessToken", nil];
    NSString *post = [acctParam JSONRepresentation];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection)
    {
        responseData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"cws error");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSDictionary *resultValue = [result JSONValue];
    NSString *strCardNumber = [[NSString alloc] initWithString:[[resultValue objectForKey:@"GetEncryptedCardDetailsResult"]objectForKey:@"CardNumber"]];
    NSString *strVerificationNumber = [[NSString alloc] initWithString:[[resultValue objectForKey:@"GetEncryptedCardDetailsResult"]objectForKey:@"VerificationNumber"]];
    NSString *strExpirationDate = [[NSString alloc] initWithString:[[resultValue objectForKey:@"GetEncryptedCardDetailsResult"]objectForKey:@"ExpirationDate"]];
    NSString *cardType;
    if([[cardNumField.text substringToIndex:1] intValue] == 4){
        cardType = @"VISA";
    }else if([[cardNumField.text substringToIndex:1] intValue] == 5){
        cardType = @"MSTR";
    }else if([[cardNumField.text substringToIndex:1] intValue] == 6){
        cardType = @"DSCR";
    }else if([[cardNumField.text substringToIndex:1] intValue] == 3){
        cardType = @"AMEX";
    }else{
        cardType = @"";
    }
    NSLog(@"card type: %@",cardType);
    NSDictionary *accountData = [NSDictionary dictionaryWithObjectsAndKeys: [[me usr] objectForKey:@"MemberId"],@"MemberId", nameOnCard.text,@"CardHolderName",cardType,@"CardType",strCardNumber,@"CardNumber",strVerificationNumber,@"VerificationNumber",strExpirationDate,@"ExpirationDate",zipField.text,@"BillingZipCode",nil];
    NSDictionary *acctParam = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)accountData,@"accountInput", nil];
    serve *addCard = [serve new];
    addCard.tagName = @"addCard";
    addCard.Delegate = self;
    [addCard saveCard:[acctParam mutableCopy]];
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    NSDictionary *save = [result JSONValue];
    NSLog(@"Save card details: %@", save);

    NSDictionary *serviceDict = [save objectForKey:@"SaveCardAccountDetailsResult"];

    if([[serviceDict objectForKey:@"Result"] isEqualToString:@"Your card account details have been updated successfully."])
    {
        UIAlertView *serviceMessage= [[UIAlertView alloc] initWithTitle:@"" message:[serviceDict objectForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [serviceMessage show];
        [serviceMessage setTag:7];
    }
    else if([[serviceDict objectForKey:@"Result"] isEqualToString:@"Your card account details have been saved successfully."])
    {
        UIAlertView *serviceMessage= [[UIAlertView alloc] initWithTitle:@"" message:[serviceDict objectForKey:@"Result"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [serviceMessage show];
        [serviceMessage setTag:7];
        [navCtrl dismissViewControllerAnimated:YES completion:nil];

        //[navCtrl dismissModalViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *serviceMessage= [[UIAlertView alloc] initWithTitle:@"Error" message:@"We ran into some difficulties adding your card, please try again later."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [serviceMessage show];
    }
}

- (IBAction)setExpiration:(id)sender {
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == nameOnCard || textField == cardNumField) {
        return;
    }else if(textField == zipField){
        [scrollView setContentOffset:CGPointMake(0.0,textField.frame.size.height+30*textField.tag) animated:YES];
    }else
        [scrollView setContentOffset:CGPointMake(0.0,textField.frame.size.height+20*textField.tag) animated:YES];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField == zipField){
        if([newString length] > 5)
            return NO;
    }else if(textField == cardNumField){
        if([newString length] > 16)
            return NO;
    }else if(textField == secCodeField){
        if([newString length] > 4)
            return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:YES];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == zipField)
        [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:YES];
}

- (void)closeKeyboard {
    [nameOnCard resignFirstResponder];
    [cardNumField resignFirstResponder];
    [secCodeField resignFirstResponder];
    [expirationField resignFirstResponder];
    [zipField resignFirstResponder];

}
- (void)previousField {
    if(cardNumField.isFirstResponder){
        [nameOnCard becomeFirstResponder];
    }else if(secCodeField.isFirstResponder){
        [cardNumField becomeFirstResponder];
    }else if(expirationField.isFirstResponder){
        [secCodeField becomeFirstResponder];
    }else if(zipField.isFirstResponder){
        [expirationField becomeFirstResponder];
    }
}
- (void)nextField {
    if(cardNumField.isFirstResponder){
        [secCodeField becomeFirstResponder];
    }else if(secCodeField.isFirstResponder){
        [expirationField becomeFirstResponder];
    }else if(expirationField.isFirstResponder){
        [zipField becomeFirstResponder];
    }else if(nameOnCard.isFirstResponder){
        [cardNumField becomeFirstResponder];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    cell.detailTextLabel.text = @"";
    cell.indentationLevel = 1;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 34, 35)];
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = 6;
    [cell.textLabel setFont:[core nFont:@"Medium" size:13.0]];
    cell.indentationWidth = 5;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    if(indexPath.row == 0){
        [cell.textLabel setText:@"Name on Card"];
    }else if(indexPath.row == 1){
        [cell.textLabel setText:@"Card Number"];
    }else if(indexPath.row == 2){
        [cell.textLabel setText:@"Security Code"];
    }else if(indexPath.row == 3){
        [cell.textLabel setText:@"Expiration Date"];
    }else if(indexPath.row == 4){
        [cell.textLabel setText:@"Billing ZIP Code"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    leftNavButton = nil;
    navBar = nil;
    scrollView = nil;
    detailsTable = nil;
    nameOnCard = nil;
    cardNumField = nil;
    secCodeField = nil;
    expirationField = nil;
    zipField = nil;
    inputAccess = nil;
    doneEntering = nil;
    previousButton = nil;
    nextButton = nil;
    [super viewDidUnload];
}
@end
