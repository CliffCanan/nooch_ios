//
//  ARManager.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//
//  version: 2.4.6
//

#import <Foundation/Foundation.h>

/*
 * This string constant can be used to set an boolean value @YES or @NO in the options dictionary which is an optional argument to startWithAppId:version:options:. Setting this to @YES will allow no one to perform the gesture on a device. The gesture recognizer is not added. @NO is the default.
 */
extern NSString *const ARManagerNeverEnableArtisanGesture;

/**
* Initializes Artisan and manages its lifecycle.
*
* ARManager is a singleton that is automatically initialized when your app starts.  Use ARManager to connect to Artisan and automatically download all experiments, configuration, and published changes for your app.
*
*/

@interface ARManager : NSObject

/** Start your Artisan instance.
 *
 * Use this method to start Artisan.  This declaration should occur at the top of the `didFinishLaunchingWithOptions:` method of your main app delegate.
 *
 * @param appId The Artisan ID for your app (e.g. '506adf5ed6fbbc5222000018'). This ID is available in your Aritsan Tools dashboard.
 */
+(void)startWithAppId:(NSString *)appId;

/** Start your Artisan instance.
*
* Use this method to start Artisan.  This declaration should occur at the top of the `didFinishLaunchingWithOptions:` method of your main app delegate.
*
* @param appId The Artisan ID for your app (e.g. '506adf5ed6fbbc5222000018'). This ID is available in your Aritsan Tools dashboard.
*
* @param version The Artisan version number for your app (e.g '1.0'). This corresponds with the 'Current Version' value in your Artisan Tools dashboard for this app.
*/
+(void)startWithAppId:(NSString *)appId version:(NSString *)version __attribute__((deprecated));

/** Start your Artisan instance.
 *
 * Use this method to start Artisan.  This declaration should occur at the top of the `didFinishLaunchingWithOptions:` method of your main app delegate.
 *
 * @param appId The Artisan ID for your app (e.g. '506adf5ed6fbbc5222000018'). This ID is available in your Aritsan Tools dashboard.
 *
 * @param options Dictionary of configuration options. These options will override the Artisan defaults.
 */
+(void)startWithAppId:(NSString *)appId options:(NSDictionary *)options;

/** Start your Artisan instance.
*
* Use this method to start Artisan.  This declaration should occur at the top of the `didFinishLaunchingWithOptions:` method of your main app delegate.
*
* @param appId The Artisan ID for your app (e.g. '506adf5ed6fbbc5222000018'). This ID is available in your Aritsan Tools dashboard.
*
* @param version The Artisan version number for your app (e.g '1.0'). This corresponds with the 'Current Version' value in your Artisan Tools dashboard for this app.
*
* @param options Dictionary of configuration options. These options will override the Artisan defaults.
*/
+(void)startWithAppId:(NSString *)appId version:(NSString *)version options:(NSDictionary *)options __attribute__((deprecated));

/** Start your Artisan instance.
 *
 * Use this method to start Artisan.  This declaration should occur at the top of the `didFinishLaunchingWithOptions:` method of your main app delegate.
 *
 * This function assume you have ArtisanConfiguration.plist in your project with an AppID set
 */
+(void)startWithConfigurationFile;

/** Set userId for Artisan Logging.
 *
 * Use this method to setup the userId for sending a log message through the Artisan SDK.
 *
 * @param userId The string used to uniquely identify a user's device.
 *
 */
+(void)setLogMessageUserId:(NSString *)userId;

/** Log a message.
 *
 * Use this method to send a log message through the Artisan SDK.
 *
 * @param message The log message.
 *
 */
+(void)logMessage:(NSString *)message;

/** Register block for callback when the first play list is downloaded.
 *
 * Use this method to register a block for callback the first time an Artisan playlist is downloaded.  This call is non-blocking so code execution will continue immediately to the next line of code.
 *
 * The thread calling the block of code is not gaurenteed to be the main thread.  If the code inside of the block requires executing on the main thread you will need to implement this logic.
 *
 * If the first playlist has already been downloaded when this call is made this becomes a blocking call and the block of code is executed immediately.
 *
 * @param block The block of code to be executed.
 *
 */
+(void) onFirstPlaylistDownloaded:(void (^)()) block;

/** Register block for callback when the first play list is downloaded.
 *
 * Use this method to register a block for callback the first time an Artisan playlist is downloaded.  This call is non-blocking so code execution will continue immediately to the next line of code.
 *
 * The thread calling the block of code is guaranteed to be the main thread.  If the code inside of the block requires executing on a background thread you will need to implement this logic.
 *
 * If the first playlist has already been downloaded when this call is made this becomes a blocking call and the block of code is executed immediately.
 *
 * If the timeout is greater than zero the block of code will fire the earliest of the timeout expiring or the first playlist is downloaded.
 *
 * @param block The block of code to be executed.
 * @param timeout The timeout interval in seconds to wait for the playlist to be downloaded.
 *
 */
+(void) onFirstPlaylistDownloaded:(void (^)()) block withTimeout:(NSTimeInterval)timeout;

/** Check if the first Artisan playlist has been downloaded
 *
 * Use this method to see if the Artisan playlist has already been downloaded at least once
 *
 */
+(BOOL) hasFirstPlaylistDownloaded;

@end
