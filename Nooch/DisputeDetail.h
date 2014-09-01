//
//  DisputeDetail.h
//  Nooch
//
//  Created by Vicky Mathneja on 01/08/14.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import <MessageUI/MessageUI.h>
@interface DisputeDetail : GAITrackedViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,serveD,MFMailComposeViewControllerDelegate>

- (id)initWithData:(NSDictionary *)trans;
@end
