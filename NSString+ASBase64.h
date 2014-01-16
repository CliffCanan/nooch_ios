//
//  NSString+ASBase64.h
//  ASBaseExample
//
//  Created by
//  Copyright (c) 2013 ID.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ASBase64)

+ (instancetype)encodeBase64String:(NSString *)stringToEncode;
+ (instancetype)decodeBase64String:(NSString *)stringToDeccode;

@end
