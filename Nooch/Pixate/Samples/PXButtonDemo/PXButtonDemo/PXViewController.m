//
//  PXViewController.m
//  PXButtonDemo
//
//  Created by Paul Colton on 6/8/12.
//  Copyright (c) Pixate, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PXViewController.h"
#import "PXKuler.h"
#import "PXSwatchView.h"

#import <PXEngine/PXEngine.h>
#import <PXEngine/PXGraphics.h>

@implementation PXViewController
{
    float startingButtonWidth;
    UIView *headerCell;
    UILabel *headerLabel;
    PXStylesheet *stylesheet;
}

@synthesize kulers;
@synthesize myButton, myButton2, myButton3, myButton4;
@synthesize tableView;
@synthesize cssTextView;
@synthesize sliderView;
@synthesize sliderLabel;
@synthesize buttonView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        kulers = [PXKuler getKulers];
        self.title = @"Button Demo";
        self.tabBarItem.image = [UIImage imageNamed:@"28-star"];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up the css text view
    [self styleTextView:cssTextView];
    [cssTextView resignFirstResponder];

    // Style default sliders
    [[UISlider appearance] setThumbTintColor:[UIColor colorWithHexString:@"33819e"]];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor colorWithHexString:@"484848"]];
    [[UISlider appearance] setMinimumTrackTintColor:[UIColor colorWithHexString:@"33819e"]];

    // Style our table
    [[UITableView appearance] setBackgroundColor:[UIColor blackColor]];
    tableView.separatorColor = [UIColor clearColor];

    // Set starting width of buttons
    self->startingButtonWidth = myButton.bounds.size.width;

    // Select a starting color from the table
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self performSelector:@selector(selectTableIndex:)
               withObject:[NSArray arrayWithObjects:tableView, indexPath, nil]
               afterDelay:.3];
}

- (void)viewDidUnload
{
    [self setMyButton:nil];
    [self setMyButton2:nil];
    [self setMyButton3:nil];
    [self setMyButton4:nil];

    [self setTableView:nil];
    [self setCssTextView:nil];
    [self setButtonView:nil];
    [self setSliderView:nil];
    [self setSliderLabel:nil];
//    [self setErrorView:nil];
    [super viewDidUnload];
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

#pragma mark - Convenience functions

//
// Convenience function to style our textview
//
- (void)styleTextView:(UITextView *)textView
{
    [[textView layer] setBorderColor:[[UIColor colorWithRed:193.0/255
                                                      green:195.0/255.0
                                                       blue:196.0/255.0
                                                      alpha:1.0] CGColor]];
    [[textView layer] setBorderWidth:2];
    [[textView layer] setCornerRadius:6];
    [textView setClipsToBounds: YES];
    [textView setDelegate:self];
}


#pragma mark - picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [kulers count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)cachedCell
{
    UIView *cell = cachedCell;

    cell = [self createCell:cell forItemAtRow:row];

    return cell;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setKulerTheme:row];
}

- (IBAction)buttonPressed:(id)sender
{
}

- (IBAction)radiusSlider:(id)sender
{
    /* NOT USED RIGHT NOW
     
    UISlider *slider = (UISlider *) sender;
    float val = [slider value];
    CGFloat newWidth;

    if (val < 20.0)
    {
        myButton.cornerRadius = val;
        myButton2.cornerRadius = val;
        myButton3.cornerRadius = val;
        myButton4.cornerRadius = val;

        newWidth = startingButtonWidth;
    }
    else
    {
        float ratio = (val - 20.0) / 20.0;

        newWidth = 39.0 + (188.0 * (1.0 - ratio));
    }

    CGRect buttonBounds = myButton.bounds;
    CGPoint buttonOrigin = buttonBounds.origin;
    CGRect newBounds = CGRectMake(buttonOrigin.x, buttonOrigin.y, newWidth, buttonBounds.size.height);

    myButton.bounds = newBounds;
    myButton2.bounds = newBounds;
    myButton3.bounds = newBounds;
    myButton4.bounds = newBounds;

    [myButton setNeedsDisplay];
    [myButton2 setNeedsDisplay];
    [myButton3 setNeedsDisplay];
    [myButton4 setNeedsDisplay];
     */
}

- (void)selectTableIndex:(NSArray *)params
{
    [self tableView:[params objectAtIndex:0] didSelectRowAtIndexPath:[params objectAtIndex:1]];
}


#pragma mark -- helpers

- (UIView *) createCell:(UIView *)cell forItemAtRow:(int)row
{
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PXKulerPickerCell" owner:nil options:nil] objectAtIndex:0];
        ((UITableViewCell *) cell).selectionStyle = UITableViewCellSelectionStyleNone;
    }

    id item = [kulers objectAtIndex:row];

    PXSwatchView *swatch = (PXSwatchView *)[cell viewWithTag:1];
    [swatch setColors:[item valueForKey:@"colors"]];

    UILabel *label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%02d.", row + 1]; //[item valueForKey:@"title"];

    return cell;
}

- (void) setKulerTheme:(int)row
{
    NSArray *colors = [[kulers objectAtIndex:row] valueForKey:@"colors"];

    self.view.backgroundColor = [colors objectAtIndex:2];

    NSString *css1 = [PXViewController cssGradientFromColor:[colors objectAtIndex:0]];
    NSString *css2 = [PXViewController cssGradientFromColor:[colors objectAtIndex:1]];
    NSString *css3 = [PXViewController cssGradientFromColor:[colors objectAtIndex:3]];
    NSString *css4 = [PXViewController cssGradientFromColor:[colors objectAtIndex:4]];

    CGFloat r,b,g,a;
    [self.view.backgroundColor getRed:&r green:&g blue:&b alpha:&a];

    [cssTextView setText:[NSString stringWithFormat:
                          @"#button1 {\n%@}\n"
                          @"#button2 {\n%@}\n"
                          @"#button3 {\n%@}\n"
                          @"#button4 {\n%@}\n"
                          @"button {\n\tborder-width: 5px;\n}\n"
                          @"#background {\n\tbackground-color: rgb(%d,%d,%d);\n}"
                          , css1, css2, css3, css4,
                          (int)(r*255), (int)(255*g), (int)(b*255)
                          ]];

    [cssTextView resignFirstResponder];

    [UIView transitionWithView:self.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self applyStyle];
                    }
                    completion:^(BOOL finished) {
                        cssTextView.selectedRange = NSMakeRange(0, 0);
                    }];

}

- (void)applyStyle
{
    [PXEngine styleSheetFromSource:cssTextView.text withOrigin:PXStylesheetOriginUser];
    [PXEngine applyStylesheets];
}

#pragma mark -- Table view

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(headerCell == nil)
    {
        headerCell = [[[NSBundle mainBundle] loadNibNamed:@"PXTableHeader" owner:nil options:nil] objectAtIndex:0];
        headerLabel = (UILabel *)[headerCell viewWithTag:1];
    }
    return headerCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [kulers count];
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    [self setKulerTheme:row];
    id item = [kulers objectAtIndex:row];
    headerLabel.text = [NSString stringWithFormat:@"Theme: %@", [item valueForKey:@"title"]];

    UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    label.textColor = [UIColor whiteColor];
}

-(void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    label.textColor = [UIColor darkGrayColor];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KulerCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = (UITableViewCell *) [self createCell:cell forItemAtRow:indexPath.row];
    return cell;
}

#pragma mark -- UITextView delegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self performSelector:@selector(applyStyle) withObject:nil afterDelay:1.0];
    return YES;
}

#pragma mark -- Utils

/**
 * Returns CSS gradient for a specified starting UIColor
 *
 * Example
 *
 *      border: linear-gradient(
 rgba(r,g,b,a),
 rgba(r,g,b,a));
 
 *      background-color: linear-gradient(
 rgba(r,g,b,a),
 rgba(r,g,b,a));
 *
 */
+ (NSString *)cssGradientFromColor:(UIColor *)color
{
    float hue, saturation, lightness, alpha;
    float saturationDelta = .06;
    float lightnessDelta = .11;
    
    [color getHue:&hue saturation:&saturation lightness:&lightness alpha:&alpha];
    
    
    UIColor *topColor  = [UIColor colorWithHue:hue saturation:saturation-saturationDelta lightness:lightness-lightnessDelta*1.30 alpha:1];
    UIColor *bottomColor  = [UIColor colorWithHue:hue saturation:saturation-saturationDelta lightness:lightness*.50 alpha:1];
    
    UIColor *borderColorTop = [UIColor colorWithHue:hue saturation:saturation+saturationDelta lightness:lightness+lightnessDelta alpha:1];
    UIColor *borderColorBottom = [UIColor colorWithHue:hue saturation:saturation-saturationDelta lightness:lightness-lightnessDelta alpha:1];
    
    NSMutableString *css = [[NSMutableString alloc] init];
    
    CGFloat r, g, b, a;
    
    [borderColorTop getRed:&r green:&g blue:&b alpha:&a];
    
    
    [css appendFormat:@"\tborder-color: linear-gradient(rgb(%d,%d,%d), ",
     (int)(r*255),
     (int)(g*255),
     (int)(b*255)
     ];
    
    [borderColorBottom getRed:&r green:&g blue:&b alpha:&a];
    
    [css appendFormat:@"rgb(%d,%d,%d));\n",
     (int)(r*255),
     (int)(g*255),
     (int)(b*255)
     ];
    
    [topColor getRed:&r green:&g blue:&b alpha:&a];
    
    [css appendFormat:@"\tbackground-color: linear-gradient(rgb(%d,%d,%d), ",
     (int)(r*255),
     (int)(g*255),
     (int)(b*255)
     ];
    
    [bottomColor getRed:&r green:&g blue:&b alpha:&a];
    
    [css appendFormat:@"rgb(%d,%d,%d));\n",
     (int)(r*255),
     (int)(g*255),
     (int)(b*255)
     ];
    
    if (lightness < 0.5)
    {
        [css appendString:@"\tcolor: white;\n"];
    }
    else
    {
        [css appendString:@"\tcolor: black;\n"];
    }
    
    return css;
}

@end
