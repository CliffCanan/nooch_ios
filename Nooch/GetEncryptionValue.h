//
//  GetEncryptionValue.h
//  Nooch
//
//  Created by Nooch on 10/01/14.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetEncryptionValueDelegate <NSObject>
-(void)encryptionDidFinish:(NSString *) encryptedData TValue:(NSNumber *) tagValue;
@end

@interface GetEncryptionValue : NSObject {

    NSMutableData *responseData;
    id <GetEncryptionValueDelegate> Delegate;

@public
    NSNumber *tag;
    
}
@property (nonatomic, retain) NSNumber *tag;
@property (retain) id <GetEncryptionValueDelegate> Delegate;
-(void)getEncryptionData:(NSString *) stringtoEncry;
@end