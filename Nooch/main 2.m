//
//  main.m
//  Nooch
//
//  Created by administrator on 28/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pixate/Pixate.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [Pixate licenseKey:@"VBN50-E9D6U-L329R-KEUBS-FUIID-KNJ09-8PKGQ-9SU3V-DDHPP-NT032-ABVT8-MPO7S-35NB3-H3N4D-LDTUM-7O" forUser:@"preston@nooch.com"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}