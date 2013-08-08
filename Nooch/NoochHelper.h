//
//  NoochHelper.h
//  Nooch
//
//  Created by administrator on 17/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoochHelper : NSObject {
    
}

+(NSString*) dateFormater:(NSString*)date;
+(NSString*)dateTimeStamp:(NSString *)dateString;
+(NSString*)absoluteDateTimeStamp:(NSString *)dateString;
+(NSString*)sendMoneyDateTimeStamp:(NSString *)dateString;
+(NSString*)dateWithoutTime:(NSString*)date;
+(NSString*)dateWithoutTimeWithAMPM:(NSString*)date;
+(NSString*)hourMinuteAP:(NSString *)dateString;
+(NSString*)dayMonthYear:(NSString *)dateString;
+(NSString*)hourMinuteAP2:(NSString *)dateString;
+(NSString*)dayMonthYear2:(NSString *)dateString;
+(UIActivityIndicatorView *) newActivityIndicatorAtCenter:(CGPoint)center;


@end
