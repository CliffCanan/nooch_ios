//
//  SendInvite.h
//  Nooch
//
//  Created by Cliff Canan on 10/8/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "serve.h"
#import "MBProgressHUD.h"
BOOL sentFromStatsScrn;
@interface SendInvite : GAITrackedViewController<UITableViewDataSource,UITableViewDelegate,serveD,MFMailComposeViewControllerDelegate,UITextFieldDelegate,MBProgressHUDDelegate>
{
    NSMutableDictionary * dictResponse;
    NSMutableDictionary * dictInviteUserList;
    UILabel * code;
    NSRange start;
    NSRange end;
    NSString * betweenBraces;
    NSString * newString;
}

@end