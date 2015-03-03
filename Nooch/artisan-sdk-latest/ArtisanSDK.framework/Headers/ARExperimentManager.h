//
//  ARExperimentManager.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* Manages all in-code experiments designed for use with Artisan. This includes:
*  
* - Create in-code experiments
* - Adding variants to in-code experiments
* - Wrapping the code blocks to be executed for each variant
* - Setting additional analytics events to be tracked for in-code experiments
* - Setting the conversion target for an in-code experiment
* - Retrieving information about experiments to tie into third party analytics tools
* 
* ARExperimentManager is a singleton that is automatically initialized when your app starts.  Use ARExperimentManager to manage all of your in-code experiments from inception to completion.
* 
* All in-code experiments created using ARExperimentManager can be registered with Artisan Tools.  The registration process will automatically detect all created experiments along with their variants, and will automatically create a corresponding experiment on the Artisan Tools App page for this app.  This experiment can then be modified, published, and observed like any other Artisan experiment. 
* To test out your experiments before publishing your app, you should use the startExperiment API call to programatically start your experiments in your test environment.
*
* Best Practices
* ==============
*
* - For in-code experiements employing this class, you should test them out prior to shipping to the app store using `startExperiment:variantName:`. This way you can preview their behavior and appearance.
* - Don't forget to remove the call to `startExperiment:variantName:` before you ship.
* - User the getCurrentExperimentDetails and getInCodeExperimentDetails methods to retrieve information on experiments
*
*
* Usage Example
* =============
*
*
*<code><pre>
* //in your app delegate
*-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
*{
*  [ARExperimentManager registerExperiment:@"first experiement" description:@"This is the first experiment"];
*  [ARExperimentManager addVariant:@"hello" forExperiment:@"first experiement" isDefault:YES];
*  [ARExperimentManager addVariant:@"hey" forExperiment:@"first experiement"];
*  [ARExperimentManager addVariant:@"whats up" forExperiment:@"first experiement"];
*  [ARManager startWithAppId:@"517eda139297c44526000006" version:@"1.0"];
*}
*</pre></code>
*
*<code><pre>
* //in your viewcontroller
*-(void) viewDidAppear:(BOOL)animated
*{
*  [ARExperimentManager setExperimentViewedForExperiment:@"first experiment"];
*}
*- (void) viewWillAppear:(BOOL)animated
*{
*    if ([ARExperimentManager isCurrentVariant:@"hey" forExperiment:@"first experiment"]) {
*    //apply variant specific changes to your app in here.
*    //for example, change buttons, labels, colors
*    //alternately, move this if statement to initWithNibName:bundle: and load different nibs for different variants
*    }
*}
* //if your target is a IBAction callback
*-(IBaction) buttonClicked
*{
*   [ARExperimentManager setTargetReachedForExperiment:@"first experiment"];
*}
*</pre></code>
*
*
*/

@interface ARExperimentManager : NSObject


/** Create a new in-code experiment with Artisan.
*
* Use this method to declare the existence of an experiment you want to run with Artisan.  This declaration should occur in the `didFinishLaunchingWithOptions:` method of your main app delegate, *before* you start Artisan using the `[ARManager startWithAppId:version:]` method. 
*
* @param experimentName The name of the experiment to register. This needs to be unique within your app, not including leading and trailing whitespace.
*/

+(void)registerExperiment:(NSString *)experimentName;


/** Create a new in-code experiment with Artisan.
*
* Use this method to declare the existence of an experiment you want to run with Artisan.  This declaration should occur in the `didFinishLaunchingWithOptions:` method of your main app delegate, *before* you start Artisan using the `[ARManager startWithAppId:version:]` method.
* 
* @param experimentName The name of the experiment to register. This needs to be unique within your app, not including leading and trailing whitespace. If you attempt to register multiple experiments with the same name, the first one registered becomes effective.
* 
* @param description The description for this test. This will appear automatically when the test is registered with Artisan Tools.
*/

+(void)registerExperiment:(NSString *)experimentName description:(NSString *)description;



/** Add a variant to an in-code experiment with Artisan.
*
* Use this method to add variants to your Artisan in-code experiment.  Variants should be added immediately after the experiment is created via registerExperiment:experimentName:.  Added variants will automatically be detected when the experiment is registered with Artisan Tools.
*
* @param variantName The name of the variant to add.  This needs to be unique for the experiment. Leading and trailing whitespace will be trimmed.
*
* @param experimentName The name of the experiment to which this variant should be added.  This needs to be the name of an experiment previously created via registerExperiment:experimentName:. Leading and trailing whitespace of experimentName will be trimmed.
*
* @param isDefault Sets whether this variant is the default.  The default variant will be used in instances where the experiment is not active (i.e. completed or not yet published)
*
* @warning At least one variant must be marked as the default.  If no variants as marked as default, the first variant added to the experiment will automatically be the default.
*/

+(void)addVariant:(NSString *)variantName forExperiment:(NSString *)experimentName isDefault:(BOOL)isDefault;



/** Add a variant to an in-code experiment with Artisan.
*
* Use this method to add variants to your Artisan in-code experiment.  Variants should be added immediately after the experiment is created via registerExperiment:experimentName:.  Added variants will automatically be detected when the experiment is registered with Artisan Tools.
*
* @param variantName The name of the variant to add.  This needs to be unique for the experiment. If you add multiple variants with the same name for the same experiment, the first one added becomes effective.
*
* @param experimentName The name of the experiment to which this variant should be added.  This needs to be the name of an experiement previously created via initExperiment:experimentName:. Leading and trailing whitespace of experimentName will be trimmed.
*
* @warning At least one variant must be marked as the default.  If no variants are marked as the default, the first variant added to the experiment will automatically be the default.  Use addVariant:forExperiment:isDefault: to explicitly mark a variant as the default. If multiple variants are marked as default, the last one added will become the default.
*/

+(void)addVariant:(NSString *)variantName forExperiment:(NSString *)experimentName;


/** Check to see which variant is currently active.
*
* Use this method to wrap blocks of code that you want to execute for this variant of the specified experiment.  For example, if you want to set the text of a UILabel to 'Buy Now!' for variant 'A' of experiment 'Buy Button Test', your code would appear as follows:
*
*     `if ([ARExperimentManager isCurrentVariant:@"A" forExperiment:@"Buy Button Test"]) {
*         label.text = @"Buy Now!";
*     }`
*
* Any experiment code can be wrapped in this manner, and these conditional blocks can be used in more than one location throughout your app.
* If you haven't yet called startAppWithId, isCurrentVariant will always return false for everything except the default variant.
*
* @param variantName Name of the variant. This must be the name of a variant already added to this experiment, otherwise `NO` will automatically be returned.
*
* @param experimentName Name of the experiment to which this variant belongs. This must be the name of an experiment already added to this app, otherwise `NO` will automatically be returned. Leading and trailing whitespace of experimentName will be trimmed.
*/

+(BOOL)isCurrentVariant:(NSString *)variantName forExperiment:(NSString *)experimentName;


/** Set the conversion target for the specified experiment.
*
* Use this method to specify what the conversion target should be for an in-code experiment.  The conversion target is the end of your funnel - the action that this variant is trying to maximize.
*
* The target set in code can be overridden by Artisan Tools as necessary.  In these cases, the target will be tracked as an ordinary analytics event.
*
* @warning If no target is specified for an experiment, your conversion rate for this test will default to zero percent. If more than one target is specified for an experiment, the target will be the first conversion event reported by a user device.
*
* @param experimentName Name of the experiment for which the target is being set. Leading and trailing whitespace of experimentName will be trimmed. Must be a valid experiment.
*/

+ (void)setTargetReachedForExperiment:(NSString *)experimentName;


/** Set the conversion target for the specified experiment, with an attached description.
 
 Use this method to specify what the conversion target should be for an in-code experiment.  The conversion target is the end of your funnel - the action that this variant is trying to maximize.
 
 @param experimentName Name of the experiment for which the target is being set. Leading and trailing whitespace of experimentName will be trimmed. Must be a valid experiment.
 
 @param description Description of the target, which will be displayed to the user on the Artisan Tools website.



 @warning If no target is specified for an experiment, your conversion rate for this test will default to zero percent. If more than one target is specified for an experiment, the target will be the first conversion event reported by a user device.
 
*/

+ (void)setTargetReachedForExperiment:(NSString *)experimentName description:(NSString *)description;

/** Indicate that the experiment has been viewed.
 *
 * Use this method to specify that your experiment has been viewed by the user. When this code is triggered, an experiment 'view' officially begins.  This experiment view counts as a 'conversion' if setTargetReachedForExperiment: is called for this experiment before (a) setExperimentViewedForExperiment: gets called again for this experiment or (b) the app is backgrounded.
 *
 * It is essential to call this method at least once for each experiment that you build to ensure that you will get an accurate conversion rate.
 *
 * @warning Placement of this event is critical to creating useful and accurate analytics. Make sure this code fires ONLY when you deem that the user has encountered your experiment. Consider cases where this method is fired, then the target for this experiment is reached, which transitions back to the same code that originally triggered this method. The conversion rate would now be 50%, rather than 100%, since this method was called twice.
 *
 * @param experimentName Name of the experiment that has been viewed. Leading and trailing whitespace will be trimmed. Must be a valid experiment.
 */

+ (void)setExperimentViewedForExperiment:(NSString *)experimentName;

/** Start an in-code Artisan experiment manually.
*
* Use this method to manually apply an experiment built using the Artisan in-code API.  The app will behave as if the experiment has been published and the user has received the variant specified. Because this is a test method not intended for production use, you don't need a valid app ID, nor do you need to call startAppwithId, for this to work. 
*
* This method should be called in   the `didFinishLaunchingWithOptions:` method of your main app delegate, immediately after all of the variants for your test have been added via calls to `addVariant:forExperiment:isDefault:`.
*
* @warning This method is intended for local test and QA use only, and should *not* be used within production code. If you accidentally leave this in your production code, the variant specified will effectively become the default.
*
* @param experimentName Name of the experiment being started. Leading and trailing whitespace will be trimmed. An error will be logged if a valid experiement is not specified.
*
* @param variantName Name of the variant to apply for this experiment.  This should be one of the variants added to the experiment.  If the name is invalid, the experiment will apply the default variant.
*/

+(void)startExperiment:(NSString *)experimentName variantName:(NSString *)variantName;

/** Retrieve all current details for running experiments.
 *
 * @warning It is suggested that the earliest you call this method is within the `[ArtisanManager onFirstPlaylistDownloaded:block]` callback.
 *
 * Returns an `NSArray` of the current experiments which are `ARExperimentDetails` objects.
 */
+(NSArray *)getCurrentExperimentDetails;

/** Retrieve details for all in-code experiments.
 *
 * Usage Example
 * =============
 *
 *<code><pre>
 * // in the view controller you're changing via your in-code experiment
 *- (void) viewWillAppear:(BOOL)animated {
 *    // Your other code...
 *    NSDictionary *detailsDictionary = [ARExperimentManager getInCodeExperimentDetails];
 *    ARInCodeExperimentDetails *inCodeDetails = [detailsDictionary objectForKey:@"Your Experiment Name"];
 *
 *    if (inCodeDetails.isRunning) {
 *        // This experiment has been started from Artisan Tools and all details are available to you.
 *        // You can use these details to feed into your third party analytics tool
 *    }
 *    // Your code continued...
 *}
 *</pre></code>
 *
 * Returns an `NSDictionary` of all in-code experiments where the keys are the in-code name of the experiment and the values are `ARInCodeExperimentDetail` objects.
 */
+(NSDictionary *)getInCodeExperimentDetails;

/** Retrieve the list of all currently active experiment variation ids
 *
 * Returns an `NSSet` of the current experiment variation ids, where the elements are the `NSString` names of the experiment variation ids.
 */
+(NSSet*)getCurrentVariationIds;

@end
