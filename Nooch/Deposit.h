//
//  Deposit.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface Deposit : UIViewController<UITextFieldDelegate,serveD,UITableViewDataSource,UITableViewDelegate>
- (id)initWithData:(NSArray *)bankinfo;

@end
