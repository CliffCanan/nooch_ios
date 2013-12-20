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
@interface nonProfit ()

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
	// Do any additional setup after loading the view.
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
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"transfer"] animated:YES completion:Nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
