//
//  ARTrackingManager.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Manages all in-code analytics tracking designed for use with Artisan, to allow you
 * to track both views and events.
 */

@interface ARTrackingManager : NSObject

/** Tracks an event with Artisan
 *
 * Use this to track any custom events you'd like to view in your Artisan dashboard.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 */

+ (void)trackEvent:(NSString *)eventName;

/** Track an event with Artisan with additional data.
 *
 * Use this to track an event with Artisan and also supply additional data.
 * For instance, if you have a product page that you want to check, but you
 * also want to be able to know which products are being viewed, you could
 * track an event named "Viewed Product" and pass the product id as additional data.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 *
 * @param parameters An NSDictionary representing additional parameters associated with the event. All keys and values must be NSString objects, or they will be ignored.
 */

+ (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

/** Track an event with Artisan with additional data and category.
 *
 * Use this to track an event with additional data and cateogy.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 *
 * @param parameters An NSDictionary representing additional parameters associated with the event. All keys and values must be NSString objects, or they will be ignored.
 *
 * @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 */

+ (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters category:(NSString *)category;

/** Track an event with Artisan with an additional category.
 *
 * Use this to track an event with an additional category.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 *
 * @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 */

+ (void)trackEvent:(NSString *)eventName category:(NSString *)category;

/** Track an event with Artisan with additional data, category, and sub category.
 *
 * Use this to track an event with additional data, category, and sub category.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 *
 * @param parameters An NSDictionary representing additional parameters associated with the event. All keys and values must be NSString objects, or they will be ignored.
 *
 * @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 *
 * @param subCategory An NSString that provides a further classification for this event, e.g. "Sweaters" or "Jackets".
 */

+ (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters category:(NSString *)category subCategory:(NSString *)subCategory;

/** Track an event with Artisan with an additional category and sub category.
 *
 * Use this to track an event with an additional category and sub category.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 *
 * @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 *
 * @param subCategory An NSString that provides a further classification for this event, e.g. "Sweaters" or "Jackets".
 */

+ (void)trackEvent:(NSString *)eventName category:(NSString *)category subCategory:(NSString *)subCategory;

/** Track an event with Artisan with additional data, category, sub category, and sub sub category.
 *
 * Use this to track an event with additional data, category, sub category, and sub sub category.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 *
 * @param parameters An NSDictionary representing additional parameters associated with the event. All keys and values must be NSString objects, or they will be ignored.
 *
 * @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 *
 * @param subCategory An NSString that provides a further classification for this event, e.g. "Sweaters" or "Jackets".
 *
 * @param subSubCategory An NSString that provides even further classification for this event, e.g. "Hoodies" or "Zip-ups".
 */

+ (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters category:(NSString *)category subCategory:(NSString *)subCategory subSubCategory:(NSString *)subSubCategory;

/** Track an event with Artisan with an additional category, sub category, and sub sub category.
 *
 * Use this to track an event with an additional category, sub category, and sub sub category.
 *
 * @param eventName The name of the event you're tracking, e.g. "Purchased Product" or "Logged In".
 *
 * @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 *
 * @param subCategory An NSString that provides a further classification for this event, e.g. "Sweaters" or "Jackets".
 *
 * @param subSubCategory An NSString that provides even further classification for this event, e.g. "Hoodies" or "Zip-ups".
 */

+ (void)trackEvent:(NSString *)eventName category:(NSString *)category subCategory:(NSString *)subCategory subSubCategory:(NSString *)subSubCategory;

+ (void)trackWebViewElement:(NSString *)eventName parameters:(NSDictionary *)parameters;
+ (void)trackWebViewPage:(NSString *)url;
@end
