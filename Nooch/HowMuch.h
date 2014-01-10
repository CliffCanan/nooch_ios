//
//  HowMuch.h
//  Nooch
//
//  Created by crks on 9/26/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"

@interface HowMuch : UIViewController<UITextFieldDelegate,serveD,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithReceiver:(NSDictionary *)receiver;

@end
