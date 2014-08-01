//  Decryption.m
//  Nooch
//  Copyright 2014 Nooch Inc. All rights reserved.

#import "Decryption.h"
#import "Constant.h"
#import "NSString+ASBase64.h"
//#import "CJSONSerializer.h"
//#import "CJSONDataSerializer.h"
//#import "JSON.h"
@implementation Decryption
@synthesize Delegate, responseData, tag;
NSMutableURLRequest *request1,*request2;

# pragma mark - Custom Method

-(void)getDecryptedValue:(NSString *) methodName pwdString:(NSString *) sources {
    
    
    self.responseData = [[NSMutableData data] retain];
    request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?data=%@", MyUrl, methodName, sources]]];
  
    [[NSURLConnection alloc] initWithRequest:request1 delegate:self];
}
-(void)getDecryptionL:(NSString*)methodName textString:(NSString*)text
{
        self.responseData = [[NSMutableData data] retain];
    NSURLRequest *requisicao = [NSURLRequest requestWithURL:
                                [NSURL URLWithString:
                                 [[NSString stringWithFormat:@"%@"@"/%@?data=%@", MyUrl, methodName, text] stringByAddingPercentEscapesUsingEncoding:
                                  NSUTF8StringEncoding]]];
        [[NSURLConnection alloc] initWithRequest:requisicao delegate:self];
}
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
                       error:&error];
    }
    NSMutableDictionary *loginResult=[[NSMutableDictionary alloc]init];
    loginResult = [NSJSONSerialization
                   JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                   options:kNilOptions
                   error:&error];;
    NSString *decodeString = [NSString decodeBase64String:[loginResult valueForKey:@"Status"]];
    NSMutableDictionary *loginResult2=[[NSMutableDictionary alloc]init];
    for (id key  in loginResult) {
        if ([key isEqualToString:@"Status"]) {
            [loginResult2 setObject:decodeString forKey:key];
        }
        else
            [loginResult2 setObject:[loginResult valueForKey:key] forKey:key];
    }
    
    [self.Delegate decryptionDidFinish:loginResult2 TValue:self.tag];
    [responseData release];   
}
@end