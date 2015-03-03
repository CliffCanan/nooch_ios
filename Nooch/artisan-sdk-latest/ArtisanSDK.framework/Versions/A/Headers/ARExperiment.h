//
//  ARExperiment.h
//  ARUXFLIP
//
//  Copyright (c) 2013 Artisan Mobile. All rights reserved.
//
//

#import <Foundation/Foundation.h>

/** 
 * Represents an in-code experiment, including its name and variants.
 *
 * Instead of creating `ARExperiment` objects directly, it's better to
 * use the methods defined in `ARExperimentManager`.
 */

@interface ARExperiment : NSObject {
  BOOL _running;
  NSString *_currentVariant;
  NSMutableArray *_variants;
}

/**The start date of this in-code experiment. This is set automatically by Artisan. If you modify this value you will have unpredictable behavior.

 ** MODIFY AT YOUR OWN RISK. **
 */
@property (nonatomic, strong) NSDate *startDate;

/**The end date of this in-code experiment. This is set automatically by Artisan. If you modify this value you will have unpredictable behavior.

 ** MODIFY AT YOUR OWN RISK. **
 */
@property (nonatomic, strong) NSDate *endDate;

/**
 * The name of the default variant for the test. If no variant has been
 * explicitly defined as the default, it's assumed to be the first variant
 * that was added.
 */
@property (nonatomic, readonly) NSString *defaultVariant;

/**
 * The name of the test.
 */
@property (nonatomic, readonly) NSString *name;

/**
 * The description of the test.
 */
@property (nonatomic, readonly) NSString *experimentDescription;

/**
 * An `NSArray` containing the defined variants for the test (as `NSString` objects).
 */
@property (nonatomic, readonly) NSArray *variants;

/**
 * The current variant for the test. If the test is not running, the
 * default variant is returned. When setting, any values that are not
 * already defined as variants will be ignored.
 */
@property (nonatomic, retain) NSString *currentVariant;

/**
 * The current variant id for the test. If the test is not running
 * this will be nil.
 */
@property (nonatomic, retain) NSString *currentVariantId;

/** Initialize an `ARExperiment`.
 * 
 * @param experimentName The name of the experiment you're creating.
 */
-(id)initWithName:(NSString *)experimentName;

/**
 * Initialize an `ARExperiment` with a description.
 *
 * @param experimentName The name of the experiment you're creating.
 * 
 * @param description The description of the experiment you're creating.
 */
-(id)initWithName:(NSString *)experimentName description:(NSString *)description;


/**
 * Add a variant to the experiment.
 *
 * @param variantName The name of the variant you're adding
 *
 * @param isDefault Whether this is the default variant for this experiment. Note that if this is the first variant for the test, it is assumed to be the default, regardless of the value of `isDefault`, until another variant is added with `isDefault` set to `YES`.
 *
 * @warning Attempting to add two variants with the same name will result in the second being ignored.
 */
-(void)addVariant:(NSString *)variantName isDefault:(BOOL)isDefault;

/**
 * Returns `YES` if the currently running variant is equal to `variantName`, otherwise, `NO` is returned.
 *
 * @param variantName The variant to be checked
 */
-(BOOL)isCurrentVariant:(NSString *)variantName;

/**
 * Starts the experiment with a given variant.
 *
 * @warning This method is intended for local test and QA use only, and should *not* be used within production code. 
 *
 * @param variantName The variant you'd like to use in the experiment.
 *
 */
-(void)startExperiment:(NSString *)variantName;

/**
 * Stops the experiment.
 *
 * @warning This stops the experiment completely, reverting it back to the default variant.
 */
-(void)stopExperiment;

/**
 * Whether the experiment is currently running.
 */
-(BOOL)isRunning;

/**
 Whether an experiment should be running.
 */
- (BOOL)shouldStart;

@end
