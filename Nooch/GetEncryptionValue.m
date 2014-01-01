//
//  GetEncryptionValue.m
//  Nooch
//
//  Created by developer on 09/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GetEncryptionValue.h"
//#import "CJSONSerializer.h"
//#import "CJSONDataSerializer.h"
//#import "JSON.h"


@implementation GetEncryptionValue

@synthesize Delegate, tag;

# pragma mark - Custom Method

-(void)getEncryptionData:(NSString *) stringtoEncry {

    serve *enc = [serve new];
    enc.Delegate = self;
    [enc getEncrypt:stringtoEncry];
    
}

-(void)listen:(NSString *)result tagName:(NSString*)tagName {
    NSError* error;
    

    NSDictionary *loginResult = [NSJSONSerialization
                                 JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                 options:kNilOptions
                                 error:&error];;
    NSLog(@"Dictionary value is : %@", loginResult);
    
    NSString *resultStr = [[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]];
    
    [self.Delegate encryptionDidFinish:resultStr TValue:self.tag];
    
}


@end
