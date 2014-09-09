//
//  core.h
//  Nooch
//
//  Created by Preston Hults on 1/26/13.
//  Copyright (c) 2014 Nooch Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "assist.h"
BOOL profileGO;
@interface core : assist{
    UIActivityIndicatorView * activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
    UIProgressView *progress;
}

-(UIView*)waitStat:(NSString*)label;
-(UIView*)waitStatProg:(NSString*)label;
-(void)endWaitStat;
-(void)setWaitProg:(float)p;

+(BOOL)isAlive:(NSString*)path;
+(BOOL)isClean:(id)object;
+(UIColor*)hexColor:(NSString*)hex;
+(NSString *)path:(NSString *)type;
+(UIFont *)nFont:(NSString*)weight size:(int)size;

@end
