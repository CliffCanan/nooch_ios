//
//  HowMuch.h
//  Nooch
//
//  Created by crks on 9/26/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
BOOL isFromHome;
BOOL isFromStats;
BOOL isFromMyApt;
BOOL isPayBack;
BOOL isUserByLocation;

@interface HowMuch : GAITrackedViewController<UITextFieldDelegate,serveD,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString * transLimitFromArtisanString;
    int transLimitFromArtisanInt;
}

- (id)initWithReceiver:(NSDictionary *)receiver;
@property(nonatomic,strong)UIButton*balance;
@end
