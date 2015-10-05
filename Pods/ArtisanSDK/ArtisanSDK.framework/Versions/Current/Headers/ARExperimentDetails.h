//
//  ARExperimentDetails.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DetailDictionaryExperimentNameKey;
extern NSString *const DetailDictionaryExperimentIdKey;
extern NSString *const DetailDictionaryExperimentTypeKey;
extern NSString *const DetailDictionaryCurrentVariationKey;
extern NSString *const DetailDictionaryCurrentVariationIdKey;
extern NSString *const DetailDictionaryCurrentVariationNameKey;

/**
 * An object containing useful information about an experiment
 **/

@interface ARExperimentDetails : NSObject

/**
 * The id of the experiment.
 */
@property (nonatomic, readonly) NSString *experimentId;

/**
 * The name of the experiment.
 */
@property (nonatomic, readonly) NSString *experimentName;

/**
 * The type of the experiment.
 */
@property (nonatomic, retain) NSString *experimentType;

/**
 * The current variant id for the experiment.
 */
@property (nonatomic, retain) NSString *currentVariantId;

/**
 * The current variant name for the experiment.
 */
@property (nonatomic, retain) NSString *currentVariantName;

/**
 * This is the init to build the ARExperimentDetails object.
 * You won't need to use this;
 */
- (id)initWithDictionary:(NSDictionary *)detailsDictionary;

@end
