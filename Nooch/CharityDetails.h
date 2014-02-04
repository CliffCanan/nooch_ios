//
//  CharityDetails.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "Decryption.h"
NSMutableDictionary*dictnonprofitid;
@interface CharityDetails : UIViewController<serveD,DecryptionDelegate>
{
    UIImageView *image;
    UILabel *info;
    NSString* ServiceType;
    NSMutableDictionary*detaildict;
    NSMutableDictionary*dict;
    NSString*weburl;
    NSString*youurl;
    NSString*fburl;
    NSString*twurl;
    UIActivityIndicatorView*spinner;
    UIView*blankView;
}

- (id)initWithReceiver:(NSDictionary *)charity;

@end
