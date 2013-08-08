//
//  PXLogoSplashViewController.m
//  PXButtonDemo
//
//  Created by Kevin Lindsey on 6/16/12.
//  Copyright (c) Pixate, Inc. All rights reserved.
//

#import "PXLogoSplashViewController.h"
#import <PXEngine/PXGraphics.h>

@implementation PXLogoSplashViewController
{
    PXRadialGradient *backgroundGradient;
    PXScene *backgroundScene;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        // set title and image for tab view
        self.title = @"Pixate Splash";
        self.tabBarItem.image = [UIImage imageNamed:@"08-chat"];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Use the following to set the shape view resource from code
    //((PXShapeView *) self.view).resourcePath = @"my-vector-file";
    
    backgroundScene = ((PXShapeView *) self.view).scene;
    PXShape *backgroundRect = (PXShape *) [backgroundScene shapeForName:@"background"];
    backgroundGradient = backgroundRect.fill;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get the point where we touched the view
    UITouch *theTouch = [touches anyObject];
    CGPoint where = [theTouch locationInView:self.view];
    
    CGAffineTransform matrix = [((PXShapeGroup *)backgroundScene.shape) viewPortTransform];
    matrix = CGAffineTransformInvert(matrix);
    where = CGPointApplyAffineTransform(where, matrix);

    CGPoint startCenter = where;
    CGPoint endCenter = backgroundGradient.endCenter;
    
    CGFloat dx = startCenter.x - endCenter.x;
    CGFloat dy = startCenter.y - endCenter.y;
    
    CGFloat radius = sqrt(dx * dx + dy * dy);
    
    if(radius <= backgroundGradient.radius)
    {
        backgroundGradient.startCenter = where;
        [self.view setNeedsDisplay];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [(PXShapeView *)self.view applyBoundsToScene];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return NO;
    }
    else
    {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
}


@end
