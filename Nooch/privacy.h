//
//  privacy.h
//  Nooch
//
//  Created by administrator on 12/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"


@interface privacy : UIViewController <serveD>

@property(nonatomic, retain) IBOutlet UIWebView *privacyView;
@property (retain,nonatomic) IBOutlet UIActivityIndicatorView *spinner;

-(IBAction)continueButtonAction;

@end
