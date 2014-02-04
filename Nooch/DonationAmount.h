//
//  DonationAmount.h
//  Nooch
//
//  Created by crks on 10/7/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface DonationAmount : UIViewController<UITextFieldDelegate,serveD,UITextViewDelegate>
{
    UIView*dedicateView;
    NSString*Donation_memo;
    UITextView* txtDedicate;
    
    UILabel *to_label;
}
- (id)initWithReceiver:(NSDictionary *)receiver;

@end
