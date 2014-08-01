//
//  LimitsAndFees.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface LimitsAndFees : UIViewController<serveD,UIWebViewDelegate>
@property (retain,nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property(nonatomic, strong) IBOutlet UIWebView *LimitsAndFeesView;
@end
