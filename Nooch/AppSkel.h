//
//  AppSkel.h
//  Nooch
//
//  Created by Preston Hults on 9/14/12.
//  Copyright (c) 2012 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "sideMenu.h"
#import "rightMenu.h"

BOOL fbLogging;
NSString *curpage;

@interface AppSkel : UINavigationController

-(void)disable;
-(void)reenable;
@end
