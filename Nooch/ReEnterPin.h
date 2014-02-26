//
//  ReEnterPin.h
//  Nooch
//
//  Created by Vicky Mathneja on 08/01/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import "Home.h"
#import <MessageUI/MessageUI.h>
@interface ReEnterPin : UIViewController<serveD,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
{
    UIActivityIndicatorView*spinner;
    NSDictionary*dictResult;
    
}
@end
