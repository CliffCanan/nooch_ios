//
//  NavControl.h
//  Nooch
//
//  Created by crks on 10/1/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
@interface NavControl : UINavigationController

-(void)disable;
-(void)reenable;
-(void)reset;
@end
