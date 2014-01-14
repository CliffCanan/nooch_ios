//
//  NSString+ASBase64.m
//  ASBaseExample
//
//  Created by Arthur Sabintsev on 9/7/13.
//  Copyright (c) 2013 ID.me. All rights reserved.
//

#import "NSString+ASBase64.h"

@implementation NSString (ASBase64)

+ (instancetype)encodeBase64String:(NSString *)stringToEncode
{
    NSData *dataToEncode = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
    NSString *encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
    
    return encodedString;
}

+ (instancetype)decodeBase64String:(NSString *)stringToDeccode
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:stringToDeccode options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
}

@end
