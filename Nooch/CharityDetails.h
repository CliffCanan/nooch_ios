//
//  CharityDetails.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
NSMutableDictionary*dictnonprofitid;
@interface CharityDetails : UIViewController<serveD>
{

    NSMutableDictionary*dictToSend;
    NSMutableDictionary*dict;
}
- (id)initWithReceiver:(NSDictionary *)charity;

@end
