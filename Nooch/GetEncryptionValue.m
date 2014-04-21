//
//  GetEncryptionValue.m
//  Nooch
//
//  Created by developer on 09/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GetEncryptionValue.h"
#import "Constant.h"
#import "NSString+ASBase64.h"
//#import "CJSONSerializer.h"
//#import "CJSONDataSerializer.h"
//#import "JSON.h"
NSMutableURLRequest*requestEncryption;

@implementation GetEncryptionValue

@synthesize Delegate, tag;

# pragma mark - Custom Method

-(void)getEncryptionData:(NSString *) stringtoEncry {
    
    NSString *encodedString = [NSString encodeBase64String:stringtoEncry];
    
    responseData = [[NSMutableData alloc] init];
    requestEncryption = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", MyUrl,@"GetEncryptedData",@"data",encodedString]]];
    [requestEncryption setHTTPMethod:@"GET"];
    [requestEncryption setTimeoutInterval:500.0f];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:requestEncryption delegate:self];
    if (!connection)
        NSLog(@"connect error");
    
}

//    serve *enc = [serve new];
//
//    enc.Delegate = self;
//    [enc getEncrypt:stringtoEncry];
//
//}
# pragma mark - NSURL Connection Methods

//response method for all request
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    NSError* error;
    
    // SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    id object = [NSJSONSerialization
                 JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                 error:&error];;
    
    NSMutableArray *transResult;
    
    if (object != nil) {
        // Success!
        transResult = [NSJSONSerialization
                       JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                       options:kNilOptions
                       error:&error];;
    }
    
    NSMutableDictionary *loginResult = [NSJSONSerialization
                                        JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                        options:kNilOptions
                                        error:&error];;
    NSString *resultStr = [[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]];
    [self.Delegate encryptionDidFinish:resultStr TValue:self.tag];
    // [self.Delegate decryptionDidFinish:loginResult TValue:self.tag];
    
    //[responseData release];
    
}

//-(void)listen:(NSString *)result tagName:(NSString*)tagName {
//    NSError* error;
//
//
//    NSDictionary *loginResult = [NSJSONSerialization
//                                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
//                                 options:kNilOptions
//                                 error:&error];;
//    NSLog(@"Dictionary value is : %@", loginResult);
//
//    NSString *resultStr = [[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]];
//
//    [self.Delegate encryptionDidFinish:resultStr TValue:self.tag];
//
//}


@end
