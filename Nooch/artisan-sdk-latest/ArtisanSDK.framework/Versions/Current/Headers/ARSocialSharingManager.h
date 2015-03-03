//
//  ARSocialSharingManager.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Manages tracking social sharing events with Artisan.
 *
 *  This includes recording Artisan analytics events for each share to a social network along with any additional information that you would like to track.
 *
 *  NOTE: There is no need to manually track share events if you are using Apple SocialFramework for sharing to social networks. Artisan is already automatically collecting analytics events for shares via the SocialFramework.
 *
 *  ARSocialSharingManager is a singleton that is automatically initialized when your app starts.
 *
 *  These analytics events are automatically synced with Artisan and can be used for Advanced segmentation and personalization with the Artisan analytics reports, experiments, power hooks and campaigns.
 */
@interface ARSocialSharingManager : NSObject

/**
 Record a social sharing event with Artisan.

    [ARSocialSharingManager shareOnServiceType:@"Flickr" wasSuccessful:YES];
    [ARSocialSharingManager shareOnServiceType:@"Flickr" wasSuccessful:NO];

 @param serviceType The type of the social service that is being shared on. This can be any value that is useful to you.
 @param successful  Whether the share was successful
 */
+ (void)shareOnServiceType:(NSString *)serviceType wasSuccessful:(BOOL)successful;

/**
 Record a social sharing event with Artisan with additional information.

    [ARSocialSharingManager shareOnServiceType:@"Flickr" wasSuccessful:YES withMetadata:@{@"post-description":postDescription}];

 @param serviceType The type of the social service that is being shared on. This can be any value that is useful to you.
 @param successful  Whether the share was successful
 @param metadata    A dictionary of key value pairs containing any additional information that you would like to record for this social event. All keys and values must be NSString objects, or they will be ignored.
 */
+ (void)shareOnServiceType:(NSString *)serviceType wasSuccessful:(BOOL)successful withMetadata:(NSDictionary *)metadata;

@end
