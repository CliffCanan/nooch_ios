//
//  PXSwatchView.m
//
//  Created by Kevin Lindsey on 6/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSwatchView.h"
#import <PXEngine/PXGraphics.h>

@implementation PXSwatchView
{
    PXShapeGroup *swatches;
}

@synthesize colors;

#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame withColorArray:(NSArray *)someColors
{
    if (self = [super initWithFrame:frame])
    {
        self->colors = someColors;

        [self makeSwatches];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame withColors:(UIColor *)firstColor, ...
{
    NSArray *colorArray = nil;

    if (self = [super initWithFrame:frame])
    {
        NSMutableArray *tempColors = [NSMutableArray array];

        va_list args;
        va_start(args, firstColor);

        for (UIColor *arg = firstColor; arg != nil; arg = va_arg(args, UIColor*))
        {
            [tempColors addObject:arg];
        }

        va_end(args);

        colorArray = [NSArray arrayWithArray:tempColors];
    }

    return [self initWithFrame:frame withColorArray:colorArray];
}

#pragma mark - Setters

- (void)setColors:(NSArray *)someColors
{
    colors = someColors;

    [self makeSwatches];
 
    [self setNeedsDisplay];
}

#pragma mark - Methods

- (void)makeSwatches
{
    PXShapeGroup *group = [[PXShapeGroup alloc] init];

    if (colors)
    {
        CGSize size = self.bounds.size;

        if (size.width >= size.height)
        {
            // horizontal layout
            float deltaX = (float) (size.width / [colors count]) - 1.0;
            float currentX = 0.0;

            for (int i = 0; i < [colors count]; i++, currentX += deltaX)
            {
                CGRect rectBounds = CGRectMake(currentX, 0, deltaX, size.height);
                PXRectangle *rectangle = [[PXRectangle alloc] initWithRect:rectBounds];

                rectangle.fill = [[PXSolidPaint alloc] initWithColor:[colors objectAtIndex:i]];
                [group addShape:rectangle];
                
                currentX+=2;
            }
        }
        else
        {
            // vertical layout
            float deltaY = (float) size.width / [colors count];
            float currentY = 0.0;

            for (int i = 0; i < [colors count]; i++, currentY += deltaY)
            {
                CGRect rectBounds = CGRectMake(0, currentY, size.width, deltaY);
                PXRectangle *rectangle = [[PXRectangle alloc] initWithRect:rectBounds];

                rectangle.fill = [[PXSolidPaint alloc] initWithColor:[colors objectAtIndex:i]];
                [group addShape:rectangle];
            }
        }
    }

    swatches = group;
}

#pragma mark - Overrides

- (void)dealloc
{
    swatches = nil;
    colors = nil;
}

- (void)drawRect:(CGRect)rect
{
    if (swatches)
    {
        [swatches render:UIGraphicsGetCurrentContext()];
    }
}

@end
