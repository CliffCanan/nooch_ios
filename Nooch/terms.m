//
//  terms.m
//  Nooch
//
//  Created by administrator on 12/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "terms.h"
#import "NSString+SBJSON.h"
#import "NSData+AESCrypt.h"
#import "NSString+AESCrypt.h"

@implementation terms

@synthesize termsView,spinner;

# pragma mark - View lifecycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil value:(NSString *)sendValue
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    termsView.backgroundColor = [UIColor clearColor];
    termsView.opaque = 0;
    
    [self navCustomization];
    self.navigationItem.title = @"Terms of Service";

    serve *tos = [serve new];
    tos.Delegate = self;
    [tos tos];
}

-(void)navCustomization
{
}

-(void)goBack
{
    [navCtrl dismissModalViewControllerAnimated:YES];
}

- (IBAction) acceptButtonAction
{
    [navCtrl dismissModalViewControllerAnimated:YES];
}

-(void)listen:(NSString *)result tagName:(NSString*)tagName
{
    NSDictionary *template =[result JSONValue];
    [termsView loadHTMLString:[template objectForKey:@"Result"] baseURL:nil];
    [spinner stopAnimating];
    for (id subView in [termsView subviews]) {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)]) {
            [subView flashScrollIndicators];
        }
    }
}

@end
