//
//  nonProfit.h
//  Nooch
//
//  Created by Vicky Mathneja on 14/12/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//
BOOL isDonationMade;
#import <UIKit/UIKit.h>
#import "serve.h"
@interface nonProfit : UIViewController<serveD>
{
    NSMutableArray*detailArr;
    IBOutlet UILabel*lblDetail;
    IBOutlet UIImageView*imgdetail;
    NSMutableDictionary*dictToSend;
    NSMutableDictionary*dict;
}
@property(nonatomic,retain)NSMutableDictionary*dictnonprofitid;
@end
