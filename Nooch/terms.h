//
//  terms.h
//  Nooch
//
//  Created by administrator on 12/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"


//@class signin;

@interface terms : UIViewController <serveD,UIWebViewDelegate>


@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UIWebView *termsView;

-(IBAction)acceptButtonAction;

@end
