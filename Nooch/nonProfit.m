//
//  nonProfit.m
//  Nooch
//
//  Created by Vicky Mathneja on 14/12/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "nonProfit.h"
#import "JSON.h"
#import "SBJSON.h"
#import "UIImageView+WebCache.h"
#import "Decryption.h"
#import "transfer.h"
@interface nonProfit ()<DecryptionDelegate>
{
    NSString*ServiceType;
}
@end

@implementation nonProfit
@synthesize dictnonprofitid;
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
    dict=[[NSMutableDictionary alloc]init];
    dictToSend=[[NSMutableDictionary alloc]init];
	// Do any additional setup after loadiing the view.
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.navigationItem.title=[dictnonprofitid valueForKey:@"OrganizationName"];
    serve*serveOBJ=[serve new];
    serveOBJ.Delegate=self;
    serveOBJ.tagName=@"npDetail";
    [serveOBJ GetNonProfiltDetail:[dictnonprofitid valueForKey:@"id"]];
    
}
-(void)listen:(NSString *)result tagName:(NSString *)tagName{
    detailArr=[NSMutableArray new];
    detailArr=[result JSONValue];
    lblDetail.text=[[detailArr objectAtIndex:0] valueForKey:@"Description"];
    [imgdetail setImageWithURL:[NSURL URLWithString:[[detailArr objectAtIndex:0] valueForKey:@"PhotoBanner"]]
       placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
    [dict setValue:[[detailArr objectAtIndex:0] valueForKey:@"MemberId"] forKey:@"ResMemberid"];
    
    ServiceType=@"Fname";
    Decryption *decry = [[Decryption alloc] init];
    decry.Delegate = self;
    decry->tag = [NSNumber numberWithInteger:2];
    [decry getDecryptionL:@"GetDecryptedData" textString:[[detailArr objectAtIndex:0] valueForKey:@"FirstName"]];
    
}
-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue{
    if ([ServiceType isEqualToString:@"Fname"]) {
        [dict setValue:[sourceData valueForKey:@"Status"] forKey:@"FirstName"];
        
        ServiceType=@"Lname";
        Decryption *decry = [[Decryption alloc] init];
        decry.Delegate = self;
        decry->tag = [NSNumber numberWithInteger:2];
        [decry getDecryptionL:@"GetDecryptedData" textString:[[detailArr objectAtIndex:0] valueForKey:@"LastName"]];
        

    }
    else
    {
       [dict setValue:[sourceData valueForKey:@"Status"] forKey:@"LastName"];
        
    }
}
- (IBAction)webLink:(id)sender {
}
- (IBAction)fb:(id)sender {
}
- (IBAction)twitter:(id)sender {
}
- (IBAction)youtube:(id)sender {
}
- (IBAction)donateClicked:(id)sender {
    [dictToSend setObject:dict forKey:@"donation"];
    isDonationMade=YES;
    transfer*transferOBJ=[self.storyboard instantiateViewControllerWithIdentifier:@"transfer"];
    transferOBJ.dictResp=dictToSend;
    [self presentViewController:transferOBJ animated:YES completion:Nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
