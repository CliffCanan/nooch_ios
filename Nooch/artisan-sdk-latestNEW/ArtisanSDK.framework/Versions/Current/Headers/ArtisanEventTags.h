//
//  ArtisanEventTags.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ArtisanEventTags are a collection of key/values that can be attached to a UIView or UIViewController so that any automatically collected analytics events, like screen view events or button tap events, will be tagged or categorized with the appropriate values.

 The artisanEventTags property is added to your UIViews and UIViewControllers automatically via category.

 You have two options for adding tags: fixed values and selectors.

 <code><pre>
 ArtisanEventTags *extraButtonInfo = [ArtisanEventTags artisanEventTags];
 [extraButtonInfo setValue:self.productDescription.text forKey:@"productDescription"]; // FIXED VALUE TAG
 [extraButtonInfo setSelector:@selector(currentTitle) forKey:@"buttonTitle"];  // SELECTOR TAG
 self.addToCartButton.artisanEventTags = extraButtonInfo;
 </pre></code>

 If you set a fixed value for a tag that value will be used as is, but with a selector the Artisan SDK will perform the given selector on your UIView or UIViewController at the time that the automatically-collected event occurs. This can be useful if there is some data that is dynamic and changing that you want to capture as additional context for a given analytics event.

 You can add as many tags as you like and you can mix and match fixed values and selector values. Duplicate tagName values will overwrite one another; the last value added for a given tagName will be used. Also, selector values will overwrite tagValues with the same tagName.

 Additionally you can register a category, subCategory, and subSubCategory on your ArtisanEventTags and those categories will be applied to the automatically-collected events as well.

 Event tags and categories can be used for filtering Artisan analytics, segmenting your users and targeting Artisan campaigns and experiments.
 */
@interface ArtisanEventTags : NSObject

/**
 This is a convenient method to build an ArtisanEventTags for your UIView or UIViewController.

 <strong>Usage Example from a UIViewController</strong>

 <code><pre>
 - (void)viewWillAppear:(BOOL)animated
 {
   [super viewWillAppear:animated];

   ArtisanEventTags *extraInfoForScreen = [ArtisanEventTags artisanEventTags];
   [extraInfoForScreen setValue:@"HOLIDAY" forKey:@"Shopping Season"];
   self.artisanEventTags = extraInfoForScreen;
 }
 </pre></code>
 */
+ (ArtisanEventTags *)artisanEventTags;

/**
 Register a key/value pair that will be added to any automatically collected events as tags. These tags can be used for filtering Artisan analytics on Artisan Tools.

<h3>Usage Example</h3>

 Here I am adding tags to a UICollectionViewCell so that automatically collected events (e.g. cell selection event) will be tagged with this additional information.

 <code><pre>
 ArtisanEventTags *extraInfoForProduct = [ArtisanEventTags artisanEventTags];
 [extraInfoForProduct setValue:[currentProduct priceAsString] forKey:@"price"];
 [extraInfoForProduct setValue:[currentProduct discountedPriceAsString] forKey:@"discountedPrice"];
 [extraInfoForProduct setValue:currentProduct.name forKey:@"productName"];
 productCell.artisanEventTags = extraInfoForProduct;
 </pre></code>

 @warning Duplicate key values will overwrite one another; the last value added for a given key will be used.

 @param tagValue An NSString that provides an extra informat for this event, e.g. "Womens" or "Mens".
 @param tagName An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 */
- (void)setValue:(NSString *)tagValue forKey:(NSString *)tagName;

/**
 Register a selector whose return value will be added as a tagged variable to the Artisan Event Tags so that any automatically collected events will be tagged with the current value.

<h3>Usage Example</h3>

 Here I am adding a tag for the button title which will perform the currentTitle selector to get the current title of the button at the time that any automatically-collected analytics event is recorded. This could be useful if the title on my button changes while it is on the screen and I want to know what it said when the user tapped on it.

 <code><pre>
 ArtisanEventTags *extraButtonInfo = [ArtisanEventTags artisanEventTags];
 [extraButtonInfo setSelector:@selector(currentTitle) forKey:@"buttonTitle"];
 self.addToCartButton.artisanEventTags = extraButtonInfo;
 </pre></code>

 @warning The UIView or UIViewController to which these ArtisanEventTags are attached must respond to the given selector and the method must return an NSString or this value will be ignored.
 @warning Duplicate key values will overwrite one another; the last value added for a given key will be used. Also, selector values will overwrite tagValues with the same tagName.

 @param selector An NSSelector for a method on either the UIView or UIViewController which returns an NSString value.
 @param tagName An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 */
- (void)setSelector:(SEL)selector forKey:(NSString *)tagName;

/**
 Add a category to the Artisan Event Tags so that any automatically collected events will be categorized accordingly.

<h3>Usage Example</h3>

 <code><pre>
 ArtisanEventTags *extraButtonInfo = [ArtisanEventTags artisanEventTags];
 [extraButtonInfo setCategory:@"Women"];
 self.addToCartButton.artisanEventTags = extraButtonInfo;
 </pre></code>

 @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 */
- (void)setCategory:(NSString *)category;

/**
 Add categories to the Artisan Event Tags so that any automatically collected events will be categorized accordingly.

<h3>Usage Example</h3>

 <code><pre>
 ArtisanEventTags *extraButtonInfo = [ArtisanEventTags artisanEventTags];
 [extraButtonInfo setCategory:@"Women" subCategory:@"Shoes"];
 self.addToCartButton.artisanEventTags = extraButtonInfo;
 </pre></code>

 @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 @param subCategory An NSString that provides a further classification for this event, e.g. "Sweaters" or "Jackets".
 */
- (void)setCategory:(NSString *)category subCategory:(NSString *)subCategory;

/**
 Add categories to the Artisan Event Tags so that any automatically collected events will be categorized accordingly.

<h3>Usage Example</h3>

 <code><pre>
 ArtisanEventTags *extraButtonInfo = [ArtisanEventTags artisanEventTags];
 [extraButtonInfo setCategory:@"Women" subCategory:@"Shoes" subSubCategory:@"Boots"];
 self.addToCartButton.artisanEventTags = extraButtonInfo;
 </pre></code>

 @param category An NSString that provides an extra classification for this event, e.g. "Womens" or "Mens".
 @param subCategory An NSString that provides a further classification for this event, e.g. "Sweaters" or "Jackets".
 @param subSubCategory An NSString that provides even further classification for this event, e.g. "Hoodies" or "Zip-ups".
 */
- (void)setCategory:(NSString *)category subCategory:(NSString *)subCategory subSubCategory:(NSString *)subSubCategory;

@end
