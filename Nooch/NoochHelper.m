//
//  NoochHelper.m
//  Nooch
//
//  Created by administrator on 17/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoochHelper.h"


@implementation NoochHelper

+(NSString*) dateFormater:(NSString*)date
{
    
    NSString *getDate = date;
    NSLog(@"Current Date ****:%@",getDate);
    NSString *dateStr;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormat setTimeZone:timeZone];
    NSDate *currentDate = [dateFormat dateFromString:getDate];
    if (currentDate == NULL) {
        return date; 
    }
    NSLog(@"Current Date ****:%@",currentDate);
    [dateFormat setDateFormat:@"MM/dd/YYYY hh:mm a"];
    dateStr = [dateFormat stringFromDate:currentDate];  
    [dateFormat release];
    NSLog(@"date Format *****:  %@",dateStr);
    return dateStr;
}

+(NSString*)dateWithoutTimeWithAMPM:(NSString*)date
{
    NSLog(@"%@",date);
    NSString *getDate = [date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *dateStr;
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormat setTimeZone:timeZone];
    NSDate *currentDate = [dateFormat dateFromString:getDate];
    if (currentDate == NULL) {
        return date; 
    }
   
    [dateFormat setDateFormat:@"MM/dd/YYYY"];
    dateStr = [dateFormat stringFromDate:currentDate];  
    [dateFormat release];
   
    return dateStr;
}

+(NSString*)dateWithoutTime:(NSString*)date
{
    NSLog(@"%@",date);
    NSString *getDate = [date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *dateStr;
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormat setTimeZone:timeZone];
    NSDate *currentDate = [dateFormat dateFromString:getDate];
    if (currentDate == NULL) {
        return date; 
    }
    
    [dateFormat setDateFormat:@"MM/dd/YYYY"];
    dateStr = [dateFormat stringFromDate:currentDate];  
    [dateFormat release];
    
    return dateStr;
}


+(NSString*)dateTimeStamp:(NSString *)dateString
{

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [dateFormat dateFromString:dateString];
    NSDateFormatter *dateReformat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:timeZone];
    [dateReformat setTimeZone:timeZone];
    [dateReformat setDateFormat:@"hh:mma MM/dd/yyyy"];
    NSString *reformattedDate = [NSString stringWithFormat:@"%@",[dateReformat stringFromDate:date]];
    
    [dateFormat release];
    [dateReformat release];
    NSDate *currentDate = [NSDate date];
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    [numFormat setNumberStyle:NSNumberFormatterSpellOutStyle];
    int time = [date timeIntervalSinceDate:currentDate];
    NSString *dayCheck = [[date description] substringWithRange:NSMakeRange(8, 2)];
    int tranDay = [dayCheck intValue];
    NSString *curDay = [[currentDate description] substringWithRange:NSMakeRange(8, 2)];
    int today = [curDay intValue];
    if (tranDay == today-1 && [[[date description] substringWithRange:NSMakeRange(5, 2)] intValue] == [[[currentDate description] substringWithRange:NSMakeRange(5, 2)] intValue] && [[[date description] substringWithRange:NSMakeRange(0,4)] intValue]
        == [[[currentDate description] substringWithRange:NSMakeRange(0,4)] intValue]) {
        return @"Yesterday";
    }
    time *= -1;
    
    
        if(time < 1) 
        {
            return reformattedDate;
        } 
        else if (time < 60)
        {
            return @"Less than a minute ago";
        } 
        else if (time < 3600)
        {
            int timeDifference = round(time / 60);
            NSNumber *numberValue = [NSNumber numberWithInt:timeDifference];
            
            if (timeDifference == 1) 
                return [NSString stringWithFormat:@"one minute ago"];
            else
                return [NSString stringWithFormat:@"%@ minutes ago", [numFormat stringFromNumber:numberValue]];
        } 
        else if (time < 86400) 
        {
            int timeDifference = round(time / 60 / 60);
            NSNumber *numberValue = [NSNumber numberWithInt:timeDifference];
            if (timeDifference == 1)
                return [NSString stringWithFormat:@"one hour ago"];
            else
                return [NSString stringWithFormat:@"%@ hours ago", [numFormat stringFromNumber:numberValue]];
        } 
        else if (time < 604800)
        {
            int timeDifference = round(time / 60 / 60 / 24);
            NSNumber *numberValue = [NSNumber numberWithInt:timeDifference];
            if (timeDifference == 1) 
                return [NSString stringWithFormat:@"Yesterday"];
            else if (timeDifference == 7)
                return [NSString stringWithFormat:@"Last week"];
            else
                return[NSString stringWithFormat:@"%@ days ago", [numFormat stringFromNumber:numberValue]];
        } 
        else
        {
            int timeDifference = round(time / 60 / 60 / 24 / 7);
            NSNumber *numberValue = [NSNumber numberWithInt:timeDifference];
            if (timeDifference == 1)
                return [NSString stringWithFormat:@"Last week"];
            else
                return [NSString stringWithFormat:@"%@ weeks ago", [numFormat stringFromNumber:numberValue]];
        } 

}

+(NSString*)absoluteDateTimeStamp:(NSString *)dateString
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [dateFormat dateFromString:dateString];
    NSDateFormatter *dateReformat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:timeZone];
    [dateReformat setTimeZone:timeZone];
    [dateReformat setDateFormat:@"hh:mma MM/dd/yyyy"];
    NSString *reformattedDate = [NSString stringWithFormat:@"%@",[dateReformat stringFromDate:date]];
    
    
    [dateFormat release];
    [dateReformat release];
    return reformattedDate;
}

+(NSString*)dayMonthYear:(NSString *)dateString
{

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [dateFormat dateFromString:dateString];
    NSDateFormatter *dateReformat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:timeZone];
    [dateReformat setTimeZone:timeZone];
    [dateReformat setDateFormat:@"MM/dd/yyyy"];
    [dateReformat setDateStyle:NSDateFormatterShortStyle];
    NSString *reformattedDate = [NSString stringWithFormat:@"%@",[dateReformat stringFromDate:date]];


    [dateFormat release];
    [dateReformat release];
    return reformattedDate;
}

+(NSString*)hourMinuteAP:(NSString *)dateString
{

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [dateFormat dateFromString:dateString];
    NSDateFormatter *dateReformat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:timeZone];
    [dateReformat setTimeZone:timeZone];
    [dateReformat setDateFormat:@"h:mma"];
    NSString *reformattedDate = [NSString stringWithFormat:@"%@",[dateReformat stringFromDate:date]];


    [dateFormat release];
    [dateReformat release];
    return reformattedDate;
}

+(NSString*)dayMonthYear2:(NSString *)dateString
{

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss aa"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [dateFormat dateFromString:dateString];
    NSDateFormatter *dateReformat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:timeZone];
    [dateReformat setTimeZone:timeZone];
    [dateReformat setDateFormat:@"MM/dd/yyyy"];
    [dateReformat setDateStyle:NSDateFormatterShortStyle];
    NSString *reformattedDate = [NSString stringWithFormat:@"%@",[dateReformat stringFromDate:date]];


    [dateFormat release];
    [dateReformat release];
    return reformattedDate;
}

+(NSString*)hourMinuteAP2:(NSString *)dateString
{

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss aa"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [dateFormat dateFromString:dateString];
    NSDateFormatter *dateReformat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:timeZone];
    [dateReformat setTimeZone:timeZone];
    [dateReformat setDateFormat:@"h:mma"];
    NSString *reformattedDate = [NSString stringWithFormat:@"%@",[dateReformat stringFromDate:date]];

    [dateFormat release];
    [dateReformat release];
    return reformattedDate;
}

+(NSString*)sendMoneyDateTimeStamp:(NSString *)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormat setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [dateFormat dateFromString:dateString];
    NSDateFormatter *dateReformat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:timeZone];
    [dateReformat setTimeZone:timeZone];
    [dateReformat setDateFormat:@"hh:mma MM/dd/yyyy"];
    NSString *reformattedDate = [NSString stringWithFormat:@"%@",[dateReformat stringFromDate:date]];
    
    
    [dateFormat release];
    [dateReformat release];
    return reformattedDate;
}

+(UIActivityIndicatorView *)newActivityIndicatorAtCenter:(CGPoint)center{

    UIActivityIndicatorView *activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge ] autorelease];
    activityIndicator.frame= CGRectMake(0.0, 0.0, 50.0, 50.0);
    activityIndicator.center = center;
    //activityIndicator.layer.cornerRadius = 3;
    activityIndicator.backgroundColor = [UIColor darkGrayColor];

    return activityIndicator ;
}

@end
