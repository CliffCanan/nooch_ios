//
//  PXSwatchView.h
//
//  Created by Kevin Lindsey on 6/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PXSwatchView : UIView

@property (nonatomic, strong) NSArray *colors;

- (id)initWithFrame:(CGRect)frame withColorArray:(NSArray *)colors;
- (id)initWithFrame:(CGRect)frame withColors:(UIColor *)firstColor, ... NS_REQUIRES_NIL_TERMINATION;

@end
