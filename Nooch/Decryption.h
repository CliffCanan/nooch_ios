//
//  Decryption.h
//  Nooch
//
//  Created by developer on 28/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DecryptionDelegate <NSObject>

-(void)decryptionDidFinish:(NSMutableDictionary *) sourceData TValue:(NSNumber *) tagValue;

@end


@interface Decryption : NSObject {
    
    NSMutableData *responseData;
    id <DecryptionDelegate> Delegate;
    
@public
    NSNumber *tag;
    
}

@property (nonatomic, retain) NSNumber *tag;

@property (retain) id <DecryptionDelegate> Delegate;
@property (nonatomic, retain) NSMutableData *responseData;

-(void)getDecryptedValue:(NSString *) methodName pwdString:(NSString *) data;
-(void)getDecryptionL:(NSString*)methodName textString:(NSString*)text;
@end
