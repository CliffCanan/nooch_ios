//
//  verification.h
//  Nooch
//
//  Created by Preston Hults on 7/25/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "NoochHome.h"
#import "core.h"

@interface verification : UIViewController<serveD,UITextFieldDelegate,UIAlertViewDelegate>{
    
    __weak IBOutlet UITextField *amount2;
    __weak IBOutlet UITextField *amount1;
    __weak IBOutlet UINavigationBar *navBar;
}

@end
