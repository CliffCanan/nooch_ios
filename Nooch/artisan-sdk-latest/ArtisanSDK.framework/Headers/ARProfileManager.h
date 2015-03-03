//
//  ARProfileManager.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum { ARGenderMale, ARGenderFemale, ARGenderNA } ARGender;

/**
 * Manages the Artisan Profiling and Segmentation capability. This includes:
 *
 * - Setting user information for use in targeting experiments and personalizing content.
 * - Collecting user information for analytics reporting and segmentation.
 *
 * ARProfileManager is a singleton that is automatically initialized when your app starts.  Use ARProfileManager to manage the personalization profile for the current user from app inception to completion.
 */
@interface ARProfileManager : NSObject

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setStringValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 */
+(void)registerString:(NSString *)variableName;

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setNumberValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 */
+(void)registerNumber:(NSString *)variableName;

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setDateTimeValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 */
+(void)registerDateTime:(NSString *)variableName;

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setLocationValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 */
+(void)registerLocation:(NSString *)variableName;

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setStringValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 *
 * @param value Initial value for the variable.
 */
+(void)registerString:(NSString *)variableName withValue:(NSString *)value;

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setNumberValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 *
 * @param value Initial value for the variable.
 */
+(void)registerNumber:(NSString *)variableName withValue:(NSNumber *)value;

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setDateTimeValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 *
 * @param value Initial value for the variable.
 */
+(void)registerDateTime:(NSString *)variableName withValue:(NSDate *)value;

/** Register a custom profile variable for this user.
 *
 * This custom variable will be included in this user's personalization profile, and can be used for segmentation, targeting, and reporting purposes.
 *
 * Once registered, the value for this variable can be set using setLocationValue:forVariable:.  The default value is nil.
 *
 * @param variableName Name of the variable to register for the current user.  Valid characters for this name include [0-9],[a-z],[A-Z], -, and _.  Any other characters will automatically be stripped out.
 *
 * @param value Initial value for the variable.
 */
+(void)registerLocation:(NSString *)variableName withValue:(CLLocationCoordinate2D)value;


/** Set or update the value associated with a custom string profile variable.
 *
 * This new value will be used as part of this user's personalization profile, and will be used from this point forward for segmentation, targeting, and reporting purposes.
 *
 * @param value Value to use for the given variable.
 *
 * @param variableName Variable to which this value should be assigned.
 */

+(void)setStringValue:(NSString *)value forVariable:(NSString *)variableName;

/** Set or update the value associated with a custom number profile variable.
 *
 * This new value will be used as part of this user's personalization profile, and will be used from this point forward for segmentation, targeting, and reporting purposes.
 *
 * @param value Value to use for the given variable.
 *
 * @param variableName Variable to which this value should be assigned.
 */

+(void)setNumberValue:(NSNumber *)value forVariable:(NSString *)variableName;

/** Set or update the value associated with a custom date profile variable.
 *
 * This new value will be used as part of this user's personalization profile, and will be used from this point forward for segmentation, targeting, and reporting purposes.
 *
 * @param value Value to use for the given variable.
 *
 * @param variableName Variable to which this value should be assigned.
 */

+(void)setDateTimeValue:(NSDate *)value forVariable:(NSString *)variableName;

/** Set or update the value associated with a custom location profile variable.
 *
 * This new value will be used as part of this user's personalization profile, and will be used from this point forward for segmentation, targeting, and reporting purposes.
 *
 * @param value Value to use for the given variable.
 *
 * @param variableName Variable to which this value should be assigned.
 */

+(void)setLocationValue:(CLLocationCoordinate2D)value forVariable:(NSString *)variableName;

/** Specify an external User ID for the current user.
 *
 * Use this method to connect the current user of this app with an ID in your user management system.  For example, if your user management system has a user whose ID is 'ABC123456' and that user logs into this app, you can use this method to pass that ID to Artisan as part of the personalization profile for this user.  You can then use this ID to trace the data collected by Artisan directly to an existing user in your system.
 *
 * @param sharedUserId The ID string to associate with the current user.
 */
+(void)setSharedUserId:(NSString *)sharedUserId;

/** Specify the age for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the age in years of the current user.
 *
 * @param age The age of the current user.
 */
+(void)setUserAge:(NSNumber*)age;

/** Specify the gender of the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param gender The gender of the current user.  Possible values for ARGender include ARGenderMale, ARGenderFemale, and ARGenderNA.
 *
 */
+(void)setGender:(ARGender)gender;

/** Clear out all previously specified profile information.
 *
 * Use this method to clear out all data previously specified for the current user, including any data set via setSharedUserId:, setUserAge:, setUserAddress:, setGender:, setUserAddress:, and setValue:forVariable:.
 */
+(void)clearProfile;

/** Clear the value for the specified user profile variable
 *
 * Use this method to clear a custom user profile variable for the current user. This is equivalent to setting the value to nil.
 *
 * To clear an Artisan-provided user profile variable like sharedUserId or userAge, simply set the value to nil with the provided setter method.
 */
+(void)clearVariable:(NSString *)variableName;

/** Specify whether to submit user profile information to Artisan Analytics.
 *
 * The user profile information collected via setSharedUserId:, setUserAge:, setUserAddress:, setGender, and setValue:forVariable: is sent by default to Artisan Analytics to enrich the experiment results.  Use this API call to deactivate (or reactivate) collection of this data.
 *
 * If profile data is not enabled for analytics collection, it can still be used to target experiments to specific user segments.
 *
 * @param enabled Whether to enable collection of user profile data by Artisan Analytics.
 */

+(void)enableProfileAnalytics:(BOOL)enabled;

/** Specify the prefix for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the prefix of the current user (Mr, Ms, Mrs, etc)
 *
 * @param userPrefix The prefix of the current user.
 */
+(void)setUserPrefix:(NSString *)userPrefix;

/** Specify the first name for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the first name of the current user as a string.
 *
 * @param userFirstName The first name of the current user.
 */
+(void)setUserFirstName:(NSString *)userFirstName;

/** Specify the middle name for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the middle name of the current user as a string.
 *
 * @param userMiddleName The middle name of the current user.
 */
+(void)setUserMiddleName:(NSString *)userMiddleName;

/** Specify the last name for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the last name of the current user as a string.
 *
 * @param userLastName The last name of the current user.
 */
+(void)setUserLastName:(NSString *)userLastName;

/** Specify the suffix for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the suffix of the current user (Jr, Sr, I, etc)
 *
 * @param userSuffix The suffix of the current user.
 */
+(void)setUserSuffix:(NSString *)userSuffix;

/** Specify the email for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the email of the current user
 *
 * @param userEmail The email of the current user.
 */
+(void)setUserEmail:(NSString *)userEmail;

/** Specify the phone number for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the phone number of the current user as a string
 *
 * @param userPhoneNumber The phone number of the current user.
 */
+(void)setUserPhoneNumber:(NSString *)userPhoneNumber;

/** Specify the company name for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the company name of the current user
 *
 * @param userCompany The company name of the current user.
 */
+(void)setUserCompanyName:(NSString *)userCompany;

/** Specify the date first seen for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the first seen date of the current user
 *
 * @param firstSeen The date first seen of the current user.
 */
+(void)setFirstSeen:(NSDate *)firstSeen;

/** Specify the sign up date for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the sign up date of the current user
 *
 * @param signUp The sign up date of the current user.
 */
+(void)setSignUpDate:(NSDate *)signUp;

/** Specify the twitter name for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the twitter name of the current user
 *
 * @param userTwitterName The twitter name of the current user.
 */
+(void)setUserTwitterName:(NSString *)userTwitterName;

/** Specify the facebook profile for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the facebook profile of the current user
 *
 * @param userFacebook The facebook profile of the current user.
 */
+(void)setUserFacebook:(NSString *)userFacebook;

/** Specify the url for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is the url of the current user
 *
 * @param userUrl The url of the current user.
 */
+(void)setUserUrl:(NSString *)userUrl;

/** Specify whether the user has opted out of push notifications.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is whether the user has opted out of push
 *
 * @param optedOutOfPush Whether the current user has push enabled.
 */
+(void)setOptedOutPush:(BOOL)optedOutOfPush;

/** Specify whether the user has opted out of text.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is whether the user has opted out of text
 *
 * @param optedOutOfText Whether the current user has text enabled.
 */
+(void)setOptedOutText:(BOOL)optedOutOfText;

/** Specify whether the user has opted out of email.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 * This is whether the user has opted out of email
 *
 * @param optedOutOfEmail Whether the current user has email enabled.
 */
+(void)setOptedOutEmail:(BOOL)optedOutOfEmail;

/** Specify the street address for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userStreet The street address of the current user.
 *
 */
+(void)setUserStreetAddress:(NSString *)userStreet;

/** Specify the street address 2 for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userStreet2 The street address 2 of the current user (apartment number, etc)
 *
 */
+(void)setUserStreetAddress2:(NSString *)userStreet2;

/** Specify the city for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userCity The city of the current user
 *
 */
+(void)setUserCity:(NSString *)userCity;

/** Specify the state or province for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userStateProvince The state or province of the current user
 *
 */
+(void)setUserStateProvince:(NSString *)userStateProvince;

/** Specify the country for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userCountry The country of the current user
 *
 */
+(void)setUserCountry:(NSString *)userCountry;

/** Specify the postal code for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userPostalCode The postal code of the current user
 *
 */
+(void)setUserPostalCode:(NSString *)userPostalCode;

/** Specify the referral source for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userReferralSource The referral source of the current user
 *
 */
+(void)setUserReferralSource:(NSString *)userReferralSource;

/** Specify the avatar url for the current user.
 *
 * This information is added to the personalization profile of the current user for segmentation, targeting, and reporting purposes.
 *
 * @param userAvatar The avatar url of the current user
 *
 */
+(void)setUserAvatarUrl:(NSString *)userAvatar;




@end