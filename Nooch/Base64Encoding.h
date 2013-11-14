//
//  Base64Encoding.h
//  DoMyExpenses
//
//  Created by devuser on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;
+ (NSData *)base64DataFromString: (NSString *)string;
@end