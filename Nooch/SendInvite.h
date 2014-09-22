//
//  SendInvite.h
//  Nooch
//
//  Created by crks on 10/8/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "serve.h"
#import "MBProgressHUD.h"

@interface SendInvite : GAITrackedViewController<UITableViewDataSource,UITableViewDelegate,serveD,MFMailComposeViewControllerDelegate,UITextFieldDelegate,MBProgressHUDDelegate>
{
    NSMutableDictionary*dictResponse;
    NSMutableDictionary*dictInviteUserList;
    UITextField*textPhoneto;
    UITextView*msgTextView;
    UIView*SMSView;
    UIButton*btnToSend;
    UILabel *code;
    NSMutableData*pic;
    NSRange start;
    NSRange end;
    NSString *betweenBraces;
    NSString *newString;
    UIView*blankView;
}
@end
