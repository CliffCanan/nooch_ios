//
//  ARPowerHookVariable.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Manages the Power Hook variable instance:
 *
 * - Retrieve hookId
 * - Retrieve value
 * - register a block to be executed when the Power Hook's value changes
 *
 * You can get an ARPowerHookVariable by calling ARPowerHookManager getPowerHookVariable: and passing in the hookId that you originally registered with Artisan.
 */
@interface ARPowerHookVariable : NSObject

/** Return the hookId for this Power Hook variable.
 *
 */
-(NSString *) hookId;

/** Return the value for this Power Hook variable.
 *
 */
-(NSString *) value;

/** Return the value for this Power Hook variable as a BOOL.
 * YES, yes, Y, y, 1, TRUE, true, T, t will return YES
 * any other value will return NO
 *
 * NOTE: if the conversion fail the method will return NO
 */
-(BOOL) valueAsBool;

/** Return the value for this Power Hook variable as an int.
 *
 * NOTE: if the conversion fail the method will return 0
 */
-(int) valueAsInt;

/** Return the value for this Power Hook variable as a float.
 *
 * NOTE: if the conversion fail the method will return 0
 */
-(int)valueAsFloat;

/** Specify a block to call when the Power Hook value changes.
 *
 * The thread calling the block of code is guaranteed to be the main thread.  If the code inside of the block requires executing on a background thread you will need to implement this logic.
 *
 * The block accepts the paramter `previewMode` which identifies if the app is currently in previewMode or not.
 *
 * This call should be made each time the containing class (i.e. UIViewController) is used (i.e. viewWillAppear).
 *
 * @param block The block will be called when the Power Hook values changes.
 */
-(void) onPowerHookChanged:(void (^)(BOOL previewMode)) block;

/** Unregister the registered block called when the Power Hook value changes.
 *
 * This call should be made when the containing class (i.e. UIViewController) is no longer displayed (i.e. viewWillDisappear).
 *
 * @param block The block will be called when the Power Hook values changes.
 */
-(void) unregisterPowerHookChanged;

@end
