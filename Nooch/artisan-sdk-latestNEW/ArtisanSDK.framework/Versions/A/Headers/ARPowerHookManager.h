//
//  ARPowerHookManager.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARPowerHookVariable.h"

/**
* Manages all Power Hooks used with Artisan. This includes:
*
* - Registering hooks to be set dynamically by Artisan Tools.
* - Referencing these hooks in the code.
* - Registering blocks whose arguments can be set dynamically by Artisan Tools.
* - Referencing these blocks in the code.
* - Providing test methods to verify the impact of different hooks on your app code.
*
* Power Hooks are key-value pairs or code blocks with key-value arguments that are passed into your application code by Artisan when your app starts, allowing for settings, text, and logic to be modified on the fly for all user devices without revisioning or updating your application.
*
* ARPowerHookManager is a singleton that is automatically initialized when your app starts.
*
* All hooks created using ARPowerHookManager are registered with Artisan Tools automatically when you connect your device to Artisan for the first time.  The registration process will detect all registered hook keys, and will display all of the hooks and code blocks for this app in Artisan Tools where they can be edited.  Values set on hooks on the web will automatically be downloaded by all devices upon app startup, allowing for their usage throughout your system code.
*/
@interface ARPowerHookManager : NSObject

/**
* Registers a single-value (non-code-block) Power Hook for use with Artisan.
*
* Use this method to declare the existence of a Power Hook you would like to pass in from Artisan.  This declaration should occur in the `didFinishLaunchingWithOptions:` method of your main app delegate, *before* you start Artisan using the `[ARManager startWithAppId:version:]` method.
*
* @param hookId The name of the configuration setting to register. Name must be unique for this app.
* @param friendlyName The name for this hook that will be displayed in Artisan Tools.
* @param defaultValue The default value for this hook.  This value will be used if no value is passed in from Artisan Tools for this app.
*/
+(void)registerHookWithId:(NSString *)hookId friendlyName:(NSString *)friendlyName defaultValue:(NSString *)defaultValue;


/**
* Gets the value of a single-value (non-code-block) Power Hook.
*
* Use this method to get the value of a Power Hook from Artisan.  This will return the value specified in Artisan Tools, or the default value if none has been specified.
*
* @param hookId The name of the Power Hook you wish to retrieve. Will return nil if the setting has not been registered.
*/
+(NSString *)getValueForHookById:(NSString *)hookId;


/** Set the value of a single-value (non-code-block) Power Hook manually.
*
* Use this method to manually apply a value to an Artisan Power Hook.  The app will behave as if this value has been passed from Artisan Tools, and all calls to getValueForhookId: for this hookId will return this value.
*
* This method should be called in the `didFinishLaunchingWithOptions:` method of your main app delegate, immediately after regstering the corresponding hookId.
*
* @warning *Note:* This method is intended for local test and QA use only, and should *not* be used within production code.
*
* @param hookId The name of the Power Hook whose value you want to set.
* @param value The value you want to specify for this Power Hook.  If the Power Hook has not been registered, this will be ignored.
*/
+(void)setValueForHookById:(NSString *)hookId value:(NSString *)value;

/** Retrieve all registered single-value (non-code-block) Power Hooks.
 *
 * Returns an `NSDictionary` of the current Power Hooks, where the keys are the `NSString` names of the hooks, and the values are `NSDictionary` objects that map friendly_name to the friendly name and default_value to the default value.
 * 
 * You don't need to call startAppWithId:variantName prior to calling getSingleValuePowerHooks.
 */
+ (NSDictionary *)getSingleValuePowerHooks;

/** Retrieve an ARPowerHookVariable instance for the passed in hookId.
 *
 * Returns an ARPowerHookVariable instance.  The ARPowerHookVariable instance is immutable and will contain the current value.
 *
 * @param hookId The name of the Power Hook whose ARPowerHookVariable instance you want to retrieve.
 */
+(ARPowerHookVariable *) getPowerHookVariable:(NSString *)hookId;

/**
 * Registers a Power Hook Block for use with Artisan.
 *
 * Use this method to declare the existence of a code block you would like to use in your app with data that is configurable from Artisan.
 * This declaration should occur in the `didFinishLaunchingWithOptions:` method of your main app delegate, *before* you start Artisan using the `[ARManager startWithAppId:version:]` method.
 *
 * *NOTE:* If this block is executed from an Artisan Push message or URL the thread calling the block of code is guaranteed to be the main thread. If the code inside of the block requires executing on a background thread you will need to implement this logic.
 *
 * @param blockId The name of the code to register. Name must be unique for this app.
 * @param friendlyName The name for this code block that will be displayed in Artisan Tools.
 * @param data The default data for this code block. This should be string keys and values. This data will be used if no data is passed in from Artisan Tools for this code block for this app.
 * @param block The reusable block of code that you are registering with Artisan. When you later call executeBlock you can provide extra_data and context that can be used by your block. We will merge the values from Artisan Tools with this extra data.
 */
+ (void)registerBlockWithId:(NSString *)blockId friendlyName:(NSString *)friendlyName data:(NSDictionary *)data andBlock:(void (^)(NSDictionary *extra_data, id context)) block;


/**
 *  Bind a power hook to a string property on one of your UI elements
 *
 *  @param powerHookId the hookId of your power hook. This is the same id that you registered it with in your AppDelegate
 *  @param element     The UI element that you'd like to bind a property on, for example a UIButton.
 *  @param attribute   The attribute of the given element that you'd like to bind this pwoer hook to.
 */
+ (void)bindPowerHookAsStringToUIElementProperty:(NSString *)powerHookId
                                       UIElement:(id)element
                                       attribute:(NSString *)attribute;

/**
 *  Bind a power hook to a string property on one of your UI elements. The power hook value will be passed into the string with format as a string.
 *
 *  @param powerHookId the hookId of your power hook. This is the same id that you registered it with in your AppDelegate
 *  @param stringWithFormat The string to bind to the attribute for the given element. The power hook value will be passed in as the argument to the string with format, so you should have just one token to replace.
 *  @param element     The UI element that you'd like to bind a property on, for example a UIButton.
 *  @param attribute   The attribute of the given element that you'd like to bind this pwoer hook to.
 */
+ (void)bindPowerHookAsStringToUIElementProperty:(NSString *)powerHookId
                                stringWithFormat:(NSString *)stringWithFormat
                                       UIElement:(id)element
                                       attribute:(NSString *)attribute;

/**
 *  Bind a power hook to a string property on one of your UI elements. The power hook value will be passed into the string with format as an int.
 *
 *  @param powerHookId the hookId of your power hook. This is the same id that you registered it with in your AppDelegate. This power hook should have a value that can be cast to an int.
 *  @param stringWithFormat The string to bind to the attribute for the given element. The power hook value will be passed in as the argument to the string with format, so you should have just one token to replace.
 *  @param element     The UI element that you'd like to bind a property on, for example a UIButton.
 *  @param attribute   The attribute of the given element that you'd like to bind this pwoer hook to.
 */
+ (void)bindPowerHookAsIntegerToUIElementProperty:(NSString *)powerHookId
                                 stringWithFormat:(NSString *)stringWithFormat
                                        UIElement:(id)element
                                        attribute:(NSString *)attribute;
/**
 *  Bind a power hook to a string property on one of your UI elements. The power hook value will be passed into the string with format as a float.
 *
 *  @param powerHookId the hookId of your power hook. This is the same id that you registered it with in your AppDelegate. This power hook should have a value that can be cast to a float.
 *  @param stringWithFormat The string to bind to the attribute for the given element. The power hook value will be passed in as the argument to the string with format, so you should have just one token to replace.
 *  @param element     The UI element that you'd like to bind a property on, for example a UIButton.
 *  @param attribute   The attribute of the given element that you'd like to bind this pwoer hook to.
 */
+ (void)bindPowerHookAsFloatToUIElementProperty:(NSString *)powerHookId
                               stringWithFormat:(NSString *)stringWithFormat
                                      UIElement:(id)element
                                      attribute:(NSString *)attribute;

/**
 * Execute the Power Hook Code Block
 *
 * Use this method to execute a Power Hook Code Block from Artisan.  This will use the values specified in Artisan Tools to execute the block. The default data will be used if none has been specified in Artisan Tools.
 *
 * @param blockId The name of the code to register. Name must be unique for this app. If no block has been registered with the given id this will do nothing.
 * @param extra_data Additional data to use when executing this block. If any keys match, this data will override the defaults and any values that come from Artisan Tools.
 * @param context Any object that you would like to pass in that is used in the block.
 */
+ (void)executeBlockWithId:(NSString *)blockId data:(NSDictionary *)extra_data context:(id)context;

/** Set the data for a code block manually.
 *
 * Use this method to manually apply a value to an Artisan code block.  The app will behave as if this value has been passed from Artisan Tools, and all calls to executeBlockWithName: for this blockName will execute with the given data instead of the defaults.
 *
 * This method should be called in the `didFinishLaunchingWithOptions:` method of your main app delegate, immediately after regstering the corresponding block.
 *
 * @warning *Note:* This method is intended for local test and QA use only, and should *not* be used within production code.
 *
 * @param blockId The name of the code block setting whose data you want to set.
 * @param data The data you want to specify for this code block.  If the code block has not been registered, this will be ignored.
 */
+ (void)setDataForBlock:(NSString *)blockId data:(NSDictionary *)data;

/** Retrieve names and data for all registered Power Hook Code Blocks.
 *
 * Returns an `NSDictionary` of the registered code blocks, where the keys are the `NSString` blockIds of the experiments, and the values are `NSDictionary` objects that map friendly_name to the friendly name and default_data to the default data.
 *
 * You don't need to call startAppWithId:variantName prior to calling getSingleValuePowerHooks.
 */
+ (NSDictionary *)getAllCodeBlocksData;

/** Register a block for callback when any Power Hook variables have changed.
 *
 * The thread calling the block of code is guaranteed to be the main thread.  If the code inside of the block requires executing on a background thread you will need to implement this logic.
 *
 * The block accepts the parameter `previewMode` which identifies if the app is currently in previewMode or not.
 *
 * This call should be made each time the containing class (i.e. UIViewController) is used (i.e. viewWillAppear).
 *
 * @param block The block of code to be executed.
 *
 */
+(void) onPowerHooksChanged:(void (^)(BOOL previewMode)) block;

@end
