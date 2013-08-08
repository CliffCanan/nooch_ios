//
//  popup.h
//  Nooch
//
//  Created by Preston Hults on 7/26/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface popup : UIViewController{
    UIView *pup;
    NSString *msg;

}

-(void)slideIn:(id)obj;
-(void)slideOut:(id)obj;
-(void)fadeIn:(id)obj;
-(void)fadeOut:(id)obj;
@end
