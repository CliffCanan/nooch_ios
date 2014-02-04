//
//  core.m
//  Nooch
//
//  Created by Preston Hults on 1/26/13.
//  Copyright (c) 2013 Nooch. All rights reserved.
//

#import "core.h"

@implementation core
-(UIView*)waitStat:(NSString*)label{
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(75,( [[UIScreen mainScreen] bounds].size.height/2)-130, 170, 130)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 15.0;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 20, activityView.bounds.size.width, activityView.bounds.size.height);
    [activityView setBackgroundColor:[UIColor clearColor]];
    [loadingView addSubview:activityView];
    progress = [[UIProgressView alloc] init];
    [progress setFrame:CGRectMake(20, 110, 130, 15)];
    [progress setProgressViewStyle:UIProgressViewStyleBar];
    [progress setTrackTintColor:[UIColor grayColor]];
    [progress setProgressTintColor:[core hexColor:@"3FABE1"]];
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 130, 50)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    [loadingLabel setFont:[self nFont:@"Medium" size:15]];
    [loadingLabel setNumberOfLines:2];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
    loadingLabel.text = label;
    [activityView startAnimating];
    [progress removeFromSuperview];
    return loadingView;
}
-(UIView*)waitStatProg:(NSString*)label{
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(75,( [[UIScreen mainScreen] bounds].size.height/2)-130, 170, 130)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 15.0;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 20, activityView.bounds.size.width, activityView.bounds.size.height);
    [activityView setBackgroundColor:[UIColor clearColor]];
    [loadingView addSubview:activityView];
    progress = [[UIProgressView alloc] init];
    [progress setFrame:CGRectMake(20, 110, 130, 15)];
    [progress setProgressViewStyle:UIProgressViewStyleBar];
    [progress setTrackTintColor:[UIColor grayColor]];
    [progress setProgressTintColor:[core hexColor:@"3FABE1"]];
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 130, 50)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    [loadingLabel setFont:[self nFont:@"Medium" size:15]];
    [loadingLabel setNumberOfLines:2];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
    loadingLabel.text = label;
    [activityView startAnimating];
    [progress removeFromSuperview];
    loadingLabel.text = label;
    [activityView startAnimating];
    [progress setProgress:0];
    [loadingView addSubview:progress];
    return loadingView;
}
-(void)endWaitStat{
    [loadingView removeFromSuperview];
}
-(void)setWaitProg:(float)p{
    [progress setProgress:p];
}
+(BOOL)isAlive:(NSString *)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    else return NO;
}
+(BOOL)isClean:(id)object{
    [object writeToFile:[self path:@"test"] atomically:NO];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self path:@"test"]])return YES;
    else return NO;
}
+(UIColor*)hexColor:(NSString*)hex{
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
+(NSString *)path:(NSString *)type{
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
+(UIFont *)nFont:(NSString*)weight size:(int)size{
    NSString *fontName = [NSString stringWithFormat:@"Roboto"];
    if(![weight isEqualToString:@"def"])
        fontName = [fontName stringByAppendingFormat:@"-%@",weight];
    UIFont *font = [UIFont fontWithName:fontName size:size];
    return font;
}

@end
