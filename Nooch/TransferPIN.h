//
//  TransferPIN.h
//  Nooch
//
//  Created by crks on 9/30/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import "Home.h"
#import "serve.h"

@interface TransferPIN : UIViewController<UITextFieldDelegate,serveD>

- (id)initWithReceiver:(NSMutableDictionary *)receiver type:(NSString *)type amount:(float)amount;

@end
