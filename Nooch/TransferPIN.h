//
//  TransferPIN.h
//  Nooch
//
//  Created by crks on 9/30/13.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import "Home.h"
#import "serve.h"
#import <MessageUI/MessageUI.h>
#import "SpinKit/RTSpinKitView.h"

@interface TransferPIN : GAITrackedViewController<UITextFieldDelegate,serveD,NSURLConnectionDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate>
{
    NSData *postTransfer;
    NSData *postDataTransfer;
    NSString *addressLine1;
    NSString *city;
    NSString *country;
    NSString *encryptedPINNonUser;
    NSString *longitude;
    NSString *latitude;
    NSString *state;
    NSString *postLengthTransfer;
    NSString *receiverFirst;
    NSString *receiverId;
    NSString *transactionId;
    NSString *responseString;
    NSString *urlStrTranfer;
    NSMutableURLRequest *requestTransfer;
    NSURL *urlTransfer;
    float lon;
    float lat;
    NSMutableDictionary * transactionInputTransfer;
    NSMutableDictionary * transactionTransfer;
    NSDictionary * dictResult;         // in 'listen' for handling PIN result from server
    NSDictionary * dictResultTransfer; // in 'connectionDidFinishLoading' Response from server
    NSDictionary *googleLocationResults;
}
-(id)initWithReceiver:(NSMutableDictionary *)receiver type:(NSString *)type amount:(float)amount;

@end
