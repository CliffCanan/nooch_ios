//
//  privacy.m
//  Nooch
//
//  Created by administrator on 12/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "privacy.h"
#import "terms.h"
#import "NSString+SBJSON.h"

@implementation privacy

@synthesize privacyView,spinner;

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
    //[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    privacyView.backgroundColor = [UIColor clearColor];
    privacyView.opaque = 0;
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];

    [self navCustomization];

    serve *pp = [serve new];
    pp.Delegate = self;
    [pp privacyPolicy];
}

-(void)navCustomization
{
    self.navigationItem.title = @"Privacy Policy";
}

-(void)goBack
{
    [navCtrl dismissViewControllerAnimated:YES completion:nil];
    //[navCtrl dismissModalViewControllerAnimated:YES];
}



# pragma mark - serve delegation

-(void)listen:(NSString *)result tagName:(NSString*)tagName
{
    NSDictionary *template =[result JSONValue];
    
    if([template objectForKey:@"Result"])
    {
        [privacyView loadHTMLString:[template objectForKey:@"Result"] baseURL:nil];
    }
    [spinner stopAnimating];
    for (id subView in [privacyView subviews]) {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)]) {
            [subView flashScrollIndicators];
        }
    }

}


- (IBAction)continueButtonAction
{
   
    [navCtrl dismissViewControllerAnimated:YES completion:nil];
   //[navCtrl dismissModalViewControllerAnimated:YES];
}


@end
