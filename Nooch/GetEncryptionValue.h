//
//  GetEncryptionValue.h
//  Nooch
//
//  Created by developer on 09/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "serve.h"

@protocol GetEncryptionValueDelegate <NSObject>

-(void)encryptionDidFinish:(NSString *) encryptedData TValue:(NSNumber *) tagValue;

@end

@interface GetEncryptionValue : NSObject <serveD>{
    
    id <GetEncryptionValueDelegate> Delegate;
    
    @public
        NSNumber *tag;
    
}

@property (nonatomic, retain) NSNumber *tag;
@property (retain) id <GetEncryptionValueDelegate> Delegate;

-(void)getEncryptionData:(NSString *) stringtoEncry;

@end
