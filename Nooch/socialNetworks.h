//
//  socialNetworks.h
//  Nooch
//
//  Created by Preston Hults on 5/27/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoochHome.h"
#import "serve.h"

@interface socialNetworks : UIViewController<serveD>{
    
    __weak IBOutlet UISwitch *allowSharingSwitch;
    __weak IBOutlet UIButton *dcFb;
    __weak IBOutlet UIView *fbConnectedView;
    __weak IBOutlet UIButton *connectFb;
    __weak IBOutlet UINavigationBar *navBar;
    __weak IBOutlet UIButton *leftNavButton;
    __weak IBOutlet UIView *notConnectedView;
}

@end
