//
//  TransferPIN.h
//  Nooch
//
//  Created by crks on 9/30/13.
//  Copyright (c) 2014 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import "Home.h"
#import "serve.h"
#import <MessageUI/MessageUI.h>

@interface TransferPIN : GAITrackedViewController<UITextFieldDelegate,serveD,NSURLConnectionDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate>
{
    
    NSString*Altitude;
    NSString*longitude;
    NSString*latitude;
    NSString*addressLine1;
    NSString*addressLine2;
    NSString*city;
    NSString*state;
    NSString* zipcode;
    NSString* country;
    BOOL transferFinished;
    BOOL sendingMoney;
    NSString*receiverFirst;
    NSMutableDictionary*resultValueTransfer;
    NSString*transactionId;
    NSString*responseString;
    NSMutableURLRequest*requestTransfer;
    NSURL*urlTransfer;
    NSString*urlStrTranfer;
    NSData *postTransfer;
    NSData *postDataTransfer;
    NSString *postLengthTransfer;
    NSDictionary*dictResult;
    NSMutableDictionary* transactionInputTransfer;
    NSMutableDictionary*transactionTransfer;
    float lon;
    float lat;
    NSDictionary*dictLocation;
    NSDictionary*dictResultTransfer;
    UIActivityIndicatorView*spinner;
    NSDictionary*jsonDictionary;
    NSString*encryptedPINNonUser;
    NSString*receiverId;
}
@property(nonatomic,strong)UIButton*balance;
- (id)initWithReceiver:(NSMutableDictionary *)receiver type:(NSString *)type amount:(float)amount;

@end
