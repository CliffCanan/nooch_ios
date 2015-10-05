//
//  ARPurchaseWorkflowManager.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Manages a purchase workflow with Artisan. This includes recording Artisan analytics events for:
 *
 *  - when items are viewed by the customer
 *  - when items are added or removed from the customer's cart.
 *  - when the cart is abandoned (user left the app without checking out)
 *  - when the customer checks out successfully or unsuccessfully
 *  - when the customer cancels checkout
 *
 *  ARPurchaseWorkflowManager is a singleton that is automatically initialized when your app starts.
 *
 *  NOTE: You do not need to manually track Apple StoreKit purchases--those purchases are already automatically tracked by Artisan.
 *
 *  These analytics events are automatically synced with Artisan and can be used for Advanced segmentation and personalization with the Artisan analytics reports, experiments, power hooks and campaigns.
 */
@interface ARPurchaseWorkflowManager : NSObject

#pragma mark - Item Viewed

/**
 Record an analytics event for a customer viewing a product.
 
 [ARPurchaseWorkflowManager productViewedWithProductIdentifier:@"ABC0000001"
                                                       atPrice:[NSNumber numberWithFloat:24.99f]
                                              withCurrencyCode:@"USD"
                                                andDescription:@"Artisan T-Shirt made in Old City, Philadelphia"
                                                   andCategory:@"T-Shirts"
                                                andSubCategory:@"Crew-Necks"
                                             andSubSubCategory:@"Artisan Paint It Black Tee"
                                               withProductInfo:@{@"style":@"organic cotton",@"size":@"medium"}];
 
 @param productIdentifier An identifier for the product.
 @param price             The price of the item.
 @param currencyCode      The ISO4217 currency code of the given price value.  (optional, may be nil) If this is left nil then the [NSLocale objectForKey:NSLocaleCurrencyCode] will be substituted.
 @param description       A description of the product. (optional, may be nil)
 @param category          The category that you would like to record for this product. (optional, may be nil)
 @param subCategory       The sub category that you would like to record for this product. (optional, may be nil)
 @param subSubCategory    The sub sub category that you would like to record for this product. (optional, may be nil)
 @param productInfo       A dictionary of any key/value pairs of information about this product. This data will be attached to the analytics event in Artisan. All keys and values must be NSString objects, or they will be ignored. (optional, may be nil)
 */
+ (void)productViewedWithProductIdentifier:(NSString *)productIdentifier
                                   atPrice:(NSNumber *)price
                          withCurrencyCode:(NSString *)currencyCode
                            andDescription:(NSString *)description
                               andCategory:(NSString *)category
                            andSubCategory:(NSString *)subCategory
                         andSubSubCategory:(NSString *)subSubCategory
                           withProductInfo:(NSDictionary *)productInfo;

#pragma mark - Item Added To Cart

/**
 Add an item to the cart for the current purchase workflow.
 
 [ARPurchaseWorkflowManager addItemToCartWithProductIdentifier:@"ABC0000001"
                                                       atPrice:[NSNumber numberWithFloat:24.99f]
                                               withCurrencyCode:@"USD"
                                                andDescription:@"Artisan T-Shirt made in Old City, Philadelphia"
                                                   andCategory:@"T-Shirts"
                                                andSubCategory:@"Crew-Necks"
                                             andSubSubCategory:@"Artisan Paint It Black Tee"
                                                   andQuantity:[NSNumber numberWithInt:1]
                                               withProductInfo:@{ @"style":@"organic cotton", @"size":@"medium" }];
 
 @param productIdentifier An identifier for the product
 @param price             The price of the item. This should be the price of a single item.
 @param currencyCode      The ISO4217 currency code of the given price value.  (optional, may be nil) If this is left nil then the [NSLocale objectForKey:NSLocaleCurrencyCode] will be substituted.
 @param description       A description of the product. (optional, may be nil)
 @param category          The category that you would like to record for this product. (optional, may be nil)
 @param subCategory       The sub category that you would like to record for this product. (optional, may be nil)
 @param subSubCategory    The sub sub category that you would like to record for this product. (optional, may be nil)
 @param quantity          The quantity of the product.
 @param productInfo       A dictionary of any key/value pairs of information about this product. This data will be attached to the analytics event in Artisan. All keys and values must be NSString objects, or they will be ignored. (optional, may be nil)
 */
+ (void)addItemToCartWithProductIdentifier:(NSString *)productIdentifier
                                   atPrice:(NSNumber *)price
                          withCurrencyCode:(NSString *)currencyCode
                            andDescription:(NSString *)description
                               andCategory:(NSString *)category
                            andSubCategory:(NSString *)subCategory
                         andSubSubCategory:(NSString *)subSubCategory
                               andQuantity:(NSNumber *)quantity
                           withProductInfo:(NSDictionary *)productInfo;

#pragma mark - Item Removed From Cart

/**
 Call this method to remove an item from the Artisan cart model for the current purchase workflow.

 It will remove the first item in the cart that matches the productIdentifier, price, description and quantity.

    [ARPurchaseWorkflowManager removeItemFromCartWithProductIdentifier:@"ABC0000001"
                                                               atPrice:[NSNumber numberWithFloat:24.99f]
                                                        andDescription:@"Artisan T-Shirt made in Old City, Philadelphia"
                                                            andQuantity:[NSNumber numberWithInt:1]];

 @param productIdentifier The identifier of the cart item that should be removed
 @param price             The price of the cart item that should be removed
 @param description       The description of the cart item that should be removed
 @param quantity          The quantity of the cart item that should be removed
 */
+ (void)removeItemFromCartWithProductIdentifier:(NSString *)productIdentifier
                                        atPrice:(NSNumber *)price
                                 andDescription:(NSString *)description
                                     andQuantity:(NSNumber *)quantity;


#pragma mark - Cart Was Emptied

/**
 *  Remove all items from the cart without marking it as abandoned or checked out.
 *
 *  Usage Example
 *  =============
 *
 *  <code><pre>
 *    [ARPurchaseWorkflowManager emptyCart];
 *  </pre></code>
 */
+ (void)emptyCart;

#pragma mark - Cart Status

/**
 *  Check if there are items in the cart model for this Artisan Purchase Workflow.
 *
 *  @return true if there are any items in the cart model.
 */
+ (BOOL)cartIsNotEmpty;

#pragma mark - Purchase Outcomes

/**
 *  Record that the cart was abandoned.
 *
 *  The items will remain in the cart so that another purchase can be completed. If you want to empty the cart you should use [ARPurchaseWorkflowManager emptyCart]
 *
 *  Usage Example
 *  =============
 *
 *  <code><pre>
 *    [ARPurchaseWorkflowManager cartWasAbandoned];
 *  </pre></code>
 */
+ (void)cartWasAbandoned;

/**
 *  Record that the checkout was cancelled by the customer.
 *
 *  The items will remain in the cart so that another purchase can be completed. If you want to empty the cart you should use [ARPurchaseWorkflowManager emptyCart]
 *
 *  Usage Example
 *  =============
 *
 *  <code><pre>
 *    [ARPurchaseWorkflowManager cartCheckoutWasCancelled];
 *  </pre></code>
 */
+ (void)cartCheckoutWasCancelled;

/**
 *  Record that the checkout failed.
 *
 *  The items will remain in the cart so that another purchase can be completed. If you want to empty the cart you should use [ARPurchaseWorkflowManager emptyCart]
 *
 *  Usage Example
 *  =============
 *
 *  <code><pre>
 *    [ARPurchaseWorkflowManager cartCheckoutFailed];
 *  </pre></code>
 */
+ (void)cartCheckoutFailed;

/**
 *  Record that the cart was checked out successfully. We will record an analytics event including information on all of the products that were purchased. 
 *
 *  We will automatically calculate the cart total and send that with the Artisan analytics event. It is assumed that all items in the cart will have the same price locale; we will use the price locale of the first item.
 *
 *  You may add shipping and tax information here and they will be recorded in the cart total. The amounts are assumed to be in the same priceLocale as the items in the cart.
 *
 *  Usage Example
 *  =============
 *
 *  <code><pre>
 *    [ARPurchaseWorkflowManager cartCheckoutSucceededWithShipping:[NSNumber numberWithFloat:2.25f] withTax:[NSNumber numberWithFloat:3.00f]];
 *  </pre></code>
 *
 *  @param shipping Amount of shipping to add to the cart total to make the transaction total. The amount is assumed to be in the same priceLocale as the items in the cart.
 *  @param tax      Amount of tax to add to the cart total to make the transaction total. The amount is assumed to be in the same priceLocale as the items in the cart.
 */
+ (void)cartCheckoutSucceededWithShipping:(NSNumber *)shipping
                                  withTax:(NSNumber *)tax;

@end
