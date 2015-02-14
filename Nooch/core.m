//
//  core.m
//  Nooch
//
//  Created by Preston Hults on 1/26/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import "core.h"

@implementation core

+(BOOL)isAlive:(NSString *)path
{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    else return NO;
}

+(BOOL)isClean:(id)object
{
    [object writeToFile:[self path:@"test"] atomically:NO];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self path:@"test"]])return YES;
    else return NO;
}

+(UIColor*)hexColor:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(NSString *)path:(NSString *)type
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"MemberId"]]];
    if ([type isEqualToString:@"image"])
        return [documentsDirectory stringByAppendingPathExtension:@"png"];
    else if([type isEqualToString:@"core"])
        return [documentsDirectory stringByAppendingPathExtension:@"plist"];
    else if([type isEqualToString:@"recents"])
        return [documentsDirectory stringByAppendingPathComponent:@"-recent.plist"];
    else if([type isEqualToString:@"fb"])
        return [documentsDirectory stringByAppendingPathComponent:@"-fbList.plist"];
    else if([type isEqualToString:@"addr"])
        return [documentsDirectory stringByAppendingPathComponent:@"-addr.plist"];
    else if([type isEqualToString:@"hCheck"])
        return [documentsDirectory stringByAppendingPathComponent:@"History.plist"];
    else if([type isEqualToString:@"hist"])
        return [documentsDirectory stringByAppendingPathComponent:@"History-cache.plist"];
    else if([type isEqualToString:@"test"])
        return [documentsDirectory stringByAppendingPathComponent:@"test"];
    else if([type isEqualToString:@"currentUser"])
        return [documentsDirectory stringByAppendingPathComponent:@"currentUser"];
    else return @"check type...";
}

+(UIFont *)nFont:(NSString*)weight size:(int)size
{
    NSString *fontName = [NSString stringWithFormat:@"Roboto"];
    if(![weight isEqualToString:@"def"])
        fontName = [fontName stringByAppendingFormat:@"-%@",weight];
    UIFont *font = [UIFont fontWithName:fontName size:size];
    return font;
}

@end
