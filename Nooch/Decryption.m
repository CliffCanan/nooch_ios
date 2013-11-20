//
//  Decryption.m
//  Nooch
//
//  Created by developer on 28/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Decryption.h"
#import "Constant.h"
#import "CJSONSerializer.h"
#import "CJSONDataSerializer.h"
#import "JSON.h"

@implementation Decryption

@synthesize Delegate, responseData, tag;
NSMutableURLRequest *request1,*request2;

# pragma mark - Custom Method

-(void)getDecryptedValue:(NSString *) methodName pwdString:(NSString *) sources {
    
    self.responseData = [[NSMutableData data] retain]; 
   request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?data=%@", MyUrl, methodName, sources]]];
    
    //Load the request in the UIWebView.
    [[NSURLConnection alloc] initWithRequest:request1 delegate:self];
    
}
-(void)getDecryptionL:(NSString*)methodName textString:(NSString*)text
{
    self.responseData = [[NSMutableData data] retain];
    NSURLRequest *requisicao = [NSURLRequest requestWithURL:
                                [NSURL URLWithString:
                                 [[NSString stringWithFormat:@"%@"@"/%@?data=%@", MyUrl, methodName, text] stringByAddingPercentEscapesUsingEncoding:
                                  NSUTF8StringEncoding]]];
    //request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?data=%@", MyUrl, methodName, text]]];
    
    //Load the request in the UIWebView.
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
    
    
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    id object = [parser objectWithString:responseString];
    
    NSMutableArray *transResult;
    
    if (object != nil) {
        // Success!
        transResult = [responseString JSONValue];
    }
    
    NSMutableDictionary *loginResult = [responseString JSONValue];
    
    [self.Delegate decryptionDidFinish:loginResult TValue:self.tag];
    
    [responseData release];
    
}


@end
